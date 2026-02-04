using LifePath.Api.Data;
using LifePath.Api.Hubs;
using LifePath.Api.Services;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddDbContext<LifePathDbContext>(options =>
    options.UseInMemoryDatabase("LifePath"));
builder.Services.AddSignalR();
builder.Services.AddScoped<JunctionProximityService>();

var app = builder.Build();

app.MapGet("/", () => "LifePath Command Center API");
app.MapHub<GpsHub>("/hubs/gps");

app.Run();
