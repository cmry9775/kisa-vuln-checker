#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
ID='U-22'; TITLE='SNMP 서비스 및 community string 점검'; SEV='상'
FIX='community 문자열을 public/private 등 기본값에서 추측 불가능한 값으로 변경, 불필요 시 SNMP 서비스 비활성화'
CONF='/etc/snmp/snmpd.conf'
if [ ! -f "$CONF" ]; then
  emit "$ID" "$TITLE" "$SEV" 'N/A' 'SNMP 미설치' "$FIX"; exit 0
fi
BAD=$(grep -Ei '^[[:space:]]*(rocommunity|rwcommunity|com2sec)[[:space:]]' "$CONF" \
  | grep -v '^[[:space:]]*#' | grep -Ei '(public|private)')
if [ -n "$BAD" ]; then
  R='취약'; EV="기본 community 문자열 사용: $(echo "$BAD" | head -1)"
else
  R='양호'; EV='public/private 등 기본 community 문자열 미사용'
fi
emit "$ID" "$TITLE" "$SEV" "$R" "$EV" "$FIX"
