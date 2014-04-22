/******************************************************************************
UT3HellfireSPMAShell

Creation date: 2009-02-13 13:31
Last change: $Id$
Copyright (c) 2009, Wormbo
******************************************************************************/

class UT3HellfireSPMAShell extends ONSMortarShell;


var Sound AirExplosionSound;
var class<Projectile> ChildProjectileClass;
var float SpreadFactor;
var Emitter SmokeTrail;

// flight correction hack
var float t0, v0, h0, g0;


simulated function PostBeginPlay()
{
	Super(Projectile).PostBeginPlay();
	
	if (Level.NetMode != NM_DedicatedServer)
		SmokeTrail = Spawn(class'UT3HellfireSPMAShellTrail', self);
}


/*simulated function Tick(float DeltaTime)
{
	local float t, h;
	
	Super.Tick(DeltaTime);
	
	// flight correction hack
	if (t0 == 0) {
		t0 = Level.TimeSeconds;
		v0 = Velocity.Z;
		h0 = Location.Z;
		g0 = PhysicsVolume.Gravity.Z;
	}
	if (g0 != PhysicsVolume.Gravity.Z || PhysicsVolume.bWaterVolume) {
		// no longer correct trajectory after gravity/water change
		g0 = 0;
		return;
	}
	t = Level.TimeSeconds - t0;
	
	h = h0 + v0 * t + 0.5 * g0 * Square(t);
	if (h > Location.Z /*|| h < Location.Z - 50*/) {
		log ("Correcting:"@t@h@Location.Z);
		Velocity.Z += (h - Location.Z);
	}
}*/


simulated function Destroyed()
{
	if (SmokeTrail != None)
		SmokeTrail.Kill();
	SmokeTrail = None;
	Super.Destroyed();
}

simulated function Timer()
{
	local int i, j;
	local Projectile Child;
	local float Mag;
	local vector CurrentVelocity;
	
	if (Level.NetMode != NM_DedicatedServer)
		Spawn(class'ONSArtilleryShellSplit', self, , Location, Rotation);
	
	CurrentVelocity = 0.85 * Velocity;
	
	// one shell in each of 9 zones
	for (i = -1; i < 2; i++) {
		for (j= -1; j < 2; j++) {
			if (Abs(i) + Abs(j) > 1)
				Mag = 0.7;
			else
				Mag = 1.0;
			Child = Spawn(ChildProjectileClass, self,, Location);
			if (Child != None) {
				Child.Velocity = CurrentVelocity;
				Child.Velocity.X += RandRange(0.3, 1.0) * Mag * i * SpreadFactor;
				Child.Velocity.Y += RandRange(0.3, 1.0) * Mag * j * SpreadFactor;
				Child.Velocity.Z = Child.Velocity.Z + SpreadFactor * (FRand() - 0.5);
				Child.InstigatorController = InstigatorController;
			}
		}
	}
	ExplodeInAir();
}


simulated function SpawnEffects(vector HitLocation, vector HitNormal)
{
	local PlayerController PC;

	PlaySound(ImpactSound, SLOT_None, 2.0);
	if (EffectIsRelevant(Location, false)) {
		PC = Level.GetLocalPlayerController();
		if (PC.ViewTarget != None && VSize(PC.ViewTarget.Location - Location) < 3000)
			Spawn(ExplosionEffectClass,,, HitLocation + HitNormal * 16);
		Spawn(ExplosionEffectClass,,, HitLocation + HitNormal * 16);
		if (ExplosionDecal != None && Level.NetMode != NM_DedicatedServer)
			Spawn(ExplosionDecal, self,, HitLocation, rotator(-HitNormal));
	}
}


simulated function ExplodeInAir()
{
	bExploded = true;
	PlaySound(AirExplosionSound, SLOT_None, 2.0);
	if (Level.NetMode != NM_DedicatedServer)
		Spawn(AirExplosionEffectClass);
	
	Explode(Location, Location - Instigator.Location);
	Destroy();
}



//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
	AirExplosionSound = Sound'SPMAShellBreakingExplode'
	ImpactSound       = Sound'SPMAShellFragmentExplode'
	AmbientSound      = None
	LifeSpan          = 8.0
	
	TransientSoundRadius = 500.0
	
	ChildProjectileClass = class'UT3HellfireSPMAShellChild'
	SpreadFactor = 400.0
	
	ExplosionEffectClass    = class'UT3HellfireSPMAAirExplosion'
	AirExplosionEffectClass = class'UT3HellfireSPMAAirExplosion'
}
