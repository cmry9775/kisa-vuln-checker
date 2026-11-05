#Requires -Version 5.1
. "$PSScriptRoot\..\..\lib\common.ps1"

$Id = 'W-21'; $Title = '암호화되지 않는 FTP 서비스 비활성화'; $Sev = '중'
$Fix = 'FTP 서비스를 중지하거나, 필요 시 SFTP(SSH 기반) 등 암호화된 방식으로 전환'

$listening = $false
$evidenceDetail = ''

try {
    $conns = Get-NetTCPConnection -LocalPort 21 -State Listen -ErrorAction Stop
    if ($conns) {
        $listening = $true
        $evidenceDetail = "Get-NetTCPConnection: LISTENING $(@($conns).Count)건"
    } else {
        $evidenceDetail = 'Get-NetTCPConnection: LISTENING 없음'
    }
} catch {
    $raw = (netstat -na 2>$null) | Select-String ':21\s.*LISTENING'
    if ($raw) {
        $listening = $true
        $evidenceDetail = "netstat: $($raw[0].Line.Trim())"
    } else {
        $evidenceDetail = 'netstat: 21번 포트 LISTENING 없음'
    }
}

if ($listening) {
    Emit $Id $Title $Sev '취약' "21번 포트 LISTENING 상태 — $evidenceDetail" $Fix
} else {
    Emit $Id $Title $Sev '양호' "21번 포트 LISTENING 아님 — $evidenceDetail" $Fix
}
