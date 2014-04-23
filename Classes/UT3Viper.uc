//============================================================
// UT3 Viper (NecrisManta)
// Copyright (c) José Luís '100GPing100' 2012-2013
// Copyright (c) GreatEmerald 2014
// Contact: zeluis.100@gmail.com
// Website: http://www.100gping100.com/
//============================================================
class UT3Viper extends ONSHoverBike;

// Load packages.
#exec OBJ LOAD FILE=../Animations/UT3ViperAnims.ukx
#exec OBJ LOAD FILE=../Textures/UT3ViperTex.utx
#exec OBJ LOAD FILE=../StaticMeshes/UT3ViperSM.usx


/* Time, in seconds, that the driver has to activate the self-destruct. */
var int SelfDestructWindow;
/* Time, in seconds, the Viper will take, after boosting, to explode. */
var int SelfDestructForceDuration;
/* If true, the driver was ejected. */
var bool bEjected;
/* Damage type for the selfdestruct's explosion. */
var class<DamageType> DmgType_SelfDestruct;
/* Damage dealt by the self-destruct's explosion. */
var int SelfDestructDamage;
/* Radius for the self-destruct explosion. */
var int SelfDestructRadius;
/* Momentum for the self-destruct explosion. */
var int SelfDestructMomentum;
/* The force magnitude with wich to boost the vehicle in self-destruction. */
var float BoostForce;
/* How much time to wait, until it explodes, after boosting. */
var int SelfDestructStartTime;
/* The name of the animation currently being played. */
var string CurrentAnim;
/* The distance that the center of the vehicle needs to be from a surface to be able to jump. */
var int JumpTraceDist;
/* Force for the self-destruction boost. */
var vector BoostDir;
/* Indicates if we have calculated the boost force (so we do not calculate it each tick). */
var bool bGotBoostDir;
/* Normal gravity scale. */
var float NormalGravScale;
/* Gravity scale when gliding. */
var float GlidingGravScale;
/* Sound played when the driver gets ejected. */
var Sound DriverEjectSnd;
/* Warns the driver that he can eject to self-destruct. */
var Sound EjectReadySnd;
/* Sound played when self destructing ("danger" sound). */
var Sound SelfDestructSnd;
/* Max thrust force to apply when gliding. */
var float GlideMaxThrustForce;
/* Max strafe force to apply when gliding. */
var float GlideMaxStrafeForce;
/* Thrust force to normally apply. */
var float NormalMaxThrustForce;
/* Strafe force to normally apply. */
var float NormalMaxStrafeForce;
/* Whether or not the self destruct is armed. */
var bool bSelfDestructReady;
/* How much time the driver pressed rise. */
var float RiseTime;
/* How much time to press rise until we arm the self destruct. */
var float TimeToRiseForSelfDestruct;
/*  */
var bool bStoppedRise;
/* True from the instance we jump until we're able to jump again (TraceJump(JumpTraceDist) == true). */
var bool bJumped;


replication
{
	reliable if (bNetOwner)
		EjectReadySnd;
}


//===============================
// Self Destruct.
//===============================
simulated state PrepareSelfDestruct
{
Begin:
	PlayerController(Controller).ClientPlaySound(EjectReadySnd,, 1.0);
	SelfDestructStartTime = Level.TimeSeconds;
}

simulated state SelfDestruct
{
	event Touch(Actor Other)
	{
		Other.TakeDamage(600, OldDriver, Other.Location, 200000 * Normal(Velocity), DmgType_SelfDestruct);
		SelfDestructExplode();

		TextToSpeech("Bullseye!", 1.0);

		// @TODO: Maybe add "Bullseye!"?
	}

	event Timer()
	{
		SelfDestructExplode();
	}

	event Tick(float DeltaTime)
	{
	}
Begin:
	EjectDriver();
	bEjected = true;
	PlaySound(SelfDestructSnd, SLOT_None, 1.5, true);

	SetTimer(SelfDestructForceDuration, false);
	/*Sleep(SelfDestructForceDuration);
	SelfDestructExplode();*/
}

function SelfDestructExplode()
{
	Health = -100000;
	PlaySound(ExplosionSounds[Rand(5)], SLOT_Pain, 1.0, true);
	HurtRadius(SelfDestructDamage, SelfDestructRadius, DmgType_SelfDestruct, SelfDestructMomentum, Location);
	/*PlaySound(ExplosionSounds[Rand(5)], SLOT_Pain, 1.0, true);
	HurtRadius(SelfDestructDamage, SelfDestructRadius, DmgType_SelfDestruct, SelfDestructMomentum, Location);
	TakeDamage(SelfDestructDamage*3, OldDriver, Location, vect(0,0,0), DmgType_SelfDestruct);*/
}

function EjectDriver()
{
	local Pawn OldPawn;
	local Vector EjectVel;
	local Inv_SelfDestruct SelfDestructInv;
	local Inv_Ejection EjectionInv;

	LoopAnim('jumpidle', 0.8, 0.5);

	OldPawn = Driver;

	KDriverLeave(true);
	bEjected = true;

	if (OldPawn == none) {
		return;
	}

	EjectVel = VRand();
	EjectVel.Z = 0;
	EjectVel = (Normal(EjectVel) * 0.2 + Vect(0,0,1)) * EjectMomentum;

	OldPawn.Velocity = EjectVel;

	PlaySound(DriverEjectSnd, SLOT_None, 1.0, true);

	// Do not take self destruct damage
	SelfDestructInv = Spawn(class'Inv_SelfDestruct', OldPawn,,, Rot(0,0,0));
	SelfDestructInv.GiveTo(OldPawn);
	EjectionInv = Spawn(class'Inv_Ejection', OldPawn,,, Rot(0,0,0));
	EjectionInv.GiveTo(OldPawn);
}
//===============================
// END Self Destruct.
//===============================

simulated function KApplyForce(out Vector Force, out Vector Torque)
{
	super.KApplyForce(Force, Torque);

	if (bDriving && JumpCountdown > 0.0) { // jump
		Force += Vect(0,0,1) * JumpForceMag;
		PlayAnim('JumpStart', 1.2, 0.15);
		CurrentAnim = "JumpStart";

		if (KGetActorGravScale() == GlidingGravScale) {
			// Do not jump too much.
			Force += vect(0,0,-0.5) * Mass * GlidingGravScale;
		}
	}
	/* THIS SHOULD BE UP THERE RIGHT?
	if (KGetActorGravScale() == GlidingGravScale) // Do not jump too much.
		Force += vect(0,0,-0.5) * Mass * GlidingGravScale;
		*/

	if (bEjected) {
		if (bGotBoostDir == false) {
			// only calculate 'BoostDir' once
			BoostDir = GetBoostForce();
			bGotBoostDir = true;
		}
		Force = BoostDir;
	}
}

function vector GetBoostForce()
{
	local Rotator AimRotation;

	AimRotation.Pitch = Weapons[0].CurrentAim.Pitch;
	AimRotation.Yaw = Rotation.Yaw;
	AimRotation.Roll = Rotation.Roll;

	return vector(AimRotation) * BoostForce;
}

simulated function CheckJumpDuck()
{
	local Emitter JumpEffect;

    if (JumpCountdown <= 0.0 && (Rise > 0 || bWeaponIsAltFiring) && Level.TimeSeconds - JumpDelay >= LastJumpTime && TraceJump(JumpTraceDist)) {
		bJumped = true;
        PlaySound(JumpSound, SLOT_Misc, 1.0, true);

        if (Role == ROLE_Authority) {
			DoBikeJump = !DoBikeJump;
		}

        if(Level.NetMode != NM_DedicatedServer) {
            JumpEffect = Spawn(class'ONSHoverBikeJumpEffect');
            JumpEffect.SetBase(Self);
            ClientPlayForceFeedback(JumpForce);
        }

    	if (AIController(Controller) != none) {
    		Rise = 0;
    	}

    	LastJumpTime = Level.TimeSeconds;
    }
}

function AltFire(optional float F)
{
	super(Vehicle).AltFire(F);

	if (bSelfDestructReady && Level.TimeSeconds - SelfDestructStartTime <= SelfDestructWindow) {
		GoToState('SelfDestruct');
	}
}

simulated event DrivingStatusChanged()
{
	local int i;

	super(ONSHoverCraft).DrivingStatusChanged();

	if (Driver == none && !bEjected) {
		PlayAnim('InactiveIdle', 0.8, 0.5);
		CurrentAnim = "InactiveIdle";
	} else if (Driver == none && bEjected) {
		Enable('Tick');
	}

	if (bDriving && Level.NetMode != NM_DedicatedServer && BikeDust.Length == 0 && bDropDetail == false) {
		BikeDust.Length = BikeDustOffset.Length;
		BikeDustLastNormal.Length = BikeDustOffset.Length;

		for (i = 0; i < BikeDust.Length; i++) {
			if (BikeDust[i] == none) {
				BikeDust[i] = Spawn(class'Emitter_ViperDust', self,, Location + (BikeDustOffset[i] >> Rotation));
				BikeDust[i].SetDustColor(Level.DustColor);
				BikeDustLastNormal[i] = Vect(0,0,1);
			}
		}
	} else {
		if (Level.NetMode != NM_DedicatedServer) {
			for (i = 0; i < BikeDust.Length; i++) {
				BikeDust[i].Destroy();
			}

			BikeDust.Length = 0;
		}

		JumpCountDown = 0.0;
	}

	if (bDriving) {
		bCanBeBaseForPawns = false;
	} else {
		bCanBeBaseForPawns = true;
	}
}

function UsedBy(Pawn user)
{
	local bool bSuccess;

	if (Driver != none) {
		return;
	}

	// Enter vehicle code
	bSuccess = TryToDrive(User);

	if (bSuccess) {
		LoopAnim('SlowIdle', 0.8, 0.5);
		CurrentAnim = "SlowIdle";
	}
}

simulated function Tick(float DeltaTime)
{
	if (bEjected == false) {
		Animate();
		CheckGliding();
	}

	if (bJumped == true && Level.TimeSeconds - JumpDelay >= LastJumpTime && TraceJump(JumpTraceDist)) {
		bJumped = false;
	}

	if (bSelfDestructReady == false && bJumped == true && bStoppedRise == false && (Rise > 0 || bWeaponIsAltFiring)) {
		RiseTime += DeltaTime;

		if (RiseTime >= 1.1) {
			RiseTime = 0.0;
			bSelfDestructReady = true;
			GoToState('PrepareSelfDestruct');
		}
	} else if (bJumped == true && (Rise <= 0 || !bWeaponIsAltFiring)) {
		bStoppedRise = true;
	} else if (bSelfDestructReady == true && Level.TimeSeconds - SelfDestructStartTime > SelfDestructWindow) {
		bSelfDestructReady = false;
		bStoppedRise = false;
	}

	if (bJumped == false) {
		// If we're on ground, these get reset.
		bStoppedRise = false;
		bSelfDestructReady = false;
		RiseTime = 0.0;
	}

	super.Tick(DeltaTime);
}

function CheckGliding()
{
	if ((Rise > 0 || bWeaponIsAltFiring) && KGetActorGravScale() != GlidingGravScale) {
		KSetActorGravScale(GlidingGravScale);
		MaxThrustForce = GlideMaxThrustForce;
		MaxStrafeForce = GlideMaxStrafeForce;
	} else if (Rise <= 0 && !bWeaponIsAltFiring && KGetActorGravScale() != NormalGravScale) {
		KSetActorGravScale(NormalGravScale);
		MaxThrustForce = NormalMaxThrustForce;
		MaxStrafeForce = NormalMaxStrafeForce;
	}
}

function Animate() {
	/* Animations list:
	FastIdle_bw
	FastIdle_fw
	FastIdle_lf
	FastIdle_rt
	InActiveIdle
	JumpEnd
	JumpIdle
	JumpStart
	SlowDown
	SlowIdle
	SpeedUp
	*/
	local bool bIsOnGround;
	local bool bIsAnimating;

	bIsOnGround = IsOnGround();
	bIsAnimating = IsAnimating();

	if ((Rise > 0 || bWeaponIsAltFiring) && CurrentAnim != "JumpIdle" && TraceJump(JumpTraceDist) == false) {
		LoopAnim('JumpIdle', 1, 0.5);
		CurrentAnim = "JumpIdle";
	} else if (Rise <= 0 && bWeaponIsAltFiring == false && CurrentAnim == "JumpIdle") {
		PlayAnim('JumpEnd', 0.8, 0.1);
		CurrentAnim = "JumpEnd";
	} else if (CurrentAnim == "JumpStart" && bIsAnimating == false) {
		PlayAnim('JumpEnd', 0.5, 0);
		CurrentAnim = "JumpEnd";
	} else if (CurrentAnim == "JumpEnd" && bIsAnimating == false) {
		LoopAnim('SlowIdle', 1, 0.2);
		CurrentAnim = "SlowIdle";
	} else if (bIsOnGround == true && OutputStrafe == 1.0 && CurrentAnim != "FastIdle_lf") {
		LoopAnim('FastIdle_lf', 0.8, 0.7);
		CurrentAnim = "FastIdle_lf";
	} else if (bIsOnGround == true && OutputStrafe == -1.0 && CurrentAnim != "FastIdle_rt") {
		LoopAnim('FastIdle_rt', 0.8, 0.7);
		CurrentAnim = "FastIdle_rt";
	} else if (bIsOnGround == true && OutputStrafe == 0.0 && OutputThrust == 0.0 && CurrentAnim != "SlowIdle") {
		LoopAnim('SlowIdle', 1, 0.5);
		CurrentAnim = "SlowIdle";
	} else if (bIsOnGround == true && OutputStrafe == 0.0 && OutputThrust == 1.0 && CurrentAnim == "SlowIdle") {
		PlayAnim('SpeedUp', 1.2, 0.2);
		CurrentAnim = "SpeedUp";
	} else if (bIsOnGround == true && OutputStrafe == 0.0 && OutputThrust == 1.0 && CurrentAnim == "SpeedUp" && bIsAnimating == false) {
		LoopAnim('FastIdle_fw', 1, 0.1);
		CurrentAnim = "FastIdle_fw";
	} else if (bIsOnGround == true && OutputStrafe == 0.0 && OutputThrust == -1.0 && CurrentAnim == "SlowIdle") {
		PlayAnim('FastIdle_bw', 1, 0.3);
		CurrentAnim = "FastIdle_bw";
	} else if (bIsOnGround == true && OutputStrafe == 0.0 && OutputThrust == -1.0 && CurrentAnim == "FastIdle_fw") {
		PlayAnim('SlowDown', 1, 0.2);
		CurrentAnim = "SlowDown";
	} else if (bIsOnGround == true && OutputStrafe == 0.0 && OutputThrust == -1.0 && CurrentAnim == "SlowDown" && bIsAnimating == false) {
		LoopAnim('FastIdle_bw', 1, 0.1);
		CurrentAnim = "FastIdle_bw";
	} else if (bIsOnGround == true && OutputStrafe == 0.0 && OutputThrust == 1.0 && (CurrentAnim == "FastIdle_rt" || CurrentAnim == "FastIdle_lf")) {
		LoopAnim('FastIdle_fw', 1, 0.5);
		CurrentAnim = "FastIdle_fw";
	} else if (bIsOnGround == true && OutputStrafe == 0.0 && OutputThrust == -1.0 && (CurrentAnim == "FastIdle_rt" || CurrentAnim == "FastIdle_lf")) {
		LoopAnim('FastIdle_bw', 1, 0.5);
		CurrentAnim = "FastIdle_bw";
	} else if ((CurrentAnim == "FastIdle_rt" || CurrentAnim == "FastIdle_lf") && TraceJump(JumpTraceDist * 2.0) == false) {
		LoopAnim('SlowIdle', 1, 0.6);
		CurrentAnim = "SlowIdle";
	}
}

function bool IsOnGround()
{
	local KarmaParams KP;
	local int i;

	KP = KarmaParams(KParams);
	for (i = 0; i < KP.Repulsors.Length; i++) {
		if (KP.Repulsors[i] != none && KP.Repulsors[i].bRepulsorInContact == true) {
			return true;
		}
	}

	return false;
}

function bool TraceJump(int TraceDist)
{
	local Vector HitLocation, HitNormal;
	local Vector TraceEnd, TraceStart;
	local Actor HitActor;

	TraceStart = Location;
	TraceEnd = TraceStart;
	TraceEnd.Z -= TraceDist;

	HitActor = Trace(HitLocation, HitNormal, TraceEnd, TraceStart, true);

	return (HitActor != none);
}

function bool TryToDrive(Pawn P)
{
	return (bEjected == false && super.TryToDrive(P));
}

event Touch(Actor Other)
{
	if (bEjected == true) {
		Other.TakeDamage(600, OldDriver, Other.Location, 200000 * Normal(Velocity), DmgType_SelfDestruct);
		SelfDestructExplode();

		// @TODO: Maybe add "Bullseye!"?
	}

	super.Touch(Other);
}

event TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType)
{
	if (bEjected) {
		Damage = Damage * 2;
	}

	// @TODO: Maybe add "Last Second Saved!"?

	super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType);
}

//===========================
// AI Interface.
function ChooseFireAt(Actor A)
{
	if (Pawn(Controller.Focus) != none && Vehicle(Controller.Focus) == none
		&& Controller.MoveTarget == Controller.Focus && Controller.InLatentExecution(Controller.LATENT_MOVETOWARD)
		&& VSize(Controller.FocalPoint - Location) < 800 && Controller.LineOfSightTo(Controller.Focus)) {
		Fire(0);
	} else if (Health < HealthMax / 2
		&& (DestroyableObjective(Controller.Focus) != None || (Vehicle(Controller.Focus) != None && Vehicle(Controller.Focus).Health >= 300))
		&& VSize(Controller.FocalPoint - Location) <= 500) {
		GoToState('BotSelfDestruct');
	}

	if (Controller.LineOfSightTo(Controller.Focus)) {
		Fire(0);
	}
}

state BotSelfDestruct
{
	// We perform the jump here.
	function BeginState()
	{
		local Emitter JumpEffect;

		PlaySound(JumpSound, SLOT_Misc, 1.0, true);

		if (Role == ROLE_Authority) {
			DoBikeJump = !DoBikeJump;
		}

		if (Level.NetMode != NM_DedicatedServer) {
			JumpEffect = Spawn(class'ONSHoverBikeJumpEffect');
			JumpEffect.SetBase(Self);
		}

		Rise = 0;
	}

// Perform the self destruct here.
Begin:
	Sleep(TimeToRiseForSelfDestruct + 0.1);
	GoToState('SelfDestruct');
}
// AI Interface End.
//============END============


DefaultProperties
{
	// Looks.
	Mesh=Mesh'UT3ViperAnims.VH_NecrisManta';
	DestroyedVehicleMesh=StaticMesh'UT3ViperSM.UT3Viper';
	RedSkin=Shader'UT3ViperTex.Viper.ViperSkin';
	BlueSkin=Shader'UT3ViperTex.Viper.ViperSkinBlue';
	HeadlightCoronaMaxSize=0.0;
	BikeDustOffset(0)=(X=50.00,Y=0.0,Z=10.0)
	BikeDustOffset(1)=(X=-25.0,Y=0.0,Z=10.0)

	// Weapons.
	DriverWeapons(0)=(WeaponClass=Class'Weap_ViperGun',WeaponBone="FrontBody")


	// Health
	Health=200;
	HealthMax=200;

	// Strings.
	VehiclePositionString="in a UT3 Viper";
	VehicleNameString="UT3 Viper";

	// Movement
	GroundSpeed=1000.0;
	AirSpeed=2400.0;
	JumpDuration=0.12;
	JumpDelay=2.0;
	MomentumMult=2.2; // 3.2
	JumpForceMag=60.0; // 67.5
	JumpTraceDist=175.0;
	NormalGravScale = 0.9;
	GlidingGravScale = 0.1;
	GlideMaxThrustForce = 1.0;
	GlideMaxStrafeForce = 1.0;
	NormalMaxThrustForce = 27.0;
	NormalMaxStrafeForce = 20.0;

	// Sound.
	IdleSound=Sound'UT3A_Vehicle_Viper.Sounds.A_Vehicle_Viper_EngineLoop';
	StartUpSound=Sound'UT3A_Vehicle_Viper.Sounds.A_Vehicle_Viper_Start';
	ShutDownSound=Sound'UT3A_Vehicle_Viper.Sounds.A_Vehicle_Viper_Stop';
	JumpSound=Sound'UT3A_Vehicle_Manta.Sounds.A_Vehicle_Manta_Jump';
	DriverEjectSnd=Sound'UT3A_Vehicle_Scorpion.Sounds.A_Vehicle_Scorpion_Eject01';
	EjectReadySnd=Sound'UT3A_Vehicle_Scorpion.Sounds.A_Vehicle_Scorpion_EjectReadyBeep';
	SelfDestructSnd=Sound'UT3A_Vehicle_Viper.Sounds.A_Vehicle_Viper_SelfDestruct';
    ExplosionSounds=()
	ExplosionSounds(0)=Sound'UT3A_Vehicle_Viper.Sounds.A_Vehicle_Viper_Explosion';
    ImpactDamageSounds=();
	ImpactDamageSounds(0)=Sound'UT3A_Vehicle_Viper.Sounds.A_Vehicle_Viper_Collision';
	MaxPitchSpeed=1000;
	SoundVolume=200;
	SoundRadius=900;

	// SelfDestruct.
	SelfDestructWindow = 3;
	SelfDestructForceDuration = 1;
	DmgType_SelfDestruct = Class'DmgType_SelfDestruct'
	SelfDestructDamage = 800;
	SelfDestructRadius = 600;
	SelfDestructMomentum = 200000;
	BoostForce = 500; // 200
	TimeToRiseForSelfDestruct = 1.1;

	// Misc.
	bCanBeBaseForPawns = true;
	CollisionHeight=50;
	CollisionRadius=220;
	DrivePos=(X=10.0,Y=0.0,Z=50.0);
	ObjectiveGetOutDist=750.0;
	MaxDesireability=0.6;
	LinkHealMult=0.35;
	MeleeRange=-100.0;
	HoverCheckDist=100; // 150

	TurnDamping=55;
	TurnTorqueFactor=750.0;
	TurnTorqueMax=1000.0;
	MaxYawRate=150.0;

	RollTorqueTurnFactor=200.0;
	RollTorqueStrafeFactor=65.0;
	RollTorqueMax=200.0;
	RollDamping=20;

	UpDamping=0.0;

	PitchTorqueMax=35.0;
}
