# lib/common.ps1 — 공통 함수. 모든 Windows 점검 스크립트가 dot-source(. )해서 사용
# Linux 쪽 lib/common.sh(emit/perm_le/owner_is/conf_val)와 동일한 역할·스키마를 PowerShell로 구현.
#Requires -Version 5.1

# 결과 출력: Emit <id> <title> <severity> <result> <evidence> <remediation>
# result 값은 양호 / 취약 / 수동 / N/A 네 가지로 고정 (Linux 스크립트와 동일 스키마)
function Emit {
    param(
        [Parameter(Mandatory)][string]$Id,
        [Parameter(Mandatory)][string]$Title,
        [Parameter(Mandatory)][string]$Severity,
        [Parameter(Mandatory)][string]$Result,
        [Parameter(Mandatory)][string]$Evidence,
        [Parameter(Mandatory)][string]$Remediation
    )
    [PSCustomObject]@{
        id          = $Id
        title       = $Title
        severity    = $Severity
        result      = $Result
        evidence    = $Evidence
        remediation = $Remediation
    } | ConvertTo-Json -Compress
}

# secedit 로 내보낸 보안 정책(계정 정책 등) 값 조회.
# 세션(run_all.ps1 1회 실행)마다 $env:TEMP에 1번만 export해 모든 점검 스크립트가 재사용.
function Get-SecPolicyValue {
    param([Parameter(Mandatory)][string]$Key)

    $cfgPath = Join-Path $env:TEMP 'kisa_secpol.cfg'
    if (-not (Test-Path $cfgPath) -or (Get-Item $cfgPath).Length -eq 0) {
        try {
            secedit /export /cfg "$cfgPath" /quiet | Out-Null
        } catch {
            return $null
        }
    }
    if (-not (Test-Path $cfgPath) -or (Get-Item $cfgPath).Length -eq 0) { return $null }

    # secedit /export 결과물은 UTF-16(유니코드) 인코딩으로 생성됨.
    # Select-String에 인코딩을 지정하지 않으면 기본 인코딩으로 읽혀 텍스트가 깨지고
    # 패턴 매칭이 전부 실패한다(모든 secedit 기반 항목이 N/A로 나오는 원인이었음).
    $line = Select-String -Path $cfgPath -Pattern "^$Key\s*=" -Encoding Unicode -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $line) { return $null }

    $val = ($line.Line -split '=', 2)[1]
    return $val.Trim().Trim('"')
}

# 레지스트리 값 읽기 : 없거나 조회 실패 시 $null 반환 (존재 자체가 취약/양호 판정에 쓰이는 경우가 많음)
function Get-RegValueSafe {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Name
    )
    try {
        return (Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop).$Name
    } catch {
        return $null
    }
}

# 문자열을 정수로 안전하게 변환 : 실패 시 $Default 반환
function ConvertTo-SafeInt {
    param([string]$Value, [int]$Default = -1)
    [int]$n = 0
    if ([int]::TryParse($Value, [ref]$n)) { return $n }
    return $Default
}
