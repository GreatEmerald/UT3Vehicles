//============================================================
// UT3 Viper (NecrisManta)
// Credits: 100GPing100(José Luís)
// Copytight José Luís, 2012
// Contact: zeluis.100@gmail.com
//============================================================
class UT3Viper extends ONSHoverBike;


// Load packages.
#exec OBJ LOAD FILE=..\Animations\UT3ViperAnims.ukx
#exec OBJ LOAD FILE=..\Textures\UT3ViperTex.utx
#exec OBJ LOAD FILE=..\StaticMeshes\UT3ViperSM.usx
// Import sounds.
#exec audio import group=Sounds file=..\Sounds\UT3Viper\Eject.wav
#exec audio import group=Sounds file=..\Sounds\UT3Viper\EjectReady.wav
#exec audio import group=Sounds file=..\Sounds\UT3Viper\Engine.wav
#exec audio import group=Sounds file=..\Sounds\UT3Viper\EnterVehicle.wav
#exec audio import group=Sounds file=..\Sounds\UT3Viper\ExitVehicle.wav
#exec audio import group=Sounds file=..\Sounds\UT3Viper\Explode.wav
#exec audio import group=Sounds file=..\Sounds\UT3Viper\Impact.wav
#exec audio import group=Sounds file=..\Sounds\UT3Viper\Jump.wav
#exec audio import group=Sounds file=..\Sounds\UT3Viper\SelfDestruct.wav


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
/* How much time to wait, until the it explodes, after boosting. */
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
		
		// Maybe add "Bullseye!"?
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
	
	if (OldPawn == None)
		return;
	
	EjectVel = VRand();
	EjectVel.Z = 0;
	EjectVel = (Normal(EjectVel) * 0.2 + Vect(0,0,1)) * EjectMomentum;
	
	OldPawn.Velocity = EjectVel;
	
	PlaySound(DriverEjectSnd, SLOT_None, 1.0, true);
	
	// Absorve damage.
	SelfDestructInv = Spawn(Class'Inv_SelfDestruct', OldPawn,,, Rot(0,0,0));
	SelfDestructInv.GiveTo(OldPawn);
	EjectionInv = Spawn(Class'Inv_Ejection', OldPawn,,, Rot(0,0,0));
	EjectionInv.GiveTo(OldPawn);
}
//===============================
// END Self Destruct.
//===============================

simulated function KApplyForce(out Vector Force, out Vector Torque)
{
	Super.KApplyForce(Force, Torque);
	
	if (bDriving && JumpCountdown > 0.0)
	{
		Force += Vect(0,0,1) * JumpForceMag;
		PlayAnim('JumpStart', 1.2, 0.15);
		CurrentAnim = "JumpStart";
	}
	if (KGetActorGravScale() == GlidingGravScale) // Do not jump too much.
		Force += vect(0,0,-0.5) * Mass * GlidingGravScale;
	
	if (bEjected)
	{
		if (!bGotBoostDir)
		{
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
	
	// If we are on the ground, and press Rise or AltFire, and we're not currently in the middle of a jump, start a new one.
    if (JumpCountdown <= 0.0 && (Rise > 0 || bWeaponIsAltFiring) && TraceJump(JumpTraceDist) && Level.TimeSeconds - JumpDelay >= LastJumpTime)
    {
		bJumped = true;
        PlaySound(JumpSound, SLOT_Misc, 1.0, true);

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
}
function AltFire(optional float F)
{
	Super(Vehicle).AltFire(F);
	
	if (bSelfDestructReady && Level.TimeSeconds - SelfDestructStartTime <= SelfDestructWindow)
		GoToState('SelfDestruct');
}
simulated event DrivingStatusChanged()
{
	local int i;
	
	Super(ONSHoverCraft).DrivingStatusChanged();
	
	if (Driver == None && !bEjected)
	{
		PlayAnim('InactiveIdle', 0.8, 0.5);
		CurrentAnim = "InactiveIdle";
	}
	else if (Driver == None && bEjected)
		Enable('Tick');
	
	if (bDriving && Level.NetMode != NM_DedicatedServer && BikeDust.Length == 0 && !bDropDetail)
	{
		BikeDust.Length = BikeDustOffset.Length;
		BikeDustLastNormal.Length = BikeDustOffset.Length;
		
		for (i = 0; i < BikeDust.Length; i++)
		{
			if (BikeDust[i] == None)
			{
				BikeDust[i] = Spawn(Class'Emitter_ViperDust', self,, Location + (BikeDustOffset[i] >> Rotation));
				BikeDust[i].SetDustColor(Level.DustColor);
				BikeDustLastNormal[i] = Vect(0,0,1);
			}
		}
	}
	else
	{
		if (Level.NetMode != NM_DedicatedServer)
		{
			for (i = 0; i < BikeDust.Length; i++)
				BikeDust[i].Destroy();
			
			BikeDust.Length = 0;
		}
		JumpCountDown = 0.0;
	}
	
	if (bDriving)
		bCanBeBaseForPawns = false;
	else
		bCanBeBaseForPawns = true;
}
function UsedBy(Pawn user)
{
	local bool bSuccess;
	
	if (Driver != None)
		return;
	
	// Enter vehicle code
	bSuccess = TryToDrive(User);
	
	if (bSuccess)
	{
		LoopAnim('SlowIdle', 0.8, 0.5);
		CurrentAnim = "SlowIdle";
	}
}
simulated function Tick(float DeltaTime)
{
	if (!bEjected)
	{
		Animate();
		CheckGliding();
	}
	
	if (bJumped && Level.TimeSeconds - JumpDelay >= LastJumpTime && TraceJump(JumpTraceDist))
		bJumped = false;
	
	if (!bSelfDestructReady && bJumped && !bStoppedRise && (Rise > 0 || bWeaponIsAltFiring))
	{
		RiseTime += DeltaTime;
		
		if (RiseTime >= 1.1)
		{
			RiseTime = 0.0;
			bSelfDestructReady = true;
			GoToState('PrepareSelfDestruct');
		}
	}
	else if (bJumped && (Rise <= 0 || !bWeaponIsAltFiring))
		bStoppedRise = true;
	else if (bSelfDestructReady && Level.TimeSeconds - SelfDestructStartTime > SelfDestructWindow)
	{
		bSelfDestructReady = false;
		bStoppedRise = false;
	}
	
	if (!bJumped)
	{
		// If we're on ground, these get reset.
		bStoppedRise = false;
		bSelfDestructReady = false;
		RiseTime = 0.0;
	}
	
	Super.Tick(DeltaTime);
}
function CheckGliding()
{
	if ((Rise > 0 || bWeaponIsAltFiring) && KGetActorGravScale() != GlidingGravScale)
	{
		KSetActorGravScale(GlidingGravScale);
		MaxThrustForce = GlideMaxThrustForce;
		MaxStrafeForce = GlideMaxStrafeForce;
	}
	else if (Rise <= 0 && !bWeaponIsAltFiring && KGetActorGravScale() != NormalGravScale)
	{
		KSetActorGravScale(NormalGravScale);
		MaxThrustForce = NormalMaxThrustForce;
		MaxStrafeForce = NormalMaxStrafeForce;
	}
}
function Animate()
{
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
	if ((Rise > 0 || bWeaponIsAltFiring) && CurrentAnim != "JumpIdle" && !TraceJump(JumpTraceDist))
	{
		LoopAnim('JumpIdle', 1, 0.5);
		CurrentAnim = "JumpIdle";
	}
	else if (Rise <= 0 && !bWeaponIsAltFiring && CurrentAnim == "JumpIdle")
	{
		PlayAnim('JumpEnd', 0.8, 0.1);
		CurrentAnim = "JumpEnd";
	}
	else if (CurrentAnim == "JumpStart" && !IsAnimating())
	{
		PlayAnim('JumpEnd', 0.5, 0);
		CurrentAnim = "JumpEnd";
	}
	else if (CurrentAnim == "JumpEnd" && !IsAnimating())
	{
		LoopAnim('SlowIdle', 1, 0.2);
		CurrentAnim = "SlowIdle";
	}
	else if (IsOnGround() && OutputStrafe == 1.0 && CurrentAnim != "FastIdle_lf")
	{
		LoopAnim('FastIdle_lf', 0.8, 0.7);
		CurrentAnim = "FastIdle_lf";
	}
	else if (IsOnGround() && OutputStrafe == -1.0 && CurrentAnim != "FastIdle_rt")
	{
		LoopAnim('FastIdle_rt', 0.8, 0.7);
		CurrentAnim = "FastIdle_rt";
	}
	else if (IsOnGround() && OutputStrafe == 0.0 && OutputThrust == 0.0 && CurrentAnim != "SlowIdle")
	{
		LoopAnim('SlowIdle', 1, 0.5);
		CurrentAnim = "SlowIdle";
	}
	else if (IsOnGround() && OutputStrafe == 0.0 && OutputThrust == 1.0 && CurrentAnim == "SlowIdle")
	{
		PlayAnim('SpeedUp', 1.2, 0.2);
		CurrentAnim = "SpeedUp";
	}
	else if (IsOnGround() && OutputStrafe == 0.0 && OutputThrust == 1.0 && CurrentAnim == "SpeedUp" && !IsAnimating())
	{
		LoopAnim('FastIdle_fw', 1, 0.1);
		CurrentAnim = "FastIdle_fw";
	}
	else if (IsOnGround() && OutputStrafe == 0.0 && OutputThrust == -1.0 && CurrentAnim == "SlowIdle")
	{
		PlayAnim('FastIdle_bw', 1, 0.3);
		CurrentAnim = "FastIdle_bw";
	}
	else if (IsOnGround() && OutputStrafe == 0.0 && OutputThrust == -1.0 && CurrentAnim == "FastIdle_fw")
	{
		PlayAnim('SlowDown', 1, 0.2);
		CurrentAnim = "SlowDown";
	}
	else if (IsOnGround() && OutputStrafe == 0.0 && OutputThrust == -1.0 && CurrentAnim == "SlowDown" && !IsAnimating())
	{
		LoopAnim('FastIdle_bw', 1, 0.1);
		CurrentAnim = "FastIdle_bw";
	}
	else if (IsOnGround() && OutputStrafe == 0.0 && OutputThrust == 1.0 && (CurrentAnim == "FastIdle_rt" || CurrentAnim == "FastIdle_lf"))
	{
		LoopAnim('FastIdle_fw', 1, 0.5);
		CurrentAnim = "FastIdle_fw";
	}
	else if (IsOnGround() && OutputStrafe == 0.0 && OutputThrust == -1.0 && (CurrentAnim == "FastIdle_rt" || CurrentAnim == "FastIdle_lf"))
	{
		LoopAnim('FastIdle_bw', 1, 0.5);
		CurrentAnim = "FastIdle_bw";
	}
	else if (!TraceJump(JumpTraceDist * 2.0) && (CurrentAnim == "FastIdle_rt" || CurrentAnim == "FastIdle_lf"))
	{
		LoopAnim('SlowIdle', 1, 0.6);
		CurrentAnim = "SlowIdle";
	}
}
function bool IsOnGround()
{
	local KarmaParams KP;
	local int i;
	
	KP = KarmaParams(KParams);
	for(i=0; i<KP.Repulsors.Length; i++)
		if( KP.Repulsors[i] != None && KP.Repulsors[i].bRepulsorInContact )
			return true;
	
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
	
	HitActor = Trace(HitLocation, HitNormal,
		TraceEnd, TraceStart, true);
	
	if (HitActor == None)
		return false;
	else
		return true;
}
function bool TryToDrive(Pawn P)
{
	return !bEjected && Super.TryToDrive(P);
}
event Touch(Actor Other)
{
	if (bEjected)
	{
		Other.TakeDamage(600, OldDriver, Other.Location, 200000 * Normal(Velocity), DmgType_SelfDestruct);
		SelfDestructExplode();
		
		// Maybe add "Bullseye!"?
	}
	
	Super.Touch(Other);
}
event TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType)
{
	if (bEjected)
		Damage *= 2;
	
	// Maybe add "Last Second Saved!"?
	
	Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType);
}

//===========================
// AI Interface.
function ChooseFireAt(Actor A)
{
	if (Pawn(Controller.Focus) != None && Vehicle(Controller.Focus) == None
		&& Controller.MoveTarget == Controller.Focus && Controller.InLatentExecution(Controller.LATENT_MOVETOWARD)
		&& VSize(Controller.FocalPoint - Location) < 800 && Controller.LineOfSightTo(Controller.Focus))
		Fire(0);
	else if (Health < HealthMax / 2 && (DestroyableObjective(Controller.Focus) != None || (Vehicle(Controller.Focus) != None && Vehicle(Controller.Focus).Health >= 300)) && VSize(Controller.FocalPoint - Location) <= 500)
		GoToState('BotSelfDestruct');
	
	if (Controller.LineOfSightTo(Controller.Focus))
		Fire(0);
}

state BotSelfDestruct
{
	// We do the jump here.
	function BeginState()
	{
		local Emitter JumpEffect;
		
		PlaySound(JumpSound, SLOT_Misc, 1.0, true);
		
		if (Role == ROLE_Authority)
			DoBikeJump = !DoBikeJump;
	
		if (Level.NetMode != NM_DedicatedServer)
		{
			JumpEffect = Spawn(class'ONSHoverBikeJumpEffect');
			JumpEffect.SetBase(Self);
		}
		Rise = 0;
	}
	
// And the self destruct we do here.
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
	DriverWeapons(0)=(WeaponClass=Class'UT3Viper.Weap_ViperGun',WeaponBone="FrontBody")
	
	
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
	IdleSound=Sound'UT3Viper.Sounds.Engine';
	StartUpSound=Sound'UT3Viper.Sounds.EnterVehicle';
	ShutDownSound=Sound'UT3Viper.Sounds.ExitVehicle';
	JumpSound=Sound'UT3Viper.Sounds.Jump';
	DriverEjectSnd=Sound'UT3Viper.Sounds.Eject';
	EjectReadySnd=Sound'UT3Viper.Sounds.EjectReady';
	SelfDestructSnd=Sound'UT3Viper.Sounds.SelfDestruct';
	ExplosionSounds(0)=Sound'UT3Viper.Sounds.Explode';
	ExplosionSounds(1)=Sound'UT3Viper.Sounds.Explode';
	ExplosionSounds(2)=Sound'UT3Viper.Sounds.Explode';
	ExplosionSounds(3)=Sound'UT3Viper.Sounds.Explode';
	ExplosionSounds(4)=Sound'UT3Viper.Sounds.Explode';
	ImpactDamageSounds(0)=Sound'UT3Viper.Sounds.Impact';
	ImpactDamageSounds(1)=Sound'UT3Viper.Sounds.Impact';
	ImpactDamageSounds(2)=Sound'UT3Viper.Sounds.Impact';
	ImpactDamageSounds(3)=Sound'UT3Viper.Sounds.Impact';
	ImpactDamageSounds(4)=Sound'UT3Viper.Sounds.Impact';
	ImpactDamageSounds(5)=Sound'UT3Viper.Sounds.Impact';
	ImpactDamageSounds(6)=Sound'UT3Viper.Sounds.Impact';
	MaxPitchSpeed=1000;
	SoundVolume=200;
	SoundRadius=900;
	
	// SelfDestruct.
	SelfDestructWindow = 3;
	SelfDestructForceDuration = 1;
	DmgType_SelfDestruct = Class'UT3Viper.DmgType_SelfDestruct'
	SelfDestructDamage = 750;
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
