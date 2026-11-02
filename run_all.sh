#!/usr/bin/env bash
# 전체 점검 실행 → JSON 배열 출력 (+ 요약은 stderr)
# 사용법: sudo ./run_all.sh [> result.json]
#
# 12일차 리팩토링: 개별 점검 스크립트를 블랙박스로 보고 실행기 레벨에서
#   1) 타임아웃: 스크립트가 멈추면 TIMEOUT초 뒤 강제 종료 → N/A로 기록
#   2) 권한 부족/비정상 종료: 크래시·잘못된 JSON·"Permission denied" 류 에러를
#      전체 실행을 중단시키지 않고 개별 N/A 레코드로 흡수
#   3) 병렬 실행: PARALLEL개씩 동시 실행(기본 CPU 코어 수)
# 환경변수: TIMEOUT(초, 기본 70), PARALLEL(동시 실행 수, 기본 nproc), CHECKS_GLOB(테스트용 점검 스크립트 glob 패턴 오버라이드)
# TIMEOUT 기본값은 U-15(파일 전수 스캔)가 내부적으로 거는 자체 timeout(60초)보다
# 여유 있게 길게 잡아, 실행기 레벨 타임아웃이 스크립트 자체의 안전장치보다 먼저
# 끼어들어 오탐(N/A)을 만들지 않도록 함.
set -u
cd "$(dirname "$0")" || exit 1
command -v jq >/dev/null || { echo "jq 필요: sudo apt install jq" >&2; exit 1; }
[ "$(id -u)" -eq 0 ] || echo "[주의] root 가 아니면 /etc/shadow 등 일부 점검이 부정확할 수 있습니다" >&2

TIMEOUT="${TIMEOUT:-70}"
PARALLEL="${PARALLEL:-$(nproc 2>/dev/null || echo 4)}"
CHECKS_GLOB="${CHECKS_GLOB:-checks/linux/U-*.sh}"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

# 점검 스크립트 1개를 안전하게 실행해 "$TMPDIR/<ID>.json"에 결과를 기록한다.
# 정상: 스크립트가 낸 JSON을 그대로 사용
# 타임아웃(exit 124): N/A, title="실행 시간 초과"
# 비정상 종료 또는 유효하지 않은 JSON:
#   - stderr에 "Permission denied"가 보이면 N/A, title="실행 권한 부족"
#   - 그 외는 N/A, title="실행 오류" (stderr 앞부분을 evidence에 포함)
run_one() {
  local s="$1" id out err rc outfile
  id=$(basename "$s" .sh)
  outfile="$TMPDIR/$id.json"

  out=$(timeout "$TIMEOUT" bash "$s" 2>"$TMPDIR/$id.err")
  rc=$?
  err=$(cat "$TMPDIR/$id.err" 2>/dev/null)
  rm -f "$TMPDIR/$id.err"

  if [ $rc -eq 124 ]; then
    jq -n --arg id "$id" --arg ev "점검 스크립트가 ${TIMEOUT}초 내에 응답하지 않아 중단함" \
      '{id:$id,title:"실행 시간 초과",severity:"-",result:"N/A",evidence:$ev,remediation:"스크립트 로직 점검 또는 TIMEOUT 환경변수 값 상향 필요"}' \
      > "$outfile"
    return
  fi

  if [ $rc -ne 0 ] || ! jq -e . >/dev/null 2>&1 <<<"$out"; then
    if printf '%s' "$err" | grep -qi 'permission denied'; then
      jq -n --arg id "$id" --arg ev "권한 부족으로 점검 불가: ${err:0:200}" \
        '{id:$id,title:"실행 권한 부족",severity:"-",result:"N/A",evidence:$ev,remediation:"root 권한으로 run_all.sh 재실행(sudo)"}' \
        > "$outfile"
    else
      jq -n --arg id "$id" --arg ev "스크립트 실행 오류(exit ${rc}): ${err:0:200}" \
        '{id:$id,title:"실행 오류",severity:"-",result:"N/A",evidence:$ev,remediation:"스크립트 문법·의존 명령 확인 필요"}' \
        > "$outfile"
    fi
    return
  fi

  printf '%s' "$out" > "$outfile"
}
export -f run_one
export TIMEOUT TMPDIR

# shellcheck disable=SC2086
printf '%s\n' $CHECKS_GLOB | xargs -P "$PARALLEL" -I{} bash -c 'run_one "$@"' _ {}

OUT=$(cat "$TMPDIR"/U-*.json 2>/dev/null | jq -s 'sort_by(.id)')
echo "$OUT"
echo "$OUT" | jq -r '"== 요약: 총 \(length)건 | 양호 \(map(select(.result=="양호"))|length) | 취약 \(map(select(.result=="취약"))|length) | 수동 \(map(select(.result=="수동"))|length) | N/A \(map(select(.result=="N/A"))|length)"' >&2
