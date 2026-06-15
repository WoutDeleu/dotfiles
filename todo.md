# Power Management — Todo

## 1. hypridle — Idle Timeouts
Configure `~/.config/hypr/hypridle.conf`:
- [x] Decide timeouts:
  - AC: 3min lock → 7min screen off → 20min suspend-then-hibernate
  - Battery: 3min lock → 5min screen off → 15min suspend-then-hibernate
- [x] Decide if timeouts differ when on AC vs battery → Yes, separate configs + start-hypridle.sh
- [x] `exec-once = ~/.config/hypr/scripts/start-hypridle.sh` added to hyprland.conf

## 2. Lid Close Behavior
Configure `/etc/systemd/logind.conf`:
- [x] Lid close, **no external monitor** → suspend-then-hibernate (`HandleLidSwitch=suspend-then-hibernate`)
- [x] Lid close, **external monitor connected** → ignore (`HandleLidSwitchDocked=ignore`, already default)
- [ ] Deploy: `sudo cp ~/dotfiles/systemd/etc/systemd/logind.conf.d/lid.conf /etc/systemd/logind.conf.d/ && sudo systemctl restart systemd-logind`
- [ ] Test: close lid with and without DP-1 connected

## 3. Power Menu Actions
Fix `~/.config/rofi/powermenu/type-4/powermenu.sh` — current script has stubs for several actions:
- [x] **Lock** → `loginctl lock-session`
- [x] **Suspend** → `systemctl suspend-then-hibernate`
- [x] **Hibernate** → added, `systemctl hibernate`
- [x] **Logout** → `hyprctl dispatch exit`
- [x] **Reboot** → `systemctl reboot`
- [x] **Shutdown** → `systemctl poweroff`
- [x] Committed to dotfiles

## 4. Keyboard Shortcuts — Lenovo Laptop
Add to `~/.config/hypr/keybindings.conf`:
- [x] Lock screen shortcut → `ALT SHIFT, L → loginctl lock-session`
- [x] Sleep shortcut → `ALT SHIFT, S → systemctl suspend-then-hibernate`
- [ ] Check if Lenovo has hardware sleep/power keys and bind `XF86Sleep`, `XF86PowerOff`

## 5. Power Modes (Performance / Balanced / Battery Saver) → [#134](https://github.com/WoutDeleu/dotfiles/issues/134)
- [ ] Decide tool: `power-profiles-daemon` (simple, systemd-integrated) vs `tlp` (more control)
  - `power-profiles-daemon`: `pacman -S power-profiles-daemon`, `powerprofilesctl set balanced/performance/power-saver`
  - `tlp`: `pacman -S tlp`, auto-applies on AC/battery switch
- [ ] Add waybar module to show/toggle current power profile (optional)
- [ ] Enable chosen service: `systemctl enable --now power-profiles-daemon` or `tlp`

## 6. Low Battery Warnings & Actions
- [ ] Choose tool: `dunst`/`swaync` script, or `upower` hook, or `hypridle` battery listener
- [ ] Decide thresholds:
  - ~20% → send notification warning
  - ~10% → send critical notification
  - ~5% → auto-hibernate
- [ ] Implement: a script polled via `hypridle` or a systemd timer / upower D-Bus listener
- [ ] Test on battery

## 7. Sleep / Hibernate Configuration
Already done (from session):
- [x] Swap partition set up (`/dev/nvme0n1p3`, UUID `c585a301-...`)
- [x] `resume` hook added to `/etc/mkinitcpio.conf`
- [x] `resume=UUID=` added to `/boot/limine.conf`
- [x] ~~⚠️ Hibernate not working~~ — fixed with `acpi_sleep=nobl` kernel parameter (Yoga Slim 7 14ARE05 AMD memory map issue)
- [x] ⚠️ Screen not locked after resuming from hibernate — fixed: `before_sleep_cmd = loginctl lock-session` added to both hypridle configs
- [x] Decide: sleep → hibernate after 2h — use `systemctl suspend-then-hibernate` + drop-in at `/etc/systemd/sleep.conf.d/hibernate-delay.conf` (`HibernateDelaySec=2h`)
  - ⚠️ Needs deploy: `sudo cp dotfiles/systemd/etc/systemd/sleep.conf.d/hibernate-delay.conf /etc/systemd/sleep.conf.d/`

## 8. hyprlock Config
- [x] Background (blurred screenshot)
- [x] Clock display
- [x] Input field styling
- [x] Added to dotfiles (`hyprland/` stow package)

## 9. Ansible Automation
Once all of the above is working:
- [ ] Add `hyprlock`, `hypridle`, `power-profiles-daemon` (or `tlp`) to Ansible packages
- [ ] Template `/etc/systemd/logind.conf` (lid behavior)
- [ ] Template `/etc/systemd/sleep.conf` (hibernate delay)
- [ ] Note: `/boot/limine.conf` `resume=UUID=` is **machine-specific** — needs per-host variable in Ansible inventory
