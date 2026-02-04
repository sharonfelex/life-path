using LifePath.Api.Services;
using Microsoft.AspNetCore.SignalR;

namespace LifePath.Api.Hubs;

public class GpsHub : Hub
{
    private readonly JunctionProximityService _proximityService;

    public GpsHub(JunctionProximityService proximityService)
    {
        _proximityService = proximityService;
    }

    public async Task SendLocationAsync(string ambulanceId, double latitude, double longitude)
    {
        var junction = await _proximityService.GetNearbyJunctionAsync(latitude, longitude, 300);
        if (junction != null)
        {
            _proximityService.SendGreenWaveRequest(junction.Id);
            await Clients.Caller.SendAsync("GreenWave", junction.Id, junction.Name);
        }
    }
}
