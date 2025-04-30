# TelemetryGuard

A Windows service that actively monitors and blocks telemetry services to enhance your privacy. TelemetryGuard runs as a background service and automatically stops and disables Windows telemetry services.

## Features

- Runs as a Windows service
- Automatically stops and disables telemetry services
- Configurable service list and check intervals
- Requires administrator privileges for full functionality
- Logs all actions to Windows Event Log

## Supported Telemetry Services

By default, TelemetryGuard monitors and blocks the following services:
- DiagTrack (Connected User Experiences and Telemetry)
- dmwappushsvc (dmwappush service)

## Requirements

- Windows operating system
- .NET 9.0 or later
- Administrator privileges

## Installation

1. Clone the repository:
```bash
git clone https://github.com/liquizz/telemetry-guard.git
```

2. Build the solution:
```bash
cd telemetry-guard/TelemetryGuardService
dotnet publish -c Release -r win-x64 --self-contained
```

3. Install the service:
```bash
sc create TelemetryGuardService binPath= "path\to\TelemetryGuardService.exe" start= auto
sc description TelemetryGuardService "Blocks Windows telemetry services"
sc start TelemetryGuardService
```

## Configuration

The service can be configured through the `appsettings.json` file:

```json
{
  "TelemetryGuard": {
    "TelemetryServices": ["DiagTrack", "dmwappushsvc"],
    "CheckInterval": "00:05:00",
    "StopTimeout": "00:00:30"
  }
}
```

- `TelemetryServices`: List of services to monitor and block
- `CheckInterval`: How often to check for running telemetry services (default: 5 minutes)
- `StopTimeout`: Maximum time to wait for a service to stop (default: 30 seconds)

## PowerShell Script

The repository also includes a PowerShell script (`Scripts/DisableTelemetry.ps1`) that can be used to:
- Stop and disable telemetry services
- Disable telemetry-related scheduled tasks
- Configure registry settings to block telemetry

![Script Demo](https://github.com/user-attachments/assets/b828c798-6d4f-4419-9c00-e9c1cd0716c6)

To run the script:
```powershell
.\Scripts\DisableTelemetry.ps1
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Disclaimer

This software is provided "as is" without warranty of any kind. Use at your own risk. The author is not responsible for any issues that may arise from using this software. 
