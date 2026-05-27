# Changelog

All notable changes to this dotfiles repo are documented here.

Format inspired by [Keep a Changelog](https://keepachangelog.com/).
Entries are date-stamped (no semver — this is a personal dotfiles repo).

**Maintenance rule**: every PR or direct change to this repo must update this
file in the same commit. AI agents working in this repo (Cursor, Claude Code,
Codex, etc.) must do the same — see [AGENTS.md](AGENTS.md).

Categories: **Added**, **Changed**, **Deprecated**, **Removed**, **Fixed**, **Security**.

---

## [Unreleased]

### Added
- `CHANGELOG.md` — this file. Establishes the convention going forward.
- `AGENTS.md` § **Changelog discipline** — rules + table of when an entry is
  required, good vs. bad examples, date-stamping protocol.
- `AGENTS.md` file map — added `CHANGELOG.md` row.
- `AGENTS.md` verification commands — added a CHANGELOG-in-commit guard.

### Changed
- `AGENTS.md` hard rules — added rule #6: every modification to a tracked file
  requires a `CHANGELOG.md` entry in the same change.
- External skill `dotfiles-keeper` (in `~/.agentic-arno/`) — Workflow B and
  Anti-patterns updated to enforce the CHANGELOG step.

---

## 2026-05-27 — Sanitize, modularize, AI-co-working ready

First structured release. Repo refactored end-to-end to become a sanitized
template that can be applied to any macOS machine via `install.sh`, with
secrets routed to `~/.secrets/*.env` and per-machine extras in `~/.zshrc.local`
/ `~/.gitconfig.local`.

### Added

- **`AGENTS.md`** — AI co-working guide. Hard rules, file map, decision tree
  for where new content goes, 11-section structure of `zshrc/.zshrc`, common
  AI tasks, verification commands.
- **`install.sh`** — one-shot idempotent bootstrap. 9 steps: Xcode CLT,
  Homebrew, `brew.sh`, oh-my-zsh, external zsh plugins, symlink templates,
  scaffold `~/.secrets/` (mode 700 with `*.env.example` placeholders),
  create empty `~/.zshrc.local`, set zsh as default shell.
- **`CHANGELOG.md`** — this file.
- **External skill** `dotfiles-keeper` at
  `~/.agentic-arno/skills/arno/cio/dotfiles-keeper/` (SKILL.md, reference.md,
  template-zshrc-spec.md) — the maintenance brain for this repo.

### Changed

- **`zshrc/.zshrc`** — full refactor, 479 → 290 lines:
  - `export ZSH=/Users/arno/.oh-my-zsh` → `export ZSH="$HOME/.oh-my-zsh"`
    (no hardcoded usernames anywhere).
  - Removed duplicate `source $ZSH/oh-my-zsh.sh` (was called twice).
  - Section structure formalized into 11 numbered sections (Oh My Zsh,
    PATH & Env, Terminal, File mgmt, Searching, Process, Networking, System,
    Aliases, Tool initializers, Secrets & Local overrides).
  - NVM is now **lazy-loaded** (saves ~250 ms shell startup) via stubs for
    `nvm`, `node`, `npm`, `npx`.
  - `PNPM_HOME` uses `$HOME` not `/Users/arno`.
  - `JAVA_HOME` now auto-detected via `/usr/libexec/java_home`, guarded.
  - Plugins list ends with `zsh-syntax-highlighting` (per upstream guidance).
  - Trailing `true` ensures `source ~/.zshrc` returns exit 0 even when
    `~/.zshrc.local` is absent.
  - Tail sources `~/.secrets/*.env` (any file) and `~/.zshrc.local` if present.
- **`brew.sh`** — rewrite as idempotent installer:
  - Fixed typos: `homebrew/depes` → dropped (deprecated), `--overide-system-vi` → dropped.
  - Removed dead refs: `homebrew/php/php55`, GHC.
  - Added modern essentials: `ripgrep`, `fd`, `fzf`, `jq`, `yq`, `gh`, `tldr`,
    `htop`, `tree`, `coreutils`, `pnpm`, `nvm`, `python@3.13`.
  - All installs idempotent: `brew list <pkg> &>/dev/null || brew install <pkg>`.
- **`.gitconfig`** — sanitized:
  - Real identity replaced with `****` / `****@****` placeholders.
  - `excludesfile = /Users/yeqingnan/.gitignore_global` → `~/.gitignore_global`.
  - Added `[include] path = ~/.gitconfig.local` so each machine sets identity locally.
  - Added `[pull] rebase = false` and `[init] defaultBranch = main`.
  - Dropped unused `media` and `hawser` filters; kept `lfs`.
- **`.gitignore`** — now excludes `*.local`, `.gitconfig.local`, `.zshrc.local`,
  `.secrets/`, `*.env` (with `!*.env.example` allow), and `*.bak.*`.
- **`README.md`** — rewritten:
  - Install one-liner: `git clone … ~/dotfiles && cd ~/dotfiles && bash install.sh`.
  - Convention table (template / machine-local / secrets).
  - Pointer to the `dotfiles-keeper` skill for AI-assisted maintenance.
  - Highlight aliases & functions table.

### Removed

- Dead blocks from `zshrc/.zshrc`: GHC 7.10.3, PHP 5.6, Alibaba `tnpm`/`alic`
  aliases, `~/Library/init/bash/aliases.bash` reference, hardcoded
  `/usr/local/mysql/bin` PATH, V2Ray proxy forced exports.

### Security

- **Identity de-leak**: real name `磬楠` and email `qingnan.yqn@alibaba-inc.com`
  removed from the tracked `.gitconfig`. Per-machine identity now lives in
  the gitignored `~/.gitconfig.local`.
- **Secrets routing**: documented the `~/.secrets/*.env` convention
  (mode 600, gitignored, auto-sourced by the template).
- **Gitignore reinforced**: `*.env`, `.secrets/`, `*.local`, `*.bak.*` now
  excluded.
- **Live-machine migration** (run on Arno's machine, not part of this repo):
  - `GEMINI_API_KEY`, `FMP_API_KEY` moved from `~/.zshrc` into
    `~/.secrets/keys.env` (chmod 600).
  - `IDENTITY_TOKEN` (JFrog), `USER`, `UV_DEFAULT_INDEX` moved into
    `~/.secrets/work.env` (chmod 600).
  - Reminder issued: any of these keys ever committed historically must be
    rotated at the issuing service.

### Known issues / follow-ups

- `~/dotfiles/zshrc/.zshrc.old` (legacy snapshot, 18 KB) is still present in
  the repo. Safe to delete on next pass — git history preserves it.
- Older commits in the public `SurfaceW/dotfiles` GitHub history still
  contain the Alibaba identity (in commit authorship and `.gitconfig` blob
  content). Rewriting public history is out of scope unless explicitly requested.

---

## Before 2026-05-27

See `git log` for raw history. Notable pre-changelog commits:

- `3fb2d08` remove unused ones
- `a381f41` ✨ (bash) batch-remove.sh
- `2c43b97` ✨ (bash) add diff.sh
- `e7d5ac9` Update .zshrc
- `2ec7542` Update .zshrc

No structured changelog was kept prior to this date.
