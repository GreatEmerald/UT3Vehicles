/*
 * Copyright © 2009, 2014 GreatEmerald
 * Copyright © 2012, 2017 Luís 'zeluisping' Guimarães <zeluis.100@gmail.com>
 * Copyright © 2017 HellDragon-HK
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

class UT3PaladinCannon extends ONSShockTankCannon;

/* Name of the shield's pitch bone. */
var name ShieldPitchBone;
/* Sound played on projectile impact. */
var Sound FireImpact;

function ProximityExplosion() //Instant shock combo
{
    local Emitter ComboHit;

    ComboHit = Spawn(class'ONSShockTankShieldComboHit', self);
    if ( Level.NetMode == NM_DedicatedServer )
    {
        ComboHit.LifeSpan = 0.6;
    }
    AttachToBone(ComboHit, PitchBone); // @100GPing100: Changed bone name.
    ComboHit.SetRelativeLocation(vect(300,0,0));
    SetTimer(0.1, false);
}

simulated function PostNetBeginPlay()
{
    Super(ONSWeapon).PostNetBeginPlay();

    ShockShield = spawn(class'UT3PaladinShield', self);

    if (ShockShield != None)
        //AttachToBone(ShockShield, 'ElectroGun');
        AttachToBone(ShockShield, ShieldPitchBone);
}

function Timer()
{
    PlaySound(FireImpact, SLOT_None,1.0,,800);
    Spawn(class'ONSShockTankProximityExplosion', self,, Location + vect(0,0,-70));
    HurtRadius(200, 900, class'DamTypeShockTankProximityExplosion', 150000, Location);
}

function Tick(float DeltaTime)
{
    local Rotator Aim, NewAim, AimRotatorWorld, rot;
    local float YawDelta, PitchDelta;
    local vector AimVectorWorld, AimVectorLocal;

    Super.Tick(DeltaTime);

    // Apply pitch rotation to the shield arm too.
    if (bForceCenterAim)
        Aim = rot(0,0,0);
    else
    {
        AimVectorWorld = CurrentHitLocation - WeaponFireLocation;
        AimVectorWorld = Normal(AimVectorWorld);
        AimRotatorWorld = Rotator(AimVectorWorld);
        AimVectorLocal = AimVectorWorld >> Rotation;
        Aim = Rotator(AimVectorLocal);
    }

    NewAim.Yaw = 0;
    NewAim.Pitch = 0;
    NewAim.Roll = 0;

    YawDelta = ShortestAngularDelta(Aim.Yaw, CurrentAim.Yaw);
    PitchDelta = ShortestAngularDelta(Aim.Pitch, CurrentAim.Pitch);

    NewAim = SmoothRotate(YawDelta, PitchDelta, CurrentAim, RotationsPerSecond, DeltaTime);

    rot.Pitch = -NewAim.Pitch;
    rot.Yaw = 0;
    rot.Roll = 0;

    SetBoneRotation(ShieldPitchBone, rot, 0, 1);
}

state ProjectileFireMode
{
    function Fire(Controller C)
    {
        Super.Fire(C);

        PlayAnim('Fire');
    }
}

// From ONSWeapon.cpp
function float ShortestAngularDelta(float EndAngle, float StartAngle)
{
    local float DeltaCW, DeltaCCW;

    DeltaCW = CWAngularDelta(EndAngle, StartAngle);
    DeltaCCW = CCWAngularDelta(EndAngle, StartAngle);

    if (DeltaCW < 32768)
        return DeltaCW;
    else
        return DeltaCCW;
}
function float CCWAngularDelta(float EndAngle, float StartAngle)
{
    return -(ClampAngle(StartAngle - EndAngle));
}
function float CWAngularDelta(float EndAngle, float StartAngle)
{
    return ClampAngle(EndAngle - StartAngle);
}
function float ClampAngle(float Angle)
{
    //return (float)((int)Angle & 65536);
    return Clamp(Angle, 0, 65536);
}
function rotator SmoothRotate(float YawDelta, float PitchDelta, rotator CurrentRotation, float RPS, float deltaSeconds)
{
    local float AngularDistance;
    local Rotator Aim;

    AngularDistance = ClampAngle(deltaSeconds * RPS * 65536);

    Aim.Yaw = CurrentRotation.Yaw + Clamp(YawDelta, -AngularDistance, AngularDistance);
    Aim.Pitch = CurrentRotation.Pitch + Clamp(PitchDelta, -AngularDistance, AngularDistance);
    Aim.Roll = 0;

    return Aim;
}

defaultproperties
{

    Drawscale = 1.0

    Mesh=SkeletalMesh'UT3VH_Paladin_Anims.PaladinWeaponOnly';
    RedSkin=Shader'UT3PaladinTex.Paladin.PaladinSkin';
    BlueSkin=Shader'UT3PaladinTex.Paladin.PaladinSkinBlue';

    FireSoundClass=Sound'UT3A_Vehicle_Paladin.Sounds.A_Vehicle_Paladin_Fire01';
    FireImpact=Sound'UT3A_Vehicle_Paladin.Sounds.A_Vehicle_Paladin_FireImpact01';
    //RotateSound=sound'ONSBPSounds.ShockTank.TurretHorizontal'
    RotationsPerSecond=0.68 //0.18
    PitchUpLimit=9900
    PitchDownLimit=57500
    
    YawBone=Turret_Yaw
    PitchBone=Cannon_Pitch
    ShieldPitchBone=Shield_Pitch
    WeaponFireAttachmentBone=CannonBarrel


    MaxShieldHealth=1200.000000    //GE: Exact Copy-Paste of the UT3 code
    MaxDelayTime=2.500000          //Increased
    ShieldRechargeRate=350.000000  //Decreased
    CurrentShieldHealth=1200.000000//Maximum Shield health is lower, but current is higher
    ProjectileClass=class'UT3PaladinProjectile'
}
