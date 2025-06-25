```bash
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

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export CLR_ICU_VERSION_OVERRIDE=70

log "Starting REST API..."
dotnet "$ROOT_DIR/publish/api/BlockchainDemonstratorApi.dll" "demonstrator.valuechainhackers.xyz" &
API_PID=$!
log "API PID=$API_PID"

log "Starting WebApp..."
dotnet "$ROOT_DIR/publish/webapp/BlockchainDemonstratorWebApp.dll" "demonstrator.valuechainhackers.xyz" &
WEB_PID=$!
log "WebApp PID=$WEB_PID"

log "✅ Services started. Waiting for exit/interruption..."
wait "$API_PID" "$WEB_PID"
```
