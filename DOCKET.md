# Docket

Issues awaiting resolution. Tracked here when they can't be fixed immediately.

---

## Upstream / Blocked

### glib VariantStrIter unsoundness (RUSTSEC-2024-0429)
- **Severity:** Medium (Dependabot)
- **Repo:** neonpixy/omny (2 alerts)
- **What:** glib 0.18.5 has an unsound `Iterator` impl. Fix requires glib 0.20.0+, which requires gtk4-rs.
- **Why blocked:** Tauri 2.x still uses gtk3-rs. Migration to gtk4-rs is tracked at [tauri-apps/tauri#12562](https://github.com/tauri-apps/tauri/issues/12562). We're already on the latest Tauri (2.10.3).
- **Risk:** None on macOS — glib is a Linux-only GTK dependency, never compiled or executed on this platform.
- **Action:** Watch for Tauri's gtk4-rs migration (likely v2 late or v3). Dismiss Dependabot alerts with note.
- **Added:** 2026-04-02

---

## Sage Phase 2 (deferred from Flight 5)

### Consent-gated skill execution
- **What:** Skills requiring human approval (Publish, Transact, Communicate, Govern) pause execution, notify via Pager, and wait for response. Currently only auto-approved skills (Suggest, Create, Modify) are supported.
- **Why deferred:** Requires async approval flow — queue pending action, return partial result to Claude, resume on approval. Significantly more complex than auto-approved path.
- **Depends on:** Sage v1 skill routing working end-to-end.

### Streaming response chunks
- **What:** Progressive token delivery from provider to UI. ThoughtChunk events over Email as they arrive from streaming HTTP response. The seam is left in v1 (ProviderCapabilities::STREAMING is tracked, Email events exist).
- **Why deferred:** Requires SSE/streaming parsing in reqwest, ThoughtChunk event pipeline, and UI rendering support.
- **Depends on:** Sage v1 generation working end-to-end.

### Per-entity Vault persistence
- **What:** Store each session, memory, and synapse as individual Vault entries instead of one `advisor_state.json` blob. Enables selective loading, survives partial corruption.
- **Why deferred:** Phase 1 uses file-based JSON persistence. Vault integration requires Crown to be unlocked, adds complexity to boot sequence.
- **Depends on:** Sage v1 persistence working, Castellan courtier matured.

### Apple Intelligence provider
- **What:** CognitiveProvider implementation for Apple's on-device AI. Would use Foundation framework APIs on macOS/iOS.
- **Why deferred:** Requires Swift FFI bridge through Divinity, platform-specific implementation. Not available on Linux/Windows.
- **Depends on:** Sage v1 provider system working, Divinity Apple bridge matured.

---

## Ready to Fix

### Chancellor `set_handle` dead code warning
- **Severity:** Warning (cargo check)
- **Repo:** neonpixy/omny — `chancellor/build.rs:466`
- **What:** `set_handle` in generated FFI code is never called. It's scaffolding for handle-bearing ops (488 skipped ops need it).
- **Fix:** Add `#[allow(dead_code)]` to the build script's `set_handle` emission.
- **Added:** 2026-04-02
