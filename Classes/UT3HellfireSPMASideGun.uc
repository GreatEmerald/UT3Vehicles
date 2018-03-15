/*
 * Copyright © 2009 Wormbo
 * Copyright © 2014 GreatEmerald
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 *     (1) Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *
 *     (2) Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimers in
 *     the documentation and/or other materials provided with the
 *     distribution.
 *
 *     (3) The name of the author may not be used to
 *     endorse or promote products derived from this software without
 *     specific prior written permission.
 *
 *     (4) The use, modification and redistribution of this software must
 *     be made in compliance with the additional terms and restrictions
 *     provided by the Unreal Tournament 2004 End User License Agreement.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
 * IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *
 * This software is not supported by Atari, S.A., Epic Games, Inc. or any
 * of such parties' affiliates and subsidiaries.
 */

class UT3HellfireSPMASideGun extends ONSArtillerySideGun;


//=============================================================================
// Default values
//=============================================================================

/* 100GPing100 BEGIN */
/*function CalcWeaponFire()
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
}*/
/* 100GPing100 END */

defaultproperties
{

    Drawscale = 1.0

    Mesh = SkeletalMesh'UT3VH_SPMA_Anims.SPMA_SecondaryTurret'
    RedSkin = Shader'UT3SPMATex.Body.RedSkin'
    BlueSkin = Shader'UT3SPMATex.Body.BlueSkin'
    YawBone = "SecondaryTurret_YawLift"
    PitchBone = "SecondaryTurret_Pitch"
    WeaponFireAttachmentBone = "SecondaryTurret_Tip"
    GunnerAttachmentBone = "SecondaryTurret_YawLift"
    DamageType=class'UT3DmgType_HellbenderLaser'

    FireSoundClass    = Sound'UT3A_Vehicle_Hellbender.UT3HellbenderBallFire.UT3HellbenderBallFireCue'
    AltFireSoundClass = Sound'UT3A_Vehicle_Hellbender.UT3HellbenderBeamFire.UT3HellbenderBeamFireCue'
    ProjectileClass   = class'UT3HBShockBall'
    bInstantRotation=false
    //RotateSound=sound'UT3SPMA.A_Vehicle_SPMA_TurretRotate01'
}
