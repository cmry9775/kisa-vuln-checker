#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
ID='U-23'; TITLE='NFS/NIS 서비스 비활성화 및 접근 통제'; SEV='상'
FIX='불필요한 NFS 공유 제거, /etc/exports에 접근 허용 IP를 명시하고 no_root_squash 제거'
CONF='/etc/exports'
if [ ! -f "$CONF" ] || [ ! -s "$CONF" ]; then
  emit "$ID" "$TITLE" "$SEV" '양호' '/etc/exports 없음 또는 공유 설정 없음(NFS 미사용)' "$FIX"; exit 0
fi
LINES=$(grep -Ev '^[[:space:]]*(#|$)' "$CONF")
BAD=$(echo "$LINES" | grep -E '(\*\(|no_root_squash)')
if [ -n "$BAD" ]; then
  R='취약'; EV="위험한 공유 설정: $(echo "$BAD" | head -1)"
else
  R='양호'; EV='공유 대상 IP 제한, no_root_squash 미사용'
fi
emit "$ID" "$TITLE" "$SEV" "$R" "$EV" "$FIX"
