/*
 * Copyright © 2008, 2014 GreatEmerald
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

class UT3MantaPlasmaGun extends ONSHoverBikePlasmaGun;

function float SuggestAttackStyle()
{
    local xBot B;

    B = xBot(Instigator.Controller);
    if ( (Pawn(Instigator.Controller.Focus) == None) || (B == None) || (B.Skill < 3) )
    {
        return -0.2;
    }

    return 0.2;
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

defaultproperties
{
    // @100GPing100
    FireSoundClass = Sound'UT3A_Vehicle_Manta.Sounds.A_Vehicle_Manta_Fire01';

    //FireSoundClass=sound'UT3Vehicles.Manta.MantaFire'
    TransientSoundVolume=0.4
    ProjectileClass=class'UT3MantaPlasmaProjectile'

    DualFireOffset = 17.0
    WeaponOffset = (X=0.0,Y=-16.0,Z=0.0)
    
    PitchUpLimit=5500
    PitchDownLimit=59000
}
