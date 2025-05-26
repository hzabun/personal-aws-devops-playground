#!/bin/bash

# Keypair file name provided as input
keypair_path="$(dirname "$0")/../../ssh-keys/$1"
if [[ -z "$1" ]]; then
  echo "Please provide a keypair file name"
  exit 1
fi

# Extract public IP address of control node
control_node_public_ip=$(terraform output -state="$(dirname "$0")/../terraform.tfstate" -json instance_public_ips | jq -r '.[0]' | xargs)

# Extract and convert private IP addresses
all_private_ips=()
while IFS= read -r line; do
  all_private_ips+=("$line")
done < <(terraform output -state="$(dirname "$0")/../terraform.tfstate" -json instance_private_ips | jq -r '.[]')

if [[ ${#all_private_ips[@]} -eq 0 ]]; then
  echo "Failed to retrieve EC2 IP address from TF state"
  exit 1
fi

# Split IP addresses
managed_node_private_ips=("${all_private_ips[@]:1}")

tmp_private_ip_file=$(mktemp)
printf "%s\n" "${managed_node_private_ips[@]}" > "$tmp_private_ip_file"
echo "Temp private IP file created successfully."

# Create Ansible inventory file
tmp_ansible_inventory_file=$(mktemp)
echo "[myflask]" > "$tmp_ansible_inventory_file"

# Loop through the list and write each host with an incrementing number
i=1
for ip in "${managed_node_private_ips[@]}"; do
    echo "ansible_managed_host$i=$ip" >> "$tmp_ansible_inventory_file"
    ((i++))
done
echo "Temp ansible inventory file created successfully."

# Copy keypair managed nodes and ansible inventory to control node
echo "Connecting to control node: '${control_node_public_ip}'"

scp -i "$keypair_path" "$keypair_path" "ec2-user@${control_node_public_ip}:~/.ssh"
scp -i "$keypair_path" "$tmp_private_ip_file" "ec2-user@${control_node_public_ip}:~/managed_nodes_ips"
scp -i "$keypair_path" "$tmp_ansible_inventory_file" "ec2-user@${control_node_public_ip}:~/myinventory.ini"

# Cleanup
trap 'rm -f "$tmp_private_ip_file" "$tmp_ansible_inventory_file"' EXIT