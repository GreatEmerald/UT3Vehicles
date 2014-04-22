/******************************************************************************
UT3HellfireSPMATrajectory

SPMA trajectory arc.
Thanks to Switch (Gunreal - http://www.gunreal.com) who provided example code
for manipulating beam emitters to achive this effect.

Creation date: 2009-02-25 20:59
Last change: $Id$
Copyright (c) 2009, Wormbo
******************************************************************************/

class UT3HellfireSPMATrajectory extends Emitter;


//=============================================================================
// Imports
//=============================================================================

#exec obj load file=EpicParticles.utx


/**
Spawn the initial trajectory beam particle.
*/
function PostBeginPlay()
{
	Emitters[0].SpawnParticle(1);
	Emitters[1].SpawnParticle(1);
}


/**
Update the trajectory arc according to the given parameters.
*/
function UpdateTrajectory(bool bVisible, optional vector StartLocation, optional vector StartVelocity, optional float Gravity, optional float MinZ)
{
	local float tMax, tDelta, t;
	local BeamEmitter Arc;
	local int i;
	
	Emitters[0].Disabled = !bVisible;
	
	// check if we need the bounding box hack
	if (bVisible && Normal(StartVelocity).Z > 0) {
		// need to calculate apex point (actually only apex height)
		Emitters[1].Disabled = False;
		Emitters[1].Particles[0].Location = StartLocation;
		Emitters[1].Particles[0].Location.Z -= 0.5 * Square(StartVelocity.Z) / Gravity;
	}
	else {
		// horizontal or downward initial velocity, so no hack required
		Emitters[1].Disabled = True;
	}
	
	if (!bVisible)
		return;
	
	Arc = BeamEmitter(Emitters[0]);
	
	tMax = (StartVelocity.Z + Sqrt(Square(StartVelocity.Z) + 2 * Gravity * (StartLocation.Z - MinZ))) / Gravity;
	tDelta = tMax / (Arc.HighFrequencyPoints - 1);
	
	Arc.HFPoints[0].Location = StartLocation;
	for (i = 1; i < Arc.HighFrequencyPoints; ++i) {
		t += tDelta;
		Arc.HFPoints[i].Location = StartLocation + StartVelocity * t - vect(0,0,0.5) * Gravity * Square(t);
	}
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
	// the trajectory arc
	Begin Object Class=BeamEmitter Name=Trajectory
		MaxParticles              = 1
		AutomaticInitialSpawning  = False
		LifetimeRange             = (Min=999999.0,Max=999999.0)
		StartSizeRange            = (X=(Min=5.0,Max=5.0))
		HighFrequencyPoints       = 50
		CoordinateSystem          = PTCS_Absolute
		DetermineEndPointBy       = PTEP_Offset
		Texture                   = Texture'EpicParticles.Beams.DanGradient'
		AlphaTest                 = False // DanGradient has an alpha value of 0 and would otherwise be invisible
		ColorMultiplierRange      = (X=(Min=0.75,Max=0.75),Z=(Min=0.5,Max=0.5))
		Opacity                   = 0.75
	End Object
	Emitters(0) = Trajectory
	
	// invisible particle placed at the trajectory apex to extend the rendering bounding box
	Begin Object Class=SpriteEmitter Name=BoundingBoxHack
		MaxParticles              = 1
		AutomaticInitialSpawning  = False
		LifetimeRange             = (Min=999999.0,Max=999999.0)
		StartSizeRange            = (X=(Min=0.0,Max=0.0)) // so it's not actually visible
		CoordinateSystem          = PTCS_Absolute
	End Object
	Emitters(1) = BoundingBoxHack
	
	bNoDelete = False
}
