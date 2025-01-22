#!/bin/bash

# Exit on error
set -e

# Create group_vars structure
mkdir -p group_vars/lucidlink

# Function to prompt for password if not provided
get_password() {
    if [ -z "$1" ]; then
        read -sp "Enter LucidLink password: " password
        echo
        echo "$password"
    else
        echo "$1"
    fi
}

# Get password from argument or prompt
ll_password=$(get_password "$1")

# Create vault password
openssl rand -base64 32 > .vault_pass
chmod 600 .vault_pass

# Create temporary vault content
cat > group_vars/lucidlink/vault.yml << EOL
---
ll_password: "${ll_password}"
EOL

# Encrypt the vault
ansible-vault encrypt --vault-password-file .vault_pass group_vars/lucidlink/vault.yml

echo "Setup complete! Vault has been created and encrypted."
echo "The vault password is stored in .vault_pass"
echo "Remember to never commit .vault_pass or vault.yml to version control."
