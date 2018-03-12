/*
 * Copyright © 2008 Wormbo
 * Copyright © 2012, 2017, 2018 Luís 'zeluisping' Guimarães (100GPing100)
 * Copyright © 2008, 2014 GreatEmerald
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

class UT3Manta extends ONSHoverBike;

/* Load the packages. */
#exec obj load file=..\Animations\UT3MantaAnims.ukx
#exec obj load file=..\Textures\UT3MantaTex.utx
#exec obj load file=..\Sounds\UT3A_Vehicle_Manta.uax
#exec OBJ LOAD FILE=..\textures\EpicParticles.utx
#exec OBJ LOAD FILE=..\textures\VMVehicles-TX.utx

var Emitter DuckEffect;

var()   array<vector>                   TrailEffectPositions;
var     class<ONSAttackCraftExhaust>    TrailEffectClass;
var     array<ONSAttackCraftExhaust>    TrailEffects;

/* The spining blades. */
var array<UT3MantaBlade> Blades;

//
// Spawn the blades.
//
function PostBeginPlay()
{
    Super.PostBeginPlay();

    // Spawn the blades and attach them to the manta.
    Blades[0] = Spawn(class'UT3MantaBlade');
    AttachToBone(Blades[0], 'Blade_rt');
    Blades[1] = Spawn(class'UT3MantaBlade');
    AttachToBone(Blades[1], 'Blade_lt');

    ToggleBlades(false);
}

//
// Update the state of the blades.
//
function DrivingStatusChanged()
{
    local vector RotX, RotY, RotZ;
    local int i;
    
    Super.DrivingStatusChanged();

    ToggleBlades(Driver != None);

    if (Driver == None) // The default value is set by the mutator.
    {    bCanBeBaseForPawns = default.bCanBeBaseForPawns;
    }
    else
    {    bCanBeBaseForPawns = false;
    }

    if (bDriving && Level.NetMode != NM_DedicatedServer && !bDropDetail)
    {
        GetAxes(Rotation,RotX,RotY,RotZ);

        if (TrailEffects.Length == 0)
        {
            TrailEffects.Length = TrailEffectPositions.Length;

            for(i=0;i<TrailEffects.Length;i++)
                if (TrailEffects[i] == None)
                {
                    TrailEffects[i] = spawn(TrailEffectClass, self,, Location + (TrailEffectPositions[i] >> Rotation) );
                    TrailEffects[i].SetBase(self);
                    TrailEffects[i].SetRelativeRotation( rot(0,32768,0) );
                }
        }

    }
    else
    {
        if (Level.NetMode != NM_DedicatedServer)
        {
            for(i=0;i<TrailEffects.Length;i++)
               TrailEffects[i].Destroy();

            TrailEffects.Length = 0;

        }
    }
}

//
// Called every game tick.
//
function Tick(float DeltaTime)
{
    local int i;
    local float ThrustAmount;
    local TrailEmitter T;
    local vector RelVel;
    local bool bIsBehindView;
    local PlayerController PC;
    
    super.Tick(DeltaTime);

    if (Driver != None) // Just in case.
        Ailerons(DeltaTime);

    if (!bHoldingDuck && DuckEffect != None)
        DuckEffect.Destroy();
    
        if(Level.NetMode != NM_DedicatedServer)
    {

        RelVel = Velocity << Rotation;

        PC = Level.GetLocalPlayerController();
        if (PC != None && PC.ViewTarget == self)
            bIsBehindView = PC.bBehindView;
        else
            bIsBehindView = True;

        // Adjust Engine FX depending on being drive/velocity
        if (!bIsBehindView)
        {
            for(i=0; i<TrailEffects.Length; i++)
                TrailEffects[i].SetThrustEnabled(false);
        }
        else
        {
            ThrustAmount = FClamp(OutputThrust, 0.0, 1.0);

            for(i=0; i<TrailEffects.Length; i++)
            {
                TrailEffects[i].SetThrustEnabled(true);
                TrailEffects[i].SetThrust(ThrustAmount);
            }
        }
    }
}


//
// Turn the blades On/Off.
//
function ToggleBlades(bool bRotating)
{
    if (Blades.length < 2 || Blades[0] == None || Blades[1] == None)
        return;

    if (bRotating) {
        // On.
        Blades[0].Skins[0] = Blades[0].BladesOnTex;
        Blades[1].Skins[0] = Blades[1].BladesOnTex;
    } else {
        // Off.
        Blades[0].Skins[0] = Blades[0].BladesOffTex;
        Blades[1].Skins[0] = Blades[1].BladesOffTex;
    }
}

//
// Animate the ailerons (code animated).
//
function Ailerons(float DeltaTime)
{
    local Rotator AileronsRotation;
    local Rotator GunsRotation;
    Super.Tick(DeltaTime);
    // 45° = 8192 RUU

    // 1000 = The velocity at wich the angle is of 45º
    AileronsRotation.Pitch = 8192 * (Velocity.Z / 1000) - Rotation.Pitch;

    if (AileronsRotation.Pitch > 8192)
        AileronsRotation.Pitch = 8192;
    else if (AileronsRotation.Pitch < -8192)
        AileronsRotation.Pitch = -8192;

    SetBoneRotation('Aileron_Rt', AileronsRotation, 0, 1);
    SetBoneRotation('Aileron_Lt', AileronsRotation, 0, 1);
    
    GunsRotation.Pitch = -DriverViewPitch;
    //GunsRotation.Yaw = -DriverViewYaw;
    
    SetBoneRotation('Barrel_rt', GunsRotation, 0, 1);
    SetBoneRotation('Barrel_lt', GunsRotation, 0, 1);

}

//
// On destruction, destroy the blades too.
//
simulated function Destroyed()
{
    local int i;

    Blades[0].Destroy();
    Blades[1].Destroy();
    
     if (Level.NetMode != NM_DedicatedServer)
    {
        for (i = 0; i < BikeDust.Length; i++)
            BikeDust[i].Destroy();

        BikeDust.Length = 0;
    }

    if(Level.NetMode != NM_DedicatedServer)
    {
        for(i=0;i<TrailEffects.Length;i++)
            TrailEffects[i].Destroy();
        TrailEffects.Length = 0;

    }

    Super.Destroyed();
}

simulated function CheckJumpDuck()
{
    local KarmaParams KP;
    local Emitter JumpEffect;
    local bool bOnGround;
    local int i;

    KP = KarmaParams(KParams);

    // Can only start a jump when in contact with the ground and not on water.
    bOnGround = false;
    for(i=0; i<KP.Repulsors.Length; i++)
    {
        if( KP.Repulsors[i] != None && KP.Repulsors[i].bRepulsorInContact )
            bOnGround = true;
    }

    // If we are on the ground, and press Rise, and we not currently in the middle of a jump, start a new one.
    if (JumpCountdown <= 0.0 && Rise > 0 && bOnGround && !bOverWater && !bHoldingDuck && Level.TimeSeconds - JumpDelay >= LastJumpTime)
    {
        PlaySound(JumpSound,,1.0);

        if (Role == ROLE_Authority)
        DoBikeJump = !DoBikeJump;

        if(Level.NetMode != NM_DedicatedServer)
        {
            JumpEffect = Spawn(class'ONSHoverBikeJumpEffect');
            JumpEffect.SetBase(Self);
            ClientPlayForceFeedback(JumpForce);
        }

        if ( AIController(Controller) != None )
            Rise = 0;

        LastJumpTime = Level.TimeSeconds;
    }
    else if (DuckCountdown <= 0.0 && (Rise < 0 || bWeaponIsAltFiring))
    {
        if (!bHoldingDuck)
        {
            bHoldingDuck = True;

            PlaySound(DuckSound,,1.0);

            if(Level.NetMode != NM_DedicatedServer)
            {
                DuckEffect = Spawn(class'UT3MantaDuckEffect');
                DuckEffect.SetBase(Self);
            }

            if ( AIController(Controller) != None )
                Rise = 0;

            JumpCountdown = 0.0; // Stops any jumping that was going on.
        }
    }
    else
    bHoldingDuck = False;
}

simulated function AttachDriver(Pawn P)
{
    local rotator ThighDriveL,ThighDriveR;
    super.AttachDriver(P);

    ThighDriveL.Pitch=1800;
    P.SetBoneRotation('Bip01 L Thigh',ThighDriveL);
    ThighDriveR.Pitch=-1800;
    P.SetBoneRotation('Bip01 R Thigh',ThighDriveR);
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
    
    Super.DetachDriver(P);
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

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
    local int i;

    if(Level.NetMode != NM_DedicatedServer)
    {
        for(i=0;i<TrailEffects.Length;i++)
            TrailEffects[i].Destroy();
        TrailEffects.Length = 0;

    }

    Super.Died(Killer, damageType, HitLocation);
}

//=============================================================================
// Default values
//=============================================================================
defaultproperties
{

    // Looks.
    Drawscale = 1.0
    Mesh = SkeletalMesh'UT3MantaAnims.Manta';
    RedSkin = Shader'UT3MantaTex.MantaSkin';
    BlueSkin = Shader'UT3MantaTex.MantaSkinBlue';
    DrivePos = (X=-67,Y=0.0,Z=64.0);

    // Damage.
    DriverWeapons(0)=(WeaponClass=class'UT3MantaPlasmaGun',WeaponBone=barrel_rt);

    // Strings.
    VehiclePositionString = "in a UT3 Manta";
    VehicleNameString = "UT3 Manta"

    // Movement.
    GroundSpeed = 1500 //UT2004 default is 2000 UT3 default is 1500
    JumpForceMag=200.0
    AirControl = 1.5
    MaxYawRate=5.0 //3.0
    TurnTorqueMax=180.0 //125.0 def UT2004
    UprightStiffness=450.000000 //The manual says it doesn't do anything
    UprightDamping=20.000000  //The manual says it doesn't do anything
    PitchTorqueMax=9.0  //18 is a bit too over the top  //13.5 as well
    RollTorqueMax=10.0  //25.0 //12.5 default 2004 value
    RollDamping=20.0    //30.0 def UT2004
    RollTorqueStrafeFactor=100.0 //50.0 def UT2004
        
    MaxStrafeForce=27 //20 def UT2004
    LatDamping=0.2
    LongDamping=0.1
    
    HoverSoftness=0.15 //0.09 def UT2004
    HoverPenScale=1.35 //1.0 def UT2004
    HoverCheckDist=165; //155 //150.0 def UT2004

    Begin Object Class=KarmaParamsRBFull Name=KParams0
        KStartEnabled=True
        KFriction=0.5
        KLinearDamping=0.15
        KAngularDamping=0.15 //0
        KMaxSpeed=1800  //?
        bKNonSphericalInertia=False
        KImpactThreshold=700
        bHighDetailOnly=False
        bClientOnly=False
        bKDoubleTickRate=True
        bKStayUpright=True
        bKAllowRotate=True
        KInertiaTensor(0)=1.3
        KInertiaTensor(1)=0.0
        KInertiaTensor(2)=0.0
        KInertiaTensor(3)=4.0
        KInertiaTensor(4)=0.0
        KInertiaTensor(5)=4.5
        KCOMOffset=(X=0.0,Y=0.0,Z=0.0)
        bDestroyOnWorldPenetrate=True
        bDoSafetime=True
        Name="KParams0"
    End Object
    KParams=KarmaParams'KParams0'
        
    // Sounds.
    IdleSound = Sound'UT3A_Vehicle_Manta.UT3MantaSingles.UT3MantaEngineLoop01Cue';
    StartUpSound = Sound'UT3A_Vehicle_Manta.UT3MantaEngineStart.UT3MantaEngineStartCue';
    ShutDownSound = Sound'UT3A_Vehicle_Manta.UT3MantaEngineStop.UT3MantaEngineStopCue';
    JumpSound = Sound'UT3A_Vehicle_Manta.UT3MantaJump.UT3MantaJumpCue';
    DuckSound = Sound'UT3A_Vehicle_Manta.UT3MantaCrouch.UT3MantaCrouchCue';
    ImpactDamageSounds=();
    ImpactDamageSounds(0) = Sound'UT3A_Vehicle_Manta.UT3MantaCollide.UT3MantaCollideCue';
    ExplosionSounds=();
    ExplosionSounds(0) = Sound'UT3A_Vehicle_Manta.UT3MantaExplode.UT3MantaExplodeCue';
    BulletSounds=()
    BulletSounds(0) = Sound'UT3A_Weapon_BulletImpacts.UT3BulletImpactMetal.UT3BulletImpactMetalCue'
    HornSounds(1)=sound'ONSVehicleSounds-S.Horns.LaCuchachaHorn';
    MaxPitchSpeed = 2000; //HD: Doesn't sound high enough when moving but changing this causes idle to not sound right either
    
    MomentumMult=0.8 //?
    ImpactDamageMult = 0.00001 //0.0003
    DamagedEffectHealthSmokeFactor=0.65 //0.5
    DamagedEffectHealthFireFactor=0.40 //0.25 //.373 is what I had, I think 0.4 will be too much but we'll se
    DamagedEffectFireDamagePerSec=2.0  //0.75
        
    EntryRadius = 160.0
    ExitPositions(0)=(X=-70,Y=140,Z=30)   //Right
    ExitPositions(1)=(X=-70,Y=-140,Z=30)  //Left
    ExitPositions(2)=(X=150,Y=0,Z=30)   //Front
    ExitPositions(3)=(X=-150,Y=0,Z=30)  //Rear
    ExitPositions(4)=(X=-150,Y=0,Z=-30) //Rear Below
    ExitPositions(5)=(X=150,Y=0,Z=-30)  //Front Below
    ExitPositions(6)=(X=-70,Y=140,Z=-30)  //Right Below
    ExitPositions(7)=(X=-70,Y=-140,Z=-30) //Left Below
    

    bDrawMeshInFP=True
    
    FPCamPos=(X=65,Y=0,Z=-5)
    
    //Normal
    TPCamDistance=300.000000  //NOTE: Be sure TO DELETE THIS LINE from USER.INI, it overrides this value and will be re-added to the ini as soon as you use the vehicle, all this does here is make it the starting distance
    TPCamLookat=(X=-10,Y=0,Z=0)
    TPCamWorldOffset=(X=0,Y=0,Z=100) //Z might need to be 110 or 120 for better upwards aim
    
    TrailEffectPositions(0)=(X=-127.000000,Y=-16.000000,Z=16.000000)
    TrailEffectPositions(1)=(X=-127.000000,Y=16.000000,Z=16.000000)
    TrailEffectClass=Class'Onslaught.ONSAttackCraftExhaust'
    
    DamagedEffectOffset=(X=2,Y=31,Z=16)   //Turbine fire point
    //DamagedEffectOffset=(X=2,Y=-75,Z=-10) //Blades fire point
    //DamagedEffectScale=0.6
    
    HeadlightCoronaOffset=()
    HeadlightCoronaOffset(0)=(X=40.0,Y=0.0,Z=-20.0)
    HeadlightCoronaMaterial=Material'EpicParticles.FlashFlare1'
    //HeadlightCoronaMaterial=Material'EmitterTextures.Flares.EFlareOY'
    
    HeadlightProjectorOffset=(X=35,Y=0,Z=-30)
    HeadlightProjectorRotation=(Yaw=0,Pitch=-1000,Roll=0)
    HeadlightProjectorMaterial=Texture'VMVehicles-TX.RVGroup.RVProjector'
    HeadlightProjectorScale=0.02
    
}
