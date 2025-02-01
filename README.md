# LucidLink Ansible Deployment

Ansible playbook for automated deployment and configuration of LucidLink client on Linux systems.

## Prerequisites

- Ansible 2.9 or higher
- Target systems:
  - Debian-based (Ubuntu, Debian) or Red Hat-based (RHEL, Amazon Linux, CentOS) distributions
  - Systemd
  - FUSE support
  - Internet connectivity

## Quick Start

1. Run the setup script:
   ```bash
   # Show setup options and help
   ./setup.sh --help

   # Interactive mode (will prompt for password)
   ./setup.sh

   # Or non-interactive with password
   ./setup.sh "your-lucidlink-password"
   ```
   This will:
   - Create env.yml from template
   - Create encrypted vault for password
   - Configure Ansible settings

2. Edit `env.yml`:
   ```yaml
   # LucidLink Configuration
   ll_filespace: "your-filespace.dpfs"
   ll_username: "your-username"
   ll_mount_point: "/mnt/lucid"
   ll_cache_location: "/data/lucidlink"
   ll_data_cache_size: "25GB"
   ll_version: "2"  # Can be "2" or "3"

   # Server Configuration
   servers:
     - ip: "x.x.x.x"
       os_type: "ubuntu"  # for Debian-based distros (Ubuntu, Debian)
                         # or "rhel" for Red Hat-based distros (RHEL, Amazon Linux, CentOS)
   ```

3. Run the playbook:
   ```