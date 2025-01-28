# LucidLink Ansible Deployment

This Ansible playbook automates the deployment and configuration of LucidLink clients on multiple Ubuntu servers.

## Setup Instructions

1. Run the setup script:
   ```bash
   # First run will create env.yml from env.sample.yml
   ./setup.sh
   ```

2. Edit `env.yml` with your configuration:
   ```yaml
   # LucidLink Configuration
   ll_version: "2"              # "2" for lucid2, "3" for lucid3
   ll_filespace: "your-filespace-name"
   ll_username: "your-username"
   ll_mount_point: "mount/point"
   ll_cache_location: "cache/location"
   ll_data_cache_size: "50GB"

   # Server Configuration
   servers:
     - ip: "x.x.x.x"
       hostname: "server1"
     - ip: "x.x.x.x"
       hostname: "server2"
   ```

3. Run the setup script again to configure everything:
   ```bash
   # Option 1: Interactive mode (will prompt for password)
   ./setup.sh

   # Option 2: Pass password as argument
   ./setup.sh "your-lucidlink-password"
   ```

   This will:
   - Create and encrypt the vault with your LucidLink password
   - Generate inventory file from your server configuration
   - Generate role defaults from your configuration

4. Run the playbook:
   ```bash
   ansible-playbook -i inventory site.yml --vault-password-file .vault_pass
   ```

## Security Notes

- Never commit `.vault_pass` or `vault.yml` to version control
- The setup script automatically generates a secure vault password
- All sensitive information is stored in encrypted format
- Keep your `.vault_pass` file secure as it's required to decrypt the vault

## Requirements

- Ansible 2.9+
- Target servers running Linux
- SSH access to target servers
- LucidLink account and credentials

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
