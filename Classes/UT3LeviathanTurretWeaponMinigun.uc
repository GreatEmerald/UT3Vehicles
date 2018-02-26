/*
 * Copyright © 2007, 2009 Wormbo
 * Copyright © 2009, 2014 GreatEmerald
 * Copyright © 2017, HellDragon
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

class UT3LeviathanTurretWeaponMinigun extends UT3LeviathanTurretWeapon;


var class<Emitter>      mTracerClass;
var() editinline Emitter mTracer;
var() float             mTracerInterval;
var() float             mTracerPullback;
var() float             mTracerMinDistance;
var() float             mTracerSpeed;
var float               mLastTracerTime;

static function StaticPrecache(LevelInfo L)
{
    L.AddPrecacheMaterial(Material'VMparticleTextures.TankFiringP.CloudParticleOrangeBMPtex');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.TracerShot');
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'VMparticleTextures.TankFiringP.CloudParticleOrangeBMPtex');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.TracerShot');

    Super.UpdatePrecacheMaterials();
}

function byte BestMode()
{
    return 0;
}

simulated function Destroyed()
{
    if (mTracer != None)
        mTracer.Destroy();

    Super.Destroyed();
}

simulated function UpdateTracer()
{
    local vector SpawnDir, SpawnVel;
    local float hitDist;

    if (Level.NetMode == NM_DedicatedServer)
        return;

    if (mTracer == None)
    {
        mTracer = Spawn(mTracerClass);
    }

    if (Level.bDropDetail || Level.DetailMode == DM_Low)
        mTracerInterval = 2 * Default.mTracerInterval;
    else
        mTracerInterval = Default.mTracerInterval;

    if (mTracer != None && Level.TimeSeconds > mLastTracerTime + mTracerInterval)
    {
            mTracer.SetLocation(WeaponFireLocation);

        hitDist = VSize(LastHitLocation - WeaponFireLocation) - mTracerPullback;

        if (Instigator != None && Instigator.IsLocallyControlled())
            SpawnDir = vector(WeaponFireRotation);
        else
            SpawnDir = Normal(LastHitLocation - WeaponFireLocation);

        if(hitDist > mTracerMinDistance)
        {
            SpawnVel = SpawnDir * mTracerSpeed;

            mTracer.Emitters[0].StartVelocityRange.X.Min = SpawnVel.X;
            mTracer.Emitters[0].StartVelocityRange.X.Max = SpawnVel.X;
            mTracer.Emitters[0].StartVelocityRange.Y.Min = SpawnVel.Y;
            mTracer.Emitters[0].StartVelocityRange.Y.Max = SpawnVel.Y;
            mTracer.Emitters[0].StartVelocityRange.Z.Min = SpawnVel.Z;
            mTracer.Emitters[0].StartVelocityRange.Z.Max = SpawnVel.Z;

            mTracer.Emitters[0].LifetimeRange.Min = hitDist / mTracerSpeed;
            mTracer.Emitters[0].LifetimeRange.Max = mTracer.Emitters[0].LifetimeRange.Min;

            mTracer.SpawnParticle(1);
        }

        mLastTracerTime = Level.TimeSeconds;
    }
}

simulated function FlashMuzzleFlash()
{
    Super.FlashMuzzleFlash();

    if (Role < ROLE_Authority)
        DualFireOffset *= -1;

    UpdateTracer();
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
    bInstantFire = True
    Spread       = 0.0675
    DamageMin    = 40
    DamageMax    = 40
    DamageType   = class'UT3DmgType_LeviathanShard'
    FireInterval = 0.1

    FireSoundClass = Sound'UT3A_Weapon_Stinger.FireAlt.FireAltCue'
    bAmbientFireSound=False

    mTracerInterval=0.06
    mTracerClass=class'XEffects.NewTracer'
    mTracerPullback=150.0
    mTracerMinDistance=0.0
    mTracerSpeed=15000.0

    AIInfo(0)=(bInstantHit=true,AimError=750)

    Mesh = SkeletalMesh'UT3VH_Leviathan_Anims.Leviathan_LeftRearTurret'
    RedSkin = Shader'UT3LeviathanTex.LeviTurret.TurretSkin'
    BlueSkin = Shader'UT3LeviathanTex.LeviTurret.TurretSkinBlue'
    SkinSlot = 2
    PitchBone = "LT_Rear_TurretPitch"
    YawBone = "LT_Rear_TurretYaw"
    WeaponFireAttachmentBone = "Lt_Rear_Turret_Barrel"
    GunnerAttachmentBone = "LT_Rear_TurretPitch"
    ShieldAttachmentBone = "Lt_Rear_Turret_Barrel"
    DualFireOffset = 0.0
}
