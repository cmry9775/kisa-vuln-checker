#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
ID='U-19'; TITLE='불필요한 서비스 비활성화 (finger·telnet·tftp·talk)'; SEV='상'
FIX='xinetd.d 설정에서 해당 서비스 disable = yes 로 변경, 또는 패키지 제거 후 systemctl disable --now'
SERVICES="finger telnet tftp talk"
BAD=""
for s in $SERVICES; do
  f="/etc/xinetd.d/$s"
  if [ -f "$f" ]; then
    V=$(conf_val "$f" disable | awk '{print tolower($NF)}')
    [ "$V" = 'no' ] && BAD="$BAD $s(xinetd)"
  fi
done
if [ -f /etc/inetd.conf ]; then
  L=$(grep -Ei '^[[:space:]]*(finger|telnet|tftp|talk)[[:space:]]' /etc/inetd.conf | grep -v '^[[:space:]]*#')
  [ -n "$L" ] && BAD="$BAD inetd.conf"
fi
if [ -z "$BAD" ]; then
  R='양호'; EV='finger/telnet/tftp/talk 서비스가 활성 설정되어 있지 않음'
else
  R='취약'; EV="활성화된 서비스:${BAD}"
fi
emit "$ID" "$TITLE" "$SEV" "$R" "$EV" "$FIX"
