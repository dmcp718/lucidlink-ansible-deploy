# LucidLink Ansible Deployment

Ansible playbook for automated deployment and configuration of LucidLink client on Linux systems.

## Prerequisites

- Ansible 2.9 or higher
- Target systems:
  - Ubuntu or Amazon Linux
  - Systemd
  - FUSE support
  - Internet connectivity

## Quick Start

1. Copy and configure environment:
   ```bash
   cp env.sample.yml env.yml
   ```

2. Edit `env.yml`:
   ```yaml
   # LucidLink Configuration
   ll_filespace: "your-filespace.dpfs"
   ll_username: "your-username"
   ll_mount_point: "/mnt/lucid"
   ll_cache_location: "/data/lucidlink"
   ll_data_cache_size: "25GB"
   ll_version: "2"  # Can be "2" or "3"
   ll_password: "your-password"  # Or use ansible-vault

   # Server Configuration
   servers:
     - ip: "x.x.x.x"
       os_type: "ubuntu"  # or "amazon"
   ```

3. Run the playbook:
   ```bash
   ansible-playbook site.yml
   ```

## Features

- Automated LucidLink client installation
- Secure credential handling with systemd-creds
- Proper service management with systemd
- Configuration management
- Error handling and logging

## Roles

### lucidlink-install
- Installs LucidLink client
- Creates service user and directories
- Sets up systemd service
- Configures FUSE

### lucidlink-config  
- Starts LucidLink daemon
- Configures cache size and location
- Sets up logging
- Handles error reporting

## Security

- Credentials encrypted with systemd-creds
- Proper file permissions
- Dedicated service user
- No sensitive data in logs

## License

See LICENSE file for details.
