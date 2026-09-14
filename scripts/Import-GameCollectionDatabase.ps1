[CmdletBinding()]
param(
  [string]$SourceDatabase = "C:\Dev\game-collection-site\data\game-collection.db",
  [string]$TargetNode = "docker-1",
  [string]$TargetDirectory = "/var/lib/game-collection/data",
  [string]$PortainerVariablesFile = "$PSScriptRoot\..\terraform\portainer\terraform.auto.tfvars"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $SourceDatabase -PathType Leaf)) {
  throw "Source database not found: $SourceDatabase"
}
if ($TargetDirectory -notmatch '^/var/lib/[A-Za-z0-9._/-]+$') {
  throw "TargetDirectory must be a path below /var/lib"
}
$containerTargetDirectory = $TargetDirectory -replace '^/var/lib', '/host-var-lib'

$variables = Get-Content -Raw -LiteralPath $PortainerVariablesFile
$portainerAddress = [regex]::Match(
  $variables,
  'portainer_address\s*=\s*"([^"]+)"'
).Groups[1].Value
$portainerApiKey = [regex]::Match(
  $variables,
  'portainer_api_key\s*=\s*"([^"]+)"'
).Groups[1].Value

if (-not $portainerAddress -or -not $portainerApiKey) {
  throw "Portainer address or API key is missing from $PortainerVariablesFile"
}

$headers = @{ "X-API-Key" = $portainerApiKey }
$dockerApi = "$portainerAddress/api/endpoints/1/docker"
$temporaryDatabase = Join-Path (
  [System.IO.Path]::GetTempPath()
) "game-collection-import-$([guid]::NewGuid().ToString('N')).db"
$temporaryServiceId = $null
$temporaryConfigId = $null

try {
  Push-Location (Split-Path -Parent $SourceDatabase)
  try {
    node -e @'
const Database = require("better-sqlite3");
const database = new Database(process.argv[1], { readonly: true });
database.backup(process.argv[2])
  .then(() => database.close())
  .catch((error) => {
    console.error(error.message);
    process.exit(1);
  });
'@ $SourceDatabase $temporaryDatabase
    if ($LASTEXITCODE -ne 0) {
      throw "Could not create a consistent SQLite backup"
    }
  }
  finally {
    Pop-Location
  }

  $expectedHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $temporaryDatabase).Hash.ToLowerInvariant()

  $services = Invoke-RestMethod -Uri "$dockerApi/services" -Headers $headers
  $gameCollectionService = $services |
    Where-Object { $_.Spec.Name -eq "game-collection-stack_game-collection" } |
    Select-Object -First 1
  if ($gameCollectionService -and $gameCollectionService.Spec.Mode.Replicated.Replicas -gt 0) {
    throw "Stop service '$($gameCollectionService.Spec.Name)' before replacing its database"
  }

  $nodes = Invoke-RestMethod -Uri "$dockerApi/nodes" -Headers $headers
  $node = $nodes |
    Where-Object { $_.Description.Hostname -eq $TargetNode } |
    Select-Object -First 1
  if (-not $node) {
    throw "Swarm node not found: $TargetNode"
  }

  $gameCollectionLabelProperty = $node.Spec.Labels.PSObject.Properties[
    "game_collection"
  ]
  $gameCollectionLabel = if ($gameCollectionLabelProperty) {
    $gameCollectionLabelProperty.Value
  }
  else {
    $null
  }
  if ($gameCollectionLabel -ne "true") {
    $labels = @{}
    if ($node.Spec.Labels) {
      $node.Spec.Labels.PSObject.Properties | ForEach-Object {
        $labels[$_.Name] = [string]$_.Value
      }
    }
    $labels.game_collection = "true"
    $nodeSpec = @{
      Labels       = $labels
      Role         = $node.Spec.Role
      Availability = $node.Spec.Availability
    }
    $updateNode = @{
      Method      = "Post"
      Uri         = "$dockerApi/nodes/$($node.ID)/update?version=$($node.Version.Index)"
      Headers     = $headers
      ContentType = "application/json"
      Body        = $nodeSpec | ConvertTo-Json -Depth 10
    }
    Invoke-RestMethod @updateNode | Out-Null
  }

  $suffix = [guid]::NewGuid().ToString("N")
  $configName = "game-collection-db-import-$suffix"
  $configBody = @{
    Name = $configName
    Data = [Convert]::ToBase64String(
      [IO.File]::ReadAllBytes($temporaryDatabase)
    )
  }
  $createConfig = @{
    Method      = "Post"
    Uri         = "$dockerApi/configs/create"
    Headers     = $headers
    ContentType = "application/json"
    Body        = $configBody | ConvertTo-Json -Depth 10
  }
  $config = Invoke-RestMethod @createConfig
  $temporaryConfigId = $config.ID

  $serviceBody = @{
    Name = "game-collection-db-import-$suffix"
    TaskTemplate = @{
      ContainerSpec = @{
        Image   = "alpine:3.22"
        Command = @("/bin/sh", "-c")
        Args    = @(
          "mkdir -p $containerTargetDirectory && cp /seed/game-collection.db $containerTargetDirectory/game-collection.db && echo '$expectedHash  $containerTargetDirectory/game-collection.db' | sha256sum -c - && chown 1000:1000 $containerTargetDirectory $containerTargetDirectory/game-collection.db && chmod 0755 $containerTargetDirectory && chmod 0644 $containerTargetDirectory/game-collection.db"
        )
        Mounts = @(
          @{
            Type   = "bind"
            Source = "/var/lib"
            Target = "/host-var-lib"
          }
        )
        Configs = @(
          @{
            ConfigID   = $temporaryConfigId
            ConfigName = $configName
            File       = @{
              Name = "/seed/game-collection.db"
              UID  = "0"
              GID  = "0"
              Mode = 292
            }
          }
        )
      }
      RestartPolicy = @{ Condition = "none" }
      Placement     = @{
        Constraints = @("node.labels.game_collection==true")
      }
    }
    Mode = @{ Replicated = @{ Replicas = 1 } }
  }
  $createService = @{
    Method      = "Post"
    Uri         = "$dockerApi/services/create"
    Headers     = $headers
    ContentType = "application/json"
    Body        = $serviceBody | ConvertTo-Json -Depth 20
  }
  $service = Invoke-RestMethod @createService
  $temporaryServiceId = $service.ID

  $deadline = (Get-Date).AddSeconds(55)
  $taskState = $null
  $taskMessage = $null
  $taskError = $null
  do {
    Start-Sleep -Seconds 2
    $filters = [uri]::EscapeDataString(
      (@{ service = @($temporaryServiceId) } | ConvertTo-Json -Compress)
    )
    $task = Invoke-RestMethod -Uri "$dockerApi/tasks?filters=$filters" -Headers $headers |
      Select-Object -First 1
    if ($task) {
      $taskState = $task.Status.State
      $taskMessage = $task.Status.Message
      $taskErrorProperty = $task.Status.PSObject.Properties["Err"]
      $taskError = if ($taskErrorProperty) {
        $taskErrorProperty.Value
      }
      else {
        $null
      }
    }
  } while (
    $taskState -notin @("complete", "failed", "rejected", "orphaned", "shutdown") -and
    (Get-Date) -lt $deadline
  )

  if ($taskState -ne "complete") {
    throw "Database import task ended in state '$taskState': $taskMessage $taskError"
  }

  [pscustomobject]@{
    SourceDatabase = $SourceDatabase
    ImportedBytes  = (Get-Item -LiteralPath $temporaryDatabase).Length
    SHA256         = $expectedHash
    TargetNode     = $TargetNode
    TargetPath     = "$TargetDirectory/game-collection.db"
    ImportState    = $taskState
  }
}
finally {
  if ($temporaryServiceId) {
    try {
      Invoke-RestMethod -Method Delete -Uri "$dockerApi/services/$temporaryServiceId" -Headers $headers |
        Out-Null
    }
    catch {
      Write-Warning "Could not remove temporary import service: $_"
    }
  }
  if ($temporaryConfigId) {
    Start-Sleep -Seconds 2
    try {
      Invoke-RestMethod -Method Delete -Uri "$dockerApi/configs/$temporaryConfigId" -Headers $headers |
        Out-Null
    }
    catch {
      Write-Warning "Could not remove temporary import config: $_"
    }
  }
  if (Test-Path -LiteralPath $temporaryDatabase) {
    [IO.File]::Delete($temporaryDatabase)
  }
}
