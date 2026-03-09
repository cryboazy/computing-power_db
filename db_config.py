#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
配置管理模块
支持从YAML文件和环境变量加载配置
"""

import os
import yaml
from pathlib import Path

CONFIG_FILE = 'config.yaml'

_config = None


def get_config_path():
    config_path = os.environ.get('DB_CONFIG_PATH', None)
    if config_path:
        return config_path
    return Path(__file__).parent / CONFIG_FILE


def load_config():
    global _config
    
    if _config is not None:
        return _config
    
    config_path = get_config_path()
    
    if os.path.exists(config_path):
        with open(config_path, 'r', encoding='utf-8') as f:
            _config = yaml.safe_load(f) or {}
    else:
        _config = {}
    
    return _config


def get_database_config():
    config = load_config()
    db_config = config.get('database', {})
    
    return {
        'host': os.environ.get('DB_HOST', db_config.get('host', 'localhost')),
        'port': int(os.environ.get('DB_PORT', db_config.get('port', 5432))),
        'database': os.environ.get('DB_NAME', db_config.get('name', 'computing_power')),
        'user': os.environ.get('DB_USER', db_config.get('user', 'gaussdb')),
        'password': os.environ.get('DB_PASSWORD', db_config.get('password', ''))
    }


def get_data_generation_config():
    config = load_config()
    return config.get('data_generation', {})


def get_config():
    return load_config()


def reload_config():
    global _config
    _config = None
    return load_config()


DB_CONFIG = get_database_config()
