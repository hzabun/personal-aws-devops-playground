#!/bin/bash

# Keypair file name provided as input
keypair_path="./ec2-ansible/ssh-keys/$1"
if [[ -z "$1" ]]; then
  echo "Please provide a keypair file name"
  exit 1
fi

# Extract public IP address of control node
control_node_public_ip=$(terraform output -state="./ec2-ansible/terraform/terraform.tfstate" -json instance_public_ips | jq -r '.[0]' | xargs)

# Extract private IP addresses
all_private_ips=()
while IFS= read -r line; do
  all_private_ips+=("$line")
done < <(terraform output -state="./ec2-ansible/terraform/terraform.tfstate" -json instance_private_ips | jq -r '.[]')

if [[ ${#all_private_ips[@]} -eq 0 ]]; then
  echo "Failed to retrieve EC2 IP address from TF state"
  exit 1
fi

# Extract managed nodes IPs
managed_node_private_ips=("${all_private_ips[@]:1}")

# Create file containing managed nodes and remove windows style carriage returns
tmp_private_ip_file=$(mktemp)
printf "%s\n" "${managed_node_private_ips[@]}" | sed 's/\r//' >"$tmp_private_ip_file"
echo "Temp private IP file created successfully."

# Create Ansible inventory file
tmp_ansible_inventory_file=$(mktemp)
echo "[myflask]" >"$tmp_ansible_inventory_file"

# Add each managed node private IP to Ansible inventory file
for ip in "${managed_node_private_ips[@]}"; do
  echo "$ip" >>"$tmp_ansible_inventory_file"
done
echo "Temp ansible inventory.ini file created successfully."

# Create ansible.cfg file
tmp_ansible_cfg_file=$(mktemp)
cat >"$tmp_ansible_cfg_file" <<EOF
[defaults]
inventory = ~/myinventory.ini
private_key_file = ~/.ssh/$(basename "$keypair_path")
remote_user = ec2-user
host_key_checking = False
EOF
echo "Temp ansible.cfg file created successfully."

# Copy keypair managed nodes and ansible inventory to control node
echo "Connecting to control node: '${control_node_public_ip}'"

scp -i "$keypair_path" "$keypair_path" "ec2-user@${control_node_public_ip}:~/.ssh"
scp -i "$keypair_path" "$tmp_private_ip_file" "ec2-user@${control_node_public_ip}:~/managed_nodes_ips"
scp -r -i "$keypair_path" "./ansible" "ec2-user@${control_node_public_ip}:/home/ec2-user/ansible"
scp -i "$keypair_path" "$tmp_ansible_inventory_file" "ec2-user@${control_node_public_ip}:/home/ec2-user/ansible/myinventory.ini"
scp -i "$keypair_path" "$tmp_ansible_cfg_file" "ec2-user@${control_node_public_ip}:/home/ec2-user/ansible/ansible.cfg"

trap 'rm -f "$tmp_private_ip_file" "$tmp_ansible_inventory_file" "$tmp_ansible_cfg_file"' EXIT
