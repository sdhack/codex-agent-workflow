#!/usr/bin/env bash
# Skill-local bootstrap: Sol (leader) + Luna (workers)
set -euo pipefail

ROOT="${1:-.}"
ROOT="$(cd "$ROOT" && pwd)"
SKILL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TPL="$SKILL_DIR/references/project-template"

if [[ ! -d "$TPL" ]]; then
  # Running from monorepo root scripts/
  REPO_ROOT="$(cd "$SKILL_DIR/../.." && pwd)"
  if [[ -d "$REPO_ROOT/templates/codex" ]]; then
    exec bash "$REPO_ROOT/scripts/bootstrap.sh" "$ROOT"
  fi
  echo "project-template not found at $TPL" >&2
  exit 1
fi

echo "==> Target project: $ROOT"
mkdir -p "$ROOT/.codex/agents" "$ROOT/.claude/agents" "$ROOT/scripts"

copy_if_missing() {
  local src="$1" dest="$2"
  if [[ -e "$dest" ]]; then
    echo "keep existing: $dest"
  else
    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
    echo "created: $dest"
  fi
}

if [[ ! -f "$ROOT/.codex/config.toml" ]]; then
  cp "$TPL/.codex/config.toml" "$ROOT/.codex/config.toml"
  echo "created: $ROOT/.codex/config.toml"
  echo "NOTE: edit base_url in .codex/config.toml for your gateway"
else
  echo "keep existing: $ROOT/.codex/config.toml"
fi

for f in luna_scout.toml luna_worker.toml luna_critic.toml luna_tester.toml; do
  copy_if_missing "$TPL/.codex/agents/$f" "$ROOT/.codex/agents/$f"
done
for f in luna-scout.md luna-worker.md luna-critic.md; do
  copy_if_missing "$TPL/.claude/agents/$f" "$ROOT/.claude/agents/$f"
done
copy_if_missing "$TPL/AGENTS.md" "$ROOT/AGENTS.md"
copy_if_missing "$TPL/CLAUDE.md" "$ROOT/CLAUDE.md"
copy_if_missing "$TPL/scripts/prepare-luna-catalog.sh" "$ROOT/scripts/prepare-luna-catalog.sh"
chmod +x "$ROOT/scripts/prepare-luna-catalog.sh"

GI="$ROOT/.gitignore"
touch "$GI"
for line in '.codex/models-v1.json' '.env' '.env.*'; do
  grep -qxF "$line" "$GI" 2>/dev/null || echo "$line" >>"$GI"
done

echo
echo "==> Optional: generate Luna-compatible catalog"
if command -v codex >/dev/null 2>&1 && [[ -n "${OPENAI_API_KEY:-}" || -n "${CODEX_API_KEY:-}" ]]; then
  if ! bash "$ROOT/scripts/prepare-luna-catalog.sh" "$ROOT/.codex/models-v1.json"; then
    echo "WARNING: catalog generation failed; Luna spawn is not verified" >&2
  fi
  ABS="$(cd "$ROOT/.codex" && pwd)/models-v1.json"
  if [[ -f "$ABS" ]] && ! grep -q 'model_catalog_json' "$ROOT/.codex/config.toml"; then
    tmp="$(mktemp)"
    { echo "model_catalog_json = \"$ABS\""; cat "$ROOT/.codex/config.toml"; } >"$tmp"
    mv "$tmp" "$ROOT/.codex/config.toml"
    echo "prepended model_catalog_json -> $ABS"
  fi
else
  echo "Skip catalog generation (need codex + OPENAI_API_KEY)"
fi

echo
echo "==> Done. See repo README for smoke tests."
