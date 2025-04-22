job "sample-dotnet-webapp" {
  datacenters = ["homelab"]

  group "web" {
    count = 1

    restart {
      attempts = 2
      delay    = "10s"
      mode     = "delay"
    }

    network {
      port "http" {
        static = 8080
      }
    }

    task "app" {
      driver = "docker"

      config {
        image = "mcr.microsoft.com/dotnet/samples:aspnetapp" # Use the Microsoft .NET sample image
        ports = ["http"] # Expose port 8080 using the label defined in the network block
      }

      resources {
        cpu    = 500 # 500 MHz
        memory = 1024 # 1024 MB
      }
    }
  }

  # Define how Nomad should update the application.  This is a rolling update.
  update {
    stagger        = "30s" # Time between updating each instance
    max_parallel = 1     # Update one instance at a time
    min_healthy_time = "10s" #  Wait this long after an instance starts before considering it healthy.
                            #  Crucial:  Should be long enough for your .NET app to start and pass the health check.
    auto_revert   = true # Automatically revert if the update fails
    canary        = 0 # Number of canary instances to deploy first (0 for no canary)
  }
}