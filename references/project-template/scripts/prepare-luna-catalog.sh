#!/usr/bin/env bash
# Generate a V1 multi-agent catalog so Sol can spawn Luna subagents.
set -euo pipefail
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
OUT="${1:-$CODEX_HOME/models-v1.json}"
mkdir -p "$(dirname "$OUT")"
TMP="$(mktemp)"
codex debug models >"$TMP" 2>/dev/null || {
  echo "codex debug models failed; is Codex installed and configured?" >&2
  exit 1
}
python3 - "$TMP" "$OUT" <<'PY'
import json, sys
raw = open(sys.argv[1]).read()
s, e = raw.find("{"), raw.rfind("}")
data = json.loads(raw[s:e+1])
models = data.get("models", data)
out = []
for m in models:
    m = dict(m)
    if m.get("slug") in ("gpt-5.6-sol", "gpt-5.6-terra", "gpt-5.6-luna"):
        m["multi_agent_version"] = "v1"
    out.append(m)
open(sys.argv[2], "w").write(json.dumps({"models": out}, ensure_ascii=False))
print("wrote", sys.argv[2])
PY
rm -f "$TMP"
echo "Add to config.toml:"
echo "  model_catalog_json = \"$OUT\""
echo "  [features]"
echo "  multi_agent = true"
echo "  multi_agent_v2 = false"
