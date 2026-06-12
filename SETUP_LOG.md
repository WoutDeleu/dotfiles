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

### AUR Packages
| Package | AUR Helper | Purpose | Status |
|---------|-----------|---------|--------|
| logiops | yay | Logitech HID++ daemon (`logid`) — remaps MX Master 3 buttons/gestures (see Input Devices) | manual |
| ycal | yay | Google Calendar module for Waybar — client secret at `~/.config/waybar-ycal/client_secret.json` (gitignored, via stow), OAuth not yet configured | manual |

### Services Enabled
| Service | Command | Status |
|---------|---------|--------|
| logid | `systemctl enable --now logid` | MX Master 3 button remapping daemon (logiops) |
| hyprpolkitagent | `systemctl --user enable hyprpolkitagent` | Polkit agent for Hyprland — user-level service, starts on next login |
| cliphist | `systemctl --user enable --now cliphist` | Clipboard history watcher — unit file in `systemd/` stow package |
| waybar | `systemctl --user enable --now waybar` | Status bar — config in `waybar/` stow package |

---

## Phase 2 — Desktop (Wayland / Hyprland)

### Hyprland Config
<!-- Log: key config decisions, monitors, keybindings, window rules -->

### Waybar
- **Install:** `pacman -S waybar`
- **Autostart:** `systemctl --user enable --now waybar` (user service)
- **Config:** in `waybar/` stow package.
- **Ansible steps:** (1) `pacman -S waybar`, (2) stow `waybar/`, (3) `systemctl --user enable waybar`.

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
<!-- Log: tool (swaylock / hyprlock), config -->

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

### Neovim
<!-- Log: config approach (kickstart / own), plugins -->

### Git
<!-- Log: global config, credential helper, SSH key setup -->

### SSH
- **Config via stow:** `~/.ssh/config` is a symlink into the `ssh/` stow package
  (`ssh/.ssh/config`). Because `~/.ssh` already exists (holds the keys), stow links only the
  `config` file and leaves everything else as real local files.
- **Keys are NEVER tracked:** repo-root `.gitignore` has `ssh/.ssh/*` + `!ssh/.ssh/config`, so only
  `config` can ever be committed — private keys / `known_hosts` are excluded even if copied in.
- **Current keys (machine-local, mode `600`):** `~/.ssh/arrakis` (+`.pub`) for host `arrakis`,
  `~/.ssh/id_ed25519` (+`.pub`). These must be restored from the encrypted backup (see Ansible
  Secrets Checklist) on a clean install.
- **Ansible steps:** (1) `stow ssh` to deploy `~/.ssh/config`; (2) vault-decrypt the private keys
  into `~/.ssh/` with mode `0600` (dir `0700`).

### Claude Code
<!-- Log: install method, config -->

### Language Toolchains
| Language | Tool | Install Method | Status |
|----------|------|---------------|--------|
| Python | pyenv / uv | | manual |
| Java | sdkman / pacman | | manual |

---

## Phase 5 — Applications

### Bitwarden
<!-- Log: install method (flatpak / AUR), setup -->

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

---

## Phase 6 — System Configuration

### Audio (Pipewire)
<!-- Log: packages, wireplumber config, volume keybindings -->

### Bluetooth
<!-- Log: packages, fastconnectable config -->

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
