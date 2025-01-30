#!/bin/bash

# Exit on error
set -e

ENV_FILE="$1"

if [ ! -f "$ENV_FILE" ]; then
    echo "Error: File $ENV_FILE does not exist"
    exit 1
fi

# Function to check if a field exists and is not empty
check_field() {
    local field="$1"
    local value
    value=$(grep "^$field:" "$ENV_FILE" | sed "s/^$field:[[:space:]]*//")
    value="${value//\"/}"  # Remove quotes
    if [ -z "$value" ] || [[ "$value" == "\"\""* ]]; then
        echo "Error: Missing or empty field: $field"
        return 1
    fi
    return 0
}

# Function to validate path
validate_path() {
    local field="$1"
    local value
    value=$(grep "^$field:" "$ENV_FILE" | sed "s/^$field:[[:space:]]*//")
    value="${value//\"/}"  # Remove quotes
    if [[ ! "$value" = /* ]]; then
        echo "Error: $field must be an absolute path"
        return 1
    fi
    return 0
}

# Function to validate cache size format
validate_cache_size() {
    local value
    value=$(grep "^ll_data_cache_size:" "$ENV_FILE" | sed "s/^ll_data_cache_size:[[:space:]]*//")
    # Remove quotes and comments
    value=$(echo "$value" | sed 's/#.*$//' | sed 's/"//g' | sed "s/'//g" | tr -d '[:space:]')
    if [[ ! "$value" =~ ^[0-9]+[MGT]B$ ]]; then
        echo "Error: ll_data_cache_size must be in format: <number>[M|G|T]B (e.g., 50GB)"
        return 1
    fi
    return 0
}

# Function to validate servers section
validate_servers() {
    local server_count
    server_count=$(grep -c "^[[:space:]]*- ip:" "$ENV_FILE" || true)
    if [ "$server_count" -eq 0 ]; then
        echo "Error: No servers defined in configuration"
        return 1
    fi

    # Check if this is the sample configuration
    local filespace
    filespace=$(grep "^ll_filespace:" "$ENV_FILE" | sed "s/^ll_filespace:[[:space:]]*//")
    filespace="${filespace//\"/}"  # Remove quotes
    if [[ "$filespace" == "your-filespace-name" ]]; then
        echo "Note: Sample configuration detected, skipping IP validation"
        return 0
    fi

    local line_num=1
    local errors=0
    while IFS= read -r line || [ -n "$line" ]; do
        if [[ "$line" =~ ^[[:space:]]*-[[:space:]]*ip:[[:space:]]*(.+)$ ]]; then
            ip="${BASH_REMATCH[1]//\"/}"  # Remove quotes
            ip="${ip//[[:space:]]/}"      # Remove whitespace
            # Skip placeholder IPs
            if [[ "$ip" == "x.x.x.x" ]]; then
                continue
            fi
            # Basic IP format validation
            if ! [[ "$ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
                echo "Error: Invalid IP format at line $line_num: $ip"
                ((errors++))
            fi
        fi
        ((line_num++))
    done < "$ENV_FILE"

    return "$errors"
}

# Required fields
REQUIRED_FIELDS=(
    "ll_filespace"
    "ll_username"
    "ll_mount_point"
    "ll_cache_location"
    "ll_data_cache_size"
)

# Validate required fields
errors=0
for field in "${REQUIRED_FIELDS[@]}"; do
    if ! check_field "$field"; then
        ((errors++))
    fi
done

# Validate paths
if ! validate_path "ll_mount_point"; then
    ((errors++))
fi
if ! validate_path "ll_cache_location"; then
    ((errors++))
fi

# Validate cache size format
if ! validate_cache_size; then
    ((errors++))
fi

# Validate servers section
if ! validate_servers; then
    ((errors++))
fi

if [ "$errors" -gt 0 ]; then
    echo "Validation failed with $errors error(s)"
    exit 1
fi

echo "Configuration validation successful!"
exit 0
