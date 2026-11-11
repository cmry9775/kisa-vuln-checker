#Requires -Version 5.1
# Windows 전체 점검 실행 → JSON 배열 출력 (요약은 stderr)
# 사용법 (관리자 PowerShell): .\run_all_windows.ps1 > results\win_result.json
#
# Linux run_all.sh(12일차 리팩토링: 타임아웃·권한부족/크래시 N/A 흡수, 병렬 실행)와 동일한 설계 목표를
# PowerShell로 구현. 1차 구현은 순차 실행 + 타임아웃/오류 흡수까지만 적용하고, 병렬 실행(Start-Job 풀링)은
# 항목 수가 늘어나는 다음 단계에서 추가할 예정.
# 환경변수: TIMEOUT(초, 기본 30), CHECKS_GLOB(테스트용 점검 스크립트 glob 패턴 오버라이드)

$ErrorActionPreference = 'Stop'
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ScriptDir

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    [Console]::Error.WriteLine('[주의] 관리자 권한이 아니면 일부 점검(보안 정책 조회 등)이 부정확할 수 있습니다.')
}

$Timeout = if ($env:TIMEOUT) { [int]$env:TIMEOUT } else { 30 }
$ChecksGlob = if ($env:CHECKS_GLOB) { $env:CHECKS_GLOB } else { 'checks\windows\W-*.ps1' }

$scripts = Get-ChildItem -Path $ChecksGlob -ErrorAction SilentlyContinue | Sort-Object Name
$results = New-Object System.Collections.Generic.List[object]

foreach ($s in $scripts) {
    $id = $s.BaseName

    $job = Start-Job -ScriptBlock { param($path) & $path } -ArgumentList $s.FullName
    $finished = Wait-Job -Job $job -Timeout $Timeout

    if (-not $finished) {
        Stop-Job -Job $job | Out-Null
        Remove-Job -Job $job -Force | Out-Null
        $results.Add([PSCustomObject]@{
            id = $id; title = '실행 시간 초과'; severity = '-'; result = 'N/A'
            evidence = "점검 스크립트가 ${Timeout}초 내에 응답하지 않아 중단함"
            remediation = '스크립트 로직 점검 또는 TIMEOUT 환경변수 값 상향 필요'
        })
        continue
    }

    $stdout = Receive-Job -Job $job -ErrorAction SilentlyContinue
    $jobErr = ($job.ChildJobs[0].Error | Out-String).Trim()
    $jobState = $job.State
    Remove-Job -Job $job -Force | Out-Null

    $text = ($stdout | Out-String).Trim()
    $parsed = $null
    if ($text) {
        try { $parsed = $text | ConvertFrom-Json } catch { $parsed = $null }
    }

    if ($jobState -eq 'Failed' -or -not $parsed) {
        $errText = if ($jobErr) { $jobErr } else { "표준출력이 올바른 JSON이 아님: $($text.Substring(0, [Math]::Min(200, $text.Length)))" }
        if ($errText -match 'Access is denied|UnauthorizedAccess|권한') {
            $results.Add([PSCustomObject]@{
                id = $id; title = '실행 권한 부족'; severity = '-'; result = 'N/A'
                evidence = "권한 부족으로 점검 불가: $($errText.Substring(0, [Math]::Min(200, $errText.Length)))"
                remediation = '관리자 권한으로 run_all_windows.ps1 재실행'
            })
        } else {
            $results.Add([PSCustomObject]@{
                id = $id; title = '실행 오류'; severity = '-'; result = 'N/A'
                evidence = "스크립트 실행 오류: $($errText.Substring(0, [Math]::Min(200, $errText.Length)))"
                remediation = '스크립트 문법·의존 cmdlet 확인 필요'
            })
        }
        continue
    }

    $results.Add($parsed)
}

$sorted = $results | Sort-Object id
$jsonOut = $sorted | ConvertTo-Json
if ($sorted.Count -le 1) { $jsonOut = "[`n$jsonOut`n]" }
Write-Output $jsonOut

$total = $sorted.Count
$good   = ($sorted | Where-Object { $_.result -eq '양호' }).Count
$bad    = ($sorted | Where-Object { $_.result -eq '취약' }).Count
$manual = ($sorted | Where-Object { $_.result -eq '수동' }).Count
$na     = ($sorted | Where-Object { $_.result -eq 'N/A' }).Count
[Console]::Error.WriteLine("== 요약: 총 ${total}건 | 양호 $good | 취약 $bad | 수동 $manual | N/A $na")
