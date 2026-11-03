param(
    # Edit defaults here for your environment, then run without parameters.
    [string]$RemoteHost = "ctc.org.nz",
    [string]$RemoteUser = "ctcserve",
    [string]$RemoteBackupDir = "~/backups/mysql",
    [string]$LocalTargetDir = "D:\Dropbox\CTC\backups",
    [int]$Port = 22,
    [string]$IdentityFile = "",
    [int]$CopyRetries = 3,
    [string[]]$SshExtraArgs = @(),
    [string[]]$ScpExtraArgs = @()
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ($RemoteHost -eq "your.server.example" -or $RemoteUser -eq "your-ssh-user") {
    throw "Set DefaultRemoteHost and DefaultRemoteUser at the top of this script, or pass -RemoteHost and -RemoteUser on the command line."
}

if (-not (Get-Command ssh -ErrorAction SilentlyContinue)) {
    throw "ssh command not found. Install OpenSSH client first."
}

if (-not (Get-Command scp -ErrorAction SilentlyContinue)) {
    throw "scp command not found. Install OpenSSH client first."
}

if ($RemoteBackupDir -match "\s") {
    throw "RemoteBackupDir cannot contain spaces for this script: $RemoteBackupDir"
}

New-Item -ItemType Directory -Path $LocalTargetDir -Force | Out-Null

$remoteSpec = "$RemoteUser@$RemoteHost"

$sshArgs = @("-p", "$Port")
if ($IdentityFile) {
    $sshArgs += @("-i", $IdentityFile)
}
$sshArgs += $SshExtraArgs

Write-Host "Discovering latest backup set in $RemoteBackupDir on $remoteSpec ..."
$remoteListCmd = "ls -1 $RemoteBackupDir/*.sql.gz $RemoteBackupDir/checksums_*.sha256 2>/dev/null || true"
$remoteOutput = & ssh @sshArgs $remoteSpec $remoteListCmd
if ($LASTEXITCODE -ne 0) {
    throw "ssh command failed with exit code $LASTEXITCODE"
}

$allRemoteFiles = @($remoteOutput | Where-Object { $_ -and $_.Trim() -ne "" })
$sqlBackups = @($allRemoteFiles | Where-Object { $_ -match '_(\d{8}T\d{6}Z)\.sql\.gz$' })
if ($sqlBackups.Count -eq 0) {
    throw "No backup files found in $RemoteBackupDir"
}

$dbPatterns = @{
    ctc        = @("ctc")
    joom4      = @("joom4")
    newsletter = @("newsletter")
    triphub    = @("triphub")
    hutbooking = @("hutbooking")
    tripreport = @("tripreport", "tripreports")
}

$stamps = $sqlBackups | ForEach-Object {
    if ($_ -match '_(\d{8}T\d{6}Z)\.sql\.gz$') { $matches[1] }
} | Sort-Object -Unique -Descending

$latestStamp = $null
$latestFiles = @()

foreach ($stamp in $stamps) {
    $candidateFiles = @()
    $isComplete = $true

    foreach ($logicalDb in $dbPatterns.Keys) {
        $found = $null

        foreach ($patternName in $dbPatterns[$logicalDb]) {
            $found = $allRemoteFiles | Where-Object { $_ -like "*/${patternName}_$stamp.sql.gz" } | Select-Object -First 1
            if ($found) { break }
        }

        if (-not $found) {
            $isComplete = $false
            break
        }

        $candidateFiles += $found
    }

    if ($isComplete) {
        $latestStamp = $stamp
        $latestFiles = $candidateFiles
        break
    }
}

if (-not $latestStamp) {
    Write-Host "No single complete timestamp set found; falling back to latest file per database."
    $latestFiles = @()
    $checksumFiles = @()

    foreach ($logicalDb in $dbPatterns.Keys) {
        $dbMatches = @()

        foreach ($patternName in $dbPatterns[$logicalDb]) {
            $dbMatches += @($allRemoteFiles | Where-Object { $_ -like "*/${patternName}_*.sql.gz" })
        }

        if ($dbMatches.Count -eq 0) {
            throw "No backup file found for required database '$logicalDb'"
        }

        $bestMatch = $dbMatches | Sort-Object {
            if ($_ -match '_(\d{8}T\d{6}Z)\.sql\.gz$') { $matches[1] } else { '' }
        } -Descending | Select-Object -First 1

        $latestFiles += $bestMatch

        if ($bestMatch -match '_(\d{8}T\d{6}Z)\.sql\.gz$') {
            $stamp = $matches[1]
            $checksum = $allRemoteFiles | Where-Object { $_ -like "*/checksums_$stamp.sha256" } | Select-Object -First 1
            if ($checksum) { $checksumFiles += $checksum }
        }
    }

    $remoteFiles = @($checksumFiles + $latestFiles | Sort-Object -Unique)
}
else {
    $remoteFiles = @($allRemoteFiles | Where-Object {
        $_ -like "*/checksums_$latestStamp.sha256"
    })
    $remoteFiles += $latestFiles
    $remoteFiles = @($remoteFiles | Sort-Object -Unique)
}

Write-Host "Found files:"
$remoteFiles | ForEach-Object { Write-Host "  $_" }

$scpBaseArgs = @("-P", "$Port")
if ($IdentityFile) {
    $scpBaseArgs += @("-i", $IdentityFile)
}
$scpBaseArgs += $ScpExtraArgs

foreach ($remoteFile in $remoteFiles) {
    $source = "${remoteSpec}:$remoteFile"
    $copied = $false

    for ($attempt = 1; $attempt -le $CopyRetries; $attempt++) {
        Write-Host "Copying $source -> $LocalTargetDir (attempt $attempt/$CopyRetries)"
        & scp @scpBaseArgs $source $LocalTargetDir

        if ($LASTEXITCODE -eq 0) {
            $copied = $true
            break
        }

        if ($attempt -lt $CopyRetries) {
            Write-Host "Retrying after scp failure (exit code $LASTEXITCODE)..."
        }
    }

    if (-not $copied) {
        throw "scp failed for $remoteFile after $CopyRetries attempts"
    }
}

Write-Host "Done. Files copied to $LocalTargetDir"
