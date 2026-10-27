#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
ID='U-04'; TITLE='비밀번호 파일 보호'; SEV='상'
FIX='pwconv 명령으로 쉐도우 비밀번호 적용'
BAD=$(awk -F: '($2!="x"){print $1}' /etc/passwd | paste -sd, -)
if [ -f /etc/shadow ] && [ -z "$BAD" ]; then
  R='양호'; EV='shadow 사용(전부 x)'
else
  R='취약'; EV="x 아님: ${BAD:-shadow없음}"
fi
emit "$ID" "$TITLE" "$SEV" "$R" "$EV" "$FIX"
