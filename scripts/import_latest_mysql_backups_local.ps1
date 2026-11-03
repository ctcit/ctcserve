param(
    [string]$ProjectRoot = "D:\Dropbox\CTC\ctcserve-win",
    [string]$BackupDir = "D:\Dropbox\CTC\backups",
    [string]$DbService = "db",
    [string]$DbUser = "root",
    [string]$DbPassword = "docker",
    [int]$MinFreeGb = 10,
    [switch]$DropTargetDatabases = $true,
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Require-Command {
    param([string]$Name)
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Required command not found: $Name"
    }
}

function Get-LatestDump {
    param(
        [string]$Dir,
        [string[]]$Patterns,
        [string]$LogicalName
    )

    $candidates = @()

    foreach ($pattern in $Patterns) {
        $candidates += @(Get-ChildItem -Path $Dir -Filter $pattern -File -ErrorAction SilentlyContinue)
    }

    if ($candidates.Count -eq 0) {
        throw "Missing dump for $LogicalName (patterns: $($Patterns -join ', ')) in $Dir"
    }

    return $candidates | Sort-Object LastWriteTime -Descending | Select-Object -First 1
}

function Assert-DbHealthy {
    param(
        [string]$Service,
        [string]$User,
        [string]$Password
    )

    docker compose up -d $Service | Out-Null
    $containerId = docker compose ps -q $Service
    if (-not $containerId) {
        throw "Container for service '$Service' is not running."
    }

    docker compose exec $Service sh -lc "mysqladmin ping -u$User -p$Password --silent" | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "MySQL is not healthy for service '$Service'."
    }
}

Require-Command docker

if (-not (Test-Path $ProjectRoot)) {
    throw "ProjectRoot not found: $ProjectRoot"
}

if (-not (Test-Path $BackupDir)) {
    throw "BackupDir not found: $BackupDir"
}

$backupDrive = [System.IO.Path]::GetPathRoot($BackupDir).TrimEnd('\\')
$driveName = $backupDrive.TrimEnd(':')
$drive = Get-PSDrive -Name $driveName -ErrorAction Stop
$freeGb = [math]::Round($drive.Free / 1GB, 2)
if ($freeGb -lt $MinFreeGb) {
    throw "Insufficient free space on drive $backupDrive ($freeGb GB free, minimum required: $MinFreeGb GB)."
}
Write-Host ("Free space on {0}: {1} GB" -f $backupDrive, $freeGb)

Set-Location $ProjectRoot

# Dependency-aware import order.
# ctc contains objects that reference newsletter/tripreports.
$plan = @(
    @{ Db = "tripreports"; Patterns = @("tripreports_*.sql.gz", "tripreport_*.sql.gz") },
    @{ Db = "newsletter"; Patterns = @("newsletter_*.sql.gz") },
    @{ Db = "ctc";        Patterns = @("ctc_*.sql.gz") },
    @{ Db = "triphub";    Patterns = @("triphub_*.sql.gz") },
    @{ Db = "hutbooking"; Patterns = @("hutbooking_*.sql.gz") },
    @{ Db = "joom4";      Patterns = @("joom4_*.sql.gz") }
)

$selected = @()
foreach ($item in $plan) {
    $selected += [pscustomobject]@{
        Db   = $item.Db
        File = Get-LatestDump -Dir $BackupDir -Patterns $item.Patterns -LogicalName $item.Db
    }
}

Write-Host "Selected backup files:"
$selected | ForEach-Object {
    Write-Host ("  {0,-11} {1} [{2}]" -f $_.Db, $_.File.Name, $_.File.LastWriteTime.ToString("s"))
}

if ($DryRun) {
    Write-Host "DryRun enabled. No import performed."
    exit 0
}

docker compose up -d $DbService | Out-Host
$cid = docker compose ps -q $DbService
if (-not $cid) {
    throw "Container for service '$DbService' is not running."
}

Assert-DbHealthy -Service $DbService -User $DbUser -Password $DbPassword

$mysql = "mysql -u$DbUser -p$DbPassword"

# Ensure compatibility for legacy definers referenced in dumps.
$definerSql = "CREATE USER IF NOT EXISTS 'ctcview'@'localhost' IDENTIFIED BY 'docker'; GRANT SELECT, SHOW VIEW ON *.* TO 'ctcview'@'localhost'; FLUSH PRIVILEGES;"
$definerCmd = "$mysql -e `"$definerSql`""
docker compose exec $DbService sh -lc $definerCmd | Out-Host
if ($LASTEXITCODE -ne 0) {
    throw "Failed to create/verify definer user."
}

if ($DropTargetDatabases) {
    $dropSql = "DROP DATABASE IF EXISTS ctc; DROP DATABASE IF EXISTS joom4; DROP DATABASE IF EXISTS newsletter; DROP DATABASE IF EXISTS triphub; DROP DATABASE IF EXISTS hutbooking; DROP DATABASE IF EXISTS tripreport; DROP DATABASE IF EXISTS tripreports;"
    $dropCmd = "$mysql -e `"$dropSql`""
    docker compose exec $DbService sh -lc $dropCmd | Out-Host
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to drop target databases."
    }
}

foreach ($entry in $selected) {
    $remotePath = "/tmp/$($entry.File.Name)"
    Write-Host ""
    Write-Host "Uploading $($entry.File.Name) ..."
    docker cp $entry.File.FullName "$cid`:$remotePath" | Out-Host
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to upload $($entry.File.Name) into container."
    }

    Write-Host "Importing $($entry.Db) from $($entry.File.Name) ..."
    docker compose exec $DbService sh -lc "gunzip -c '$remotePath' | mysql --force --init-command='SET SESSION sql_log_bin=0' -u$DbUser -p$DbPassword" | Out-Host
    if ($LASTEXITCODE -ne 0) {
        throw "Import failed for $($entry.Db) from $($entry.File.Name)."
    }

    Assert-DbHealthy -Service $DbService -User $DbUser -Password $DbPassword
}

Write-Host ""
Write-Host "Post-import schema counts:"
$countSql = "SELECT table_schema, COUNT(*) FROM information_schema.tables WHERE table_schema IN ('ctc','joom4','newsletter','triphub','hutbooking','tripreport','tripreports') GROUP BY table_schema ORDER BY table_schema;"
$countCmd = "$mysql -NBe `"$countSql`""
docker compose exec $DbService sh -lc $countCmd | Out-Host

Write-Host ""
Write-Host "Restore complete."
