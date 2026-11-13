#Requires -Version 5.1

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

    # secedit /export 결과물은 UTF-16(유니코드) 인코딩으로 생성.
    $line = Select-String -Path $cfgPath -Pattern "^$Key\s*=" -Encoding Unicode -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $line) { return $null }

    $val = ($line.Line -split '=', 2)[1]
    return $val.Trim().Trim('"')
}

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

function ConvertTo-SafeInt {
    param([string]$Value, [int]$Default = -1)
    [int]$n = 0
    if ([int]::TryParse($Value, [ref]$n)) { return $n }
    return $Default
}
