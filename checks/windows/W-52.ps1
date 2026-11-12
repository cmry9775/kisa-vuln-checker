#Requires -Version 5.1
. "$PSScriptRoot\..\..\lib\common.ps1"

$Id = 'W-52'; $Title = 'Autologon(자동 로그온) 기능 제어'; $Sev = '상'
$Fix = '레지스트리 HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon 의 AutoAdminLogon 값을 0으로 설정(또는 키 삭제), DefaultPassword 값이 남아있다면 함께 제거'

$path = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
$val = Get-RegValueSafe -Path $path -Name 'AutoAdminLogon'

if ($null -eq $val -or $val -eq '0' -or $val -eq 0) {
    Emit $Id $Title $Sev '양호' "AutoAdminLogon 값 없음 또는 0 (자동 로그온 비활성화됨, 실제값: $val)" $Fix
} else {
    Emit $Id $Title $Sev '취약' "AutoAdminLogon=$val (자동 로그온 활성화됨, 기준: 0 또는 키 없음)" $Fix
}
