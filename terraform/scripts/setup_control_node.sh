#!/bin/bash

# Keypair file name provided as input
keypair_path="$(dirname "$0")/$1"
if [[ -z "$1" ]]; then
  echo "Please provide a keypair file name"
  exit 1
fi

# Extract and convert IP addresses JSON
ec2_ips=()
while IFS= read -r line; do
  ec2_ips+=("$line")
done < <(terraform output -json instance_ips | jq -r '.[]')

if [[ ${#ec2_ips[@]} -eq 0 ]]; then
  echo "Failed to retrieve EC2 IP address from TF state"
  exit 1
fi

# Split IP addresses
control_node="$(echo "${ec2_ips[0]}" | xargs)" 
managed_node=("${ec2_ips[@]:1}")

tmp_file=$(mktemp)
printf "%s\n" "${managed_node[@]}" > "$tmp_file"

# Copy keypair and managed nodes to control node
echo "Connecting to control node: '${control_node}'"

scp -i "$keypair_path" "$keypair_path" "ec2-user@${control_node}:~/.ssh"
scp -i "$keypair_path" "$tmp_file" "ec2-user@${control_node}:~/.ssh/known_hosts"

# SSH into control node
ssh -i "$keypair_path" "ec2-user@${control_node}"