/******************************************************************************
UT3HellfireSPMA

Creation date: 2008-05-02 20:50
Last change: $Id$
Copyright (c) 2009, Wormbo
Copyright (c) 2013-2014, José Luís '100GPing100'
******************************************************************************/

class UT3HellfireSPMA extends ONSArtillery;


//=============================================================================
// Inports
//=============================================================================

#exec obj load file=Sounds/include/UT3SPMA.uax package=UT3Style.SPMA
#exec obj load file=..\Animations\UT3SPMAAnims.ukx


//=============================================================================
// Properties
//=============================================================================

var float MaxDeploySpeed;
var float DeployTime, UndeployTime;
var Sound DeploySound, UndeploySound;
var IntBox DeployIconCoords;


//=============================================================================
// Variables
//=============================================================================

var enum EDeployState {
	DS_Undeployed,
	DS_Deploying,
	DS_Deployed,
	DS_Undeploying
} DeployState, LastDeployState;
var bool bBotDeploy; // delayed bot deploy flag

var float LastDeployStartTime, LastDeployCheckTime, LastDeployAttempt;
var bool bDrawCanDeployTooltip;

var rotator CannonAim;

//=============================================================================
// Replication
//=============================================================================

replication
{
	reliable if (Role < ROLE_Authority)
		ServerToggleDeploy;
	
	reliable if (bNetDirty)
		DeployState;
		
	reliable if (!bNetOwner)
		CannonAim;
}


simulated function DrawHUD(Canvas C)
{
	local PlayerController PC;

	Super.DrawHUD(C);

	// don't draw if we are dead, scoreboard is visible, etc
	PC = PlayerController(Controller);
	if (Health < 1 || PC == None || PC.myHUD == None || PC.MyHUD.bShowScoreboard || DeployState != DS_Undeployed)
		return;

	// draw deploy tooltip
	if (bDrawCanDeployTooltip)
		class'UT3HudOverlay'.static.DrawToolTip(C, PC, "Jump", C.ClipX * 0.5, C.ClipY * 0.92, DeployIconCoords);
}


simulated function Tick(float DeltaTime)
{
	local DestroyableObjective ObjectiveTarget;
	local int i;
	/* 100GPing100 BEGIN */
	local rotator rot;
	/* 100GPing100 END */
	
	Super(ONSWheeledCraft).Tick(DeltaTime);
	
	/* 100GPing100 BEGIN */
	if (bStationary == false) {
		// Secondary turret rotation
		//rot.Yaw = Weapons[0].WeaponFireRotation.Yaw;
		//SetBoneRotation('SecondaryTurret_YawLift', rot);
	}
	/* 100GPing100 END */
	
	if (bBotDeploy || Role == ROLE_Authority && IsHumanControlled() && Rise > 0 && Level.TimeSeconds - LastDeployAttempt > 0.1) {
		if (bBotDeploy) {
			Throttle = 0;
			Steering = 0;
			Rise = 1; // handbrake to quickly slow down
		}
		ServerToggleDeploy();
		if (bBotDeploy && LastDeployStartTime == Level.TimeSeconds) {
			bBotDeploy = False;
			Rise = 0;
		}
		LastDeployAttempt = Level.TimeSeconds;
	}
	if (Level.NetMode != NM_DedicatedServer && Driver != None && DeployState != DS_Undeployed) {
		// override brake lights
		for (i = 0; i < 2; ++i) {
			if (BrakeLight[i] != None)
				BrakeLight[i].UpdateBrakelightState(0, 1);
		}
	}
	if (IsLocallyControlled() && IsHumanControlled() && Level.TimeSeconds - LastDeployCheckTime > 0.25) {
		// check if can be deployed
		bDrawCanDeployTooltip = DeployState == DS_Undeployed && Driver != None && CanDeploy(True);
		LastDeployCheckTime = Level.TimeSeconds;
	}
	
	if (MortarCamera != None) {
		// mouse view aiming for SPMA camera
		bCustomAiming = True;
		bAltFocalPoint = true; // for bots
		
		if (IsLocallyControlled() && IsHumanControlled()) {
			if (!MortarCamera.bShotDown && PlayerController(Controller).ViewTarget != MortarCamera) {
				PlayerController(Controller).SetViewTarget(MortarCamera);
				PlayerController(Controller).bBehindView = False;
				PlayerController(Controller).ClientSetBehindView(False);
			}
			
			CustomAim = UT3HellfireSPMACannon(Weapons[ActiveWeapon]).TargetRotation;
			
			if (bJustDeployed || Level.TimeSeconds - ClientUpdateTime > 0.0222 && CustomAim != LastAim) {
				ClientUpdateTime = Level.TimeSeconds;
				ServerAim((CustomAim.Yaw & 0xffff) | (CustomAim.Pitch << 16));
				LastAim = CustomAim;
				bJustDeployed = false;
			}
		}
		else {
			if (IsLocallyControlled() && !IsHumanControlled()) {
				// AI-controlled
				if (Controller.Target != None) {
					if (MortarCamera.bDeployed) {
						if ( ShootTarget(Controller.Target) != None )
							ObjectiveTarget = DestroyableObjective(Controller.Target.Owner);
						else
							ObjectiveTarget = DestroyableObjective(Controller.Target);
					}
					if (ObjectiveTarget != None && !ObjectiveTarget.LegitimateTargetOf(Bot(Controller)) || !Weapons[ActiveWeapon].CanAttack(ObjectiveTarget)) {
						MortarCamera.ShotDown();
						Weapons[ActiveWeapon].FireCountDown = Weapons[ActiveWeapon].AltFireInterval;
					}
					
					AltFocalPoint = Weapons[ActiveWeapon].Location + vector(CustomAim) * Weapons[ActiveWeapon].MaxRange();
					Controller.Focus = None;
				}
				else {
					// no target, retry later
					bAltFocalPoint = false;
					MortarCamera.ShotDown();
					Weapons[ActiveWeapon].FireCountDown = Weapons[ActiveWeapon].AltFireInterval;
				}
			}
			CustomAim = CannonAim;
		}
		Throttle = 0.0;
		Steering = 0.0;
	}
	else {
		bCustomAiming = False;
		if (PlayerController(Controller) != None) {
			if (PlayerController(Controller).ViewTarget == MortarCamera)
				PlayerController(Controller).SetViewTarget(Self);
			if (PlayerController(Controller).ViewTarget == Self && PlayerController(Controller).bBehindView != PointOfView()) {
				PlayerController(Controller).bBehindView = PointOfView();
				PlayerController(Controller).ClientSetBehindView(PointOfView());
			}
		}
		else if (IsDeployed() && AIController(Controller) != None) {
			bAltFocalPoint = true;
			bCustomAiming = true;
			if (Controller.Target != None)
				CustomAim.Yaw = rotator(Controller.Target.Location - Location).Yaw;
			CustomAim.Pitch = 8192; // 45 degrees up, to fire camera in the target's general direction
			AltFocalPoint = Weapons[ActiveWeapon].Location + vector(CustomAim) * Weapons[ActiveWeapon].MaxRange();
			Controller.Focus = None;
		}
		else {
			bAltFocalPoint = false;
		}
	}
}


function ServerAim(int NewYaw)
{
	CustomAim.Yaw = NewYaw & 0xffff;
	CustomAim.Pitch = NewYaw >>> 16;
	CustomAim.Roll = 0;
	CannonAim = CustomAim;
}


function bool CanAttack(Actor Other)
{
	local Pawn P;

	// if far away or objective, check if can hit with deployed artillery
	if (DeployState == DS_Undeployed && (Controller.PlayerReplicationInfo.Team == None || Controller.PlayerReplicationInfo.Team.Size > 1) && VSize(Other.Location - Location) > 1000.0 && (VSize(Velocity) > MaxDeploySpeed || CanDeploy()) && (Other.IsA('Pawn') || Other.IsA('GameObjective')))
	{
		P = Pawn(Other);
		if ((P == None || P.bStationary || (!P.bCanFly && VSize(Other.Location - Location) > 5000.0)) && Weapons[1].CanAttack(Other)) {
			bBotDeploy = True;
			return true;
		}
	}

	return Super.CanAttack(Other);
}


function ShouldTargetMissile(Projectile P)
{
	if (Health < 200 && Bot(Controller) != None && Level.Game.GameDifficulty > RandRange(4, 8) && VSize(P.Location - Location) < VSize(P.Velocity)) {
		// not much health left, so get out to avoid getting killed
		KDriverLeave(false);
		TeamUseTime = Level.TimeSeconds + 4;
		return;
	}

	// otherwise maybe try shooting down incoming AVRiLs if not deployed
	if (DeployState == DS_Undeployed)
		Super(ONSWheeledCraft).ShouldTargetMissile(P);
}


/**
Check whether the SPMA can be deployed.
*/
simulated function bool CanDeploy(optional bool bNoMessage)
{
	local int i;
	local bool bOneUnstable;
	
	if (VSize(Velocity) > MaxDeploySpeed) {
		if (!bNoMessage && PlayerController(Controller) != None)
			PlayerController(Controller).ReceiveLocalizedMessage(class'UT3DeployMessage', 0);
		return false;
	}
	
	if (IsFiring())
		return false;
	
	Rise = 0;
	for (i = 0; i < Wheels.Length; i++) {
		if (!Wheels[i].bWheelOnGround) {
			if (!bOneUnstable) {
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


function bool IsDeployed()
{
	return DeployState == DS_Deployed;
}


function ServerToggleDeploy()
{
	if (CanDeploy()) {
		GotoState('Deploying');
	}
}


function ChangeDeployState(EDeployState NewState)
{
	DeployState = NewState;
	Level.NetUpdateTime = Level.TimeSeconds - 1;
	DeployStateChanged();
}


simulated function PostNetReceive()
{
	Super.PostNetReceive();
	
	if (LastDeployState != DeployState) {
		LastDeployState = DeployState;
		DeployStateChanged();
	}
}


simulated function DeployStateChanged()
{
	switch (DeployState) {
	case DS_Deploying:
		LastDeployStartTime = Level.TimeSeconds;
		SetVehicleDeployed();
		if (DeploySound != None)
			PlaySound(DeploySound, SLOT_Misc, 1.0);
		break;
		
	case DS_Deployed:
		break;
		
	case DS_UnDeploying:
		LastDeployStartTime = Level.TimeSeconds;
		SetVehicleUndeploying();
		if (UndeploySound != None)
			PlaySound(UndeploySound, SLOT_Misc, 1.0);
		break;
		
	case DS_Undeployed:
		SetVehicleUnDeployed();
		break;
	}
}

simulated function SetVehicleDeployed()
{
	local int i;
	
	// play shutdown sound
	if (Driver != None && ShutdownSound != None)
		PlaySound(ShutdownSound, SLOT_None, 1.0);
	if (AmbientSound != None)
		AmbientSound = None;
	
	// HACK: don't play engine sounds when entering/leaving while deployed
	IdleSound = None;
	StartupSound = None;
	ShutdownSound = None;
	
	// make immobile
	SetPhysics(PHYS_None);
	SetBase(None); // Ensure we are not hooked on something (eg another vehicle)
	bStationary = true;
	bMovable = false;
	bCannotBeBased = true;
	SetActiveWeapon(1);
	Weapons[1].bForceCenterAim = False;
	Weapons[1].FireCountdown = DeployTime;
	
	// stop wheels and dirt effects
	for (i = 0; i < Wheels.Length; ++i) {
		Wheels[i].SpinVel = 0.0;
		Wheels[i].SlipVel = 0.0;
	}
}

simulated function SetVehicleUndeployed()
{
	// restore engine sounds after undeplocing
	IdleSound = default.IdleSound;
	StartupSound = default.StartupSound;
	ShutdownSound = default.ShutdownSound;
	
	if (Driver != None && Health > 0) {
		// play startup sounds
		AmbientSound = IdleSound;
		if (StartupSound != None)
			PlaySound(StartupSound, SLOT_None, 1.0);
	}
	
	// restore mobility
	bCannotBeBased = false;
	bStationary = false;
	bMovable = true;
	SetPhysics(PHYS_Karma);
	SetActiveWeapon(0);
}

simulated function SetVehicleUndeploying()
{
	Weapons[1].bForceCenterAim = True;
	if (MortarCamera != None)
		MortarCamera.ShotDown();
}

function int LimitPitch(int Pitch)
{
	if (MortarCamera != None)
		return Clamp(Pitch, -16384, 16383);
	
	return Super(ONSWheeledCraft).LimitPitch(Pitch);
}


function VehicleFire(bool bWasAltFire)
{
	if (MortarCamera != None && (bWasAltFire || !MortarCamera.bDeployed && !MortarCamera.bShotDown)) {
		bWasAltFire = True;
		if (!MortarCamera.bDeployed) {
			if (AIController(Instigator.Controller) != None)
				return;
			
			MortarCamera.Deploy();
			CustomAim = Weapons[ActiveWeapon].WeaponFireRotation;
			Weapons[ActiveWeapon].FireCountdown = Weapons[ActiveWeapon].AltFireInterval;
			return;
		}
		else if (AIController(Instigator.Controller) != None) {
			bWasAltFire = false;
		}
		else {
			MortarCamera.ShotDown();
			return;
		}
	}
	Super(ONSWheeledCraft).VehicleFire(bWasAltFire);
}


simulated function PrevWeapon()
{
	Super(ONSWheeledCraft).PrevWeapon(); // skip ONSArtillery implementation
}

simulated function NextWeapon()
{
	Super(ONSWheeledCraft).NextWeapon(); // skip ONSArtillery implementation
}


event ApplyFireImpulse(bool bAltFire)
{
	Super(ONSWheeledCraft).ApplyFireImpulse(bAltFire); // skip ONSArtillery implementation
}


function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	bMovable = True;
	SetPhysics(PHYS_Karma); // ONSVehicle expects PHYS_Karma when dying
	if (MortarCamera != None)
		MortarCamera.ShotDown();
	
	Super.Died(Killer, damageType, HitLocation);
}


state Deployed
{
	function MayUndeploy()
	{
		ServerToggleDeploy();
	}
	
	function ServerToggleDeploy()
	{
		if (!IsFiring())
			GotoState('Undeploying');
	}
	
	/**
	Makes sure the wheels are still on stable ground, otherwise undeploys.
	*/
	function CheckStability()
	{
		local int i, Count;
		local vector WheelLoc, XAxis, YAxis, ZAxis, HL, HN;

		GetAxes(Rotation, XAxis, YAxis, ZAxis);

		for (i = 0; i < Wheels.Length && Count <= 1; i++) {
			WheelLoc = Location + (Wheels[i].WheelPosition >> Rotation);
			if (Trace(HL, HN, WheelLoc - (ZAxis * (Wheels[i].WheelRadius + Wheels[i].SuspensionTravel)), WheelLoc, false, vect(1,1,1)) == None)
				Count++;
		}
		if (Count > 1) {
			// unstable!
			SetPhysics(PHYS_Karma);
			GotoState('UnDeploying');
			return;
		}
	}

	function BeginState()
	{
		ChangeDeployState(DS_Deployed);
		if (Role == ROLE_Authority)
			SetTimer(1.0, true); // start checking stability
	}

	function EndState()
	{
		SetTimer(0.0, false);
	}
}

state UnDeploying
{
	ignores ServerToggleDeploy;
	
	function BeginState()
	{
		/* 100GPing100 BEGIN */
		PlayAnim('UnDeploying', 1.0, 0.1);
		/* 100GPing100 END */
		SetTimer(UnDeployTime, False);
		ChangeDeployState(DS_UnDeploying);
	}

	function Timer()
	{
		ChangeDeployState(DS_UnDeployed);
		GotoState('');
	}
}

state Deploying
{
	ignores ServerToggleDeploy;
	
	function BeginState()
	{
		/* 100GPing100 BEGIN */
		PlayAnim('Deploying', 1.0, 0.1);
		/* 100GPing100 END */
		SetTimer(DeployTime, False);
		ChangeDeployState(DS_Deploying);
	}

	function Timer()
	{
		GotoState('Deployed');
	}
}


simulated event Destroyed()
{
	if (MortarCamera != None)
		MortarCamera.ShotDown();

	Super(ONSWheeledCraft).Destroyed();
}

function DriverLeft()
{
	if (MortarCamera != None)
		MortarCamera.ShotDown();
	
	/* 100GPing100 BEGIN */
	PlayAnim('GetOut', 1.0, 0.1);
	/* 100GPing100 END */
	
	Super(ONSWheeledCraft).DriverLeft();
}


/* 100GPing100 BEGIN */
event PostBeginPlay()
{
	PlayAnim('InActiveStill', 1.0, 0.0);
	
	super.PostBeginPlay();
}

event KDriverEnter(Pawn P)
{
	PlayAnim('GetIn', 1.0, 0.0);
	
	super.KDriverEnter(P);
}
/* 100GPing100 END */


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
    /* 100GPing100 BEGIN */
    
    Mesh = SkeletalMesh'UT3SPMAAnims.SPMA';
    RedSkin = Shader'UT3SPMATex.Body.RedSkin';
    BlueSkin = Shader'UT3SPMATex.Body.BlueSkin';
    
    FlagBone = 'Body';
    
	DriverWeapons = ();
	DriverWeapons(0) = (WeaponClass=class'UT3HellfireSPMASideGun',WeaponBone=body);
	DriverWeapons(1) = (WeaponClass=class'UT3HellfireSPMACannon',WeaponBone=MainTurret_Yaw);

	Wheels = ();
	Begin Object Class=SVehicleWheel Name=LWheel1
		BoneName="LtFrontTire"
		BoneRollAxis=AXIS_Y
		BoneSteerAxis=AXIS_Z
		BoneOffset=(X=0.0,Y=0.0,Z=0.0)
		WheelRadius=40
		bPoweredWheel=True
		bHandbrakeWheel=True
		SteerType=VST_Steered
		SupportBoneName="LtFrontTire"
		SupportBoneAxis=AXIS_X
	End Object
	Wheels(0)=SVehicleWheel'LWheel1'
	
	Begin Object Class=SVehicleWheel Name=LWheel2
		BoneName="LtTread_Wheel2"
		BoneRollAxis=AXIS_Y
		BoneSteerAxis=AXIS_Z
		BoneOffset=(X=0.0,Y=0.0,Z=0.0)
		WheelRadius=21
		bPoweredWheel=True
		bHandbrakeWheel=True
		SteerType=VST_Fixed
		SupportBoneName="LtTread_MIdStrut"
		SupportBoneAxis=AXIS_X
	End Object
	Wheels(1)=SVehicleWheel'LWheel2'

	Begin Object Class=SVehicleWheel Name=LWheel3
		BoneName="LtTread_Wheel3"
		BoneRollAxis=AXIS_Y
		BoneSteerAxis=AXIS_Z
		BoneOffset=(X=0.0,Y=0.0,Z=0.0)
		WheelRadius=21
		bPoweredWheel=True
		bHandbrakeWheel=True
		SteerType=VST_Fixed
		SupportBoneName="LtTread_MIdStrut"
		SupportBoneAxis=AXIS_X
	End Object
	Wheels(2)=SVehicleWheel'LWheel3'
    
    Begin Object Class=SVehicleWheel Name=RWheel1
		BoneName="RtFrontTire"
		BoneRollAxis=AXIS_Y
		BoneSteerAxis=AXIS_Z
		BoneOffset=(X=0.0,Y=0.0,Z=0.0)
		WheelRadius=40
		bPoweredWheel=True
		bHandbrakeWheel=True
		SteerType=VST_Steered
		SupportBoneName="RtFrontTire"
		SupportBoneAxis=AXIS_X
	End Object
	Wheels(3)=SVehicleWheel'RWheel1'    
    
	Begin Object Class=SVehicleWheel Name=RWheel2
		BoneName="RtTread_Wheel2"
		BoneRollAxis=AXIS_Y
		BoneSteerAxis=AXIS_Z
		BoneOffset=(X=0.0,Y=0.0,Z=0.0)
		WheelRadius=21
		bPoweredWheel=True
		bHandbrakeWheel=True
		SteerType=VST_Fixed
		SupportBoneName="RtTread_MIdStrut"
		SupportBoneAxis=AXIS_X
	End Object
	Wheels(4)=SVehicleWheel'RWheel2'
	
	Begin Object Class=SVehicleWheel Name=RWheel3
		BoneName="RtTread_Wheel3"
		BoneRollAxis=AXIS_Y
		BoneSteerAxis=AXIS_Z
		BoneOffset=(X=0.0,Y=0.0,Z=0.0)
		WheelRadius=21
		bPoweredWheel=True
		bHandbrakeWheel=True
		SteerType=VST_Fixed
		SupportBoneName="RtTread_MIdStrut"
		SupportBoneAxis=AXIS_X
	End Object
	Wheels(5)=SVehicleWheel'RWheel3'
    
    /* 100GPing100 END */
    
	VehiclePositionString="in a Hellfire SPMA"
	VehicleNameString = "UT3 Hellfire SPMA"
	
	DeployIconCoords = (X1=2,Y1=371,X2=124,Y2=115)
	
	//DriverWeapons(0) = (WeaponClass=class'UT3HellfireSPMASideGun',WeaponBone=SideGunAttach);
	//DriverWeapons(1) = (WeaponClass=class'UT3HellfireSPMACannon',WeaponBone=CannonAttach);
	PassengerWeapons = ()
	FireImpulse      = (X=0) // sidegun shouldn't recoil and main cannon is fired when deployed
	bAllowViewChange = false // who would want to use it 1st-person anyway
	
	GroundSpeed = 650.0
	
	bStasis = False // would interfer with aiming when deployed
	
	bNetNotify      = True
	DeployState     = DS_Undeployed
	LastDeployState = DS_Undeployed
	
	MaxDeploySpeed = 100.0
	DeployTime     = 2.1
	UndeployTime   = 2.0
	DeploySound    = Sound'SPMADeploy'
	UndeploySound  = Sound'SPMADeploy'
	
	SoundVolume    = 255
	SoundRadius    = 300
	IdleSound      = Sound'SPMAEngineIdle'
	StartUpSound   = Sound'SPMAEngineStart'
	ShutDownSound  = Sound'SPMAEngineStop'
}
