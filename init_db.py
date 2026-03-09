#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
智能算力监测平台 - 数据库初始化脚本
功能：
1. 执行 computing-power.sql 创建表结构
2. 检查数据库是否已有数据
3. 如果有数据，询问用户是否清空重建
"""

import os
import sys
import re
import psycopg2
from psycopg2 import sql
from db_config import DB_CONFIG, get_database_config

SQL_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'computing-power.sql')

TABLES_TO_CHECK = [
    'collect_info',
    'collect_task',
    'collect_task_detail',
    'daily_device_summary',
    'daily_gpu_usage_summary',
    'device',
    'device_bak',
    'device_cpu_monitor',
    'device_cpu_monitor_backup',
    'device_disk_monitor',
    'device_disk_monitor_backup',
    'device_gpu_monitor',
    'device_gpu_monitor_backup',
    'device_gpu_monitor_detail',
    'device_gpu_monitor_detail_backup',
    'device_memory_monitor',
    'device_memory_monitor_backup',
    'device_network_monitor',
    'device_network_monitor_backup',
    'dic_info',
    'gpu_card_info',
    'network',
    'org_gpu_usage_summary',
    'organization',
    'schedule_job',
    'schedule_job_log',
    'statistics_data',
    'sys_menu',
    'sys_operation_log',
    'sys_role',
    'sys_role_menu',
    'sys_user',
    'sys_user_role',
]


def get_connection():
    """获取数据库连接"""
    config = get_database_config()
    return psycopg2.connect(
        host=config['host'],
        port=config['port'],
        database=config['database'],
        user=config['user'],
        password=config['password']
    )


def check_tables_exist(conn):
    """检查表是否存在"""
    cursor = conn.cursor()
    existing_tables = []
    
    conn.rollback()
    
    for table in TABLES_TO_CHECK:
        try:
            cursor.execute("SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = %s)", [table])
            result = cursor.fetchone()[0]
            if result:
                existing_tables.append(table)
        except Exception:
            conn.rollback()
    
    conn.commit()
    cursor.close()
    return existing_tables


def check_tables_have_data(conn, tables):
    """检查表是否有数据"""
    cursor = conn.cursor()
    tables_with_data = []
    total_records = 0
    
    for table in tables:
        try:
            cursor.execute(sql.SQL("SELECT COUNT(*) FROM {}").format(sql.Identifier(table)))
            count = cursor.fetchone()[0]
            if count > 0:
                tables_with_data.append((table, count))
                total_records += count
        except Exception as e:
            print(f"  检查表 {table} 时出错: {e}")
    
    cursor.close()
    return tables_with_data, total_records


def drop_all_tables(conn):
    """删除所有表"""
    cursor = conn.cursor()
    
    print("\n正在删除现有表...")
    
    for table in TABLES_TO_CHECK:
        try:
            cursor.execute(sql.SQL("DROP TABLE IF EXISTS {} CASCADE").format(sql.Identifier(table)))
            print(f"  - 已删除表: {table}")
        except Exception as e:
            print(f"  - 删除表 {table} 时出错: {e}")
    
    conn.commit()
    cursor.close()
    print("表删除完成!\n")


def preprocess_sql_content(sql_content):
    """预处理SQL内容，移除OpenGauss特定语法"""
    sql_content = re.sub(
        r'\)\s*WITH\s*\(\s*orientation=row,\s*compression=no\s*\);',
        ');',
        sql_content,
        flags=re.IGNORECASE | re.DOTALL
    )
    sql_content = sql_content.replace('WITH (orientation=row, compression=no);', ';')
    sql_content = sql_content.replace(' TABLESPACE pg_default', '')
    sql_content = re.sub(r' LOCAL\([^)]+\)', '', sql_content)
    sql_content = sql_content.replace('pg_systimestamp()', 'CURRENT_TIMESTAMP')
    
    sql_content = re.sub(
        r'(code varchar\(50\) NOT NULL) -- 设备编码,--主板序列号',
        r'\1, -- 设备编码,--主板序列号',
        sql_content
    )
    
    return sql_content


def split_sql_statements(sql_content):
    """将SQL内容分割成独立的语句"""
    statements = []
    current_statement = []
    in_comment = False
    
    lines = sql_content.split('\n')
    
    for line in lines:
        stripped = line.strip()
        
        if stripped.startswith('--'):
            continue
        
        if '/*' in stripped:
            in_comment = True
        if '*/' in stripped:
            in_comment = False
            continue
        if in_comment:
            continue
        
        current_statement.append(line)
        
        if stripped.endswith(';'):
            stmt = '\n'.join(current_statement)
            stmt = stmt.strip()
            if stmt and stmt != ';':
                first_non_comment = False
                for sline in stmt.split('\n'):
                    sl = sline.strip()
                    if sl and not sl.startswith('--'):
                        first_non_comment = True
                        break
                if first_non_comment:
                    statements.append(stmt)
            current_statement = []
    
    if current_statement:
        stmt = '\n'.join(current_statement).strip()
        if stmt and stmt != ';':
            first_non_comment = False
            for sline in stmt.split('\n'):
                sl = sline.strip()
                if sl and not sl.startswith('--'):
                    first_non_comment = True
                    break
            if first_non_comment:
                statements.append(stmt)
    
    return statements


def execute_sql_file(conn, sql_file_path):
    """执行SQL文件创建表结构"""
    print(f"正在执行SQL文件: {sql_file_path}")
    
    if not os.path.exists(sql_file_path):
        print(f"错误: SQL文件不存在: {sql_file_path}")
        return False
    
    cursor = conn.cursor()
    
    try:
        with open(sql_file_path, 'r', encoding='utf-8') as f:
            sql_content = f.read()
        
        sql_content = preprocess_sql_content(sql_content)
        statements = split_sql_statements(sql_content)
        
        print(f"正在创建表结构... (共 {len(statements)} 条SQL语句)")
        
        if len(statements) > 0:
            print(f"  第一条语句预览: {statements[0][:100]}...")
        
        success_count = 0
        error_count = 0
        
        for i, stmt in enumerate(statements, 1):
            if not stmt or stmt.strip() == '':
                continue
            
            stmt_upper = stmt.upper().strip()
            if stmt_upper.startswith('CREATE TABLE'):
                match = re.search(r'CREATE TABLE\s+(\w+)', stmt, re.IGNORECASE)
                if match:
                    table_name = match.group(1)
                    print(f"  [{i}/{len(statements)}] 创建表: {table_name}")
            elif stmt_upper.startswith('CREATE INDEX') or stmt_upper.startswith('CREATE UNIQUE INDEX'):
                match = re.search(r'CREATE\s+(?:UNIQUE\s+)?INDEX\s+(\w+)', stmt, re.IGNORECASE)
                if match:
                    index_name = match.group(1)
                    print(f"  [{i}/{len(statements)}] 创建索引: {index_name}")
            elif stmt_upper.startswith('COMMENT ON'):
                pass
            else:
                print(f"  [{i}/{len(statements)}] 执行SQL...")
            
            try:
                cursor.execute(stmt)
                conn.commit()
                success_count += 1
            except Exception as e:
                conn.rollback()
                error_msg = str(e)
                if 'already exists' in error_msg.lower():
                    pass
                else:
                    print(f"    错误: {e}")
                    error_count += 1
        
        cursor.close()
        
        print(f"\n表结构创建完成! 成功: {success_count}, 错误: {error_count}")
        return error_count == 0
        
    except Exception as e:
        print(f"SQL执行失败: {e}")
        return False


def ask_user_confirmation(prompt, default='n'):
    """询问用户确认"""
    while True:
        response = input(f"{prompt} [Y/n]: ").strip().lower()
        if response == '':
            return default.lower() == 'y'
        if response in ['y', 'yes']:
            return True
        if response in ['n', 'no']:
            return False
        print("请输入 Y 或 N")


def main():
    print("=" * 60)
    print("智能算力监测平台 - 数据库初始化脚本")
    print("=" * 60)
    print()
    
    db_config = get_database_config()
    print("数据库连接配置:")
    print(f"  主机: {db_config['host']}")
    print(f"  端口: {db_config['port']}")
    print(f"  数据库: {db_config['database']}")
    print(f"  用户: {db_config['user']}")
    print(f"  SQL文件: {SQL_FILE}")
    print()
    
    try:
        print("正在连接数据库...")
        conn = get_connection()
        print("数据库连接成功!\n")
        
        existing_tables = check_tables_exist(conn)
        
        if existing_tables:
            print(f"检测到 {len(existing_tables)} 个已存在的表:")
            
            tables_with_data, total_records = check_tables_have_data(conn, existing_tables)
            
            if tables_with_data:
                print(f"\n以下表包含数据 (共 {total_records} 条记录):")
                for table, count in tables_with_data[:10]:
                    print(f"  - {table}: {count} 条")
                if len(tables_with_data) > 10:
                    print(f"  ... 还有 {len(tables_with_data) - 10} 个表")
                
                print()
                print("=" * 60)
                print("警告: 数据库中已有数据!")
                print("=" * 60)
                
                if ask_user_confirmation("\n是否清空并重建所有表?"):
                    drop_all_tables(conn)
                else:
                    print("\n操作已取消。")
                    conn.close()
                    return
            
            print("\n表已存在但无数据，将删除并重建表结构...")
            drop_all_tables(conn)
        else:
            print("未检测到已存在的表，将创建新表结构。\n")
        
        success = execute_sql_file(conn, SQL_FILE)
        
        if success:
            print("\n" + "=" * 60)
            print("数据库初始化完成!")
            print("=" * 60)
            
            new_tables = check_tables_exist(conn)
            print(f"\n已创建 {len(new_tables)} 个表:")
            for table in new_tables:
                print(f"  - {table}")
        else:
            print("\n数据库初始化失败!")
            sys.exit(1)
        
        conn.close()
        
    except psycopg2.OperationalError as e:
        print(f"\n数据库连接失败: {e}")
        print("\n请检查:")
        print("  1. 数据库服务是否已启动")
        print("  2. 连接配置是否正确")
        print("  3. 数据库是否已创建")
        print("\n可以通过环境变量设置连接参数:")
        print("  DB_HOST - 数据库主机")
        print("  DB_PORT - 数据库端口")
        print("  DB_NAME - 数据库名称")
        print("  DB_USER - 数据库用户")
        print("  DB_PASSWORD - 数据库密码")
        sys.exit(1)
    except Exception as e:
        print(f"\n初始化过程出错: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == '__main__':
    main()
