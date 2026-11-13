#Requires -Version 5.1
. "$PSScriptRoot\..\..\lib\common.ps1"

$Id = 'W-39'; $Title = '백신 프로그램 업데이트'; $Sev = '상'
$Fix = '백신 프로그램을 설치하고 바이러스 정의를 최신(가능하면 1일 이내)으로 업데이트. Windows Defender는 Update-MpSignature'

# 1) Windows Defender 상태/정의 날짜 — AntivirusSignatureLastUpdated로 정의 최신성(시간 단위)을 직접 확인 가능
$mp = $null
try {
    $mp = Get-MpComputerStatus -ErrorAction Stop
} catch {
    $mp = $null
}

if ($mp) {
    $ageHours = $null
    if ($mp.AntivirusSignatureLastUpdated) {
        $ageHours = [math]::Round(((Get-Date) - $mp.AntivirusSignatureLastUpdated).TotalHours, 1)
    }
    $ageText = if ($null -ne $ageHours) { "${ageHours}시간 경과" } else { '확인 불가' }
    $evid = "Windows Defender: AntivirusEnabled=$($mp.AntivirusEnabled), 정의 업데이트: $ageText (기준: 가능하면 24시간 이내)"

    if ($mp.AntivirusEnabled -and $null -ne $ageHours -and $ageHours -le 24) {
        Emit $Id $Title $Sev '양호' $evid $Fix
    } else {
        Emit $Id $Title $Sev '취약' $evid $Fix
    }
    exit 0
}

# 2) Defender를 조회할 수 없는 경우(서버 Core, 타사 백신으로 Defender 비활성 등) — SecurityCenter2로 등록된 제품만 확인
$avProducts = $null
try {
    $avProducts = Get-CimInstance -Namespace 'root/SecurityCenter2' -ClassName 'AntivirusProduct' -ErrorAction Stop
} catch {
    $avProducts = $null
}

if ($avProducts) {
    $names = ($avProducts | Select-Object -ExpandProperty displayName) -join ', '
    Emit $Id $Title $Sev '수동' "SecurityCenter2에 등록된 백신 발견: $names (Defender 상태 조회 불가로 정의 최신 여부는 제품 콘솔에서 직접 확인 필요)" $Fix
} else {
    Emit $Id $Title $Sev 'N/A' '백신 상태를 조회할 수 없음(Get-MpComputerStatus, SecurityCenter2 둘 다 실패 — 서버 Core 환경이거나 WMI 네임스페이스 미지원 가능)' $Fix
}
