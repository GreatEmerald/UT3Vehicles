class Beam extends LinkBeamEffect;

simulated function SetBeamLocation()
{
	// Only set the location, we get BeamStart from the nightshade.
	SetLocation(StartEffect);
}