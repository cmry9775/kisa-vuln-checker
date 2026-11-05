#Requires -Version 5.1
. "$PSScriptRoot\..\..\lib\common.ps1"

$Id = 'W-17'; $Title = '하드디스크 기본 공유 제거'; $Sev = '중'
$Fix = '레지스트리 HKLM\SYSTEM\CurrentControlSet\Services\lanmanserver\parameters\AutoShareServer 값을 0으로 설정 후 재부팅(또는 Server 서비스 재시작)'

$path = 'HKLM:\SYSTEM\CurrentControlSet\Services\lanmanserver\parameters'
$val = Get-RegValueSafe -Path $path -Name 'AutoShareServer'

if ($null -eq $val) {
    Emit $Id $Title $Sev '취약' "AutoShareServer 레지스트리 값 없음(값이 없으면 기본 공유가 자동 생성되는 기본 동작과 동일) — 경로: $path" $Fix
} elseif ($val -eq 0) {
    Emit $Id $Title $Sev '양호' 'AutoShareServer=0 (기본 공유 비활성화됨)' $Fix
} else {
    Emit $Id $Title $Sev '취약' "AutoShareServer=$val (기본 공유 활성화됨, 기준: 0)" $Fix
}
