/*
 * Copyright © 2008-2009 Wormbo
 * Copyright © 2008-2009, 2014 GreatEmerald
 * Copyright © 2012 100GPing100
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

class UT3RaptorWeapon extends ONSLinkableWeapon;

var(Sound) Sound HomingSound;
var bool bSkipFire; // GEm: Last shot was from this gun, let the other gun fire now

var class<Projectile> TeamProjectileClasses[2];
var float MinAim;

function byte BestMode()
{
    local bot B;

    B = Bot(Instigator.Controller);
    if ( B == None )
        return 0;

    if ( (Vehicle(B.Enemy) != None)
         && (B.Enemy.bCanFly || B.Enemy.IsA('ONSHoverCraft')) && (FRand() < 0.3 + 0.1 * B.Skill) )
        return 1;
    else
        return 0;
}

state ProjectileFireMode
{
    function Fire(Controller C)
    {
        if (Vehicle(Owner) != None && Vehicle(Owner).Team < 2)
            ProjectileClass = TeamProjectileClasses[Vehicle(Owner).Team];
        else
            ProjectileClass = TeamProjectileClasses[0];

        Super.Fire(C);
    }

    function AltFire(Controller C)
    {
        local ONSAttackCraftMissle M;
        local Vehicle V, Best;
        local float CurAim, BestAim;

        M = ONSAttackCraftMissle(SpawnProjectile(AltFireProjectileClass, True));
        if (M != None)
        {
            if (AIController(Instigator.Controller) != None)
            {
                V = Vehicle(Instigator.Controller.Enemy);
                if (V != None && (V.bCanFly || V.IsA('ONSHoverCraft')) && Instigator.FastTrace(V.Location, Instigator.Location))
                    M.SetHomingTarget(V);
            }
            else
            {
                BestAim = MinAim;
                for (V = Level.Game.VehicleList; V != None; V = V.NextVehicle)
                    if (V.Health > 0 && (V.bCanFly || V.IsA('ONSHoverCraft')) && V != Instigator && Instigator.GetTeamNum() != V.GetTeamNum())
                    {
                        CurAim = Normal(V.Location - WeaponFireLocation) dot vector(WeaponFireRotation);
                        if (CurAim > BestAim && Instigator.FastTrace(V.Location, Instigator.Location))
                        {
                            Best = V;
                            BestAim = CurAim;
                        }
                    }
                if (Best != None) {
                    M.SetHomingTarget(Best);
                    PlayOwnedSound(HomingSound, SLOT_Interact, 2.5*TransientSoundVolume);
                }
            }
        }
    }
}

event bool AttemptFire(Controller C, bool bAltFire)
{
    local bool bResult;

    if(Role != ROLE_Authority || bForceCenterAim)
        return False;

    //Instigator.ClientMessage(self@"AttemptFire"@FireCountdown@bAltFire);
    /*if (bSkipFire)
    {
        bSkipFire = false;
        //Instigator.ClientMessage(self@"AttemptFire: Skipping");
        if (ChildWeapon != None)
            return ChildWeapon.AttemptFire(C, bAltFire);
        return false;
    }
    else
        bSkipFire = true;*/
    //Instigator.ClientMessage(self@"AttemptFire: Firing");
    if (bSkipFire && UT3RaptorWeapon(ChildWeapon) != None)
    {
        bSkipFire = false;
        bResult = UT3RaptorWeapon(ChildWeapon).ChildAttemptFire(C, bAltFire, FireCountdown);
        if (FireCountdown <= 0 && bAltFire)
            FireCountdown = AltFireInterval;
        else if (FireCountdown <= 0)
            FireCountdown = FireInterval;
        return bResult;
    }
    else if (!bSkipFire)
        bSkipFire = true;

    if (FireCountdown <= 0)
    {
        CalcWeaponFire();
        if (bCorrectAim)
            WeaponFireRotation = AdjustAim(bAltFire);
        if (Spread > 0)
            WeaponFireRotation = rotator(vector(WeaponFireRotation) + VRand()*FRand()*Spread);

            //DualFireOffset *= -1;

        Instigator.MakeNoise(1.0);
        if (bAltFire)
        {
            FireCountdown = AltFireInterval;
            AltFire(C);
        }
        else
        {
            FireCountdown = FireInterval;
            //Instigator.ClientMessage(self@"Fire");
            Fire(C);
        }
        AimLockReleaseTime = Level.TimeSeconds + FireCountdown * FireIntervalAimLock;

        /*if (ChildWeapon != None)
            UT3RaptorWeapon(ChildWeapon).bSkipFire = false;
            ChildWeapon.AttemptFire(C, bAltFire);*/

        return True;
    }

    return False;
}

function bool ChildAttemptFire(Controller C, bool bAltFire, float RealCountdown)
{
    if (RealCountdown <= 0)
    {
        CalcWeaponFire();
        if (bCorrectAim)
            WeaponFireRotation = AdjustAim(bAltFire);
        if (Spread > 0)
            WeaponFireRotation = rotator(vector(WeaponFireRotation) + VRand()*FRand()*Spread);

        //DualFireOffset *= -1;

        Instigator.MakeNoise(1.0);
        if (bAltFire)
            AltFire(C);
        else
            Fire(C);
        AimLockReleaseTime = Level.TimeSeconds + FireCountdown * FireIntervalAimLock;

        return True;
    }

    return False;
}

simulated function CalcWeaponFire()
{
    local coords WeaponBoneCoords;
    local vector CurrentFireOffset;
    local float DualFireHack;

    // GEm: Because I have no clue why both weapons fire from the same point
    DualFireHack = DualFireOffset * (int(UT3RaptorWeapon(ChildWeapon) != None) * 2 - 1);

    // Calculate fire offset in world space
    WeaponBoneCoords = GetBoneCoords(WeaponFireAttachmentBone);
    CurrentFireOffset = (WeaponFireOffset * vect(1,0,0)) + (DualFireHack * vect(0,1,0));

    // Calculate rotation of the gun
    WeaponFireRotation = rotator(vector(CurrentAim) >> Rotation);

    // Calculate exact fire location
    WeaponFireLocation = WeaponBoneCoords.Origin + (CurrentFireOffset >> WeaponFireRotation);

    // Adjust fire rotation taking dual offset into account
    //if (bDualIndependantTargeting)
        WeaponFireRotation.Pitch = rotator(CurrentHitLocation - WeaponFireLocation).Pitch;

    //local vector LogVec;
    //Super.CalcWeaponFire();
    //LogVec = WeaponBoneCoords.Origin;
    /*log(self@"CalcWeaponFire: WeaponBoneCoords"
    @WeaponBoneCoords.Origin
    @"WeaponFireLocation"
    @WeaponFireLocation);*/
}

//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
    //===========================
    // @100GPing100
    FireSoundClass = Sound'UT3A_Vehicle_Raptor.Sounds.A_Vehicle_Raptor_Fire01';
    AltFireSoundClass = Sound'UT3A_Vehicle_Raptor.Sounds.A_Vehicle_Raptor_AltFire01_Dup';
    HomingSound = Sound'UT3A_Vehicle_Cicada.Sounds.A_Vehicle_Cicada_TargetLock01';
    Mesh = SkeletalMesh'UT3VH_Raptor_Anims.RaptorRightGunOnly'
    RedSkin = Shader'UT3RaptorTex.RaptorSkin'
    BlueSkin = Shader'UT3RaptorTex.RaptorSkinBlue'
    PitchBone = 'rt_gun'
    YawBone = 'rt_gun'
    WeaponFireAttachmentBone = 'rt_gun';
    WeaponFireOffset = 95.0
    DualFireOffset = 15.0
    // @100GPing100
    //============EDN============
    FireInterval    = 0.2
    AltFireInterval = 1.2
    ProjectileClass=class'UT3RaptorProjRed'
    TeamProjectileClasses(0)=class'UT3RaptorProjRed'
    TeamProjectileClasses(1)=class'UT3RaptorProjBlue'
    RotationsPerSecond=0.51 //GE: Maybe too low?
    MinAim=0.930
    AltFireProjectileClass=class'UT3RaptorRocket'
    //HomingSound=Sound'UT3Weapons2.Generic.LockOn'
    //FireSoundClass=sound'UT3Vehicles.RAPTOR.RaptorFire'
    //AltFireSoundClass=sound'UT3Vehicles.RAPTOR.RaptorAltFire'
    PitchUpLimit = 18000
    PitchDownLimit = 49153
    //YawEndConstraint = 49153
    YawStartConstraint=-5000
    YawEndConstraint=5000
}
