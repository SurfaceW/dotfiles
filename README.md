# dotfiles

Sanitized templates for `~/.zshrc`, `~/.gitconfig`, `~/.vimrc`, plus a one-shot
bootstrap for a fresh macOS.

## Convention

This repo is cloned at **`~/dotfiles`** on every machine. All scripts assume
that path.

| File / dir | Role |
| --- | --- |
| `zshrc/.zshrc` | Canonical zsh template (sanitized; symlinked to `~/.zshrc`) |
| `.gitconfig` | Git config template (identity masked; symlinked to `~/.gitconfig`) |
| `.vimrc` | Vim config template (symlinked to `~/.vimrc`) |
| `brew.sh` | Idempotent Homebrew installer |
| `install.sh` | One-shot bootstrap (Xcode CLT → brew → oh-my-zsh → plugins → symlinks) |
| `bash/` | Standalone bash helpers (`batch-remove.sh`, `diff.sh`) |
| `proxy/` | Clash proxy config sample |

## Install

```bash
git clone git@github.com:SurfaceW/dotfiles.git ~/dotfiles
cd ~/dotfiles && bash install.sh
```

The script is idempotent — safe to re-run. It backs up any existing
`~/.zshrc` / `~/.gitconfig` / `~/.vimrc` to `*.bak.<timestamp>` before
symlinking.

## Secrets policy

**No secrets in this repo. Ever.**

Secrets live in `~/.secrets/*.env` (mode `600`), gitignored. The template
sources every `~/.secrets/*.env` from its tail. `install.sh` seeds three
example files:

| File | Contents |
| --- | --- |
| `~/.secrets/keys.env` | API keys (`OPENAI_API_KEY`, `GEMINI_API_KEY`, etc.) |
| `~/.secrets/work.env` | Employer identity (`USER`, `IDENTITY_TOKEN`, registry tokens) |
| `~/.secrets/proxy.env` | Local proxy URLs (`http_proxy`, `ALL_PROXY`) |

After install:

```bash
cp ~/.secrets/keys.env.example ~/.secrets/keys.env
$EDITOR ~/.secrets/keys.env   # fill in real values
```

## Per-machine overrides

| File | Purpose |
| --- | --- |
| `~/.zshrc.local` | Per-machine PATHs, employer-specific aliases, scratch exports |
| `~/.gitconfig.local` | Per-machine git identity (name / email / signing key) |

Both are gitignored, sourced from the tail of their respective templates.

## Maintenance

This repo is maintained with the `dotfiles-keeper` skill at
`~/.agentic-arno/skills/arno/cio/dotfiles-keeper/SKILL.md`. The skill
covers:

- **Scan** — diff live machine vs template, detect secrets and dead code.
- **Refactor** — promote reusable bits from the live machine to the template.
- **Apply / migrate** — bring a live machine in line with the template safely.
- **Secrets routing** — move secrets out of any committed file into `~/.secrets/`.
- **Bootstrap** — what `install.sh` runs on a fresh machine.

## Plugins (oh-my-zsh)

Default `plugins=(...)` in the template:

| Plugin | Source | Notes |
| --- | --- | --- |
| `git`, `macos`, `wd`, `copyfile`, `history`, `last-working-dir` | builtin | Always on |
| `autojump` | builtin | Requires `brew install autojump` (handled by `brew.sh`) |
| `zsh-autosuggestions` | external | Cloned by `install.sh` |
| `zsh-syntax-highlighting` | external | Cloned by `install.sh`; **must be last** |

## Highlight aliases & functions

Pulled from the template; full list in `zshrc/.zshrc`.

| Command | Description |
| --- | --- |
| `ll` | Detailed listing (`ls -FGlAhp`) |
| `..`, `...`, `.3`–`.6` | Walk up N directories |
| `f` | Open current dir in Finder |
| `mcd <dir>` | `mkdir -p` then `cd` |
| `trash <file>` | Move to macOS Trash |
| `extract <archive>` | Unpack `.tar.gz`, `.zip`, `.7z`, etc. |
| `ff`, `ffs`, `ffe` | Find file by name / prefix / suffix |
| `cdf` | `cd` to frontmost Finder window |
| `myip`, `flushDNS`, `openPorts`, `ii` | Networking helpers |
| `gs`, `co`, `br`, `gpl`, `gps` | Git shortcuts |

## License

Personal config. Use what's useful.
