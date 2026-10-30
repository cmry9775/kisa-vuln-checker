#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
ID='U-25'; TITLE='커널 패치 적용 여부(재부팅 대기) 점검'; SEV='상'
FIX='최신 커널 패키지 설치 후 재부팅하여 패치된 커널을 적용'
RUNNING=$(uname -r)

if [ -f /var/run/reboot-required ]; then
  PKGS=$(cat /var/run/reboot-required.pkgs 2>/dev/null | tr '\n' ',' | sed 's/,$//')
  emit "$ID" "$TITLE" "$SEV" '취약' "재부팅 대기 중인 패치 존재(현재 실행 커널: ${RUNNING})${PKGS:+, 관련 패키지: ${PKGS}}" "$FIX"
  exit 0
fi

# Debian/Ubuntu 계열은 /var/run/reboot-required 부재 = 재부팅 대기 패치 없음으로 판단 가능
if [ -f /etc/debian_version ]; then
  emit "$ID" "$TITLE" "$SEV" '양호' "재부팅 대기 패치 없음(현재 실행 커널: ${RUNNING})" "$FIX"
  exit 0
fi

# RHEL/CentOS 계열은 needs-restarting(yum-utils)로 판단
if command -v needs-restarting >/dev/null 2>&1; then
  if needs-restarting -r >/dev/null 2>&1; then
    emit "$ID" "$TITLE" "$SEV" '양호' "재부팅 불필요(현재 실행 커널: ${RUNNING})" "$FIX"
  else
    emit "$ID" "$TITLE" "$SEV" '취약' "재부팅 필요 — 패치된 커널 미적용(현재 실행 커널: ${RUNNING})" "$FIX"
  fi
  exit 0
fi

emit "$ID" "$TITLE" "$SEV" '수동' "재부팅 필요 여부 자동 판단 불가(현재 실행 커널: ${RUNNING}) — 배포판별 도구로 수동 확인 필요" "$FIX"
