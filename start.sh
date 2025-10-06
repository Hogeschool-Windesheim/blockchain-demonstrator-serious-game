#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit

log()   { printf '⏺ [%s] %s\n' "$(date +'%Y-%m-%dT%H:%M:%S%z')" "$*"; }
error() { log "❌ $*" >&2; exit 1; }

cleanup() {
  log "🧹 Cleaning up processes..."
  [[ -n "${API_PID-}" ]] && kill "$API_PID" 2>/dev/null || true
  [[ -n "${WEB_PID-}" ]] && kill "$WEB_PID" 2>/dev/null || true
}
trap cleanup EXIT SIGINT SIGTERM

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Set Production environment
export ASPNETCORE_ENVIRONMENT=Production
export CLR_ICU_VERSION_OVERRIDE=70

# Server IP configuration
SERVER_IP="${SERVER_IP:-10.0.5.13:8080}"

log "Environment: $ASPNETCORE_ENVIRONMENT"
log "Server IP: $SERVER_IP"

log "Starting REST API..."
dotnet "$ROOT_DIR/publish/api/BlockchainDemonstratorApi.dll" "$SERVER_IP" &
API_PID=$!
log "API PID=$API_PID"

log "Starting WebApp..."
dotnet "$ROOT_DIR/publish/webapp/BlockchainDemonstratorWebApp.dll" "$SERVER_IP" &
WEB_PID=$!
log "WebApp PID=$WEB_PID"

log "✅ Services started in PRODUCTION mode. Waiting for exit/interruption..."
wait "$API_PID" "$WEB_PID"
