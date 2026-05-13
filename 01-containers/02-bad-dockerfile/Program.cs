var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.MapGet("/", () => "Hello from the bad Dockerfile example!");
app.MapGet("/health", () => Results.Ok("healthy"));

app.Run();
