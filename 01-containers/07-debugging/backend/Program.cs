using System.Net.Sockets;
using Microsoft.EntityFrameworkCore;
using Npgsql;

var builder = WebApplication.CreateBuilder(args);

var connectionString = builder.Configuration.GetConnectionString("Default")
    ?? Environment.GetEnvironmentVariable("ConnectionStrings__Default")
    ?? "Host=postgres;Database=lifedb;Username=life;Password=life2026";

builder.Services.AddDbContext<StudentDb>(options =>
    options.UseNpgsql(connectionString));

builder.Services.AddCors(options =>
    options.AddDefaultPolicy(policy =>
        policy.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader()));

var app = builder.Build();
app.UseCors();

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<StudentDb>();
    try
    {
        db.Database.EnsureCreated();
        Console.WriteLine($"[STARTUP] Connected to PostgreSQL successfully");
    }
    catch (Exception ex)
    {
        Console.WriteLine($"[STARTUP] Failed to connect to database: {ex.Message}");
        Console.WriteLine($"[STARTUP] Starting anyway — health check will report unhealthy.");
    }
}

app.MapGet("/", () => "LIFE-3 Student Registry API — POST /api/students, GET /api/students");

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

        Console.WriteLine($"[HEALTH] Connected to {host}:{port} — healthy");
        return Results.Ok("healthy");
    }
    catch (Exception ex)
    {
        Console.WriteLine($"[HEALTH] Cannot reach database: {ex.Message}");
        return Results.StatusCode(503);
    }
});

app.MapGet("/api/students", async (StudentDb db) =>
{
    var students = await db.Students.OrderBy(s => s.Id).ToListAsync();
    Console.WriteLine($"[API] Listed {students.Count} students");
    return Results.Ok(students);
});

app.MapPost("/api/students", async (StudentDb db, CreateStudentRequest request) =>
{
    if (string.IsNullOrWhiteSpace(request.Name))
        return Results.BadRequest(new { error = "Name is required" });

    var student = new Student { Name = request.Name.Trim(), RegisteredAt = DateTime.UtcNow };
    db.Students.Add(student);
    await db.SaveChangesAsync();

    var total = await db.Students.CountAsync();
    Console.WriteLine($"[API] Saved student: {student.Name} (total: {total})");

    return Results.Created($"/api/students/{student.Id}", student);
});

Console.WriteLine("[STARTUP] LIFE-3 Student Registry API running on port 8080");
app.Run();

public class Student
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public DateTime RegisteredAt { get; set; }
}

public record CreateStudentRequest(string Name);

public class StudentDb : DbContext
{
    public StudentDb(DbContextOptions<StudentDb> options) : base(options) { }
    public DbSet<Student> Students => Set<Student>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Student>().ToTable("life3_students");
    }
}
