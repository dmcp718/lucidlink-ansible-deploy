# LucidLink Ansible Deployment

This Ansible playbook automates the deployment and configuration of LucidLink clients on multiple servers.

## Setup Instructions

1. Copy `env.sample.yml` to `env.yml`:
   ```bash
   cp env.sample.yml env.yml
   ```

2. Edit `env.yml` with your configuration:
   - Configure mount points and cache locations
   - Add your server IPs and hostnames

3. Run the setup script to create and encrypt the vault:
   ```bash
   # Option 1: Interactive mode (will prompt for password)
   ./setup.sh

   # Option 2: Pass password as argument
   ./setup.sh "your-lucidlink-password"
   ```

4. Update the `inventory` file with your server information using the template provided

5. Run the playbook:
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
- Target servers running Ubuntu 20.04 LTS or later
- SSH access to target servers
- LucidLink account and credentials

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
