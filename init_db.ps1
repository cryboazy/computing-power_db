<#
.SYNOPSIS
    智能算力监测平台 - 数据库初始化脚本

.DESCRIPTION
    执行 computing-power.sql 创建表结构
    检查数据库是否已有数据，如有数据则询问是否清空重建

.EXAMPLE
    .\init_db.ps1
#>

param(
    [string]$DB_HOST = $env:DB_HOST,
    [string]$DB_PORT = $env:DB_PORT,
    [string]$DB_NAME = $env:DB_NAME,
    [string]$DB_USER = $env:DB_USER,
    [string]$DB_PASSWORD = $env:DB_PASSWORD
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PythonScript = Join-Path $ScriptDir "init_db.py"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  智能算力监测平台 - 数据库初始化" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "错误: 未找到Python，请先安装Python 3" -ForegroundColor Red
    exit 1
}

$env:DB_HOST = if ($DB_HOST) { $DB_HOST } else { "localhost" }
$env:DB_PORT = if ($DB_PORT) { $DB_PORT } else { "5432" }
$env:DB_NAME = if ($DB_NAME) { $DB_NAME } else { "computing_power" }
$env:DB_USER = if ($DB_USER) { $DB_USER } else { "gaussdb" }
$env:DB_PASSWORD = if ($DB_PASSWORD) { $DB_PASSWORD } else { "Qwaszx@12" }

Write-Host "数据库连接配置:" -ForegroundColor Yellow
Write-Host "  主机: $env:DB_HOST"
Write-Host "  端口: $env:DB_PORT"
Write-Host "  数据库: $env:DB_NAME"
Write-Host "  用户: $env:DB_USER"
Write-Host ""

& python $PythonScript
