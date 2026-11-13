#Requires -Version 5.1
. "$PSScriptRoot\..\..\lib\common.ps1"

$Id = 'W-64'; $Title = '윈도우 방화벽 설정'; $Sev = '상'
$Fix = 'netsh advfirewall set allprofiles state on 또는 제어판 > Windows Defender 방화벽에서 도메인/개인/공용 프로필 모두 켜기로 설정'

# 1) Get-NetFirewallProfile(NetSecurity 모듈)
$profiles = $null
try {
    $profiles = Get-NetFirewallProfile -ErrorAction Stop | Select-Object Name, Enabled
} catch {
    $profiles = $null
}

if ($profiles) {
    $offProfiles = $profiles | Where-Object { -not $_.Enabled }
    $evid = "Get-NetFirewallProfile: " + (($profiles | ForEach-Object { "$($_.Name)=$(if ($_.Enabled) {'ON'} else {'OFF'})" }) -join ', ')

    if ($offProfiles.Count -eq 0) {
        Emit $Id $Title $Sev '양호' "$evid (모든 프로필 ON)" $Fix
    } else {
        Emit $Id $Title $Sev '취약' "$evid (OFF인 프로필 존재, 기준: 전부 ON)" $Fix
    }
    exit 0
}

# 2) netsh 출력 직접 파싱 — 한국어 Windows는 "상태", 영문 Windows는 "State" 뒤에 ON/OFF가 옴
try {
    $raw = (netsh advfirewall show allprofiles 2>$null) | Out-String
} catch {
    Emit $Id $Title $Sev 'N/A' "방화벽 상태를 조회할 수 없음(Get-NetFirewallProfile, netsh 둘 다 실패)" $Fix
    exit 0
}

if (-not $raw -or $raw.Trim().Length -eq 0) {
    Emit $Id $Title $Sev 'N/A' 'netsh advfirewall show allprofiles 출력이 비어 있음(권한 부족 가능)' $Fix
    exit 0
}

$stateMatches = [regex]::Matches($raw, '(?:상태|State)\s+(ON|OFF)') | ForEach-Object { $_.Groups[1].Value }

if ($stateMatches.Count -eq 0) {
    $preview = $raw.Substring(0, [Math]::Min(200, $raw.Length))
    Emit $Id $Title $Sev '수동' "netsh 출력에서 상태(ON/OFF) 값을 식별하지 못함 — 직접 확인 필요(원본 일부: $preview)" $Fix
    exit 0
}

$offCount = ($stateMatches | Where-Object { $_ -eq 'OFF' }).Count
$evid = "netsh: " + ($stateMatches -join ', ') + " (도메인/개인/공용 순, 기준: 전부 ON)"

if ($offCount -eq 0) {
    Emit $Id $Title $Sev '양호' $evid $Fix
} else {
    Emit $Id $Title $Sev '취약' $evid $Fix
}
