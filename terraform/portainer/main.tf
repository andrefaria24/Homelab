resource "portainer_environment" "docker" {
  name                   = "docker"
  environment_address    = "tcp://tasks.agent:9001"
  public_ip              = "tcp://tasks.agent:9001"
  type                   = 2
  group_id               = 1
  tls_enabled            = true
  tls_skip_client_verify = true
  tls_skip_verify        = true
}

locals {
  portainer_stacks = {
    for stack_key, stack in var.stack_configuration.stacks :
    stack_key => merge(
      var.stack_configuration.defaults,
      { for attribute, value in stack : attribute => value if value != null }
    )
  }
}

resource "portainer_stack" "stacks" {
  for_each = local.portainer_stacks

  endpoint_id     = portainer_environment.docker.id
  name            = each.value.name
  deployment_type = each.value.deployment_type
  method          = each.value.method

  repository_url            = var.repo_url
  repository_reference_name = each.value.repository_reference_name
  file_path_in_repository   = each.value.file_path_in_repository

  git_repository_authentication = each.value.git_repository_authentication
  repository_git_credential_id  = each.value.repository_git_credential_id
  tlsskip_verify                = each.value.tlsskip_verify
  support_relative_path         = each.value.support_relative_path

  update_interval = each.value.update_interval
  stack_webhook   = each.value.stack_webhook
  pull_image      = each.value.pull_image
  force_update    = each.value.force_update
  prune           = each.value.prune
  active          = each.value.active

  lifecycle {
    ignore_changes = [env]
  }
}

moved {
  from = portainer_stack.hello_world
  to   = portainer_stack.stacks["hello_world"]
}

moved {
  from = portainer_stack.uptime_kuma
  to   = portainer_stack.stacks["uptime_kuma"]
}

moved {
  from = portainer_stack.convertx
  to   = portainer_stack.stacks["convertx"]
}

moved {
  from = portainer_stack.pulse
  to   = portainer_stack.stacks["pulse"]
}

moved {
  from = portainer_stack.vault
  to   = portainer_stack.stacks["vault"]
}

moved {
  from = portainer_stack.nginx_reverse_proxy
  to   = portainer_stack.stacks["nginx_reverse_proxy"]
}

moved {
  from = portainer_stack.mealie
  to   = portainer_stack.stacks["mealie"]
}

moved {
  from = portainer_stack.hermes
  to   = portainer_stack.stacks["hermes"]
}
