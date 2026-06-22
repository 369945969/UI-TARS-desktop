#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
MULTIMODAL_DIR="$ROOT_DIR/multimodal"

# ---- Load .env ----
if [ -f "$ROOT_DIR/.env" ]; then
  set -a
  source "$ROOT_DIR/.env"
  set +a
fi

# ==============================================================
#  模型配置 (优先级: 环境变量 > .env > 默认值)
# ==============================================================
# 方式 A: 直接 export 环境变量 (取消注释即可)
# export MODEL_PROVIDER="openai"
# export MODEL_BASE_URL="https://api.openai.com/v1"
# export MODEL_API_KEY="sk-xxx"
# export MODEL_ID="gpt-4o"

# 方式 B: 从 .env 的 VLM_* 回退 (默认)
: "${MODEL_PROVIDER:=openai}"
: "${MODEL_BASE_URL:=${VLM_BASE_URL:-}}"
: "${MODEL_API_KEY:=${VLM_API_KEY:-}}"
: "${MODEL_ID:=${VLM_MODEL_NAME:-gpt-4o}}"

PORT="${PORT:-3000}"

# ---- 搜索引擎 ----
SEARCH_PROVIDER="${SEARCH_PROVIDER:-browser_search}"
SEARCH_API_KEY="${SEARCH_API_KEY:-}"

# ---- 浏览器配置 ----
# 优先: 手动指定浏览器配置 (JSON), 如 '{"headless":true,"type":"local"}'
# 若留空, 则根据环境自动选择
BROWSER_CFG="${BROWSER_CFG:-}"
CDP_URL="${CDP_URL:-}"  # 指定此值则使用远程浏览器
# ==============================================================

# ---- Prerequisites ----
NODE_VERSION=$(node -v 2>/dev/null | sed 's/v//' | cut -d'.' -f1)
if [ -z "$NODE_VERSION" ] || [ "$NODE_VERSION" -lt 22 ]; then
  echo "Error: Node.js >= 22 required (current: $(node -v 2>/dev/null || echo 'not found'))" >&2
  exit 1
fi

if ! command -v pnpm &>/dev/null; then
  echo "Error: pnpm is not installed" >&2
  exit 1
fi

# ---- Install deps if needed ----
if [ ! -d "$MULTIMODAL_DIR/node_modules" ]; then
  echo "==> Installing dependencies..."
  (cd "$MULTIMODAL_DIR" && pnpm install)
fi

# ---- Build all required packages (only needed once) ----
NEEDS_BUILD=false
for pkg in agent-tars/cli/dist tarko/agent-ui-builder/static omni-tars/omni-agent/dist gui-agent/agent-sdk/dist; do
  if [ ! -d "$MULTIMODAL_DIR/$pkg" ]; then
    NEEDS_BUILD=true
    break
  fi
done

if [ "$NEEDS_BUILD" = true ]; then
  echo "==> Building packages (first time only)..."
  for scope in "./gui-agent/**" "./omni-tars/**" "./agent-tars/**" "./tarko/**"; do
    (cd "$MULTIMODAL_DIR" && pnpm --filter "$scope" --include-dependencies build)
  done
  # build agent-ui separately
  (cd "$MULTIMODAL_DIR/tarko/agent-ui" && AGENT_BASE_URL="" pnpm build)
  echo "==> Build complete."
fi

# ---- 浏览器配置 ----
# 由 Agent 内部管理浏览器生命周期 (LocalBrowser),
# 比脚本提前启动再传 CDP 更稳定 (支持进程恢复)
BROWSER_HEADLESS=""
if [ -z "$BROWSER_CFG" ] && [ -z "$CDP_URL" ]; then
  if [ -n "${DISPLAY:-}" ]; then
    echo "==> Display detected, using headed browser"
  else
    echo "==> No display, using headless browser (managed by agent)"
    BROWSER_HEADLESS="--browser.headless"
  fi
fi

# ---- 清理旧进程 (tars + chrome) ----
# 杀掉旧的 agent-tars CLI 进程, 避免端口冲突
# 注意: grep 无匹配返回 1, 配合 set -o pipefail 需加 || true
OLD_TARS_PIDS=$(ps -eo pid,cmd | grep -E 'cli/bin/cli\.js run|node bin/cli\.js run' | grep -v grep | awk '{print $1}' || true)
if [ -n "$OLD_TARS_PIDS" ]; then
  echo "==> Killing old agent-tars processes: $OLD_TARS_PIDS"
  echo "$OLD_TARS_PIDS" | xargs kill -9 2>/dev/null || true
  sleep 1
fi

# 杀掉残留的 chrome/chromium 进程 (用 -f 匹配完整命令行, 不用 -x 匹配进程名)
# 因为 chromium 的子进程名多样: chromium-browser, chrome, chrome_crashpad_handler 等
pkill -f 'chromium-browser|google-chrome|/chrome ' 2>/dev/null || true
sleep 2

# ---- Start agent-tars CLI ----
echo "=============================================="
echo "  Agent TARS Web UI — http://localhost:$PORT"
echo "  Model: $MODEL_PROVIDER / $MODEL_ID"
if [ -n "$BROWSER_CFG" ]; then
  echo "  Browser: managed by agent ($BROWSER_CFG)"
elif [ -n "$BROWSER_HEADLESS" ]; then
  echo "  Browser: headless (managed by agent)"
elif [ -n "$CDP_URL" ]; then
  echo "  Browser: $CDP_URL"
fi
echo "=============================================="

export TARKO_ALLOWED_ORIGINS="${TARKO_ALLOWED_ORIGINS:-*}"
export AGENT_BASE_URL=""

cd "$MULTIMODAL_DIR/agent-tars/cli"
exec node bin/cli.js run \
  --port "$PORT" \
  --server.exclusive \
  --model.provider "$MODEL_PROVIDER" \
  --model.baseURL "$MODEL_BASE_URL" \
  --model.apiKey "$MODEL_API_KEY" \
  --model.id "$MODEL_ID" \
  --search.provider "$SEARCH_PROVIDER" \
  ${SEARCH_API_KEY:+--search.apiKey "$SEARCH_API_KEY"} \
  ${BROWSER_CFG:+--browser "$BROWSER_CFG"} \
  ${CDP_URL:+--browser.cdpEndpoint "$CDP_URL"} \
  $BROWSER_HEADLESS \
  "$@"
