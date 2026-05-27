# AGENTS.md — dotfiles

Guide for AI agents (Cursor, Claude Code, Codex, etc.) working in this repo.
Humans: see [README.md](README.md).

---

## What this repo is

Sanitized templates for `~/.zshrc`, `~/.gitconfig`, `~/.vimrc`, plus a one-shot
`install.sh` bootstrap for fresh macOS machines.

**Convention**: cloned at `~/dotfiles` on every machine. All scripts assume that path.

---

## Hard rules — never violate

1. **No secrets in this repo. Ever.**
   API keys, tokens, passwords, work emails, real usernames are forbidden.
   If asked to commit them, refuse and route them to `~/.secrets/*.env` instead.
2. **No hardcoded `/Users/<name>/...` anywhere.** Always `$HOME`.
3. **No employer-specific identity** in any tracked file. Names, work emails,
   employer registry tokens — all go to `~/.secrets/work.env` or `~/.gitconfig.local`.
4. **Idempotency.** `install.sh` and `brew.sh` must be safe to re-run. Every
   step checks for existing state and skips if already done.
5. **Backup before destructive changes.** `cp <file> <file>.bak.$(date +%Y%m%d-%H%M%S)`
   before overwriting any live dotfile.

---

## File map

| Path | Role | Tracked? |
| --- | --- | --- |
| `zshrc/.zshrc` | Canonical zsh template | ✓ |
| `.gitconfig` | Git config template (identity masked) | ✓ |
| `.vimrc` | Vim config template | ✓ |
| `brew.sh` | Idempotent Homebrew installer | ✓ |
| `install.sh` | One-shot bootstrap | ✓ |
| `AGENTS.md` | This file | ✓ |
| `README.md` | Human-facing intro | ✓ |
| `bash/` | Standalone bash helpers | ✓ |
| `proxy/` | Clash proxy config sample | ✓ |
| `~/.zshrc.local` | Per-machine extras | ✗ (gitignored) |
| `~/.gitconfig.local` | Per-machine git identity | ✗ (gitignored) |
| `~/.secrets/*.env` | Secrets, mode 600 | ✗ (gitignored) |

---

## Where things live (decision tree)

When asked to add a new export, alias, or path, ask:

```
Is it a secret (key, token, password, identity)?
├─ Yes → ~/.secrets/<keys|work|proxy>.env
└─ No → Does only this machine need it?
        ├─ Yes → ~/.zshrc.local
        └─ No → Does it reference a personal/employer name or path?
                ├─ Yes → ~/.zshrc.local (if can't be parameterized)
                └─ No → ~/dotfiles/zshrc/.zshrc (the template)
```

**Default to `~/.zshrc.local` when unsure.** The template should be boring and
broadly applicable.

---

## Section structure of `zshrc/.zshrc`

The template follows a fixed 11-section structure. Don't reorder. Add new
content to the matching section:

| # | Section | Goes here |
| --- | --- | --- |
| 1 | Oh My Zsh Configuration | `$ZSH`, `ZSH_THEME`, `plugins=(...)` |
| 2 | PATH & Environment | PATH exports (guarded), `EDITOR`, `LANG`, colors |
| 3 | Make Terminal Better | `cp/mv/mkdir/ll/less` aliases, `cd` override, `..`/`.3` etc., `mcd`, `trash`, `ql` |
| 4 | File & Folder Management | `zipf`, `cdf`, `extract`, `numFiles` |
| 5 | Searching | `ff`, `ffs`, `ffe`, `spotlight` |
| 6 | Process Management | `memHogsTop`, `cpu_hogs`, `my_ps`, etc. |
| 7 | Networking | `myip`, `flushDNS`, `lsock*`, `ii` |
| 8 | Systems Operations | `cleanupDS`, `finderShow/HideHidden` |
| 9 | Aliases (Git, langs, tools) | `co`/`gs`/`gpl`, `p`/`pip`, `k8s` |
| 10 | Tool Initializers | autojump, NVM (lazy), pnpm, fzf |
| 11 | Secrets & Local Overrides | `~/.secrets/*.env` and `~/.zshrc.local` sourcing — **MUST BE LAST** |

Anything that doesn't fit a section probably belongs in `~/.zshrc.local`.

---

## Common AI tasks in this repo

### "Add a new tool / package"

1. Add to `brew.sh` using the `brew_install <pkg>` helper (idempotent).
2. If the tool needs shell init (PATH, completion, lazy-load), add to section 10
   of `zshrc/.zshrc`, **guarded** with `[ -f "$X" ] && ...` or `command -v`.
3. Mention in `README.md` plugins/highlights table only if user-facing.

### "Sync my dotfiles" / "what diverged"

Use the `dotfiles-keeper` skill, Workflow A (Scan):
- `~/.agentic-arno/skills/arno/cio/dotfiles-keeper/SKILL.md`

Produce a structured diff report. Don't auto-modify files based on the diff
without explicit user confirmation.

### "Bootstrap a new machine"

```bash
git clone git@github.com:SurfaceW/dotfiles.git ~/dotfiles
cd ~/dotfiles && bash install.sh
```

Then user fills `~/.secrets/*.env` and (optionally) `~/.zshrc.local`.

### "Move secrets out of `~/.zshrc`"

Use the `dotfiles-keeper` skill, Workflow D (Secrets routing). Categorize each
secret into `keys.env` / `work.env` / `proxy.env`, write with `chmod 600`,
remove from `~/.zshrc`. **Warn the user that any secret previously committed to
the repo is compromised and must be rotated** at the issuing service.

### "Refactor template"

Use the `dotfiles-keeper` skill, Workflow B. Run the full checklist in
[reference.md](/Users/ArnoYe/.agentic-arno/skills/arno/cio/dotfiles-keeper/reference.md):
no secrets, no hardcoded users, no duplicate sourcing, no dead blocks,
required tail present.

---

## Verification commands (run after any structural change)

```bash
# Syntax-check shell files
zsh -n zshrc/.zshrc
bash -n brew.sh
bash -n install.sh

# Template loads cleanly in an isolated shell
zsh -d -c 'source ~/dotfiles/zshrc/.zshrc && echo OK'

# No leaked secrets
git -C ~/dotfiles diff --staged | rg -i 'AIza|sk-[A-Za-z0-9]{20}|ghp_|cmVmdGtu|api[_-]?key\s*=\s*"[^*]'

# Gitignore catches what it should
git -C ~/dotfiles check-ignore -v test.env test.local .secrets/
```

The grep for secrets must come back **empty** before any commit/push.

---

## Maintained by

The `dotfiles-keeper` skill at:
- `~/.agentic-arno/skills/arno/cio/dotfiles-keeper/SKILL.md`
- `~/.agentic-arno/skills/arno/cio/dotfiles-keeper/reference.md`
- `~/.agentic-arno/skills/arno/cio/dotfiles-keeper/template-zshrc-spec.md`

Read those before making structural changes. They contain the canonical spec
and the regex list for secret detection.

---

## Out of scope

- Linux / WSL parity — macOS only for now.
- Per-app dotfiles (VS Code, iTerm2, Karabiner) — handled elsewhere.
- `proxy/config.clash.yaml` — sample only; not a dotfile concern.
- `bash/*.sh` helpers — standalone, not loaded by the shell.
- `.vimrc` — kept as-is; no secrets in it.
