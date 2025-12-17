using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Distributed;
using PracDocker.Data;
using PracDocker.Extensions;
using PracDocker.Models;
using PracDocker.Services;
using PracDocker.Services.Interfaces;

var builder = WebApplication.CreateBuilder(args);

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection") 
                       ?? "Host=localhost;Port=5433;Database=test_db;Username=test_user;Password=test_password";

// DbContext
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(connectionString));

// Сервисы
builder.Services.AddScoped<IProductService, ProductService>();
builder.Services.AddScoped<ICacheService<Product>, ProductCacheService>();


// Controllers + Swagger
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Redis cache
builder.Services.AddDistributedCache(builder.Configuration);

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();

app.MapControllers();

app.Run();