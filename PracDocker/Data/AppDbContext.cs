using Microsoft.EntityFrameworkCore;
using PracDocker.Models;


namespace PracDocker.Data;

public class AppDbContext : DbContext
{
    public DbSet<User> Users => Set<User>();

    public AppDbContext(DbContextOptions<AppDbContext> options)
        : base(options)
    {
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<User>().ToTable("users");
        base.OnModelCreating(modelBuilder);
    }
}
