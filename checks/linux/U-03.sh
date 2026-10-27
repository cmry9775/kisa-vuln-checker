#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
ID='U-03'; TITLE='계정 잠금 임계값 설정'; SEV='상'
FIX='pam_faillock deny=10 이하 설정'
DENY=$(grep -hoE 'deny[[:space:]]*=[[:space:]]*[0-9]+' \
  /etc/pam.d/system-auth /etc/pam.d/password-auth /etc/security/faillock.conf 2>/dev/null \
  | grep -oE '[0-9]+' | head -1)
if [ -n "$DENY" ] && [ "$DENY" -ge 1 ] && [ "$DENY" -le 10 ]; then R='양호'; else R='취약'; fi
emit "$ID" "$TITLE" "$SEV" "$R" "deny=${DENY:-미설정}" "$FIX"
