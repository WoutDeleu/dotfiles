#!/usr/bin/env bash
set -e

# Install required packages
sudo pacman -Sy --noconfirm ansible git stow

# Clone repository if not present
if [ ! -d ~/linux-setup ]; then
  git clone https://github.com/WoutDeleu/linux-setup ~/linux-setup
fi

# Run Ansible playbook
cd ~/linux-setup/ansible
ansible-playbook -i inventory.ini playbook.yml --ask-become-pass
