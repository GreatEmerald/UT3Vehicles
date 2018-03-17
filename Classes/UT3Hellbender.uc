/*
 * Copyright © 2008, 2014, 2017 GreatEmerald
 * Copyright © 2008-2009 Wormbo
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

class UT3Hellbender extends ONSPRV;

var float OldWheelPitch[4];
//var float DebugFloat;

//This is a great example of how to get rid of a passenger seat.

function VehicleFire(bool bWasAltFire) //This is to remove the horn each time you fire
{
    Super(ONSWheeledCraft).VehicleFire(bWasAltFire);
}

function AltFire(optional float F) //This is to remove the horn each time you fire
{
    Super(ONSWheeledCraft).AltFire(F);
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> DamageType)
{                            //Make sure you don't hurt yourself with a combo
    if (InstigatedBy == self && ClassIsChildOf(DamageType, class'DamTypePRVCombo'))
        return;
    Super.TakeDamage(Damage, instigatedBy, Hitlocation, Momentum, damageType);
}

simulated function Tick(float DeltaTime)
{
    Super.Tick(DeltaTime);

    CloneBoneRotation('Rt_Rear_Suspension', 'Rt_Rear_Tire', 0);
    CloneBoneRotation('Lt_Rear_Suspension', 'Lt_Rear_Tire', 1);
    /*DebugFloat += DeltaTime;
    if (DebugFloat > 1.0)
    {
        CloneBoneRotation('Rt_Front_Suspension', 'Rt_Front_Tire', 2, true);
        DebugFloat = 0;
    }
    else*/
    CloneBoneRotation('Rt_Front_Suspension', 'Rt_Front_Tire', 2);
    CloneBoneRotation('Lt_Front_Suspension', 'Lt_Front_Tire', 3);
}

simulated function CloneBoneRotation(name BoneToSet, name BoneToCopy, byte i, optional bool bLog)
{
    local rotator NewRotation;

    NewRotation = GetBoneRotation(BoneToSet);
    NewRotation.Pitch = OldWheelPitch[i]-NewRotation.Pitch;
    NewRotation.Roll = 0;
    NewRotation.Yaw = 0;
    SetBoneRotation(BoneToSet, NewRotation);
    //if (bLog)
    //    Instigator.ClientMessage(self@"CloneBoneRotation:"@GetBoneRotation(BoneToSet));
    OldWheelPitch[i] = NewRotation.Pitch;
}

function DriverLeft()
{
    GoToState('');
    PlayAnim('GetOut', 1.0, 0.1);

    Super.DriverLeft();
}

event PostBeginPlay()
{
    PlayAnim('InActiveIdle', 1.0, 0.0);

    super.PostBeginPlay();
}

event KDriverEnter(Pawn P)
{
    GoToState('Idle');

    super.KDriverEnter(P);
}

simulated state Idle
{
    Begin:
    PlayAnim('GetIn', 1.0, 0.0);
    FinishAnim();
    LoopAnim('Idle', 1.0, 0.0);
}

// GEm: Just for wheel squealing, this disables license plate names too
simulated event DrivingStatusChanged()
{
    local int i;
    local Coords WheelCoords;

    Super(ONSVehicle).DrivingStatusChanged();

    if (bDriving && Level.NetMode != NM_DedicatedServer && !bDropDetail)
    {
        Dust.length = Wheels.length;
        for(i=0; i<Wheels.Length; i++)
            if (Dust[i] == None)
            {
                // Create wheel dust emitters.
                WheelCoords = GetBoneCoords(Wheels[i].BoneName);
                Dust[i] = spawn(class'UT3WheelSlipEffect', self,, WheelCoords.Origin + ((vect(0,0,-1) * Wheels[i].WheelRadius) >> Rotation));
                Dust[i].SetBase(self);
                Dust[i].SetDirtColor( Level.DustColor );
            }

        if(bMakeBrakeLights)
        {
            for(i=0; i<2; i++)
                if (BrakeLight[i] == None)
                {
                    BrakeLight[i] = spawn(class'ONSBrakelightCorona', self,, Location + (BrakeLightOffset[i] >> Rotation) );
                    BrakeLight[i].SetBase(self);
                    BrakeLight[i].SetRelativeRotation( rot(0,32768,0) ); // Point lights backwards.
                    BrakeLight[i].Skins[0] = BrakeLightMaterial;
                }
        }
    }
    else
    {
        if (Level.NetMode != NM_DedicatedServer)
        {
            for(i=0; i<Dust.Length; i++)
                Dust[i].Destroy();

            Dust.Length = 0;

            if(bMakeBrakeLights)
            {
                for(i=0; i<2; i++)
                    if (BrakeLight[i] != None)
                        BrakeLight[i].Destroy();
            }
        }

        TurnDamping = 0.0;
    }
}

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

    //===========================
    // @100GPing100
    //LOOKS RELATED
    Drawscale = 1.0
    
    VehiclePositionString="in a Hellbender"
    VehicleNameString="UT3 Hellbender
    
    Mesh = SkeletalMesh'UT3VH_Hellbender_Anims.SK_VH_Hellbender';
    RedSkin = Shader'UT3HellbenderTex.UT3HellbenderSkinRed';
    BlueSkin = Shader'UT3HellbenderTex.UT3HellbenderSkinBlue';
    
    DriveAnim = "Idle"
    MovementAnims(0) = "Idle"

    CollisionRadius=219 
   
    DriverWeapons(0)=(WeaponClass=Class'UT3HellbenderSideGun',WeaponBone="SecondaryTurretYaw")
    PassengerWeapons=((WeaponPawnClass=Class'UT3HellbenderRearGunPawn',WeaponBone="MainTurretYaw"))
    
    /*GEm: Excellent! So that is a great example of how to get rid of a turret! 
    Turns out that you need one pair of () to show that this is an array,
    and the other pair of () inside the first one to show that this is the one and only element inside it.*/

    FlagBone = Hood;

    DamagedEffectOffset=(X=-35,Y=25,Z=120)  //Behind Driver Turret Fire Point
    DamagedEffectScale=1.2                 //Behind Driver Turret Fire Size
    //DamagedEffectOffset=(X=-60,Y=-65,Z=90)   //Exhaust Pipe Fire Point
    //DamagedEffectScale=0.6                   //Exhaust Pipe Fire Size
    
    HeadlightCoronaOffset(0)=(X=90,Y=34,Z=62)
    HeadlightCoronaOffset(1)=(X=90,Y=-34,Z=62)
    HeadlightCoronaOffset(2)=(X=90,Y=31,Z=49)
    HeadlightCoronaOffset(3)=(X=90,Y=-31,Z=49)
    HeadlightCoronaMaterial=Material'EpicParticles.FlashFlare1'
    HeadlightCoronaMaxSize=120
    
    HeadlightProjectorOffset=(X=90,Y=0,Z=62)
    HeadlightProjectorRotation=(Yaw=0,Pitch=-1000,Roll=0)
    HeadlightProjectorMaterial=Texture'VMVehicles-TX.NewPRVGroup.PRVProjector'
    HeadlightProjectorScale=0.65

    BrakeLightOffset(0)=(X=-165,Y=50,Z=77)
    BrakeLightOffset(1)=(X=-165,Y=-50,Z=77)
    BrakeLightMaterial=Material'EpicParticles.FlashFlare1'
   
    //SOUND RELATED
    IdleSound=Sound'UT3A_Vehicle_Hellbender.UT3HellbenderSingles.UT3HellbenderEngineIdle01Cue'
    StartUpSound=Sound'UT3A_Vehicle_Hellbender.UT3HellbenderEngineStart.UT3HellbenderEngineStartCue'
    ShutDownSound=Sound'UT3A_Vehicle_Hellbender.UT3HellbenderEngineStop.UT3HellbenderEngineStopCue'
    HornSounds(0)=Sound'UT3A_Vehicle_Hellbender.UT3HellbenderSingles.UT3HellbenderHorn01'
    ImpactDamageSounds=()
    ImpactDamageSounds(0) = Sound'UT3A_Vehicle_Hellbender.UT3HellbenderCollide.UT3HellbenderCollideCue';
    ExplosionSounds=()
    ExplosionSounds(0) = Sound'UT3A_Vehicle_Hellbender.UT3HellbenderExplode.UT3HellbenderExplodeCue';
    BulletSounds = ()
    BulletSounds(0) = Sound'UT3A_Weapon_BulletImpacts.UT3BulletImpactMetal.UT3BulletImpactMetalCue'
    IdleRPM=2000
    SoundVolume=255
    
    //DAMAGE RELATED
    DamagedEffectHealthSmokeFactor=0.65 //0.5
    DamagedEffectHealthFireFactor=0.40 //0.25
    DamagedEffectFireDamagePerSec=2.0 //0.75
   
    DriverDamageMult=0.000000
    ImpactDamageMult = 0.00005
    MomentumMult=0.400000 //1.0  //HDm to GE: 0.4 feels right but Rocket and AVRiL force are reversed with each other
        
    //MOVEMENT RELATED
    GroundSpeed=800.000000 //700
    SteerSpeed=200.000000 //110.0 def UT2004
    //MaxSteerAngleCurve=(Points=((OutVal=50.000000),,)) @100GPing100: Causes crash.    
    TransRatio=0.15 //0.11
    
    ChassisTorqueScale=1.0 //0.82 //0.7
    EngineInertia=0.01
    EngineBrakeFactor=0.0002 //0.0001 def
    MaxBrakeTorque=20.5 //20.0
    WheelInertia=0.01
    WheelSuspensionOffset=7.0 //5.0 //HDm: Fixes the chassis sitting height in-game
    
   Begin Object Class=KarmaParamsRBFull Name=KParams0
        KStartEnabled=True
        KFriction=0.5
        KLinearDamping=0.05
        KAngularDamping=0.05
        KImpactThreshold=500
        kMaxSpeed=1050.0
        bKNonSphericalInertia=True
        bHighDetailOnly=False
        bClientOnly=False
        bKDoubleTickRate=True
        KInertiaTensor(0)=1.0
        KInertiaTensor(1)=0.0
        KInertiaTensor(2)=0.0
        KInertiaTensor(3)=3.0
        KInertiaTensor(4)=0.0
        KInertiaTensor(5)=3.5
        KCOMOffset=(X=-0.3,Y=0.0,Z=-0.5)
        bDestroyOnWorldPenetrate=True
        bDoSafetime=True
        Name="KParams0"
    End Object
    KParams=KarmaParams'KParams0'

    Begin Object Class=SVehicleWheel Name=RRWheel
        BoneName="Rt_Rear_Tire"
        BoneRollAxis=AXIS_Y
        BoneSteerAxis=AXIS_Z
        BoneOffset=(X=0.0,Y=27.0,Z=-6.0)
        WheelRadius=30
        bPoweredWheel=True
        bHandbrakeWheel=True
        SteerType=VST_Fixed
        //SupportBoneName="Rt_Rear_Suspension"
        //SupportBoneAxis=AXIS_Y
    End Object
    Begin Object Class=SVehicleWheel Name=LRWheel
        BoneName="Lt_Rear_Tire"
        BoneRollAxis=AXIS_Y
        BoneSteerAxis=AXIS_Z
        BoneOffset=(X=15.0,Y=-27.0,Z=-6.0)
        WheelRadius=30
        bPoweredWheel=True
        bHandbrakeWheel=True
        SteerType=VST_Fixed
        //SupportBoneName="Lt_Rear_Suspension"
        //SupportBoneAxis=AXIS_Y
    End Object
    Begin Object Class=SVehicleWheel Name=RFWheel
        BoneName="Rt_Front_Tire"
        BoneRollAxis=AXIS_Y
        BoneSteerAxis=AXIS_Z
        BoneOffset=(X=0.0,Y=27.0,Z=-6.0)
        WheelRadius=30
        bPoweredWheel=True
        SteerType=VST_Steered
        //SupportBoneName="Rt_Front_Suspension"
        //SupportBoneAxis=AXIS_Y
    End Object
    Begin Object Class=SVehicleWheel Name=LFWheel
        BoneName="Lt_Front_Tire"
        BoneRollAxis=AXIS_Y
        BoneSteerAxis=AXIS_Z
        BoneOffset=(X=0.0,Y=-27.0,Z=-6.0)
        WheelRadius=30
        bPoweredWheel=True
        SteerType=VST_Steered
        //SupportBoneName="Lt_Front_Suspension"
        //SupportBoneAxis=AXIS_Y
    End Object

    Wheels(0) = RRWheel;
    Wheels(1) = LRWheel;
    Wheels(2) = RFWheel;
    Wheels(3) = LFWheel;
    // @100GPing100
    //============EDN============   
   
    //ENTRY & EXIT RELATED

    EntryPosition=(X=0,Y=0,Z=0)
    EntryRadius=180.0  //300.000000
    
    ExitPositions(0)=(X=-10,Y=-160,Z=50)  //Left
    ExitPositions(1)=(X=-10,Y=160,Z=50)   //Right
    ExitPositions(2)=(X=-10,Y=-160,Z=-50) //Left Below
    ExitPositions(3)=(X=-10,Y=160,Z=-50)  //Right Below
    ExitPositions(4)=(X=10,Y=-5,Z=130)    //Roof

    //CAMERA RELATED
    bDrawDriverInTP=False
    FPCamPos=(X=0,Y=31,Z=160)
    TPCamDistance=375.000000
    TPCamLookat=(X=0,Y=0,Z=0)
    TPCamWorldOffset=(X=0,Y=0,Z=200)
    
}
