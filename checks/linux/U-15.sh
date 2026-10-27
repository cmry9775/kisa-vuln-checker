#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
ID='U-15'; TITLE='파일 및 디렉토리 소유자 설정'; SEV='상'
FIX='소유자/그룹 없는 파일은 제거하거나 chown/chgrp 로 소유자 지정'
# -xdev: 다른 파일시스템(/proc 등) 제외. 결과 많을 수 있어 5개까지만 증거로 기록
LIST=$(timeout 60 find / -xdev \( -nouser -o -nogroup \) 2>/dev/null)
CNT=$(printf '%s' "$LIST" | grep -c .)
if [ "$CNT" -eq 0 ]; then
  R='양호'; EV='소유자/그룹 없는 파일 없음'
else
  R='취약'; EV="${CNT}건: $(printf '%s\n' "$LIST" | head -5 | paste -sd, -)"
fi
emit "$ID" "$TITLE" "$SEV" "$R" "$EV" "$FIX"
