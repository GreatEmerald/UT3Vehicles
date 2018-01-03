/*
 * Copyright © 2008-2009 Wormbo
 * Copyright © 2008-2009, 2014 GreatEmerald
 * Copyright © 2012, 2017 Luís 'zeluisping' Guimarães <zeluis.100@gmail.com>
 * Copyright © 2017-2018 HellDragon-HK
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

/* NOTE: (by zeluisping)
 * To increase the ground speed increase the radius of the
 * wheels. And make the BoneOffset's z component equal to
 * (WheelRadius - 30).
 *
 * The real radius of the wheels is 30.
 */

class UT3Paladin extends ONSShockTank;

#exec obj load file=../Animations/UT3PaladinAnims.ukx
#exec obj load file=../Textures/UT3PaladinTex.utx
#exec obj load file=../Sounds/UT3A_Vehicle_Paladin.uax

simulated function TeamChanged()
{
    local int i;

    Super.TeamChanged();

    if (Level.NetMode != NM_DedicatedServer)
    {
        for(i = 0; i < HeadlightCorona.Length; i++)
        {
            HeadlightCorona[i].LightSaturation = 0;
            if (Team == 0)
                HeadlightCorona[i].LightHue = 0;
            if (Team == 1)
                HeadlightCorona[i].LightHue = 175;
        }
    }
}

//=============================================================================
// Default values
//=============================================================================
defaultproperties
{

    Drawscale = 1.0 //Ensure default scale and not be overriden by stock classes

    Mesh=SkeletalMesh'UT3PaladinAnims.Paladin';
    RedSkin=Shader'UT3PaladinTex.Paladin.PaladinSkin';
    BlueSkin=Shader'UT3PaladinTex.Paladin.PaladinSkinBlue';

    DriverWeapons(0)=(WeaponClass=class'UT3PaladinCannon',WeaponBone="Turret_Yaw");

    VehiclePositionString="in a UT3 Paladin";
    SteerBoneName="Body"

    // Sound.
    IdleSound=Sound'UT3A_Vehicle_Paladin.Sounds.A_Vehicle_Paladin_EngineLoop01';
    StartUpSound=Sound'UT3A_Vehicle_Paladin.Sounds.A_Vehicle_Paladin_Start01';
    ShutDownSound=Sound'UT3A_Vehicle_Paladin.Sounds.A_Vehicle_Paladin_Stop01';
    DamagedEffectHealthSmokeFactor=0.65 //0.5
    DamagedEffectHealthFireFactor=0.40 //0.25
    DamagedEffectFireDamagePerSec=2.00 //0.75
    ExplosionSounds=()
    ExplosionSounds(0)=Sound'UT3A_Vehicle_Paladin.Sounds.A_Vehicle_Paladin_Explode02;
    ImpactDamageSounds=()
    ImpactDamageSounds(0)=Sound'UT3A_Vehicle_Paladin.Sounds.A_Vehicle_Paladin_Collide01';

    //HornSounds(0)=sound'ONSBPSounds.ShockTank.PaladinHorn'
    //HornSounds(1)=sound'ONSVehicleSounds-S.Dixie_Horn'

    BaseEyeheight=40;
    Eyeheight=40;

    Begin Object Class=SVehicleWheel Name=RWheel1
        BoneName="RtTire01";
        SupportBoneName="RtSuspension01";
        BoneOffset=(X=0.0,Y=35,Z=13.0);
        SuspensionTravel=60.0;
        bPoweredWheel=true;
        WheelRadius=60;

        BoneRollAxis=AXIS_Y
        BoneSteerAxis=AXIS_Z
        SupportBoneAxis=AXIS_X
        SteerType=VST_Steered
    End Object
    Begin Object Class=SVehicleWheel Name=RWheel2
        BoneName="RtTire02";
        SupportBoneName="RtSuspension02";
        BoneOffset=(X=0.0,Y=35.0,Z=13.0);
        SuspensionTravel=60.0;
        bPoweredWheel=true;
        WheelRadius=60;

        BoneRollAxis=AXIS_Y
        BoneSteerAxis=AXIS_Z
        SupportBoneAxis=AXIS_X
        SteerType=VST_Steered
    End Object
    Begin Object Class=SVehicleWheel Name=RWheel3
        BoneName="RtTire03";
        SupportBoneName="RtSuspension03";
        BoneOffset=(X=0.0,Y=35.0,Z=13.0);
        SuspensionTravel=60.0;
        bPoweredWheel=true;
        WheelRadius=60;

        BoneRollAxis=AXIS_Y
        BoneSteerAxis=AXIS_Z
        SupportBoneAxis=AXIS_X
        SteerType=VST_Inverted
    End Object
    Begin Object Class=SVehicleWheel Name=RWheel4
        BoneName="RtTire04";
        SupportBoneName="RtSuspension04";
        BoneOffset=(X=0.0,Y=35.0,Z=13.0);
        SuspensionTravel=60.0;
        bPoweredWheel=true;
        WheelRadius=60;

        BoneRollAxis=AXIS_Y
        BoneSteerAxis=AXIS_Z
        SupportBoneAxis=AXIS_X
        SteerType=VST_Inverted
    End Object
    Begin Object Class=SVehicleWheel Name=LWheel1
        BoneName="LtTire01";
        SupportBoneName="LtSuspension01";
        BoneOffset=(X=0.0,Y=-35.0,Z=13.0);
        SuspensionTravel=60.0;
        bPoweredWheel=true;
        WheelRadius=60;

        BoneRollAxis=AXIS_Y
        BoneSteerAxis=AXIS_Z
        SupportBoneAxis=AXIS_X
        SteerType=VST_Steered
    End Object
    Begin Object Class=SVehicleWheel Name=LWheel2
        BoneName="LtTire02";
        SupportBoneName="LtSuspension02";
        BoneOffset=(X=0.0,Y=-35.0,Z=13.0);
        SuspensionTravel=60.0;
        bPoweredWheel=true;
        WheelRadius=60;

        BoneRollAxis=AXIS_Y
        BoneSteerAxis=AXIS_Z
        SupportBoneAxis=AXIS_X
        SteerType=VST_Steered
    End Object
    Begin Object Class=SVehicleWheel Name=LWheel3
        BoneName="LtTire03";
        SupportBoneName="LtSuspension03";
        BoneOffset=(X=0.0,Y=-35.0,Z=13.0)
        SuspensionTravel=60.0;
        bPoweredWheel=true;
        WheelRadius=60;

        BoneRollAxis=AXIS_Y
        BoneSteerAxis=AXIS_Z
        SupportBoneAxis=AXIS_X
        SteerType=VST_Inverted
    End Object
    Begin Object Class=SVehicleWheel Name=LWheel4
        BoneName="LtTire04";
        SupportBoneName="LtSuspension04";
        BoneOffset=(X=0.0,Y=-35.0,Z=13.0);
        SuspensionTravel=60.0;
        bPoweredWheel=true;
        WheelRadius=60;

        BoneRollAxis=AXIS_Y
        BoneSteerAxis=AXIS_Z
        SupportBoneAxis=AXIS_X
        SteerType=VST_Inverted
    End Object
    Wheels(0)=RWheel1;
    Wheels(1)=RWheel2;
    Wheels(2)=RWheel3;
    Wheels(3)=RWheel4;
    Wheels(4)=LWheel1;
    Wheels(5)=LWheel2;
    Wheels(6)=LWheel3;
    Wheels(7)=LWheel4;

    VehicleNameString="UT3 Paladin"   //GE: UT3 Paladin...
    ImpactDamageMult=0.0003
    SteerSpeed=82                       // Is steered more easily
    ChassisTorqueScale=0.18             // Has a lower... setting of some kind
    MinBrakeFriction=4.2
    MaxBrakeTorque=75.000000            // And another, but this time higher
    MaxSteerAngleCurve=(Points=((OutVal=20.000000),(InVal=700.000000,OutVal=15.000000))) // Again, steered more easily
    //EngineBrakeFactor=0.100000        // This makes it extremely easy to flip and have an accident
    WheelInertia=0.750000               // Has more inertia
    WheelSuspensionOffset=3.0
    
    GroundSpeed=700.000000              //Is faster, GroundSpeed == deprecated?
    //DriverWeapons(0)=(WeaponClass=class'UT3PaladinCannon',WeaponBone=CannonAttach); // Has a better shield
    
    TurnDamping=25     //35
    TransRatio=0.030    //0.03
    ChangeUpPoint=2600 //2000
    
    MomentumMult=0.1 //0.8
    
    Begin Object Class=KarmaParamsRBFull Name=KParams0
        KStartEnabled=True
        KFriction=0.5
        KLinearDamping=0.05
        KAngularDamping=0.05
        KImpactThreshold=700
        KMaxSpeed=1200
        bKNonSphericalInertia=True
        bHighDetailOnly=False
        bClientOnly=False
        bKDoubleTickRate=True
        KInertiaTensor(0)=1.0
        KInertiaTensor(1)=0.0
        KInertiaTensor(2)=0.0
        KInertiaTensor(3)=3.0
        KInertiaTensor(4)=0.0
        KInertiaTensor(5)=3.0
        KCOMOffset=(X=-0.25,Y=0.0,Z=-1.35)
        bDestroyOnWorldPenetrate=True
        bDoSafetime=True
        Name="KParams0"
    End Object
    KParams=KarmaParams'KParams0'
    
    EntryPosition=(X=20,Y=0,Z=0)
    EntryRadius=350.0
    
    ExitPositions(0)=(X=0,Y=-260,Z=50)
    ExitPositions(1)=(X=0,Y=260,Z=50)
    ExitPositions(2)=(X=0,Y=-260,Z=-50)
    ExitPositions(3)=(X=0,Y=260,Z=-50)
    ExitPositions(4)=(X=90,Y=0,Z=160)
    
    FPCamPos = (X=-55,Y=0,Z=170);
    FPCamViewOffset = (X=0,Y=0,Z=0);
    
    TPCamWorldOffset = (X=0,Y=0,Z=220); //280+ aiming up without clipping but ground level aim feels awkward
    TPCamDistance = 575;

    //Aerial View
    //TPCamWorldOffset = (X=0,Y=0,Z=200);
    
    HeadlightCoronaOffset=()
    HeadlightCoronaOffset(0)=(X=290.0,Y=47,Z=58.0)
    HeadlightCoronaMaterial=Material'EpicParticles.FlashFlare1'
    //HeadlightCoronaMaterial=Material'EmitterTextures.Flares.EFlareOY'
    HeadlightCoronaMaxSize=92
    
    HeadlightProjectorOffset=(X=290,Y=10,Z=58.0)
    HeadlightProjectorRotation=(Yaw=0,Pitch=-1000,Roll=0)
    HeadlightProjectorMaterial=Texture'VMVehicles-TX.NewPRVGroup.PRVProjector'
    HeadlightProjectorScale=0.05
    
}
