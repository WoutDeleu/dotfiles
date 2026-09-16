#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_SCRIPT="${1:-$SCRIPT_DIR/../monitor-workspaces.sh}"

tmpdir="$(mktemp -d)"
cleanup() {
  rm -rf "$tmpdir"
}
trap cleanup EXIT

log="$tmpdir/hyprctl.log"
fake_bin="$tmpdir/bin"
mkdir -p "$fake_bin"
: >"$log"

cat >"$fake_bin/hyprctl" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

log_file="${HYPRCTL_LOG:?}"

case "${1:-}" in
  monitors)
    if [ "${2:-}" = "all" ] && [ "${3:-}" = "-j" ]; then
      printf '%s\n' '[{"name":"DP-1","description":"Dell U2720Q","width":2560,"height":1440,"disabled":false}]'
      exit 0
    fi
    ;;
  workspaces)
    if [ "${2:-}" = "-j" ]; then
      printf '%s\n' '[]'
      exit 0
    fi
    ;;
  --batch)
    printf 'BATCH\t%s\n' "${2-}" >>"$log_file"
    exit 0
    ;;
  dispatch)
    printf 'DISPATCH\t%s\n' "${2-}" >>"$log_file"
    exit 0
    ;;
  reload)
    printf 'RELOAD\n' >>"$log_file"
    exit 0
    ;;
esac

printf 'unexpected hyprctl call: %s\n' "$*" >&2
exit 1
EOF
chmod +x "$fake_bin/hyprctl"

PATH="$fake_bin:$PATH" HYPRCTL_LOG="$log" "$TARGET_SCRIPT" apply

if ! grep -q 'hl\.workspace_rule' "$log"; then
  printf 'expected workspace rules in hyprctl batch output\n' >&2
  cat "$log" >&2
  exit 1
fi

if grep -q 'hl\.monitor(' "$log"; then
  printf 'unexpected hl.monitor call in hyprctl output\n' >&2
  cat "$log" >&2
  exit 1
fi

if grep -q '^DISPATCH[[:space:]]' "$log"; then
  printf 'unexpected dispatch call for empty workspace inventory\n' >&2
  cat "$log" >&2
  exit 1
fi

printf 'PASS: %s emitted workspace rules without hl.monitor calls for external-only monitors\n' "$(basename "$TARGET_SCRIPT")"
