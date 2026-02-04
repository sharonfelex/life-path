namespace LifePath.Api.Models;

public class Trip
{
    public Guid Id { get; set; }
    public Guid AmbulanceId { get; set; }
    public Ambulance? Ambulance { get; set; }
    public DateTimeOffset StartedAt { get; set; }
    public DateTimeOffset? CompletedAt { get; set; }
    public decimal? DistanceKm { get; set; }
}
