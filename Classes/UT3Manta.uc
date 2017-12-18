/*
 * Copyright © 2008 Wormbo
 * Copyright © 2012 100GPing100
 * Copyright © 2008, 2014 GreatEmerald
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

var Emitter DuckEffect;

//===============
// @100GPing100
/* Load the packages. */
#exec obj load file=../Animations/UT3MantaAnims.ukx
#exec obj load file=../Textures/UT3MantaTex.utx

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
    Super.DrivingStatusChanged();

    ToggleBlades(Driver != None);

    if (Driver == None) // The default value is set by the mutator.
        bCanBeBaseForPawns = default.bCanBeBaseForPawns;
    else
        bCanBeBaseForPawns = false;
}

//
// Called every game tick.
//
function Tick(float DeltaTime)
{
    if (Driver != None) // Just in case.
        Ailerons(DeltaTime);
    EmeraldTick(DeltaTime); // Renamed it.
}

//
// Turn the blades On/Off.
//
function ToggleBlades(bool OnOff)
{
    if (Blades.length < 2 || Blades[0] == None || Blades[1] == None)
        return;

    if (OnOff) { // On.
        Blades[0].Skins[0] = Blades[0].BladesOnTex;
        Blades[1].Skins[0] = Blades[1].BladesOnTex;
    } else { // Off.
        Blades[0].Skins[0] = Blades[0].BladesOffTex;
        Blades[1].Skins[0] = Blades[1].BladesOffTex;
    }
}

//
// Animate the ailerons (code animated).
//
function Ailerons(float DeltaTime)
{
    // 45° = 8192 RUU
    local Rotator AileronsRotation;

    // 1000 = The velocity at wich the angle is of 45º
    AileronsRotation.Pitch = 8192 * (Velocity.Z / 1000) - Rotation.Pitch;
    AileronsRotation.Yaw = 0;
    AileronsRotation.Roll = 0;

    if (AileronsRotation.Pitch > 8192)
        AileronsRotation.Pitch = 8192;
    else if (AileronsRotation.Pitch < -8192)
        AileronsRotation.Pitch = -8192;

    SetBoneRotation('Aileron_Rt', AileronsRotation, 0, 1);
    SetBoneRotation('Aileron_Lt', AileronsRotation, 0, 1);
}

//
// On destruction, destroy the blades too.
//
function Destroyed()
{
    Blades[0].Destroy();
    Blades[1].Destroy();

    Super.Destroyed();
}
// @100GPing100
//======END======

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

simulated function EmeraldTick(float DeltaTime)
{
Super.Tick(DeltaTime);
if (!bHoldingDuck && DuckEffect!=None) {
    DuckEffect.Destroy();
    }
}

//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
    //===============
    // @100GPing100
    // Looks.
    Mesh = SkeletalMesh'UT3MantaAnims.Manta';
    RedSkin = Shader'UT3MantaTex.MantaSkin';
    BlueSkin = Shader'UT3MantaTex.MantaSkinBlue';
    DrivePos = (X=-70,Y=0.0,Z=50.0);

    // Damage.
    DriverWeapons(0)=(WeaponClass=class'UT3MantaPlasmaGun',WeaponBone=barrel_rt);

    // Strings.
    VehiclePositionString = "in a UT3 Manta";

    // Movement.
    GroundSpeed = 1500 //UT2004 def 2000, UT3 def 1500
    MaxPitchSpeed = 2000;
    HoverSoftness=0.15 //0.09 def UT2004
	HoverPenScale=1.35 //1.0 def UT2004
	HoverCheckDist=165; //155 GE //150.0 def UT2004
    AirControl = 1.5;

	MaxStrafeForce=27 //20 def UT2004
    LatDamping=0.2

	Begin Object Class=KarmaParamsRBFull Name=KParams0
		KStartEnabled=True
		KFriction=0.5
		KLinearDamping=0.15
		KAngularDamping=0.02 //0
		KMaxSpeed=1800
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
    IdleSound = Sound'UT3A_Vehicle_Manta.Sounds.A_Vehicle_Manta_EngineLoop01';
    StartUpSound = Sound'UT3A_Vehicle_Manta.Sounds.A_Vehicle_Manta_Start01';
    ShutDownSound = Sound'UT3A_Vehicle_Manta.Sounds.A_Vehicle_Manta_Stop01';
    JumpSound = Sound'UT3A_Vehicle_Manta.Sounds.A_Vehicle_Manta_Jump';
    DuckSound = Sound'UT3A_Vehicle_Manta.Sounds.A_Vehicle_Manta_Crouch';
    ImpactDamageSounds(0) = Sound'UT3A_Vehicle_Manta.Sounds.A_Vehicle_Manta_Collide01';
    ImpactDamageSounds(1) = Sound'UT3A_Vehicle_Manta.Sounds.A_Vehicle_Manta_Collide02';
    ImpactDamageSounds(2) = Sound'UT3A_Vehicle_Manta.Sounds.A_Vehicle_Manta_Collide01';
    ImpactDamageSounds(3) = Sound'UT3A_Vehicle_Manta.Sounds.A_Vehicle_Manta_Collide02';
    ImpactDamageSounds(4) = Sound'UT3A_Vehicle_Manta.Sounds.A_Vehicle_Manta_Collide01';
    ImpactDamageSounds(5) = Sound'UT3A_Vehicle_Manta.Sounds.A_Vehicle_Manta_Collide02';
    ImpactDamageSounds(6) = Sound'UT3A_Vehicle_Manta.Sounds.A_Vehicle_Manta_Collide01';
    ExplosionSounds(0) = Sound'UT3A_Vehicle_Manta.Sounds.A_Vehicle_Manta_Explode01';
    ExplosionSounds(1) = Sound'UT3A_Vehicle_Manta.Sounds.A_Vehicle_Manta_Explode01';
    ExplosionSounds(2) = Sound'UT3A_Vehicle_Manta.Sounds.A_Vehicle_Manta_Explode01';
    ExplosionSounds(3) = Sound'UT3A_Vehicle_Manta.Sounds.A_Vehicle_Manta_Explode01';
    ExplosionSounds(4) = Sound'UT3A_Vehicle_Manta.Sounds.A_Vehicle_Manta_Explode01';
    // @100GPing100
    //======END======

    VehicleNameString = "UT3 Manta"

    MaxYawRate=3.0
    UprightStiffness=450.000000 //The manual says it doesn't do anything
    UprightDamping=20.000000  //The manual says it doesn't do anything
    PitchTorqueMax=9.0  //18 is a bit too over the top  //13.5 as well
    RollTorqueStrafeFactor=100.0 //50.0 def UT2004
    RollTorqueMax=10.0 //25.0 //12.5 default 2004 value
    RollDamping=20.0 //30.0 def UT2004
     
    HornSounds(1)=sound'ONSVehicleSounds-S.Horns.LaCuchachaHorn'

    EntryRadius = 160.0

    ExitPositions(0)=(X=0,Y=160,Z=30)
    ExitPositions(1)=(X=0,Y=-160,Z=30)
	ExitPositions(2)=(X=160,Y=0,Z=30)
	ExitPositions(3)=(X=-160,Y=0,Z=30)
	ExitPositions(4)=(X=-160,Y=0,Z=-30)
	ExitPositions(5)=(X=160,Y=0,Z=-30)
	ExitPositions(6)=(X=0,Y=160,Z=-30)
	ExitPositions(7)=(X=0,Y=-160,Z=-30)

    HeadlightCoronaOffset=()
    HeadlightCoronaOffset(0)=(X=40.0,Y=0.0,Z=-30.0)
    HeadlightCoronaMaterial=Material'EmitterTextures.Flares.EFlareOY'
    
    HeadlightProjectorOffset=(X=43,Y=0,Z=-30)
	HeadlightProjectorRotation=(Yaw=0,Pitch=-1000,Roll=0)
	HeadlightProjectorMaterial=Texture'VMVehicles-TX.RVGroup.RVProjector'
	HeadlightProjectorScale=0.3
}
