> **[Omnidea](https://github.com/neonpixy/omnidea)** · [README](README.md) · [WIRING.md](WIRING.md)

# Omnidea -- AI Contributor Instructions

This file provides context for AI assistants (Claude, etc.) working on the Omnidea codebase.

---

## The Big Picture

Omnidea is a sovereign internet with its own protocol, browser, rendering engine, identity system, encrypted storage, relay network, and economic system. It is governed by a constitution called the Covenant.

### Four Repos, One System

| Repo | What It Is | Language | Where |
|------|-----------|----------|-------|
| **Covenant** | The constitution. 14 documents defining Dignity, Sovereignty, and Consent. | Prose | `Covenant/` |
| **Omninet** | The protocol. 29 Rust crates, 26 building blocks (A-Z), 6,700+ tests. | Rust | `Omninet/` |
| **Omny** | The browser. Throne (Tauri 2.x shell), Castle (contract engine), Chancellor (state authority, 5 infrastructure modules). Programs live in `Apps/`. | Rust, TypeScript | `Omny/` |
| **Library** | Shared libraries. Crystal (WebGPU glass), `@omnidea/net` SDK (860 ops), `@omnidea/ui` (54 Solid.js components), `@omnidea/editor` (CRDT), `@omnidea/fx` (effects). | TypeScript, WGSL | `Library/` |

### How They Connect

```
Rust crates (Omninet) --> C FFI (1,040 functions) --> Chancellor (Omny)
    --> IPC (JSON over unix socket) --> @omnidea/net SDK (Library)
    --> Solid.js UI (Apps/)
```

The daemon is the single source of truth. It owns all state -- identity (Crown), storage (Vault), node runtime (Omnibus), and the FFI orchestrator. Frontends talk to the daemon over IPC, never directly to the Rust crates.

For cross-repo integration details, read `WIRING.md`.

---

## The ABCs (26 Building Blocks)

Each letter A-Z is a Rust crate in Omninet representing a fundamental building block:

| | Name | Purpose |
|---|---|---|
| A | Advisor | AI cognition |
| B | Bulwark | Safety and protection |
| C | Crown | Identity and self |
| D | Divinity | Platform interface (FFI + rendering) |
| E | Equipment | Communication (Pact protocol) |
| F | Fortune | Economics |
| G | Globe | Networking (ORP) |
| H | Hall | File I/O |
| I | Ideas | Universal content format (.idea) |
| J | Jail | Verification and accountability |
| K | Kingdom | Community governance |
| L | Lingo | Language and translation |
| M | Magic | Rendering and code translation |
| N | Nexus | Federation and interop |
| O | Oracle | Guidance and onboarding |
| P | Polity | Rights enforcement and consensus |
| Q | Quest | Gamification and progression |
| R | Regalia | Design language |
| S | Sentinal | Encryption |
| T | Target | Cargo build output |
| U | Undercroft | System health and observatory |
| V | Vault | Encrypted storage |
| W | World | Digital and physical worlds |
| X | X | Shared utilities |
| Y | Yoke | History and provenance |
| Z | Zeitgeist | Discovery and culture |

---

## Key Patterns

- **Equipment** is the nervous system. All inter-module communication uses Pact (Phone, Email, Contacts, Pager). String-based routing -- no direct cross-crate imports.
- **Ideas** (.idea) is the universal content format. Everything is an .idea document.
- **Regalia** is the design language. Aura tokens, Arbiter layout, Surge animation, Reign theming. No hardcoded colors, spacing, or typography.
- **Extend, never break.** New features add types and traits. Existing public APIs never change. Every existing test must continue to pass.
- **Respect the exports contract.** Never bypass a package's `exports` field with explicit dist paths. Use the `browserExportsPlugin` in `throne/build.ts` to resolve conditional exports correctly. esbuild ignores `exports` for entry points and falls back to the legacy `module` field, which can point to server builds.
- **Wyndsor coherence.** Throne is the composition host. Its tsconfig must have full type awareness of everything it compiles (castle, crystal, Library). Type errors anywhere in the composition tree are failures, not cosmetic noise.

---

## Building

```bash
# Full build (from repo root)
./build.sh

# Individual repos
cd Omninet && cargo build --workspace
cd Library && npm install && npm run build
cd Omny/chancellor && cargo build
cd Omny/throne && cargo tauri build
```

## Testing

```bash
cd Omninet && cargo test --workspace          # 6,700+ tests
cd Library && npm test                             # vitest
cd Omny/chancellor && cargo test              # Rust tests
```

## Code Style

- **Rust:** Clippy clean including tests (`cargo clippy --workspace --tests`). No `print!()` -- use Logger.
- **TypeScript:** Solid.js + UnoCSS. No React patterns. No Tailwind. Remix Icon (`ri-{name}-{fill|line}`).
- **FFI:** Never change an existing function signature. Add new functions alongside. `#[serde(default)]` on new optional fields.

---

## The Covenant

Every technical decision answers to three principles:

1. **Dignity** -- worth that cannot be taken, traded, or measured.
2. **Sovereignty** -- the right to choose, refuse, and reshape.
3. **Consent** -- voluntary, informed, continuous, and revocable.

The Covenant is the project's governing framework. See `Covenant/` for the full text (14 documents).

---

## Per-Repo Documentation

Each repo has its own CLAUDE.md with deeper architecture and patterns:

- [Covenant/](https://github.com/neonpixy/covenant) -- the constitution (Dignity, Sovereignty, Consent)
- [Omninet/CLAUDE.md](https://github.com/neonpixy/omninet/blob/main/CLAUDE.md) -- protocol bible, crate map, build chain
- [Omny/CLAUDE.md](https://github.com/neonpixy/omny/blob/main/CLAUDE.md) -- browser architecture, Tauri shell, daemon, bridge, programs
- [Library/CLAUDE.md](https://github.com/neonpixy/library/blob/main/CLAUDE.md) -- shared libraries: Crystal, SDK, UI, Editor, FX
- [WIRING.md](WIRING.md) -- how features flow through all four repos

---

## Documentation Index

Every CLAUDE.md in the tree. Read the ones relevant to your task.

### Umbrella

| File | When to Read |
|------|-------------|
| [CLAUDE.md](CLAUDE.md) | Always -- top-level orientation, build commands, ABCs, code style |
| [WIRING.md](WIRING.md) | When a feature touches more than one repo |
| [DOCKET.md](DOCKET.md) | Blocked or deferred issues awaiting resolution |

### Covenant (Constitution)

| File | When to Read |
|------|-------------|
| [Covenant/](https://github.com/neonpixy/covenant) | Making decisions about privacy, consent, governance, or any ethical question |

### Omninet (Protocol)

| File | When to Read |
|------|-------------|
| [Omninet/CLAUDE.md](https://github.com/neonpixy/omninet/blob/main/CLAUDE.md) | Working on any Rust crate, FFI, or protocol logic |
| Omninet/{A-Z}/CLAUDE.md | Working on a specific crate (e.g., [Crown](https://github.com/neonpixy/omninet/blob/main/Crown/CLAUDE.md), [Vault](https://github.com/neonpixy/omninet/blob/main/Vault/CLAUDE.md), [Equipment](https://github.com/neonpixy/omninet/blob/main/Equipment/CLAUDE.md)) |

### Omny (Browser)

| File | When to Read |
|------|-------------|
| [Omny/CLAUDE.md](https://github.com/neonpixy/omny/blob/main/CLAUDE.md) | Browser architecture, daemon IPC, shell lifecycle |
| [Apps/](https://github.com/neonpixy/apps) | Manifest-driven programs (Solid.js + UnoCSS) |

### Library (Shared Libraries)

| File | When to Read |
|------|-------------|
| [Library/CLAUDE.md](https://github.com/neonpixy/library/blob/main/CLAUDE.md) | Package layout, build commands |
| [Library/crystal/CLAUDE.md](https://github.com/neonpixy/crystal/blob/main/CLAUDE.md) | WebGPU glass effects, shaders, SDF |
