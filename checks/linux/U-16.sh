#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
ID='U-16'; TITLE='/etc/passwd 파일 소유자 및 권한 설정'; SEV='상'
FIX='chown root /etc/passwd; chmod 644 /etc/passwd'
F=/etc/passwd
if [ ! -e "$F" ]; then
  emit "$ID" "$TITLE" "$SEV" 'N/A' "$F 없음" "$FIX"; exit 0
fi
INFO=$(stat -c '%U %a' "$F")
if owner_is "$F" root && perm_le "$F" 644; then
  R='양호'
else
  R='취약'
fi
emit "$ID" "$TITLE" "$SEV" "$R" "소유자/권한: $INFO (기준: root, 644 이하)" "$FIX"
