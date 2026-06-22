#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT_DIR"

echo "==> Checking prerequisites..."
NODE_VERSION=$(node -v 2>/dev/null | sed 's/v//' | cut -d'.' -f1)
if [ -z "$NODE_VERSION" ] || [ "$NODE_VERSION" -lt 20 ]; then
  echo "Error: Node.js >= 20 is required (current: $(node -v 2>/dev/null || echo 'not found'))" >&2
  exit 1
fi

if ! command -v pnpm &>/dev/null; then
  echo "Error: pnpm is not installed. Install it via: npm install -g pnpm" >&2
  exit 1
fi

if [ ! -f ".env" ]; then
  echo "==> Creating .env from .env.example..."
  cp .env.example .env
  echo "==> Please edit .env to set your VLM_API_KEY and other settings."
fi

if [ ! -d "node_modules" ]; then
  echo "==> Installing dependencies..."
  pnpm install
fi

export PORT="${PORT:-31212}"
export HOST="${HOST:-0.0.0.0}"

if [ -z "${DISPLAY:-}" ]; then
  echo "==> No display detected, starting renderer dev server only..."

  # Patch electron-vite to not exit when Electron crashes (headless env)
  ELECTRON_VITE_CLI="/opt/typescript/UI-TARS-desktop/node_modules/electron-vite/dist/chunks"
  for f in "$ELECTRON_VITE_CLI"/lib-*.{mjs,cjs}; do
    if [ -f "$f" ]; then
      sed -i "s/ps.on('close', process.exit);/ps.on('close', () => {});/" "$f" 2>/dev/null || true
    fi
  done

  # Create fake electron binary for headless (keeps vite dev server alive)
  ELECTRON_REAL="/opt/typescript/UI-TARS-desktop/node_modules/electron/dist/electron"
  ELECTRON_BACKUP="${ELECTRON_REAL}.bak"
  if [ ! -f "$ELECTRON_BACKUP" ]; then
    cp "$ELECTRON_REAL" "$ELECTRON_BACKUP"
  fi

  cat > "$ELECTRON_REAL" << 'WRAPPER'
#!/usr/bin/env bash
ELECTRON_REAL="$(dirname "$0")/electron.bak"
if [ -z "${DISPLAY:-}" ]; then
  exit 0
fi
exec "$ELECTRON_REAL" "$@"
WRAPPER
  chmod +x "$ELECTRON_REAL"

  # Start dev server
  cd apps/ui-tars && NO_SANDBOX=1 DISPLAY=:99 npx electron-vite dev --rendererOnly &
  DEV_PID=$!

  # Wait for server
  echo "==> Waiting for dev server on port $PORT..."
  for i in $(seq 1 30); do
    if curl -s -o /dev/null "http://localhost:$PORT/" 2>/dev/null; then
      echo "==> Dev server running at http://0.0.0.0:$PORT (PID: $DEV_PID)"
      break
    fi
    sleep 1
    if ! kill -0 $DEV_PID 2>/dev/null; then
      echo "==> Dev server failed to start" >&2
      exit 1
    fi
  done
else
  echo "==> Starting UI-TARS Desktop (full mode) on port $PORT..."
  (cd apps/ui-tars && npx electron-vite dev)
fi
