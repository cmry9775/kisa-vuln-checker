#Requires -Version 5.1
. "$PSScriptRoot\..\..\lib\common.ps1"

$Id = 'W-01'; $Title = 'Administrator 계정 이름 변경'; $Sev = '중'
$Fix = '기본 Administrator 계정명을 다른 이름으로 변경하거나, 변경이 어려우면 해당 계정을 비활성화'

try {
    $admin = Get-LocalUser | Where-Object { $_.SID -like '*-500' } | Select-Object -First 1
} catch {
    Emit $Id $Title $Sev 'N/A' "계정 정보 조회 실패: $($_.Exception.Message)" $Fix
    exit 0
}

if (-not $admin) {
    Emit $Id $Title $Sev 'N/A' '기본 Administrator 계정(SID ...-500)을 찾을 수 없음' $Fix
    exit 0
}

if ($admin.Name -ne 'Administrator') {
    Emit $Id $Title $Sev '양호' "계정명 변경됨: $($admin.Name)" $Fix
} elseif (-not $admin.Enabled) {
    Emit $Id $Title $Sev '양호' '계정명은 기본값(Administrator)이나 비활성화됨(Enabled=False)' $Fix
} else {
    Emit $Id $Title $Sev '취약' '기본 계정명(Administrator)을 그대로 사용 중이며 활성 상태' $Fix
}
