/******************************************************************************
UT3HellfireSPMASideGun

Creation date: 2009-02-09 16:10
Latest change: $Id$
Copyright (c) 2009, Wormbo
******************************************************************************/

class UT3HellfireSPMASideGun extends ONSArtillerySideGun;


//=============================================================================
// Default values
//=============================================================================

/* 100GPing100 BEGIN */
function CalcWeaponFire()
{
	local UT3HellfireSPMA HellFire;
	local coords WeaponBoneCoords;
    local vector CurrentFireOffset;

	HellFire = UT3HellfireSPMA(Owner);
	if (HellFire != none) {
	    // Calculate fire offset in world space
	    WeaponBoneCoords = HellFire.GetBoneCoords(WeaponFireAttachmentBone);
	    CurrentFireOffset = (WeaponFireOffset * vect(1,0,0)) + (DualFireOffset * vect(0,1,0));
	
	    // Calculate rotation of the gun
	    WeaponFireRotation = rotator(vector(CurrentAim) >> Rotation);
	
	    // Calculate exact fire location
	    WeaponFireLocation = WeaponBoneCoords.Origin + (CurrentFireOffset >> WeaponFireRotation);
	
	    // Adjust fire rotation taking dual offset into account
	    if (bDualIndependantTargeting)
	        WeaponFireRotation = rotator(CurrentHitLocation - WeaponFireLocation);
	} else {
		Level.GetLocalPlayerController().ClientMessage("UT3HellfireSPMASideGun::CalcWeaponFire(), HellFire == none");
		super.CalcWeaponFire();
	}
}

simulated function InitEffects()
{
	local UT3HellfireSPMA HellFire;
	
	HellFire = UT3HellfireSPMA(Owner);
	if (HellFire != none) {
	    // don't even spawn on server
	    if (Level.NetMode == NM_DedicatedServer)
			return;
	
	    if ( (FlashEmitterClass != None) && (FlashEmitter == None) )
	    {
	        FlashEmitter = Spawn(FlashEmitterClass);
	        FlashEmitter.SetDrawScale(DrawScale);
	        if (WeaponFireAttachmentBone == '')
	            FlashEmitter.SetBase(self);
	        else
	            HellFire.AttachToBone(FlashEmitter, WeaponFireAttachmentBone);
	
	        FlashEmitter.SetRelativeLocation(WeaponFireOffset * vect(1,0,0));
	    }
	
	    if (AmbientEffectEmitterClass != none && AmbientEffectEmitter == None)
	    {
	        AmbientEffectEmitter = spawn(AmbientEffectEmitterClass, self,, WeaponFireLocation, WeaponFireRotation);
	        if (WeaponFireAttachmentBone == '')
	            AmbientEffectEmitter.SetBase(self);
	        else
	            HellFire.AttachToBone(AmbientEffectEmitter, WeaponFireAttachmentBone);
	
	        AmbientEffectEmitter.SetRelativeLocation(WeaponFireOffset * vect(1,0,0));
	    }
	} else {
		Level.GetLocalPlayerController().ClientMessage("UT3HellfireSPMASideGun::InitEffects(), HellFire == none");
		super.InitEffects();
	}
}

event Tick(float DeltaTime)
{
	local UT3HellfireSPMA HellFire;
	local Rotator rot;
	
	super.Tick(DeltaTime);
	
	HellFire = UT3HellfireSPMA(Owner);
	if (HellFire != none) {
		//CalcBoneRotation();
		rot.Yaw = -CurrentAim.Yaw;
		HellFire.SetBoneRotation('SecondaryTurret_YawLift', rot);
		
		rot.Yaw = 0;
		SetRotation(rot);
	}
}
/* 100GPing100 END */

defaultproperties
{
	/* 100GPing100 BEGIN */
	//Mesh = SkeletalMesh'UT3SPMAAnims.SPMA';
	
	YawBone = 'SecondaryTurret_YawLift';
	//PitchBone = 'SecondaryTurret_Pitch';
	WeaponFireAttachmentBone = 'SecondaryTurret_Barrel';
	//GunnerAttachmentBone = 'SecondaryTurret_YawLift';
	/* 100GPing100 END */
	
	FireSoundClass    = Sound'HellbenderFire'
	AltFireSoundClass = Sound'HellbenderAltFire'
	ProjectileClass   = class'UT3HellfireSPMAShockBall'
}
