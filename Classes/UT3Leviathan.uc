/*
 * Copyright © 2007, 2009 Wormbo
 * Copyright © 2007, 2009, 2014 GreatEmerald
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

class UT3Leviathan extends ONSMobileAssaultStation;


//=============================================================================
// Variables
//=============================================================================


state UnDeploying
{
Begin:
    if (Controller != None)
    {
        if (PlayerController(Controller) != None)
        {
            PlayerController(Controller).ClientPlaySound(HideSound);
            if (PlayerController(Controller).bEnableGUIForceFeedback)
                PlayerController(Controller).ClientPlayForceFeedback(HideForce);
        }
        Weapons[1].bForceCenterAim = True;
        Weapons[1].PlayAnim('UnDeploying');
        PlayAnim('UnDeploying');
        Sleep(8.333333);
        bMovable = True;
        SetPhysics(PHYS_Karma);
        ServerPhysics = PHYS_Karma;
        bStationary = False;
        SetActiveWeapon(0);
        TPCamLookat = UnDeployedTPCamLookat;
        TPCamWorldOffset = UnDeployedTPCamWorldOffset;
        FPCamPos = UnDeployedFPCamPos;
        bEnableProximityViewShake = True;
        bDeployed = False;
        GotoState('UnDeployed');
    }
}

state Deploying
{
Begin:
    if (Controller != None)
    {
        SetPhysics(PHYS_None);
        ServerPhysics = PHYS_None;
        bMovable = False;
        bStationary = True;
        if (PlayerController(Controller) != None)
        {
            PlayerController(Controller).ClientPlaySound(DeploySound);
            if (PlayerController(Controller).bEnableGUIForceFeedback)
                PlayerController(Controller).ClientPlayForceFeedback(DeployForce);
        }
        PlayAnim('Deploying');
        Weapons[1].PlayAnim('Deploying');
        Sleep(6.666666);
        Weapons[1].bForceCenterAim = False;
        SetActiveWeapon(1);
        bWeaponisFiring = false; //so bots don't immediately fire until the gun has a chance to move
        TPCamLookat = DeployedTPCamLookat;
        TPCamWorldOffset = DeployedTPCamWorldOffset;
        FPCamPos = DeployedFPCamPos;
        bEnableProximityViewShake = False;
        bDeployed = True;
        GotoState('Deployed');
    }
}

//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
    VehicleNameString = "UT3 Leviathan"

    Health = 6500

    DriverWeapons(0) = (WeaponClass=class'UT3LeviathanDriverWeapon',WeaponBone="DriverTurretYaw")
    DriverWeapons(1)=(WeaponClass=class'UT3LeviathanPrimaryWeapon',WeaponBone="Base");

    PassengerWeapons(0) = (WeaponPawnClass=class'UT3LeviathanTurretBeam',WeaponBone="RT_Front_TurretYaw")
    PassengerWeapons(1) = (WeaponPawnClass=class'UT3LeviathanTurretRocket',WeaponBone="LT_Front_TurretYaw")
    PassengerWeapons(2) = (WeaponPawnClass=class'UT3LeviathanTurretStinger',WeaponBone="LT_Rear_TurretYaw")
    PassengerWeapons(3) = (WeaponPawnClass=class'UT3LeviathanTurretShock',WeaponBone="RT_Rear_TurretYaw")

    CollisionHeight=100.0
    LSDFactor=1.000000
    ChassisTorqueScale=0.200000
    MaxSteerAngleCurve=(Points=((OutVal=30.000000),(InVal=1500.000000,OutVal=20.000000)))
    SteerSpeed=50.000000
    //EngineBrakeFactor=0.020000
    MaxBrakeTorque=8.000000
    //StopThreshold=500.000000

    Mesh = SkeletalMesh'UT3VH_Leviathan_Anims.SK_VH_Leviathan'
    // GEm: TODO: Two skins!
    RedSkin = Shader'UT3LeviathanTex.Levi1.LeviathanSkin1'
    BlueSkin = Shader'UT3LeviathanTex.Levi1.LeviathanSkin1Blue'

    // GEm: The Leviathan is insane. It has 5 wheels. 5.
        Begin Object Class=SVehicleWheel Name=RtRWheel
        BoneName="Rt_Rear_Tire"
        BoneOffset=(X=0.0,Y=40.0,Z=0.0)
        WheelRadius=90
        SuspensionTravel=40
        bPoweredWheel=true
        //SteerFactor=0.0
        //LongSlipFactor=12000
        SteerType=VST_Fixed
        BoneRollAxis=AXIS_Y
        BoneSteerAxis=AXIS_Z
    End Object
    Wheels(0) = SVehicleWheel'RtRWheel'

    Begin Object Class=SVehicleWheel Name=LtRWheel
        BoneName="Lt_Rear_Tire"
        BoneOffset=(X=0.0,Y=-40.0,Z=0)
        WheelRadius=90
        SuspensionTravel=40
        bPoweredWheel=true
        //SteerFactor=0.0
        //LongSlipFactor=12000
        SteerType=VST_Fixed
        BoneRollAxis=AXIS_Y
        BoneSteerAxis=AXIS_Z
    End Object
    Wheels(1) = SVehicleWheel'LtRWheel'

    Begin Object Class=SVehicleWheel Name=RtMWheel
        BoneName="Rt_Mid_Tire"
        BoneOffset=(X=0.0,Y=40.0,Z=0)
        WheelRadius=90
        SuspensionTravel=40
        bPoweredWheel=true
        //SteerFactor=0.0
        //LongSlipFactor=12000
        SteerType=VST_Fixed
        BoneRollAxis=AXIS_Y
        BoneSteerAxis=AXIS_Z
    End Object
    Wheels(2) = SVehicleWheel'RtMWheel'

    Begin Object Class=SVehicleWheel Name=LtMWheel
        BoneName="Lt_Mid_Tire"
        BoneOffset=(X=0.0,Y=-40.0,Z=0)
        WheelRadius=90
        SuspensionTravel=40
        bPoweredWheel=true
        //SteerFactor=0.0
        //LongSlipFactor=12000
        SteerType=VST_Fixed
        BoneRollAxis=AXIS_Y
        BoneSteerAxis=AXIS_Z
    End Object
    Wheels(3) = SVehicleWheel'LtMWheel'

    Begin Object Class=SVehicleWheel Name=RtFWheel
        BoneName="Rt_Front_Tire"
        BoneOffset=(X=0.0,Y=130.0,Z=-10.0)
        WheelRadius=100
        SuspensionTravel=40
        bPoweredWheel=true
        //SteerFactor=1.0
        //LongSlipFactor=12000
        SteerType=VST_Steered
        BoneRollAxis=AXIS_Y
        BoneSteerAxis=AXIS_Z
    End Object
    Wheels(4) = SVehicleWheel'RtFWheel'

    Begin Object Class=SVehicleWheel Name=LtFWheel
        BoneName="Lt_Front_Tire"
        BoneOffset=(X=0.0,Y=-130,Z=-10.0)
        WheelRadius=100
        SuspensionTravel=40
        bPoweredWheel=true
        //SteerFactor=1.0
        //LongSlipFactor=12000
        SteerType=VST_Steered
        BoneRollAxis=AXIS_Y
        BoneSteerAxis=AXIS_Z
    End Object
    Wheels(5) = SVehicleWheel'LtFWheel'

    /*Begin Object Class=SVehicleWheel Name=CenterWheel //fake wheel to help prevent getting stuck
        BoneName="Body"
        BoneOffset=(X=-30.0,Y=0.0,Z=-50.0)
        WheelRadius=75
        SuspensionTravel=200
        bPoweredWheel=true
        //SteerFactor=0.0
        //LongSlipFactor=12000
        SteerType=VST_Fixed
    End Object
    Wheels(6) = SVehicleWheel'CenterWheel'*/

    DeploySound = Sound'UT3A_Vehicle_Leviathan.Sounds.A_Vehicle_Leviathan_Deploy01'
    HideSound = Sound'UT3A_Vehicle_Leviathan.Sounds.A_Vehicle_Leviathan_Deploy01'

    // GEm: TODO: Make use of EngineIdle when not moving
    IdleSound = Sound'UT3A_Vehicle_Leviathan.Sounds.A_Vehicle_Leviathan_EngineMove01'
    StartUpSound = Sound'UT3A_Vehicle_Leviathan.Sounds.A_Vehicle_Leviathan_EngineStart02'
    ShutDownSound = Sound'UT3A_Vehicle_Leviathan.Sounds.A_Vehicle_Leviathan_EngineStop02'
}
