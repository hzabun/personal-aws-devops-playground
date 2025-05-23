#!/bin/bash

# Keypair file name provided as input
KEYPAIR_NAME=$1
if [[ -z "$KEYPAIR_NAME" ]]; then
  echo "Please provide a keypair file name"
  exit 1
fi

# Extract and convert IP addresses JSON
EC2_IPS=()
while IFS= read -r line; do
  EC2_IPS+=("$line")
done < <(terraform output -json instance_ips | jq -r '.[]')

if [[ -z "$EC2_IPS" ]]; then
  echo "Failed to retrieve EC2 IP address from TF state"
  exit 1
fi

# Split IP addresses
CONTROL_NODE=${EC2_IPS[0]}
MANAGED_NODES=("${EC2_IPS[@]:1}")

TMP_FILE=$(mktemp)
printf "%s\n" "${MANAGED_NODES[@]}" > "$TMP_FILE"

# # # Copy keypair and managed nodes to control node
scp -i "${KEYPAIR_NAME}" "${KEYPAIR_NAME}" "ec2-user@${CONTROL_NODE}:~.ssh"
scp -i "${KEYPAIR_NAME}" "${TMP_FILE}" "ec2-user@${CONTROL_NODE}:~.ssh/known_hosts"

# # # SSH into control node
ssh -i "${KEYPAIR_NAME}" "ec2-user@${CONTROL_NODE}"