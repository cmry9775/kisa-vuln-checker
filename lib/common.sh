#!/usr/bin/env bash
# 공통 함수 — 모든 점검 스크립트가 source 해서 사용
set -u

# 결과 출력: emit <id> <title> <severity> <result> <evidence> <remediation>
# result 값은 양호 / 취약 / 수동 / N/A 네 가지로 고정
emit() {
  jq -n --arg id "$1" --arg title "$2" --arg severity "$3" \
        --arg result "$4" --arg evidence "$5" --arg remediation "$6" \
        '{id:$id,title:$title,severity:$severity,result:$result,evidence:$evidence,remediation:$remediation}'
}

# 권한이 기준(8진수) 이하인가: perm_le <file> <max,예 644>  → 0 성공=양호
perm_le() {
  local f="$1" max="$2" perm
  [ -e "$f" ] || return 2
  perm=$(stat -c '%a' "$f")
  (( (8#$perm & ~8#$max) == 0 ))
}

# 소유자 확인: owner_is <file> <user>
owner_is() { [ "$(stat -c '%U' "$1" 2>/dev/null)" = "$2" ]; }

# 설정값 읽기(주석 제외, 마지막 매칭): conf_val <file> <key>
conf_val() {
  grep -Ei "^[[:space:]]*$2([[:space:]]|=)" "$1" 2>/dev/null \
    | grep -v '^[[:space:]]*#' | tail -1
}
