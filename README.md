# LucidLink Ansible Deployment

Ansible playbook for automated deployment and configuration of LucidLink client on Linux systems.

## Prerequisites

- Ansible 2.9 or higher
- SSH private key with permissions 600 for target server access
- Target systems:
  - Debian-based (Ubuntu, Debian) or Red Hat-based (RHEL, Amazon Linux, CentOS) distributions
  - Systemd version 250 or higher (for systemd-creds support)
  - FUSE support
  - Internet connectivity

> **Note about systemd-creds**: This deployment uses systemd-creds, a utility introduced in systemd version 250, for secure credential management. The utility's availability depends on your distribution's systemd version. Please ensure your target systems meet this requirement.

To verify systemd version and systemd-creds availability on your target systems:
```bash
# Check systemd version (must be 250 or higher)
systemctl --version

# Verify systemd-creds is available
systemd-creds --help
```

Supported distributions known to include systemd 250+:
- Ubuntu 22.04 LTS and newer
- RHEL 9 and newer
- Amazon Linux 2023
- Debian 12 and newer

## Quick Start

1. Ensure your SSH private key is ready:
   ```bash
   chmod 600 /path/to/your/key.pem
   ```

2. Run setup script to create configuration template:
   ```bash
   # Show setup options and help
   ./setup.sh --help

   # First run creates env.yml template
   ./setup.sh
   ```

3. Edit `env.yml` with your configuration:
   ```yaml
   # LucidLink Configuration
   ll_filespace: "your-filespace.dpfs"
   ll_username: "your-username"
   ll_mount_point: "/mnt/lucid"
   ll_cache_location: "/data/lucidlink"
   ll_data_cache_size: "25GB"
   ll_version: "2"  # Can be "2" or "3"

   # Server Configuration
   ssh_private_key: "/path/to/key.pem"  # Path to your SSH key

   servers:
     - ip: "x.x.x.x"
       os_type: "ubuntu"  # for Debian-based distros (Ubuntu, Debian)
                         # or "rhel" for Red Hat-based distros (RHEL, Amazon Linux, CentOS)
   ```

4. Run setup script again to configure deployment:
   ```bash
   # Interactive mode (will prompt for password)
   ./setup.sh

   # Or non-interactive with password
   ./setup.sh "your-lucidlink-password"
   ```
   This will:
   - Create encrypted vault for password
   - Configure Ansible settings

5. Run the playbook:
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

## Manual Setup (Alternative)

If you prefer to set up manually instead of using setup.sh:

1. Copy and configure environment:
   ```bash
   cp env.sample.yml env.yml
   ```

2. Create vault for password:
   ```bash
   ansible-vault create vault.yml
   ```
   Add your password:
   ```yaml
   ll_password: "your-password"
   ```

## Configuration Reference

### Environment Configuration

The deployment uses two configuration files:

1. **env.sample.yml**: Template file showing all available options
2. **env.yml**: Your actual configuration file (created by setup.sh)

> Note: Do not edit env.sample.yml directly. The setup script will create env.yml from this template.

All available configuration options (from env.sample.yml):

```yaml
# LucidLink Configuration
ll_filespace: "your-filespace.dpfs"    # Your LucidLink filespace name
ll_username: "your-username"           # Your LucidLink username
ll_mount_point: "/mnt/lucid"          # Where to mount the LucidLink filesystem
ll_cache_location: "/data/lucidlink"  # Where to store LucidLink cache
ll_data_cache_size: "25GB"            # Size of the data cache
ll_version: "2"                       # LucidLink version (2 or 3)

# Server Configuration
ssh_private_key: "/path/to/key.pem"   # Path to SSH private key for server access

# Target Servers
servers:
  - ip: "x.x.x.x"                     # Server IP address
    os_type: "ubuntu"                 # OS type: "ubuntu" for Debian-based or
                                     # "rhel" for Red Hat-based distributions
```

### Configuration Notes

- **ll_version**: 
  - Use "2" for LucidLink v2.x
  - Use "3" for LucidLink v3.x

- **os_type**:
  - "ubuntu": For Debian-based distributions (Ubuntu, Debian)
  - "rhel": For Red Hat-based distributions (RHEL, Amazon Linux, CentOS)

- **ssh_private_key**: 
  - Can be relative or absolute path
  - Must have proper permissions (600)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.