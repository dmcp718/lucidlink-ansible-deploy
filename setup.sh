#!/bin/bash

# Exit on error
set -e

# Check if env.yml exists, if not copy from sample
if [ ! -f env.yml ]; then
    echo "Creating env.yml from sample..."
    cp env.sample.yml env.yml
    echo "Please edit env.yml with your configuration values and run this script again."
    exit 0
fi

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

# Create group_vars structure
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

# Generate defaults/main.yml from env.yml
mkdir -p roles/lucidlink/defaults
cat > roles/lucidlink/defaults/main.yml << EOL
---
# LucidLink Configuration

# Version of LucidLink to use
# Options:
#   "2" - Uses /usr/bin/lucid2
#   "3" - Uses /usr/bin/lucid3
ll_version: "$(get_env_value ll_version 2)"

ll_filespace: "$(get_env_value ll_filespace "your-filespace-name")"
ll_username: "$(get_env_value ll_username "your-username")"
ll_mount_point: "$(get_env_value ll_mount_point "/mnt/lucidlink")"
ll_cache_location: "$(get_env_value ll_cache_location "/var/cache/lucidlink")"
ll_data_cache_size: "$(get_env_value ll_data_cache_size "50GB")"
EOL

# Generate inventory from env.yml
echo "[lucidlink]" > inventory
# Use awk to parse the servers section of env.yml
awk '/^servers:/,/^[^-]/ {
    if ($1 == "-") {
        ip = ""; hostname = ""
    }
    if ($1 == "ip:") ip = $2
    if ($1 == "hostname:") hostname = $2
    if (ip != "" && hostname != "") {
        gsub(/"/, "", ip)
        gsub(/"/, "", hostname)
        print hostname " ansible_host=" ip
        ip = ""; hostname = ""
    }
}' env.yml >> inventory

echo "Setup complete! The following files have been created/updated:"
echo "- .vault_pass (encrypted vault password)"
echo "- group_vars/lucidlink/vault.yml (encrypted)"
echo "- roles/lucidlink/defaults/main.yml (generated from env.yml)"
echo "- inventory (generated from env.yml)"
