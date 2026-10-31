#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
ID='U-33'; TITLE='감사 로그(auditd) 설치 및 규칙 설정 여부 점검'; SEV='상'
FIX='auditd를 설치하고 주요 이벤트(계정 변경, 권한 상승, 중요 파일 접근 등)에 대한 규칙을 /etc/audit/rules.d/에 등록'

if ! command -v auditctl >/dev/null 2>&1 && [ ! -f /etc/audit/auditd.conf ]; then
  emit "$ID" "$TITLE" "$SEV" '취약' 'auditd 미설치' "$FIX"; exit 0
fi

RULES=""
for f in /etc/audit/audit.rules /etc/audit/rules.d/*.rules; do
  [ -f "$f" ] || continue
  RULES="${RULES}
$(grep -Ev '^[[:space:]]*(#|$)' "$f")"
done

CNT=$(echo "$RULES" | grep -Ev '^[[:space:]]*$' | wc -l)
if [ "$CNT" -gt 0 ]; then
  emit "$ID" "$TITLE" "$SEV" '양호' "auditd 설치됨, 감사 규칙 ${CNT}줄 설정" "$FIX"
else
  emit "$ID" "$TITLE" "$SEV" '취약' 'auditd는 설치됐으나 감사 규칙이 설정되어 있지 않음(기본값만 존재)' "$FIX"
fi
