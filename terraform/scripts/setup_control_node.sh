# Keypair file name provided as input
KEYPAIR_NAME=$1
if [[ -z "$KEYPAIR_NAME" ]]; then
  echo "Please provide a keypair file name"
  exit 1
fi

# EC2 IP address automatically assigned
EC2_IP=$(terraform output -json instance_ips | jq -r '.[0]')
if [[ -z "$EC2_IP" ]]; then
  echo "Failed to retrieve EC2 IP address from TF state"
  exit 1
fi

# Copy keypair to control node
scp -i ${KEYPAIR_NAME}.pem ${KEYPAIR_NAME}.pem ec2-user@5${EC2_IP}:~.ssh

# SSH into control node
ssh -i ${KEYPAIR_NAME}.pem ec2-user@${EC2_IP}