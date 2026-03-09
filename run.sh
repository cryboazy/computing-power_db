#!/bin/bash
# 智能算力监测平台 - 数据生成/加载脚本
# 用法: ./run.sh [选项]
#   -g, --generate    重新生成数据并加载
#   -l, --load        仅加载现有CSV数据
#   -h, --help        显示帮助信息

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="${SCRIPT_DIR}/generated_data"
PYTHON_SCRIPT="${SCRIPT_DIR}/generate_data.py"
LOG_DIR="${SCRIPT_DIR}/logs"
LOG_FILE="${LOG_DIR}/run_$(date +%Y%m%d_%H%M%S).log"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[成功]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[错误]${NC} $1" | tee -a "$LOG_FILE"
}

log_warn() {
    echo -e "${YELLOW}[警告]${NC} $1" | tee -a "$LOG_FILE"
}

show_help() {
    echo "智能算力监测平台 - 数据生成/加载脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -g, --generate    重新生成数据并加载到数据库"
    echo "  -l, --load        仅加载现有CSV数据到数据库"
    echo "  -i, --init        初始化数据库（执行SQL文件）"
    echo "  --skip-clear      跳过清空现有数据（与-i或-l配合使用）"
    echo "  -h, --help        显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 -g             # 重新生成数据并加载"
    echo "  $0 --load         # 仅加载现有数据"
    echo "  $0 -i             # 初始化数据库（清空数据）"
    echo "  $0 -i --skip-clear # 初始化数据库（不清空数据）"
    echo ""
}

check_python() {
    if ! command -v python3 &> /dev/null; then
        if ! command -v python &> /dev/null; then
            log_error "未找到Python，请先安装Python 3"
            exit 1
        fi
        PYTHON_CMD="python"
    else
        PYTHON_CMD="python3"
    fi
    
    log "使用Python命令: $PYTHON_CMD"
}

check_csv_files() {
    local files=(
        "organization.csv"
        "device.csv"
        "gpu_card_info.csv"
        "device_gpu_monitor.csv"
        "device_gpu_monitor_detail.csv"
        "device_cpu_monitor.csv"
        "device_memory_monitor.csv"
        "device_disk_monitor.csv"
        "device_network_monitor.csv"
    )
    
    local missing=0
    for file in "${files[@]}"; do
        if [ ! -f "${DATA_DIR}/${file}" ]; then
            log_warn "缺少文件: ${file}"
            missing=1
        fi
    done
    
    if [ $missing -eq 1 ]; then
        return 1
    fi
    return 0
}

init_database() {
    local skip_clear=$1
    log "开始初始化数据库..."
    
    mkdir -p "$LOG_DIR"
    
    cd "$SCRIPT_DIR"
    
    if [ "$skip_clear" = "true" ]; then
        $PYTHON_CMD "$PYTHON_SCRIPT" --init --skip-clear
    else
        $PYTHON_CMD "$PYTHON_SCRIPT" --init
    fi
    
    if [ $? -eq 0 ]; then
        log_success "数据库初始化完成"
    else
        log_error "数据库初始化失败"
        exit 1
    fi
}

generate_data() {
    log "开始生成数据..."
    
    mkdir -p "$DATA_DIR"
    mkdir -p "$LOG_DIR"
    
    cd "$SCRIPT_DIR"
    
    $PYTHON_CMD "$PYTHON_SCRIPT" --generate
    
    if [ $? -eq 0 ]; then
        log_success "数据生成完成"
    else
        log_error "数据生成失败"
        exit 1
    fi
}

load_data() {
    local skip_clear=$1
    log "开始加载数据到数据库..."
    
    mkdir -p "$LOG_DIR"
    
    if ! check_csv_files; then
        log_error "CSV文件不完整，请先运行: $0 -g"
        exit 1
    fi
    
    cd "$SCRIPT_DIR"
    
    if [ "$skip_clear" = "true" ]; then
        $PYTHON_CMD "$PYTHON_SCRIPT" --load --skip-clear
    else
        $PYTHON_CMD "$PYTHON_SCRIPT" --load
    fi
    
    if [ $? -eq 0 ]; then
        log_success "数据加载完成"
    else
        log_error "数据加载失败"
        exit 1
    fi
}

generate_and_load() {
    log "=========================================="
    log "  智能算力监测平台 - 数据生成与加载"
    log "=========================================="
    
    mkdir -p "$LOG_DIR"
    
    log "开始完整流程: 生成数据 -> 加载数据"
    
    generate_data
    load_data false
    
    log "=========================================="
    log_success "所有操作完成!"
    log "日志文件: $LOG_FILE"
    log "CSV文件: $DATA_DIR"
    log "=========================================="
}

load_only() {
    local skip_clear=$1
    log "=========================================="
    log "  智能算力监测平台 - 数据加载"
    log "=========================================="
    
    mkdir -p "$LOG_DIR"
    
    load_data $skip_clear
    
    log "=========================================="
    log_success "数据加载完成!"
    log "日志文件: $LOG_FILE"
    log "=========================================="
}

interactive_mode() {
    echo ""
    echo "=========================================="
    echo "  智能算力监测平台 - 数据管理"
    echo "=========================================="
    echo ""
    echo "请选择操作:"
    echo "  1) 初始化数据库（清空现有数据）"
    echo "  2) 初始化数据库（保留现有数据）"
    echo "  3) 重新生成数据并加载到数据库"
    echo "  4) 仅加载现有CSV数据到数据库（清空现有数据）"
    echo "  5) 仅加载现有CSV数据到数据库（保留现有数据）"
    echo "  6) 查看CSV文件状态"
    echo "  7) 退出"
    echo ""
    read -p "请输入选项 [1-7]: " choice
    
    case $choice in
        1)
            init_database false
            ;;
        2)
            init_database true
            ;;
        3)
            generate_and_load
            ;;
        4)
            load_only false
            ;;
        5)
            load_only true
            ;;
        6)
            echo ""
            echo "CSV文件状态:"
            echo "----------------------------------------"
            if [ -d "$DATA_DIR" ]; then
                ls -lh "$DATA_DIR"/*.csv 2>/dev/null || echo "没有找到CSV文件"
            else
                echo "数据目录不存在: $DATA_DIR"
            fi
            echo ""
            interactive_mode
            ;;
        7)
            echo "退出"
            exit 0
            ;;
        *)
            echo "无效选项，请重新选择"
            interactive_mode
            ;;
    esac
}

main() {
    check_python
    
    local skip_clear=false
    
    for arg in "$@"; do
        case $arg in
            --skip-clear)
                skip_clear=true
                ;;
        esac
    done
    
    case "${1:-}" in
        -g|--generate)
            generate_and_load
            ;;
        -l|--load)
            load_only $skip_clear
            ;;
        -i|--init)
            init_database $skip_clear
            ;;
        -h|--help)
            show_help
            ;;
        "")
            interactive_mode
            ;;
        *)
            log_error "未知选项: $1"
            show_help
            exit 1
            ;;
    esac
}

main "$@"
