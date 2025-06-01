#!/bin/bash
exec > /var/log/user-data.log 2>&1
set -x

sudo dnf update -y
sudo dnf install ansible -y