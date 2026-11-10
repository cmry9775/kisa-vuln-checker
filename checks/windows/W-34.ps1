#Requires -Version 5.1
. "$PSScriptRoot\..\..\lib\common.ps1"

$Id = 'W-34'; $Title = 'Telnet 서비스 비활성화'; $Sev = '중'
$Fix = 'Telnet 서비스(TlntSvr)를 중지하고 시작 유형을 사용 안 함으로 변경, 원격 접속이 필요하면 SSH로 대체'

$listening = $false
$evidenceDetail = ''

try {
    $conns = Get-NetTCPConnection -LocalPort 23 -State Listen -ErrorAction Stop
    if ($conns) {
        $listening = $true
        $evidenceDetail = "Get-NetTCPConnection: LISTENING $(@($conns).Count)건"
    } else {
        $evidenceDetail = 'Get-NetTCPConnection: LISTENING 없음'
    }
} catch {
    $raw = (netstat -na 2>$null) | Select-String ':23\s.*LISTENING'
    if ($raw) {
        $listening = $true
        $evidenceDetail = "netstat: $($raw[0].Line.Trim())"
    } else {
        $evidenceDetail = 'netstat: 23번 포트 LISTENING 없음'
    }
}

$svc = Get-Service -Name 'TlntSvr' -ErrorAction SilentlyContinue
$svcInfo = if ($svc) { "TlntSvr 상태:$($svc.Status)/$($svc.StartType)" } else { 'TlntSvr 미설치' }

if ($listening) {
    Emit $Id $Title $Sev '취약' "23번 포트 LISTENING 상태 — $evidenceDetail, $svcInfo" $Fix
} else {
    Emit $Id $Title $Sev '양호' "23번 포트 LISTENING 아님 — $evidenceDetail, $svcInfo" $Fix
}
