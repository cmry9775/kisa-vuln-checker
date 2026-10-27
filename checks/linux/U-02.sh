#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
ID='U-02'; TITLE='비밀번호 관리정책 설정'; SEV='상'
FIX='pwquality.conf에 minlen 8 이상 및 복잡성(-1) 설정'
PWQ='/etc/security/pwquality.conf'; SA='/etc/pam.d/system-auth'
MINLEN=$(conf_val "$PWQ" minlen | grep -oE '[0-9]+' | tail -1)
if { [ -n "$MINLEN" ] && [ "$MINLEN" -ge 8 ]; } || grep -qE 'pam_pwquality|pam_cracklib' "$SA" 2>/dev/null; then
  R='양호'; EV="minlen=${MINLEN:-pam설정}"
else
  R='취약'; EV="minlen=${MINLEN:-미설정}"
fi
emit "$ID" "$TITLE" "$SEV" "$R" "$EV" "$FIX"
