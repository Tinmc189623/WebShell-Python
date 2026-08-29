#!/usr/bin/env bash
set -e

# ========== 颜色与消息 ==========
if [ -t 1 ]; then
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    YELLOW='\033[1;33m'
    NC='\033[0m'
else
    GREEN=''; RED=''; YELLOW=''; NC=''
fi

echo_info()  { echo -e "${GREEN}ℹ️  $*${NC}"; }
echo_warn()  { echo -e "${YELLOW}⚠️  $*${NC}"; }
echo_error() { echo -e "${RED}❌ $*${NC}"; }
echo_success(){ echo -e "${GREEN}✅ $*${NC}"; }

# ========== 检测系统架构 ==========
detect_arch() {
    local arch=$(uname -m)
    case "$arch" in
        x86_64)  echo "x86_64" ;;
        aarch64) echo "arm64"  ;;
        armv7l)  echo "armv7"  ;;
        *)       echo "unknown" ;;
    esac
}

ARCH=$(detect_arch)
if [ "$ARCH" = "unknown" ]; then
    echo_error "不支持的架构: $(uname -m)"
    exit 1
fi

# ========== 检查并下载 ttyd ==========
TTYD="./ttyd"
if [ ! -f "$TTYD" ]; then
    echo_info "未找到 ttyd，正在下载..."
    TTYD_VERSION="1.7.7"
    BASE_URL="https://github.com/tsl0922/ttyd/releases/download/${TTYD_VERSION}"
    case "$ARCH" in
        x86_64) FILE="ttyd.x86_64" ;;
        arm64)  FILE="ttyd.arm64" ;;
        armv7)  FILE="ttyd.armv7" ;;
    esac
    DOWNLOAD_URL="${BASE_URL}/${FILE}"
    echo_info "下载地址: $DOWNLOAD_URL"
    
    if command -v curl &>/dev/null; then
        curl -fsSL -o "$TTYD" "$DOWNLOAD_URL"
    elif command -v wget &>/dev/null; then
        wget -q -O "$TTYD" "$DOWNLOAD_URL"
    else
        echo_error "需要 curl 或 wget 来下载 ttyd"
        exit 1
    fi
    
    if [ ! -f "$TTYD" ]; then
        echo_error "下载失败"
        exit 1
    fi
    chmod +x "$TTYD"
    echo_success "ttyd 下载完成"
else
    echo_info "ttyd 已存在，使用现有文件"
fi

# ========== 启动服务 ==========
PORT="${1:-5000}"   # 默认端口 5000
echo_info "启动 Web Shell 服务，端口 $PORT"
echo_info "访问地址: http://$(hostname -I | awk '{print $1}'):$PORT"
echo_info "按 Ctrl+C 停止服务"

# 使用 ttyd 启动 bash，并开启浏览器访问
exec "$TTYD" -p "$PORT" -W bash
