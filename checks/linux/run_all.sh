#!/usr/bin/env bash
# 전체 점검 실행 → JSON 배열 출력 (+ 요약은 stderr)
# 사용법: sudo ./run_all.sh [> result.json]
cd "$(dirname "$0")" || exit 1
command -v jq >/dev/null || { echo "jq 필요: sudo apt install jq" >&2; exit 1; }
[ "$(id -u)" -eq 0 ] || echo "[주의] root 가 아니면 /etc/shadow 등 일부 점검이 부정확할 수 있습니다" >&2

OUT=$(for s in checks/linux/U-*.sh; do bash "$s"; done | jq -s '.')
echo "$OUT"
echo "$OUT" | jq -r '"== 요약: 총 \(length)건 | 양호 \(map(select(.result=="양호"))|length) | 취약 \(map(select(.result=="취약"))|length) | 수동 \(map(select(.result=="수동"))|length) | N/A \(map(select(.result=="N/A"))|length)"' >&2
