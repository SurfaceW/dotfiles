#!/usr/bin/env bash
#
# install.sh — one-shot bootstrap for ~/dotfiles
#
# Convention: this repo is cloned to ~/dotfiles on every machine.
# Re-running is safe: every step checks for existing state and skips.
#
# Usage:
#   git clone git@github.com:SurfaceW/dotfiles.git ~/dotfiles
#   cd ~/dotfiles && bash install.sh

set -uo pipefail

DOTFILES="$HOME/dotfiles"
TS="$(date +%Y%m%d-%H%M%S)"

if [ ! -d "$DOTFILES" ]; then
  echo "✗ Expected repo at $DOTFILES — clone it there first."
  exit 1
fi

cd "$DOTFILES"

step() { echo ""; echo "→ $*"; }
ok()   { echo "  ✓ $*"; }
warn() { echo "  ! $*"; }

#   -------------------------------
#   1. Xcode Command Line Tools
#   -------------------------------
step "1/9  Xcode Command Line Tools"
if xcode-select -p &>/dev/null; then
  ok "already installed"
else
  warn "triggering install — finish the GUI prompt, then re-run this script"
  xcode-select --install || true
  exit 1
fi

#   -------------------------------
#   2. Homebrew
#   -------------------------------
step "2/9  Homebrew"
if command -v brew &>/dev/null; then
  ok "already installed at $(command -v brew)"
else
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Apple Silicon: Homebrew lives at /opt/homebrew and may not be on PATH yet
  if [ -x "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
fi

#   -------------------------------
#   3. Brew formulae
#   -------------------------------
step "3/9  Brew formulae (running brew.sh)"
bash "$DOTFILES/brew.sh"

#   -------------------------------
#   4. Oh My Zsh
#   -------------------------------
step "4/9  Oh My Zsh"
if [ -d "$HOME/.oh-my-zsh" ]; then
  ok "already installed"
else
  RUNZSH=no CHSH=no sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

#   -------------------------------
#   5. Zsh plugins (external)
#   -------------------------------
step "5/9  zsh-autosuggestions, zsh-syntax-highlighting"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

clone_plugin() {
  local name="$1" url="$2"
  local dir="$ZSH_CUSTOM/plugins/$name"
  if [ -d "$dir" ]; then
    ok "$name already cloned"
  else
    git clone --depth=1 "$url" "$dir"
  fi
}

clone_plugin zsh-autosuggestions     https://github.com/zsh-users/zsh-autosuggestions
clone_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting

#   -------------------------------
#   6. Symlink dotfiles
#   -------------------------------
step "6/9  Symlinking templates into \$HOME"

link_file() {
  local src="$1" dst="$2"
  if [ ! -e "$src" ]; then
    warn "missing source: $src — skipping"
    return
  fi
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    ok "$dst already linked"
    return
  fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mv "$dst" "$dst.bak.$TS"
    warn "backed up existing $dst → $dst.bak.$TS"
  fi
  ln -s "$src" "$dst"
  ok "linked $dst → $src"
}

link_file "$DOTFILES/zshrc/.zshrc" "$HOME/.zshrc"
link_file "$DOTFILES/.gitconfig"   "$HOME/.gitconfig"
link_file "$DOTFILES/.vimrc"       "$HOME/.vimrc"

#   -------------------------------
#   7. ~/.secrets scaffolding
#   -------------------------------
step "7/9  ~/.secrets scaffolding"

mkdir -p "$HOME/.secrets"
chmod 700 "$HOME/.secrets"

write_example() {
  local name="$1" body="$2"
  local f="$HOME/.secrets/${name}.env.example"
  if [ -e "$f" ]; then
    ok "$f already exists"
  else
    printf '%s\n' "$body" > "$f"
    chmod 600 "$f"
    ok "seeded $f"
  fi
}

write_example keys "# API keys — never commit, chmod 600
# Copy this file to keys.env and fill in real values.
export OPENAI_API_KEY=\"****\"
export ANTHROPIC_API_KEY=\"****\"
export GEMINI_API_KEY=\"****\"
export FMP_API_KEY=\"****\""

write_example work "# Work / employer-specific identity — never commit, chmod 600
# Copy this file to work.env and fill in real values.
export USER=\"****\"
export IDENTITY_TOKEN=\"****\"
# export UV_DEFAULT_INDEX=\"\$(pip config get global.index-url)\""

write_example proxy "# Proxy — never commit, chmod 600
# Copy this file to proxy.env if you use a local proxy (e.g. clash).
# Only sourced where the file exists, so absence is safe.
# export http_proxy=\"http://127.0.0.1:1087\"
# export https_proxy=\"http://127.0.0.1:1087\"
# export ALL_PROXY=\"socks5://127.0.0.1:1080\""

#   -------------------------------
#   8. ~/.zshrc.local
#   -------------------------------
step "8/9  ~/.zshrc.local"
if [ -e "$HOME/.zshrc.local" ]; then
  ok "already exists"
else
  cat > "$HOME/.zshrc.local" <<'EOF'
# ~/.zshrc.local — machine-local extras, gitignored.
# Use this for: per-machine PATHs, employer-specific aliases, scratch exports.
# Sourced from the tail of ~/.zshrc.
EOF
  ok "created empty $HOME/.zshrc.local"
fi

#   -------------------------------
#   9. Default shell
#   -------------------------------
step "9/9  Default shell"
ZSH_PATH="$(command -v zsh || echo /bin/zsh)"
if [ "$SHELL" = "$ZSH_PATH" ]; then
  ok "zsh is already the default ($SHELL)"
else
  warn "default shell is $SHELL"
  echo "  run: chsh -s $ZSH_PATH"
fi

echo ""
echo "✓ install.sh complete."
echo ""
echo "Next steps:"
echo "  1. cp ~/.secrets/keys.env.example  ~/.secrets/keys.env  && \$EDITOR ~/.secrets/keys.env"
echo "  2. cp ~/.secrets/work.env.example  ~/.secrets/work.env  && \$EDITOR ~/.secrets/work.env"
echo "  3. cp ~/.secrets/proxy.env.example ~/.secrets/proxy.env && \$EDITOR ~/.secrets/proxy.env  # if needed"
echo "  4. \$EDITOR ~/.zshrc.local  # for machine-specific extras"
echo "  5. Open a new terminal."
