#Requires -Version 5.1
. "$PSScriptRoot\..\..\lib\common.ps1"

$Id = 'W-04'; $Title = '계정 잠금 임계값 설정'; $Sev = '상'
$Fix = 'net accounts /lockoutthreshold:5  (1~5 사이 값으로 설정, 0=제한 없음은 금지)'

$val = Get-SecPolicyValue -Key 'LockoutBadCount'
if ($null -eq $val) {
    Emit $Id $Title $Sev 'N/A' '보안 정책 값(LockoutBadCount)을 조회할 수 없음(secedit 실행 권한 확인 필요)' $Fix
    exit 0
}

$n = ConvertTo-SafeInt -Value $val
if ($n -eq -1) {
    Emit $Id $Title $Sev 'N/A' "LockoutBadCount 값을 해석할 수 없음: $val" $Fix
    exit 0
}

if ($n -ge 1 -and $n -le 5) {
    Emit $Id $Title $Sev '양호' "잠금 임계값: $n (기준: 1~5)" $Fix
} else {
    Emit $Id $Title $Sev '취약' "잠금 임계값: $n (기준: 1~5, 0=제한 없음)" $Fix
}
