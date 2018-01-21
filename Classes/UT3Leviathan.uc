/*
 * Copyright © 2007, 2009 Wormbo
 * Copyright © 2007, 2009, 2014 GreatEmerald
 * Copyright © 2017-2018 HellDragon
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

var bool bBotDeploy; // delayed bot deploy flag
var float /*LastDeployStartTime,*/ LastDeployCheckTime, LastDeployAttempt;
var bool bDrawCanDeployTooltip;
var() float MaxDeploySpeed;
var IntBox DeployIconCoords;

var float OldWheelPitch[2];

var Material RedSkinB[2], BlueSkinB[2];

replication
{
    reliable if (Role < ROLE_Authority)
        ServerToggleDeploy;
}

simulated function PostBeginPlay()
{
    PlayAnim('InActiveStill', 1.0, 0.0);
    super.PostBeginPlay();
}

simulated function Tick(float DeltaTime)
{
    Super.Tick(DeltaTime);

    if (bBotDeploy || Role == ROLE_Authority && IsHumanControlled() && Rise > 0 && Level.TimeSeconds - LastDeployAttempt > 0.1)
    {
        if (bBotDeploy)
        {
            Throttle = 0;
            Steering = 0;
            Rise = 1; // handbrake to quickly slow down
        }
        ServerToggleDeploy();
        /*if (bBotDeploy && LastDeployStartTime == Level.TimeSeconds)
        {
            bBotDeploy = False;
            Rise = 0;
        }*/
        LastDeployAttempt = Level.TimeSeconds;
    }
    if (IsLocallyControlled() && IsHumanControlled() && Level.TimeSeconds - LastDeployCheckTime > 0.25)
    {
        // check if can be deployed
        bDrawCanDeployTooltip = IsInState('Undeployed') && Driver != None && CanDeploy(True);
        LastDeployCheckTime = Level.TimeSeconds;
    }
    if (Level.NetMode != NM_DedicatedServer && IsInState('Undeployed'))
    {
        // GEm: Stop wheels from rotating
        FixFenderRotation('Rt_Front_Foot', 'Rt_Front_Tire', 0);
        FixFenderRotation('Lt_Front_Foot', 'Lt_Front_Tire', 1);
    }
}

simulated function FixFenderRotation(name BoneToSet, name BoneToCopy, byte i)
{
    local rotator NewRotation;

    // GEm: Still acts weirdly, unfortunately (like the SPMA)
    NewRotation = GetBoneRotation(BoneToSet);
    NewRotation.Pitch = OldWheelPitch[i]-NewRotation.Pitch;
    NewRotation.Roll = 32768;
    NewRotation.Yaw = 32768;
    SetBoneRotation(BoneToSet, NewRotation);
    OldWheelPitch[i] = NewRotation.Pitch;
}

function ServerToggleDeploy()
{
    if (CanDeploy())
    {
        bBotDeploy = false;
        Rise = 0;
        GotoState('Deploying');
    }
    else if (IsHumanControlled())
    {
        bBotDeploy = false;
        Rise = 0;
    }
}

simulated function bool CanDeploy(optional bool bNoMessage)
{
    local int i;
    local bool bOneUnstable;

    if (VSize(Velocity) > MaxDeploySpeed)
    {
        if (!bNoMessage && PlayerController(Controller) != None)
            PlayerController(Controller).ReceiveLocalizedMessage(class'UT3DeployMessage', 0);
        return false;
    }

    if (IsFiring())
        return false;

    Rise = 0;
    for (i = 0; i < Wheels.Length; i++)
    {
        if (!Wheels[i].bWheelOnGround)
        {
            if (!bOneUnstable)
            {
                // ignore if just one of the six wheels is unstable
                bOneUnstable = True;
                continue;
            }
            if (!bNoMessage && PlayerController(Controller) != None)
                PlayerController(Controller).ReceiveLocalizedMessage(class'UT3DeployMessage', 1);
            return false;
        }
    }
    return true;
}

simulated function DrawHUD(Canvas C)
{
    local PlayerController PC;

    Super.DrawHUD(C);

    // don't draw if we are dead, scoreboard is visible, etc
    PC = PlayerController(Controller);
    if (Health < 1 || PC == None || PC.myHUD == None || PC.MyHUD.bShowScoreboard || !IsInState('Undeployed'))
        return;

    // draw deploy tooltip
    if (bDrawCanDeployTooltip)
        class'UT3HudOverlay'.static.DrawToolTip(C, PC, "Jump", C.ClipX * 0.5, C.ClipY * 0.92, DeployIconCoords);
}

// GEm: Disable beeping on alt fire (beep on rise instead)
function VehicleFire(bool bWasAltFire)
{
    Super(ONSWheeledCraft).VehicleFire(bWasAltFire);
}

// GEm: Enable zooming on alt fire
function AltFire(optional float F)
{
    local PlayerController PC;

    PC = PlayerController(Controller);
    if (PC == None)
        return;

    bWeaponIsAltFiring = true;
    PC.ToggleZoomWithMax(0.5);
}

function ClientVehicleCeaseFire(bool bWasAltFire)
{
    local PlayerController PC;

    if (!bWasAltFire)
    {
        Super.ClientVehicleCeaseFire(bWasAltFire);
        return;
    }

    PC = PlayerController(Controller);
    if (PC == None)
        return;

    bWeaponIsAltFiring = false;
    PC.StopZoom();
}

simulated function ClientKDriverLeave(PlayerController PC)
{
    Super.ClientKDriverLeave(PC);

    bWeaponIsAltFiring = false;
    PC.EndZoom();
}

auto state UnDeployed
{
    function Deploy()
    {
        bBotDeploy = true;
    }

    function ChooseFireAt(Actor A)
    {
        local Bot B;

        B = Bot(Controller);
        if ( B == None || B.Squad == None || ONSPowerCore(B.Squad.SquadObjective) == None )
        {
            Fire(0);
            return;
        }

        if (ONSPowerCore(B.Squad.SquadObjective).LegitimateTargetOf(B) && CanAttack(B.Squad.SquadObjective))
            bBotDeploy = true;
        else
            Fire(0);
    }

    function VehicleFire(bool bWasAltFire)
    {
        if (!bWasAltFire)
            bWeaponIsFiring = True;
    }
}

state Deploying
{
    ignores ServerToggleDeploy, Fire;

Begin:
    if (Controller != None)
    {
        //LastDeployStartTime = Level.TimeSeconds;
        StopWeaponFiring();
        SetPhysics(PHYS_None);
        ServerPhysics = PHYS_None;
        bMovable = False;
        bStationary = True;
        PlaySound(DeploySound, SLOT_None, TransientSoundVolume*3.0,, TransientSoundRadius/2.0,, false);
        if (PlayerController(Controller) != None)
        {
            if (PlayerController(Controller).bEnableGUIForceFeedback)
                PlayerController(Controller).ClientPlayForceFeedback(DeployForce);
        }
        PlayAnim('Deploying');
        Weapons[1].PlayAnim('Deploying');
        Sleep(8.333333);
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

state Deployed
{
    function MayUndeploy()
    {
        ServerToggleDeploy();
    }

    function ServerToggleDeploy()
    {
        if (!bWeaponIsFiring && !UT3LeviathanPrimaryWeapon(Weapons[1]).bCurrentlyFiring)
            GotoState('Undeploying');
    }

    function bool IsDeployed()
    {
        return true;
    }

    function VehicleFire(bool bWasAltFire)
    {
        if (!bWasAltFire)
            bWeaponIsFiring = True;
    }
}

state UnDeploying
{
    ignores ServerToggleDeploy, Fire;

Begin:
    if (Controller != None)
    {
        //LastDeployStartTime = Level.TimeSeconds;
        StopWeaponFiring();
        PlaySound(HideSound, SLOT_None, TransientSoundVolume*3.0,, TransientSoundRadius/2.0,, false);
        if (PlayerController(Controller) != None)
        {
            if (PlayerController(Controller).bEnableGUIForceFeedback)
                PlayerController(Controller).ClientPlayForceFeedback(HideForce);
        }
        Weapons[1].bForceCenterAim = True;
        Weapons[1].PlayAnim('UnDeploying');
        PlayAnim('UnDeploying');
        Sleep(6.666666);
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

simulated event TeamChanged()
{
    local int i;

    Super(SVehicle).TeamChanged();

    if (Team == 0 && RedSkin != None)
    {
        Skins[0] = RedSkin;
        Skins[1] = RedSkinB[0];
        Skins[2] = RedSkinB[1];
        Skins[3] = RedSkinB[1];
        Skins[4] = RedSkinB[1];
        Skins[5] = RedSkinB[1];
    }
    else if (Team == 1 && BlueSkin != None)
    {
        Skins[0] = BlueSkin;
        Skins[1] = BlueSkinB[0];
        Skins[2] = BlueSkinB[1];
        Skins[3] = BlueSkinB[1];
        Skins[4] = BlueSkinB[1];
        Skins[5] = BlueSkinB[1];
    }

    if (Level.NetMode != NM_DedicatedServer && Team <= 2 && SpawnOverlay[0] != None && SpawnOverlay[1] != None)
        SetOverlayMaterial(SpawnOverlay[Team], 1.5, True);

    for (i = 0; i < Weapons.Length; i++)
        Weapons[i].SetTeam(Team);

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
    VehicleNameString = "UT3 Leviathan"

    Health = 6500
    HealthMax = 6500

    DriverWeapons(0) = (WeaponClass=class'UT3LeviathanDriverWeapon',WeaponBone="DriverTurretYaw")
    DriverWeapons(1)=(WeaponClass=class'UT3LeviathanPrimaryWeapon',WeaponBone="Base");

    PassengerWeapons(0) = (WeaponPawnClass=class'UT3LeviathanTurretBeam',WeaponBone="LT_Front_TurretYaw")
    PassengerWeapons(1) = (WeaponPawnClass=class'UT3LeviathanTurretRocket',WeaponBone="RT_Front_TurretYaw")
    PassengerWeapons(2) = (WeaponPawnClass=class'UT3LeviathanTurretStinger',WeaponBone="LT_Rear_TurretYaw")
    PassengerWeapons(3) = (WeaponPawnClass=class'UT3LeviathanTurretShock',WeaponBone="RT_Rear_TurretYaw")

    CollisionHeight=100.0
    GroundSpeed=600
    LSDFactor=1.000000
    ChassisTorqueScale=0.200000
    MaxSteerAngleCurve=(Points=((OutVal=30.000000),(InVal=1500.000000,OutVal=20.000000)))
    SteerSpeed=50.000000
    //EngineBrakeFactor=0.020000
    MaxBrakeTorque=8.000000
    //StopThreshold=500.000000
    WheelSuspensionOffset=25.0

    Begin Object Class=KarmaParamsRBFull Name=KParams0
        KStartEnabled=True
        KFriction=0.5
        KLinearDamping=0.05
        KAngularDamping=0.05
        KImpactThreshold=500
        bKNonSphericalInertia=True
        bHighDetailOnly=False
        bClientOnly=False
        bKDoubleTickRate=True
        KInertiaTensor(0)=1.260000
        KInertiaTensor(1)=0
        KInertiaTensor(2)=0
        KInertiaTensor(3)=3.099998
        KInertiaTensor(4)=0
        KInertiaTensor(5)=4.499996
        KMaxSpeed=850.0 //UT2004 def 650
        KCOMOffset=(X=0,Y=0,Z=0)
        bDestroyOnWorldPenetrate=True
        bDoSafetime=True
        Name="KParams0"
    End Object
    KParams=KarmaParams'KParams0'

    Mesh = SkeletalMesh'UT3VH_Leviathan_Anims.SK_VH_Leviathan'
    // GEm: TODO: Two skins!
    RedSkin = Shader'UT3LeviathanTex.Levi1.LeviathanSkin1'
    BlueSkin = Shader'UT3LeviathanTex.Levi1.LeviathanSkin1Blue'
    RedSkinB(0) = Shader'UT3LeviathanTex.Levi2.LeviathanSkin2'
    BlueSkinB(0) = Shader'UT3LeviathanTex.Levi2.LeviathanSkin2Blue'
    RedSkinB(1) = Shader'UT3LeviathanTex.LeviTurret.TurretSkin'
    BlueSkinB(1) = Shader'UT3LeviathanTex.LeviTurret.TurretSkinBlue'

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
    IdleSound = Sound'UT3A_Vehicle_Leviathan.Sounds.A_Vehicle_Leviathan_EngineIdle'
    StartUpSound = Sound'UT3A_Vehicle_Leviathan.Sounds.A_Vehicle_Leviathan_EngineStart'
    ShutDownSound = Sound'UT3A_Vehicle_Leviathan.Sounds.A_Vehicle_Leviathan_EngineStop'
    ImpactDamageMult = 0.00003 //0.0003
    DamagedEffectHealthSmokeFactor=0.90 //0.5
    DamagedEffectHealthFireFactor=0.80 //0.25
    DamagedEffectFireDamagePerSec=2.0 //0.75
    ImpactDamageSounds = ()
    ImpactDamageSounds(0) = Sound'UT3A_Vehicle_Leviathan.Sounds.A_Vehicle_Leviathan_Collide01'
    ExplosionSounds = ()
    ExplosionSounds(0) = Sound'UT3A_Vehicle_Leviathan.Sounds.A_Vehicle_Leviathan_Explode'

    ExitPositions(0)=(X=90,Y=-330,Z=20)
    ExitPositions(1)=(X=90,Y=330,Z=20)
    ExitPositions(2)=(X=90,Y=-330,Z=-20)
    ExitPositions(3)=(X=90,Y=330,Z=-20)
    ExitPositions(4)=(X=230,Y=-90,Z=280)

    MomentumMult=0.0001

    MaxDeploySpeed = 15.0
    DeployIconCoords = (X1=0,Y1=670,X2=154,Y2=96)

    TPCamDistance=980.000000
    TPCamLookat=(X=0,Y=0,Z=170) //(X=-200,Y=0,Z=300) def UT2004
    UnDeployedTPCamLookat=(X=0,Y=0,Z=170)
    UnDeployedTPCamWorldOffset=(X=0,Y=0,Z=170)
    DeployedTPCamWorldOffset=(X=0,Y=0,Z=500) //(X=0,Y=0,Z=800) def UT2004
    DeployedTPCamLookat=(X=-60,Y=0,Z=0) //(X=100,Y=0,Z=0)
    
    FPCamPos=(X=100,Y=0,Z=330)
    UnDeployedFPCamPos=(X=100,Y=0,Z=330)
    DeployedFPCamPos=(X=-200,Y=0,Z=500)

    //DamagedEffectOffset=(X=280,Y=160,Z=210)   //Front Right Turret Fire Point
    DamagedEffectScale=2.3                    
    //DamagedEffectOffset=(X=-110,Y=-150,Z=150)   //Rear Left Turret Fire Point

    //Custom Alternate Fire Locations Away from Passenger Turrets
    DamagedEffectOffset=(X=210,Y=70,Z=190)     
    //DamagedEffectOffset=(X=-70,Y=-110,Z=150)

    HeadlightCoronaOffset(0)=(X=318,Y=87,Z=212)
    HeadlightCoronaOffset(1)=(X=318,Y=-87,Z=212)
    HeadlightCoronaOffset(2)=(X=318,Y=72.5,Z=212)
    HeadlightCoronaOffset(3)=(X=318,Y=-72.5,Z=212)
    HeadlightCoronaMaterial=Material'EpicParticles.FlashFlare1'
    //HeadlightCoronaMaterial=Material'EmitterTextures.Flares.EFlareOY'
    HeadlightCoronaMaxSize=50
    
    HeadlightProjectorOffset=(X=254.0,Y=0,Z=165)
    HeadlightProjectorRotation=(Yaw=0,Pitch=-1000,Roll=0)
    HeadlightProjectorMaterial=Texture'VMVehicles-TX.RVGroup.RVProjector'
    HeadlightProjectorScale=0.16
    
}
