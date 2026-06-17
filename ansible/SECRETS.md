# Ansible Secrets Checklist

All sensitive material that must be present for a clean reinstall. **None of this is in git in
plaintext** — the intended mechanism is **Ansible Vault**: encrypt each secret, and have the playbook
decrypt and deploy it to its destination with the correct permissions. The vault password itself is
the one secret that lives only in your head / password manager.

> When you introduce a new secret anywhere in the setup, add a row here so the vault stays the single
> source of truth for recovery. (Mirror summary kept in `SETUP_LOG.md` Phase 7.)

## Checklist

| # | Secret | Destination (mode) | Source / how to provide | Status |
|---|--------|--------------------|--------------------------|--------|
| 0 | **Ansible Vault password** | `--ask-vault-pass` prompt (or `.vault_pass`, gitignored) | Memorized / Bitwarden — unlocks everything below | ⬜ manual |
| 1 | **Anthropic API creds** — `ANTHROPIC_BASE_URL`, `ANTHROPIC_API_KEY` | `~/.config/secrets/ai.zsh` (file `600`, dir `700`) | axxes bridge key; template at `zsh/secrets.example/ai.zsh` | ⬜ vault TODO |
| 2 | **SSH private key — `arrakis`** (+`.pub`) | `~/.ssh/arrakis` (`600`) | Host key for `arrakis` (192.168.129.10) | ⬜ vault TODO |
| 3 | **SSH private key — `id_ed25519`** (+`.pub`) | `~/.ssh/id_ed25519` (`600`) | General / GitHub key | ⬜ vault TODO |
| 4 | **Git identity & signing** | `~/.gitconfig` (+ signing key if used) | `user.name`, `user.email`, optional GPG/SSH signing key | ⬜ TODO |
| 5 | **Git remote auth** | credential helper / token | GitHub PAT or SSH (covered by #3) — confirm `gh auth` too | ⬜ TODO |
| 6 | **ycal OAuth client secret** | `~/.config/waybar-ycal/client_secret.json` (`600`) | Google Cloud OAuth desktop client JSON; tracked in `waybar/` stow package but gitignored. After deploy, run ycal auth to generate token. | ⬜ vault TODO |
| 7 | **Gmail App Password** | encrypted via GPG → `~/.config/aerc/gmail.gpg` | 16-char app password from [myaccount.google.com/apppasswords](https://myaccount.google.com/apppasswords). On restore: generate GPG key, decrypt from vault, re-encrypt with GPG. See aerc setup in SETUP_LOG.md Phase 5. | ⬜ vault TODO |

## Notes / gotchas

- SSH **public** keys aren't secret, but keep them alongside their private partners so host access
  works immediately after restore.
- `~/.ssh/known_hosts` is not a secret — let it regenerate, or restore it for convenience.
- Brave / Bitwarden / browser logins are interactive app sign-ins, **not** Ansible-deployed secrets —
  out of scope for the vault (you log in once via the app).

## How it should work (target)

1. Secrets are stored encrypted, e.g. `ansible/vault/secrets.yml` (encrypted with `ansible-vault`).
2. `ansible-playbook ... --ask-vault-pass` decrypts at runtime.
3. Tasks write each secret to its destination with the mode listed above (e.g. `copy`/`template`
   with `mode: '0600'`, and `0700` for parent dirs like `~/.ssh` and `~/.config/secrets`).
