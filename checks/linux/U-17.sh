#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
ID='U-17'; TITLE='시스템 시작 스크립트 권한 설정'; SEV='상'
FIX='chown root <파일>; chmod o-w <파일> (일반 사용자 쓰기 권한 제거)'
BAD=""
# systemd 유닛(심볼릭 링크는 실제 파일 기준) + SysV init 스크립트
for f in /etc/systemd/system/* /etc/init.d/* /etc/rc.local; do
  [ -e "$f" ] || continue
  real=$(readlink -f "$f" 2>/dev/null) || continue
  [ -f "$real" ] || continue
  o=$(stat -c '%U' "$real")
  p=$(stat -c '%a' "$real")
  # 소유자가 root 가 아니거나 others 쓰기 비트(o+w)가 있으면 취약
  if [ "$o" != "root" ] || (( (8#$p & 8#002) != 0 )); then
    BAD="$BAD $real($o,$p)"
  fi
done
if [ -z "$BAD" ]; then
  R='양호'; EV='시작 스크립트 소유자 root, 일반 사용자 쓰기 권한 없음'
else
  R='취약'; EV="부적절:${BAD}"
fi
emit "$ID" "$TITLE" "$SEV" "$R" "$EV" "$FIX"
