using System.Net.Sockets;
using System.Text;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Npgsql;
using RabbitMQ.Client;
using StackExchange.Redis;

var builder = WebApplication.CreateBuilder(args);

string connectionString =
    builder.Configuration.GetConnectionString("Default")
    ?? Environment.GetEnvironmentVariable("ConnectionStrings__Default")
    ?? "Host=postgres;Database=lifedb;Username=life;Password=life2026";

string? redisUrl =
    Environment.GetEnvironmentVariable("REDIS_URL")
    ?? builder.Configuration["Redis:Url"];

string? rabbitUrl =
    Environment.GetEnvironmentVariable("RABBITMQ_URL")
    ?? builder.Configuration["Rabbit:Url"];

builder.Services.AddDbContext<ShortenerDb>(o =>
    o.UseNpgsql(connectionString));

builder.Services.AddCors(o =>
    o.AddDefaultPolicy(p =>
        p.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader()));

builder.Services.AddSingleton<IConnectionMultiplexer?>(_ =>
{
    if (string.IsNullOrWhiteSpace(redisUrl))
    {
        Console.WriteLine("[STARTUP] REDIS_URL not set — cache disabled");
        return null;
    }
    try
    {
        var endpoint = redisUrl.Replace("redis://", "").TrimEnd('/');
        var mux = ConnectionMultiplexer.Connect(endpoint);
        Console.WriteLine($"[STARTUP] Connected to Redis at {endpoint}");
        return mux;
    }
    catch (Exception ex)
    {
        Console.WriteLine($"[STARTUP] Redis connection failed: {ex.Message}");
        return null;
    }
});

builder.Services.AddSingleton(new RabbitPublisher(rabbitUrl));

var app = builder.Build();
app.UseCors();

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<ShortenerDb>();
    try
    {
        db.Database.ExecuteSqlRaw(@"
            CREATE TABLE IF NOT EXISTS shortened_urls (
                id           SERIAL PRIMARY KEY,
                code         VARCHAR(8) UNIQUE NOT NULL,
                original_url TEXT NOT NULL,
                created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                click_count  INT NOT NULL DEFAULT 0
            );
        ");
        Console.WriteLine("[STARTUP] Connected to PostgreSQL successfully");
    }
    catch (Exception ex)
    {
        Console.WriteLine($"[STARTUP] Failed to connect to database: {ex.Message}");
        Console.WriteLine("[STARTUP] Starting anyway — health check will report unhealthy.");
    }
}

app.MapGet("/", () =>
    "LIFE Shortener API — POST /api/shorten, GET /api/urls, GET /api/urls/{code}");

app.MapGet("/health", async () =>
{
    try
    {
        var parsed = new NpgsqlConnectionStringBuilder(connectionString);
        var host = parsed.Host ?? "localhost";
        var port = parsed.Port > 0 ? parsed.Port : 5432;

        using var tcp = new TcpClient();
        using var cts = new CancellationTokenSource(TimeSpan.FromSeconds(2));
        await tcp.ConnectAsync(host, port, cts.Token);
        return Results.Ok(new { status = "healthy", db = $"{host}:{port}" });
    }
    catch (Exception ex)
    {
        Console.WriteLine($"[HEALTH] Cannot reach database: {ex.Message}");
        return Results.StatusCode(503);
    }
});

app.MapGet("/api/urls", async (ShortenerDb db) =>
{
    var rows = await db.Urls
        .OrderByDescending(u => u.Id)
        .Take(50)
        .ToListAsync();
    return Results.Ok(rows);
});

app.MapGet("/api/urls/{code}", async (string code, ShortenerDb db,
                                       IConnectionMultiplexer? redis) =>
{
    if (redis is not null && redis.IsConnected)
    {
        try
        {
            var cached = await redis.GetDatabase().StringGetAsync($"shortener:url:{code}");
            if (cached.HasValue)
                return Results.Ok(JsonSerializer.Deserialize<ShortenedUrl>(cached!));
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[API] Redis lookup failed: {ex.Message}");
        }
    }

    var row = await db.Urls.FirstOrDefaultAsync(u => u.Code == code);
    if (row is null) return Results.NotFound();

    if (redis is not null && redis.IsConnected)
    {
        try
        {
            await redis.GetDatabase().StringSetAsync(
                $"shortener:url:{code}",
                JsonSerializer.Serialize(row),
                TimeSpan.FromMinutes(10));
        }
        catch { /* cache is best-effort */ }
    }

    return Results.Ok(row);
});

app.MapPost("/api/shorten", async (ShortenerDb db,
                                    IConnectionMultiplexer? redis,
                                    RabbitPublisher rabbit,
                                    ShortenRequest request) =>
{
    if (string.IsNullOrWhiteSpace(request.Url))
        return Results.BadRequest(new { error = "url is required" });

    if (!Uri.TryCreate(request.Url, UriKind.Absolute, out _))
        return Results.BadRequest(new { error = "url must be absolute" });

    string code = "";
    int attempts = 0;
    while (true)
    {
        code = GenerateCode();
        var exists = await db.Urls.AnyAsync(u => u.Code == code);
        if (!exists) break;
        if (++attempts > 5)
            return Results.Problem("Could not generate unique code");
    }

    var row = new ShortenedUrl
    {
        Code = code,
        OriginalUrl = request.Url.Trim(),
        CreatedAt = DateTime.UtcNow,
        ClickCount = 0,
    };
    db.Urls.Add(row);
    await db.SaveChangesAsync();

    var total = await db.Urls.CountAsync();
    Console.WriteLine($"[API] Shortened {row.OriginalUrl} -> {code} (total: {total})");

    rabbit.PublishShortened(row);

    return Results.Created($"/api/urls/{code}", new
    {
        code = row.Code,
        short_url = $"http://localhost/s/{row.Code}",
        original_url = row.OriginalUrl,
        created_at = row.CreatedAt,
    });
});

Console.WriteLine("[STARTUP] LIFE Shortener API running on port 8080");
app.Run();


static string GenerateCode()
{
    const string charset = "abcdefghijkmnpqrstuvwxyz23456789";
    var sb = new StringBuilder(6);
    var rng = Random.Shared;
    for (int i = 0; i < 6; i++)
        sb.Append(charset[rng.Next(charset.Length)]);
    return sb.ToString();
}


public class ShortenedUrl
{
    public int Id { get; set; }
    public string Code { get; set; } = "";
    public string OriginalUrl { get; set; } = "";
    public DateTime CreatedAt { get; set; }
    public int ClickCount { get; set; }
}

public record ShortenRequest(string Url);

public class ShortenerDb : DbContext
{
    public ShortenerDb(DbContextOptions<ShortenerDb> options) : base(options) { }
    public DbSet<ShortenedUrl> Urls => Set<ShortenedUrl>();

    protected override void OnModelCreating(ModelBuilder b)
    {
        var t = b.Entity<ShortenedUrl>().ToTable("shortened_urls");
        t.Property(u => u.Id).HasColumnName("id");
        t.Property(u => u.Code).HasColumnName("code").HasMaxLength(8);
        t.Property(u => u.OriginalUrl).HasColumnName("original_url");
        t.Property(u => u.CreatedAt).HasColumnName("created_at");
        t.Property(u => u.ClickCount).HasColumnName("click_count").HasDefaultValue(0);
        t.HasIndex(u => u.Code).IsUnique();
    }
}

public sealed class RabbitPublisher
{
    private readonly string? _url;
    private IConnection? _connection;
    private readonly object _lock = new();

    public RabbitPublisher(string? url) { _url = url; }

    public void PublishShortened(ShortenedUrl row)
    {
        if (string.IsNullOrWhiteSpace(_url)) return;
        try
        {
            lock (_lock) { EnsureConnected(); }
            using var channel = _connection!.CreateModel();
            channel.QueueDeclare(
                queue: "life.url.shortened",
                durable: false,
                exclusive: false,
                autoDelete: false);
            var body = Encoding.UTF8.GetBytes(JsonSerializer.Serialize(new
            {
                code = row.Code,
                original_url = row.OriginalUrl,
                created_at = row.CreatedAt,
            }));
            channel.BasicPublish(
                exchange: "",
                routingKey: "life.url.shortened",
                basicProperties: null,
                body: body);
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[RABBIT] Publish failed: {ex.Message}");
        }
    }

    private void EnsureConnected()
    {
        if (_connection?.IsOpen == true) return;
        var factory = new ConnectionFactory { Uri = new Uri(_url!) };
        _connection = factory.CreateConnection();
        Console.WriteLine("[STARTUP] Connected to RabbitMQ");
    }
}
