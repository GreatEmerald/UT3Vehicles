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

class UT3HellfireSPMACamera extends ONSMortarCamera;


/** Camera view offset scale. Interpolated to 0 while deploying. */
var float CVScale;

/** Maximum target trace range from camera. */
var float MaxTargetRange;

var Sound DeploySound, DeployedAmbientSound;

var bool bTargetOutOfRange;

/** Player's aiming target location. */
var vector TargetLocation, TargetNormal;

var float NextAIDeployCheck;


var UT3HellfireSPMATrajectory Trajectory;


function BeginPlay()
{
    // set up deploy check/message
    NextAIDeployCheck = Level.TimeSeconds + 1;
    SetTimer(0.25, false);
}

simulated function Destroyed()
{
    if (Trajectory != None)
        Trajectory.Destroy();

    //log(self@Instigator.Controller.GetTeamNum()@"Destroyed");
    Super.Destroyed();
}


// unused by camera
function StartTimer(float Fuse);

// send deployment hint
function Timer()
{
    if (Instigator != None && PlayerController(Instigator.Controller) != None && PlayerController(Instigator.Controller).ViewTarget == Self) {
        PlayerController(Instigator.Controller).ReceiveLocalizedMessage(class'ONSOnslaughtMessage', 34);
    }
}

function bool IsStationary()
{
    return bDeployed;
}

function Deploy()
{
    AnnounceTargetTime = Level.TimeSeconds + 1.5;
    DeployCamera();
}


simulated function DeployCamera()
{
    if (bShotDown) {
        // can't deploy if already disconnected
        //log(self@Instigator.Controller.GetTeamNum()@"DeployCamera: Trying to deploy but already shot down");
        return;
    }
    bDeployed = True;
    Velocity = vect(0,0,0);
    SetPhysics(PHYS_Projectile);
    bOrientToVelocity = False;
    DesiredRotation = rot(-16384,0,0);
    RotationRate = rot(16384,16384,16384);
    bRotateToDesired = True;
    PlaySound(DeploySound, SLOT_None, 1.0);
    AmbientSound = DeployedAmbientSound;
    PlayAnim('Deploy', 1.0, 0.0);
    if (Trajectory == None)
        Trajectory = Spawn(class'UT3HellfireSPMATrajectory', Self, '', Location);
}


simulated event EndedRotation()
{
    bRotateToDesired = False;
    RotationRate = rot(0,0,0);
}


simulated function Tick(float DeltaTime)
{
    local vector HitLocation, HitNormal;

    if (bShotDown || UT3HellfireSPMA(Instigator) == None || UT3HellfireSPMA(Instigator).Driver == None) {
        //log(self@Instigator.Controller.GetTeamNum()@"Tick: shooting down"@!bShotDown@"because Instigator"@UT3HellfireSPMA(Instigator)@"Driver"@UT3HellfireSPMA(Instigator).Driver);
        if (!bShotDown)
            ShotDown();
        Disable('Tick');
        return;
    }

    if (!bDeployed) {
        TargetLocation = Location;
    }
    else {
        if (CVScale > 0) {
            CVScale -= DeltaTime * 0.8;
            if (CVScale <= 0)
                CVScale = 0;
            if (CVScale < 0.25 && !bOwnerNoSee)
                bOwnerNoSee = true;
        }
        if (Instigator.IsLocallyControlled() && Instigator.IsHumanControlled()) {
            if (Trace(HitLocation, HitNormal, Location + vector(Instigator.Controller.Rotation) * MaxTargetRange,, True) == None) {
                HitLocation = Location + vector(Instigator.Controller.Rotation) * MaxTargetRange;
                HitNormal = vect(0,0,1);
            }
            else {
                HitLocation += HitNormal * 50.0;
            }
            UpdateTargetLocation(HitLocation, HitNormal);
            UT3HellfireSPMACannon(Owner).PredictTarget();

            if (Trajectory != None) {
                if (UT3HellfireSPMACannon(Owner).bCanHitTarget && UT3HellfireSPMACannon(Owner).FireCountdown <= 0
                    && vector(UT3HellfireSPMACannon(Owner).WeaponFireRotation) dot vector(UT3HellfireSPMACannon(Owner).TargetRotation) > 0.99)
                    Trajectory.UpdateTrajectory(True, UT3HellfireSPMACannon(Owner).WeaponFireLocation,
                        vector(UT3HellfireSPMACannon(Owner).WeaponFireRotation) * Lerp(UT3HellfireSPMACannon(Owner).WeaponCharge,
                        UT3HellfireSPMACannon(Owner).MinSpeed, UT3HellfireSPMACannon(Owner).MaxSpeed),
                        -PhysicsVolume.Gravity.Z, Region.Zone.KillZ);
                else
                    Trajectory.UpdateTrajectory(False);
            }
        }
    }

    if (Role < ROLE_Authority)
        return;
    // following code is serverside-only

    if (!bDeployed) {
        if (Instigator != None && AIController(Instigator.Controller) != None && NextAIDeployCheck <= Level.TimeSeconds) {
        //log(self@"Tick: AI is testing camera!");
            if (Instigator.Controller.Target != None && FastTrace(Instigator.Controller.Target.Location)) {
                //log(self@"Tick: deploying camera!");
                Deploy();
            }
            else {
                NextAIDeployCheck = Level.TimeSeconds + 0.1;
            }
        }
    }
    else if (Level.TimeSeconds > AnnounceTargetTime) {
        AnnounceTargetTime = Level.TimeSeconds + 1.5;
        ShowSelf(True);
    }
}


// obsolete
function SetTarget(vector loc);

simulated function UpdateTargetLocation(vector NewTargetLocation, vector NewTargetNormal)
{
    local vector X, Y;

    TargetLocation = NewTargetLocation;
    TargetNormal   = NewTargetNormal;

    if (TargetBeam == None) {
        TargetBeam = Spawn(class'UT3HellfireSPMATargetReticle', self,, Location, rot(0,0,0));
        TargetBeam.ArtilleryLocation = Instigator.Location;
    }
    if (TargetBeam != None) {
        TargetBeam.SetLocation(TargetLocation);

        // reticle StaticMesh uses TargetNormal as Z direction
        Y = Normal(TargetNormal Cross (TargetLocation - Instigator.Location));
        X = -(TargetNormal Cross Y);
        TargetBeam.SetRotation(OrthoRotation(X, Y, TargetNormal));
    }
}


/**
Reveal the camera to enemy bots, giving them a chance to target it.
*/
function ShowSelf(bool bCheckFOV)
{
    local Controller C;
    local Bot B;

    if (!bShotDown) {
        for (C = Level.ControllerList; C != None; C = C.NextController) {
            B = Bot(C);
            if (B != None && !B.SameTeamAs(Instigator.Controller) && B.Pawn != None && !B.Pawn.IsFiring() && (B.Enemy == None || B.Enemy == Instigator || B.Skill > 2.0 + 2.0 * FRand() && !B.EnemyVisible()) && (!bCheckFOV || Normal(B.FocalPoint - B.Pawn.Location) dot (Location - B.Pawn.Location) > B.Pawn.PeripheralVision) && B.LineOfSightTo(self)) {
                // give B a chance to shoot at me
                B.GoalString = "Destroy Mortar Camera";
                B.Target = self;
                B.SwitchToBestWeapon();
                if (B.Pawn.CanAttack(self)) {
                    B.DoRangedAttackOn(self);
                    if (FRand() < 0.5)
                        break;
                }
            }
        }
    }
}

// non-tick part of UT3 CalcCamera()
simulated function bool SpecialCalcView(out Actor ViewActor, out vector CameraLocation, out rotator CameraRotation, bool bBehindView)
{
    local vector HitNormal, HitLocation;

    ViewActor = Self;

    CameraLocation = Location + ((MortarCameraOffset * CVScale) >> CameraRotation);
    if (Trace(HitLocation, HitNormal, CameraLocation, Location, false, vect(12,12,12)) != None)
        CameraLocation = HitLocation;

    return True;
}


simulated function ShotDown()
{
    //log(self@Instigator.Controller.GetTeamNum()@"ShotDown");
    if (Instigator != None && PlayerController(Instigator.Controller) != None && PlayerController(Instigator.Controller).ViewTarget == Self) {
        if (Instigator.Controller.Pawn != None) {
            PlayerController(Instigator.Controller).bBehindView = Instigator.Controller.Pawn.PointOfView();
            PlayerController(Instigator.Controller).SetViewTarget(Instigator.Controller.Pawn);
        }
        else {
            PlayerController(Instigator.Controller).bBehindView = False;
            PlayerController(Instigator.Controller).SetViewTarget(Instigator.Controller);
        }
    }

    if (TargetBeam != None)
        TargetBeam.Destroy();

    if (Trajectory != None)
        Trajectory.Destroy();

    Super.ShotDown();
    bShotDown = True;
}


/**
Slightly modified verion of ONSMortarCamera::PostNetReceive() to account for
bDeployed reverting to False when shot down or manually disconnected.
*/
simulated function PostNetReceive()
{
    Super(ONSMortarShell).PostNetReceive();

    if (bDeployed != bLastDeployed) {
        bLastDeployed = bDeployed;
        if (bDeployed)
            DeployCamera();
    }

    if (bShotDown != bLastShotDown) {
        bLastShotDown = bShotDown;
        if (bShotDown)
            ShotDown();
    }

    if (RealLocation != LastRealLocation) {
        SetLocation(RealLocation);
        LastRealLocation = RealLocation;
    }
}

// GEm: DEBUG
/*function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType)
{
    log(self@Instigator.Controller.GetTeamNum()@"TakeDamage from"@instigatedBy);
    Super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
}*/

//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
    MortarCameraOffset = (X=-256.0,Z=128.0)
    CVScale = 1.0
    MaxTargetRange = 10240.0
    Speed = 4000.0
    DrawScale=0.3
    DeploySound = Sound'UT3A_Vehicle_SPMA.UT3SPMACameraDeploy.UT3SPMACameraDeployCue'
    DeployedAmbientSound = Sound'UT3A_Vehicle_SPMA.UT3SPMASingles.UT3SPMACameraAmbient01CueAll'
    ImpactSound = Sound'UT3A_Vehicle_SPMA.UT3SPMAShellFragmentExplode.UT3SPMAShellFragmentExplodeCue'
    bOrientToVelocity = True
    bAlwaysRelevant = True
    //TransientSoundRadius = 500.0
}
