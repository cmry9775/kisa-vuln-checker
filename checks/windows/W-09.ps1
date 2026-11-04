#Requires -Version 5.1
. "$PSScriptRoot\..\..\lib\common.ps1"

$Id = 'W-09'; $Title = '비밀번호 관리 정책 설정'; $Sev = '상'
$Fix = 'net accounts /minpwlen:8 /maxpwage:90 /minpwage:1 /uniquepw:4'

$minLen  = Get-SecPolicyValue -Key 'MinimumPasswordLength'
$maxAge  = Get-SecPolicyValue -Key 'MaximumPasswordAge'
$minAge  = Get-SecPolicyValue -Key 'MinimumPasswordAge'
$history = Get-SecPolicyValue -Key 'PasswordHistorySize'

if ($null -eq $minLen -or $null -eq $maxAge -or $null -eq $minAge -or $null -eq $history) {
    Emit $Id $Title $Sev 'N/A' '보안 정책 값(비밀번호 관리 정책)을 조회할 수 없음' $Fix
    exit 0
}

$ml = ConvertTo-SafeInt -Value $minLen
$ma = ConvertTo-SafeInt -Value $maxAge
$mi = ConvertTo-SafeInt -Value $minAge
$hs = ConvertTo-SafeInt -Value $history

$evid = "최소길이:$ml, 최대 사용기간:${ma}일, 최소 사용기간:${mi}일, 암호 기록:$hs"
$criteria = "(기준: 길이>=8, 최대기간 1~90일, 최소기간>=1일, 기록>=4)"

if ($ml -ge 8 -and $ma -gt 0 -and $ma -le 90 -and $mi -ge 1 -and $hs -ge 4) {
    Emit $Id $Title $Sev '양호' "$evid $criteria" $Fix
} else {
    Emit $Id $Title $Sev '취약' "$evid $criteria" $Fix
}
