#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
ID='U-18'; TITLE='/etc/shadow 파일 소유자 및 권한 설정'; SEV='상'
FIX='chown root /etc/shadow; chmod 400 /etc/shadow'
F=/etc/shadow
if [ ! -e "$F" ]; then
  emit "$ID" "$TITLE" "$SEV" 'N/A' "$F 없음" "$FIX"; exit 0
fi
INFO=$(stat -c '%U %a' "$F")
# Debian/Ubuntu 기본값은 root:shadow 640 — KISA 기준(400 이하)과 다르므로 증거에 그대로 기록
if owner_is "$F" root && perm_le "$F" 400; then
  R='양호'
else
  R='취약'
fi
emit "$ID" "$TITLE" "$SEV" "$R" "소유자/권한: $INFO (기준: root, 400 이하)" "$FIX"
