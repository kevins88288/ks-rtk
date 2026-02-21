#!/bin/bash
# fork-stats.sh — Compare ks-rtk fork feature savings vs upstream RTK
#
# Usage: bash scripts/fork-stats.sh
#
# Queries the RTK tracking database for records tagged with fork features
# (fork_tag column) vs upstream-only records (fork_tag IS NULL).

DB="${RTK_DB_PATH:-${HOME}/.local/share/rtk/history.db}"

if [ ! -f "$DB" ]; then
    echo "No tracking database found at: $DB"
    echo "RTK needs to run some commands first to generate tracking data."
    exit 1
fi

echo "=== Fork Feature Savings (ks-rtk) ==="
sqlite3 -column -header "$DB" \
  "SELECT
     COALESCE(fork_tag, '(none)') as feature,
     COUNT(*) as cmds,
     SUM(saved_tokens) as saved,
     ROUND(AVG(savings_pct), 1) as avg_pct
   FROM commands
   WHERE fork_tag IS NOT NULL
   GROUP BY fork_tag
   ORDER BY saved DESC;"

echo ""
echo "=== Upstream RTK Savings (no fork tag) ==="
sqlite3 -column -header "$DB" \
  "SELECT
     COUNT(*) as cmds,
     SUM(saved_tokens) as saved,
     ROUND(AVG(savings_pct), 1) as avg_pct
   FROM commands
   WHERE fork_tag IS NULL;"

echo ""
echo "=== Total (all commands) ==="
sqlite3 -column -header "$DB" \
  "SELECT
     COUNT(*) as cmds,
     SUM(saved_tokens) as total_saved,
     ROUND(AVG(savings_pct), 1) as avg_pct
   FROM commands;"

echo ""
echo "=== Fork vs Upstream Summary ==="
sqlite3 -column -header "$DB" \
  "SELECT
     CASE WHEN fork_tag IS NOT NULL THEN 'ks-rtk fork' ELSE 'upstream' END as source,
     COUNT(*) as cmds,
     SUM(saved_tokens) as saved,
     ROUND(AVG(savings_pct), 1) as avg_pct,
     ROUND(100.0 * SUM(saved_tokens) / (SELECT SUM(saved_tokens) FROM commands), 1) as pct_of_total
   FROM commands
   GROUP BY (fork_tag IS NOT NULL)
   ORDER BY saved DESC;"
