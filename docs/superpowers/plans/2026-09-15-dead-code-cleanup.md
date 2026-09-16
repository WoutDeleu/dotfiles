# Evidence-Based Dead Code Cleanup Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove repository artifacts proven obsolete while preserving active display, shell, Neovim, automation, and recovery behavior.

**Architecture:** Keep `nwg-displays` as the sole owner of monitor geometry through generated `monitors.lua`, while the existing watcher owns only dynamic workspace placement and lid recovery. Remove only files with explicit live replacements; ignore optional generated workspace output so editing workspace assignments in the GUI cannot reintroduce tracked dead configuration.

**Tech Stack:** Bash, Hyprland Lua configuration, nwg-displays 0.4.4, GNU Stow layout, Neovim

**Spec:** `docs/superpowers/specs/2026-09-15-dead-code-cleanup-design.md`

## Global Constraints

- Delete only code or files proven superseded, unreachable from the active startup chain, or duplicated by an actively maintained replacement.
- Treat external application entry points, plugin discovery conventions, and manual commands as live unless proven otherwise.
- Preserve unrelated uncommitted work.
- Do not repair `bootstrap.sh`, Ansible, root configuration deployment, or dormant optional Neovim modules in this change.
- `nwg-displays`, installed from the AUR with `yay`, owns monitor mode, position, scale, and VRR configuration.
- `monitor-workspaces.sh` owns only profile detection, workspace assignment, and lid-state recovery.

---

### Task 1: Remove the superseded Hyprland arrangement module

**Files:**
- Modify: `hyprland/.config/hypr/hyprland.lua`
- Modify: `hyprland/.config/hypr/monitors/monitor-workspaces.sh`
- Modify: `hyprland/.config/hypr/monitors/layouts/home.sh`
- Modify: `hyprland/.config/hypr/monitors/layouts/laptop.sh`
- Modify: `hyprland/.config/hypr/monitors/layouts/vrt.sh`
- Modify: `hyprland/.config/hypr/monitors/workspaces.lua`
- Modify: `hyprland/.config/hypr/scripts/startup.sh`
- Delete: `hyprland/.config/hypr/monitors/arrangement.lua`
- Verify: `hyprland/.config/hypr/monitors.lua`
- Verify: `hyprland/.config/hypr/monitors/monitor-workspaces.sh`

**Interfaces:**
- Consumes: `require("monitors")`, the nwg-displays-generated Lua module.
- Produces: One active monitor-geometry source, while retaining `xwayland.force_zero_scaling = true`.

- [ ] **Step 1: Capture the failing active-config assertion**

Run:

```bash
grep -q 'require("monitors")' hyprland/.config/hypr/hyprland.lua &&
grep -A4 'xwayland = {' hyprland/.config/hypr/hyprland.lua |
  grep -q 'force_zero_scaling = true' &&
test ! -e hyprland/.config/hypr/monitors/arrangement.lua
```

Expected: FAIL because `xwayland.force_zero_scaling` still lives only in the
unloaded arrangement module and that module still exists.

- [ ] **Step 2: Preserve the live XWayland setting in the active root config**

Add this block to the existing system-config `hl.config` call in
`hyprland/.config/hypr/hyprland.lua`:

```lua
    xwayland = {
        force_zero_scaling = true,
    },
```

Do not copy the fallback wildcard monitor rule. The generated
`hyprland/.config/hypr/monitors.lua` is now the intentional arrangement source.

- [ ] **Step 3: Delete the unloaded module**

Delete:

```text
hyprland/.config/hypr/monitors/arrangement.lua
```

- [ ] **Step 4: Run the active-config assertion**

Run:

```bash
grep -q 'require("monitors")' hyprland/.config/hypr/hyprland.lua &&
grep -A4 'xwayland = {' hyprland/.config/hypr/hyprland.lua |
  grep -q 'force_zero_scaling = true' &&
test ! -e hyprland/.config/hypr/monitors/arrangement.lua &&
! grep -R -n -E 'monitors\.arrangement|_arrange\(\)|mon_spec_to_lua|mon_field\(\)' \
  hyprland/.config/hypr
```

Expected: PASS with no references to the removed arrangement path or helpers.

- [ ] **Step 5: Verify live Hyprland behavior**

Run:

```bash
set -e
hyprctl reload
sleep 1
hyprctl configerrors
before=$(hyprctl monitors all -j | jq -Sc '[.[] | {name,x,y}] | sort_by(.name)')
"$HOME/.config/hypr/monitors/monitor-workspaces.sh" apply
after=$(hyprctl monitors all -j | jq -Sc '[.[] | {name,x,y}] | sort_by(.name)')
printf 'before=%s\nafter=%s\n' "$before" "$after"
test "$before" = "$after"
```

Expected: no config errors and identical monitor coordinates before and after
the workspace watcher runs.

- [ ] **Step 6: Commit the display cleanup**

```bash
git add hyprland/.config/hypr/hyprland.lua \
  hyprland/.config/hypr/monitors/arrangement.lua \
  hyprland/.config/hypr/monitors/monitor-workspaces.sh \
  hyprland/.config/hypr/monitors/layouts/home.sh \
  hyprland/.config/hypr/monitors/layouts/laptop.sh \
  hyprland/.config/hypr/monitors/layouts/vrt.sh \
  hyprland/.config/hypr/monitors/workspaces.lua \
  hyprland/.config/hypr/scripts/startup.sh
git commit -m "refactor(hypr): remove obsolete arrangement module" \
  -m "Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"
```

---

### Task 2: Remove obsolete generated workspace files and backups

**Files:**
- Modify: `.gitignore`
- Delete: `hyprland/.config/hypr/workspaces.conf`
- Delete: `hyprland/.config/hypr/workspaces.lua`
- Delete: `bak/.zshrc`
- Delete: `bak/init.vim`
- Modify: `ansible/files/logid.cfg`

**Interfaces:**
- Consumes: dynamic workspace rules from `monitors/monitor-workspaces.sh` and active configs from `zsh/.zshrc` and `nvim/.config/nvim/init.lua`.
- Produces: no tracked stale nwg-displays workspace output and no obsolete configuration backup directory.

- [ ] **Step 1: Capture the failing cleanup assertion**

Run:

```bash
test ! -e hyprland/.config/hypr/workspaces.conf &&
test ! -e hyprland/.config/hypr/workspaces.lua &&
test ! -e bak/.zshrc &&
test ! -e bak/init.vim
```

Expected: FAIL because all four obsolete files currently exist.

- [ ] **Step 2: Ignore optional nwg-displays workspace output**

Append this exact block to `.gitignore`:

```gitignore
# nwg-displays workspace output is unused; workspaces are assigned dynamically
hyprland/.config/hypr/workspaces.conf
hyprland/.config/hypr/workspaces.lua
```

`nwg-displays` 0.4.4 writes these files only when workspace assignments are
changed in its GUI. There is no supported disable flag, so ignoring the output
is safer than wrapping or patching the packaged desktop launcher.

- [ ] **Step 3: Delete the proven obsolete files**

Delete:

```text
hyprland/.config/hypr/workspaces.conf
hyprland/.config/hypr/workspaces.lua
bak/.zshrc
bak/init.vim
```

- [ ] **Step 4: Correct the live logiops reference**

In `ansible/files/logid.cfg`, replace the obsolete comment reference:

```text
// Hyprland bind in hyprland/.config/hypr/monitors/workspaces.conf:
//     bind = $mainMod, mouse_down, workspace, e+1
//     bind = $mainMod, mouse_up,   workspace, e-1
```

with the active Lua location and syntax:

```text
// Hyprland binds in hyprland/.config/hypr/monitors/workspaces.lua:
//     hl.bind(var_mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
//     hl.bind(var_mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
```

- [ ] **Step 5: Run cleanup and reference assertions**

Run:

```bash
set -e
test ! -e hyprland/.config/hypr/workspaces.conf
test ! -e hyprland/.config/hypr/workspaces.lua
test ! -e bak/.zshrc
test ! -e bak/init.vim
grep -q '^hyprland/.config/hypr/workspaces.conf$' .gitignore
grep -q '^hyprland/.config/hypr/workspaces.lua$' .gitignore
! grep -R -n -E 'monitors/workspaces\.conf|bak/(\.zshrc|init\.vim)' \
  --exclude-dir=.git ansible hyprland
```

Expected: PASS and no stale code/documentation references.

- [ ] **Step 6: Verify the active replacement configurations**

Run:

```bash
zsh -n zsh/.zshrc
nvim --headless '+qa'
```

Expected: both commands exit 0.

- [ ] **Step 7: Commit the obsolete-file cleanup**

```bash
git add .gitignore ansible/files/logid.cfg
git add -u -- bak/.zshrc bak/init.vim
git commit -m "chore: remove superseded configuration files" \
  -m "Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"
```

---

### Task 3: Log display ownership and complete repository validation

**Files:**
- Modify: `SETUP_LOG.md`
- Verify: `docs/superpowers/specs/2026-09-15-dead-code-cleanup-design.md`
- Verify: all files changed by Tasks 1-3

**Interfaces:**
- Consumes: the final display ownership and cleanup state from Tasks 1-2.
- Produces: recovery documentation that identifies the package, installation method, active generated file, watcher responsibility, and rationale.

- [ ] **Step 1: Capture the failing log assertions**

Run:

```bash
grep -q '| nwg-displays | yay |' SETUP_LOG.md &&
grep -A15 '^### Display / Monitor Layout' SETUP_LOG.md |
  grep -q 'monitors.lua' &&
grep -A15 '^### Display / Monitor Layout' SETUP_LOG.md |
  grep -q 'monitor-workspaces.sh' &&
grep -q 'nwg-displays owns monitor geometry' SETUP_LOG.md
```

Expected: FAIL because the display tool and ownership decision are not logged.

- [ ] **Step 2: Add the AUR package entry**

Add this row to the Phase 1 AUR Packages table:

```markdown
| nwg-displays | yay | GUI for arranging Hyprland outputs; generates `~/.config/hypr/monitors.lua` | manual — `yay -S nwg-displays` |
```

- [ ] **Step 3: Fill in the Display / Monitor Layout section**

Replace the placeholder under `### Display / Monitor Layout` with:

```markdown
- **Tool:** `nwg-displays` (`yay -S nwg-displays`).
- **Monitor geometry owner:** `nwg-displays` generates
  `hyprland/.config/hypr/monitors.lua`, loaded by `require("monitors")` in
  `hyprland.lua`. Use the GUI for monitor mode, position, scale, and VRR.
- **Workspace owner:** `hyprland/.config/hypr/monitors/monitor-workspaces.sh`
  detects laptop/home/work monitor profiles and applies only workspace mappings.
  Its watcher starts from `scripts/startup.sh`; it must not emit monitor
  arrangement calls.
- **Lid recovery:** the watcher may disable the laptop panel for a physically
  closed lid or reload Hyprland after a missed lid-open event. Reloading restores
  the saved `nwg-displays` layout.
- **Generated workspace files:** `workspaces.conf` and `workspaces.lua` are
  intentionally ignored because workspace placement is dynamic. `nwg-displays`
  may recreate them if its workspace-assignment dialog is used.
- **Reason:** the former arrangement module and profile `_arrange` functions
  competed with `nwg-displays`, so GUI changes were saved and then overwritten.
```

- [ ] **Step 4: Correct the stale setup-log keybinding reference**

In the MX Master 3 section, replace:

```text
`bind = $mainMod, mouse_down/up, workspace, e+1/e-1` (in `workspaces.conf`).
```

with:

```text
the `mouse_down` / `mouse_up` `hl.bind` calls in `monitors/workspaces.lua`.
```

- [ ] **Step 5: Add the ownership decision**

Add this row to the Decisions & Notes table:

```markdown
| 2026-09-15 | nwg-displays owns monitor geometry; monitor-workspaces watcher owns only dynamic workspace mapping and lid recovery | Two arrangement sources competed: nwg-displays saved changes correctly, then the watcher restored hard-coded profile coordinates. Loading generated `monitors.lua` and removing watcher arrangement code makes GUI layouts persistent. |
```

- [ ] **Step 6: Run log assertions and full validation**

Run:

```bash
set -e
grep -q '| nwg-displays | yay |' SETUP_LOG.md
grep -A20 '^### Display / Monitor Layout' SETUP_LOG.md | grep -q 'monitors.lua'
grep -A20 '^### Display / Monitor Layout' SETUP_LOG.md | grep -q 'monitor-workspaces.sh'
grep -q 'nwg-displays owns monitor geometry' SETUP_LOG.md
bash -n \
  hyprland/.config/hypr/monitors/monitor-workspaces.sh \
  hyprland/.config/hypr/monitors/layouts/home.sh \
  hyprland/.config/hypr/monitors/layouts/laptop.sh \
  hyprland/.config/hypr/monitors/layouts/vrt.sh \
  hyprland/.config/hypr/scripts/startup.sh
zsh -n zsh/.zshrc
nvim --headless '+qa'
hyprctl reload
sleep 1
test -z "$(hyprctl configerrors)"
before=$(hyprctl monitors all -j | jq -Sc '[.[] | {name,x,y}] | sort_by(.name)')
"$HOME/.config/hypr/monitors/monitor-workspaces.sh" apply
after=$(hyprctl monitors all -j | jq -Sc '[.[] | {name,x,y}] | sort_by(.name)')
test "$before" = "$after"
git diff --check
```

Expected: every command exits 0, Hyprland reports no config errors, and the
watcher leaves monitor coordinates unchanged.

- [ ] **Step 7: Inspect scope and commit the log**

Run:

```bash
git status --short
git diff -- SETUP_LOG.md
```

Confirm the log diff preserves pre-existing unrelated edits, then commit only
the display-log hunks. If unrelated changes share `SETUP_LOG.md`, use
`git diff -- SETUP_LOG.md` to construct a patch containing only the display
section, AUR row, corrected reference, and decision row, and apply that patch to
the index with `git apply --cached`.

```bash
git commit -m "docs: log persistent monitor layout ownership" \
  -m "Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"
```
