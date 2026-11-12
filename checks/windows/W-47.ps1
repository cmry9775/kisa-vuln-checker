#Requires -Version 5.1
. "$PSScriptRoot\..\..\lib\common.ps1"

$Id = 'W-47'; $Title = '화면 보호기 설정'; $Sev = '중'
$Fix = '레지스트리 HKCU\Control Panel\Desktop 에서 ScreenSaveActive=1, ScreenSaverIsSecure=1, ScreenSaveTimeOut을 600(10분) 이하로 설정'

$path = 'HKCU:\Control Panel\Desktop'
$active = Get-RegValueSafe -Path $path -Name 'ScreenSaveActive'
$secure = Get-RegValueSafe -Path $path -Name 'ScreenSaverIsSecure'
$timeoutRaw = Get-RegValueSafe -Path $path -Name 'ScreenSaveTimeOut'
$timeout = ConvertTo-SafeInt -Value $timeoutRaw -Default -1

$activeOn = ($active -eq '1' -or $active -eq 1)
$secureOn = ($secure -eq '1' -or $secure -eq 1)
$timeoutOk = ($timeout -ge 0 -and $timeout -le 600)

function Show-Val($v) { if ($null -eq $v -or "$v" -eq '') { '(없음)' } else { "$v" } }
$evid = "ScreenSaveActive=$(Show-Val $active), ScreenSaverIsSecure=$(Show-Val $secure), ScreenSaveTimeOut=$(Show-Val $timeoutRaw) (기준: 활성화(1) + 암호 보호(1) + 대기시간 600초 이하)"

if ($activeOn -and $secureOn -and $timeoutOk) {
    Emit $Id $Title $Sev '양호' $evid $Fix
} else {
    Emit $Id $Title $Sev '취약' $evid $Fix
}
