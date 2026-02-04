namespace LifePath.Api.Models;

public class Ambulance
{
    public Guid Id { get; set; }
    public string Identifier { get; set; } = string.Empty;
    public bool IsActive { get; set; }
    public ICollection<Trip> Trips { get; set; } = new List<Trip>();
}
