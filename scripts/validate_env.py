#!/usr/bin/env python3
import sys
import yaml
import os
from typing import Dict, Any

REQUIRED_FIELDS = {
    'll_filespace': str,
    'll_username': str,
    'll_mount_point': str,
    'll_cache_location': str,
    'll_data_cache_size': str,
    'servers': list
}

def validate_server(server: Dict[str, Any]) -> list:
    errors = []
    if not isinstance(server, dict):
        return ["Server entry must be a dictionary"]
    
    if 'ip' not in server:
        errors.append("Server missing 'ip' field")
    elif not isinstance(server['ip'], str):
        errors.append("Server 'ip' must be a string")
        
    if 'hostname' not in server:
        errors.append("Server missing 'hostname' field")
    elif not isinstance(server['hostname'], str):
        errors.append("Server 'hostname' must be a string")
        
    return errors

def validate_env(config: Dict[str, Any]) -> list:
    errors = []
    
    # Check required fields
    for field, expected_type in REQUIRED_FIELDS.items():
        if field not in config:
            errors.append(f"Missing required field: {field}")
        elif not isinstance(config[field], expected_type):
            errors.append(f"Field {field} must be of type {expected_type.__name__}")
            
    # Validate servers if present
    if 'servers' in config and isinstance(config['servers'], list):
        for i, server in enumerate(config['servers']):
            server_errors = validate_server(server)
            if server_errors:
                errors.extend([f"Server {i+1}: {error}" for error in server_errors])
                
    # Validate mount point and cache location paths
    if 'll_mount_point' in config:
        if not config['ll_mount_point'].startswith('/'):
            errors.append("Mount point must be an absolute path")
            
    if 'll_cache_location' in config:
        if not config['ll_cache_location'].startswith('/'):
            errors.append("Cache location must be an absolute path")
            
    return errors

def main():
    if len(sys.argv) != 2:
        print("Usage: validate_env.py <path_to_env.yml>")
        sys.exit(1)
        
    env_file = sys.argv[1]
    if not os.path.exists(env_file):
        print(f"Error: File {env_file} does not exist")
        sys.exit(1)
        
    try:
        with open(env_file) as f:
            config = yaml.safe_load(f)
    except yaml.YAMLError as e:
        print(f"Error parsing YAML: {e}")
        sys.exit(1)
        
    errors = validate_env(config)
    if errors:
        print("Configuration validation failed:")
        for error in errors:
            print(f"- {error}")
        sys.exit(1)
    else:
        print("Configuration validation successful!")
        sys.exit(0)

if __name__ == "__main__":
    main()
