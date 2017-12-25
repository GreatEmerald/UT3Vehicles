/*
 * Copyright © 2008, 2014 GreatEmerald
 * Copyright © 2008-2009 Wormbo
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
    if (InstigatedBy != self)
    Super.TakeDamage(Damage, instigatedBy, Hitlocation, Momentum, damageType);
}

event bool IsVehicleEmpty() //Starting the removal of one seat - everywhere length-1
{
    local int i;

    if ( Driver != None )
        return false;

    for (i=0; i<(WeaponPawns.length)-1; i++)
        if ( WeaponPawns[i].Driver != None )
            return false;

    return true;
}

static function StaticPrecache(LevelInfo L)
{
    local int i;

    for(i=0;i<Default.DriverWeapons.Length;i++)
        Default.DriverWeapons[i].WeaponClass.static.StaticPrecache(L);

    for(i=0;i<(Default.PassengerWeapons.Length)-1;i++)
        Default.PassengerWeapons[i].WeaponPawnClass.static.StaticPrecache(L);

    if (Default.DestroyedVehicleMesh != None)
        L.AddPrecacheStaticMesh(Default.DestroyedVehicleMesh);

    if (Default.HeadlightCoronaMaterial != None)
        L.AddPrecacheMaterial(Default.HeadLightCoronaMaterial);

    if (Default.HeadlightProjectorMaterial != None)
        L.AddPrecacheMaterial(Default.HeadLightProjectorMaterial);

    L.AddPrecacheMaterial( default.VehicleIcon.Material );

    L.AddPrecacheMaterial(Material'EmitterTextures.MultiFrame.LargeFlames');
    L.AddPrecacheMaterial(Material'EmitterTextures.MultiFrame.fire3');
    L.AddPrecacheMaterial(Texture'AW-2004Particles.Weapons.DustSmoke');
    L.AddPrecacheStaticMesh(StaticMesh'ONSDeadVehicles-SM.HELLbenderExploded.HellTire');
    L.AddPrecacheStaticMesh(StaticMesh'ONSDeadVehicles-SM.HELLbenderExploded.HellDoor');
    L.AddPrecacheStaticMesh(StaticMesh'ONSDeadVehicles-SM.HELLbenderExploded.HellGun');
    L.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris2');
    L.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris1');

    L.AddPrecacheMaterial(Material'AW-2004Particles.Energy.SparkHead');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp2_frames');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp1_frames');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.we1_frames');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.MuchSmoke1');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.NapalmSpot');
    L.AddPrecacheMaterial(Material'EpicParticles.Fire.SprayFire1');
    L.AddPrecacheMaterial(Material'VMVehicles-TX.NEWprvGroup.newPRVnoColor');
    L.AddPrecacheMaterial(Material'VMVehicles-TX.NEWprvGroup.PRVcolorRED');
    L.AddPrecacheMaterial(Material'VMVehicles-TX.NEWprvGroup.PRVcolorBLUE');
    L.AddPrecacheMaterial(Material'VMVehicles-TX.NEWprvGroup.EnergyEffectMASKtex');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Energy.PowerSwirl');
    L.AddPrecacheMaterial(Material'VMWeaponsTX.ManualBaseGun.baseGunEffectcopy');
    L.AddPrecacheMaterial(Material'VehicleFX.Particles.DustyCloud2');
    L.AddPrecacheMaterial(Material'VMParticleTextures.DirtKICKGROUP.dirtKICKTEX');
    L.AddPrecacheMaterial(Material'Engine.GRADIENT_Fade');
    L.AddPrecacheMaterial(Material'VMVehicles-TX.NEWprvGroup.PRVtagFallBack');
    L.AddPrecacheMaterial(Material'VMVehicles-TX.NEWprvGroup.prvTAGSCRIPTED');
}

simulated function PostNetBeginPlay()
{
    local int i;

    // Count the number of powered wheels on the car
    NumPoweredWheels = 0.0;
    for(i=0; i<Wheels.Length; i++)
    {
        NumPoweredWheels += 1.0;
    }

    Super(SVehicle).PostNetBeginPlay();

    if (Role == ROLE_Authority)
    {
        // Spawn the Driver Weapons
        for(i=0;i<DriverWeapons.Length;i++)
        {
            // Spawn Weapon
            Weapons[i] = spawn(DriverWeapons[i].WeaponClass, self,, Location, rot(0,0,0));
            AttachToBone(Weapons[i], DriverWeapons[i].WeaponBone);
            if (!Weapons[i].bAimable)
                Weapons[i].CurrentAim = rot(0,32768,0);
        }

        if (ActiveWeapon < Weapons.length)
        {
            PitchUpLimit = Weapons[ActiveWeapon].PitchUpLimit;
            PitchDownLimit = Weapons[ActiveWeapon].PitchDownLimit;
        }

        // Spawn the Passenger Weapons
        for(i=0;i<(PassengerWeapons.Length)-1;i++)
        {
            // Spawn WeaponPawn
            WeaponPawns[i] = spawn(PassengerWeapons[i].WeaponPawnClass, self,, Location);
            WeaponPawns[i].AttachToVehicle(self, PassengerWeapons[i].WeaponBone);
            if (!WeaponPawns[i].bHasOwnHealth)
                WeaponPawns[i].HealthMax = HealthMax;
            WeaponPawns[i].ObjectiveGetOutDist = ObjectiveGetOutDist;
        }
    }

    if(Level.NetMode != NM_DedicatedServer && Level.DetailMode > DM_Low && SparkEffectClass != None)
    {
        SparkEffect = spawn( SparkEffectClass, self,, Location);
    }

    if(Level.NetMode != NM_DedicatedServer && Level.bUseHeadlights && !(Level.bDropDetail || (Level.DetailMode == DM_Low)))
    {
        HeadlightCorona.Length = HeadlightCoronaOffset.Length;

        for(i=0; i<HeadlightCoronaOffset.Length; i++)
        {
            HeadlightCorona[i] = spawn( class'ONSHeadlightCorona', self,, Location + (HeadlightCoronaOffset[i] >> Rotation) );
            HeadlightCorona[i].SetBase(self);
            HeadlightCorona[i].SetRelativeRotation(rot(0,0,0));
            HeadlightCorona[i].Skins[0] = HeadlightCoronaMaterial;
            HeadlightCorona[i].ChangeTeamTint(Team);
            HeadlightCorona[i].MaxCoronaSize = HeadlightCoronaMaxSize * Level.HeadlightScaling;
        }

        if(HeadlightProjectorMaterial != None && Level.DetailMode == DM_SuperHigh)
        {
            HeadlightProjector = spawn( class'ONSHeadlightProjector', self,, Location + (HeadlightProjectorOffset >> Rotation) );
            HeadlightProjector.SetBase(self);
            HeadlightProjector.SetRelativeRotation( HeadlightProjectorRotation );
            HeadlightProjector.ProjTexture = HeadlightProjectorMaterial;
            HeadlightProjector.SetDrawScale(HeadlightProjectorScale);
            HeadlightProjector.CullDistance = ShadowCullDistance;
        }
    }

    SetTeamNum(Team);
    TeamChanged();
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


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
    //===========================
    // @100GPing100
    Mesh = SkeletalMesh'UT3VH_Hellbender_Anims.SK_VH_Hellbender';
    RedSkin = Shader'UT3HellbenderTex.UT3HellbenderSkinRed';
    BlueSkin = Shader'UT3HellbenderTex.UT3HellbenderSkinBlue';
    DriveAnim = "Idle"
    MovementAnims(0) = "Idle"

    DriverWeapons(0)=(WeaponClass=Class'UT3HellbenderSideGun',WeaponBone="SecondaryTurretYaw")
    PassengerWeapons(0)=(WeaponPawnClass=Class'UT3HellbenderRearGunPawn',WeaponBone="MainTurretYaw")

    FlagBone = Hood;

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
        BoneOffset=(X=0.0,Y=27.0,Z=0.0)
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
        BoneOffset=(X=15.0,Y=-27.0,Z=0.0)
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
        BoneOffset=(X=0.0,Y=27.0,Z=0.0)
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
        BoneOffset=(X=0.0,Y=-27.0,Z=0.0)
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

    //MaxSteerAngleCurve=(Points=((OutVal=50.000000),,)) @100GPing100: Causes crash.
    SteerSpeed=200.000000 //110.0 def UT2004
    PassengerWeapons(1)=()
    IdleSound=Sound'UT3A_Vehicle_Hellbender.Sounds.A_Vehicle_Hellbender_EngineIdle01'
    StartUpSound=Sound'UT3A_Vehicle_Hellbender.Sounds.A_Vehicle_Hellbender_EngineStart01'
    ShutDownSound=Sound'UT3A_Vehicle_Hellbender.Sounds.A_Vehicle_Hellbender_EngineStop01'
    DamagedEffectHealthSmokeFactor=0.65 //0.5
    DamagedEffectHealthFireFactor=0.39 //0.25
    DamagedEffectFireDamagePerSec=0.95 //0.75
    ImpactDamageSounds(0) = Sound'UT3A_Vehicle_Scorpion.Sounds.A_Vehicle_Scorpion_Collide03';
    ImpactDamageSounds(1) = Sound'UT3A_Vehicle_Scorpion.Sounds.A_Vehicle_Scorpion_Collide04';
    ImpactDamageSounds(2) = Sound'UT3A_Vehicle_Scorpion.Sounds.A_Vehicle_Scorpion_Collide03';
    ImpactDamageSounds(3) = Sound'UT3A_Vehicle_Scorpion.Sounds.A_Vehicle_Scorpion_Collide04';
    ImpactDamageSounds(4) = Sound'UT3A_Vehicle_Scorpion.Sounds.A_Vehicle_Scorpion_Collide03';
    ImpactDamageSounds(5) = Sound'UT3A_Vehicle_Scorpion.Sounds.A_Vehicle_Scorpion_Collide04';
    ImpactDamageSounds(6) = Sound'UT3A_Vehicle_Scorpion.Sounds.A_Vehicle_Scorpion_Collide03';
    ExplosionSounds(0) = Sound'UT3A_Vehicle_Hellbender.Sounds.A_Vehicle_Hellbender_Explode01';
    ExplosionSounds(1) = Sound'UT3A_Vehicle_Hellbender.Sounds.A_Vehicle_Hellbender_Explode01';
    ExplosionSounds(2) = Sound'UT3A_Vehicle_Hellbender.Sounds.A_Vehicle_Hellbender_Explode01';
    ExplosionSounds(3) = Sound'UT3A_Vehicle_Hellbender.Sounds.A_Vehicle_Hellbender_Explode01';
    ExplosionSounds(4) = Sound'UT3A_Vehicle_Hellbender.Sounds.A_Vehicle_Hellbender_Explode01';
    EntryPosition=(X=0,Y=0,Z=0)
    EntryRadius=180.0  //300.000000
    MomentumMult=0.400000 //1.0  //HDm to GE: 0.4 feels right but Rocket and AVRiL force are reversed with each other
    MomentumMult=1.000000
    bDrawDriverInTP=False
    DriverDamageMult=0.000000
    VehiclePositionString="in a Hellbender"
    VehicleNameString="UT3 Hellbender"
    HornSounds(0)=Sound'UT3A_Vehicle_Hellbender.Sounds.A_Vehicle_Hellbender_Horn01'
    GroundSpeed=800.000000 //700
    SoundVolume=255

    TransRatio=0.15 //0.11
    EngineBrakeFactor=0.0002 //0.0001 def
    MaxBrakeTorque=20.5 //20.0
    EngineInertia=0.01
    WheelInertia=0.01
    ChassisTorqueScale=0.82 //0.7

    DrawScale=0.95

    CollisionRadius=219
    
    //ExitPositions(0)=(X=0,Y=-165,Z=50)
    //ExitPositions(1)=(X=0,Y=165,Z=50)
    //ExitPositions(2)=(X=0,Y=-165,Z=-50)
    //ExitPositions(3)=(X=0,Y=165,Z=-50)
    
    ExitPositions(0)=(X=-10,Y=-160,Z=50)  //Left
    ExitPositions(1)=(X=-10,Y=160,Z=50)   //Right
    ExitPositions(2)=(X=-10,Y=-160,Z=-50) //Left Below
    ExitPositions(3)=(X=-10,Y=160,Z=-50)  //Right Below
    
    FPCamPos=(X=-10,Y=28,Z=135)
    
    //Normal
    TPCamDistance=375.000000
    TPCamLookat=(X=0,Y=0,Z=0)
    TPCamWorldOffset=(X=0,Y=0,Z=200)
    
    //Aerial View
    //TPCamDistance=375.000000
    //TPCamLookat=(X=-10,Y=0,Z=0)
    //TPCamWorldOffset=(X=0,Y=0,Z=140)
    
    HeadlightCoronaOffset(0)=(X=72.5,Y=26.5,Z=49.5) //(X=77.5,Y=27.5,Z=52.5)
    HeadlightCoronaOffset(1)=(X=72.5,Y=-26.5,Z=49.5)
    HeadlightCoronaOffset(2)=(X=72.5,Y=25,Z=39)
    HeadlightCoronaOffset(3)=(X=72.5,Y=-25,Z=39)
    HeadlightCoronaMaterial=Material'EpicParticles.FlashFlare1'
    //HeadlightCoronaMaterial=Material'EmitterTextures.Flares.EFlareOY'
    HeadlightCoronaMaxSize=50 //82 works with EFlareOY but FlashFlare is huge
    
    HeadlightProjectorOffset=(X=72.0,Y=0,Z=46.5) //(X=82.5,Y=0,Z=55.5)
    HeadlightProjectorRotation=(Yaw=0,Pitch=-1000,Roll=0)
    HeadlightProjectorMaterial=Texture'VMVehicles-TX.NewPRVGroup.PRVProjector'
    HeadlightProjectorScale=0.40 //0.65

    BrakeLightOffset(0)=(X=-130.5,Y=38.5,Z=60) //(X=-137.5,Y=42.5,Z=64)
    BrakeLightOffset(1)=(X=-130.5,Y=-38.5,Z=60)
    BrakeLightMaterial=Material'EpicParticles.FlickerFlare'
}
