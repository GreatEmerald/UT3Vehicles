/******************************************************************************
UT3HellfireSPMAShellTrail

Creation date: 2009-02-18 15:36
Latest change: $Id$
Copyright (c) 2009, Wormbo
******************************************************************************/

class UT3HellfireSPMAShellTrail extends ProjectileTrailEmitter;


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
	Begin Object Class=SpriteEmitter Name=SmokeTrail
		RespawnDeadParticles=False
		SpinParticles=True
		AutomaticInitialSpawning=False
		UseRandomSubdivision=True
		UseColorScale=True
		ColorScale(0)=(Color=(G=160,R=255))
		ColorScale(1)=(RelativeTime=0.01,Color=(B=128,G=255,R=255,A=255))
		ColorScale(2)=(RelativeTime=0.2,Color=(B=255,G=255,R=255,A=255))
		ColorScale(3)=(RelativeTime=1.0,Color=(B=255,G=255,R=255))
		MaxParticles=500
		SpinsPerSecondRange=(X=(Min=-0.1,Max=0.1))
		StartSpinRange=(X=(Min=-50.0,Max=50.0))
		StartSizeRange=(X=(Min=30.0,Max=40.0))
		ParticlesPerSecond=0.0
		InitialParticlesPerSecond=0.0
		DrawStyle=PTDS_AlphaBlend
        Texture=Texture'UT3SPMATex.Smoke.SPMASmoke'
		SecondsBeforeInactive=0.0
		LifetimeRange=(Min=2.0,Max=2.5)
		InitialDelayRange=(Min=0.1,Max=0.1)
		StartVelocityRange=(X=(Min=-5.0,Max=5.0),Y=(Min=-5.0,Max=5.0),Z=(Min=-5.0,Max=5.0))
		Acceleration=(Z=20.0)
		Opacity=0.75
	End Object
	Emitters(0)=SpriteEmitter'SmokeTrail'
	
	VelocitySpawnInfo(0) = (EmitterIndex=0,ParticlesPerUU=0.04)
}
