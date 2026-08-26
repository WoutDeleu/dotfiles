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
| grim | Wayland screenshot capture (see Screenshots) | manual |
| slurp | Wayland region selector, piped into grim/satty (see Screenshots) | manual |
| satty | Screenshot annotation editor (see Screenshots) | manual |
| wl-clipboard | Provides `wl-copy`/`wl-paste`; clipboard output for screenshots | manual |
| cliphist | Wayland clipboard history manager — stores clipboard entries; needs watcher + picker to be useful (see Clipboard History) | manual — `pacman -S cliphist` |
| hyprpolkitagent | Polkit authentication agent for Hyprland — handles privilege escalation popups (e.g. sudo GUI prompts) | manual — `pacman -S hyprpolkitagent` |
| waybar | Status bar for Hyprland | manual — `pacman -S waybar` |
| btop | Resource monitor (CPU/mem/net/disk) | manual — `pacman -S btop`, default config |
| ruby | Ruby runtime — required by `get_weather.rb` waybar weather script | manual — `pacman -S ruby` |
| trash-cli | Moves files to `~/.local/share/Trash` instead of permanent deletion; used via `rm` alias | manual — `pacman -S trash-cli` |
| hyprlock | Hyprland-native lock screen — config at `~/.config/hypr/hyprlock.conf` | manual — `pacman -S hyprlock` |
| hypridle | Hyprland-native idle daemon — triggers lock/sleep/hibernate on inactivity; config at `~/.config/hypr/hypridle.conf` | manual — `pacman -S hypridle` |
| power-profiles-daemon | Power profile switching daemon (performance / balanced / power-saver); see Power Profile Management | manual — `pacman -S power-profiles-daemon` |
| vlc | Media player with broad codec support | manual — `pacman -S vlc` |
| onlyoffice-bin | Office suite (Writer/Calc/Impress) | manual — `pacman -S onlyoffice-bin` |
| zathura | Minimal PDF/document viewer | manual — `pacman -S zathura zathura-pdf-mupdf` |
| wlsunset | Blue light filter — time-based warm/cool color temperature; schedule 21:30–06:30; systemd user service in `systemd/` stow package | manual — `pacman -S wlsunset` |
| yt-dlp | YouTube/streaming site downloader — used as mpv backend for terminal streaming | manual — `pacman -S yt-dlp` |
| mpv-mpris | MPRIS plugin for mpv — exposes playerctl control over mpv playback; without this `playerctl` cannot see mpv | manual — `pacman -S mpv-mpris` |
| plymouth | Boot splash screen | manual — `pacman -S plymouth` |
| dmidecode | DMI/SMBIOS hardware info tool | manual — `pacman -S dmidecode` |
| cups | Common Unix Printing System | manual — `pacman -S cups` |
| cups-pdf | CUPS virtual PDF printer | manual — `pacman -S cups-pdf` |
| system-config-printer | GUI front-end for managing CUPS printers | manual — `pacman -S system-config-printer` |
| avahi | mDNS/DNS-SD service discovery — needed to auto-discover network printers (e.g. HP Envy 6430) | manual — `pacman -S avahi` |
| nss-mdns | NSS plugin for `.local` mDNS hostname resolution, works alongside avahi | manual — `pacman -S nss-mdns` |

### AUR Packages
| Package | AUR Helper | Purpose | Status |
|---------|-----------|---------|--------|
| logiops | yay | Logitech HID++ daemon (`logid`) — remaps MX Master 3 buttons/gestures (see Input Devices) | manual |
| ycal | yay | Google Calendar module for Waybar — client secret at `~/.config/waybar-ycal/client_secret.json` (gitignored, via stow), OAuth not yet configured | manual |
| swayosd-git | yay | Wayland OSD for volume/brightness — shows overlay bar on key/scroll change | manual — `yay -S swayosd-git` |
| spotify-player | yay | Terminal Spotify client with TUI | manual — `yay -S spotify-player` |

### Services Enabled
| Service | Command | Status |
|---------|---------|--------|
| logid | `systemctl enable --now logid` | MX Master 3 button remapping daemon (logiops) |
| hyprpolkitagent | `systemctl --user enable hyprpolkitagent` | Polkit agent for Hyprland — user-level service, starts on next login |
| cliphist | `systemctl --user enable --now cliphist` | Clipboard history watcher — unit file in `systemd/` stow package |
| waybar | `systemctl --user enable --now waybar` | Status bar — config in `waybar/` stow package |
| swayosd-server | run as user — `swayosd-server &` or via Hyprland `exec-once` | OSD display daemon |
| swayosd-libinput-backend | `sudo systemctl enable --now swayosd-libinput-backend` | **system** service — required for brightness control via libinput |
| wlsunset | `systemctl --user enable --now wlsunset` | Blue light filter — warm 3500K at 21:30, cool 6500K at 06:30 |
| cups.service | `sudo systemctl enable cups.service` | CUPS print service |
| cups.socket | `sudo systemctl enable cups.socket` | CUPS socket activation |
| avahi-daemon | `sudo systemctl enable --now avahi-daemon` | mDNS/DNS-SD discovery — required for network printer auto-discovery |

---

## Phase 2 — Desktop (Wayland / Hyprland)

### Hyprland Config
<!-- Log: key config decisions, monitors, keybindings, window rules -->

### Waybar
- **Install:** `pacman -S waybar`
- **Autostart:** `systemctl --user enable --now waybar` (user service)
- **Config:** in `waybar/` stow package.
- **Weather script:** `waybar/.config/waybar/scripts/weather/get_weather.rb` — requires `ruby` (`pacman -S ruby`). Script must be executable: committed to git with `git update-index --chmod=+x`; Ansible should use `file` module with `mode: '0755'`.
- **Ansible steps:** (1) `pacman -S waybar ruby`, (2) stow `waybar/`, (3) `systemctl --user enable waybar`, (4) ensure `get_weather.rb` is `+x`.

### Application Launcher (wofi / rofi-wayland)
<!-- Log: choice made and why, config -->

### Fonts
<!-- Log: fonts installed, nerd font variant -->

### Desktop Background
- **Tool:** `hyprpaper` (already installed; pacman package `hyprpaper`).
- **Config:** `hyprland/.config/hypr/hyprpaper.conf` (dotfile, symlinked via the folded
  `~/.config/hypr -> dotfiles/hyprland/.config/hypr` stow link). Uses the block syntax:
  ```
  wallpaper {
      monitor =
      path = ~/.config/hypr/Wallpapers/dune_wallpaper.png
      fit_mode = cover
  }
  ```
  Empty `monitor =` = wildcard, applies to all outputs. `fit_mode = cover` scales/crops to fill.
- **Autostart:** added `exec-once = hyprpaper` to `hyprland/.config/hypr/hyprland.conf`.
- **Images location:** `~/.config/hypr/Wallpapers/` (dune_wallpaper variants), now committed inside the
  `hyprland/` stow package so the wallpaper survives a clean reinstall (moved out of `~/Pictures/Wallpapers/`).
- **Gotcha (cost real time):** the old inline syntax `wallpaper = , <path>` silently fails —
  hyprpaper logs `Monitor <name> has no target: no wp will be created` and shows no wallpaper.
  A space after the comma gets parsed into the path. Use the `wallpaper { ... }` block instead.
- **Ansible steps:** (1) `pacman -S hyprpaper`, (2) deploy `hyprpaper.conf` + the `exec-once` line,
  (3) place wallpaper images under `~/Pictures/Wallpapers/`.
- **Reload after edits:** `killall hyprpaper && hyprpaper`.

### GTK Theme (dark mode)
- **Theme:** Catppuccin GTK (dark variant), installed from source (not AUR/pacman).
- **Install:**
  ```bash
  git clone https://github.com/Fausto-Korpsvart/Catppuccin-GTK-Theme.git
  cd Catppuccin-GTK-Theme/themes
  ./install.sh -m dark -l
  ```
  `-m dark` restricts installation to the dark variant (skips the interactive light/dark prompt).
  `-l` links the installed GTK4 theme into the libadwaita config folder so GTK4/libadwaita apps
  (e.g. Nautilus-style GNOME4 apps) pick it up too. Default accent color used (no `-a` flag).
- **Requires:** `gnome-themes-extra`, `gsettings-desktop-schemas` (for `gsettings`/Adwaita fallback support).
- **Apply globally:**
  ```bash
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
  gsettings set org.gnome.desktop.interface gtk-theme '<generated-theme-name>'
  ```
  Exact `gtk-theme` name depends on install flags — check `~/.themes/` for the generated folder name
  (e.g. `Catppuccin-Mocha-Standard-<Accent>-Dark`).
- **Per-app dark mode config (GTK3/GTK4 fallback, covers apps that ignore gsettings):**
  ```bash
  mkdir -p ~/.config/gtk-3.0 ~/.config/gtk-4.0
  # ~/.config/gtk-3.0/settings.ini
  [Settings]
  gtk-theme-name=<generated-theme-name>
  gtk-application-prefer-dark-theme=1
  # ~/.config/gtk-4.0/settings.ini
  [Settings]
  gtk-application-prefer-dark-theme=1
  ```
- **Per-app launcher override (e.g. system-config-printer not honoring gsettings via drun):**
  copy the app's `.desktop` file to `~/.local/share/applications/`, prefix `Exec=` with
  `env GTK_THEME=<generated-theme-name>`, then `update-desktop-database ~/.local/share/applications`.
- **Ansible steps:** (1) `pacman -S gnome-themes-extra gsettings-desktop-schemas`, (2) clone +
  run `install.sh -m dark -l` (idempotency TODO — script re-installs on rerun, may need a guard),
  (3) deploy `gtk-3.0`/`gtk-4.0` `settings.ini` as dotfiles, (4) set `gsettings` via `exec-once` in
  Hyprland config.

### Cursor Theme
- **Theme:** `Bibata-Modern-Amber` (rounded, amber variant), size `24`.
- **Install:** AUR package `bibata-cursor-theme` (via AUR helper, e.g. `yay -S bibata-cursor-theme`).
  Installs system-wide to `/usr/share/icons/Bibata-Modern-Amber/` — no manual move into
  `~/.local/share/icons` needed when installed this way.
- **Apply (GTK / Wayland apps):**
  ```bash
  gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Amber'
  gsettings set org.gnome.desktop.interface cursor-size 24
  ```
- **Apply (Hyprland):** add to `hyprland/.config/hypr/hyprland.conf`:
  ```
  env = XCURSOR_THEME,Bibata-Modern-Amber
  env = XCURSOR_SIZE,24
  ```
  Live-apply without relogin: `hyprctl setcursor Bibata-Modern-Amber 24`.
- **Ansible steps:** (1) install AUR package `bibata-cursor-theme`, (2) deploy the two `env` lines in
  `hyprland.conf`, (3) run the two `gsettings set` commands (or manage via a dconf/gsettings task).

### Display / Monitor Layout
<!-- Log: monitor names (wlr-randr output), hyprland monitor config lines -->

### Screenshots
- **Stack:** `grim` (capture) + `slurp` (region select) + `satty` (annotation editor).
  Wayland-native; chosen over Flameshot (flaky on Hyprland, no recording) and the bundled
  rofi `screenshot.sh` applet (X11-only: maim/xclip/xdotool — does not work on Wayland).
- **Config (dotfile):** `hyprland/.config/hypr/screenshots.conf`, sourced from `hyprland.conf`.
  Clipboard-only by design — nothing is written to disk.
  - `Print` → region select → straight to clipboard (`grim -g "$(slurp)" - | wl-copy`)
  - `CTRL+Print` → region select → annotate in satty → clipboard
    (`grim -g "$(slurp)" - | satty --filename - --early-exit --copy-command wl-copy`)
- **Dependency:** `wl-copy` (from `wl-clipboard`) for clipboard output.
- **Gotcha:** an earlier version did `mkdir -p ~/Pictures/Screenshots` and saved files;
  reverted to clipboard-only. Don't reintroduce the save dir unless saving is wanted.
- **Recording:** `wf-recorder` is installed but intentionally NOT configured yet
  (deferred — will set up a rofi toggle applet if/when needed).
- **Ansible steps:** (1) `pacman -S grim slurp satty wl-clipboard`,
  (2) deploy `screenshots.conf` + the `source` line in `hyprland.conf`.

### Clipboard History
- **Tool:** `cliphist` — `pacman -S cliphist` (depends on `wl-clipboard`, already installed).
- **How it works:** `wl-paste` watches the clipboard and pipes every copy event into `cliphist store`. History is queried via `cliphist list` and decoded with `cliphist decode | wl-copy`.
- **Daemon:** managed as a systemd user service (not `exec-once`) — unit file at `systemd/.config/systemd/user/cliphist.service` (stow package `systemd/`).
  - Enable: `systemctl --user enable --now cliphist`
  - Stow: `cd dotfiles && stow systemd`
- **Still needed:**
  - [ ] Choose a picker (`wofi`, `rofi-wayland`, or `fuzzel`) and add keybinding, e.g.:
    ```
    bind = $mainMod, V, exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy
    ```
- **Ansible steps:** (1) `pacman -S cliphist`, (2) stow `systemd/`, (3) `systemctl --user enable --now cliphist`, (4) add keybind to dotfiles.

### Screen Lock
- **Tool:** `hyprlock` (Hyprland-native) + `hypridle` (idle daemon) — `pacman -S hyprlock hypridle`
- **Autostart:** `exec-once = hypridle` in `hyprland/.config/hypr/hyprland.conf`
- **hypridle config** (`hyprland/.config/hypr/hypridle.conf`, stow package `hyprland/`):
  - 5 min idle → `loginctl lock-session` (lock)
  - 10 min idle → `hyprctl dispatch dpms off` (screen off); resumes on activity
  - 30 min idle → `systemctl suspend` (sleep)
  - 60 min idle → `systemctl hibernate`
  - `before_sleep_cmd = loginctl lock-session` — always locks before sleep/hibernate
- **hyprlock config** (`hyprland/.config/hypr/hyprlock.conf`): blurred screenshot background, centered password input field
- **Manual lock:** `loginctl lock-session` (or bind a key in `keybindings.conf`)
- **Ansible steps:** (1) `pacman -S hyprlock hypridle`, (2) stow `hyprland/` (deploys both configs + `exec-once` line)

### Power Profile Management
- **Daemon:** `power-profiles-daemon` — `pacman -S power-profiles-daemon`; enable: `systemctl enable --now power-profiles-daemon`.
- **Profiles:** `performance`, `balanced` (default), `power-saver`. Switch with `powerprofilesctl set <profile>`.
- **Auto-switching (udev rule):** `systemd/etc/udev/rules.d/80-power-profiles.rules` (stow package `systemd/`).
  - AC plugged in (`ACAD` online=1) → `balanced`
  - AC unplugged (`ACAD` online=0) → `power-saver`
  - Uses `systemd-run --no-block` so `powerprofilesctl` can reach the system D-Bus from udev context.
  - **Machine-specific:** AC adapter kernel name is `ACAD` on this laptop — verify with `ls /sys/class/power_supply/` on a different machine.
  - Deploy: `sudo cp ... /etc/udev/rules.d/80-power-profiles.rules && sudo udevadm control --reload-rules`
- **Waybar module:** built-in `power-profiles-daemon` module — added to `group/indicators` in `waybar/` stow package. Click cycles through profiles. Icons: `󱐋` performance, `󰗑` balanced, `󰌪` power-saver.
- **Ansible steps:** (1) `pacman -S power-profiles-daemon`, (2) `systemctl enable power-profiles-daemon`, (3) deploy udev rule from `ansible/files/` or via stow, (4) stow `waybar/`.


### Notifications (swaync)
- **Tool:** `swaync` (SwayNotificationCenter) — `pacman -S swaync` (0.12.6).
- **Autostart:** `exec-once = swaync` in `hyprland/.config/hypr/notifications.conf`
  (sourced by `hyprland.conf`).
- **Config (dotfiles, stow package `swaync/`):**
  - `swaync/.config/swaync/config.json` — panel top-right; timeouts balanced
    (normal 10s, low 5s, critical never auto-dismiss); widgets: title (+Clear All),
    DND toggle, MPRIS, volume slider, backlight slider, notifications; grouping on.
  - `swaync/.config/swaync/style.css` — themed to match Hyprland (navy `#0a1726`,
    orange accent `#ff7800`, JetBrainsMono Nerd Font, rounded 10).
  - `backlight` widget pinned to device `amdgpu_bl1` (from `/sys/class/backlight/`);
    **machine-specific — re-detect on a different GPU/laptop.**
- **Keybindings** (`keybindings.conf`): `SUPER+SHIFT+N` toggle panel
  (`swaync-client -t -sw`), `SUPER+N` toggle DND (`swaync-client -d -sw`).
  Note: these use literal **SUPER**, not `$mainMod` (which is ALT here).
- **Reload after edits:** `swaync-client -rs` (reloads css + config, no restart).
- **Ansible steps:** (1) `pacman -S swaync`, (2) deploy the `swaync/` dotfiles +
  the `exec-once` line, (3) fix the `backlight.device` per machine.

### Display Manager (SDDM)
- **Theme:** keyitdev/sddm-astronaut-theme, installed via its upstream setup script:
  ```bash
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/keyitdev/sddm-astronaut-theme/master/setup.sh)"
  ```
- The script clones the theme into `/usr/share/sddm/themes/sddm-astronaut-theme`, pulls Qt6
  dependencies (qt6-svg, qt6-virtualkeyboard, qt6-multimedia), and writes the active theme to
  `/etc/sddm.conf.d/` (e.g. `Current=sddm-astronaut-theme`).
- **Dependency:** requires `gum` (installed via pacman beforehand — see Packages table).
- **TODO / not yet done:** ~~`sddm.service` is NOT enabled yet (`systemctl enable sddm` still pending).~~ ✅ Added to Ansible playbook.
- **Theme variant:** `black_hole` — set via `ConfigFile=Themes/black_hole.conf` in
  `/usr/share/sddm/themes/sddm-astronaut-theme/metadata.desktop`.
- **Custom background (intentional):** the stock `Backgrounds/black_hole.png` was replaced with a
  personal ultrawide wallpaper (3440x1440). Full path:
  `/usr/share/sddm/themes/sddm-astronaut-theme/Backgrounds/black_hole.png`.
  This is referenced by `Background="Backgrounds/black_hole.png"` in `Themes/black_hole.conf`.
  ✅ Custom image stored in repo at `ansible/files/sddm/black_hole.png` — deployed by Ansible after theme clone.
- **Ansible:** fully automated — git clone theme, Qt6 deps, deploy `sddm.conf`, `virtualkbd.conf`, `Xsetup`, and custom wallpaper.

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

#### Safe delete aliases
- `alias rm='trash-put'` — redirects `rm` to trash instead of permanent delete. Requires `trash-cli` (`pacman -S trash-cli`).
- `alias rmf='/usr/bin/rm'` — escape hatch for real permanent deletion when needed.
- Restore files: `trash-restore`; list: `trash-list`; empty bin: `trash-empty`.
- **Ansible steps:** (1) `pacman -S trash-cli`, (2) aliases are in `zsh/.zshrc` (deployed via stow).

#### Secrets handling
- **Pattern:** API keys / secrets are kept OUT of the tracked `.zshrc`. Real values live in a
  machine-local **folder** `~/.config/secrets/` (dir mode `700`, files mode `600`), one file per
  category (e.g. `ai.zsh`). `.zshrc` sources the whole folder:
  `for _secret in "$HOME"/.config/secrets/*.zsh(N); do source "$_secret"; done`.
- **Template:** committed at `zsh/secrets.example/ai.zsh`. The `zsh/` stow package carries a
  `.stow-local-ignore` (`secrets\.example`) so the template is NOT symlinked into `$HOME`.
- **Gitignore:** repo-root `.gitignore` excludes `*_secrets`, `*.secret`, `.zsh_secrets`, and
  vault-password files. The real `~/.config/secrets/` lives outside the repo entirely, so it can't
  be tracked by accident.
- **Currently held:** `~/.config/secrets/ai.zsh` → `ANTHROPIC_BASE_URL`, `ANTHROPIC_API_KEY`
  (axxes bridge).
- **History:** replaced the earlier single flat file `~/.zsh_secrets` (+ `zsh/.zsh_secrets.example`)
  with this per-category folder on 2026-06-09.
- **⚠️ TODO — migrate to Ansible Vault:** `~/.config/secrets/` is machine-local only, so it does NOT
  survive a clean reinstall. Encrypt these with `ansible-vault` and have the playbook decrypt +
  deploy them on setup, so secrets are part of the recoverable backup (encrypted) instead of being
  manually recreated. See the **Ansible Secrets Checklist** (Phase 7).

#### fzf
- **Tool:** `fzf` — fuzzy finder. `pacman -S fzf` (official repo).
- **Shell integration (done):** `.zshrc` sources fzf's zsh keybindings + completion via
  `command -v fzf >/dev/null && source <(fzf --zsh)`. Gives `CTRL-R` history search,
  `CTRL-T` file picker, `ALT-C` cd-into-dir. (`fzf --zsh` requires fzf ≥ 0.48; running 0.72.)
- **Ansible steps:** (1) `pacman -S fzf`, (2) deploy the `source <(fzf --zsh)` line as part of
  the `zsh/` dotfiles (already in `zsh/.zshrc`).

#### bat (cat replacement)
- **Tool:** `bat` — `cat` clone with syntax highlighting. `pacman -S bat` (official repo).
- **Alias (in `zsh/.zshrc`):** `alias cat="bat --paging=never"` — drop-in replacement that
  never invokes a pager. Scripts/pipes are unaffected (aliases don't apply in non-interactive
  shells), so the real `cat` is still used there.
- **Ansible steps:** (1) `pacman -S bat`, (2) the alias ships with the `zsh/` dotfiles.

### Prompt (starship / p10k / etc.)
- **Tool:** Powerlevel10k (p10k) — zsh prompt theme.
- **Config:** `~/.p10k.zsh` is now part of the `zsh/` stow package
  (`zsh/.p10k.zsh`, symlinked to `~/.p10k.zsh`). Sourced by `.zshrc` via
  `[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh`.
- **Gotcha:** the config was previously a plain file in `$HOME` (not tracked) —
  would have been lost on a clean reinstall. Now committed alongside `.zshrc`.
- **Ansible steps:** deploy `zsh/.p10k.zsh` with the rest of the `zsh/` dotfiles
  (the p10k *engine* itself comes from the plugin manager / `zsh-theme-powerlevel10k`).

---

## Phase 4 — Development Tools

### Packages (pacman)
| Package | Purpose | Status |
|---------|---------|--------|
| lazygit | Terminal UI for git | manual — `pacman -S lazygit`, no custom config (defaults) |
| docker | Container runtime (daemon + CLI) | manual — `pacman -S docker`; see Docker |
| docker-compose | Multi-container orchestration (`docker compose`) | manual — `pacman -S docker-compose` |
| lazydocker | Terminal UI for Docker/compose | manual — `pacman -S lazydocker`, no custom config (defaults) |

### Docker
- **Install:** `pacman -S docker docker-compose lazydocker` (all official repos).
- **Service:** `sudo systemctl enable --now docker` — daemon enabled on boot.
- **User group:** `sudo usermod -aG docker $USER` — run docker without sudo. **Requires re-login** to take effect. Easy to forget on a clean install — docker commands fail with a permission error until then.
- **Ansible steps:** (1) `pacman -S docker docker-compose lazydocker`, (2) `service`/`systemd` module enable + start `docker`, (3) `user` module add to `docker` group.

### Neovim

#### Plugin Manager — packer.nvim

| Package | AUR Helper | Status |
|---------|-----------|--------|
| `nvim-packer-git` | yay | ✅ installed |

```bash
yay -S nvim-packer-git
```

**Note:** `nvim-packer-git` installs packer into the Neovim data path (`~/.local/share/nvim/site/pack/packer`). On a clean install, run `yay -S nvim-packer-git` before launching Neovim, then open nvim and run `:PackerSync` to install declared plugins.

### Git
<!-- Log: global config, credential helper, SSH key setup -->

### SSH
- **Config via stow:** `~/.ssh/config` is a symlink into the `ssh/` stow package
  (`ssh/.ssh/config`). Because `~/.ssh` already exists (holds the keys), stow links only the
  `config` file and leaves everything else as real local files.
- **Keys are NEVER tracked:** repo-root `.gitignore` has `ssh/.ssh/*` + `!ssh/.ssh/config`, so only
  `config` can ever be committed — private keys / `known_hosts` are excluded even if copied in.
- **Current keys (machine-local, mode `600`):** `~/.ssh/arrakis` (+`.pub`) for host `arrakis`,
  `~/.ssh/tailscale` (+`.pub`) for the Tailscale homelab/VPS host (root@192.168.129.34),
  `~/.ssh/id_ed25519` (+`.pub`). These must be restored from the encrypted backup (see Ansible
  Secrets Checklist) on a clean install.
- **`tailscale` SSH host:** alias for the Tailscale IP of the homelab/VPS (`192.168.129.34`, user
  `root`). The `tailscale` package itself is **not yet automated** — must be installed (`pacman -S
  tailscale`) and `tailscaled` enabled/started (`systemctl enable --now tailscaled`), then
  authenticated (`tailscale up`) manually on a new machine until an Ansible task is added.
- **Ansible steps:** (1) `stow ssh` to deploy `~/.ssh/config`; (2) vault-decrypt the private keys
  into `~/.ssh/` with mode `0600` (dir `0700`); (3) TODO: add `tailscale` package + service to
  Ansible (see open task).

### Claude Code
<!-- Log: install method, config -->

### Language Toolchains

**Tool:** [mise](https://mise.jdx.dev/) — single multi-language version manager (replaces sdkman, pyenv)

| Package | Install Method | Status |
|---------|---------------|--------|
| `mise` | `curl https://mise.run \| sh` | ✅ installed |

- Shell hook added to `~/.zshrc`: `eval "$(~/.local/bin/mise activate zsh)"`
- Global versions stored in `~/.config/mise/config.toml` (stow package: `mise/`)
- Per-project versions via `.mise.toml` in project root
- **Ansible steps:** (1) install via curl installer, (2) stow `mise/`, (3) `mise install` to pull toolchains

| Language | Tool managed by mise | Global version |
|----------|---------------------|---------------|
| Python | `mise use --global python@x.y` | 3.14.6 |
| Java | `mise use --global java@temurin-x` | temurin-25.0.3 |
| Maven | `mise use --global maven@x.y.z` | 3.9.16 |

---

## Phase 5 — Applications

### Bitwarden

| Package | Install Method | Status |
|---------|---------------|--------|
| `bitwarden` | pacman | ✅ installed |

**Ansible steps:** `pacman -S bitwarden`

**Hyprland:** window rule to always open floating + centered (see `windowrules.conf`).

### Browser — Helium (replaces Brave)

| Package | Install Method | Status |
|---------|---------------|--------|
| `helium-browser-bin` | AUR (`yay`) | ✅ installed |
| `brave` | — | ❌ do **not** install on new setups |

**Rationale:** Helium supports installing PWAs (e.g. Google Calendar, Gmail) as standalone app windows. Brave is kept on current machine temporarily but should not be installed on new setups.

**Ansible steps:** `yay -S helium-browser-bin` (do not include `brave` in package list)

### File Manager
<!-- Log: choice (thunar / nemo / yazi), config -->

### Microsoft Teams (`teams-for-linux`)

| Package | Install Method | Status |
|---------|---------------|--------|
| `teams-for-linux` | AUR (`yay`) | ✅ installed |

**Config:** `~/.config/teams-for-linux/config.json` (stow: `teams`)

Key settings applied:
- `trayIconEnabled: false` — no tray icon
- `closeAppOnCross: true` — X button closes the app
- `appIdleTimeout: 3000` / `appIdleTimeoutCheckInterval: 300` — idle detection tuning
- `multiAccount.enabled: true` — multi-account support enabled
- `screenSharing.thumbnail.enabled: true` / `alwaysOnTop: true` — screen sharing thumbnail

**Profile:** one account configured via `settings.json` (stow package includes this file).

**TODO:** further configuration needed — see GitHub ticket for multi-account polish, screen sharing, calls, and Wayland/Hyprland-specific tuning.

### Office Suite — OnlyOffice (replaces OpenOffice)

| Package | Install Method | Status |
|---------|---------------|--------|
| `onlyoffice-bin` | AUR (`yay`) | ✅ installed |
| `openoffice-bin` | — | ❌ do **not** install on new setups |

**Rationale:** Replaced OpenOffice with OnlyOffice — preferred UI.

**Ansible steps:** `yay -S onlyoffice-bin` (do not include `openoffice-bin` in package list)

### Email — aerc (Gmail via IMAP)

| Package | Install Method | Status |
|---------|---------------|--------|
| `aerc` | pacman | ✅ installed |
| `chafa` | pacman — `pacman -S chafa` | ✅ installed — terminal image renderer used by aerc `[filters]` image/* |

**Config:** `~/.config/aerc/` — stow package `aerc/`
- `aerc.conf` + `binds.conf` → stowed (symlinked)
- `accounts.conf` → **not stowed** (references secrets; machine-local)
- `gmail.gpg` → **not stowed** (encrypted secret; machine-local)
- `accounts.conf.example` → stowed (safe template, no secrets)

**Gmail setup:**
- Uses IMAP/SMTPS (TLS encrypted in transit)
- Auth via **Gmail App Password** (not regular password — Google blocks plain passwords for IMAP)
  - Generate at: [myaccount.google.com/apppasswords](https://myaccount.google.com/apppasswords) (requires 2FA)
  - Remove spaces from the 16-char password before use
- App password stored **GPG-encrypted** at `~/.config/aerc/gmail.gpg` (never plaintext on disk)

**GPG key setup** (run once on new machine):
```bash
gpg --batch --gen-key <<EOF
%no-protection
Key-Type: EdDSA
Key-Curve: ed25519
Subkey-Type: ECDH
Subkey-Curve: cv25519
Name-Real: Wout Deleu
Name-Email: wout.deleu@gmail.com
Expire-Date: 0
%commit
EOF

# Encrypt the app password (replace APP_PASSWORD with actual value from vault/secret)
echo -n "APP_PASSWORD" | gpg --encrypt -r wout.deleu@gmail.com --output ~/.config/aerc/gmail.gpg
```

**accounts.conf:**
```ini
[Personal]
source            = imaps://wout.deleu%40gmail.com@imap.gmail.com:993
outgoing          = smtps://wout.deleu%40gmail.com@smtp.gmail.com:465
source-cred-cmd   = gpg --quiet --decrypt ~/.config/aerc/gmail.gpg
outgoing-cred-cmd = gpg --quiet --decrypt ~/.config/aerc/gmail.gpg
default           = INBOX
from              = Wout Deleu <wout.deleu@gmail.com>
cache-headers     = true
```

**Ansible steps:**
1. `pacman -S aerc`
2. `cd ~/dotfiles && stow aerc` (links `aerc.conf`, `binds.conf`, `accounts.conf.example`)
3. Create GPG key (batch, no passphrase)
4. Retrieve app password from Ansible Vault, encrypt with GPG → `~/.config/aerc/gmail.gpg`
5. Deploy `accounts.conf` from template (fill in email; password stays GPG-encrypted)

### Email — aerc (Work accounts: Microsoft 365 via OAuth2)

Two work mailboxes on **Microsoft 365 / Exchange Online** — Axxes (`wout.deleu@axxes.com`)
and VRT (`wout.deleu@vrt.be`). M365 has **basic password auth disabled**, so these require
**OAuth2 (XOAUTH2)** via a token helper, unlike the Gmail account which uses an app password.

| Package | Install Method | Status |
|---------|---------------|--------|
| `mutt_oauth2.py` | manual — muttmua contrib script → `~/.local/bin/mutt_oauth2.py` (chmod +x) | ✅ installed |

**Source:** `https://raw.githubusercontent.com/muttmua/mutt/master/contrib/mutt_oauth2.py`

**Script edits required** (the muttmua 2020 version has no CLI flags — everything is baked in):
- `ENCRYPTION_PIPE` recipient → `wout.deleu@gmail.com` (must be a GPG key you actually hold;
  reuses the same ed25519 key as the Gmail app-password setup). `DECRYPTION_PIPE` left as `gpg --decrypt`.
- `registrations['microsoft']['client_id']` → `9e5f94bc-e8a4-4e73-b8be-63364c29d753`
  (Thunderbird's public app registration; client_secret stays empty).
- Ships with empty `client_id` → server returns `AADSTS900144: must contain 'client_id'` until set.

**Token generation** (run once per account; token file is GPG-encrypted, mode 0600):
```bash
export GPG_TTY=$(tty)   # required or gpg pipe can't prompt → "Difficulty decrypting token file"
mutt_oauth2.py ~/.config/aerc/axxes.token --verbose --authorize   # microsoft / devicecode / wout.deleu@axxes.com
mutt_oauth2.py ~/.config/aerc/vrt.token   --verbose --authorize   # microsoft / devicecode / wout.deleu@vrt.be
# verify:
mutt_oauth2.py ~/.config/aerc/<acct>.token --verbose --test       # expect IMAP/POP/SMTP auth succeeded
```
Flow prompts: registration `microsoft`, flow `devicecode` (headless URL+code), then the email.

**accounts.conf** (M365 blocks — auth mechanism goes in the **URL scheme**, not a separate key):
```ini
[Axxes]
source            = imaps+xoauth2://wout.deleu%40axxes.com@outlook.office365.com:993
source-cred-cmd   = ~/.local/bin/mutt_oauth2.py ~/.config/aerc/axxes.token
outgoing          = smtp+xoauth2://wout.deleu%40axxes.com@smtp.office365.com:587
outgoing-cred-cmd = ~/.local/bin/mutt_oauth2.py ~/.config/aerc/axxes.token
from              = Wout Deleu <wout.deleu@axxes.com>
copy-to           = Sent

[VRT]
source            = imaps+xoauth2://wout.deleu%40vrt.be@outlook.office365.com:993
source-cred-cmd   = ~/.local/bin/mutt_oauth2.py ~/.config/aerc/vrt.token
outgoing          = smtp+xoauth2://wout.deleu%40vrt.be@smtp.office365.com:587
outgoing-cred-cmd = ~/.local/bin/mutt_oauth2.py ~/.config/aerc/vrt.token
from              = Wout Deleu <wout.deleu@vrt.be>
copy-to           = Sent
```
Notes:
- Servers: IMAP `outlook.office365.com:993`, SMTP `smtp.office365.com:587` (STARTTLS → scheme `smtp+`, not `smtps`).
- `@` in username must be URL-encoded as `%40`.
- `.token` files are machine-local secrets → **not stowed** (like `gmail.gpg` / `accounts.conf`).
- If a tenant blocks the public Thunderbird app (`AADSTS65001` / "need admin approval"), IT must
  register an app with delegated `IMAP.AccessAsUser.All`, `SMTP.Send`, `offline_access`.

**Image rendering (`[filters]` in aerc.conf):** the shipped `image/*` filter used `magick convert`
(deprecated in ImageMagick 7) whose stderr warning corrupted the bytes piped to kitty `icat`. Bigger
issue: aerc renders filter output through its own **text-cell UI**, which does **not** pass terminal
graphics-protocol escapes — so kitty (`\e_G…`) or sixel (`\eP…`) output shows up as a literal "string
of letters". Only **chafa symbols mode** (Unicode block art = plain SGR color cells) renders inside aerc:
```ini
image/*=chafa -f symbols -s "$(tput cols)x$(tput lines)" --animate off -
```
Requires `pacman -S chafa`. Currently kept **commented out** in `aerc.conf` (left disabled by choice);
uncomment the line above to enable. Alternative for pixel-perfect images: the old `kitty +kitten icat`
one-liner writes straight to the terminal (bypassing aerc's UI) but is finicky (fixed placement, scroll
artifacts).

**Ansible steps (work accounts):**
1. Download `mutt_oauth2.py` → `~/.local/bin/`, chmod +x
2. Patch script: set `ENCRYPTION_PIPE` recipient + microsoft `client_id` (idempotent sed/lineinfile)
3. `pacman -S chafa`; set the `image/*` chafa filter in `aerc.conf`
4. Per account, run `--authorize` (devicecode, interactive — one-time, browser login) → `~/.config/aerc/<acct>.token`
5. Deploy `[Axxes]`/`[VRT]` blocks into machine-local `accounts.conf`

### Stremio

| Package | Install Method | Status |
|---------|---------------|--------|
| `flatpak` | pacman | ✅ installed |
| `com.stremio.Stremio` | Flatpak (Flathub) | ✅ installed |

**Rationale:** No working pacman or AUR package found for Stremio — Flatpak was the only viable option.

**Setup steps:**
```bash
pacman -S flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install flathub com.stremio.Stremio
```

**Ansible steps:**
1. `pacman -S flatpak`
2. Add Flathub remote: `flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo`
3. `flatpak install -y flathub com.stremio.Stremio`

---

## Phase 6 — System Configuration

### Audio (PipeWire)
Full PipeWire stack installed — replaces PulseAudio entirely.

| Package | Purpose | Status |
|---------|---------|--------|
| `pipewire` | Core audio/video router | installed |
| `pipewire-audio` | Audio support | installed |
| `pipewire-alsa` | Routes ALSA apps through PipeWire | installed |
| `pipewire-pulse` | Drop-in PulseAudio emulation (pavucontrol etc. work via this) | installed |
| `wireplumber` | Session/policy manager | manual — `pacman -S wireplumber`, `systemctl --user enable --now wireplumber` |
| `alsa-utils` | CLI tools (`alsamixer`, `aplay`) — useful for debugging | manual — `pacman -S alsa-utils` |
| `pulsemixer` | TUI mixer — per-app volume + output selection | manual — `pacman -S pulsemixer` |

- `pulseaudio` is **not** installed — correctly replaced by `pipewire-pulse`
- Use `pulsemixer` for TUI volume/output switching — works via `pipewire-pulse`; bound to waybar audio click
- Use `wpctl status` / `wpctl set-default <ID>` for CLI output switching

### Bluetooth
| Package | Purpose | Status |
|---------|---------|--------|
| `bluetui` | TUI Bluetooth client — keyboard-driven, AUR | manual — `yay -S bluetui` |

- `blueman` was tried and uninstalled — using `bluetui` only
- Enable service: `sudo systemctl enable --now bluetooth`

### Input Devices

#### Keyboard modifiers (NuPhy Halo65, macOS mode)
- **Goal:** `$mainMod = SUPER` everywhere. Laptop Win key = Super natively. The external
  NuPhy Halo65 stays physically in **macOS mode** (Opt→Alt, Cmd→Super), so its main-mod key
  would be wrong.
- **Fix:** per-device `kb_options` in `hyprland/.config/hypr/hyprland.conf` swaps left Alt↔Win
  on that keyboard only, so **Opt acts as SUPER** (and Cmd becomes Alt):
  ```
  device {
      name = nuphy-halo65-v2-2-keyboard
      kb_options = caps:escape,escape:caps,altwin:swap_lalt_lwin
  }
  ```
  Per-device `kb_options` fully override the global `input { kb_options }`, so the caps/escape
  swap is repeated here. Device name comes from `hyprctl devices`.

#### MX Master 3 — thumb button as $mainMod (logiops)
- **Goal:** hold the **thumb gesture button** + roll the **normal scroll wheel** → cycle workspaces.
- **Why logiops:** Hyprland bind modifiers are keyboard-only — a mouse button can't be a held
  modifier in a native `bind`. logiops (`logid` daemon) remaps at the device level.
- **Mechanism:** map the thumb gesture button (`cid: 0xc3`) to a `Keypress` of the current
  `$mainMod`. logiops holds the key while the button is held, so thumb-button + scroll =
  `$mainMod`+scroll, which hits the existing Hyprland bind
  `bind = $mainMod, mouse_down/up, workspace, e+1/e-1` (in `workspaces.conf`).
  No Hyprland change needed beyond that bind.
- **Key must match `$mainMod`:** `$mainMod = ALT` → emit `KEY_LEFTALT`. If `$mainMod` ever
  becomes SUPER, change the key to `KEY_LEFTMETA`.
- **Install:** `yay -S logiops` (AUR).
- **Config:** committed at **`ansible/files/logid.cfg`**, deploys to `/etc/logid.cfg`
  (root-owned, NOT a stow dotfile). The thumb button (`cid: 0xc3`) → `Keypress KEY_LEFTALT`.
- **Enable:** `sudo systemctl enable --now logid`. Restart after edits: `sudo systemctl restart logid`.
- **Gotcha:** the device `name:` must match exactly what `sudo logid -v` prints (may differ from
  Hyprland's `hyprctl devices` label). Wrong name = daemon ignores the mouse silently.
- **Ansible steps:** (1) `yay -S logiops`, (2) copy `ansible/files/logid.cfg` → `/etc/logid.cfg`,
  (3) `systemctl enable --now logid`.

#### SwayOSD caps-lock indicator suppression
- **Symptom:** caps lock kept showing a popup even though caps is rebound to escape (`caps:escape`).
- **Root cause:** `swayosd-libinput-backend` is a **system** service running as **root**, so it reads
  `/etc/xdg/swayosd/backend.toml` — **NOT** the user `~/.config/swayosd/backend.toml` (the `swayosd/`
  stow package). The user config's `ignore_caps_lock_key = true` was silently ignored.
- **Fix:** set `ignore_caps_lock_key = true` in the **root-owned** `/etc/xdg/swayosd/backend.toml`, then
  `sudo systemctl restart swayosd-libinput-backend.service`.
- **Note:** there is intentionally **no** user-level `~/.config/swayosd/backend.toml` — the libinput
  backend ignores it, so it was removed to avoid confusion. Only `style.css` stays in the `swayosd/`
  stow package (user-level, fine).
- **Ansible steps:** deploy `backend.toml` to `/etc/xdg/swayosd/backend.toml` as a root-owned file (same
  pattern as `logid.cfg` → `/etc/logid.cfg`, NOT a stow dotfile), then restart the backend service.

### Fn Keys / Media Controls
- **Media keys** (`XF86AudioPlay/Pause/Next/Prev`) bound in `hyprland/.config/hypr/keybindings.conf` via `playerctl-smart.sh`
- **playerctl:** `pacman -S playerctl` — MPRIS controller used for all media key actions
- **Smart player selection:** `waybar/.config/waybar/scripts/playerctl-smart.sh` — finds the currently Playing MPRIS player first, falls back to first available. Avoids wrong-player issues when multiple MPRIS sources are registered (e.g. browser + music app)
- **Gotcha:** browsers (brave, firefox) register as MPRIS players but don't support Next/Previous. play-pause works; skip controls only work with dedicated music apps (Spotify, VLC, etc.)
- **Ansible steps:** `pacman -S playerctl`, stow `waybar/` and `hyprland/`

### Waybar — Media / Now Playing module
- **mpris module** grouped with `custom/cava` in `group/media` (green bottom stripe pill)
- **Click controls** on the mpris entry: left = play-pause, right = next, middle = previous, scroll = next/prev (all via `playerctl-smart.sh`)
- **cava visualizer:** `custom/cava` module runs `waybar/.config/waybar/scripts/cava.sh`; only shows bars when a player is in Playing state. Config at `waybar/.config/waybar/cava.conf` (8 bars, ASCII output)
- **Install cava:** `pacman -S cava` (not yet installed — module is configured and ready)
- **Ansible steps:** `pacman -S cava playerctl`, stow `waybar/`; ensure `cava.sh` and `playerctl-smart.sh` are `+x`

### swaync — Notification Center Styling
- Restyled to match waybar color palette (`#0e1626` bg, `#162032` notification bg, `#d4e0f0` text, `#f07830` accent)
- Reduced sizes: font 13px body / 14px summary (was 15/16px), border-radius 12px (was 25px), icon 48px (was 64px)
- Toggle buttons use orange accent (`#f07830`) instead of blue; system action buttons use muted `#3a5270`
- Config: `swaync/.config/swaync/style.css`
- **Reload:** `swaync-client --reload-css`

### Networking
| Package | Purpose | Status |
|---------|---------|--------|
| `iwd` | Wifi daemon (replaces NetworkManager) | pre-installed |
| `impala` | TUI wifi manager for iwd — keyboard-driven | manual — `pacman -S impala` |

- `iwd` was already running as the wifi backend — no NetworkManager
- `impala` added on top as TUI frontend; no service changes needed

---

### Power Management (Sleep, Hibernate, Lid Behavior)

#### Hibernate prerequisites
- **Swap partition:** `/dev/nvme0n1p3`, UUID `c585a301-e41a-4237-8108-6bef77ca7d33`, 16G — must be ≥ RAM size
- **⚠️ Machine-specific:** the swap UUID changes per machine — re-detect with `blkid /dev/nvme0n1pX` on reinstall
- **`/etc/mkinitcpio.conf`** — added `resume` hook after `udev`, before `filesystems`:
  ```
  HOOKS=(base udev autodetect microcode modconf kms keyboard keymap consolefont block resume filesystems fsck)
  ```
  Rebuild UKI after editing: `sudo mkinitcpio -P`
- **`/boot/limine.conf`** — added `resume=UUID=<swap-uuid>` and `acpi_sleep=nobl` to the `cmdline`:
  ```
  cmdline: root=PARTUUID=... zswap.enabled=0 rw rootfstype=ext4 resume=UUID=c585a301-e41a-4237-8108-6bef77ca7d33 acpi_sleep=nobl
  ```
  ⚠️ Machine-specific — update `resume=UUID=` per machine. `zswap.enabled=0` is intentional (zswap interferes with hibernate).
  - `acpi_sleep=nobl` required on **Lenovo Yoga Slim 7 14ARE05 (AMD, 82A2)** — without it, hibernate resumes fail with `Hibernate inconsistent memory map detected`. This is an AMD/UEFI firmware issue where the memory map changes between boots. May not be needed on other machines.

#### Known hardware quirks — Yoga Slim 7 14ARE05 (82A2, AMD)
- **No S3 sleep** — Lenovo removed S3 from BIOS; only `s2idle` available (`cat /sys/power/mem_sleep` shows `[s2idle]`). Sleep works but is shallower than S3 (higher idle battery drain).
- **Hibernate memory map mismatch** — fixed with `acpi_sleep=nobl` kernel parameter.

#### Lid switch behavior
- **`/etc/systemd/logind.conf.d/lid.conf`** (drop-in, preferred over editing base file):
  ```ini
  HandleLidSwitch=suspend-then-hibernate              # lid close, standalone → suspend first, then hibernate
  HandleLidSwitchExternalPower=suspend-then-hibernate # lid close on AC, no external monitor → same
  HandleLidSwitchDocked=ignore                        # external monitor connected → logind does nothing, Hyprland takes over
  ```
  Apply with: `sudo systemctl restart systemd-logind`
- **Hyprland `keybindings.conf`** — disables internal display when lid is closed while docked:
  ```ini
  bindl = , switch:on:Lid Switch,  exec, hyprctl keyword monitor eDP-1,disable
  bindl = , switch:off:Lid Switch, exec, hyprctl keyword monitor eDP-1,1920x1080,auto,1,bitdepth,8
  ```
  `switch:on` = lid closed, `switch:off` = lid opened. When undocked, logind suspends before display disable is visible; on resume, lid-open re-enables `eDP-1`.

#### Idle-based auto lock/sleep/hibernate
- Handled by `hypridle` — see Phase 2 Screen Lock section for config details.

#### Recovery (if hibernate fails to resume)
- Boot normally — system will start fresh if resume fails; no data loss beyond unsaved work
- If kernel parameter is wrong: boot with Limine, edit `cmdline` at the boot prompt, fix `/boot/limine.conf`
- If `resume` hook is missing: boot, re-add hook to `/etc/mkinitcpio.conf`, run `sudo mkinitcpio -P`

#### Ansible steps
1. Edit `/etc/mkinitcpio.conf` — add `resume` hook (Ansible `lineinfile` or template)
2. Edit `/boot/limine.conf` — add `resume=UUID=` + `acpi_sleep=nobl` (template with vault variable per machine; `acpi_sleep=nobl` may be Yoga Slim 7 specific)
3. Edit `/etc/systemd/logind.conf` — set lid switch handlers
4. `sudo systemctl restart systemd-logind`
5. `sudo mkinitcpio -P` (rebuilds UKI)

---

## Phase 7 — Recovery & Backup

### File Transfer from Old System
<!-- Log: what was transferred, method (rsync / USB) -->

### Backup System
<!-- Log: tool (restic / borgbackup), remote target, schedule -->

### Ansible Secrets Checklist
➡️ Full checklist lives in **`ansible/SECRETS.md`** (single source of truth — vault password, AI
creds, SSH keys, git identity/auth, with destinations and modes). Add new secrets there.

---

## Decisions & Notes

| Date | Decision | Reason |
|------|----------|--------|
| 2026-06-01 | Switch from Fedora/i3 to Arch/Wayland | Full control, Hyprland ecosystem, fresh start |
| 2026-06-01 | Log-first workflow | Document manual steps before automating into Ansible |
| 2026-06-06 | SDDM theme via sddm-astronaut-theme | Customized graphical login greeter; installed through upstream setup.sh (needs gum) |
| 2026-06-06 | SDDM variant = black_hole + custom wallpaper | Picked black_hole variant; deliberately overwrote its stock `Backgrounds/black_hole.png` with a personal 3440x1440 image — must be backed up to repo and re-applied on reinstall |
| 2026-06-06 | SDDM greeter laid out via X11 `Xsetup` + `xrandr` (not `wlr-randr`) | Greeter runs on X11; `wlr-randr` needs a wlroots Wayland compositor and can't drive it. `xrandr` is the right layer. Ultrawide set primary, laptop switched off to avoid a duplicated login dialog |
| 2026-06-06 | Wallpaper via hyprpaper (dune_wallpaper.png, all monitors) | hyprpaper already installed; config kept as a dotfile, autostarted with `exec-once`. Wildcard monitor so both eDP-1 and DP-1 share one wallpaper |
| 2026-06-06 | Zsh secrets in gitignored `~/.zsh_secrets` (sourced from `.zshrc`) | Keep API keys out of the tracked dotfiles. TODO: graduate to Ansible Vault so secrets are part of the encrypted, recoverable backup |
| 2026-06-06 | Cursor theme = Bibata-Modern-Amber (size 24), via AUR `bibata-cursor-theme` | Consistent rounded cursor across GTK + Hyprland. AUR install lands in `/usr/share/icons` system-wide; applied via gsettings + Hyprland `env`/`hyprctl setcursor` |
| 2026-06-06 | swaync themed config (navy/orange, top-right, balanced timeouts, DND + volume/backlight sliders) | Custom notification daemon styled to match the desktop; kept as stow package `swaync/`. Critical notifications never auto-dismiss; `backlight` device `amdgpu_bl1` is machine-specific |
| 2026-06-09 | SSH `config` managed via `ssh/` stow package; keys gitignored | `~/.ssh` already holds the keys so stow links only `config`; `.gitignore` (`ssh/.ssh/*` + `!config`) guarantees private keys / `known_hosts` are never committed |
| 2026-06-09 | Secrets moved from flat `~/.zsh_secrets` to folder `~/.config/secrets/*.zsh` | Per-category files (e.g. `ai.zsh`), dir `700`/files `600`, sourced via a loop in `.zshrc`. Real folder lives outside the repo; template `zsh/secrets.example/ai.zsh` kept out of `$HOME` via `.stow-local-ignore` |
| 2026-06-09 | Added Ansible Secrets Checklist (Phase 7) | Single source of truth for everything the vault must restore on a clean install (AI creds, SSH keys, git identity/auth) |
| 2026-06-09 | fzf installed (pacman) + zsh integration via `source <(fzf --zsh)` | Fuzzy finder; CTRL-R/CTRL-T/ALT-C keybindings wired into `.zshrc`. Modern `fzf --zsh` hook (needs ≥0.48) instead of sourcing the `/usr/share/fzf/*.zsh` scripts |
| 2026-06-09 | bat replaces `cat` via `alias cat="bat --paging=never"` | Syntax-highlighted `cat` for interactive use; `--paging=never` keeps it drop-in. Pipes/scripts still hit real `cat`, so nothing breaks |
| 2026-06-11 | MX Master 3 thumb button = `$mainMod` via logiops (`cid 0xc3` → `Keypress KEY_LEFTALT`) | Mouse buttons can't be Hyprland bind modifiers; logiops holds the mod key while the thumb button is down, so thumb+scroll cycles workspaces through the existing `$mainMod`+scroll bind. Key = `KEY_LEFTALT` to match `$mainMod = ALT`. logiops via AUR, config in `ansible/files/logid.cfg` → `/etc/logid.cfg`, `logid` service enabled |
| 2026-06-13 | Media keys use `playerctl-smart.sh` instead of plain `playerctl` | `playerctl` picks the wrong player when multiple MPRIS sources are registered (browser wins over music app). Smart script iterates players, picks the one in Playing state first |
| 2026-06-13 | Switched from Brave to Helium browser | Helium supports PWA installs (Google Calendar, Gmail, etc.) as standalone windows — cleaner than browser tabs. Brave not installed on new setups |
| 2026-06-13 | Browser MPRIS next/previous not supported | Brave/Firefox register as MPRIS players but only implement play/pause — skip controls silently do nothing. Not a script bug; inherent browser limitation |
| 2026-06-13 | cava visualizer in waybar — hidden when not playing | `custom/cava` module runs cava with ASCII output; script checks `playerctl status` each frame and emits empty string when nothing is Playing so the bars disappear when music stops |
| 2026-06-13 | swaync styled to match waybar palette | Consistent navy/orange theme across bar and notification center; reduced sizes (12px radius, 13px font) to feel less bloated |
| 2026-06-13 | Hibernate via swap partition (`/dev/nvme0n1p3`); zswap disabled | zram (`/dev/zram0`) is compressed RAM-only — not usable for hibernate. Physical swap partition required. `zswap.enabled=0` in kernel cmdline prevents zswap from intercepting swap writes needed for hibernate. `resume=UUID=` in limine.conf + `resume` hook in mkinitcpio wires resume on boot. UUID is machine-specific — must be updated per device |
| 2026-06-14 | `acpi_sleep=nobl` required for hibernate on Yoga Slim 7 14ARE05 | AMD/UEFI firmware randomizes memory map between boots causing `Hibernate inconsistent memory map detected` — `acpi_sleep=nobl` disables the memory map blacklist check and fixes resume. No S3 sleep available on this model (BIOS removed it); s2idle only |
| 2026-06-20 | Lid close behavior via `/etc/systemd/logind.conf.d/lid.conf` + Hyprland `bindl` — suspend-then-hibernate when undocked, disable `eDP-1` when docked | logind handles sleep/hibernate (can't be done in Hyprland); Hyprland handles display disable when docked. `HandleLidSwitchDocked=ignore` keeps logind out of the way. `switch:off` re-enables `eDP-1` on lid open. |
| 2026-06-17 | aerc email client — Gmail via IMAP with GPG-encrypted app password | Google blocks plain IMAP passwords; App Password required (2FA must be on). Password stored GPG-encrypted at `~/.config/aerc/gmail.gpg` — never plaintext on disk. GPG key: ed25519/cv25519, no passphrase. accounts.conf uses `source-cred-cmd`/`outgoing-cred-cmd` to decrypt at runtime. On new machine: generate GPG key, retrieve app password from Ansible Vault, re-encrypt |
| 2026-06-27 | SwayOSD caps-lock suppression must live in `/etc/xdg/swayosd/backend.toml` (root), not the user stow config | `swayosd-libinput-backend` runs as a **system** (root) service, so it reads `/etc/xdg/swayosd/backend.toml` and ignores `~/.config/swayosd/backend.toml`. `ignore_caps_lock_key = true` had to be set in the root file (then restart the backend) to stop the caps-lock popup. Ansible must deploy this as a root-owned file like `logid.cfg`, not a stow dotfile |
| 2026-08-03 | Work email (Axxes, VRT) in aerc uses OAuth2/XOAUTH2 via `mutt_oauth2.py`, not app passwords | Both are Microsoft 365 with basic auth disabled — only OAuth2 works. Reused the muttmua contrib script + Thunderbird's public `client_id` (`9e5f94bc-...`); token files GPG-encrypted per account at `~/.config/aerc/<acct>.token`. aerc scheme must be `imaps+xoauth2`/`smtp+xoauth2` (auth in URL, not an `auth=` key); SMTP 587 = STARTTLS so scheme is `smtp+`, not `smtps`. `GPG_TTY` must be exported or the token pipe can't decrypt. If a tenant blocks the public app, IT must register one with delegated IMAP.AccessAsUser.All/SMTP.Send/offline_access |
| 2026-08-03 | aerc inline images: chafa **symbols** mode only; kitty/sixel graphics don't work in aerc | aerc renders filter output through its own text-cell UI, so terminal graphics-protocol escapes (kitty `\e_G…`, sixel `\eP…`) print as literal text ("string of letters"). Only `chafa -f symbols` (Unicode block art → plain SGR color cells) renders. Original `magick convert` was also broken (IM7 deprecation warning corrupts the piped bytes). `pacman -S chafa`. Filter currently left commented in `aerc.conf`; `kitty +kitten icat` remains an option for pixel-perfect images since it writes straight to the terminal, bypassing aerc's UI |
