var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.MapGet("/", () => "Hello from the multi-stage Dockerfile example!");
app.MapGet("/health", () => Results.Ok("healthy"));

app.Run();
