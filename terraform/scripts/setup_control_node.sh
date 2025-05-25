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
ec2_ips=()
while IFS= read -r line; do
  ec2_ips+=("$line")
done < <(terraform output -state="$(dirname "$0")/../terraform.tfstate" -json instance_private_ips | jq -r '.[]')

if [[ ${#ec2_ips[@]} -eq 0 ]]; then
  echo "Failed to retrieve EC2 IP address from TF state"
  exit 1
fi

# Split IP addresses
# control_node="$(echo "${ec2_ips[0]}" | xargs)" 
managed_node_private_ips=("${ec2_ips[@]:1}")

tmp_file=$(mktemp)
printf "%s\n" "${managed_node_private_ips[@]}" > "$tmp_file"

# Copy keypair and managed nodes to control node
echo "Connecting to control node: '${control_node_public_ip}'"

scp -i "$keypair_path" "$keypair_path" "ec2-user@${control_node_public_ip}:~/.ssh"
scp -i "$keypair_path" "$tmp_file" "ec2-user@${control_node_public_ip}:~/managed_nodes_ips"

rm "$tmp_file"

# SSH into control node
ssh -i "$keypair_path" "ec2-user@${control_node_public_ip}"