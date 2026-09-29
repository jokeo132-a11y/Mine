#!/usr/bin/env bash
set -Eeuo pipefail
KEY="${1:-$HOME/.ssh/id_ed25519}"
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
if [[ ! -f "$KEY" ]]; then
  echo "No SSH key found at $KEY. Create one with:"
  echo "  ssh-keygen -t ed25519 -f '$KEY' -C 'your-email@example.com'"
  echo "Then add the .pub file to GitHub: https://github.com/settings/keys"
  exit 1
fi
ssh-keyscan -H github.com >> "$HOME/.ssh/known_hosts" 2>/dev/null || true
chmod 600 "$HOME/.ssh/known_hosts"
printf 'Public key to add to GitHub:\n\n'
cat "$KEY.pub"
printf '\nTesting SSH authentication (GitHub may return a normal code 1 greeting):\n'
ssh -o BatchMode=yes -T git@github.com || true
