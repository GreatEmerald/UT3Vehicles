/******************************************************************************
UT3HellfireSPMAAirExplosion

Creation date: 2009-02-24 19:22
Last change: $Id$
Copyright (c) 2009, 2013 Wormbo, GreatEmerald
******************************************************************************/

class UT3HellfireSPMAAirExplosion extends Emitter;


//=============================================================================
// Imports
//=============================================================================

#exec obj load file=UT3SPMAEffects.usx
#exec obj load file=VMParticleTextures.utx


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
	Begin Object Class=MeshEmitter Name=FlashMesh
		StaticMesh=StaticMesh'SPMAAirExplosionMesh'
		RespawnDeadParticles=False
		SpinParticles=True
		UseSizeScale=True
		UseRegularSizeScale=False
		AutomaticInitialSpawning=False
		CoordinateSystem=PTCS_Relative
		MaxParticles=1
		UseRotationFrom=PTRS_Actor
		StartSpinRange=(Z=(Max=1.0))
		SizeScale(1)=(RelativeTime=0.15,RelativeSize=2.0)
		SizeScale(2)=(RelativeTime=1.0)
		StartSizeRange=(X=(Min=0.18,Max=1.8),Y=(Min=2.4,Max=2.4),Z=(Min=2.4,Max=2.4))
		InitialParticlesPerSecond=1000.0
		SecondsBeforeInactive=0.0
		LifetimeRange=(Min=0.225,Max=0.225)
	End Object
	Emitters()=MeshEmitter'FlashMesh'

	Begin Object Class=SpriteEmitter Name=ExplosionSprite
		FadeOut=True
		RespawnDeadParticles=False
		SpinParticles=True
		UseSizeScale=True
		UseRegularSizeScale=False
		UniformSize=True
		AutomaticInitialSpawning=False
		BlendBetweenSubdivisions=True
		AddVelocityFromOwner=True
		MaxParticles=3
		StartLocationRange=(X=(Min=-10.0,Max=3.0),Y=(Min=-2.0,Max=2.0),Z=(Min=-2.0,Max=2.0))
		UseRotationFrom=PTRS_Actor
		SpinsPerSecondRange=(X=(Min=-0.05,Max=0.05))
		StartSpinRange=(X=(Max=1.0))
		SizeScale(1)=(RelativeTime=0.225,RelativeSize=4.0)
		SizeScale(2)=(RelativeTime=1.0,RelativeSize=3.0)
		StartSizeRange=(X=(Min=40.0,Max=50.0))
		InitialParticlesPerSecond=50.0
		DrawStyle=PTDS_Brighten
		Texture=Texture'VMParticleTextures.VehicleExplosions.VMExp2_framesANIM'
		TextureUSubdivisions=4
		TextureVSubdivisions=4
		SecondsBeforeInactive=0.0
		LifetimeRange=(Min=0.525,Max=0.8)
		AddVelocityMultiplierRange=(X=(Min=0.03,Max=0.03),Y=(Min=0.03,Max=0.03),Z=(Min=0.03,Max=0.03))
	End Object
	Emitters(1)=SpriteEmitter'ExplosionSprite'

	Begin Object Class=SpriteEmitter Name=GlowSprite
		FadeOut=True
		RespawnDeadParticles=False
		SpinParticles=True
		UseSizeScale=True
		UseRegularSizeScale=False
		UniformSize=True
		AutomaticInitialSpawning=False
		MaxParticles=1
		StartSpinRange=(X=(Max=1.0))
		SizeScale()=(RelativeSize=1.0)
		SizeScale(1)=(RelativeTime=0.3,RelativeSize=2.5)
		SizeScale(2)=(RelativeTime=1.0,RelativeSize=0.8)
		StartSizeRange=(X=(Min=100.0,Max=100.0))
		InitialParticlesPerSecond=1000.0
		DrawStyle=PTDS_Brighten
		Texture=Texture'XEffects.GoldGlow'
		SecondsBeforeInactive=0.0
		LifetimeRange=(Min=0.6,Max=0.6)
	End Object
	Emitters(2)=SpriteEmitter'GlowSprite'

	Begin Object Class=SpriteEmitter Name=Sparks
		UseDirectionAs=PTDU_Up
		UseColorScale=True
		RespawnDeadParticles=False
		UseSizeScale=True
		UseRegularSizeScale=False
		AutomaticInitialSpawning=False
		Acceleration=(Z=-1000.0)
		ColorScale()=(RelativeTime=0.44,Color=(B=192,G=192,R=255,A=255))
		ColorScale(1)=(RelativeTime=1.0)
		FadeOutStartTime=0.44
		MaxParticles=15
		SizeScale()=(RelativeSize=8.0)
		SizeScale(1)=(RelativeTime=0.25,RelativeSize=2.25)
		SizeScale(2)=(RelativeTime=1.0,RelativeSize=0.2)
		StartSizeRange=(X=(Min=0.5,Max=10.0),Y=(Min=3.0,Max=10.0),Z=(Min=0.5,Max=10.0))
		InitialParticlesPerSecond=1000.0
		DrawStyle=PTDS_Brighten
		Texture=Texture'SPMASpark'
		SecondsBeforeInactive=0.0
		LifetimeRange=(Min=0.4,Max=1.0)
		StartVelocityRange=(X=(Min=200.0,Max=700.0),Y=(Min=-200.0,Max=200.0),Z=(Min=-200.0,Max=200.0))
	End Object
	Emitters(3)=SpriteEmitter'Sparks'

	AmbientGlow=64
	bNoDelete=False
	AutoDestroy=True
}
