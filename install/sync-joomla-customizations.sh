#!/usr/bin/env bash
set -euo pipefail

BASE_COMPOSE_FILE="${1:-docker-compose.yaml}"
OVERLAY_COMPOSE_FILE="${2:-docker-compose.custom-overlays.yaml}"
WEB_SERVICE="${3:-webserver}"

if [[ ! -f "$BASE_COMPOSE_FILE" ]]; then
  echo "Base compose file '$BASE_COMPOSE_FILE' was not found. Run this script from the ctcserve repository root." >&2
  exit 1
fi

COMPOSE_ARGS=(-f "$BASE_COMPOSE_FILE")
if [[ -f "$OVERLAY_COMPOSE_FILE" ]]; then
  COMPOSE_ARGS+=(-f "$OVERLAY_COMPOSE_FILE")
fi

echo "Refreshing Joomla extension registry..."
docker compose "${COMPOSE_ARGS[@]}" exec -T "$WEB_SERVICE" php /var/www/html/cli/joomla.php extension:discover
docker compose "${COMPOSE_ARGS[@]}" exec -T "$WEB_SERVICE" php /var/www/html/cli/joomla.php extension:discover:install

echo "Clearing Joomla cache and PSR-4 map..."
docker compose "${COMPOSE_ARGS[@]}" exec -T "$WEB_SERVICE" php /var/www/html/cli/joomla.php cache:clean
docker compose "${COMPOSE_ARGS[@]}" exec -T "$WEB_SERVICE" sh -lc "rm -f /var/www/html/administrator/cache/autoload_psr4.php"

echo "Done. Reload http://localhost/ to regenerate caches."
