#!/bin/bash

# Log all stdout and stderror
exec > /var/log/user-data.log 2>&1

# Log all commands and their arguments
set -x

# Update and install ansible
sudo dnf update -y
sudo dnf install ansible -y

# Install ansible docker collection
sudo ansible-galaxy collection install community.docker