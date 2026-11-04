#Requires -Version 5.1
. "$PSScriptRoot\..\..\lib\common.ps1"

$Id = 'W-02'; $Title = 'Guest 계정 비활성화'; $Sev = '상'
$Fix = 'Guest 계정을 비활성화 (Disable-LocalUser -Name Guest)'

try {
    $guest = Get-LocalUser -Name 'Guest' -ErrorAction Stop
} catch {
    Emit $Id $Title $Sev 'N/A' "Guest 계정을 찾을 수 없음: $($_.Exception.Message)" $Fix
    exit 0
}

if ($guest.Enabled) {
    Emit $Id $Title $Sev '취약' 'Guest 계정 활성화됨(Enabled=True)' $Fix
} else {
    Emit $Id $Title $Sev '양호' 'Guest 계정 비활성화됨(Enabled=False)' $Fix
}
