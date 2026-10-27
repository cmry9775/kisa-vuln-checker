#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
ID='U-14'; TITLE='root 홈, 패스 디렉터리 권한 및 패스 설정'; SEV='상'
FIX='/etc/profile, ~/.profile, ~/.bashrc 의 PATH 에서 "." 및 빈 항목(::, 앞뒤 :) 제거 또는 맨 뒤로 이동'
FILES="/etc/environment /etc/profile /root/.profile /root/.bashrc /root/.bash_profile"
BAD=""
for f in $FILES; do
  [ -f "$f" ] || continue
  # 주석 제외, PATH= 라인에서 '.' 항목 또는 빈 항목(::, 앞 :, 끝 :) 탐지
  L=$(grep -E '^[[:space:]]*(export[[:space:]]+)?PATH=' "$f" 2>/dev/null \
      | grep -E '(=|:)\.(:|"|'"'"'|$)|::|=:|:["'"'"']?$' )
  [ -n "$L" ] && BAD="$BAD $f"
done
# 현재 root 환경의 PATH 도 확인
case ":${PATH}:" in *:.:*|*::*) BAD="$BAD (현재PATH)";; esac
if [ -z "$BAD" ]; then
  R='양호'; EV='PATH 에 "." 또는 빈 항목 없음'
else
  R='취약'; EV="PATH 에 . 또는 빈 항목 포함:${BAD}"
fi
emit "$ID" "$TITLE" "$SEV" "$R" "$EV" "$FIX"
