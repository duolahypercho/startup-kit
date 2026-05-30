#!/usr/bin/env bash
set -uo pipefail

# Installs the Stripe CLI, used by references/payments.md to test webhooks
# locally (`stripe listen`), trigger events, and call the API from the terminal.
#
# Installed via its OFFICIAL methods (https://docs.stripe.com/stripe-cli):
#   macOS / Linux (Homebrew)   brew install stripe/stripe-cli/stripe
#   Linux (no brew)            download the official release tarball from GitHub
#   Windows                    scoop install stripe   (printed as guidance)
#
# There is no official npm package for the Stripe CLI. Best-effort and
# idempotent: re-run any time to (re)install. Usage:
#   scripts/install-stripe-cli.sh

have() { command -v "$1" >/dev/null 2>&1; }

REPO="stripe/stripe-cli"

# --- Pick an install dir on PATH we can write to, else fall back to ~/.stripe/bin. ---
target_bin_dir() {
  if [ -w "/usr/local/bin" ]; then echo "/usr/local/bin"; return; fi
  if [ -d "$HOME/.local/bin" ]; then echo "$HOME/.local/bin"; return; fi
  echo "$HOME/.stripe/bin"
}

# --- Map uname to the Stripe release asset suffix (matches their naming). ---
asset_suffix() {
  os="$(uname -s)"; arch="$(uname -m)"
  case "$os" in
    Darwin) os_part="mac-os" ;;
    Linux)  os_part="linux" ;;
    *)      return 1 ;;
  esac
  case "$arch" in
    x86_64|amd64) arch_part="x86_64" ;;
    arm64|aarch64) arch_part="arm64" ;;
    *) return 1 ;;
  esac
  echo "${os_part}_${arch_part}.tar.gz"
}

# --- Resolve the latest release tarball URL for this platform (no jq needed). ---
latest_tarball_url() {
  suffix="$1"
  curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" \
    | grep -o "https://[^\"]*stripe_[0-9.]*_${suffix}" \
    | head -1
}

install_brew() {
  have brew || return 1
  echo "Installing Stripe CLI (Homebrew)..."
  brew install stripe/stripe-cli/stripe
}

install_tarball() {
  have curl || { echo "Stripe: curl not found; cannot download release."; return 1; }
  have tar  || { echo "Stripe: tar not found; cannot extract release.";   return 1; }

  suffix="$(asset_suffix)" || { echo "Stripe: unsupported OS/arch ($(uname -s)/$(uname -m))."; return 1; }
  url="$(latest_tarball_url "$suffix")"
  [ -n "$url" ] || { echo "Stripe: could not find a release asset for ${suffix}."; return 1; }

  bindir="$(target_bin_dir)"
  mkdir -p "$bindir" || return 1

  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' RETURN

  echo "Downloading $(basename "$url")..."
  curl -fsSL "$url" -o "$tmp/stripe.tar.gz" || { echo "Stripe: download failed."; return 1; }
  tar -xzf "$tmp/stripe.tar.gz" -C "$tmp" || { echo "Stripe: extract failed."; return 1; }
  [ -f "$tmp/stripe" ] || { echo "Stripe: binary not found in archive."; return 1; }

  install -m 0755 "$tmp/stripe" "$bindir/stripe" 2>/dev/null || {
    mv "$tmp/stripe" "$bindir/stripe" && chmod 0755 "$bindir/stripe";
  } || { echo "Stripe: failed to place binary in $bindir."; return 1; }

  echo "  Installed to $bindir/stripe"
  case ":$PATH:" in
    *":$bindir:"*) : ;;
    *) echo "  Add it to your PATH:"; echo "    export PATH=\"$bindir:\$PATH\"" ;;
  esac
}

STRIPE_OK=1

if install_brew; then
  :
elif [ "$(uname -s)" = "Linux" ] || [ "$(uname -s)" = "Darwin" ]; then
  install_tarball || STRIPE_OK=0
else
  STRIPE_OK=0
fi

if [ "$STRIPE_OK" -ne 1 ]; then
  echo
  echo "Stripe CLI not installed automatically. Install it with one of:"
  echo "  - macOS/Linux:  brew install stripe/stripe-cli/stripe"
  echo "  - Windows:      scoop install stripe   (after: scoop bucket add stripe-cli https://github.com/stripe/scoop-stripe-cli.git)"
  echo "  - Any OS:       download a release from https://github.com/stripe/stripe-cli/releases/latest"
  echo "  Docs: https://docs.stripe.com/stripe-cli"
fi

echo
echo "Install summary:"
if have stripe; then
  echo "  stripe    installed  ($(stripe --version 2>/dev/null | head -1 || echo '?'))"
else
  echo "  stripe    not installed (see options above; you may need to open a new shell for PATH changes)"
fi

echo
echo "Next, connect the CLI to your account and test webhooks locally:"
echo "  stripe login                                   # authorize this machine"
echo "  stripe listen --forward-to localhost:3000/api/webhooks/stripe"
echo "  stripe trigger checkout.session.completed      # fire a test event"
echo
echo "See references/payments.md for the Checkout + webhook flow."

# Exit non-zero only if the install clearly failed and stripe is absent.
have stripe || [ "$STRIPE_OK" -eq 1 ]
