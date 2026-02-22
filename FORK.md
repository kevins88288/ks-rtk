# ks-rtk — Fork of rtk-ai/rtk

## Overview

This is Kevin's fork of [rtk-ai/rtk](https://github.com/rtk-ai/rtk) (Rust Token Killer).
We track upstream closely and layer our own improvements on feature branches.

## Upstream

| Field | Value |
|-------|-------|
| **Upstream repo** | https://github.com/rtk-ai/rtk |
| **Remote name** | `origin` (direct clone, not GitHub fork) |
| **Last synced** | 2026-02-20 |
| **Synced version** | 0.22.2 |

## Sync Risks

### Upstream CLAUDE.md Contains Author Personal Preferences

**Risk**: When syncing upstream, the author's `CLAUDE.md` is pulled in verbatim. It contains
personal workflow preferences including language settings (e.g., "Respond in French"). These
override your own Claude behavior until caught.

**What happened**: Syncing to v0.22.2 pulled in a French language preference that caused Claude
to respond in French for multiple sessions.

**After every upstream sync, always review and override:**
- `Language & Communication` section — confirm English is set
- Any personal style, tone, or communication preferences the upstream author added
- Dev workflow assumptions that differ from this environment (paths, tools, OS)

**Fix applied**: Commit `fd66cc9` — Language section in `CLAUDE.md` now says "English always"
with English communication examples replacing the original French ones.

## Our Customizations

### Phase 1: Foundation (merged to master)
- FORK.md tracking doc (this file)
- LLM-friendly empty result messages (grep, find)
- Clearer abbreviations (no emoji-heavy headers)

### Phase 2: Anti-Circumvention + Tracking (feat/phase2-tracking)
- **fork_tag tracking**: `fork_tag TEXT` column in tracking DB for per-feature attribution
- **track_tagged() API**: Fork-modified modules tag records with `ks:llm-friendly`, `ks:tee`, etc.
- **Tee integration**: `tee_and_hint()` wired into `ls.rs`, `container.rs`, `grep_cmd.rs`
- **Log truncation fix**: Error line truncation increased from 100→200 chars (fixes docker "Permission denied" cutoff)
- **Fork stats in `rtk gain`**: Shows fork vs upstream savings breakdown
- **`scripts/fork-stats.sh`**: SQL-based comparison script

### Feature Tags

| Tag | Modules | Purpose |
|-----|---------|---------|
| `ks:llm-friendly` | grep_cmd.rs, find_cmd.rs | Natural language messages prevent LLM circumvention |
| `ks:tee` | ls.rs, container.rs, grep_cmd.rs | Tee recovery hints for filtered output |
| `ks:truncation-fix` | log_cmd.rs | Less aggressive error truncation |
| `ks:grep-flag-strip` | hooks/rtk-rewrite.sh | Strips -r/-n/-l/-H/-h before rewriting to rtk grep (upstream Clap rejects them when passed before positional args) |

### How to Check Fork Savings

```bash
# In rtk gain output (automatic)
rtk gain

# Detailed breakdown
bash scripts/fork-stats.sh
```

## How to Sync with Upstream

```bash
git checkout master
git pull origin master
# Rebuild and deploy
cargo build --release
sudo cp target/release/rtk /usr/local/bin/rtk
rtk --version
```

## History

| Date | Action |
|------|--------|
| 2026-02-20 | Initial fork setup. Synced from 0.18.0 to 0.22.2. Dropped obsolete grep bash flag stripping (upstream fixed in Rust). |
| 2026-02-20 | Phase 1: LLM-friendly output messages merged to master. |
| 2026-02-21 | Phase 2: fork_tag tracking, tee integration, log truncation fix, fork-stats script. |
| 2026-02-21 | Docs: Added Sync Risks section documenting CLAUDE.md personal preference inheritance risk. |
| 2026-02-22 | Merged grep flag stripping hook fix (b9094b2 → 765611e). Upstream did not fix: trailing_var_arg only captures flags after positional args, so -rn before pattern still errors. |
