# Disable Windows Telemetry in Windows
# Run this script as Administrator

Write-Host "Disabling telemetry services..." -ForegroundColor Cyan

# 1. Stop and disable telemetry services
$services = @(
    'DiagTrack',       # Connected User Experiences and Telemetry
    'dmwappushsvc'     # dmwappush service
)

foreach ($svc in $services) {
    if (Get-Service -Name $svc -ErrorAction SilentlyContinue) {
        Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
        Set-Service  -Name $svc -StartupType Disabled
        Write-Host "  - $svc stopped and disabled"
    } else {
        Write-Host "  - $svc not found" -ForegroundColor Yellow
    }
}

# 2. Disable telemetry-related scheduled tasks
Write-Host "Disabling telemetry scheduled tasks..." -ForegroundColor Cyan

$tasks = @(
    '\Microsoft\Windows\Application Experience\ProgramDataUpdater',
    '\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser',
    '\Microsoft\Windows\Customer Experience Improvement Program\Consolidator',
    '\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask',
    '\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip'
)

foreach ($taskPath in $tasks) {
    $taskName = Split-Path $taskPath -Leaf
    $taskFolder = Split-Path $taskPath
    try {
        Disable-ScheduledTask -TaskPath $taskFolder -TaskName $taskName -ErrorAction Stop
        Write-Host "  - Disabled task: $taskPath"
    } catch {
        Write-Host "  - Task not found or already disabled: $taskPath" -ForegroundColor Yellow
    }
}

# 3. Set registry to turn off Windows telemetry (AllowTelemetry = 0)
Write-Host "Configuring registry to block telemetry..." -ForegroundColor Cyan

$regPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'
If (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
    Write-Host "  - Created registry path $regPath"
}

Set-ItemProperty -Path $regPath -Name 'AllowTelemetry' -Value 0 -Type DWord
Write-Host "  - Set AllowTelemetry = 0"

Write-Host "Telemetry disabling complete." -ForegroundColor Green
