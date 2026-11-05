#Requires -Version 5.1
. "$PSScriptRoot\..\..\lib\common.ps1"

$Id = 'W-18'; $Title = '불필요한 서비스 제거'; $Sev = '상'
$Fix = 'services.msc에서 Simple TCP/IP, SNMP, FTP Publishing, Telnet 서비스를 중지하고 시작 유형을 사용 안 함(또는 수동)으로 변경'

# Simple TCP/IP Services, SNMP Service, FTP Publishing Service(IIS), Telnet
$targets = @(
    @{ Name = 'SimpTcp';   Label = 'Simple TCP/IP Services' },
    @{ Name = 'SNMP';      Label = 'SNMP Service' },
    @{ Name = 'MSFTPSVC';  Label = 'FTP Publishing Service' },
    @{ Name = 'TlntSvr';   Label = 'Telnet' }
)

$running = @()
$checked = @()

foreach ($t in $targets) {
    $svc = Get-Service -Name $t.Name -ErrorAction SilentlyContinue
    if (-not $svc) {
        $checked += "$($t.Label)(미설치)"
        continue
    }
    $checked += "$($t.Label)($($svc.Status)/$($svc.StartType))"
    if ($svc.Status -eq 'Running') {
        $running += $t.Label
    }
}

if ($running.Count -eq 0) {
    Emit $Id $Title $Sev '양호' "불필요 서비스 실행 중인 것 없음 — $($checked -join ', ')" $Fix
} else {
    Emit $Id $Title $Sev '취약' "실행 중인 서비스: $($running -join ', ') — 전체 확인 결과: $($checked -join ', ')" $Fix
}
