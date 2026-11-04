#Requires -Version 5.1
. "$PSScriptRoot\..\..\lib\common.ps1"

$Id = 'W-08'; $Title = '계정 잠금 기간 설정'; $Sev = '중'
$Fix = 'net accounts /lockoutduration:60 /lockoutwindow:60  (잠금 기간·관찰 창 모두 60분 이상)'

$duration = Get-SecPolicyValue -Key 'LockoutDuration'
$window   = Get-SecPolicyValue -Key 'ResetLockoutCount'

if ($null -eq $duration -or $null -eq $window) {
    Emit $Id $Title $Sev 'N/A' '보안 정책 값(LockoutDuration/ResetLockoutCount)을 조회할 수 없음' $Fix
    exit 0
}

$d = ConvertTo-SafeInt -Value $duration
$w = ConvertTo-SafeInt -Value $window
$evid = "잠금 기간:${d}분, 잠금 관찰 창:${w}분 (기준: 둘 다 60분 이상)"

if ($d -ge 60 -and $w -ge 60) {
    Emit $Id $Title $Sev '양호' $evid $Fix
} else {
    Emit $Id $Title $Sev '취약' $evid $Fix
}
