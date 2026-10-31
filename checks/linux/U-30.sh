#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
ID='U-30'; TITLE='주요 로그 파일 소유자 및 권한 점검'; SEV='상'
FIX='로그 파일 소유자를 root로, 권한을 640 이하로 설정(chown root <file>; chmod 640 <file>)'

CANDIDATES="/var/log/syslog /var/log/auth.log /var/log/messages /var/log/secure"
FOUND=""
BAD=""
for f in $CANDIDATES; do
  [ -f "$f" ] || continue
  FOUND="$FOUND $f"
  owner_is "$f" root || BAD="$BAD $f(owner=$(stat -c '%U' "$f"))"
  perm_le "$f" 640 || BAD="$BAD $f(perm=$(stat -c '%a' "$f"))"
done

if [ -z "$FOUND" ]; then
  emit "$ID" "$TITLE" "$SEV" '수동' '주요 로그 파일(syslog/auth.log/messages/secure)을 찾을 수 없음 — 수동 확인 필요' "$FIX"; exit 0
fi

if [ -n "$BAD" ]; then
  emit "$ID" "$TITLE" "$SEV" '취약' "기준 미달:${BAD}" "$FIX"
else
  emit "$ID" "$TITLE" "$SEV" '양호' "확인된 로그 파일(${FOUND# }) 모두 소유자 root, 권한 640 이하" "$FIX"
fi
