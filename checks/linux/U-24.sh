#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
ID='U-24'; TITLE='OS 배포판 EOL(지원종료) 여부 점검'; SEV='상'
FIX='EOL(지원 종료)된 배포판은 최신 LTS/안정 버전으로 업그레이드'
REL='/etc/os-release'

if [ ! -f "$REL" ]; then
  emit "$ID" "$TITLE" "$SEV" '수동' '/etc/os-release 없음 — 배포판 확인 불가, 수동 확인 필요' "$FIX"; exit 0
fi

DIST_ID=$(conf_val "$REL" ID | cut -d= -f2 | tr -d '"')
DIST_VER=$(conf_val "$REL" VERSION_ID | cut -d= -f2 | tr -d '"')
TODAY=$(date +%Y-%m-%d)

# 알려진 주요 배포판 표준 지원 종료일(EOL) — 벤더 공식 발표 기준, 필요 시 docs/항목별_판단기준.md와 함께 갱신
EOL=""
case "${DIST_ID}/${DIST_VER}" in
  ubuntu/18.04) EOL="2023-05-31";;
  ubuntu/20.04) EOL="2025-04-02";;
  ubuntu/22.04) EOL="2027-04-21";;
  ubuntu/24.04) EOL="2029-04-25";;
  debian/10)    EOL="2022-09-10";;
  debian/11)    EOL="2024-08-14";;
  debian/12)    EOL="2026-06-10";;
  centos/7)     EOL="2024-06-30";;
  centos/8)     EOL="2021-12-31";;
  rhel/7)       EOL="2024-06-30";;
  rhel/8)       EOL="2029-05-31";;
esac

if [ -z "$EOL" ]; then
  emit "$ID" "$TITLE" "$SEV" '수동' "EOL 기준 데이터 미보유 배포판(${DIST_ID} ${DIST_VER}) — 벤더 공식 EOL 페이지에서 수동 확인 필요" "$FIX"; exit 0
fi

if [[ "$TODAY" > "$EOL" ]]; then
  R='취약'; EV="${DIST_ID} ${DIST_VER} EOL=${EOL} (오늘=${TODAY} 기준 지원 종료됨)"
else
  R='양호'; EV="${DIST_ID} ${DIST_VER} EOL=${EOL} (오늘=${TODAY} 기준 지원 중)"
fi
emit "$ID" "$TITLE" "$SEV" "$R" "$EV" "$FIX"
