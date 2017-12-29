/*
 * Copyright © 2007 Wormbo
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

class UT3LeviathanDriverWeapon extends ONSMASRocketPack;

// GEm: This uses skin 1, not 0
simulated function SetTeam(byte T)
{
    Team = T;
    if (T == 0 && RedSkin != None)
    {
        Skins[1] = RedSkin;
        RepSkin = RedSkin;
    }
    else if (T == 1 && BlueSkin != None)
    {
        Skins[1] = BlueSkin;
        RepSkin = BlueSkin;
    }
}

// GEm: Add a weapon offset
simulated function InitEffects()
{
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
            AttachToBone(FlashEmitter, WeaponFireAttachmentBone);

        FlashEmitter.SetRelativeLocation(WeaponFireOffset * vect(1,0,0) + WeaponOffset);
    }

    if (AmbientEffectEmitterClass != none && AmbientEffectEmitter == None)
    {
        AmbientEffectEmitter = spawn(AmbientEffectEmitterClass, self,, WeaponFireLocation, WeaponFireRotation);
        if (WeaponFireAttachmentBone == '')
            AmbientEffectEmitter.SetBase(self);
        else
            AttachToBone(AmbientEffectEmitter, WeaponFireAttachmentBone);

        AmbientEffectEmitter.SetRelativeLocation(WeaponFireOffset * vect(1,0,0) + WeaponOffset);
    }
}

simulated function CalcWeaponFire()
{
    local coords WeaponBoneCoords;
    local vector CurrentFireOffset;

    // Calculate fire offset in world space
    WeaponBoneCoords = GetBoneCoords(WeaponFireAttachmentBone);
    CurrentFireOffset = (WeaponFireOffset * vect(1,0,0)) + (DualFireOffset * vect(0,1,0)) + WeaponOffset;

    // Calculate rotation of the gun
    WeaponFireRotation = rotator(vector(CurrentAim) >> Rotation);

    // Calculate exact fire location
    WeaponFireLocation = WeaponBoneCoords.Origin + (CurrentFireOffset >> WeaponFireRotation);

    // Adjust fire rotation taking dual offset into account
    if (bDualIndependantTargeting)
        WeaponFireRotation = rotator(CurrentHitLocation - WeaponFireLocation);
}

//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
    ProjectileClass  = Class'UT3LeviathanBolt'
    FireInterval     = 0.3
    DrawScale        = 0.6
    //RelativeLocation = (Z=-10)

    Mesh = SkeletalMesh'UT3VH_Leviathan_Anims.LeviathanDriverTurretOnly'
    RedSkin = Shader'UT3LeviathanTex.Levi2.LeviathanSkin2'
    BlueSkin = Shader'UT3LeviathanTex.Levi2.LeviathanSkin2Blue'
    YawBone = "DriverTurretYaw"
    PitchBone = "DriverTurretPitch"
    WeaponFireAttachmentBone = "DriverTurret_Tip"
    DualFireOffset = 13.0 //6.0
    WeaponOffset = (X=0.0,Y=-11.0,Z=0.0) //(X=0.0,Y=-6.0,Z=0.0)
    RotationsPerSecond=0.40 //0.18

    FireSoundClass = Sound'UT3A_Vehicle_Leviathan.SoundCues.A_Vehicle_Leviathan_TurretFire'
}
