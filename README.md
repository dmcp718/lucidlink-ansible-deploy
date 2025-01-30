# LucidLink Ansible Deployment

This repository contains Ansible playbooks for automated deployment and configuration of LucidLink clients. The deployment process is modular, secure, and includes comprehensive error handling and validation.

## Prerequisites

- Ansible 2.9 or higher
- Python 3.6 or higher
- OpenSSL
- Target systems must have:
  - Minimum 4GB RAM
  - Minimum 10GB free disk space
  - FUSE support
  - Internet connectivity

## Directory Structure

```
.
├── roles/
│   ├── lucidlink-prerequisites/   # System preparation
│   ├── lucidlink-install/         # Core installation
│   ├── lucidlink-config/          # Configuration management
│   └── lucidlink-mount/           # Mount point management
├── scripts/
│   └── validate_env.py           # Environment validation script
├── env.sample.yml                # Sample configuration
├── site.yml                      # Main playbook
├── setup.sh                      # Setup script
└── ansible.cfg                   # Ansible configuration
```

## Quick Start

1. Clone this repository
2. Copy and configure environment:
   ```bash
   ./setup.sh
   ```
3. Edit `env.yml` with your configuration
4. Run the playbook:
   ```bash
   ansible-playbook site.yml
   ```

## Configuration

### Environment Configuration (env.yml)

```yaml
# LucidLink Configuration
ll_filespace: "your-filespace-name"  # Your LucidLink filespace name
ll_username: "your-username"         # Your LucidLink username
ll_mount_point: "/mnt/lucidlink"    # Where to mount the LucidLink filesystem
ll_cache_location: "/var/cache/lucidlink"  # Where to store LucidLink cache
ll_data_cache_size: "50GB"          # Size of the data cache

# Server Configuration
servers:
  - ip: "x.x.x.x"
    hostname: "server1"
```

### Security

- Credentials are stored in an encrypted Ansible vault
- Secure random vault password generation
- File permissions are properly set
- No sensitive information in logs

## Deployment Tags

Use tags to run specific parts of the deployment:

- `prereq`: System prerequisites
- `install`: LucidLink installation
- `config`: Configuration
- `mount`: Filesystem mounting
- `health-check`: Run health checks

Example:
```bash
ansible-playbook site.yml --tags "install,config"
```

## Monitoring

The deployment includes comprehensive monitoring:

- System metrics collection
- Performance monitoring
- Health checks
- Automated alerts
- Logging configuration

Logs are stored in `/var/log/lucidlink-ansible-deploy/`

## Error Handling

The deployment includes:

- Pre-flight system checks
- Comprehensive error handling
- Automatic retry mechanisms
- Rollback capabilities
- Detailed logging

## Troubleshooting

1. Check logs:
   ```bash
   tail -f /var/log/lucidlink-ansible-deploy/deploy.log
   ```

2. Verify service status:
   ```bash
   systemctl status lucidlink
   ```

3. Check mount point:
   ```bash
   mountpoint /mnt/lucidlink
   ```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## License

See the LICENSE file for details.
