#!/bin/bash

# Exit on error
set -e

# Source environment variables if exists
if [ -f .env ]; then
    source .env
fi

# Function to check dependencies
check_dependencies() {
    local missing_deps=()
    for dep in ansible openssl; do
        if ! command -v $dep &> /dev/null; then
            missing_deps+=($dep)
        fi
    done
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo "Missing required dependencies: ${missing_deps[*]}"
        exit 1
    fi
}

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

# Check dependencies
check_dependencies

# Check if env.yml exists, if not copy from sample
if [ ! -f env.yml ]; then
    echo "Creating env.yml from sample..."
    cp env.sample.yml env.yml
    echo "Please edit env.yml with your configuration values and run this script again."
    exit 0
fi

# Validate environment configuration
if ! ./scripts/validate_env.sh env.yml; then
    exit 1
fi

# Get password from argument or prompt
ll_password=$(get_password "$1")

# Create secure vault password
if [ ! -f .vault_pass ]; then
    openssl rand -base64 48 > .vault_pass
    chmod 600 .vault_pass
fi

# Ensure group_vars structure exists
mkdir -p group_vars/lucidlink

# Create temporary vault content
cat > group_vars/lucidlink/vault.yml << EOL
---
ll_password: "${ll_password}"
EOL

# Encrypt the vault
ansible-vault encrypt --vault-password-file .vault_pass group_vars/lucidlink/vault.yml

# Function to extract value from env.yml
get_env_value() {
    local key=$1
    local default=$2
    value=$(grep "^${key}:" env.yml | sed "s/^${key}:[[:space:]]*//")
    echo "${value:-$default}"
}

# Generate inventory if it doesn't exist
if [ ! -f inventory ]; then
    echo "Generating inventory file..."
    echo "[lucidlink]" > inventory
    
    while IFS= read -r line; do
        if [[ $line =~ ^[[:space:]]*-[[:space:]]*ip:[[:space:]]*(.+)$ ]]; then
            ip="${BASH_REMATCH[1]}"
            # Remove quotes and comments
            ip=$(echo "$ip" | sed 's/#.*$//' | sed 's/"//g' | sed "s/'//g" | tr -d '[:space:]')
            # Skip placeholder IPs
            if [[ "$ip" == "x.x.x.x" ]]; then
                continue
            fi
            echo "$ip" >> inventory
        fi
    done < env.yml
fi

# Create ansible.cfg if it doesn't exist
if [ ! -f ansible.cfg ]; then
    cat > ansible.cfg << EOL
[defaults]
inventory = inventory
vault_password_file = .vault_pass
host_key_checking = False
retry_files_enabled = False
log_path = ansible.log

[ssh_connection]
pipelining = True
EOL
fi

# Set up logging directory
mkdir -p logs

echo "Setup complete! You can now run: ansible-playbook site.yml"
