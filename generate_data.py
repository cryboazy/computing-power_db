#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
智能算力监测平台 - 数据生成脚本 (优化版)
生成单位、设备、GPU卡及监测数据
优化内容：
1. 三级组织层级结构
2. 设备与GPU卡正确关联
3. 同一时间点监控数据共享msg_id
4. 添加汇总数据表
5. 添加采集任务数据
6. 数据趋势性和连续性
"""

import psycopg2
import random
import uuid
import csv
import os
import argparse
from datetime import datetime, timedelta
from decimal import Decimal
import math
from db_config import get_database_config, get_data_generation_config

DATA_DIR = 'generated_data'

GPU_MODELS = [
    {
        'name': 'NVIDIA H100 80GB HBM3',
        'memory_gb': 80,
        'tflops_fp32': 67.0,
        'tflops_fp16': 1979.0,
        'tflops_fp64': 33.5,
        'tflops_int8': 3958.0,
        'tdp_watts': 700,
        'card_type': 1,
        'cuda_cores': 16896,
        'memory_type': 'HBM3',
        'memory_bus_width': 5120,
        'memory_bandwidth_gbps': 3352,
        'architecture': 'Hopper',
        'compute_capability': '9.0',
        'base_clock_mhz': 1095,
        'boost_clock_mhz': 1980,
        'pcie_gen': 5,
        'pcie_width': 16
    },
    {
        'name': 'NVIDIA A100 80GB PCIe',
        'memory_gb': 80,
        'tflops_fp32': 19.5,
        'tflops_fp16': 312.0,
        'tflops_fp64': 9.7,
        'tflops_int8': 624.0,
        'tdp_watts': 300,
        'card_type': 1,
        'cuda_cores': 6912,
        'memory_type': 'HBM2e',
        'memory_bus_width': 5120,
        'memory_bandwidth_gbps': 2039,
        'architecture': 'Ampere',
        'compute_capability': '8.0',
        'base_clock_mhz': 1065,
        'boost_clock_mhz': 1410,
        'pcie_gen': 4,
        'pcie_width': 16
    },
    {
        'name': 'NVIDIA A100 40GB PCIe',
        'memory_gb': 40,
        'tflops_fp32': 19.5,
        'tflops_fp16': 312.0,
        'tflops_fp64': 9.7,
        'tflops_int8': 624.0,
        'tdp_watts': 250,
        'card_type': 1,
        'cuda_cores': 6912,
        'memory_type': 'HBM2',
        'memory_bus_width': 5120,
        'memory_bandwidth_gbps': 1555,
        'architecture': 'Ampere',
        'compute_capability': '8.0',
        'base_clock_mhz': 1065,
        'boost_clock_mhz': 1410,
        'pcie_gen': 4,
        'pcie_width': 16
    },
    {
        'name': 'NVIDIA RTX 4090',
        'memory_gb': 24,
        'tflops_fp32': 82.6,
        'tflops_fp16': 330.4,
        'tflops_fp64': 1.29,
        'tflops_int8': 1321.0,
        'tdp_watts': 450,
        'card_type': 2,
        'cuda_cores': 16384,
        'memory_type': 'GDDR6X',
        'memory_bus_width': 384,
        'memory_bandwidth_gbps': 1008,
        'architecture': 'Ada Lovelace',
        'compute_capability': '8.9',
        'base_clock_mhz': 2235,
        'boost_clock_mhz': 2520,
        'pcie_gen': 4,
        'pcie_width': 16
    },
    {
        'name': 'NVIDIA RTX 4080',
        'memory_gb': 16,
        'tflops_fp32': 48.7,
        'tflops_fp16': 194.8,
        'tflops_fp64': 0.76,
        'tflops_int8': 779.0,
        'tdp_watts': 320,
        'card_type': 2,
        'cuda_cores': 9728,
        'memory_type': 'GDDR6X',
        'memory_bus_width': 256,
        'memory_bandwidth_gbps': 717,
        'architecture': 'Ada Lovelace',
        'compute_capability': '8.9',
        'base_clock_mhz': 2205,
        'boost_clock_mhz': 2505,
        'pcie_gen': 4,
        'pcie_width': 16
    },
    {
        'name': 'NVIDIA A800 80GB SXM',
        'memory_gb': 80,
        'tflops_fp32': 19.5,
        'tflops_fp16': 312.0,
        'tflops_fp64': 9.7,
        'tflops_int8': 624.0,
        'tdp_watts': 300,
        'card_type': 1,
        'cuda_cores': 6912,
        'memory_type': 'HBM2e',
        'memory_bus_width': 5120,
        'memory_bandwidth_gbps': 2039,
        'architecture': 'Ampere',
        'compute_capability': '8.0',
        'base_clock_mhz': 1065,
        'boost_clock_mhz': 1410,
        'pcie_gen': 4,
        'pcie_width': 16
    }
]

PROVINCES = [
    {'name': '北京市', 'code': '110000'},
    {'name': '广东省', 'code': '440000'},
    {'name': '江苏省', 'code': '320000'},
    {'name': '浙江省', 'code': '330000'},
    {'name': '上海市', 'code': '310000'},
    {'name': '四川省', 'code': '510000'},
    {'name': '湖北省', 'code': '420000'},
    {'name': '山东省', 'code': '370000'},
    {'name': '河南省', 'code': '410000'},
    {'name': '陕西省', 'code': '610000'},
    {'name': '安徽省', 'code': '340000'},
]

SERVER_MODELS = [
    'Dell PowerEdge R750xa',
    'HPE Cray XD670',
    'Lenovo ThinkSystem SR665',
    'Inspur NF5688M6',
    'Huawei Ascend 910 Server',
    'Sugon A620-G30'
]

OS_TYPES = [
    'Ubuntu 22.04 LTS',
    'CentOS 8.4',
    'Rocky Linux 9.0',
    'Red Hat Enterprise Linux 8.6'
]

BUSINESS_NETWORKS = [
    {'name': '本地部署', 'code': 'NET_LOCAL', 'parent_code': None},
    {'name': '主干网', 'code': 'NET_BACKBONE', 'parent_code': None},
    {'name': 'H网', 'code': 'NET_H', 'parent_code': None},
    {'name': '互联网', 'code': 'NET_INTERNET', 'parent_code': None},
    {'name': 'J网', 'code': 'NET_J', 'parent_code': None},
    {'name': '蓝网', 'code': 'NET_BLUE', 'parent_code': None},
    {'name': '数据域', 'code': 'NET_DATA', 'parent_code': None},
]

DEFAULT_CONFIG = {
    'level1_count': 1,
    'ministry_bureau_count': 12,
    'local_bureau_count': 20,
    'ministry_dept_count': 5,
    'local_dept_min': 3,
    'local_dept_max': 5,
    'device_min': 0,
    'device_max': 4,
    'days': 30,
    'gpu_per_device': 8,
    'initial_device_ratio': 0.3,
    'device_add_prob': 0.002,
    'device_remove_prob': 0.001,
    'always_high_load_ratio': 0.15
}


def get_default_config():
    config = DEFAULT_CONFIG.copy()
    config.update(get_data_generation_config())
    return config


def get_user_config():
    print("\n" + "=" * 60)
    print("交互式参数配置")
    print("=" * 60)
    print("提示: 直接按回车使用默认值\n")
    
    config = {}
    
    def get_int_input(prompt, default, min_val=1, max_val=None):
        while True:
            try:
                value = input(f"{prompt} [默认: {default}]: ").strip()
                if value == '':
                    return default
                value = int(value)
                if value < min_val:
                    print(f"  错误: 值不能小于 {min_val}")
                    continue
                if max_val and value > max_val:
                    print(f"  错误: 值不能大于 {max_val}")
                    continue
                return value
            except ValueError:
                print("  错误: 请输入有效的整数")
    
    def get_range_input(prompt, default_min, default_max):
        print(f"{prompt}:")
        min_val = get_int_input(f"  最小值", default_min, min_val=1)
        max_val = get_int_input(f"  最大值", default_max, min_val=min_val)
        return min_val, max_val
    
    print("\n【组织层级配置】")
    print("-" * 40)
    default_cfg = get_default_config()
    config['level1_count'] = get_int_input(
        "一级组织(部机关)数量", 
        default_cfg['level1_count'], 
        min_val=1, max_val=5
    )
    
    config['ministry_bureau_count'] = get_int_input(
        "部机关局数量(二级组织)", 
        default_cfg['ministry_bureau_count'], 
        min_val=1, max_val=20
    )
    
    config['local_bureau_count'] = get_int_input(
        "地方厅局数量(二级组织)", 
        default_cfg['local_bureau_count'], 
        min_val=1, max_val=len(PROVINCES) - 1
    )
    
    config['ministry_dept_count'] = get_int_input(
        "部机关局下属处室数量(三级组织)", 
        default_cfg['ministry_dept_count'], 
        min_val=1, max_val=20
    )
    
    config['local_dept_min'], config['local_dept_max'] = get_range_input(
        "地方厅局下属处室数量范围(三级组织)", 
        default_cfg['local_dept_min'], 
        default_cfg['local_dept_max']
    )
    
    print("\n【设备配置】")
    print("-" * 40)
    config['device_min'], config['device_max'] = get_range_input(
        "各单位设备数量范围", 
        default_cfg['device_min'], 
        default_cfg['device_max']
    )
    
    config['gpu_per_device'] = get_int_input(
        "每台设备GPU卡数量", 
        default_cfg['gpu_per_device'], 
        min_val=1, max_val=16
    )
    
    print("\n【时间配置】")
    print("-" * 40)
    config['days'] = get_int_input(
        "生成数据天数", 
        default_cfg['days'], 
        min_val=1, max_val=365
    )
    
    print("\n" + "=" * 60)
    print("配置摘要:")
    print("-" * 40)
    print(f"  一级组织: {config['level1_count']} 个")
    print(f"  部机关局: {config['ministry_bureau_count']} 个")
    print(f"  地方厅局: {config['local_bureau_count']} 个")
    print(f"  部机关局下属处室: {config['ministry_dept_count']} 个/局")
    print(f"  地方厅局下属处室: {config['local_dept_min']}-{config['local_dept_max']} 个/厅")
    print(f"  设备数量: {config['device_min']}-{config['device_max']} 台/单位")
    print(f"  每台设备GPU: {config['gpu_per_device']} 块")
    print(f"  数据时间跨度: {config['days']} 天")
    
    total_l2 = config['ministry_bureau_count'] + config['local_bureau_count']
    avg_local_dept = (config['local_dept_min'] + config['local_dept_max']) // 2
    total_l3 = config['ministry_bureau_count'] * config['ministry_dept_count'] + config['local_bureau_count'] * avg_local_dept
    avg_device = (config['device_min'] + config['device_max']) // 2
    total_devices = total_l3 * avg_device
    total_gpus = total_devices * config['gpu_per_device']
    
    print(f"\n预估数据量:")
    print(f"  二级组织总数: {total_l2} 个")
    print(f"  三级组织总数: 约 {total_l3} 个")
    print(f"  设备总数: 约 {total_devices} 台")
    print(f"  GPU卡总数: 约 {total_gpus} 块")
    print(f"  监控记录数: 约 {total_devices * config['days'] * 1440} 条/表")
    print("=" * 60)
    
    confirm = input("\n确认以上配置? [Y/n]: ").strip().lower()
    if confirm in ['n', 'no']:
        print("已取消，请重新配置...")
        return get_user_config()
    
    return config


def get_connection():
    config = get_database_config()
    return psycopg2.connect(
        host=config['host'],
        port=config['port'],
        database=config['database'],
        user=config['user'],
        password=config['password']
    )


def execute_sql_file(conn, sql_file_path, clear_data=False):
    print(f"正在执行SQL文件: {sql_file_path}")
    
    if not os.path.exists(sql_file_path):
        print(f"  - SQL文件不存在: {sql_file_path}")
        return False
    
    cursor = conn.cursor()
    
    try:
        if clear_data:
            print("正在删除现有表...")
            tables_to_drop = [
                'sys_user_role',
                'sys_role_menu',
                'sys_role',
                'sys_user',
                'sys_operation_log',
                'sys_menu',
                'schedule_job_log',
                'schedule_job',
                'statistics_data',
                'org_gpu_usage_summary',
                'daily_gpu_usage_summary',
                'daily_device_summary',
                'collect_task_detail',
                'collect_task',
                'collect_info',
                'device_gpu_monitor_detail',
                'device_gpu_monitor',
                'device_cpu_monitor',
                'device_memory_monitor',
                'device_disk_monitor',
                'device_network_monitor',
                'device_gpu_monitor_detail_backup',
                'device_gpu_monitor_backup',
                'device_cpu_monitor_backup',
                'device_memory_monitor_backup',
                'device_disk_monitor_backup',
                'device_network_monitor_backup',
                'gpu_card_info',
                'device',
                'organization',
                'network',
                'dic_info'
            ]
            
            for table in tables_to_drop:
                try:
                    cursor.execute(f"DROP TABLE IF EXISTS {table} CASCADE")
                    print(f"  - 已删除表: {table}")
                except Exception as e:
                    print(f"  - 删除表 {table} 时出错: {e}")
            
            conn.commit()
        
        with open(sql_file_path, 'r', encoding='utf-8') as f:
            sql_content = f.read()
        
        sql_content = sql_content.replace('WITH (\n\torientation=row,\n\tcompression=no\n);', ';')
        sql_content = sql_content.replace('WITH (orientation=row, compression=no);', ';')
        sql_content = sql_content.replace(' TABLESPACE pg_default', '')
        
        import re
        sql_content = re.sub(r' LOCAL\([^)]+\)', '', sql_content)
        
        print("正在执行SQL语句...")
        cursor.execute(sql_content)
        conn.commit()
        print("SQL执行成功!")
        return True
        
    except Exception as e:
        conn.rollback()
        print(f"SQL执行失败: {e}")
        return False
    finally:
        cursor.close()


def ensure_data_dir():
    if not os.path.exists(DATA_DIR):
        os.makedirs(DATA_DIR)
        print(f"创建数据目录: {DATA_DIR}")


def clear_all_data(conn, skip_clear=False):
    if skip_clear:
        print("跳过清空数据库中的现有数据...")
        return
    
    print("正在清空数据库中的现有数据...")
    cursor = conn.cursor()
    
    tables_to_clear = [
        'device_gpu_monitor_detail',
        'device_gpu_monitor',
        'device_cpu_monitor',
        'device_memory_monitor',
        'device_disk_monitor',
        'device_network_monitor',
        'gpu_card_info',
        'device',
        'organization',
        'network'
    ]
    
    for table in tables_to_clear:
        try:
            cursor.execute(f"TRUNCATE TABLE {table} CASCADE")
            print(f"  - 已清空表: {table}")
        except Exception as e:
            print(f"  - 清空表 {table} 时出错: {e}")
    
    conn.commit()
    cursor.close()
    print("数据清空完成!\n")


def generate_network_csv():
    print("正在生成业务网络数据到CSV...")
    
    network_rows = []
    network_list = []
    network_id = 1
    
    for net in BUSINESS_NETWORKS:
        row = {
            'id': network_id,
            'code': net['code'],
            'parent_code': net.get('parent_code', ''),
            'name': net['name'],
            'create_time': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            'update_time': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            'create_by': 'system',
            'update_by': 'system',
            'deleted': 0
        }
        network_rows.append(row)
        network_list.append({
            'id': network_id,
            'code': net['code'],
            'name': net['name'],
            'parent_code': net.get('parent_code')
        })
        network_id += 1
    
    csv_path = os.path.join(DATA_DIR, 'network.csv')
    with open(csv_path, 'w', newline='', encoding='utf-8') as f:
        fieldnames = ['id', 'code', 'parent_code', 'name', 'create_time', 'update_time', 'create_by', 'update_by', 'deleted']
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(network_rows)
    
    print(f"  - 已生成 {len(network_rows)} 条业务网络数据到 {csv_path}")
    return network_list


def generate_organizations_csv(config=None):
    print("正在生成三级组织结构数据到CSV...")
    
    if config is None:
        config = get_default_config()
    
    org_rows = []
    org_hierarchy = {'level1': [], 'level2': [], 'level3': []}
    org_id = 1
    
    level1_org = {
        'name': '全国',
        'code': 'CHINA',
        'province': '北京市',
        'province_code': '110000'
    }

    row = {
        'id': 1,
        'parent_id': 0,
        'name': level1_org['name'],
        'code': level1_org['code'],
        'type': 1,
        'sort': 1,
        'leader': '部长',
        'phone': '010-12345678',
        'email': 'office@ministry.gov.cn',
        'address': '北京市西城区XX路XX号',
        'status': 1,
        'remark': '一级组织-全国',
        'province': level1_org['province'],
        'province_code': level1_org['province_code']
    }
    org_rows.append(row)
    org_hierarchy['level1'].append({
        'id': 1,
        'name': level1_org['name'],
        'code': level1_org['code'],
        'province': level1_org['province'],
        'province_code': level1_org['province_code']
    })
    nationwide_id = 1
    org_id = 2

    local_bureau_category_id = 2
    row = {
        'id': 2,
        'parent_id': nationwide_id,
        'name': '地方厅局',
        'code': 'LOCAL',
        'type': 2,
        'sort': 2,
        'leader': '',
        'phone': '',
        'email': '',
        'address': '',
        'status': 1,
        'remark': '二级组织-地方厅局分类',
        'province': '北京市',
        'province_code': '110000'
    }
    org_rows.append(row)
    org_hierarchy['level2'].append({
        'id': 2,
        'parent_id': nationwide_id,
        'name': '地方厅局',
        'code': 'LOCAL',
        'province': '北京市',
        'province_code': '110000',
        'level1_id': nationwide_id,
        'level1_name': level1_org['name'],
        'org_category': 'local_bureau_category'
    })
    org_id = 3

    ministry_category_id = 7
    row = {
        'id': 7,
        'parent_id': nationwide_id,
        'name': '部机关',
        'code': 'MINISTRY',
        'type': 2,
        'sort': 7,
        'leader': '',
        'phone': '',
        'email': '',
        'address': '',
        'status': 1,
        'remark': '二级组织-部机关分类',
        'province': '北京市',
        'province_code': '110000'
    }
    org_rows.append(row)
    org_hierarchy['level2'].append({
        'id': 7,
        'parent_id': nationwide_id,
        'name': '部机关',
        'code': 'MINISTRY',
        'province': '北京市',
        'province_code': '110000',
        'level1_id': nationwide_id,
        'level1_name': level1_org['name'],
        'org_category': 'ministry_category'
    })
    org_id = 8

    num_local_bureaus = min(config['local_bureau_count'], len(PROVINCES) - 1)
    for idx, province in enumerate(PROVINCES[1:1+num_local_bureaus], 1):
        province_name_short = province['name'].replace('省', '').replace('市', '')
        org_code = f"A{idx:02d}"
        row = {
            'id': org_id,
            'parent_id': local_bureau_category_id,
            'name': f"{province['name']}XX厅",
            'code': org_code,
            'type': 3,
            'sort': org_id,
            'leader': f"厅长{random.randint(1, 10)}",
            'phone': f"0{random.randint(10, 99)}-{random.randint(10000000, 99999999)}",
            'email': f"office@{province_name_short}.gov.cn",
            'address': f"{province['name']}省会城市XX路XX号",
            'status': 1,
            'remark': '三级组织-地方厅局',
            'province': province['name'],
            'province_code': province['code']
        }
        org_rows.append(row)
        org_hierarchy['level3'].append({
            'id': org_id,
            'parent_id': local_bureau_category_id,
            'name': row['name'],
            'code': org_code,
            'province': province['name'],
            'province_code': province['code'],
            'level1_id': nationwide_id,
            'level1_name': level1_org['name'],
            'level2_id': local_bureau_category_id,
            'level2_name': '地方厅局',
            'org_category': 'local_bureau'
        })
        org_id += 1
    
    ministry_bureaus = [
        {'name': '科技发展局'},
        {'name': '规划发展局'},
        {'name': '产业发展局'},
        {'name': '信息化推进局'},
        {'name': '政策法规局'},
        {'name': '国际合作局'},
        {'name': '财务审计局'},
        {'name': '人事教育局'},
        {'name': '综合管理局'},
        {'name': '数据资源局'},
        {'name': '网络安全局'},
        {'name': '标准规范局'},
        {'name': '运行监测局'},
        {'name': '创新应用局'},
        {'name': '基础设施局'},
        {'name': '质量监督局'},
        {'name': '服务管理局'},
        {'name': '评估考核局'},
        {'name': '培训发展局'},
        {'name': '交流合作局'},
    ]

    num_ministry_bureaus = min(config['ministry_bureau_count'], len(ministry_bureaus))
    for idx, bureau in enumerate(ministry_bureaus[:num_ministry_bureaus], 1):
        org_code = f"B{idx:02d}"
        row = {
            'id': org_id,
            'parent_id': ministry_category_id,
            'name': bureau['name'],
            'code': org_code,
            'type': 3,
            'sort': org_id,
            'leader': f"局长{random.randint(1, 10)}",
            'phone': f"010-{random.randint(10000000, 99999999)}",
            'email': f"bureau{idx}@ministry.gov.cn",
            'address': '北京市西城区XX路XX号',
            'status': 1,
            'remark': '三级组织-部机关局',
            'province': '北京市',
            'province_code': '110000'
        }
        org_rows.append(row)
        org_hierarchy['level3'].append({
            'id': org_id,
            'parent_id': ministry_category_id,
            'name': bureau['name'],
            'code': org_code,
            'province': '北京市',
            'province_code': '110000',
            'level1_id': nationwide_id,
            'level1_name': level1_org['name'],
            'level2_id': ministry_category_id,
            'level2_name': '部机关',
            'org_category': 'ministry_bureau'
        })
        org_id += 1
    
    csv_path = os.path.join(DATA_DIR, 'organization.csv')
    with open(csv_path, 'w', newline='', encoding='utf-8') as f:
        fieldnames = ['id', 'parent_id', 'name', 'code', 'type', 'sort', 'leader', 'phone', 'email', 'address', 'status', 'remark', 'province', 'province_code']
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(org_rows)
    
    print(f"  - 已生成 {len(org_rows)} 条组织数据到 {csv_path}")
    print(f"    一级组织(全国): {len(org_hierarchy['level1'])} 个")
    print(f"    二级组织(地方厅局+部机关): {len(org_hierarchy['level2'])} 个")
    local_bureau_cat_count = len([o for o in org_hierarchy['level2'] if o.get('org_category') == 'local_bureau_category'])
    ministry_cat_count = len([o for o in org_hierarchy['level2'] if o.get('org_category') == 'ministry_category'])
    print(f"      - 地方厅局分类: {local_bureau_cat_count} 个")
    print(f"      - 部机关分类: {ministry_cat_count} 个")
    print(f"    三级组织(地方厅局+部机关局): {len(org_hierarchy['level3'])} 个")
    local_bureau_count = len([o for o in org_hierarchy['level3'] if o.get('org_category') == 'local_bureau'])
    ministry_bureau_count = len([o for o in org_hierarchy['level3'] if o.get('org_category') == 'ministry_bureau'])
    print(f"      - 地方厅局: {local_bureau_count} 个")
    print(f"      - 部机关局: {ministry_bureau_count} 个")
    
    return org_hierarchy


def generate_devices_csv(org_hierarchy, network_list, config=None, start_time=None, end_time=None):
    print("正在生成GPU服务器数据到CSV...")
    
    if config is None:
        config = get_default_config()
    
    if start_time is None:
        end_time = datetime.now().replace(second=0, microsecond=0)
        start_time = end_time - timedelta(days=config.get('days', 30))
    
    devices = []
    rows = []
    device_id = 1
    gpu_per_device = config.get('gpu_per_device', 8)
    initial_ratio = config.get('initial_device_ratio', 0.3)
    
    network_map = {n['code']: n for n in network_list}
    all_network_codes = [n['code'] for n in network_list]
    
    total_minutes = int((end_time - start_time).total_seconds() / 60)
    
    for l3 in org_hierarchy['level3']:
        max_server_count = random.randint(config['device_min'], config['device_max'])
        initial_count = max(0, int(max_server_count * initial_ratio))
        
        net_code = random.choice(all_network_codes)
        
        if net_code in network_map:
            net_module_code = net_code
            net_module_name = network_map[net_code]['name']
        else:
            net_module_code = 'NET_LOCAL'
            net_module_name = '本地部署'
        
        for i in range(max_server_count):
            gpu_model = random.choice(GPU_MODELS)
            server_model = random.choice(SERVER_MODELS)
            device_code = f"SRV-{uuid.uuid4().hex[:12].upper()}"
            
            cpu_cores = random.choice([32, 48, 64, 96, 128])
            memory_size = random.choice([256, 512, 1024, 2048])
            disk_size = random.choice([2000, 4000, 8000, 16000])
            
            detail_info = str({
                'manufacturer': server_model.split()[0],
                'model': server_model,
                'cpu_model': random.choice(['Intel Xeon Platinum 8380', 'AMD EPYC 7763', 'Intel Xeon Gold 6348']),
                'gpu_model': gpu_model['name'],
                'gpu_count': gpu_per_device,
                'memory_gb': memory_size,
                'disk_gb': disk_size,
                'network': net_module_name
            })
            
            if i < initial_count:
                online_minute = random.randint(0, max(1, total_minutes // 10))
                online_time = start_time + timedelta(minutes=online_minute)
            else:
                online_minute = random.randint(0, total_minutes)
                online_time = start_time + timedelta(minutes=online_minute)
            
            if random.random() < 0.1:
                offline_minute = random.randint(online_minute + 1, total_minutes)
                offline_time = start_time + timedelta(minutes=offline_minute)
            else:
                offline_time = None
            
            row = {
                'id': device_id,
                'name': f"{server_model}-{i+1:02d}",
                'code': device_code,
                'organization_id': l3['id'],
                'organization_code': l3['code'],
                'cpu_cores': cpu_cores,
                'memory_size': memory_size,
                'disk_size': disk_size,
                'gpu_count': gpu_per_device,
                'gpu_model': gpu_model['name'],
                'total_memory': gpu_model['memory_gb'] * gpu_per_device,
                'operating_system': random.choice(OS_TYPES),
                'purpose': random.choice([1, 2, 3]),
                'net_module_code': net_module_code,
                'net_module_name': net_module_name,
                'detail_info': detail_info,
                'online_status': 1
            }
            rows.append(row)
            
            devices.append({
                'id': device_id,
                'org_id': l3['id'],
                'org_code': l3['code'],
                'org_name': l3['name'],
                'province': l3['province'],
                'province_code': l3['province_code'],
                'level1_id': l3['level1_id'],
                'level1_name': l3['level1_name'],
                'level2_id': l3['level2_id'],
                'level2_name': l3['level2_name'],
                'gpu_model': gpu_model,
                'device_code': device_code,
                'cpu_cores': cpu_cores,
                'memory_size': memory_size,
                'disk_size': disk_size,
                'net_module_code': net_module_code,
                'net_module_name': net_module_name,
                'gpu_per_device': gpu_per_device,
                'online_time': online_time,
                'offline_time': offline_time
            })
            device_id += 1
    
    csv_path = os.path.join(DATA_DIR, 'device.csv')
    with open(csv_path, 'w', newline='', encoding='utf-8') as f:
        fieldnames = ['id', 'name', 'code', 'organization_id', 'organization_code', 'cpu_cores', 'memory_size', 'disk_size', 'gpu_count', 'gpu_model', 'total_memory', 'operating_system', 'purpose', 'net_module_code', 'net_module_name', 'detail_info', 'online_status']
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)
    
    print(f"  - 已生成 {len(rows)} 条服务器数据到 {csv_path}")
    return devices


def generate_gpu_cards_csv(devices):
    print("正在生成GPU卡数据到CSV...")
    rows = []
    gpu_card_id = 1
    
    unique_gpu_models = {}
    for device in devices:
        gpu_model = device['gpu_model']
        model_name = gpu_model['name']
        if model_name not in unique_gpu_models:
            unique_gpu_models[model_name] = gpu_model
    
    for model_name, gpu_model in unique_gpu_models.items():
        row = {
            'id': gpu_card_id,
            'gpu_index': 0,
            'gpu_name': gpu_model['name'],
            'card_type': gpu_model['card_type'],
            'cuda_cores': gpu_model['cuda_cores'],
            'memory_total_mb': int(gpu_model['memory_gb'] * 1024),
            'memory_total_gb': gpu_model['memory_gb'],
            'tdp_watts': gpu_model['tdp_watts'],
            'max_power_watts': int(gpu_model['tdp_watts'] * 1.1),
            'memory_type': gpu_model['memory_type'],
            'memory_bus_width': gpu_model['memory_bus_width'],
            'memory_bandwidth_gbps': gpu_model['memory_bandwidth_gbps'],
            'architecture': gpu_model['architecture'],
            'compute_capability': gpu_model['compute_capability'],
            'base_clock_mhz': gpu_model['base_clock_mhz'],
            'boost_clock_mhz': gpu_model['boost_clock_mhz'],
            'pcie_gen': gpu_model['pcie_gen'],
            'pcie_width': gpu_model['pcie_width'],
            'tflops_fp32': gpu_model['tflops_fp32'],
            'tflops_fp16': gpu_model['tflops_fp16'],
            'tflops_fp64': gpu_model['tflops_fp64'],
            'tflops_int8': gpu_model['tflops_int8'],
            'status': 1
        }
        rows.append(row)
        gpu_card_id += 1
    
    csv_path = os.path.join(DATA_DIR, 'gpu_card_info.csv')
    with open(csv_path, 'w', newline='', encoding='utf-8') as f:
        fieldnames = ['id', 'gpu_index', 'gpu_name', 'card_type', 'cuda_cores', 'base_clock_mhz', 'boost_clock_mhz', 'memory_total_mb', 'memory_total_gb', 'pcie_gen', 'pcie_width', 'tflops_fp32', 'tflops_fp16', 'tflops_fp64', 'tflops_int8', 'tdp_watts', 'max_power_watts', 'memory_type', 'memory_bus_width', 'memory_bandwidth_gbps', 'architecture', 'compute_capability', 'status']
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)
    
    print(f"  - 已生成 {len(rows)} 条GPU卡数据到 {csv_path}")


GPU_USAGE_MODE_OVERLOAD = 'overload'
GPU_USAGE_MODE_NORMAL = 'normal'
GPU_USAGE_MODE_IDLE = 'idle'

GPU_USAGE_MODES = [GPU_USAGE_MODE_OVERLOAD, GPU_USAGE_MODE_NORMAL, GPU_USAGE_MODE_IDLE]

WORK_HOUR_START = 9
WORK_HOUR_END = 18


def is_work_time(dt):
    if dt.weekday() >= 5:
        return False
    return WORK_HOUR_START <= dt.hour < WORK_HOUR_END


class DeviceState:
    def __init__(self, device, start_time, always_high_load=False):
        self.device = device
        self.gpu_model = device['gpu_model']
        self.gpu_count = device.get('gpu_per_device', 8)
        self.always_high_load = always_high_load
        
        if always_high_load:
            self.usage_mode = GPU_USAGE_MODE_OVERLOAD
            self.work_base_gpu_util = random.uniform(75, 90)
            self.work_gpu_util_min = 70
            self.work_gpu_util_max = 98
            self.idle_base_gpu_util = random.uniform(70, 85)
            self.idle_gpu_util_min = 65
            self.idle_gpu_util_max = 95
            self.base_mem_util = random.uniform(70, 90)
            self.base_temp = random.uniform(70, 80)
            self.base_power = self.gpu_model['tdp_watts'] * random.uniform(0.85, 0.98)
        else:
            usage_mode_weights = [0.25, 0.50, 0.25]
            self.usage_mode = random.choices(GPU_USAGE_MODES, weights=usage_mode_weights)[0]
            
            if self.usage_mode == GPU_USAGE_MODE_OVERLOAD:
                self.work_base_gpu_util = random.uniform(65, 85)
                self.work_gpu_util_min = 60
                self.work_gpu_util_max = 95
                self.idle_base_gpu_util = random.uniform(5, 15)
                self.idle_gpu_util_min = 2
                self.idle_gpu_util_max = 25
                self.base_mem_util = random.uniform(60, 80)
                self.base_temp = random.uniform(65, 75)
                self.base_power = self.gpu_model['tdp_watts'] * random.uniform(0.7, 0.9)
            elif self.usage_mode == GPU_USAGE_MODE_IDLE:
                self.work_base_gpu_util = random.uniform(10, 25)
                self.work_gpu_util_min = 5
                self.work_gpu_util_max = 30
                self.idle_base_gpu_util = random.uniform(3, 10)
                self.idle_gpu_util_min = 1
                self.idle_gpu_util_max = 15
                self.base_mem_util = random.uniform(20, 40)
                self.base_temp = random.uniform(40, 50)
                self.base_power = self.gpu_model['tdp_watts'] * random.uniform(0.1, 0.3)
            else:
                self.work_base_gpu_util = random.uniform(35, 55)
                self.work_gpu_util_min = 30
                self.work_gpu_util_max = 60
                self.idle_base_gpu_util = random.uniform(5, 15)
                self.idle_gpu_util_min = 2
                self.idle_gpu_util_max = 25
                self.base_mem_util = random.uniform(40, 60)
                self.base_temp = random.uniform(50, 60)
                self.base_power = self.gpu_model['tdp_watts'] * random.uniform(0.4, 0.6)
        
        self.base_gpu_util = self.work_base_gpu_util
        self.gpu_util_min = self.work_gpu_util_min
        self.gpu_util_max = self.work_gpu_util_max
        
        self.gpu_utils = [self.base_gpu_util + random.uniform(-5, 5) for _ in range(self.gpu_count)]
        self.mem_utils = [self.base_mem_util + random.uniform(-5, 5) for _ in range(self.gpu_count)]
        self.temps = [self.base_temp + random.uniform(-3, 3) for _ in range(self.gpu_count)]
        self.powers = [self.base_power / self.gpu_count + random.uniform(-10, 10) for _ in range(self.gpu_count)]
        
        if always_high_load or self.usage_mode == GPU_USAGE_MODE_OVERLOAD:
            self.cpu_util = random.uniform(60, 85)
            self.mem_percent = random.uniform(60, 80)
        elif self.usage_mode == GPU_USAGE_MODE_IDLE:
            self.cpu_util = random.uniform(10, 30)
            self.mem_percent = random.uniform(20, 40)
        else:
            self.cpu_util = random.uniform(30, 55)
            self.mem_percent = random.uniform(40, 60)
        
        self.cumulative_bytes_sent = random.randint(1000000000000, 10000000000000)
        self.cumulative_bytes_recv = random.randint(1000000000000, 10000000000000)
        self.cumulative_read_bytes = random.randint(1000000000000, 10000000000000)
        self.cumulative_write_bytes = random.randint(500000000000, 5000000000000)
        
        self.trend_phase = random.uniform(0, 2 * math.pi)
        self.trend_freq = random.uniform(0.01, 0.05)
        
        if always_high_load or self.usage_mode == GPU_USAGE_MODE_OVERLOAD:
            self.trend_amplitude = random.uniform(5, 8)
        elif self.usage_mode == GPU_USAGE_MODE_IDLE:
            self.trend_amplitude = random.uniform(3, 6)
        else:
            self.trend_amplitude = random.uniform(5, 10)
        
        self.idle_trend_amplitude = self.trend_amplitude * 0.3
        if always_high_load:
            self.idle_trend_amplitude = self.trend_amplitude
    
    def update(self, time_delta_minutes, current_time=None):
        self.trend_phase += self.trend_freq
        
        is_work = current_time is None or is_work_time(current_time)
        
        if is_work:
            self.base_gpu_util = self.work_base_gpu_util
            self.gpu_util_min = self.work_gpu_util_min
            self.gpu_util_max = self.work_gpu_util_max
            trend = math.sin(self.trend_phase) * self.trend_amplitude
        else:
            self.base_gpu_util = self.idle_base_gpu_util
            self.gpu_util_min = self.idle_gpu_util_min
            self.gpu_util_max = self.idle_gpu_util_max
            trend = math.sin(self.trend_phase) * self.idle_trend_amplitude
        
        for i in range(self.gpu_count):
            noise = random.uniform(-3, 3)
            raw_util = self.base_gpu_util + trend + noise
            self.gpu_utils[i] = max(self.gpu_util_min, min(self.gpu_util_max, raw_util))
            
            mem_trend = trend * 0.3
            mem_noise = random.uniform(-2, 2)
            if self.usage_mode == GPU_USAGE_MODE_OVERLOAD:
                self.mem_utils[i] = max(50, min(90, self.base_mem_util + mem_trend + mem_noise))
            elif self.usage_mode == GPU_USAGE_MODE_IDLE:
                self.mem_utils[i] = max(15, min(45, self.base_mem_util + mem_trend + mem_noise))
            else:
                self.mem_utils[i] = max(30, min(70, self.base_mem_util + mem_trend + mem_noise))
            
            temp_base = self.base_temp
            if is_work:
                if self.usage_mode == GPU_USAGE_MODE_OVERLOAD:
                    self.temps[i] = max(60, min(85, temp_base + (self.gpu_utils[i] - 70) * 0.2 + random.uniform(-2, 2)))
                elif self.usage_mode == GPU_USAGE_MODE_IDLE:
                    self.temps[i] = max(35, min(55, temp_base + (self.gpu_utils[i] - 20) * 0.2 + random.uniform(-2, 2)))
                else:
                    self.temps[i] = max(45, min(70, temp_base + (self.gpu_utils[i] - 45) * 0.2 + random.uniform(-2, 2)))
            else:
                self.temps[i] = max(30, min(50, temp_base * 0.7 + (self.gpu_utils[i] - 10) * 0.15 + random.uniform(-2, 2)))
            
            power_base = self.base_power / self.gpu_count
            if is_work:
                if self.usage_mode == GPU_USAGE_MODE_OVERLOAD:
                    self.powers[i] = max(100, min(self.gpu_model['tdp_watts'] * 0.95, 
                                                  power_base + (self.gpu_utils[i] - 70) * 1.5 + random.uniform(-10, 10)))
                elif self.usage_mode == GPU_USAGE_MODE_IDLE:
                    self.powers[i] = max(30, min(self.gpu_model['tdp_watts'] * 0.35, 
                                                 power_base + (self.gpu_utils[i] - 20) * 1.0 + random.uniform(-5, 5)))
                else:
                    self.powers[i] = max(50, min(self.gpu_model['tdp_watts'] * 0.7, 
                                                 power_base + (self.gpu_utils[i] - 45) * 1.5 + random.uniform(-10, 10)))
            else:
                self.powers[i] = max(20, min(self.gpu_model['tdp_watts'] * 0.3, 
                                             power_base * 0.3 + self.gpu_utils[i] * 0.5 + random.uniform(-5, 5)))
        
        if is_work:
            if self.usage_mode == GPU_USAGE_MODE_OVERLOAD:
                self.cpu_util = max(55, min(90, self.cpu_util + random.uniform(-2, 2)))
                self.mem_percent = max(55, min(85, self.mem_percent + random.uniform(-1, 1)))
            elif self.usage_mode == GPU_USAGE_MODE_IDLE:
                self.cpu_util = max(5, min(35, self.cpu_util + random.uniform(-2, 2)))
                self.mem_percent = max(15, min(45, self.mem_percent + random.uniform(-1, 1)))
            else:
                self.cpu_util = max(25, min(60, self.cpu_util + random.uniform(-2, 2)))
                self.mem_percent = max(35, min(65, self.mem_percent + random.uniform(-1, 1)))
        else:
            self.cpu_util = max(5, min(25, self.cpu_util * 0.8 + random.uniform(-2, 2)))
            self.mem_percent = max(15, min(40, self.mem_percent * 0.8 + random.uniform(-1, 1)))
        
        if is_work:
            if self.usage_mode == GPU_USAGE_MODE_OVERLOAD:
                self.cumulative_bytes_sent += random.randint(50000000, 200000000)
                self.cumulative_bytes_recv += random.randint(50000000, 200000000)
                self.cumulative_read_bytes += random.randint(5000000, 30000000)
                self.cumulative_write_bytes += random.randint(2000000, 15000000)
            elif self.usage_mode == GPU_USAGE_MODE_IDLE:
                self.cumulative_bytes_sent += random.randint(1000000, 20000000)
                self.cumulative_bytes_recv += random.randint(1000000, 20000000)
                self.cumulative_read_bytes += random.randint(100000, 2000000)
                self.cumulative_write_bytes += random.randint(50000, 1000000)
            else:
                self.cumulative_bytes_sent += random.randint(10000000, 100000000)
                self.cumulative_bytes_recv += random.randint(10000000, 100000000)
                self.cumulative_read_bytes += random.randint(1000000, 10000000)
                self.cumulative_write_bytes += random.randint(500000, 5000000)
        else:
            self.cumulative_bytes_sent += random.randint(100000, 5000000)
            self.cumulative_bytes_recv += random.randint(100000, 5000000)
            self.cumulative_read_bytes += random.randint(10000, 500000)
            self.cumulative_write_bytes += random.randint(5000, 200000)


def generate_monitoring_data_csv(devices, days=30, config=None):
    print(f"正在生成{days}天监测数据到CSV...")
    
    if config is None:
        config = get_default_config()
    
    end_time = datetime.now().replace(second=0, microsecond=0)
    start_time = end_time - timedelta(days=days)
    
    print(f"  时间范围: {start_time.strftime('%Y-%m-%d %H:%M:%S')} 至 {end_time.strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"  设备数量: {len(devices)}")
    
    device_states = {}
    always_high_load_ratio = config.get('always_high_load_ratio', 0.15)
    
    for d in devices:
        is_high_load = random.random() < always_high_load_ratio
        d['always_high_load'] = is_high_load
        device_states[d['id']] = DeviceState(d, d.get('online_time'), always_high_load=is_high_load)
    
    gpu_monitor_rows = []
    gpu_detail_rows = []
    cpu_monitor_rows = []
    memory_monitor_rows = []
    disk_monitor_rows = []
    network_monitor_rows = []
    
    gpu_monitor_id = 1
    gpu_detail_id = 1
    cpu_monitor_id = 1
    memory_monitor_id = 1
    disk_monitor_id = 1
    network_monitor_id = 1
    
    current_time = start_time
    total_minutes = int((end_time - start_time).total_seconds() / 60)
    processed_minutes = 0
    
    online_devices_cache = {}
    
    while current_time <= end_time:
        online_devices = []
        for device in devices:
            device_id = device['id']
            online_time = device.get('online_time', start_time)
            offline_time = device.get('offline_time')
            
            if current_time >= online_time and (offline_time is None or current_time < offline_time):
                online_devices.append(device)
        
        for device in online_devices:
            device_id = device['id']
            state = device_states[device_id]
            gpu_model = device['gpu_model']
            gpu_count = device.get('gpu_per_device', 8)
            
            state.update(1, current_time)
            
            msg_id = str(uuid.uuid4())
            
            avg_gpu_util = sum(state.gpu_utils) / gpu_count
            avg_temp = sum(state.temps) / gpu_count
            total_power = sum(state.powers)
            avg_mem_usage = sum(state.mem_utils) / gpu_count
            
            total_memory_mb = int(gpu_model['memory_gb'] * 1024 * gpu_count)
            used_memory_mb = int(total_memory_mb * avg_mem_usage / 100)
            
            gpu_monitor_rows.append({
                'id': gpu_monitor_id,
                'device_id': device_id,
                'msg_id': msg_id,
                'organization_id1': device['level1_id'],
                'organization_name1': device['level1_name'],
                'organization_id2': device['level2_id'],
                'organization_name2': device['level2_name'],
                'organization_id3': device['org_id'],
                'organization_name3': device['org_name'],
                'gpu_count': gpu_count,
                'total_memory_mb': total_memory_mb,
                'used_memory_mb': used_memory_mb,
                'free_memory_mb': total_memory_mb - used_memory_mb,
                'memory_usage_percent': round(avg_mem_usage, 2),
                'avg_gpu_utilization': round(avg_gpu_util, 2),
                'avg_memory_utilization': round(avg_mem_usage, 2),
                'max_gpu_utilization': int(max(state.gpu_utils)),
                'min_gpu_utilization': int(min(state.gpu_utils)),
                'avg_temperature': round(avg_temp, 2),
                'max_temperature': int(max(state.temps)),
                'total_power_draw': round(total_power, 2),
                'total_power_limit': round(gpu_model['tdp_watts'] * gpu_count, 2),
                'power_usage_percent': round(total_power / (gpu_model['tdp_watts'] * gpu_count) * 100, 2),
                'collection_timestamp': current_time.strftime('%Y-%m-%d %H:%M:%S')
            })
            
            for idx in range(gpu_count):
                total_mb = gpu_model['memory_gb'] * 1024
                used_mb = total_mb * state.mem_utils[idx] / 100
                
                gpu_detail_rows.append({
                    'id': gpu_detail_id,
                    'device_gpu_monitor_id': gpu_monitor_id,
                    'gpu_idx': idx,
                    'gpu_name': gpu_model['name'],
                    'total_mb': total_mb,
                    'used_mb': round(used_mb, 2),
                    'free_mb': round(total_mb - used_mb, 2),
                    'usage_percent': round(state.mem_utils[idx], 2),
                    'gpu_utilization_percent': round(state.gpu_utils[idx], 2),
                    'memory_utilization_percent': round(state.mem_utils[idx], 2),
                    'current_gpu_clock_mhz': random.randint(int(gpu_model['base_clock_mhz']), int(gpu_model['boost_clock_mhz'])),
                    'current_memory_clock_mhz': random.randint(500, 1500),
                    'temperature_celsius': round(state.temps[idx], 2),
                    'power_draw_watts': round(state.powers[idx], 2),
                    'power_limit_watts': gpu_model['tdp_watts'],
                    'power_usage_percent': round(state.powers[idx] / gpu_model['tdp_watts'] * 100, 2),
                    'collection_timestamp': current_time.strftime('%Y-%m-%d %H:%M:%S')
                })
                gpu_detail_id += 1
            
            gpu_monitor_id += 1
            
            cpu_time_total = (current_time - start_time).total_seconds()
            
            cpu_monitor_rows.append({
                'id': cpu_monitor_id,
                'device_id': device_id,
                'msg_id': msg_id,
                'organization_id1': device['level1_id'],
                'organization_name1': device['level1_name'],
                'organization_id2': device['level2_id'],
                'organization_name2': device['level2_name'],
                'organization_id3': device['org_id'],
                'organization_name3': device['org_name'],
                'physical_cores': device['cpu_cores'],
                'logical_cores': device['cpu_cores'] * 2,
                'cpu_percent': round(state.cpu_util, 2),
                'load_average_1min': round(state.cpu_util / 10 + random.uniform(-1, 1), 2),
                'load_average_5min': round(state.cpu_util / 8 + random.uniform(-2, 2), 2),
                'load_average_15min': round(state.cpu_util / 6 + random.uniform(-3, 3), 2),
                'idle_time': round(cpu_time_total * (100 - state.cpu_util) / 100, 2),
                'user_time': round(cpu_time_total * state.cpu_util / 100 * 0.7, 2),
                'system_time': round(cpu_time_total * state.cpu_util / 100 * 0.3, 2),
                'nice_time': round(random.uniform(0, 5), 2),
                'iowait_time': round(random.uniform(0, 10), 2),
                'irq_time': round(random.uniform(0, 1), 2),
                'softirq_time': round(random.uniform(0, 0.5), 2),
                'steal_time': round(random.uniform(0, 0.5), 2),
                'idle_percent': round(100 - state.cpu_util, 2),
                'user_percent': round(state.cpu_util * 0.7, 2),
                'system_percent': round(state.cpu_util * 0.3, 2),
                'nice_percent': round(random.uniform(0, 2), 2),
                'iowait_percent': round(random.uniform(0, 5), 2),
                'irq_percent': round(random.uniform(0, 0.5), 2),
                'softirq_percent': round(random.uniform(0, 0.3), 2),
                'steal_percent': round(random.uniform(0, 0.3), 2),
                'current_frequency': random.randint(2000, 4000),
                'min_frequency': random.randint(800, 1200),
                'max_frequency': random.randint(3000, 5000),
                'cumulative_ctx_switches': random.randint(1000000, 10000000),
                'cumulative_interrupts': random.randint(500000, 5000000),
                'cumulative_soft_interrupts': random.randint(100000, 1000000),
                'cumulative_syscalls': random.randint(50000, 500000),
                'ctx_switches_per_sec': round(random.uniform(1000, 5000), 2),
                'interrupts_per_sec': round(random.uniform(500, 2000), 2),
                'soft_interrupts_per_sec': round(random.uniform(100, 500), 2),
                'syscalls_per_sec': round(random.uniform(50, 200), 2),
                'collection_timestamp': current_time.strftime('%Y-%m-%d %H:%M:%S')
            })
            cpu_monitor_id += 1
            
            virtual_total = device['memory_size'] * 1024 * 1024 * 1024
            virtual_used = int(virtual_total * state.mem_percent / 100)
            swap_total = int(virtual_total * 0.5)
            swap_used = int(swap_total * random.uniform(0, 30) / 100)
            
            memory_monitor_rows.append({
                'id': memory_monitor_id,
                'device_id': device_id,
                'msg_id': msg_id,
                'organization_id1': device['level1_id'],
                'organization_name1': device['level1_name'],
                'organization_id2': device['level2_id'],
                'organization_name2': device['level2_name'],
                'organization_id3': device['org_id'],
                'organization_name3': device['org_name'],
                'virtual_total': virtual_total,
                'virtual_available': virtual_total - virtual_used,
                'virtual_used': virtual_used,
                'virtual_free': virtual_total - virtual_used,
                'virtual_percent': round(state.mem_percent, 2),
                'virtual_active': int(virtual_used * 0.6),
                'virtual_inactive': int(virtual_used * 0.4),
                'virtual_buffers': int(virtual_total * 0.05),
                'virtual_cached': int(virtual_total * 0.1),
                'virtual_shared': int(virtual_total * 0.02),
                'virtual_slab': int(virtual_total * 0.01),
                'swap_total': swap_total,
                'swap_used': swap_used,
                'swap_free': swap_total - swap_used,
                'swap_percent': round(swap_used / swap_total * 100, 2) if swap_total > 0 else 0,
                'swap_sin': random.randint(0, 1000000000),
                'swap_sout': random.randint(0, 500000000),
                'collection_timestamp': current_time.strftime('%Y-%m-%d %H:%M:%S')
            })
            memory_monitor_id += 1
            
            total_space = device['disk_size'] * 1024 * 1024 * 1024
            usage_percent = random.uniform(30, 80)
            used_space = int(total_space * usage_percent / 100)
            
            disk_monitor_rows.append({
                'id': disk_monitor_id,
                'device_id': device_id,
                'msg_id': msg_id,
                'organization_id1': device['level1_id'],
                'organization_name1': device['level1_name'],
                'organization_id2': device['level2_id'],
                'organization_name2': device['level2_name'],
                'organization_id3': device['org_id'],
                'organization_name3': device['org_name'],
                'total_space': total_space,
                'used_space': used_space,
                'free_space': total_space - used_space,
                'usage_percent': round(usage_percent, 2),
                'cumulative_read_count': random.randint(1000000, 100000000),
                'cumulative_write_count': random.randint(500000, 50000000),
                'cumulative_read_bytes': state.cumulative_read_bytes,
                'cumulative_write_bytes': state.cumulative_write_bytes,
                'cumulative_read_time': random.randint(10000000, 100000000),
                'cumulative_write_time': random.randint(50000000, 500000000),
                'cumulative_busy_time': random.randint(10000000, 100000000),
                'read_iops': round(random.uniform(100, 500), 2),
                'write_iops': round(random.uniform(50, 300), 2),
                'read_bytes_per_sec': random.randint(100000000, 1000000000),
                'write_bytes_per_sec': random.randint(50000000, 500000000),
                'read_speed_mbps': round(random.uniform(100, 500), 2),
                'write_speed_mbps': round(random.uniform(50, 300), 2),
                'collection_timestamp': current_time.strftime('%Y-%m-%d %H:%M:%S')
            })
            disk_monitor_id += 1
            
            bytes_sent_per_sec = random.randint(10000000, 99999999)
            bytes_recv_per_sec = random.randint(10000000, 99999999)
            
            network_monitor_rows.append({
                'id': network_monitor_id,
                'device_id': device_id,
                'msg_id': msg_id,
                'organization_id1': device['level1_id'],
                'organization_name1': device['level1_name'],
                'organization_id2': device['level2_id'],
                'organization_name2': device['level2_name'],
                'organization_id3': device['org_id'],
                'organization_name3': device['org_name'],
                'cumulative_bytes_sent': state.cumulative_bytes_sent,
                'cumulative_bytes_recv': state.cumulative_bytes_recv,
                'cumulative_packets_sent': random.randint(100000000, 2000000000),
                'cumulative_packets_recv': random.randint(100000000, 2000000000),
                'cumulative_errin': random.randint(0, 1000),
                'cumulative_errout': random.randint(0, 1000),
                'cumulative_dropin': random.randint(0, 100),
                'cumulative_dropout': random.randint(0, 100),
                'bytes_recv_per_sec': bytes_recv_per_sec,
                'bytes_sent_per_sec': bytes_sent_per_sec,
                'packets_recv_per_sec': round(random.uniform(1000, 50000), 2),
                'packets_sent_per_sec': round(random.uniform(1000, 50000), 2),
                'errin_per_sec': round(random.uniform(0, 10), 2),
                'errout_per_sec': round(random.uniform(0, 10), 2),
                'dropin_per_sec': round(random.uniform(0, 5), 2),
                'dropout_per_sec': round(random.uniform(0, 5), 2),
                'download_speed_mbps': round(bytes_recv_per_sec * 8 / 1000000, 2),
                'upload_speed_mbps': round(bytes_sent_per_sec * 8 / 1000000, 2),
                'download_speed_kbps': round(bytes_recv_per_sec * 8 / 1000, 2),
                'upload_speed_kbps': round(bytes_sent_per_sec * 8 / 1000, 2),
                'collection_timestamp': current_time.strftime('%Y-%m-%d %H:%M:%S')
            })
            network_monitor_id += 1
        
        current_time += timedelta(minutes=1)
        processed_minutes += 1
        if processed_minutes % 500 == 0:
            print(f"  已处理 {processed_minutes}/{total_minutes} 分钟的数据...")
    
    def write_csv(filename, rows, fieldnames):
        csv_path = os.path.join(DATA_DIR, filename)
        with open(csv_path, 'w', newline='', encoding='utf-8') as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(rows)
        print(f"  - 已生成 {len(rows)} 条数据到 {csv_path}")
    
    write_csv('device_gpu_monitor.csv', gpu_monitor_rows, 
              ['id', 'device_id', 'msg_id', 'organization_id1', 'organization_name1', 'organization_id2', 'organization_name2', 'organization_id3', 'organization_name3', 'gpu_count', 'total_memory_mb', 'used_memory_mb', 'free_memory_mb', 'memory_usage_percent', 'avg_gpu_utilization', 'avg_memory_utilization', 'max_gpu_utilization', 'min_gpu_utilization', 'avg_temperature', 'max_temperature', 'total_power_draw', 'total_power_limit', 'power_usage_percent', 'collection_timestamp'])
    
    write_csv('device_gpu_monitor_detail.csv', gpu_detail_rows,
              ['id', 'device_gpu_monitor_id', 'gpu_idx', 'gpu_name', 'total_mb', 'used_mb', 'free_mb', 'usage_percent', 'gpu_utilization_percent', 'memory_utilization_percent', 'current_gpu_clock_mhz', 'current_memory_clock_mhz', 'temperature_celsius', 'power_draw_watts', 'power_limit_watts', 'power_usage_percent', 'collection_timestamp'])
    
    write_csv('device_cpu_monitor.csv', cpu_monitor_rows,
              ['id', 'device_id', 'msg_id', 'organization_id1', 'organization_name1', 'organization_id2', 'organization_name2', 'organization_id3', 'organization_name3', 'physical_cores', 'logical_cores', 'cpu_percent', 'load_average_1min', 'load_average_5min', 'load_average_15min', 'idle_time', 'user_time', 'system_time', 'nice_time', 'iowait_time', 'irq_time', 'softirq_time', 'steal_time', 'idle_percent', 'user_percent', 'system_percent', 'nice_percent', 'iowait_percent', 'irq_percent', 'softirq_percent', 'steal_percent', 'current_frequency', 'min_frequency', 'max_frequency', 'cumulative_ctx_switches', 'cumulative_interrupts', 'cumulative_soft_interrupts', 'cumulative_syscalls', 'ctx_switches_per_sec', 'interrupts_per_sec', 'soft_interrupts_per_sec', 'syscalls_per_sec', 'collection_timestamp'])
    
    write_csv('device_memory_monitor.csv', memory_monitor_rows,
              ['id', 'device_id', 'msg_id', 'organization_id1', 'organization_name1', 'organization_id2', 'organization_name2', 'organization_id3', 'organization_name3', 'virtual_total', 'virtual_available', 'virtual_used', 'virtual_free', 'virtual_percent', 'virtual_active', 'virtual_inactive', 'virtual_buffers', 'virtual_cached', 'virtual_shared', 'virtual_slab', 'swap_total', 'swap_used', 'swap_free', 'swap_percent', 'swap_sin', 'swap_sout', 'collection_timestamp'])
    
    write_csv('device_disk_monitor.csv', disk_monitor_rows,
              ['id', 'device_id', 'msg_id', 'organization_id1', 'organization_name1', 'organization_id2', 'organization_name2', 'organization_id3', 'organization_name3', 'total_space', 'used_space', 'free_space', 'usage_percent', 'cumulative_read_count', 'cumulative_write_count', 'cumulative_read_bytes', 'cumulative_write_bytes', 'cumulative_read_time', 'cumulative_write_time', 'cumulative_busy_time', 'read_iops', 'write_iops', 'read_bytes_per_sec', 'write_bytes_per_sec', 'read_speed_mbps', 'write_speed_mbps', 'collection_timestamp'])
    
    write_csv('device_network_monitor.csv', network_monitor_rows,
              ['id', 'device_id', 'msg_id', 'organization_id1', 'organization_name1', 'organization_id2', 'organization_name2', 'organization_id3', 'organization_name3', 'cumulative_bytes_sent', 'cumulative_bytes_recv', 'cumulative_packets_sent', 'cumulative_packets_recv', 'cumulative_errin', 'cumulative_errout', 'cumulative_dropin', 'cumulative_dropout', 'bytes_recv_per_sec', 'bytes_sent_per_sec', 'packets_recv_per_sec', 'packets_sent_per_sec', 'errin_per_sec', 'errout_per_sec', 'dropin_per_sec', 'dropout_per_sec', 'download_speed_mbps', 'upload_speed_mbps', 'download_speed_kbps', 'upload_speed_kbps', 'collection_timestamp'])
    
    print(f"\n监测数据生成完成!")
    print(f"  - GPU监控汇总数据: {len(gpu_monitor_rows)} 条")
    print(f"  - GPU监控明细数据: {len(gpu_detail_rows)} 条")
    print(f"  - CPU监控数据: {len(cpu_monitor_rows)} 条")
    print(f"  - 内存监控数据: {len(memory_monitor_rows)} 条")
    print(f"  - 磁盘监控数据: {len(disk_monitor_rows)} 条")
    print(f"  - 网络监控数据: {len(network_monitor_rows)} 条")


def load_csv_to_table(conn, table_name, csv_filename, columns):
    csv_path = os.path.join(DATA_DIR, csv_filename)
    if not os.path.exists(csv_path):
        print(f"  - 跳过 {table_name}: CSV文件不存在")
        return 0
    
    cursor = conn.cursor()
    
    try:
        with open(csv_path, 'r', encoding='utf-8') as f:
            next(f)
            cursor.copy_expert(
                f"COPY {table_name} ({', '.join(columns)}) FROM STDIN WITH (FORMAT CSV, NULL '', ENCODING 'UTF8')",
                f
            )
        
        count = cursor.rowcount
        conn.commit()
        print(f"  - 已加载 {count} 条数据到 {table_name}")
        return count
    except Exception as e:
        conn.rollback()
        print(f"  - 加载 {table_name} 失败: {e}")
        return 0
    finally:
        cursor.close()


def disable_indexes(conn):
    print("正在禁用索引...")
    cursor = conn.cursor()
    
    indexes = [
        ('device_gpu_monitor', 'device_gpu_monitor_idx_device_timestamp'),
        ('device_gpu_monitor', 'device_gpu_monitor__idx_msg_id'),
        ('device_gpu_monitor', 'idx_gpu_collection'),
        ('device_gpu_monitor', 'idx_gpu_device'),
        ('device_gpu_monitor_detail', 'device_gpu_monitor_detail_idx_collection_timestamp'),
        ('device_gpu_monitor_detail', 'device_gpu_monitor_detail_idx_gpu_idx'),
        ('device_gpu_monitor_detail', 'device_gpu_monitor_detail_idx_summary_gpu'),
        ('device_gpu_monitor_detail', 'device_gpu_monitor_detail_idx_summary_id'),
        ('device_gpu_monitor_detail', 'idx_gpu_detail_collection'),
        ('device_gpu_monitor_detail', 'idx_gpu_detail_monitor'),
        ('device_gpu_monitor_detail', 'idx_gpu_detail_monitor_collection'),
        ('device_cpu_monitor', 'device_cpu_monitor_idx_device_timestamp'),
        ('device_cpu_monitor', 'device_idx_msg_id'),
        ('device_cpu_monitor', 'idx_cpu_collection'),
        ('device_cpu_monitor', 'idx_cpu_device'),
        ('device_cpu_monitor', 'idx_cpu_device_collection'),
        ('device_memory_monitor', 'device_memory_monitor_idx_device_timestamp'),
        ('device_memory_monitor', 'device_memory_monitor_idx_msg_id'),
        ('device_memory_monitor', 'idx_memory_collection'),
        ('device_memory_monitor', 'idx_memory_device'),
        ('device_memory_monitor', 'idx_memory_device_collection'),
        ('device_disk_monitor', 'device_desk_monitor_idx_msg_id'),
        ('device_disk_monitor', 'idx_disk_collection'),
        ('device_disk_monitor', 'idx_disk_device'),
        ('device_disk_monitor', 'idx_disk_device_collection'),
        ('device_network_monitor', 'device_network_monitor_idx_msg_id'),
        ('device_network_monitor', 'idx_network_collection'),
        ('device_network_monitor', 'idx_network_device'),
        ('device_network_monitor', 'idx_network_device_collection'),
    ]
    
    disabled_count = 0
    for table, index in indexes:
        try:
            cursor.execute(f"DROP INDEX IF EXISTS {index}")
            disabled_count += 1
        except Exception as e:
            pass
    
    conn.commit()
    cursor.close()
    print(f"  已禁用 {disabled_count} 个索引\n")


def recreate_indexes(conn):
    print("正在重建索引...")
    cursor = conn.cursor()
    
    indexes_sql = [
        "CREATE INDEX IF NOT EXISTS device_gpu_monitor_idx_device_timestamp ON device_gpu_monitor (device_id, collection_timestamp)",
        "CREATE INDEX IF NOT EXISTS device_gpu_monitor__idx_msg_id ON device_gpu_monitor (msg_id)",
        "CREATE INDEX IF NOT EXISTS idx_gpu_collection ON device_gpu_monitor (collection_timestamp)",
        "CREATE INDEX IF NOT EXISTS idx_gpu_device ON device_gpu_monitor (device_id)",
        "CREATE INDEX IF NOT EXISTS device_gpu_monitor_detail_idx_collection_timestamp ON device_gpu_monitor_detail (collection_timestamp)",
        "CREATE INDEX IF NOT EXISTS device_gpu_monitor_detail_idx_gpu_idx ON device_gpu_monitor_detail (gpu_idx)",
        "CREATE INDEX IF NOT EXISTS device_gpu_monitor_detail_idx_summary_gpu ON device_gpu_monitor_detail (device_gpu_monitor_id, gpu_idx)",
        "CREATE INDEX IF NOT EXISTS device_gpu_monitor_detail_idx_summary_id ON device_gpu_monitor_detail (device_gpu_monitor_id)",
        "CREATE INDEX IF NOT EXISTS idx_gpu_detail_collection ON device_gpu_monitor_detail (collection_timestamp)",
        "CREATE INDEX IF NOT EXISTS idx_gpu_detail_monitor ON device_gpu_monitor_detail (device_gpu_monitor_id)",
        "CREATE INDEX IF NOT EXISTS idx_gpu_detail_monitor_collection ON device_gpu_monitor_detail (device_gpu_monitor_id, collection_timestamp DESC)",
        "CREATE INDEX IF NOT EXISTS device_cpu_monitor_idx_device_timestamp ON device_cpu_monitor (device_id, collection_timestamp)",
        "CREATE INDEX IF NOT EXISTS device_idx_msg_id ON device_cpu_monitor (msg_id)",
        "CREATE INDEX IF NOT EXISTS idx_cpu_collection ON device_cpu_monitor (collection_timestamp)",
        "CREATE INDEX IF NOT EXISTS idx_cpu_device ON device_cpu_monitor (device_id)",
        "CREATE INDEX IF NOT EXISTS idx_cpu_device_collection ON device_cpu_monitor (device_id, collection_timestamp DESC)",
        "CREATE INDEX IF NOT EXISTS device_memory_monitor_idx_device_timestamp ON device_memory_monitor (device_id, collection_timestamp)",
        "CREATE INDEX IF NOT EXISTS device_memory_monitor_idx_msg_id ON device_memory_monitor (msg_id)",
        "CREATE INDEX IF NOT EXISTS idx_memory_collection ON device_memory_monitor (collection_timestamp)",
        "CREATE INDEX IF NOT EXISTS idx_memory_device ON device_memory_monitor (device_id)",
        "CREATE INDEX IF NOT EXISTS idx_memory_device_collection ON device_memory_monitor (device_id, collection_timestamp DESC)",
        "CREATE INDEX IF NOT EXISTS device_desk_monitor_idx_msg_id ON device_disk_monitor (msg_id)",
        "CREATE INDEX IF NOT EXISTS idx_disk_collection ON device_disk_monitor (collection_timestamp)",
        "CREATE INDEX IF NOT EXISTS idx_disk_device ON device_disk_monitor (device_id)",
        "CREATE INDEX IF NOT EXISTS idx_disk_device_collection ON device_disk_monitor (device_id, collection_timestamp DESC)",
        "CREATE INDEX IF NOT EXISTS device_network_monitor_idx_msg_id ON device_network_monitor (msg_id)",
        "CREATE INDEX IF NOT EXISTS idx_network_collection ON device_network_monitor (collection_timestamp)",
        "CREATE INDEX IF NOT EXISTS idx_network_device ON device_network_monitor (device_id)",
        "CREATE INDEX IF NOT EXISTS idx_network_device_collection ON device_network_monitor (device_id, collection_timestamp DESC)",
    ]
    
    for sql in indexes_sql:
        try:
            cursor.execute(sql)
        except Exception as e:
            print(f"  警告: {e}")
    
    conn.commit()
    cursor.close()
    print(f"  已重建 {len(indexes_sql)} 个索引\n")


def load_all_data_to_db(conn):
    print("正在批量加载数据到数据库...\n")
    
    load_csv_to_table(conn, 'network', 'network.csv',
                      ['id', 'code', 'parent_code', 'name', 'create_time', 'update_time', 'create_by', 'update_by', 'deleted'])
    
    load_csv_to_table(conn, 'organization', 'organization.csv',
                      ['id', 'parent_id', 'name', 'code', 'type', 'sort', 'leader', 'phone', 'email', 'address', 'status', 'remark', 'province', 'province_code'])
    
    load_csv_to_table(conn, 'device', 'device.csv',
                      ['id', 'name', 'code', 'organization_id', 'organization_code', 'cpu_cores', 'memory_size', 'disk_size', 'gpu_count', 'gpu_model', 'total_memory', 'operating_system', 'purpose', 'net_module_code', 'net_module_name', 'detail_info', 'online_status'])
    
    load_csv_to_table(conn, 'gpu_card_info', 'gpu_card_info.csv',
                      ['id', 'gpu_index', 'gpu_name', 'card_type', 'cuda_cores', 'base_clock_mhz', 'boost_clock_mhz', 'memory_total_mb', 'memory_total_gb', 'pcie_gen', 'pcie_width', 'tflops_fp32', 'tflops_fp16', 'tflops_fp64', 'tflops_int8', 'tdp_watts', 'max_power_watts', 'memory_type', 'memory_bus_width', 'memory_bandwidth_gbps', 'architecture', 'compute_capability', 'status'])
    
    load_csv_to_table(conn, 'device_gpu_monitor', 'device_gpu_monitor.csv',
                      ['id', 'device_id', 'msg_id', 'organization_id1', 'organization_name1', 'organization_id2', 'organization_name2', 'organization_id3', 'organization_name3', 'gpu_count', 'total_memory_mb', 'used_memory_mb', 'free_memory_mb', 'memory_usage_percent', 'avg_gpu_utilization', 'avg_memory_utilization', 'max_gpu_utilization', 'min_gpu_utilization', 'avg_temperature', 'max_temperature', 'total_power_draw', 'total_power_limit', 'power_usage_percent', 'collection_timestamp'])
    
    load_csv_to_table(conn, 'device_gpu_monitor_detail', 'device_gpu_monitor_detail.csv',
                      ['id', 'device_gpu_monitor_id', 'gpu_idx', 'gpu_name', 'total_mb', 'used_mb', 'free_mb', 'usage_percent', 'gpu_utilization_percent', 'memory_utilization_percent', 'current_gpu_clock_mhz', 'current_memory_clock_mhz', 'temperature_celsius', 'power_draw_watts', 'power_limit_watts', 'power_usage_percent', 'collection_timestamp'])
    
    load_csv_to_table(conn, 'device_cpu_monitor', 'device_cpu_monitor.csv',
                      ['id', 'device_id', 'msg_id', 'organization_id1', 'organization_name1', 'organization_id2', 'organization_name2', 'organization_id3', 'organization_name3', 'physical_cores', 'logical_cores', 'cpu_percent', 'load_average_1min', 'load_average_5min', 'load_average_15min', 'idle_time', 'user_time', 'system_time', 'nice_time', 'iowait_time', 'irq_time', 'softirq_time', 'steal_time', 'idle_percent', 'user_percent', 'system_percent', 'nice_percent', 'iowait_percent', 'irq_percent', 'softirq_percent', 'steal_percent', 'current_frequency', 'min_frequency', 'max_frequency', 'cumulative_ctx_switches', 'cumulative_interrupts', 'cumulative_soft_interrupts', 'cumulative_syscalls', 'ctx_switches_per_sec', 'interrupts_per_sec', 'soft_interrupts_per_sec', 'syscalls_per_sec', 'collection_timestamp'])
    
    load_csv_to_table(conn, 'device_memory_monitor', 'device_memory_monitor.csv',
                      ['id', 'device_id', 'msg_id', 'organization_id1', 'organization_name1', 'organization_id2', 'organization_name2', 'organization_id3', 'organization_name3', 'virtual_total', 'virtual_available', 'virtual_used', 'virtual_free', 'virtual_percent', 'virtual_active', 'virtual_inactive', 'virtual_buffers', 'virtual_cached', 'virtual_shared', 'virtual_slab', 'swap_total', 'swap_used', 'swap_free', 'swap_percent', 'swap_sin', 'swap_sout', 'collection_timestamp'])
    
    load_csv_to_table(conn, 'device_disk_monitor', 'device_disk_monitor.csv',
                      ['id', 'device_id', 'msg_id', 'organization_id1', 'organization_name1', 'organization_id2', 'organization_name2', 'organization_id3', 'organization_name3', 'total_space', 'used_space', 'free_space', 'usage_percent', 'cumulative_read_count', 'cumulative_write_count', 'cumulative_read_bytes', 'cumulative_write_bytes', 'cumulative_read_time', 'cumulative_write_time', 'cumulative_busy_time', 'read_iops', 'write_iops', 'read_bytes_per_sec', 'write_bytes_per_sec', 'read_speed_mbps', 'write_speed_mbps', 'collection_timestamp'])
    
    load_csv_to_table(conn, 'device_network_monitor', 'device_network_monitor.csv',
                      ['id', 'device_id', 'msg_id', 'organization_id1', 'organization_name1', 'organization_id2', 'organization_name2', 'organization_id3', 'organization_name3', 'cumulative_bytes_sent', 'cumulative_bytes_recv', 'cumulative_packets_sent', 'cumulative_packets_recv', 'cumulative_errin', 'cumulative_errout', 'cumulative_dropin', 'cumulative_dropout', 'bytes_recv_per_sec', 'bytes_sent_per_sec', 'packets_recv_per_sec', 'packets_sent_per_sec', 'errin_per_sec', 'errout_per_sec', 'dropin_per_sec', 'dropout_per_sec', 'download_speed_mbps', 'upload_speed_mbps', 'download_speed_kbps', 'upload_speed_kbps', 'collection_timestamp'])


def verify_data(conn):
    print("正在验证数据完整性...")
    cursor = conn.cursor()
    
    tables_to_check = [
        ('network', '业务网络'),
        ('organization', '单位'),
        ('device', '服务器'),
        ('gpu_card_info', 'GPU卡'),
        ('device_gpu_monitor', 'GPU监控汇总'),
        ('device_gpu_monitor_detail', 'GPU监控明细'),
        ('device_cpu_monitor', 'CPU监控'),
        ('device_memory_monitor', '内存监控'),
        ('device_disk_monitor', '磁盘监控'),
        ('device_network_monitor', '网络监控'),
    ]
    
    print("\n数据统计:")
    print("-" * 50)
    
    for table, desc in tables_to_check:
        cursor.execute(f"SELECT COUNT(*) FROM {table}")
        count = cursor.fetchone()[0]
        print(f"  {desc} ({table}): {count} 条记录")
    
    print("\n组织层级验证:")
    print("-" * 50)
    
    cursor.execute("SELECT COUNT(*) FROM organization WHERE type = 1")
    print(f"  一级组织(全国): {cursor.fetchone()[0]} 个")
    
    cursor.execute("SELECT COUNT(*) FROM organization WHERE type = 2 AND remark LIKE '%地方厅局分类%'")
    print(f"  二级组织-地方厅局分类: {cursor.fetchone()[0]} 个")
    
    cursor.execute("SELECT COUNT(*) FROM organization WHERE type = 2 AND remark LIKE '%部机关分类%'")
    print(f"  二级组织-部机关分类: {cursor.fetchone()[0]} 个")
    
    cursor.execute("SELECT COUNT(*) FROM organization WHERE type = 3 AND remark LIKE '%地方厅局%'")
    print(f"  三级组织-地方厅局: {cursor.fetchone()[0]} 个")
    
    cursor.execute("SELECT COUNT(*) FROM organization WHERE type = 3 AND remark LIKE '%部机关局%'")
    print(f"  三级组织-部机关局: {cursor.fetchone()[0]} 个")
    
    print("\n业务网络验证:")
    print("-" * 50)
    
    cursor.execute("SELECT COUNT(*) FROM network")
    print(f"  业务网络总数: {cursor.fetchone()[0]} 个")
    
    print("\n设备网络关联验证:")
    print("-" * 50)
    
    cursor.execute("""
        SELECT n.name as network_name, COUNT(d.id) as device_count
        FROM network n
        LEFT JOIN device d ON n.code = d.net_module_code
        GROUP BY n.id, n.name
        ORDER BY device_count DESC
        LIMIT 10
    """)
    
    for row in cursor.fetchall():
        print(f"  {row[0]}: {row[1]} 台服务器")
    
    print("\nmsg_id关联验证:")
    print("-" * 50)
    
    cursor.execute("""
        SELECT COUNT(DISTINCT g.msg_id) as gpu_msg_count,
               COUNT(DISTINCT c.msg_id) as cpu_msg_count,
               COUNT(DISTINCT m.msg_id) as mem_msg_count
        FROM device_gpu_monitor g
        JOIN device_cpu_monitor c ON g.device_id = c.device_id AND g.collection_timestamp = c.collection_timestamp
        JOIN device_memory_monitor m ON g.device_id = m.device_id AND g.collection_timestamp = m.collection_timestamp
        LIMIT 1
    """)
    
    row = cursor.fetchone()
    print(f"  GPU监控msg_id数: {row[0]}")
    print(f"  CPU监控msg_id数: {row[1]}")
    print(f"  内存监控msg_id数: {row[2]}")
    
    cursor.close()
    print("\n数据验证完成!\n")


def main():
    parser = argparse.ArgumentParser(description='智能算力监测平台 - 数据生成脚本 (优化版)')
    parser.add_argument('-g', '--generate', action='store_true', help='仅生成CSV数据文件')
    parser.add_argument('-l', '--load', action='store_true', help='仅加载现有CSV数据到数据库')
    parser.add_argument('--init', action='store_true', help='初始化数据库（执行SQL文件）')
    parser.add_argument('--skip-clear', action='store_true', help='跳过清空现有数据（与--init或--load配合使用）')
    parser.add_argument('--days', type=int, default=None, help='生成数据的天数')
    parser.add_argument('--sql-file', type=str, default='computing-power.sql', help='SQL文件路径（默认: computing-power.sql）')
    parser.add_argument('--non-interactive', action='store_true', help='非交互模式，使用默认参数')
    
    args = parser.parse_args()
    
    print("=" * 60)
    print("智能算力监测平台 - 数据生成脚本 (优化版)")
    print("=" * 60)
    print()
    
    try:
        ensure_data_dir()
        
        config = None
        if not args.non_interactive and not args.init and not args.load:
            config = get_user_config()
        else:
            config = get_default_config()
            if args.days:
                config['days'] = args.days
        
        if args.init:
            print("模式: 初始化数据库")
            print("-" * 40)
            conn = get_connection()
            print("数据库连接成功!\n")
            
            sql_file = args.sql_file
            if not os.path.isabs(sql_file):
                sql_file = os.path.join(os.path.dirname(__file__), sql_file)
            
            success = execute_sql_file(conn, sql_file, clear_data=not args.skip_clear)
            conn.close()
            
            if success:
                print("\n数据库初始化完成!")
            else:
                print("\n数据库初始化失败!")
                exit(1)
        
        elif args.generate:
            print("模式: 仅生成CSV数据")
            print("-" * 40)
            network_list = generate_network_csv()
            org_hierarchy = generate_organizations_csv(config)
            devices = generate_devices_csv(org_hierarchy, network_list, config)
            generate_gpu_cards_csv(devices)
            generate_monitoring_data_csv(devices, config['days'], config)
            print("\nCSV数据生成完成!")
            print(f"文件保存在: {os.path.abspath(DATA_DIR)}")
            
        elif args.load:
            print("模式: 仅加载CSV数据")
            print("-" * 40)
            conn = get_connection()
            print("数据库连接成功!\n")
            
            clear_all_data(conn, skip_clear=args.skip_clear)
            disable_indexes(conn)
            load_all_data_to_db(conn)
            recreate_indexes(conn)
            verify_data(conn)
            conn.close()
            print("\n数据加载完成!")
            
        else:
            print("模式: 完整流程（生成+加载）")
            print("-" * 40)
            
            print("\n阶段1: 生成数据到CSV文件")
            print("-" * 40)
            network_list = generate_network_csv()
            org_hierarchy = generate_organizations_csv(config)
            devices = generate_devices_csv(org_hierarchy, network_list, config)
            generate_gpu_cards_csv(devices)
            generate_monitoring_data_csv(devices, config['days'], config)
            
            print("\n阶段2: 加载数据到数据库")
            print("-" * 40)
            conn = get_connection()
            print("数据库连接成功!\n")
            
            clear_all_data(conn, skip_clear=args.skip_clear)
            disable_indexes(conn)
            load_all_data_to_db(conn)
            recreate_indexes(conn)
            verify_data(conn)
            conn.close()
        
        print("=" * 60)
        print("数据生成任务完成!")
        print(f"CSV文件保存在: {os.path.abspath(DATA_DIR)}")
        print("=" * 60)
        
    except Exception as e:
        print(f"错误: {e}")
        import traceback
        traceback.print_exc()
        exit(1)


if __name__ == '__main__':
    main()
