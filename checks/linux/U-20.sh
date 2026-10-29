#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
ID='U-20'; TITLE='r 계열 서비스 비활성화 (rsh/rlogin/rexec)'; SEV='상'
FIX='xinetd.d의 shell/login/exec disable = yes 설정, .rhosts/hosts.equiv 파일 제거'
SERVICES="shell login exec"
BAD=""
for s in $SERVICES; do
  f="/etc/xinetd.d/$s"
  if [ -f "$f" ]; then
    V=$(conf_val "$f" disable | awk '{print tolower($NF)}')
    [ "$V" = 'no' ] && BAD="$BAD $s(xinetd)"
  fi
done
[ -s /etc/hosts.equiv ] && BAD="$BAD hosts.equiv"
shopt -s nullglob
for rc in /root/.rhosts /home/*/.rhosts; do
  [ -s "$rc" ] && BAD="$BAD $rc"
done
shopt -u nullglob
if [ -z "$BAD" ]; then
  R='양호'; EV='rsh/rlogin/rexec 비활성, .rhosts·hosts.equiv 미사용'
else
  R='취약'; EV="발견:${BAD}"
fi
emit "$ID" "$TITLE" "$SEV" "$R" "$EV" "$FIX"
