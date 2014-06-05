/*
 * Copyright © 2007, 2009 Wormbo
 * Copyright © 2009, 2014 GreatEmerald
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

class UT3LeviathanTurretWeaponRocket extends UT3LeviathanTurretWeapon;


//=============================================================================
// Imports
//=============================================================================

#exec obj load file=WeaponSounds.uax


//=============================================================================
// Properties
//=============================================================================

var int RocketBurstSize;
var float RocketBurstInterval;


//=============================================================================
// Variables
//=============================================================================

var int RemainingRockets;
var Controller FireController;


state ProjectileFireMode
{
    function Fire(Controller C)
    {
        RemainingRockets = RocketBurstSize;
        ActuallyFire();
    }

    function Timer()
    {
        // begin copy/paste from AttemptFire()
        CalcWeaponFire();
        if (bCorrectAim)
            WeaponFireRotation = AdjustAim(false);
        if (Spread > 0)
            WeaponFireRotation = rotator(vector(WeaponFireRotation) + VRand() * FRand() * Spread);

        DualFireOffset *= -1;
        Instigator.MakeNoise(1.0);
        // end copy/paste from AttemptFire()

        ActuallyFire();
    }

    function ActuallyFire()
    {
        if (Instigator != None && Instigator.Controller != None) {
            RemainingRockets--;
        }
        else {
            RemainingRockets = 0;
            return;
        }
        SpawnProjectile(ProjectileClass, false);

        if (RemainingRockets > 0)
            SetTimer(RocketBurstInterval, false);
    }
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
    ProjectileClass     = Class'UT3LeviathanRocket'
    FireSoundClass      = Sound'UT3Weapons2.RocketLauncher.RocketLauncherFire'
    RocketBurstSize     = 4
    RocketBurstInterval = 0.15
    FireInterval        = 2.0

    Mesh = SkeletalMesh'UT3VH_Leviathan_Anims.Leviathan_RightFrontTurret'
    RedSkin = Shader'UT3LeviathanTex.LeviTurret.TurretSkin'
    BlueSkin = Shader'UT3LeviathanTex.LeviTurret.TurretSkinBlue'
    SkinSlot = 5
    PitchBone = "RT_Front_TurretPitch"
    YawBone = "RT_Front_TurretYaw"
    WeaponFireAttachmentBone = "Rt_Front_Turret_BarrelLt"
    GunnerAttachmentBone = "RT_Front_TurretPitch"
    ShieldAttachmentBone = "Rt_Front_Turret_BarrelLt"
    DualFireOffset = 0.0
}
