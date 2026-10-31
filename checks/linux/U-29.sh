#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
ID='U-29'; TITLE='로그 기록(Syslog) 설정 여부 점검'; SEV='상'
FIX='rsyslog 또는 syslog-ng를 설치·설정하거나, journald Storage=persistent로 설정하여 로그를 영구 기록'

has_content() {
  [ -s "$1" ] && grep -Evq '^[[:space:]]*(#|$)' "$1"
}

if has_content /etc/rsyslog.conf; then
  emit "$ID" "$TITLE" "$SEV" '양호' 'rsyslog 설정 존재(/etc/rsyslog.conf)' "$FIX"; exit 0
fi

if has_content /etc/syslog-ng/syslog-ng.conf; then
  emit "$ID" "$TITLE" "$SEV" '양호' 'syslog-ng 설정 존재(/etc/syslog-ng/syslog-ng.conf)' "$FIX"; exit 0
fi

if [ -f /etc/systemd/journald.conf ]; then
  STORAGE=$(conf_val /etc/systemd/journald.conf Storage | cut -d= -f2 | tr -d ' ')
  STORAGE=${STORAGE:-auto}
  if [ "$STORAGE" = 'persistent' ] || { [ "$STORAGE" = 'auto' ] && [ -d /var/log/journal ]; }; then
    emit "$ID" "$TITLE" "$SEV" '양호' "systemd-journald 영구 로그 저장 활성(Storage=${STORAGE}, /var/log/journal 존재)" "$FIX"; exit 0
  fi
fi

emit "$ID" "$TITLE" "$SEV" '취약' 'rsyslog/syslog-ng 미설정, journald 영구 저장도 비활성 — 로그가 기록되지 않거나 재부팅 시 소실될 수 있음' "$FIX"
