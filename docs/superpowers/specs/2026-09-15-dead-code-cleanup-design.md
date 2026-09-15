# Evidence-Based Dead Code Cleanup

## Goal

Remove code and files that are demonstrably unreachable or superseded across
the repository, while preserving manual entry points, external application
configuration, dormant optional features, and the user's unrelated uncommitted
work.

Document the display-layout ownership established on 2026-09-15 so a clean
reinstall reproduces the intended behavior.

## Deletion Criteria

A file or code path may be deleted only when repository evidence proves one of
the following:

1. A live replacement supersedes it.
2. The active startup/configuration chain cannot reach it.
3. It is an obsolete backup duplicated by an actively maintained file.

Lack of an in-repository reference is insufficient when an external program,
plugin discovery convention, system service, or manual command may invoke the
file.

## Confirmed Cleanup Scope

- Remove obsolete shell and Vim backups under `bak/` that are superseded by the
  active `zsh/` and `nvim/` stow packages.
- Remove old root-level nwg-displays workspace output because dynamic workspace
  assignment is owned by `monitors/monitor-workspaces.sh`.
- Remove the unloaded `monitors/arrangement.lua` module because monitor
  arrangement is now loaded from nwg-displays-generated `monitors.lua`.
- Remove stale comments or documentation references that would direct future
  work back to deleted display paths.
- Check whether nwg-displays supports suppressing generated compatibility files.
  If it does not, preserve output that it will recreate rather than adding a
  brittle cleanup mechanism.

## Protected Scope

- Do not delete broken or incomplete automation merely because it is not
  operational. `bootstrap.sh`, Ansible tasks, and root configuration deployment
  remain advertised recovery surfaces and require repair as a separate task.
- Do not delete commented-out Neovim plugin modules; they are intentionally
  dormant optional features.
- Do not delete examples excluded through `.stow-local-ignore`.
- Do not modify unrelated dirty-worktree changes.

## Display Setup Log

Record that:

- `nwg-displays` was installed from the AUR with `yay`.
- Its generated `~/.config/hypr/monitors.lua` is the authoritative monitor
  mode, position, scale, and VRR configuration.
- `monitor-workspaces.sh` remains responsible only for monitor-profile
  detection, workspace assignment, and lid-state recovery.
- The old arrangement module and watcher arrangement functions were removed
  because they competed with the display UI and reverted manual layouts.

Add the ownership choice to the Decisions & Notes table.

## Validation

- Search the full repository for references to every deleted path or symbol.
- Run shell syntax checks for touched shell scripts.
- Run the display-layout ownership regression test.
- Reload Hyprland, confirm no configuration errors, and confirm the workspace
  watcher does not change nwg-displays coordinates.
- Start Neovim headlessly to verify its active configuration after backup
  removal.
- Run `git diff --check` over touched files.
