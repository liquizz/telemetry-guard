using System.Runtime.Versioning;
using Microsoft.Extensions.Hosting.WindowsServices;
using TelemetryGuardService.Options;

namespace TelemetryGuardService;

[SupportedOSPlatform("windows")]
public class Program
{
    public static void Main(string[] args)
    {
        var builder = Host.CreateApplicationBuilder(new HostApplicationBuilderSettings
        {
            Args = args,
            ContentRootPath = WindowsServiceHelpers.IsWindowsService()
                ? AppContext.BaseDirectory
                : default
        });

        builder.Services.AddWindowsService(options =>
        {
            options.ServiceName = "TelemetryGuardService";
        });

        builder.Logging.AddEventLog(eventLogSettings =>
        {
            eventLogSettings.SourceName = "TelemetryGuardService";
            eventLogSettings.LogName = "Application";
        });
        
        var guardOptions = builder.Configuration.GetSection("TelemetryGuard");
        builder.Services.Configure<TelemetryGuardOptions>(guardOptions);

        builder.Services.AddHostedService<Worker>();

        var host = builder.Build();
        host.Run();
    }
}