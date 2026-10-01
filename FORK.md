# ks-rtk — Fork of rtk-ai/rtk

## Overview

Kevin's fork of [rtk-ai/rtk](https://github.com/rtk-ai/rtk) (Rust Token Killer).
We track upstream closely and keep the fork surface as small as possible: every
sync, each fork patch is re-triaged and dropped the moment upstream solves the
same problem.

## Upstream

| Field | Value |
|-------|-------|
| **Upstream repo** | https://github.com/rtk-ai/rtk |
| **Remote** | `upstream` → `rtk-ai/rtk`; `origin` → `kevins88288/ks-rtk` (our mirror) |
| **Last synced** | 2026-09-30 |
| **Synced version** | v0.50.0 (tag) |

## Our Customizations

The fork surface is deliberately tiny. Four patches as of v0.50.0:

| Tag | Location | Purpose |
|-----|----------|---------|
| `ks:playwright-reporter` | `src/cmds/js/playwright_cmd.rs` | Strips the split form `--reporter x`, not just `--reporter=x`. Upstream leaves `x` behind as a stray positional, which Playwright treats as a test-path filter and matches nothing. |
| `ks:truncation-fix` | `src/cmds/system/log_cmd.rs` | Error-line truncation 100 → 200 chars. 100 cut the tail off common errors (docker `...: Permission denied`), hiding the cause. |
| `ks:grep-h` | `src/main.rs` (`Grep`) | `disable_help_flag`: `-h` is grep's `--no-filename`. The hook rewrites `grep -h X f` to `rtk grep -h X f`, and clap printed rtk help instead of results. Drop when rtk-ai/rtk#3663 lands. |
| `ks:build-config` | `.cargo/config.toml` | `lto=off` for `x86_64-unknown-linux-gnu` container builds. Not upstreamable (environment-specific). |

## Sync Risks

### Upstream CLAUDE.md may contain author personal preferences

**Risk**: syncing pulls the upstream author's `CLAUDE.md` in verbatim. It has
previously contained personal workflow preferences including a language setting
("respond in French"), which overrode Claude's behavior for multiple sessions
before it was caught.

**Status at v0.44.1**: clean — upstream's `CLAUDE.md` no longer carries a
Language/Communication section, so the fork's English override is no longer
needed and was dropped.

**After every upstream sync, re-check**:
- any Language / Communication section — confirm English
- personal style, tone, or workflow preferences
- dev workflow assumptions that differ from this environment (paths, tools, OS)

### Fork patches that upstream adopts must be dropped, not merged

Several fork patches were silently superseded between v0.30.0 and v0.44.1 (see
History). Re-triage every patch each sync rather than carrying it forward by
default — a stale fork patch that fights an upstream fix is worse than no patch.

## How to Sync with Upstream

```bash
git fetch upstream --tags --prune
git checkout master
git branch backup/pre-sync-$(date +%Y%m%d)          # safety net

git merge --no-ff --no-commit vX.Y.Z                # expect conflicts
git read-tree --reset -u vX.Y.Z                     # upstream wins wholesale
# then re-apply only the patches in "Our Customizations" that survive triage

cargo build --release
cargo test
install -m755 target/release/rtk ~/.cargo/bin/rtk
rtk --version
```

Resolving conflicts by taking upstream wholesale and *re-applying* a short,
documented patch list is far cheaper than hand-merging a restructured tree —
upstream moved `src/*.rs` into `src/cmds/**`, `src/core/**`, and `src/hooks/**`
in the 0.3x→0.4x range, so textual cherry-picks across that boundary do not apply.

## History

| Date | Action |
|------|--------|
| 2026-02-20 | Initial fork setup. Synced 0.18.0 → 0.22.2. |
| 2026-02-20 | Phase 1: LLM-friendly output messages. |
| 2026-02-21 | Phase 2: fork_tag tracking, tee integration, log truncation fix, fork-stats script. |
| 2026-02-22 | Merged grep flag stripping hook fix. |
| 2026-02-22 | Synced to v0.30.0. |
| 2026-07-29 | Synced to **v0.44.1**. Dropped 8 of 12 fork patches as superseded or obsolete (hook grep-flag stripping, `wc` hook rewrite, `hook-audit`/`wc` CLI wiring, tee UTF-8 truncation, tee integration, grep header wording, CLAUDE.md English override, rustfmt fix). Dropped `fork_tag` tracking + `scripts/fork-stats.sh` deliberately — see below. Kept the four patches above. |
| 2026-09-30 | Synced to **v0.50.0**. Dropped `ks:llm-friendly`: upstream now pins silent no-match for grep/find in 4 tests, and the message was wrong when grep skips a binary-file match. Agents are told "empty = no match" via CLAUDE.md instead. Kept `ks:playwright-reporter`, `ks:truncation-fix` (now with a test), `ks:build-config`. Known env failure: `git_log_malformed_digit_run_propagates_real_git_error` expects git ≥2.51 wording; OCI has 2.43. |
| 2026-09-30 | Added `ks:grep-h` + test `dash_h_hides_filenames_like_grep`. |

### Dropped at the 2026-07-29 sync: `fork_tag` tracking

`fork_tag` (tracking DB column, `track_tagged()`, `get_fork_stats()`, the
`rtk gain` fork section, and `scripts/fork-stats.sh`) measured fork-vs-upstream
savings. It was dropped because:

- it required changing `Tracker::record()`'s signature, touching every call site
  in a tree upstream had just restructured — high merge cost, permanently, at
  every future sync;
- it existed to attribute savings across a fork surface that is now four small
  patches, two of which are a one-line constant and a build config;
- upstream adopted the features it was mainly measuring (`ks:tee`, and the grep
  "N matches in M files" header), so the interesting rows would read zero.

It is recoverable from `backup/pre-sync-20260729` (commit `62b32e0`) if the fork
surface ever grows enough to justify the attribution machinery again.
