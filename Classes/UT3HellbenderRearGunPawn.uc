/*
 * Copyright © 2008, 2014 GreatEmerald
 * Copyright © 2018 HellDragon
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

class UT3HellbenderRearGunPawn extends ONSPRVRearGunPawn;

simulated function AttachDriver(Pawn P)
{
    Local rotator SpineDrive;
    Local rotator ThighDriveL,ThighDriveR;
    Local rotator CalfDriveL,CalfDriveR;
    Local rotator FootDriveL,FootDriveR;
    Local rotator ArmDriveL,ArmDriveR;
    Local rotator HandDriveL, HandDriveR;
    Local rotator ForeArmDriveL, ForeArmDriveR;
    Local rotator NeckDrive;
    super.AttachDriver(P);

    NeckDrive.Yaw=4000;
    P.SetBoneRotation('Bip01 Head',NeckDrive);
    SpineDrive.Yaw=-8000;
    P.SetBoneRotation('Bip01 Spine',SpineDrive);
    ArmDriveL.Pitch=-3000;
    ArmDriveL.Roll=-3000;
    P.SetBoneRotation('Bip01 L UpperArm',ArmDriveL);
    ArmDriveR.Pitch=1500;
    P.SetBoneRotation('Bip01 R UpperArm',ArmDriveR);
    ForeArmDriveL.Yaw=4000;
    ForeArmDriveL.Pitch=2000;
    ForeArmDriveL.Roll=-8000;
    P.SetBoneRotation('Bip01 L ForeArm',ForeArmDriveL);
    ForeArmDriveR.Yaw=4000;
    ForeArmDriveR.Pitch=500;
    ForeArmDriveR.Roll=8000;
    P.SetBoneRotation('Bip01 R ForeArm',ForeArmDriveR);
    HandDriveL.Roll=4000;
    P.SetBoneRotation('Bip01 L Hand',HandDriveL);
    HandDriveR.Pitch=-2000;
    HandDriveR.Roll=-2000;
    P.SetBoneRotation('Bip01 R Hand',HandDriveR);
    ThighDriveL.Pitch=2000;
    ThighDriveL.Yaw=5000;
    P.SetBoneRotation('Bip01 L Thigh',ThighDriveL);
    ThighDriveR.Pitch=-2000;
    ThighDriveR.Yaw=5000;
    P.SetBoneRotation('Bip01 R Thigh',ThighDriveR);
    CalfDriveL.Yaw=-8000;
    P.SetBoneRotation('Bip01 L Calf',CalfDriveL);
    CalfDriveR.Yaw=-8000;
    P.SetBoneRotation('Bip01 R Calf',CalfDriveR);
    FootDriveL.Yaw=9000;
    P.SetBoneRotation('Bip01 L Foot',FootDriveL);
    FootDriveR.Yaw=9000;
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
    P.SetBoneRotation('Bip01 L Hand');
    P.SetBoneRotation('Bip01 R Hand');
    P.SetBoneRotation('Bip01 L Thigh');
    P.SetBoneRotation('Bip01 R Thigh');
    P.SetBoneRotation('Bip01 L Calf');
    P.SetBoneRotation('Bip01 R Calf');
    P.SetBoneRotation('Bip01 L Foot');
    P.SetBoneRotation('Bip01 R Foot');
    
    Super.DetachDriver(P);
}

defaultproperties
{

    Drawscale = 1.0

    GunClass = class'UT3HellbenderRearGun'
    CameraBone = MainTurretPitch
    DrivePos=(X=6.500000,Z=55.000000)
    
    FPCamPos=(X=-15.000000)
    
    //Normal
    TPCamDistance=250.000000
    TPCamLookat=(X=0,Y=0,Z=70)
    TPCamWorldOffset=(X=0,Y=0,Z=50)
    
    //Aerial View Mutator Cam Settings
    //TPCamLookAt=(X=-10,Y=0,Z=55)
    //TPCamWorldOffset=(X=0,Y=0,Z=50)
}

