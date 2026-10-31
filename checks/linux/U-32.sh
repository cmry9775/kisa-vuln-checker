#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
ID='U-32'; TITLE='원격 로그 서버 전송 설정 점검'; SEV='중'
FIX='rsyslog 설정에 원격 로그 서버 전송 규칙(예: *.* @@loghost:514)을 추가'

FOUND=""
EXAMINED=0
for f in /etc/rsyslog.conf /etc/rsyslog.d/*.conf; do
  [ -f "$f" ] || continue
  EXAMINED=1
  L=$(grep -Ev '^[[:space:]]*(#|$)' "$f" | grep -E '@')
  if [ -n "$L" ]; then
    FOUND="$f: $(echo "$L" | head -1)"
    break
  fi
done

if [ -n "$FOUND" ]; then
  emit "$ID" "$TITLE" "$SEV" '양호' "원격 로그 전송 설정 발견(${FOUND})" "$FIX"
elif [ "$EXAMINED" -eq 1 ]; then
  emit "$ID" "$TITLE" "$SEV" '취약' 'rsyslog 설정에 원격 로그 서버 전송(@ 또는 @@) 규칙 없음 — 로컬 저장만 수행' "$FIX"
else
  emit "$ID" "$TITLE" "$SEV" '취약' 'rsyslog 미설치 — 원격 로그 전송 불가(로그가 로컬에만 남아 침해 시 조작·삭제 위험)' "$FIX"
fi
