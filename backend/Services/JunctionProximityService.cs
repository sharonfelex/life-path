using LifePath.Api.Data;
using LifePath.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace LifePath.Api.Services;

public class JunctionProximityService
{
    private readonly LifePathDbContext _dbContext;

    public JunctionProximityService(LifePathDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<Junction?> GetNearbyJunctionAsync(double latitude, double longitude, double radiusMeters)
    {
        var junctions = await _dbContext.Junctions.ToListAsync();
        return junctions.FirstOrDefault(junction =>
            CalculateDistanceMeters(latitude, longitude, junction.Latitude, junction.Longitude) <= radiusMeters);
    }

    public void SendGreenWaveRequest(Guid junctionId)
    {
        // TODO: Integrate with BTP ASTraM API.
    }

    private static double CalculateDistanceMeters(
        double lat1,
        double lon1,
        double lat2,
        double lon2)
    {
        const double earthRadius = 6371000;
        var dLat = DegreesToRadians(lat2 - lat1);
        var dLon = DegreesToRadians(lon2 - lon1);

        var a = Math.Pow(Math.Sin(dLat / 2), 2)
                + Math.Cos(DegreesToRadians(lat1))
                * Math.Cos(DegreesToRadians(lat2))
                * Math.Pow(Math.Sin(dLon / 2), 2);
        var c = 2 * Math.Asin(Math.Sqrt(a));
        return earthRadius * c;
    }

    private static double DegreesToRadians(double degrees) => degrees * Math.PI / 180;
}
