# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal system recovery/setup repository for an **Arch Linux + Wayland** environment. It enables fast disaster recovery and new PC setup by combining:
- **Ansible**: Package installation and system configuration
- **GNU Stow**: Dotfile management via symlinks
- **Ansible Vault**: Secure storage for sensitive config (SSH keys, git credentials, etc.)

The goal is to go from a fresh Arch install to a fully configured Wayland desktop (Hyprland or Sway) in minutes instead of days.

### Target Environment
- **OS**: Arch Linux (pacman)
- **Display protocol**: Wayland
- **Compositor**: Hyprland or Sway (i3-like tiling)

### Setup Workflow
New configuration is developed in two phases:
1. **Log phase**: Document all manual setup steps in `SETUP_LOG.md` as you go (commands, decisions, config changes). Organize entries by category: packages, dotfiles, services.
2. **Automation phase**: Convert the log into Ansible tasks and dotfiles in this repo, then commit and clean up the log entries.

## Setup Commands

### Initial Bootstrap
```bash
./bootstrap.sh
```
This script:
- Detects OS and installs Ansible, Git, and Stow via appropriate package manager
- Clones the repository to `~/linux-setup` if not present
- Runs the Ansible playbook with vault password prompts

### Manual Ansible Execution
```bash
cd ansible
ansible-playbook -i inventory.ini playbook.yml --ask-become-pass --ask-vault-pass
```

## Repository Structure

- **`bootstrap.sh`**: Entry point - OS-agnostic setup script
- **`ansible/`**: Ansible playbooks for package installation and system configuration
  - Should contain `inventory.ini` and `playbook.yml`
  - Use Ansible Vault for encrypted secrets (SSH keys, git credentials, API tokens)
- **`dotfiles/`**: Configuration files organized by application (hyprland/sway, terminal, waybar, git, etc.)
  - Each subdirectory represents a "stow package" that gets symlinked to `$HOME`
  - Example: `dotfiles/hyprland/.config/hypr/hyprland.conf` → `~/.config/hypr/hyprland.conf`
- **`SETUP_LOG.md`**: Running log of manual setup steps (commands, decisions, config changes) captured during active setup, organized by category (packages, dotfiles, services). Entries are removed once automated into Ansible/dotfiles.

## Workflow

### Adding New Dotfiles
1. Copy existing config files to `dotfiles/` maintaining the structure relative to `$HOME`
2. Use `stow` to create symlinks: `cd dotfiles && stow <package-name>`
3. Commit to git

### Managing Secrets
- Use `ansible-vault` to encrypt sensitive files
- Store vault password securely (not in repo)
- Playbook will prompt for vault password during execution

### Testing
- Use VM or container to test bootstrap script on a clean Arch install
- Verify all packages install correctly via pacman/AUR
- Verify dotfiles are symlinked properly
- Verify compositor (Hyprland/Sway), waybar, and terminal configs work as expected

### Creating GitHub Tickets
When asked to create tickets or issues in the GitHub project:
- Use the `gh` CLI tool via the Bash tool
- Structure tickets as **user stories** with **success criteria**
- Format the issue body with:
  - User story describing the goal (e.g., "Configure i3 window manager")
  - Success criteria as a checklist of tasks to complete
- Include relevant labels (e.g., `enhancement`, `bug`, `documentation`)
- Reference related issues or PRs when applicable
- **After creating the issue, add it to the GitHub project** (WoutDeleu/projects/5)

Example structure:
```markdown
## User Story
Configure i3 window manager for optimal workflow

## Success Criteria
- [ ] Setup Ansible playbook for i3 installation
- [ ] Write and review i3 config file
- [ ] Test config on fresh install
```

Example commands:
```bash
# Create the issue
gh issue create --title "Configure i3 window manager" --body "$(cat <<'EOF'
## User Story
Configure i3 window manager for optimal workflow

## Success Criteria
- [ ] Setup Ansible playbook for i3 installation
- [ ] Write and review i3 config file
- [ ] Test config on fresh install
EOF
)" --label "enhancement"

# Add the issue to the project (replace ISSUE_NUMBER with the created issue number)
gh project item-add 5 --owner WoutDeleu --url https://github.com/WoutDeleu/linux-setup/issues/ISSUE_NUMBER
```
