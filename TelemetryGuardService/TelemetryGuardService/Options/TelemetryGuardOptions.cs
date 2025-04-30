namespace TelemetryGuardService.Options;

public class TelemetryGuardOptions
{
    public string[] TelemetryServices { get; } = ["DiagTrack", "dmwappushsvc"];
    public TimeSpan CheckInterval { get; } = TimeSpan.FromMinutes(5);
    public TimeSpan StopTimeout { get; } = TimeSpan.FromSeconds(30);
}