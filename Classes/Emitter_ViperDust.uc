class Emitter_ViperDust extends ONSHoverBikeHoverDust;

simulated function UpdateHoverDust(bool bActive, float HoverHeight)
{
	local float Force;

	Force = 1 - HoverHeight;

	if(!bActive)
	{
		Emitters[0].ParticlesPerSecond = 0;
		Emitters[0].InitialParticlesPerSecond = 0;
		Emitters[1].Disabled = true;
		return;
	}
	else
	{
		Emitters[0].ParticlesPerSecond = 5; // 100
		Emitters[0].InitialParticlesPerSecond = 5; // 100
		Emitters[0].AllParticlesDead = false;
		//Emitters[1].Disabled = (Level.DetailMode == DM_Low);
		Emitters[1].Disabled = true;
	}

	// Dust
	Emitters[0].StartVelocityRadialRange.Min = -325 + (Force * -100); // -650 + (Force * -100)
	Emitters[0].StartVelocityRadialRange.Max = Emitters[0].StartVelocityRadialRange.Min - 100;

	Emitters[0].StartLocationPolarRange.Z.Min = 10 + (HoverHeight * 30);
	Emitters[0].StartLocationPolarRange.Z.Max = Emitters[0].StartLocationPolarRange.Z.Min;
}

simulated function SetDustColor(color DustColor)
{
	Super.SetDustColor(DustColor);
	
	// Reduce opacity.
	Emitters[0].ColorScale[1].Color.A = 200;
	Emitters[0].ColorScale[2].Color.A = 200;
}