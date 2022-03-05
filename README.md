# gh install

This [gh](https://github.com/cli/cli) extension helps you install binaries and .deb releases interactively from GitHub repos.

[![asciicast](https://asciinema.org/a/7XniSZ3FyskFz3iZvhyCcwe1c.svg)](https://asciinema.org/a/7XniSZ3FyskFz3iZvhyCcwe1c)

## Install

```bash
gh extension install redraw/gh-install
```

## Usage

```bash
gh install <user>/<repo>
```

Optional: For fuzzy search support, install [fzf](https://github.com/junegunn/fzf)

## Environment variables
- `$GH_BINPATH` path to install binaries, defaults to `$HOME/.local/bin`
