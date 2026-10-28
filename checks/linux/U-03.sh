#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
ID='U-03'; TITLE='계정 잠금 임계값 설정'; SEV='상'
FIX='pam_faillock deny=10 이하 설정'
DENY_LINE=''
for f in /etc/pam.d/system-auth /etc/pam.d/password-auth /etc/security/faillock.conf; do
  [ -e "$f" ] || continue
  LINE=$(conf_val "$f" 'deny')
  [ -n "$LINE" ] && DENY_LINE="$LINE"
done
DENY=$(echo "$DENY_LINE" | grep -oE '[0-9]+' | tail -1)
if [ -n "$DENY" ] && [ "$DENY" -ge 1 ] && [ "$DENY" -le 10 ]; then R='양호'; else R='취약'; fi
emit "$ID" "$TITLE" "$SEV" "$R" "deny=${DENY:-미설정}" "$FIX"
