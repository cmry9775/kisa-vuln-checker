#Requires -Version 5.1
. "$PSScriptRoot\..\..\lib\common.ps1"

$Id = 'W-40'; $Title = '정책에 따른 시스템 로깅 설정'; $Sev = '상'
$Fix = 'auditpol /set /category:"로그온/로그오프","계정 관리","개체 액세스" /success:enable /failure:enable 등으로 주요 범주의 감사 정책을 성공 또는 실패로 설정'

try {
    $raw = (auditpol /get /category:* 2>$null) | Out-String
} catch {
    Emit $Id $Title $Sev 'N/A' "auditpol 실행 실패: $($_.Exception.Message)" $Fix
    exit 0
}

if (-not $raw -or $raw.Trim().Length -eq 0) {
    Emit $Id $Title $Sev 'N/A' 'auditpol 출력이 비어 있어 감사 정책을 확인할 수 없음' $Fix
    exit 0
}

# 하위 범주 줄은 "<범주명>   <설정값>" 형태로 끝에 성공/실패/성공 및 실패/감사 안 함 중 하나가 붙어 나옴
$resultPattern = '(성공 및 실패|성공|실패|감사 안 함)\s*$'
$lines = $raw -split "`r?`n" | Where-Object { $_.Trim().Length -gt 0 }
$subcategoryLines = $lines | Where-Object { $_ -match $resultPattern }

if ($subcategoryLines.Count -eq 0) {
    Emit $Id $Title $Sev '수동' "auditpol 출력에서 하위 범주 설정값을 식별하지 못함 — 출력 형식이 예상과 달라 수동 확인 필요" $Fix
    exit 0
}

$notConfigured = $subcategoryLines | Where-Object { $_ -match '감사 안 함\s*$' }
$configured = $subcategoryLines | Where-Object { $_ -notmatch '감사 안 함\s*$' }

$total = $subcategoryLines.Count
$configuredCount = $configured.Count
$notConfiguredCount = $notConfigured.Count
$evid = "하위 범주 $total 건 중 감사 설정됨(성공/실패) $configuredCount 건, 감사 안 함 $notConfiguredCount 건"

if ($configuredCount -gt 0 -and $notConfiguredCount -eq 0) {
    Emit $Id $Title $Sev '양호' $evid $Fix
} elseif ($configuredCount -eq 0) {
    Emit $Id $Title $Sev '취약' "$evid (대부분의 항목이 감사 안 함으로 설정됨)" $Fix
} else {
    Emit $Id $Title $Sev '수동' "$evid — 일부만 설정됨, 로그온/로그오프·계정 관리·개체 액세스 등 핵심 범주가 포함됐는지 직접 확인 필요" $Fix
}
