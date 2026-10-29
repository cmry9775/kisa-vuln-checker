#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
ID='U-21'; TITLE='Anonymous FTP 비활성화'; SEV='상'
FIX='vsftpd.conf 등에서 anonymous_enable = NO 로 설정 후 서비스 재시작'
CONF=""
for f in /etc/vsftpd.conf /etc/vsftpd/vsftpd.conf /etc/proftpd/proftpd.conf; do
  [ -f "$f" ] && CONF="$f" && break
done
if [ -z "$CONF" ]; then
  emit "$ID" "$TITLE" "$SEV" 'N/A' 'FTP 서버 미설치' "$FIX"; exit 0
fi
VAL=$(conf_val "$CONF" anonymous_enable | awk -F= '{print tolower($NF)}' | tr -d ' ')
case "$VAL" in
  yes) R='취약';;
  *) R='양호'; VAL="${VAL:-no(기본값)}";;
esac
emit "$ID" "$TITLE" "$SEV" "$R" "anonymous_enable=${VAL}" "$FIX"
