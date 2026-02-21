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

## Our Customizations

### Deployed (on master)
- FORK.md tracking doc (this file)

### Feature Branches (not deployed)
- `feat/llm-friendly-output` — LLM-friendly empty result messages, clearer abbreviations, grep exit code propagation

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
