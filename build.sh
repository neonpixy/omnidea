#!/usr/bin/env bash
set -e

# ──────────────────────────────────────────────
# Omnidea Build Script
# Builds all repos in dependency order:
#   Omninet (protocol) -> Library (shared packages) -> Chancellor (daemon) -> Throne (shell)
#   Covenant is prose — no build step
#   Apps are built by Throne's build.ts automatically
# ──────────────────────────────────────────────

ROOT="$(cd "$(dirname "$0")" && pwd)"

# Colors (disabled if not a terminal)
if [ -t 1 ]; then
    BOLD="\033[1m"
    GREEN="\033[32m"
    YELLOW="\033[33m"
    RED="\033[31m"
    DIM="\033[2m"
    RESET="\033[0m"
else
    BOLD="" GREEN="" YELLOW="" RED="" DIM="" RESET=""
fi

info()  { echo -e "${BOLD}==> $1${RESET}"; }
ok()    { echo -e "${GREEN}==> $1${RESET}"; }
warn()  { echo -e "${YELLOW}==> $1${RESET}"; }
fail()  { echo -e "${RED}==> $1${RESET}"; exit 1; }
dim()   { echo -e "${DIM}    $1${RESET}"; }

# ── Parse flags ──────────────────────────────

CLEAN=false
DEV=false

for arg in "$@"; do
    case "$arg" in
        --clean) CLEAN=true ;;
        --dev)   DEV=true ;;
        --help|-h)
            echo "Usage: ./build.sh [--clean] [--dev]"
            echo ""
            echo "  --clean  Wipe build artifacts before building (dist, node_modules, target)"
            echo "  --dev    Build debug binaries instead of release (faster)"
            echo ""
            exit 0
            ;;
        *) fail "Unknown flag: $arg (try --help)" ;;
    esac
done

CARGO_PROFILE="--release"
if [ "$DEV" = true ]; then
    CARGO_PROFILE=""
fi

# ── Check required tools ──────────────────────

info "Checking required tools..."

command -v cargo >/dev/null 2>&1 || fail "cargo not found. Install Rust: https://rustup.rs"
command -v npm   >/dev/null 2>&1 || fail "npm not found. Install Node.js: https://nodejs.org"
command -v node  >/dev/null 2>&1 || fail "node not found. Install Node.js: https://nodejs.org"

ok "Tools: cargo $(cargo --version | cut -d' ' -f2), npm $(npm --version), node $(node --version)"

# ── Check submodules ──────────────────────────

info "Checking submodules..."

MISSING=false
[ ! -f "$ROOT/Omninet/Cargo.toml" ] && MISSING=true
[ ! -f "$ROOT/Library/package.json" ] && MISSING=true
[ ! -f "$ROOT/Omny/chancellor/chancellor/Cargo.toml" ] && MISSING=true
[ ! -f "$ROOT/Omny/throne/src-tauri/Cargo.toml" ] && MISSING=true

if [ "$MISSING" = true ]; then
    info "Initializing submodules..."
    git -C "$ROOT" submodule update --init --recursive
fi

# ── Clean (optional) ─────────────────────────

if [ "$CLEAN" = true ]; then
    warn "Cleaning build artifacts..."

    dim "Omninet target/"
    rm -rf "$ROOT/Omninet/target"

    dim "Library node_modules/ + dist/"
    rm -rf "$ROOT/Library/node_modules"
    for pkg in crystal net ui editor fx; do
        rm -rf "$ROOT/Library/$pkg/dist"
    done

    dim "Chancellor target/"
    rm -rf "$ROOT/Omny/chancellor/target"

    dim "Throne node_modules/ + dist/ + target/"
    rm -rf "$ROOT/Omny/throne/node_modules"
    rm -rf "$ROOT/Omny/throne/dist"
    rm -rf "$ROOT/Omny/throne/src-tauri/target"

    ok "Clean complete."
fi

# ── 1. Omninet (protocol) ────────────────────

info "Building Omninet (protocol)..."
(cd "$ROOT/Omninet" && cargo build --workspace $CARGO_PROFILE)
ok "Omninet built."

# ── 2. Library (shared packages) ─────────────

info "Building Library (shared packages)..."
(cd "$ROOT/Library" && npm install && npm run build)
ok "Library built."

# ── 3. Chancellor (state authority daemon) ───

info "Building Chancellor (daemon)..."
(cd "$ROOT/Omny/chancellor" && cargo build $CARGO_PROFILE)
ok "Chancellor built."

# ── 4. Throne (desktop shell) ────────────────
# cargo tauri build runs throne/build.ts (esbuild) automatically,
# which compiles all programs from Apps/ into dist/.

info "Building Throne (shell + programs)..."
(cd "$ROOT/Omny/throne" && npm install && cargo tauri build)
ok "Throne built."

# ── Done ─────────────────────────────────────

echo ""
ok "Omnidea built successfully."
echo ""
echo "  Omninet:     $ROOT/Omninet/target/"
echo "  Library:     $ROOT/Library/"
echo "  Chancellor:  $ROOT/Omny/chancellor/target/"
echo "  Throne:      $ROOT/Omny/throne/src-tauri/target/"
echo ""
