# gh install

This [gh](https://github.com/cli/cli) extension helps you install binaries and .deb releases interactively from GitHub repos.

[![asciicast](https://asciinema.org/a/7XniSZ3FyskFz3iZvhyCcwe1c.svg)](https://asciinema.org/a/7XniSZ3FyskFz3iZvhyCcwe1c)

## Install

```bash
gh extension install redraw/gh-install
```

## Usage

### Interactive mode (default)

```bash
gh install <user>/<repo>
```

The interactive mode will prompt you to select:
- Version to install
- Asset file to download
- Binary to extract (if archive)
- Name for the installed binary

Optional: For fuzzy search support, install [fzf](https://github.com/junegunn/fzf)

### Auto mode (for scripts and CI/CD)

```bash
gh install <user>/<repo> --auto
```

Auto mode automatically detects your platform (OS and architecture) and installs the latest version without prompts.

**Examples:**

```bash
# Auto-detect everything (version, OS, architecture, binary name)
gh install cli/cli --auto

# Auto-detect with specific version
gh install cli/cli --auto --version v2.40.0

# Auto-detect with pattern to choose variant (musl vs gnu, etc)
gh install BurntSushi/ripgrep --auto --pattern '*.tar.gz$'

# Auto-detect with custom binary name
gh install sharkdp/fd --auto --name fdfind
```

**Options:**
- `-a, --auto` - Enable non-interactive mode with auto-detection
- `-v, --version <tag|latest>` - Version to install (default: latest in auto mode)
- `-p, --pattern <glob>` - Asset filename pattern to narrow down matches
- `-n, --name <name>` - Binary name (default: auto-detect from filename)
- `-h, --help` - Show help message

## Environment variables
- `$GH_BINPATH` - Path to install binaries, defaults to `$HOME/.local/bin`
