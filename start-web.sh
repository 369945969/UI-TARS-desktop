#!/usr/bin/env bash
# ============================================================================
# Agent TARS Web 端启动脚本
# 支持 4 种启动方式:
#   1) agent-tars-cli  - agent-tars run 命令 (Express 服务器 + 内置 Web UI)
#   2) agent-ui-dev    - Web UI 开发服务器 (rsbuild dev, 需搭配后端 API)
#   3) agent-server-next - 下一代 Hono 服务器 (仅 API, 需搭配前端)
#   4) desktop-renderer - Electron 桌面版渲染进程 (浏览器模式)
# ============================================================================
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
MULTIMODAL_DIR="$ROOT_DIR/multimodal"
UI_APP_DIR="$ROOT_DIR/apps/ui-tars"

# ---- Color helpers ----
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
step()  { echo -e "\n${BLUE}==>${NC} ${CYAN}$1${NC}"; }

# ---- Prerequisites ----
check_prereqs() {
  step "Checking prerequisites..."

  NODE_VERSION=$(node -v 2>/dev/null | sed 's/v//' | cut -d'.' -f1)
  if [ -z "$NODE_VERSION" ] || [ "$NODE_VERSION" -lt 20 ]; then
    error "Node.js >= 20 is required (current: $(node -v 2>/dev/null || echo 'not found'))"
    exit 1
  fi
  info "Node.js $(node -v)"

  if ! command -v pnpm &>/dev/null; then
    error "pnpm is not installed. Install via: npm install -g pnpm"
    exit 1
  fi
  info "pnpm $(pnpm -v)"

  # Ensure .env exists
  if [ ! -f "$ROOT_DIR/.env" ] && [ -f "$ROOT_DIR/.env.example" ]; then
    warn "Creating $ROOT_DIR/.env from .env.example (please edit it!)"
    cp "$ROOT_DIR/.env.example" "$ROOT_DIR/.env"
  fi
}

# ---- Install dependencies if needed ----
ensure_deps() {
  local target_dir="$1"
  if [ ! -d "$target_dir/node_modules" ]; then
    step "Installing dependencies in $target_dir..."
    (cd "$target_dir" && pnpm install)
  fi
}

# ---- Build workspace packages ----
build_tarko_packages() {
  step "Building @tarko packages..."
  ensure_deps "$MULTIMODAL_DIR"
  (cd "$MULTIMODAL_DIR" && pnpm run build:tarko)
}

build_agent_tars_packages() {
  step "Building @agent-tars packages..."
  ensure_deps "$MULTIMODAL_DIR"
  (cd "$MULTIMODAL_DIR" && pnpm run build:agent-tars)
}

build_omni_tars_packages() {
  step "Building @omni-tars packages..."
  ensure_deps "$MULTIMODAL_DIR"
  (cd "$MULTIMODAL_DIR" && pnpm run build:omni-tars)
}

build_gui_agent_packages() {
  step "Building @gui-agent packages..."
  ensure_deps "$MULTIMODAL_DIR"
  (cd "$MULTIMODAL_DIR" && pnpm run build:gui-agent)
}

build_agent_ui() {
  step "Building @tarko/agent-ui..."
  ensure_deps "$MULTIMODAL_DIR"
  (cd "$MULTIMODAL_DIR/tarko/agent-ui" && pnpm build)
}

# ============================================================================
# Mode 1: agent-tars CLI (agent-tars run)
# ============================================================================
mode_agent_tars_cli() {
  echo ""
  echo "=============================================="
  echo " Mode 1: agent-tars CLI (Web UI 模式)"
  echo "=============================================="

  build_agent_tars_packages
  build_tarko_packages
  build_omni_tars_packages
  build_gui_agent_packages
  build_agent_ui

  step "Starting Agent TARS Web UI server..."

  # Set default port
  export PORT="${PORT:-3000}"

  # Use agent-tars CLI run command (interactive mode)
  cd "$MULTIMODAL_DIR"
  exec pnpm --filter @agent-tars/cli exec agent-tars run --port "$PORT" "$@"
}

# ============================================================================
# Mode 2: @tarko/agent-ui 开发服务器 (rsbuild dev)
# ============================================================================
mode_agent_ui_dev() {
  echo ""
  echo "=============================================="
  echo " Mode 2: @tarko/agent-ui 开发服务器"
  echo "=============================================="

  build_tarko_packages
  build_agent_ui

  # The rsbuild dev server needs AGENT_BASE_URL to point to a running API server
  export AGENT_BASE_URL="${AGENT_BASE_URL:-http://localhost:3000}"
  export PORT="${PORT:-5173}"

  step "Starting Agent Web UI dev server on port $PORT..."
  info "AGENT_BASE_URL=$AGENT_BASE_URL"
  warn "Note: This is ONLY the frontend. You need a backend API server running separately."
  warn "  Option A: Run 'agent-tars serve' for headless API"
  warn "  Option B: Run agent-server-next bootstrap for Hono API"

  cd "$MULTIMODAL_DIR/tarko/agent-ui"
  exec npx rsbuild dev --port "$PORT"
}

# ============================================================================
# Mode 3: @tarko/agent-server-next (Hono 服务器)
# ============================================================================
mode_agent_server_next() {
  echo ""
  echo "=============================================="
  echo " Mode 3: @tarko/agent-server-next (Hono)"
  echo "=============================================="

  build_tarko_packages
  build_omni_tars_packages
  build_gui_agent_packages

  step "Starting Agent Server Next (Hono-based)..."

  export PORT="${PORT:-3000}"
  export AGENT_DEBUG="${AGENT_DEBUG:-true}"

  info "Server will start on http://localhost:$PORT"
  warn "Note: This is a headless API server (Hono)."
  warn "  The bootstrap example references @omni-tars/agent and requires:"
  warn "    - OMNI_TARS_BASE_URL, OMNI_TARS_API_KEY"
  warn "    - WEBUI_REMOTE_URL (for frontend)"
  warn "  Start the UI separately with Mode 2."

  cd "$MULTIMODAL_DIR/tarko/agent-server-next"
  exec npx tsx examples/bootstrap.ts
}

# ============================================================================
# Mode 4: Desktop 版 renderer-only (Electron 渲染进程 Web 模式)
# ============================================================================
mode_desktop_renderer() {
  echo ""
  echo "=============================================="
  echo " Mode 4: Desktop 版 Renderer-Only (Web 模式)"
  echo "=============================================="

  ensure_deps "$ROOT_DIR"
  ensure_deps "$UI_APP_DIR"

  # Source the .env from root
  if [ -f "$ROOT_DIR/.env" ]; then
    set -a
    source "$ROOT_DIR/.env"
    set +a
  fi

  export PORT="${PORT:-31212}"
  export HOST="${HOST:-0.0.0.0}"

  if [ -z "${DISPLAY:-}" ]; then
    info "No display detected."

    # Patch electron-vite so it doesn't exit when Electron crashes
    ELECTRON_VITE_CLI="$ROOT_DIR/node_modules/electron-vite/dist/chunks"
    for f in "$ELECTRON_VITE_CLI"/lib-*.{mjs,cjs}; do
      if [ -f "$f" ]; then
        sed -i "s/ps.on('close', process.exit);/ps.on('close', () => {});/" "$f" 2>/dev/null || true
      fi
    done

    # Wrap electron binary to no-op in headless
    ELECTRON_REAL="$ROOT_DIR/node_modules/electron/dist/electron"
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
  fi

  step "Starting Electron renderer dev server on port $PORT..."

  cd "$UI_APP_DIR"
  exec npx electron-vite dev --rendererOnly
}

# ============================================================================
# Usage / Help
# ============================================================================
usage() {
  cat << EOF
Usage: $(basename "$0") <mode> [options]

启动 Agent TARS Web 端，支持 4 种模式:

  1 | cli           启动 agent-tars CLI (Express + 内置 Web UI) [推荐]
  2 | ui-dev        启动 @tarko/agent-ui 开发服务器 (仅前端)
  3 | server-next   启动 @tarko/agent-server-next (Hono API 服务器)
  4 | desktop       启动 Desktop 版 renderer-only (Electron 渲染进程)

环境变量:
  PORT              服务器端口 (默认: mode 1/3=3000, mode 2=5173, mode 4=31212)
  HOST              监听地址 (默认: 0.0.0.0)
  AGENT_BASE_URL    Mode 2 后端 API 地址 (默认: http://localhost:3000)
  AGENT_DEBUG       Mode 3 调试模式 (默认: true)
  DISPLAY           显示器 (Mode 4 检测到无显示器会自动降级)

示例:
  $(basename "$0") 1          # 启动 agent-tars CLI Web UI
  $(basename "$0") cli        # 同上
  $(basename "$0") 2          # 启动前端开发服务器
  $(basename "$0") 3          # 启动 Hono API 服务器
  $(basename "$0") 4          # 启动 Desktop renderer-only
EOF
  exit 0
}

# ============================================================================
# Main
# ============================================================================
check_prereqs

MODE="${1:-}"
shift 2>/dev/null || true

case "$MODE" in
  1|cli)
    mode_agent_tars_cli "$@"
    ;;
  2|ui-dev)
    mode_agent_ui_dev "$@"
    ;;
  3|server-next)
    mode_agent_server_next "$@"
    ;;
  4|desktop)
    mode_desktop_renderer "$@"
    ;;
  -h|--help|help|"")
    usage
    ;;
  *)
    error "Unknown mode: $MODE"
    usage
    ;;
esac
