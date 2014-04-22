/******************************************************************************
UT3Manta

Creation date: 2008-05-02 20:50
Last change: $Id$
Copyright (c) 2008, Wormbo and GreatEmerald
Copyright (c) 2012, 100GPing100
******************************************************************************/

class UT3Manta extends ONSHoverBike;

var Emitter DuckEffect;

//===============
// @100GPing100
/* Load the packages. */
#exec obj load file=..\Animations\UT3MantaAnims.ukx
#exec obj load file=..\Textures\UT3MantaTex.utx

/* Import all the sounds. */
#exec audio import group=Sounds file=..\Sounds\UT3Manta\Engine.wav
#exec audio import group=Sounds file=..\Sounds\UT3Manta\EngineStart.wav
#exec audio import group=Sounds file=..\Sounds\UT3Manta\EngineStop.wav
#exec audio import group=Sounds file=..\Sounds\UT3Manta\Jump.wav
#exec audio import group=Sounds file=..\Sounds\UT3Manta\Duck.wav
#exec audio import group=Sounds file=..\Sounds\UT3Manta\Impact01.wav
#exec audio import group=Sounds file=..\Sounds\UT3Manta\Impact02.wav
#exec audio import group=Sounds file=..\Sounds\UT3Manta\Explode.wav

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
	// 45º = 8192 RUU
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
	DrivePos = (X=-70,Y=0.0,Z=55.0);
	
	// Damage.
	DriverWeapons(0)=(WeaponClass=class'UT3MantaPlasmaGun',WeaponBone=barrel_rt);
	
	// Strings.
	VehiclePositionString = "in a UT3 Manta";
	
	// Movement.
	MaxPitchSpeed = 2000;
	HoverCheckDist = 155;
	AirControl = 1.5;
	
	// Sounds.
	IdleSound = Sound'UT3Manta.Sounds.Engine';
	StartUpSound = Sound'UT3Manta.Sounds.EngineStart';
	ShutDownSound = Sound'UT3Manta.Sounds.EngineStop';
	JumpSound = Sound'UT3Manta.Sounds.Jump';
	DuckSound = Sound'UT3Manta.Sounds.Duck';
	ImpactDamageSounds(0) = Sound'UT3Manta.Sounds.Impact01';
	ImpactDamageSounds(1) = Sound'UT3Manta.Sounds.Impact02';
	ImpactDamageSounds(2) = Sound'UT3Manta.Sounds.Impact01';
	ImpactDamageSounds(3) = Sound'UT3Manta.Sounds.Impact02';
	ImpactDamageSounds(4) = Sound'UT3Manta.Sounds.Impact01';
	ImpactDamageSounds(5) = Sound'UT3Manta.Sounds.Impact02';
	ImpactDamageSounds(6) = Sound'UT3Manta.Sounds.Impact01';
	ExplosionSounds(0) = Sound'UT3Manta.Sounds.Explode';
	ExplosionSounds(1) = Sound'UT3Manta.Sounds.Explode';
	ExplosionSounds(2) = Sound'UT3Manta.Sounds.Explode';
	ExplosionSounds(3) = Sound'UT3Manta.Sounds.Explode';
	ExplosionSounds(4) = Sound'UT3Manta.Sounds.Explode';
	// @100GPing100
	//======END======
	
	
	VehicleNameString = "UT3 Manta"

    MaxYawRate=3.0
    UprightStiffness=450.000000 //The manual says it doesn't do anything
	UprightDamping=20.000000  //The manual says it doesn't do anything
	PitchTorqueMax=9.0  //18 is a bit too over the top  //13.5 as well
	RollTorqueMax=25.0
	/*DriverWeapons(0)=(WeaponClass=class'UT3MantaPlasmaGun',WeaponBone=PlasmaGunAttachment);
	IdleSound=sound'UT3Manta.Sounds.Engine';
    StartUpSound=sound'UT3Vehicles.Manta.MantaEnter'
    ShutDownSound=sound'UT3Vehicles.Manta.MantaLeave'
    JumpSound=sound'UT3Vehicles.Manta.MantaJump'
    DuckSound=sound'UT3Vehicles.Manta.MantaDuck'*/
    HornSounds(1)=sound'ONSVehicleSounds-S.Horns.LaCuchachaHorn'
}
