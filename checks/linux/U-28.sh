#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
ID='U-28'; TITLE='핵심 서비스(OpenSSH·OpenSSL) 버전 및 EOL 점검'; SEV='상'
FIX='배포판 패키지 매니저로 OpenSSH·OpenSSL을 최신 버전으로 업데이트'

ISSUES=""
SSH_VER="미설치"
SSL_VER="미설치"

if command -v ssh >/dev/null 2>&1; then
  SSH_VER=$(ssh -V 2>&1 | grep -oE 'OpenSSH_[0-9]+\.[0-9]+' | head -1 | sed 's/OpenSSH_//')
  SSH_MAJOR=$(echo "$SSH_VER" | cut -d. -f1)
  if [ -n "$SSH_MAJOR" ] && [ "$SSH_MAJOR" -lt 8 ] 2>/dev/null; then
    ISSUES="${ISSUES}OpenSSH ${SSH_VER}(8.0 미만, 오래된 버전); "
  fi
fi

if command -v openssl >/dev/null 2>&1; then
  SSL_VER=$(openssl version | awk '{print $2}')
  case "$SSL_VER" in
    1.0.*|1.1.0*|1.1.1*)
      ISSUES="${ISSUES}OpenSSL ${SSL_VER}(EOL 지난 버전); ";;
  esac
fi

if [ -z "$ISSUES" ]; then
  emit "$ID" "$TITLE" "$SEV" '양호' "OpenSSH ${SSH_VER}, OpenSSL ${SSL_VER} — EOL 대상 아님" "$FIX"
else
  emit "$ID" "$TITLE" "$SEV" '취약' "${ISSUES}(OpenSSH ${SSH_VER}, OpenSSL ${SSL_VER})" "$FIX"
fi
