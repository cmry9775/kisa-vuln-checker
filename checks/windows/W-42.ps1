#Requires -Version 5.1
. "$PSScriptRoot\..\..\lib\common.ps1"

$Id = 'W-42'; $Title = '이벤트 로그 관리 설정'; $Sev = '중'
$Fix = '이벤트 뷰어에서 보안 로그 속성 > 최대 로그 크기를 10240KB 이상으로, 로그가 가득 차면 "필요한 경우 이벤트 덮어쓰기(오래된 이벤트부터)"로 설정'

try {
    $raw = (wevtutil gl Security 2>$null) | Out-String
} catch {
    Emit $Id $Title $Sev 'N/A' "wevtutil 실행 실패: $($_.Exception.Message)" $Fix
    exit 0
}

if (-not $raw -or $raw.Trim().Length -eq 0) {
    Emit $Id $Title $Sev 'N/A' 'wevtutil gl Security 출력이 비어 있음(권한 부족 또는 로그 채널 접근 불가 가능)' $Fix
    exit 0
}

$maxSizeMatch = [regex]::Match($raw, 'maxSize:\s*(\d+)')
$retentionMatch = [regex]::Match($raw, 'retention:\s*(true|false)')

if (-not $maxSizeMatch.Success -or -not $retentionMatch.Success) {
    $preview = $raw.Substring(0, [Math]::Min(200, $raw.Length))
    Emit $Id $Title $Sev '수동' "wevtutil 출력에서 maxSize/retention 값을 파싱하지 못함 — 이벤트 뷰어에서 직접 확인 필요(원본 일부: $preview)" $Fix
    exit 0
}

$maxSizeBytes = [int64]$maxSizeMatch.Groups[1].Value
$maxSizeKB = [math]::Round($maxSizeBytes / 1024, 0)
$retention = $retentionMatch.Groups[1].Value

$evid = "보안 로그 최대 크기: ${maxSizeKB}KB (기준: 10240KB 이상), retention=$retention (기준: false=필요 시 이벤트 덮어쓰기)"

if ($maxSizeKB -ge 10240 -and $retention -eq 'false') {
    Emit $Id $Title $Sev '양호' $evid $Fix
} else {
    Emit $Id $Title $Sev '취약' $evid $Fix
}
