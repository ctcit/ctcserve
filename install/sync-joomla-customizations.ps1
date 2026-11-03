param(
    [string]$BaseComposeFile = "docker-compose.yaml",
    [string]$OverlayComposeFile = "docker-compose.custom-overlays.yaml",
    [string]$WebService = "webserver"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $BaseComposeFile)) {
    throw "Base compose file '$BaseComposeFile' was not found. Run this script from the ctcserve repository root."
}

$composeArgs = @("compose", "-f", $BaseComposeFile)

if (Test-Path $OverlayComposeFile) {
    $composeArgs += @("-f", $OverlayComposeFile)
}

Write-Host "Refreshing Joomla extension registry..."
docker @composeArgs exec -T $WebService php /var/www/html/cli/joomla.php extension:discover
if (-not $?) { throw "extension:discover failed." }

docker @composeArgs exec -T $WebService php /var/www/html/cli/joomla.php extension:discover:install
if (-not $?) { throw "extension:discover:install failed." }

Write-Host "Clearing Joomla cache and PSR-4 map..."
docker @composeArgs exec -T $WebService php /var/www/html/cli/joomla.php cache:clean
if (-not $?) { throw "cache:clean failed." }

docker @composeArgs exec -T $WebService sh -lc "rm -f /var/www/html/administrator/cache/autoload_psr4.php"
if (-not $?) { throw "Failed to remove administrator/cache/autoload_psr4.php." }

Write-Host "Done. Reload http://localhost/ to regenerate caches."
