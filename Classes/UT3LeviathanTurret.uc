/*
 * Copyright © 2007 Wormbo
 * Copyright © 2014 GreatEmerald
 * Copyright © 2017 HellDragon
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

class UT3LeviathanTurret extends ONSMASSideGunPawn abstract;

#exec OBJ LOAD FILE="..\Sounds\UT3A_Vehicle_Leviathan.uax"

//=============================================================================
// Properties
//=============================================================================

var float ShieldDuration;
var float ShieldRecharge;

//=============================================================================
// Variables
//=============================================================================

var float ShieldAvailableTime;

var name EnterAnim, LeaveAnim, ArmBone;


/**
Best mode is always primary. Shield activation is handled separately for bots.
*/
function byte BestMode()
{
    return 0;
}

/*
/**
React to incoming AVRiLs.
*/
function ShouldTargetMissile(Projectile P)
{
    local vector ;

    if (Bot(Controller) != None && Bot(Controller).Skill >= 3.0) {
        GetAxes(VehicleBase.Rotation, X, Y, Z);
    }
}
*/


/**
Shield charge bar fill percentage.
*/
simulated function float ChargeBar()
{
    if (UT3LeviathanTurretWeapon(Gun) != None && !bHasAltFire) {
        if (UT3LeviathanTurretWeapon(Gun).bShieldActive)
            return FClamp(1.0 - TimerCounter / ShieldDuration, 0.0, 0.999);
        else
            return FClamp(1.0 - (ShieldAvailableTime - Level.TimeSeconds) / ShieldRecharge, 0.0, 0.999);
    }
    return 0;
}


/**
Activate shield on alt-fire.
*/
function AltFire(optional float F)
{
    if (!bHasAltFire) {
        ActivateShield();
    }
    else {
        Super.AltFire(F);
    }
}


/**
Deactivate the shield and set its recharge delay.
*/
function ActivateShield()
{
    if (UT3LeviathanTurretWeapon(Gun) != None && Level.TimeSeconds >= ShieldAvailableTime) {
        ShieldAvailableTime = Level.TimeSeconds + ShieldDuration + ShieldRecharge;
        SetTimer(ShieldDuration, false);
        UT3LeviathanTurretWeapon(Gun).ActivateShield();
    }
}


/**
Deactivate the shield and set its recharge delay.
*/
function DeactivateShield()
{
    if (UT3LeviathanTurretWeapon(Gun) != None && UT3LeviathanTurretWeapon(Gun).bShieldActive) {
        ShieldAvailableTime = Level.TimeSeconds + ShieldRecharge;
        UT3LeviathanTurretWeapon(Gun).DeactivateShield();
    }
}


/**
Deactivate shield after its time runs out.
*/
function Timer()
{
    DeactivateShield();
}


function DriverLeft()
{
    DeactivateShield();
}

function KDriverEnter(Pawn P)
{
    local int AnimSlot;

    Super.KDriverEnter(P);

    // GEm: Desyncs due to rotation, perhaps the turret bone should be connected to Base
    if (UT3LeviathanTurretWeapon(Gun) != None)
    {
        AnimSlot = UT3LeviathanTurretWeapon(Gun).SkinSlot-1;
        VehicleBase.AnimBlendParams(AnimSlot, 1.0, , , ArmBone);
        VehicleBase.PlayAnim(EnterAnim, 1.0, 0.0, AnimSlot);
        PlaySound(Sound'UT3A_Vehicle_Leviathan.Sounds.A_Vehicle_Leviathan_TurretActivate', SLOT_None, 2.0);
    }
}

function bool KDriverLeave(bool bForceLeave)
{
    local bool bResult;
    local int AnimSlot;

    bResult = Super.KDriverLeave(bForceLeave);
    if (bResult && UT3LeviathanTurretWeapon(Gun) != None)
    {
        AnimSlot = UT3LeviathanTurretWeapon(Gun).SkinSlot-1;
        VehicleBase.AnimBlendParams(AnimSlot, 1.0, , , ArmBone);
        VehicleBase.PlayAnim(LeaveAnim, 1.0, 0.0, AnimSlot);
        PlaySound(Sound'UT3A_Vehicle_Leviathan.Sounds.A_Vehicle_Leviathan_TurretDeactivate', SLOT_None, 2.0);
    }

    return bResult;
}

/*simulated function PostBeginPlay()
{
    // GEm: The following puts the weapons too close to the base vehicle...
    UT3LeviathanTurretWeapon(Gun).PlayAnim('InActiveStill', 1.0, 0.0);
    super.PostBeginPlay();
}*/

simulated function vector GetCameraLocationStart()
{
    if (Gun != None)
        return Gun.GetBoneCoords(Gun.WeaponFireAttachmentBone).Origin;
    else
        return Super.GetCameraLocationStart();
}

simulated function AttachDriver(Pawn P)
{
    Local rotator FootDriveL,FootDriveR;
    Local rotator ArmDriveL,ArmDriveR;
    Local rotator ForeArmDriveL, ForeArmDriveR;
    Local rotator ThighDriveL,ThighDriveR;
    Local rotator CalfDriveL,CalfDriveR;
    Local rotator SpineDrive;
    super.AttachDriver(P);

    ArmDriveL.Yaw=-5000;
    ArmDriveL.Pitch=-4000;
    P.SetBoneRotation('Bip01 L UpperArm',ArmDriveL);
    ArmDriveR.Yaw=-5000;
    ArmDriveR.Pitch=4000;
    P.SetBoneRotation('Bip01 R UpperArm',ArmDriveR);
    ForeArmDriveL.Yaw=8000;
    P.SetBoneRotation('Bip01 L ForeArm',ForeArmDriveL);
    ForeArmDriveR.Yaw=8000;
    P.SetBoneRotation('Bip01 R ForeArm',ForeArmDriveR);
    ThighDriveL.Pitch=1000;
    P.SetBoneRotation('Bip01 L Thigh',ThighDriveL);
    ThighDriveR.Pitch=-1000;
    P.SetBoneRotation('Bip01 R Thigh',ThighDriveR);
    CalfDriveL.Yaw=-2000;
    P.SetBoneRotation('Bip01 L Calf',CalfDriveL);
    CalfDriveR.Yaw=-2000;
    P.SetBoneRotation('Bip01 R Calf',CalfDriveR);
    SpineDrive.Yaw=-4000;
    P.SetBoneRotation('Bip01 Spine',SpineDrive);
    FootDriveL.Yaw=8000;
    P.SetBoneRotation('Bip01 L Foot',FootDriveL);
    FootDriveR.Yaw=8000;
    P.SetBoneRotation('Bip01 R Foot',FootDriveR);
}

simulated function DetachDriver(Pawn P)
{
    P.SetBoneRotation('Bip01 Head');
    P.SetBoneRotation('Bip01 Spine');
    P.SetBoneRotation('Bip01 Spine1');
    P.SetBoneRotation('Bip01 Spine2');
    P.SetBoneRotation('Bip01 L Clavicle');
    P.SetBoneRotation('Bip01 R Clavicle');
    P.SetBoneRotation('Bip01 L UpperArm');
    P.SetBoneRotation('Bip01 R UpperArm');
    P.SetBoneRotation('Bip01 L ForeArm');
    P.SetBoneRotation('Bip01 R ForeArm');
    P.SetBoneRotation('Bip01 L Thigh');
    P.SetBoneRotation('Bip01 R Thigh');
    P.SetBoneRotation('Bip01 L Calf');
    P.SetBoneRotation('Bip01 R Calf');
    P.SetBoneRotation('Bip01 L Foot');
    P.SetBoneRotation('Bip01 R Foot');
    
    Super.DetachDriver(P);
}

//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
    bShowChargingBar = True
    bHasAltFire      = False
    ShieldDuration   = 4.0
    ShieldRecharge   = 5.0
    bDrawDriverInTP = true
    DrivePos = (X=7,Y=0.0,Z=53.5) //(X=-7.0,Y=0.0,Z=65.0)
}
