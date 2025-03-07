job "hello_world" {
  datacenters = ["homelab"]

  group "test" {
    network {
      port "http" {
        static = "5678"
      }
    }
    task "server" {
      driver = "docker"

      config {
        image = "hashicorp/http-echo"
        ports = ["http"]
        args = [
          "-listen",
          ":5678",
          "-text",
          "hello world",
        ]
      }
    }
  }
}