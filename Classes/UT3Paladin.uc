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

/* NOTE: (by 100GPing100)
 * To increase the ground speed increase the radius of the
 * wheels. And make the BoneOffset's z component equal to
 * (WheelRadius - 30).
 *
 * The real radius of the wheels is 30.
 */

class UT3Paladin extends ONSShockTank;

//===============
// @100GPing100
#exec obj load file=../Animations/UT3PaladinAnims.ukx
#exec obj load file=../Textures/UT3PaladinTex.utx
// @100GPing100
//======END======


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
    //===============
    // @100GPing100
    Mesh = SkeletalMesh'UT3PaladinAnims.Paladin';
    RedSkin = Shader'UT3PaladinTex.Paladin.PaladinSkin';
    BlueSkin = Shader'UT3PaladinTex.Paladin.PaladinSkinBlue';

    DriverWeapons(0)=(WeaponClass=class'UT3PaladinCannon',WeaponBone="Turret_Yaw");

    FPCamPos = (X=-30,Y=0,Z=120);
    FPCamViewOffset = (X=-100,Y=0,Z=0);
    TPCamWorldOffset = (X=0,Y=0,Z=200);
    TPCamDistance = 575;

    VehiclePositionString = "in a UT3 Paladin";
    SteerBoneName="Body"

    // Sound.
    IdleSound = Sound'UT3A_Vehicle_Paladin.Sounds.A_Vehicle_Paladin_EngineLoop01';
    StartUpSound = Sound'UT3A_Vehicle_Paladin.Sounds.A_Vehicle_Paladin_Start01';
    ShutDownSound = Sound'UT3A_Vehicle_Paladin.Sounds.A_Vehicle_Paladin_Stop01';
    DamagedEffectHealthSmokeFactor=0.65 //0.5
	DamagedEffectHealthFireFactor=0.37 //0.25
	DamagedEffectFireDamagePerSec=0.95 //0.75
    ExplosionSounds(0) = Sound'UT3A_Vehicle_Paladin.Sounds.A_Vehicle_Paladin_Explode01';
    ExplosionSounds(1) = Sound'UT3A_Vehicle_Paladin.Sounds.A_Vehicle_Paladin_Explode02';
    ExplosionSounds(2) = Sound'UT3A_Vehicle_Paladin.Sounds.A_Vehicle_Paladin_Explode01';
    ExplosionSounds(3) = Sound'UT3A_Vehicle_Paladin.Sounds.A_Vehicle_Paladin_Explode02';
    ExplosionSounds(4) = Sound'UT3A_Vehicle_Paladin.Sounds.A_Vehicle_Paladin_Explode01';
    ImpactDamageSounds(0) = Sound'UT3A_Vehicle_Paladin.Sounds.A_Vehicle_Paladin_Collide01';
    ImpactDamageSounds(1) = Sound'UT3A_Vehicle_Paladin.Sounds.A_Vehicle_Paladin_Collide01';
    ImpactDamageSounds(2) = Sound'UT3A_Vehicle_Paladin.Sounds.A_Vehicle_Paladin_Collide01';
    ImpactDamageSounds(3) = Sound'UT3A_Vehicle_Paladin.Sounds.A_Vehicle_Paladin_Collide01';
    ImpactDamageSounds(4) = Sound'UT3A_Vehicle_Paladin.Sounds.A_Vehicle_Paladin_Collide01';
    ImpactDamageSounds(5) = Sound'UT3A_Vehicle_Paladin.Sounds.A_Vehicle_Paladin_Collide01';
    ImpactDamageSounds(6) = Sound'UT3A_Vehicle_Paladin.Sounds.A_Vehicle_Paladin_Collide01';

    //HornSounds(0)=sound'ONSBPSounds.ShockTank.PaladinHorn'
    //HornSounds(1)=sound'ONSVehicleSounds-S.Dixie_Horn'

    BaseEyeheight = 40;
    Eyeheight = 40;

    Begin Object Class=SVehicleWheel Name=RWheel1
        BoneName = "RtTire01";
        SupportBoneName = "RtSuspension01";
        BoneOffset = (X=0.0,Y=35,Z=30.0);
        SuspensionTravel = 60.0;
        bPoweredWheel = true;
        WheelRadius = 60;

        BoneRollAxis=AXIS_Y
        BoneSteerAxis=AXIS_Z
        SupportBoneAxis=AXIS_X
        SteerType=VST_Steered
    End Object
    Begin Object Class=SVehicleWheel Name=RWheel2
        BoneName = "RtTire02";
        SupportBoneName = "RtSuspension02";
        BoneOffset = (X=0.0,Y=35.0,Z=30.0);
        SuspensionTravel = 60.0;
        bPoweredWheel = true;
        WheelRadius = 60;

        BoneRollAxis=AXIS_Y
        BoneSteerAxis=AXIS_Z
        SupportBoneAxis=AXIS_X
        SteerType=VST_Fixed
    End Object
    Begin Object Class=SVehicleWheel Name=RWheel3
        BoneName = "RtTire03";
        SupportBoneName = "RtSuspension03";
        BoneOffset = (X=0.0,Y=35.0,Z=30.0);
        SuspensionTravel = 60.0;
        bPoweredWheel = true;
        WheelRadius = 60;

        BoneRollAxis=AXIS_Y
        BoneSteerAxis=AXIS_Z
        SupportBoneAxis=AXIS_X
        SteerType=VST_Fixed
    End Object
    Begin Object Class=SVehicleWheel Name=RWheel4
        BoneName = "RtTire04";
        SupportBoneName = "RtSuspension04";
        BoneOffset = (X=0.0,Y=35.0,Z=30.0);
        SuspensionTravel = 60.0;
        bPoweredWheel = true;
        WheelRadius = 60;

        BoneRollAxis=AXIS_Y
        BoneSteerAxis=AXIS_Z
        SupportBoneAxis=AXIS_X
        SteerType=VST_Inverted
    End Object
    Begin Object Class=SVehicleWheel Name=LWheel1
        BoneName = "LtTire01";
        SupportBoneName = "LtSuspension01";
        BoneOffset = (X=0.0,Y=-35.0,Z=30.0);
        SuspensionTravel = 60.0;
        bPoweredWheel = true;
        WheelRadius = 60;

        BoneRollAxis=AXIS_Y
        BoneSteerAxis=AXIS_Z
        SupportBoneAxis=AXIS_X
        SteerType=VST_Steered
    End Object
    Begin Object Class=SVehicleWheel Name=LWheel2
        BoneName = "LtTire02";
        SupportBoneName = "LtSuspension02";
        BoneOffset = (X=0.0,Y=-35.0,Z=30.0);
        SuspensionTravel = 60.0;
        bPoweredWheel = true;
        WheelRadius = 60;

        BoneRollAxis=AXIS_Y
        BoneSteerAxis=AXIS_Z
        SupportBoneAxis=AXIS_X
        SteerType=VST_Fixed
    End Object
    Begin Object Class=SVehicleWheel Name=LWheel3
        BoneName = "LtTire03";
        SupportBoneName = "LtSuspension03";
        BoneOffset=(X=0.0,Y=-35.0,Z=30.0)
        SuspensionTravel = 60.0;
        bPoweredWheel = true;
        WheelRadius = 60;

        BoneRollAxis=AXIS_Y
        BoneSteerAxis=AXIS_Z
        SupportBoneAxis=AXIS_X
        SteerType=VST_Fixed
    End Object
    Begin Object Class=SVehicleWheel Name=LWheel4
        BoneName = "LtTire04";
        SupportBoneName = "LtSuspension04";
        BoneOffset = (X=0.0,Y=-35.0,Z=30.0);
        SuspensionTravel = 60.0;
        bPoweredWheel = true;
        WheelRadius = 60;

        BoneRollAxis=AXIS_Y
        BoneSteerAxis=AXIS_Z
        SupportBoneAxis=AXIS_X
        SteerType=VST_Inverted
    End Object
    Wheels(0) = RWheel1;
    Wheels(1) = RWheel2;
    Wheels(2) = RWheel3;
    Wheels(3) = RWheel4;
    Wheels(4) = LWheel1;
    Wheels(5) = LWheel2;
    Wheels(6) = LWheel3;
    Wheels(7) = LWheel4;
    // @100GPing100
    //======END======

    VehicleNameString = "UT3 Paladin" //GE: UT3 Paladin...
    SteerSpeed=90                     //Is steered more easily
    ChassisTorqueScale=0.1            //Has a lower... setting of some kind
    MaxBrakeTorque=75.000000          //And another, but this time higher
    MaxSteerAngleCurve=(Points=((OutVal=20.000000),(InVal=700.000000,OutVal=15.000000)))//Again steered more easily
    //EngineBrakeFactor=0.100000       //This makes it extremely easy to flip and have an accident
    WheelInertia=0.750000             //Has more inertia
    //GroundSpeed=1000.000000           //Is faster, GroundSpeed == deprecated?
    //DriverWeapons(0)=(WeaponClass=class'UT3PaladinCannon',WeaponBone=CannonAttach);//Has a better shield
}
