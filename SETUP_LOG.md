# Arch Linux Setup Log

Running log of manual steps performed during the Arch + Wayland (Hyprland) setup.
Entries are removed once they have been automated into Ansible or committed as dotfiles.

**Workflow:**
1. Log steps here as you go (commands, decisions, config changes)
2. Organize by category so the Ansible/dotfile conversion is clean
3. Delete entries once automated

---

## Phase 1 — Foundation

### Bootable USB
<!-- Log: ISO version used, dd/Etcher command, verification steps -->

### Base Installation
<!-- Log: partition layout, filesystems, pacstrap packages, bootloader choice -->

### User & Hostname
<!-- Log: hostname, username, locale, timezone -->

### Packages (pacman)
| Package | Purpose | Status |
|---------|---------|--------|
| gum | Interactive shell prompts; required by the sddm-astronaut-theme setup.sh | manual |

### AUR Packages
| Package | AUR Helper | Purpose | Status |
|---------|-----------|---------|--------|
|  |  |  | manual |

### Services Enabled
| Service | Command | Status |
|---------|---------|--------|
|  |  | manual |

---

## Phase 2 — Desktop (Wayland / Hyprland)

### Hyprland Config
<!-- Log: key config decisions, monitors, keybindings, window rules -->

### Waybar
<!-- Log: modules enabled, CSS changes -->

### Application Launcher (wofi / rofi-wayland)
<!-- Log: choice made and why, config -->

### Fonts
<!-- Log: fonts installed, nerd font variant -->

### Desktop Background
<!-- Log: tool used (hyprpaper / swaybg), images location -->

### Display / Monitor Layout
<!-- Log: monitor names (wlr-randr output), hyprland monitor config lines -->

### Screen Lock
<!-- Log: tool (swaylock / hyprlock), config -->

### Display Manager (SDDM)
- **Theme:** keyitdev/sddm-astronaut-theme, installed via its upstream setup script:
  ```bash
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/keyitdev/sddm-astronaut-theme/master/setup.sh)"
  ```
- The script clones the theme into `/usr/share/sddm/themes/sddm-astronaut-theme`, pulls Qt6
  dependencies (qt6-svg, qt6-virtualkeyboard, qt6-multimedia), and writes the active theme to
  `/etc/sddm.conf.d/` (e.g. `Current=sddm-astronaut-theme`).
- **Dependency:** requires `gum` (installed via pacman beforehand — see Packages table).
- **TODO / not yet done:** `sddm.service` is NOT enabled yet (`systemctl enable sddm` still pending).
- **Theme variant:** TBD — to be filled in once chosen from the setup.sh gum menu.
- **Ansible note:** prefer packaging the theme files into a dotfiles/role rather than re-running the
  remote `curl | bash` script; capture the chosen variant and the final `/etc/sddm.conf.d` config.

---

## Phase 3 — Terminal & Shell

### Terminal Emulator
<!-- Log: choice (kitty / alacritty / foot), config changes -->

### Zsh & Plugins
<!-- Log: plugin manager, plugins installed, .zshrc customizations -->

### Prompt (starship / p10k / etc.)
<!-- Log: theme/config used -->

---

## Phase 4 — Development Tools

### Neovim
<!-- Log: config approach (kickstart / own), plugins -->

### Git
<!-- Log: global config, credential helper, SSH key setup -->

### Claude Code
<!-- Log: install method, config -->

### Language Toolchains
| Language | Tool | Install Method | Status |
|----------|------|---------------|--------|
| Python | pyenv / uv | | manual |
| Java | sdkman / pacman | | manual |

---

## Phase 5 — Applications

### Brave Browser
<!-- Log: install method, sync setup -->

### Bitwarden
<!-- Log: install method (flatpak / AUR), setup -->

### File Manager
<!-- Log: choice (thunar / nemo / yazi), config -->

---

## Phase 6 — System Configuration

### Audio (Pipewire)
<!-- Log: packages, wireplumber config, volume keybindings -->

### Bluetooth
<!-- Log: packages, fastconnectable config -->

### Input Devices
<!-- Log: keyboard layout, caps/escape swap, touchpad config -->

### Fn Keys / Media Controls
<!-- Log: keybinding setup, wl-clipboard, brightnessctl, etc. -->

### Networking
<!-- Log: NetworkManager or iwd setup -->

---

## Phase 7 — Recovery & Backup

### File Transfer from Old System
<!-- Log: what was transferred, method (rsync / USB) -->

### Backup System
<!-- Log: tool (restic / borgbackup), remote target, schedule -->

---

## Decisions & Notes

| Date | Decision | Reason |
|------|----------|--------|
| 2026-06-01 | Switch from Fedora/i3 to Arch/Wayland | Full control, Hyprland ecosystem, fresh start |
| 2026-06-01 | Log-first workflow | Document manual steps before automating into Ansible |
| 2026-06-06 | SDDM theme via sddm-astronaut-theme | Customized graphical login greeter; installed through upstream setup.sh (needs gum) |
