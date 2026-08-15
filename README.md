# Homelab

Infrastructure-as-code for a Proxmox-based homelab running a Docker Swarm. Packer builds VM templates, Ansible prepares and joins the Docker hosts, Portainer deploys the application stacks from this repository, and Terraform manages Portainer and HashiCorp Vault configuration.

## Architecture

```text
Proxmox
  └─ Ubuntu VMs built from Packer templates
       └─ Docker Swarm configured by Ansible
            ├─ Portainer and Portainer Agent
            ├─ Git-backed application stacks
            └─ Persistent bind mounts on the shared NFS path

Vault supplies secrets and PKI services to the environment.
Nginx Proxy Manager provides HTTP/HTTPS ingress for internal applications.
```

The example Ansible inventory models one Swarm manager and three workers. Actual hostnames and topology are supplied through the ignored `ansible/hosts` file.

## Repository layout

| Path | Purpose |
| --- | --- |
| `docker/` | Docker Swarm stack files and the Vault server configuration |
| `terraform/portainer/` | Portainer environment and Git-backed stack resources |
| `terraform/vault/` | Vault auth methods, policies, KV v2, and PKI configuration |
| `terraform/proxmox/` | Proxmox provider configuration and VM defaults |
| `packer/proxmox/` | Ubuntu Server 24.04 and Windows Server 2022 templates |
| `ansible/` | Docker installation, Swarm formation, storage mounts, CA installation, and Linux updates |
| `_archive/` | Retired or superseded configurations; not part of the active deployment |

## Docker Swarm stacks

Portainer itself is bootstrapped from `docker/portainer-stack.yml`. Terraform then manages the Portainer environment and the other eight Git-backed stacks. The status below is the desired `active` setting in Terraform, not a real-time health report.

Each application stack has a health check for its primary service and uses a dedicated attachable overlay network. Persistent application data is bind-mounted from host paths supplied through Portainer variables. The Portainer agent is deployed globally and does not have an explicit Compose health check.

The Ansible storage playbook mounts the NFS export `nas.local.andrecfaria.com:/volume1/docker-swarm` at `/mnt/docker-swarm` on Docker hosts. Any bind-mounted path used by a movable Swarm service must exist consistently on every eligible node.

### Portainer deployment behavior

The Terraform stack resources share these defaults:

- Docker Swarm deployment from the `master` branch of `repo_url`.
- Unauthenticated Git access with TLS verification enabled.
- A `24h` repository polling interval.
- Webhooks, forced updates, forced image pulls, relative paths, and pruning disabled.
- New stacks default to inactive.

`hello-world` overrides the polling interval to `72h`. Uptime Kuma, Pulse, Vault, and Nginx Proxy Manager override the default status and are active.

Stack environment values are intentionally managed in Portainer rather than Terraform:

```hcl
lifecycle {
  ignore_changes = [env]
}
```

This prevents routine Terraform updates from removing Portainer-managed values such as `AWS_REGION` and `VAULT_AWSKMS_SEAL_KEY_ID`. Terraform state can still contain values returned by the Portainer API, so the state must be treated as sensitive.

Vault also expects the following external Docker secrets to exist before its stack is deployed:

- `vault_aws_access_key_id`
- `vault_aws_secret_access_key`

Both existing secrets are imported as `portainer_docker_secret` resources and protected with `prevent_destroy`. Docker does not return secret payloads after creation, so Terraform manages their names and metadata but does not contain the existing AWS credential values. Preserve the Terraform state; recreating or rotating either secret requires supplying a new value deliberately.

## Provisioning workflow

### 1. Build Proxmox templates

Packer definitions are provided for:

- Ubuntu Server 24.04, VM ID `8000`, using cloud-init and credentials read from Vault.
- Windows Server 2022, VM ID `9000`, using an unattended installation, WinRM, Windows Update, and Sysprep.

Create a private `packer/proxmox/vars.pkr.hcl` from the example, then initialize and build from the relevant template directory:

```bash
packer init .
packer validate -var-file=../vars.pkr.hcl .
packer build -var-file=../vars.pkr.hcl .
```

The Ubuntu build expects Vault connectivity for its Proxmox API credentials. The Windows build expects the Proxmox API variables in addition to the values shown in the shared example, and also requires the ignored unattended template, VirtIO drivers, and guest-tools executable under `build_files/`.

### 2. Configure Docker hosts

Create local Ansible configuration from the examples:

```bash
cd ansible
cp ansible.cfg.example ansible.cfg
cp hosts.example hosts
ansible-galaxy collection install -r requirements.yml
```

The main playbooks are:

```bash
ansible-playbook docker-setup.yml
ansible-playbook docker-swarm-share-mount.yml
ansible-playbook docker-swarm-setup.yml
ansible-playbook install-local-ca.yml
```

`docker-setup.yml` installs Docker Engine on Ubuntu. The Swarm playbook initializes the first manager, joins remaining managers and workers, and keeps Docker's data root local at `/var/lib/docker`. The NFS playbook provides shared application storage under `/mnt/docker-swarm`.

The CA playbook requires `ansible/files/local.andrecfaria.com-ca-chain.pem`, which is intentionally not committed. `docker-swarm-share-mount.yml` uses `ansible.posix.mount`; install the `ansible.posix` collection if it is not already available in the Ansible environment.

### 3. Bootstrap Portainer

Run this once from a Swarm manager after creating the Portainer data and certificate directories:

```bash
export DOCKER_SWARM_STORAGE=/mnt/docker-swarm/volumes
docker stack deploy --compose-file docker/portainer-stack.yml portainer
```

Portainer connects to the global agent service at `tasks.agent:9001`. Agent certificate verification is disabled in the current bootstrap stack and Terraform environment configuration. The UI is exposed over `9443`, with `9000` also published by the current stack definition.

### 4. Manage Portainer with Terraform

The Portainer configuration requires Terraform `>= 1.10.0` and provider `portainer/portainer` `1.34.3`.

Create `terraform/portainer/terraform.auto.tfvars` locally:

```hcl
portainer_address = "https://portainer.example.internal:9443"
portainer_api_key = "ptr_..."
repo_url          = "https://github.com/example/homelab"
```

Then run:

```bash
cd terraform/portainer
terraform init
terraform plan
terraform apply
```

The eight stacks are represented by one `for_each` resource. Shared defaults and the per-stack inventory are centralized in `variables.tf`.

Do not run `apply` against an existing Portainer installation with an empty state. Restore the secured Terraform state or import the existing environment and stacks first. Portainer stack import IDs use:

```text
<endpoint_id>-<stack_id>-<deployment_type>-<method>
```

For example, the Vault stack in the current environment uses `1-6-swarm-repository`.

### 5. Configure Vault with Terraform

The Vault configuration provides:

- Google OIDC authentication and a `google-admin` role.
- An `admin` policy loaded from `terraform/vault/policies/admin-policy.hcl`.
- A KV version 2 secrets engine mounted at `kv`.
- A PKI mount named from the configured root domain and a server-certificate role.

Create `terraform/vault/terraform.auto.tfvars` from its example, then run the normal Terraform workflow from `terraform/vault`.

The Vault container uses AWS KMS auto-unseal and file-backed storage. Its current listener is plain HTTP on port `8200` because `tls_disable = "true"`; HTTPS is expected to be terminated by the reverse proxy.

## Proxmox Terraform status

`terraform/proxmox` configures the Proxmox and Vault providers and defines common VM settings. Proxmox API credentials are read ephemerally from Vault so they are not persisted in Terraform state. No Proxmox VM resources are currently declared, so this directory does not create infrastructure yet.

There is a current mount-name mismatch to resolve before using this configuration: the Vault Terraform module creates KV v2 at `kv`, while the Proxmox Terraform and Ubuntu Packer definitions read Proxmox credentials from `kvv2`.

## Secrets and local files

The repository intentionally ignores:

- Terraform state, `.terraform/`, and `*.auto.tfvars`.
- Ansible inventory and configuration.
- Packer variable files, caches, unattended templates, drivers, and executables.
- Docker `.env` files.
- Certificates.

Never commit API keys, Vault tokens, passwords, Docker secret contents, certificates, or Terraform state. For shared use, store Terraform state in an encrypted remote backend with locking and tightly controlled access.
