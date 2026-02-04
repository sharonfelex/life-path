using LifePath.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace LifePath.Api.Data;

public class LifePathDbContext : DbContext
{
    public LifePathDbContext(DbContextOptions<LifePathDbContext> options) : base(options)
    {
    }

    public DbSet<Ambulance> Ambulances => Set<Ambulance>();
    public DbSet<Trip> Trips => Set<Trip>();
    public DbSet<Junction> Junctions => Set<Junction>();
}
