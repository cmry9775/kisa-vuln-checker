#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
ID='U-27'; TITLE='마지막 패치 적용 일자(최근성) 점검'; SEV='중'
FIX='정기적인 패치 적용 주기(분기 1회 이상 권장)를 수립하고 준수'
THRESHOLD_DAYS=90

LAST=""
if [ -f /var/log/apt/history.log ]; then
  LAST=$(grep '^Start-Date:' /var/log/apt/history.log 2>/dev/null | tail -1 | cut -d' ' -f2-)
elif [ -f /var/log/yum.log ]; then
  LAST=$(tail -1 /var/log/yum.log 2>/dev/null | awk '{print $1, $2, $3}')
fi

if [ -z "$LAST" ]; then
  emit "$ID" "$TITLE" "$SEV" '수동' '패치 이력 로그(/var/log/apt/history.log 등)를 찾을 수 없음 — 수동 확인 필요' "$FIX"; exit 0
fi

LAST_EPOCH=$(date -d "$LAST" +%s 2>/dev/null)
if [ -z "$LAST_EPOCH" ]; then
  emit "$ID" "$TITLE" "$SEV" '수동' "패치 이력 날짜 파싱 실패(raw: ${LAST}) — 수동 확인 필요" "$FIX"; exit 0
fi

DAYS=$(( ( $(date +%s) - LAST_EPOCH ) / 86400 ))
if [ "$DAYS" -le "$THRESHOLD_DAYS" ]; then
  R='양호'
else
  R='취약'
fi
emit "$ID" "$TITLE" "$SEV" "$R" "마지막 패치 적용일: ${LAST} (${DAYS}일 경과, 기준 ${THRESHOLD_DAYS}일 이내)" "$FIX"
