/*
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

class UT3CicadaMissileLauncher extends ONSDualACSideGun;

var(Sound) sound LoadSound;

event bool AttemptFire(Controller C, bool bAltFire) //GE: More control over when we altfire.
{
    if(Role != ROLE_Authority || bForceCenterAim )
        return False;

    if (bAltFire)
    {
        if ( Bot(C) != None )
        {
            if ( (Vehicle(Instigator).Rise <= 0) && FastTrace(Instigator.Location - vect(0,0,500),Instigator.Location) )
                Vehicle(Instigator).Rise = -0.5;
            else
                Vehicle(Instigator).Rise = 1;
        }
        if (!bLocked && LoadedShotCount == 0)   // Handle Alt Fire
            ChangeTargetLock();

        if ( !bDumpingLoad && FireCountdown <= 0 )
        {
            if ( LoadedShotCount < MaxShotCount)
            {
                LoadedShotCount++;
                PlaySound(LoadSound);
                FireCountdown = AltFireInterval;
                Instigator.MakeNoise(1.0);
            }
        }
    }
    else
    {
        if ( Bot(Instigator.Controller) != None )
            Vehicle(Instigator).Rise = 0;
        if (LoadedShotCount==0 && FireCountdown <= 0)
            FireSingle(C,false, false); //GE: Not Don't Skip so it would fire one at a time
    }

    return False;
}

function Projectile SpawnProjectile(class<Projectile> ProjClass, bool bAltFire) //GE: Attempting the UT3 values for ejecting.
{
    local Projectile P;
    local vector StartLocation, StartVelocity;
    local rotator WFR, UpRot;
    local float Rand;

    // We want projectiles to "eject" from this gun then take flight.  Part is handled here, part in
    // the projectile.

    if ( Bot(Instigator.Controller) != None )
        Vehicle(Instigator).Rise = 0;
    StartLocation = WeaponFireLocation;
    Rand = ( (400.0 * FRand()) - 100.0 ) * ( FRand() * 2.f);   // This is our range for the ejection. //GE: Default: (400 * frand()) + 200

    // if we are going forward, apply the ships velocity to the projectile,
    // if we are going backwards, apply the 1/4 the inverse X/Y.

    WFR = WeaponFireRotation;
    if (bLocked)
        WFR.Pitch += 2048;

    StartVelocity = Instigator.Velocity;

    // Modify the start velocity so it ejects to the proper side.

    if (bFiresRight)
        StartVelocity += (Vector(WFR) cross vect(0,0,-1)) * 450;
    else
        StartVelocity += (Vector(WFR) cross vect(0,0,1)) * 450;

    // Always kick it up a little bit more

    if ( bAltFire )
        StartVelocity.Z += (Rand * ( frand()*2));
    else
        StartVelocity.Z = 200;

    P = spawn(ProjClass, self, , StartLocation, WFR);

    P.Velocity = StartVelocity; // Apply the velocity
    if ( bAltFire && bLocked && (Bot(Instigator.Controller) != None) && !FastTrace(LockedTarget,P.Location) )
    {
        UpRot = WeaponFireRotation;
        UpRot.Pitch = 12000;
        if ( !FastTrace(P.Location + 3000*vector(UpRot),P.Location) )
            UpRot.Pitch = 16000;
        ONSDualACRocket(P).Target = FindInitialTarget(WeaponFireLocation, UpRot);
    }
    else
        ONSDualACRocket(P).Target = FindInitialTarget(WeaponFireLocation, WeaponFireRotation);

    if (!bAltFire)
        ONSDualACRocket(P).DesiredDistanceToAxis = 64;
    else
        ONSDualACRocket(P).KillRange=4500;

    if (bLocked)
    {
        ONSDualACRocket(P).bFinalTarget     = false;
        ONSDualACRocket(P).SecondTarget     = LockedTarget;
        ONSDualACRocket(P).SwitchTargetTime = 0.5;
    }
    else
        ONSDualACRocket(P).bFinalTarget = true;

    // Play effects

    if (P != None)
    {
        FlashMuzzleFlash();

        // Play firing noise
        if (bAltFire)
        {
            if (bAmbientAltFireSound)
                AmbientSound = AltFireSoundClass;
            else
                PlayOwnedSound(AltFireSoundClass, SLOT_None, FireSoundVolume/255.0,, AltFireSoundRadius,, false);
        }
        else
        {
            if (bAmbientFireSound)
                AmbientSound = FireSoundClass;
            else
                PlayOwnedSound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius,, false);
        }

    }

    return P;
}


defaultproperties
{
    FireInterval=0.25
    AltFireInterval=0.5
    ProjectileClass=class'UT3CicadaRocket'
    AltFireProjectileClass=class'UT3CicadaRocket'
    LoadSound=sound'UT3A_Vehicle_Cicada.Sounds.A_Vehicle_Cicada_MissleLoad01'
    FireSoundClass=Sound'UT3A_Vehicle_Cicada.Sounds.A_Vehicle_Cicada_MissleEject01'
    AltFireSoundClass=Sound'UT3A_Vehicle_Cicada.Sounds.A_Vehicle_Cicada_MissleEject01'
    Mesh = SkeletalMesh'UT3VH_Cicada_Anims.VH_Cicada_RightSideGun'
    RedSkin = Shader'UT3CicadaTex.CicadaSkin'
    BlueSkin = Shader'UT3CicadaTex.CicadaSkinBlue'
    PitchBone = Rt_Gun_Pitch
    YawBone = Rt_Gun_Yaw
    WeaponFireAttachmentBone = Rt_Gun_Pitch
    RotationsPerSecond = 0.5
    YawStartConstraint=-5000
    YawEndConstraint=5000
    bInstantRotation = false
}
