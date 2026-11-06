#!/usr/bin/env bash
#
# Rate-limited recon pipeline for authorized testing only.
# Usage: ./recon.sh example.com
#
set -euo pipefail

DOMAIN="${1:-}"
if [ -z "$DOMAIN" ]; then
  echo "Usage: $0 <domain>"
  exit 1
fi

OUT="$HOME/bb/$DOMAIN"
mkdir -p "$OUT"/{subs,http,js,findings}

echo "[*] Target: $DOMAIN"
echo "[*] Output: $OUT"

# ---------- Phase 1: passive enumeration ----------
echo "[*] Phase 1: passive subdomain enumeration"
subfinder -d "$DOMAIN" -all -silent > "$OUT/subs/subfinder.txt" 2>/dev/null || true
assetfinder --subs-only "$DOMAIN" > "$OUT/subs/assetfinder.txt" 2>/dev/null || true

curl -s "https://crt.sh/?q=%25.$DOMAIN&output=json" \
  | jq -r '.[].name_value' 2>/dev/null \
  | sed 's/\*\.//g' > "$OUT/subs/crtsh.txt" || true

cat "$OUT"/subs/*.txt | grep -vE '^\*' | sort -u > "$OUT/subs/all.txt"
echo "    $(wc -l < "$OUT/subs/all.txt") unique hosts"

# ---------- Phase 2: resolve ----------
echo "[*] Phase 2: resolving + CNAME map"
dnsx -l "$OUT/subs/all.txt" -a -resp -silent > "$OUT/subs/resolved.txt" 2>/dev/null || true
dnsx -l "$OUT/subs/all.txt" -cname -resp -silent > "$OUT/subs/cnames.txt" 2>/dev/null || true
echo "    $(wc -l < "$OUT/subs/resolved.txt") resolving"

# ---------- Phase 3: live hosts ----------
echo "[*] Phase 3: live host triage (rate limited)"
awk '{print $1}' "$OUT/subs/resolved.txt" > "$OUT/subs/names.txt"
httpx -l "$OUT/subs/names.txt" -silent -threads 15 -rl 20 \
  -status-code -title -tech-detect > "$OUT/http/live.txt" 2>/dev/null || true

grep -E '\[(200|401|403)\]' "$OUT/http/live.txt" > "$OUT/http/interesting.txt" || true
echo "    $(wc -l < "$OUT/http/interesting.txt") interesting hosts"

# ---------- Phase 4: JS endpoint extraction ----------
echo "[*] Phase 4: JS crawl + endpoint extraction"
katana -list "$OUT/http/interesting.txt" -jc -d 2 -c 5 -rl 20 -silent \
  > "$OUT/http/urls.txt" 2>/dev/null || true

grep -Ei '\.js(\?|$)' "$OUT/http/urls.txt" | sort -u > "$OUT/js/js_urls.txt" || true

while read -r u; do
  f="$OUT/js/$(echo "$u" | md5sum | cut -c1-12).js"
  [ -s "$f" ] || curl -s -L --max-time 20 -A "Mozilla/5.0" "$u" -o "$f" 2>/dev/null || true
  sleep 0.3
done < "$OUT/js/js_urls.txt"

grep -rhoE '/api/v[0-9]+/[A-Za-z0-9/_{}.-]+' "$OUT/js/" \
  | sort -u > "$OUT/findings/api_paths.txt" || true

echo "[+] Done."
echo "    Endpoints: $OUT/findings/api_paths.txt ($(wc -l < "$OUT/findings/api_paths.txt") paths)"
echo "    Next: manual testing. Automation stops here."
