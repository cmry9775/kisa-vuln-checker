#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
ID='U-01'; TITLE='root 계정 원격 접속 제한'; SEV='상'
FIX='sshd_config에 PermitRootLogin no 설정 후 sshd 재시작'
CONF='/etc/ssh/sshd_config'
if [ ! -f "$CONF" ]; then
  emit "$ID" "$TITLE" "$SEV" 'N/A' 'sshd_config 없음(SSH 미설치)' "$FIX"; exit 0
fi
VAL=$(conf_val "$CONF" PermitRootLogin | awk '{print tolower($NF)}')
[ "$VAL" = 'no' ] && R='양호' || R='취약'
emit "$ID" "$TITLE" "$SEV" "$R" "PermitRootLogin=${VAL:-미설정}" "$FIX"
