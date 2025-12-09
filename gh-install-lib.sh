#!/bin/bash
# gh-install auto-mode helper library
# Sourced by gh-install when --auto flag is used
#
# Expects these globals from main script:
#   REPO, FLAG_VERSION, FLAG_PATTERN, FLAG_NAME

# Platform detection variables
OS_NAME=""
OS_ALIASES=""
ARCH_NAME=""
ARCH_ALIASES=""

detect_platform() {
    local os=$(uname -s | tr '[:upper:]' '[:lower:]')
    local arch=$(uname -m)

    # Normalize OS names
    case "$os" in
        linux)
            OS_NAME="linux"
            OS_ALIASES="linux"
            ;;
        darwin)
            OS_NAME="darwin"
            OS_ALIASES="darwin|macos|osx|mac|apple"
            ;;
        mingw*|msys*|cygwin*)
            OS_NAME="windows"
            OS_ALIASES="windows|win64|win32|win"
            ;;
        *)
            OS_NAME="$os"
            OS_ALIASES="$os"
            ;;
    esac

    # Normalize architecture names
    case "$arch" in
        x86_64|amd64)
            ARCH_NAME="x86_64"
            ARCH_ALIASES="amd64|x86_64|x64"
            ;;
        aarch64|arm64)
            ARCH_NAME="arm64"
            ARCH_ALIASES="arm64|aarch64"
            ;;
        armv7l|armv6l)
            ARCH_NAME="arm"
            ARCH_ALIASES="arm|armv7|armv6"
            ;;
        i386|i686)
            ARCH_NAME="i386"
            ARCH_ALIASES="i386|i686|x86"
            ;;
        *)
            ARCH_NAME="$arch"
            ARCH_ALIASES="$arch"
            ;;
    esac
}

auto_select_version() {
    # Uses globals: REPO, FLAG_VERSION
    if [ -n "$FLAG_VERSION" ]; then
        echo "$FLAG_VERSION"
    else
        gh api "repos/$REPO/releases/latest" -q ".tag_name"
    fi
}

auto_select_asset() {
    # Uses globals: FLAG_PATTERN
    local assets="$1"  # Newline-separated list (must be passed)

    # Filter by OS first
    local os_matches=$(echo "$assets" | grep -iE "$OS_ALIASES" || true)

    if [ -z "$os_matches" ]; then
        echo "Error: No assets found for OS: $OS_NAME" >&2
        echo "Available assets:" >&2
        echo "$assets" | sed 's/^/  /' >&2
        return 1
    fi

    # Filter by architecture
    local matched=$(echo "$os_matches" | grep -iE "$ARCH_ALIASES" || true)

    if [ -z "$matched" ]; then
        echo "Error: No assets found for $OS_NAME $ARCH_NAME" >&2
        echo "Assets matching OS ($OS_NAME):" >&2
        echo "$os_matches" | sed 's/^/  /' >&2
        return 1
    fi

    # If pattern provided, narrow down further
    if [ -n "$FLAG_PATTERN" ]; then
        # Convert glob pattern to grep pattern (* -> .*, ? -> .)
        local grep_pattern=$(echo "$FLAG_PATTERN" | sed 's/\*/.*/g' | sed 's/?/./g')
        local narrowed=$(echo "$matched" | grep -E "$grep_pattern" || true)

        if [ -z "$narrowed" ]; then
            echo "Error: No platform matches satisfy pattern: $FLAG_PATTERN" >&2
            echo "Platform matches:" >&2
            echo "$matched" | sed 's/^/  /' >&2
            return 1
        fi

        matched="$narrowed"
    fi

    # Exclude checksum/signature files
    matched=$(echo "$matched" | grep -vE '\.(sha256|sha512|sig|asc)$' || echo "$matched")

    # Count matches
    local count=$(echo "$matched" | wc -l | tr -d ' ')

    if [ "$count" -eq 1 ]; then
        echo "$matched"
        return 0
    fi

    # Multiple matches: prefer gnu over musl (more common on standard Linux)
    if [ "$count" -gt 1 ]; then
        local gnu_match=$(echo "$matched" | grep -i 'gnu' | head -n 1)
        if [ -n "$gnu_match" ]; then
            echo "$gnu_match"
            return 0
        fi
    fi

    # Still multiple matches, error out
    echo "Error: Multiple assets match platform ($count found):" >&2
    echo "$matched" | sed 's/^/  /' >&2
    echo "" >&2
    if [ -z "$FLAG_PATTERN" ]; then
        echo "Use --pattern to narrow down (e.g., --pattern '*musl*' or --pattern '*.tar.gz')" >&2
    else
        echo "Pattern '$FLAG_PATTERN' still matches multiple files. Be more specific." >&2
    fi
    return 1
}

auto_select_binary() {
    local filename="$1"

    # Find executable file automatically
    local bin=$(find . -type f -not -path "*$filename" -executable | head -n 1)

    if [ -z "$bin" ]; then
        # No executable found, try to find any binary file
        bin=$(find . -type f -not -path "*$filename" | head -n 1)
    fi

    if [ -z "$bin" ]; then
        echo "Error: No binary found in archive" >&2
        return 1
    fi

    echo "$bin"
}

auto_select_name() {
    # Uses globals: FLAG_NAME
    local binary_path="$1"  # Must be passed (computed at runtime)

    if [ -n "$FLAG_NAME" ]; then
        echo "$FLAG_NAME"
    else
        basename "$binary_path"
    fi
}
