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
| xorg-xrandr | Provides `xrandr`, needed by the SDDM X11 `Xsetup` greeter layout script (see Display Manager). Easy to forget — script fails silently with `xrandr: command not found` if missing | manual |

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
- **Theme variant:** `black_hole` — set via `ConfigFile=Themes/black_hole.conf` in
  `/usr/share/sddm/themes/sddm-astronaut-theme/metadata.desktop`.
- **Custom background (intentional):** the stock `Backgrounds/black_hole.png` was replaced with a
  personal ultrawide wallpaper (3440x1440). Full path:
  `/usr/share/sddm/themes/sddm-astronaut-theme/Backgrounds/black_hole.png`.
  This is referenced by `Background="Backgrounds/black_hole.png"` in `Themes/black_hole.conf`.
  Must be re-copied after the theme is (re)installed, otherwise a reinstall reverts to the stock image.
- **Ansible note:** prefer packaging the theme files into a dotfiles/role rather than re-running the
  remote `curl | bash` script. Capture: (1) variant = `black_hole` in `metadata.desktop`,
  (2) the final `/etc/sddm.conf.d` config (`Current=sddm-astronaut-theme`), and
  (3) the custom `black_hole.png` (store it in the repo and copy it over the theme's stock file).

#### Multi-monitor greeter resolution (X11 Xsetup)
- **Problem:** On the laptop + ultrawide setup, the SDDM greeter came up at a wrong/scaled
  resolution. SDDM runs on **X11** (`DisplayServer=x11` in `/usr/lib/sddm/sddm.conf.d/default.conf`)
  and doesn't know the monitor layout, so it fell back to a bad default.
- **Fix:** a root `Xsetup` script that runs `xrandr` before the greeter draws. Deployed to
  `/usr/share/sddm/scripts/Xsetup` (mode `755`). Script copy kept in repo at `ansible/files/sddm/Xsetup`.
- **Behaviour:** detects the ultrawide as the connected output advertising a native `3440x1440`
  mode, sets it primary at `3440x1440 +0+0`, and switches the laptop panel **off** so the login
  dialog isn't duplicated across both screens. Falls back to the laptop alone when no ultrawide.
- **X11 connector names differ from Wayland's** — laptop is `eDP` (Wayland `eDP-1`), ultrawide is
  `DisplayPort-0` (Wayland `DP-1`). Script detects names dynamically rather than hardcoding, so this
  mismatch doesn't bite. (Original attempt hardcoded `eDP-1`/`DP-1` and silently half-failed.)
- **Hard dependency:** `xorg-xrandr` (see Packages table). Without it the script errors with
  `xrandr: command not found` and the greeter stays broken.
- **Note:** `wlr-randr` cannot be used here — it needs a wlroots Wayland compositor; the greeter is
  X11, so `xrandr` is the correct tool for this layer.
- **Ansible steps to reproduce:** (1) `pacman -S xorg-xrandr`, (2) deploy `ansible/files/sddm/Xsetup`
  to `/usr/share/sddm/scripts/Xsetup` mode `0755`.

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

### Packages (pacman)
| Package | Purpose | Status |
|---------|---------|--------|
| lazygit | Terminal UI for git | manual — `pacman -S lazygit`, no custom config (defaults) |

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
| 2026-06-06 | SDDM variant = black_hole + custom wallpaper | Picked black_hole variant; deliberately overwrote its stock `Backgrounds/black_hole.png` with a personal 3440x1440 image — must be backed up to repo and re-applied on reinstall |
| 2026-06-06 | SDDM greeter laid out via X11 `Xsetup` + `xrandr` (not `wlr-randr`) | Greeter runs on X11; `wlr-randr` needs a wlroots Wayland compositor and can't drive it. `xrandr` is the right layer. Ultrawide set primary, laptop switched off to avoid a duplicated login dialog |
