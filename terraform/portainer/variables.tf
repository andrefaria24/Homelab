variable "portainer_address" {
  description = "Portainer address"
  type        = string
}
variable "portainer_api_key" {
  description = "Portainer API key"
  type        = string
  sensitive   = true
}

variable "repo_url" {
  description = "URL of the Git repository"
  type        = string
}

variable "stack_configuration" {
  description = "Shared Portainer stack defaults and per-stack overrides"

  type = object({
    defaults = object({
      deployment_type               = string
      method                        = string
      repository_reference_name     = string
      git_repository_authentication = bool
      repository_git_credential_id  = number
      tlsskip_verify                = bool
      support_relative_path         = bool
      update_interval               = string
      stack_webhook                 = bool
      pull_image                    = bool
      force_update                  = bool
      prune                         = bool
      active                        = bool
    })

    stacks = map(object({
      name                    = string
      file_path_in_repository = string
      update_interval         = optional(string)
      active                  = optional(bool)
    }))
  })

  default = {
    defaults = {
      deployment_type               = "swarm"
      method                        = "repository"
      repository_reference_name     = "refs/heads/master"
      git_repository_authentication = false
      repository_git_credential_id  = 0
      tlsskip_verify                = false
      support_relative_path         = false
      update_interval               = "24h"
      stack_webhook                 = false
      pull_image                    = false
      force_update                  = false
      prune                         = false
      active                        = false
    }

    stacks = {
      hello_world = {
        name                    = "hello-world"
        file_path_in_repository = "docker/hello-world-stack.yml"
        update_interval         = "72h"
      }
      uptime_kuma = {
        name                    = "uptime-kuma"
        file_path_in_repository = "docker/uptimekuma-stack.yml"
        active                  = true
      }
      convertx = {
        name                    = "convertx"
        file_path_in_repository = "docker/convertx-stack.yml"
      }
      pulse = {
        name                    = "pulse"
        file_path_in_repository = "docker/pulse-stack.yml"
        active                  = true
      }
      vault = {
        name                    = "vault"
        file_path_in_repository = "docker/vault-stack.yml"
        active                  = true
      }
      nginx_reverse_proxy = {
        name                    = "nginx-reverse-proxy"
        file_path_in_repository = "docker/nginx-reverse-proxy-stack.yml"
        active                  = true
      }
      mealie = {
        name                    = "mealie"
        file_path_in_repository = "docker/mealie-stack.yml"
      }
      hermes = {
        name                    = "hermes"
        file_path_in_repository = "docker/hermes-stack.yml"
      }
    }
  }
}
