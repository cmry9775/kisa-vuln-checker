#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
ID='U-05'; TITLE='root 이외의 UID 0 금지'; SEV='상'
FIX='root 외 UID 0 계정을 다른 UID로 변경 또는 제거'
BAD=$(awk -F: '($3==0 && $1!="root"){print $1}' /etc/passwd | paste -sd, -)
[ -z "$BAD" ] && R='양호' || R='취약'
emit "$ID" "$TITLE" "$SEV" "$R" "UID0 계정: ${BAD:-root뿐}" "$FIX"
