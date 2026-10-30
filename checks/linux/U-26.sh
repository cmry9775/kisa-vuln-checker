#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
ID='U-26'; TITLE='패키지 매니저 기준 미적용 보안 업데이트 개수 점검'; SEV='상'
FIX='apt upgrade / yum·dnf update 등으로 대기 중인 패키지 업데이트를 적용'

if command -v apt >/dev/null 2>&1; then
  CNT=$(apt list --upgradable 2>/dev/null | grep -vc '^Listing')
  if [ "$CNT" -eq 0 ]; then
    emit "$ID" "$TITLE" "$SEV" '양호' '미적용 업데이트 0건(apt list --upgradable)' "$FIX"
  else
    emit "$ID" "$TITLE" "$SEV" '취약' "미적용 업데이트 ${CNT}건(apt list --upgradable)" "$FIX"
  fi
  exit 0
fi

if command -v dnf >/dev/null 2>&1 || command -v yum >/dev/null 2>&1; then
  PM=dnf; command -v dnf >/dev/null 2>&1 || PM=yum
  CNT=$("$PM" check-update 2>/dev/null | grep -Ec '^\S+\.\S+[[:space:]]+\S+[[:space:]]+\S+$')
  if [ "$CNT" -eq 0 ]; then
    emit "$ID" "$TITLE" "$SEV" '양호' "미적용 업데이트 0건(${PM} check-update)" "$FIX"
  else
    emit "$ID" "$TITLE" "$SEV" '취약' "미적용 업데이트 ${CNT}건(${PM} check-update)" "$FIX"
  fi
  exit 0
fi

emit "$ID" "$TITLE" "$SEV" 'N/A' '지원되는 패키지 매니저(apt/yum/dnf) 없음' "$FIX"
