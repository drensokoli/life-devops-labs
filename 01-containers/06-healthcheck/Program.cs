var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

var isHealthy = true;
var visitCount = 0;

app.MapGet("/", () => "Health check demo — try /health, /crash, and /api/visit");

app.MapGet("/health", () =>
    isHealthy ? Results.Ok("healthy") : Results.StatusCode(503));

app.MapGet("/crash", () =>
{
    isHealthy = false;
    Console.WriteLine($"[HEALTH] App marked as UNHEALTHY at {DateTime.UtcNow:HH:mm:ss}");
    return Results.Ok("Health set to unhealthy — watch docker ps for status change");
});

app.MapGet("/api/visit", (HttpContext ctx) =>
{
    visitCount++;
    var ip = ctx.Connection.RemoteIpAddress?.ToString() ?? "unknown";
    Console.WriteLine($"[API] Visit #{visitCount} from {ip} at {DateTime.UtcNow:HH:mm:ss}");
    return Results.Ok(new { visit = visitCount, timestamp = DateTime.UtcNow });
});

Console.WriteLine("[STARTUP] Health check demo running on port 8080");
app.Run();
