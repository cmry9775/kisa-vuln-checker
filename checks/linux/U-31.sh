#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
ID='U-31'; TITLE='로그 보존 기간(로테이션) 설정 점검'; SEV='중'
FIX='/etc/logrotate.conf의 rotate 값을 조직 로그 보관 정책(예: 4회=약 1개월 이상)에 맞게 설정'
MIN_ROTATE=4
CONF='/etc/logrotate.conf'

if [ ! -f "$CONF" ]; then
  emit "$ID" "$TITLE" "$SEV" '수동' 'logrotate 미설치 또는 설정 파일 없음 — 수동 확인 필요' "$FIX"; exit 0
fi

ROTATE=$(conf_val "$CONF" rotate | awk '{print $NF}')
if [ -z "$ROTATE" ]; then
  emit "$ID" "$TITLE" "$SEV" '취약' '전역 rotate 값 미설정(보존 기간 불명확)' "$FIX"; exit 0
fi

if [ "$ROTATE" -ge "$MIN_ROTATE" ] 2>/dev/null; then
  emit "$ID" "$TITLE" "$SEV" '양호' "logrotate rotate=${ROTATE}(기준 ${MIN_ROTATE} 이상)" "$FIX"
else
  emit "$ID" "$TITLE" "$SEV" '취약' "logrotate rotate=${ROTATE}(기준 ${MIN_ROTATE} 미만)" "$FIX"
fi
