# 智能算力监测平台

智能算力监测平台数据库初始化和数据生成工具，用于创建和管理算力监测平台的数据库结构及模拟数据。

## 功能特性

- **数据库初始化**：自动创建完整的数据库表结构
- **组织层级管理**：支持三级组织架构（全国、厅局、处室）
- **设备管理**：管理服务器设备及其GPU配置
- **监控数据生成**：生成CPU、内存、磁盘、网络、GPU等监控数据
- **多GPU型号支持**：支持NVIDIA H100、A100、RTX 4090等多种GPU型号
- **数据汇总**：支持每日设备汇总和GPU使用率汇总
- **采集任务管理**：支持数据采集任务的调度和管理

## 技术栈

- **Python 3.x**
- **PostgreSQL / OpenGauss**
- **psycopg2** - PostgreSQL数据库驱动
- **PyYAML** - 配置文件解析

## 项目结构

```
computing-power_db/
├── computing-power.sql          # 数据库表结构定义
├── config.yaml.example          # 配置文件示例
├── db_config.py                 # 数据库配置管理模块
├── init_db.py                   # 数据库初始化脚本
├── generate_data.py             # 数据生成脚本
├── requirements.txt             # Python依赖
├── init_db.ps1                  # PowerShell初始化脚本
└── run.sh                       # Shell运行脚本
```

## 安装步骤

### 1. 安装依赖

```bash
pip install -r requirements.txt
```

### 2. 配置数据库连接

复制配置文件示例并根据实际情况修改：

```bash
cp config.yaml.example config.yaml
```

编辑 `config.yaml` 文件，配置数据库连接信息：

```yaml
database:
  host: your_database_host
  port: 5432
  name: computing_power
  user: your_username
  password: your_password
```

或者通过环境变量设置：

```bash
export DB_HOST=your_database_host
export DB_PORT=5432
export DB_NAME=computing_power
export DB_USER=your_username
export DB_PASSWORD=your_password
```

### 3. 初始化数据库

运行初始化脚本创建表结构：

```bash
python init_db.py
```

或者在Windows上使用PowerShell：

```powershell
.\init_db.ps1
```

## 使用说明

### 生成模拟数据

运行数据生成脚本：

```bash
python generate_data.py
```

支持以下参数：

- `--interactive` - 交互式配置生成参数
- `--skip-clear` - 跳过清空现有数据
- `--config` - 指定配置文件路径

示例：

```bash
# 使用默认配置生成数据
python generate_data.py

# 交互式配置
python generate_data.py --interactive

# 使用自定义配置文件
python generate_data.py --config /path/to/config.yaml

# 跳过数据清空
python generate_data.py --skip-clear
```

### 配置数据生成参数

在 `config.yaml` 中配置数据生成参数：

```yaml
data_generation:
  level1_count: 1                    # 一级组织数量
  ministry_bureau_count: 12           # 部机关局数量
  local_bureau_count: 20             # 地方厅局数量
  ministry_dept_count: 5             # 部机关局下属处室数量
  local_dept_min: 3                  # 地方厅局下属处室最小数量
  local_dept_max: 5                  # 地方厅局下属处室最大数量
  device_min: 0                      # 各单位设备最小数量
  device_max: 4                      # 各单位设备最大数量
  days: 30                           # 生成数据天数
  gpu_per_device: 8                  # 每台设备GPU卡数量
  initial_device_ratio: 0.3          # 初始设备比例
  device_add_prob: 0.002             # 设备添加概率
  device_remove_prob: 0.001          # 设备移除概率
  always_high_load_ratio: 0.15       # 始终高负载比例
```

## 数据库表结构

主要数据表包括：

- **organization** - 组织机构表（三级层级）
- **device** - 设备信息表
- **gpu_card_info** - GPU卡信息表
- **device_gpu_monitor** - GPU监控数据表
- **device_cpu_monitor** - CPU监控数据表
- **device_memory_monitor** - 内存监控数据表
- **device_disk_monitor** - 磁盘监控数据表
- **device_network_monitor** - 网络监控数据表
- **collect_task** - 采集任务表
- **collect_info** - 采集信息表
- **daily_device_summary** - 每日设备汇总表
- **daily_gpu_usage_summary** - 每日GPU使用率汇总表

## 支持的GPU型号

- NVIDIA H100 80GB HBM3
- NVIDIA A100 80GB PCIe
- NVIDIA A100 40GB PCIe
- NVIDIA RTX 4090
- NVIDIA RTX 4080
- NVIDIA A800 80GB SXM

## 注意事项

1. 确保数据库服务已启动并可访问
2. 首次运行 `init_db.py` 时会检测并提示是否清空现有数据
3. 数据生成过程可能需要较长时间，取决于配置的数据量
4. 生成的监控数据会保存到 `generated_data` 目录下的CSV文件中

## 故障排除

### 数据库连接失败

检查以下内容：
- 数据库服务是否已启动
- 连接配置是否正确（主机、端口、用户名、密码）
- 数据库是否已创建
- 防火墙是否允许连接

### SQL执行失败

- 确认数据库类型为PostgreSQL或OpenGauss
- 检查SQL文件路径是否正确
- 查看错误信息以获取详细问题

## 许可证

本项目仅供学习和研究使用。
