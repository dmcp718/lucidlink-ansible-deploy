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

# Function to validate environment configuration
validate_env() {
    if [ ! -f "./scripts/validate_env.sh" ]; then
        echo "Error: validate_env.sh script not found"
        exit 1
    fi
    
    ./scripts/validate_env.sh env.yml
}

# Function to generate inventory file
generate_inventory() {
    local env_file="env.yml"
    local inventory_file="inventory"
    
    echo "Generating inventory from $env_file..."
    
    if [ ! -f "$env_file" ]; then
        echo "Error: $env_file not found!"
        exit 1
    fi
    
    echo "Contents of $env_file:"
    cat "$env_file"
    echo "-------------------"
    
    echo "Servers section of $env_file:"
    sed -n '/^servers:/,$p' "$env_file"
    echo "-------------------"
    
    echo "[lucidlink]" > "$inventory_file"
    
    while IFS= read -r line; do
        echo "Processing line: $line"
        if [[ $line =~ ^[[:space:]]*-[[:space:]]*ip:[[:space:]]*\"?([^\"]+)\"?$ ]]; then
            ip="${BASH_REMATCH[1]}"
            echo "Found IP: $ip"
            echo "$ip" >> "$inventory_file"
        fi
    done < <(sed -n '/^servers:/,$p' "$env_file")
    
    if [ ! -s "$inventory_file" ]; then
        echo "Warning: Generated inventory file is empty!"
    else
        echo "Generated inventory contents:"
        cat "$inventory_file"
    fi
}

# Function to extract value from env.yml
get_env_value() {
    local key=$1
    local default=$2
    
    if [[ $key == "servers[0].os_type" ]]; then
        # Special handling for nested server OS type
        value=$(sed -n '/^servers:/,/^[^ ]/p' env.yml | grep "os_type:" | head -n1 | sed "s/^[[:space:]]*os_type:[[:space:]]*\"\{0,1\}\([^\"]*\)\"\{0,1\}/\1/")
    else
        value=$(grep "^${key}:" env.yml | sed "s/^${key}:[[:space:]]*\"\{0,1\}\([^\"]*\)\"\{0,1\}/\1/")
    fi
    
    echo "${value:-$default}"
}

# Function to get remote user based on OS type
get_remote_user() {
    local os_type=$(get_env_value "servers[0].os_type" "")
    echo "Detected OS type: $os_type" >&2
    case "$os_type" in
        *"ubuntu"*) echo "ubuntu" ;;
        *"amazon"*) echo "ec2-user" ;;
        *"rhel"*) echo "ec2-user" ;;
        *) echo "ec2-user" ;; # default fallback
    esac
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
if ! validate_env; then
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
ansible-vault encrypt --vault-password-file .vault_pass --encrypt-vault-id default group_vars/lucidlink/vault.yml

# Always regenerate inventory
echo "Regenerating inventory file..."
generate_inventory

# Always regenerate ansible.cfg
echo "Generating ansible.cfg..."
private_key=$(get_env_value "ssh_private_key" "")
if [ -z "$private_key" ]; then
    echo "Warning: No SSH private key specified in env.yml"
fi

# Ensure private key path is absolute
if [[ "$private_key" != /* ]]; then
    private_key="$(pwd)/$private_key"
fi

remote_user=$(get_remote_user)
echo "Setting remote_user to: $remote_user based on OS type"
echo "Using private key: $private_key"

cat > ansible.cfg << EOL
[defaults]
inventory = inventory
vault_password_file = .vault_pass
host_key_checking = False
retry_files_enabled = False
log_path = ansible.log
remote_user = ${remote_user}
private_key_file = ${private_key}

[ssh_connection]
ssh_args = -o ForwardAgent=yes -o ControlMaster=auto -o ControlPersist=60s
pipelining = True

[privilege_escalation]
become = True
become_method = sudo
become_user = root
become_ask_pass = False
become_flags = -n
EOL

# Set up logging directory
mkdir -p logs

echo "Setup complete! You can now run: ansible-playbook site.yml"
