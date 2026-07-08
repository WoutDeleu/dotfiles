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

### Answering Questions

Claude serves as a knowledge assistant for two types of questions. Detect intent from phrasing:

#### How-To Mode

**Triggers:** "how do I...", "how to...", "what command...", "what's the syntax for..."

- Answer immediately — no clarifying questions, no preamble
- Commands in code blocks, copy-paste ready
- Add a one-line explanation only if the command is non-obvious or has a gotcha
- If the answer is something worth automating, append: "Want me to log this?"

#### Advice Mode

**Triggers:** "should I...", "what's the best...", "X vs Y", "which is better...", "recommend..."

1. Ask up to **3 context questions** — one at a time, multiple-choice where possible. Focus on: hardware constraints, existing setup, workflow style (power-user vs simple), performance vs stability preference.
2. Once context is clear: structured **pros/cons per option**, then a **clear recommendation** with reasoning.
3. End with a definitive pick — no hedging.

#### Ambiguous Cases

Default to How-To (give the answer), then offer: "Want me to compare this against alternatives?"

---

### Logging Setup Steps

When the user describes something they have configured or installed, Claude should:

1. **Ask clarifying questions** before writing anything down, to collect all details needed for future Ansible automation. Focus on:
   - Exact package name(s) and install method (`pacman -S`, `yay`, `flatpak`, manual build)
   - Any config files changed: path, key options set, and why
   - Services enabled/started (`systemctl enable --now <name>`)
   - Dependencies or order-of-operations constraints
   - Decisions made and the reason (e.g. "chose X over Y because Z")
   - Anything that would break on a clean reinstall if forgotten

2. **Write a concise entry** to `SETUP_LOG.md` in the correct phase/section, using the existing table or comment format. Keep entries brief — just enough to rebuild with Ansible later. Use the log's existing structure (tables for packages/services, inline notes for config decisions).

3. **Update the Decisions & Notes table** at the bottom of `SETUP_LOG.md` if a significant choice was made.

Example questions to ask:
- "Which package manager did you use — pacman or an AUR helper?"
- "Did you enable the service on boot (`systemctl enable`) or just start it?"
- "Any config file changes? If so, which file and what did you change?"
- "Why did you pick this tool over alternatives?"

### Creating GitHub Tickets

**Use the `project-board-maintenance` skill** for all board operations.

Key rules:
- **Title**: clear and concise — the main assignment in a few words
- **Description**: brief and structured. Use bullet points, checklists (`- [ ]`), and headers where they help. Enough context to know what to do — not a full spec.
- **Every task must have a parent Epic** — link after creation via `addSubIssue` GraphQL mutation
- **Epics get Type = Epic on the board; Tasks get Type = Task**
- **Labels**: apply exactly one of `Essentials` (core/required feature) or `Future Enhancements` (idea for later) to each task
- New issues are auto-added to the board as Todo via GitHub Action (`.github/workflows/auto-add-to-project.yml`), requires `ADD_TO_PROJECT_PAT` secret

Current Epics: #96 Desktop Environment, #97 Development Environment, #98 Applications, #99 System Infrastructure
