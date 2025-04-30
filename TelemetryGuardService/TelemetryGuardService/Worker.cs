using Microsoft.Extensions.Options;
using System.Runtime.Versioning;
using System.Security.Principal;
using System.ServiceProcess;
using TelemetryGuardService.Options;

namespace TelemetryGuardService;

[SupportedOSPlatform("windows")]
public class Worker(ILogger<Worker> logger, IOptions<TelemetryGuardOptions> options)
    : BackgroundService
{
    private readonly TelemetryGuardOptions _options = options.Value;
    private bool _isAdministrator;

    public override async Task StartAsync(CancellationToken cancellationToken)
    {
        _isAdministrator = CheckAdminPrivileges();
        if (!_isAdministrator)
        {
            logger.LogError("TelemetryGuardService requires administrator privileges to function properly");
        }

        await base.StartAsync(cancellationToken);
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        logger.LogInformation("TelemetryGuardService started at: {Time}", DateTimeOffset.Now);

        while (!stoppingToken.IsCancellationRequested)
        {
            if (_isAdministrator)
            {
                await ManageTelemetryServices(stoppingToken);
            }
            else
            {
                logger.LogWarning("Skipping service management due to insufficient privileges");
            }

            try
            {
                await Task.Delay(_options.CheckInterval, stoppingToken);
            }
            catch (OperationCanceledException)
            {
                break;
            }
        }

        logger.LogInformation("TelemetryGuardService stopping at: {Time}", DateTimeOffset.Now);
    }

    private async Task ManageTelemetryServices(CancellationToken stoppingToken)
    {
        foreach (var svcName in _options.TelemetryServices)
        {
            if (stoppingToken.IsCancellationRequested)
                break;

            try
            {
                using var svc = new ServiceController(svcName);
                
                var status = svc.Status;
                logger.LogWarning("Service '{Svc}' detected with status {Status}", svcName, status);

                if (status != ServiceControllerStatus.Stopped)
                {
                    await StopServiceAsync(svc, svcName, stoppingToken);
                }

                await DisableServiceStartupAsync(svcName);
            }
            catch (InvalidOperationException)
            {
                logger.LogDebug("Service '{Svc}' not present", svcName);
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "Error handling service '{Svc}'", svcName);
            }
        }
    }

    private async Task StopServiceAsync(ServiceController svc, string svcName, CancellationToken stoppingToken)
    {
        try
        {
            svc.Stop();
            var waitTask = Task.Run(() =>
            {
                try
                {
                    svc.WaitForStatus(ServiceControllerStatus.Stopped, _options.StopTimeout);
                    return true;
                }
                catch
                {
                    return false;
                }
            }, stoppingToken);

            var timeoutTask = Task.Delay(_options.StopTimeout, stoppingToken);
            if (await Task.WhenAny(waitTask, timeoutTask) == waitTask && waitTask.Result)
            {
                logger.LogInformation("Stopped service '{Svc}'", svcName);
            }
            else
            {
                logger.LogWarning("Timeout while stopping service '{Svc}'", svcName);
            }
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Failed to stop service '{Svc}'", svcName);
        }
    }

    private async Task DisableServiceStartupAsync(string svcName)
    {
        try
        {
            using var key = Microsoft.Win32.Registry.LocalMachine.OpenSubKey(
                $@"SYSTEM\CurrentControlSet\Services\{svcName}", true);

            if (key == null) return;

            key.SetValue("Start", 4, Microsoft.Win32.RegistryValueKind.DWord);
            logger.LogInformation("Disabled startup for '{Svc}'", svcName);
        }
        catch (UnauthorizedAccessException ex)
        {
            logger.LogError(ex, "Access denied when disabling startup for '{Svc}'", svcName);
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Error disabling startup for '{Svc}'", svcName);
        }

        await Task.CompletedTask;
    }

    private static bool CheckAdminPrivileges()
    {
        using var identity = WindowsIdentity.GetCurrent();
        var principal = new WindowsPrincipal(identity);
        return principal.IsInRole(WindowsBuiltInRole.Administrator);
    }
}