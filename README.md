# Linux Setup

> Fast disaster recovery and new PC setup for Arch Linux + Wayland (Hyprland)

Automates system setup using Ansible for packages, GNU Stow for dotfiles, and Ansible Vault for secrets.

## Prerequisites

- Fresh Arch Linux installation
- Internet connection
- Sudo access

## Quick Start

```bash
# Download and run
curl -O https://raw.githubusercontent.com/WoutDeleu/linux-setup/main/bootstrap.sh
chmod +x bootstrap.sh
./bootstrap.sh
```

## What It Does

1. Installs Ansible, Git, and Stow via `pacman`
2. Clones this repository to `~/linux-setup`
3. Runs the Ansible playbook (prompts for sudo password)

## Repository Structure

```
linux-setup/
├── bootstrap.sh          # Entry point — run on a fresh Arch install
├── SETUP_LOG.md          # Running log of manual steps (source for future automation)
├── ansible/              # Ansible playbooks
│   ├── inventory.ini
│   └── playbook.yml
└── dotfiles/             # Config files managed with GNU Stow
    ├── hyprland/         # ~/.config/hypr/
    ├── waybar/           # ~/.config/waybar/
    ├── terminal/         # ~/.config/<terminal>/
    ├── nvim/             # ~/.config/nvim/
    └── git/              # ~/.gitconfig etc.
```

## Workflow

### Logging new setup steps
As you configure the system manually, log commands and decisions in `SETUP_LOG.md` under the relevant category. Once a step is automated, remove it from the log.

### Adding packages to Ansible
Edit `ansible/playbook.yml` and add packages to the relevant section. Run manually:

```bash
cd ~/linux-setup/ansible
ansible-playbook -i inventory.ini playbook.yml --ask-become-pass
```

### Adding dotfiles
```bash
# Copy config to dotfiles/ maintaining directory structure relative to $HOME
# Example: ~/.config/hypr/hyprland.conf → dotfiles/hyprland/.config/hypr/hyprland.conf
cd ~/linux-setup/dotfiles
stow hyprland   # creates symlinks in $HOME
```

### Managing secrets
```bash
ansible-vault encrypt vars/secrets.yml
ansible-vault edit vars/secrets.yml
```

## License

Personal configuration repository. Fork and adapt as needed.
