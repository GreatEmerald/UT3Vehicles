//============================================================
// UT3 Nemesis Mutator
// Contact: zeluis.100@gmail.com
// Copyright (c) 2012, José Luís '100GPing100'
//
// @TODO: Turret doesn't update unless we fire or we're moving.
//============================================================
class UT3Nemesis extends ONSTreadCraft;

#exec obj load file=..\Animations\UT3NemesisAnims.ukx
#exec obj load file=..\Textures\UT3NemesisTex.utx

/* Speed when in normal state. */
var float NormalMaxSpeed;
/* Speed when in raised state. */
var float RaisedMaxSpeed;
/* Speed when in lowered state. */
var float LoweredMaxSpeed;
/* The many states for the turret. */
enum ETurretHeightState
{
	THS_Lowered,
	THS_Normal,
	THS_Raised,
};
/* Holds the state of the turret. */
var ETurretHeightState CurrentState;
/* Holds the last state of the turret. */
var ETurretHeightState LastState;
/* The firing rate when the turret is raised. */
var float RaisedFiringRate;
/* The animation set. */
var AnimationSet AnimSet;
/* Used to change engine's sound based on speed. */
var float MaxPitchSpeed;
/* Last time we changed state. */
var float LastStateChange;
/* Location of the camera when lowered relative to the turret. */
var(NemesisCamera) Vector LoweredCameraOffset;

//
// Initialize the animation set.
//
simulated event PostBeginPlay()
{
	local BySpeedNode BSNode;
	local BlendNode BNode;
	local AnimNode ANode;
	local SkelControlBone SC;
	
	AnimSet = new Class'AnimationSet';
	
	// Idle Animations.
	BSNode = Spawn(Class'BySpeedNode', self);
	BSNode.MaxSpeed = 300;
	BSNode.OwnerVehicle = self;
	
	BSNode.Target = Spawn(Class'AnimNode', self);
	AnimNode(BSNode.Target).AnimName = 'ActiveIdle';
	AnimNode(BSNode.Target).Alpha = 1;
	AnimNode(BSNode.Target).Rate = 1;
	AnimNode(BSNode.Target).bAutoStart = true;
	AnimNode(BSNode.Target).bLoop = true;
	AnimNode(BSNode.Target).OwnerVehicle = self;
	
	AnimNode(BSNode.Target).AddBone('RtTail1', 10).AddBone('RtTail2', 1).AddBone('RtTail3', 2).AddBone('RtTail4', 3).AddBone('RtTail5', 4);
	AnimNode(BSNode.Target).AddBone('LtTail1', 5).AddBone('LtTail2', 6).AddBone('LtTail3', 7).AddBone('LtTail4', 8).AddBone('LtTail5', 9);
	AnimSet.AddNode(BSNode, 'MoveNode');

	// Crouch/Normal Animations.
	BNode = Spawn(Class'BlendNode', self);
	
	ANode = Spawn(Class'AnimNode', self);
	ANode.AnimName = 'Normal';
	ANode.Alpha = 1;
	ANode.Rate = 1;
	ANode.bAutoStart = true;
	ANode.bLoop = true;
	ANode.OwnerVehicle = self;
	ANode.AddBone('TurretArm', 11);
	BNode.Target = ANode;
	
	ANode = Spawn(Class'AnimNode', self);
	ANode.AnimName = 'Crouch';
	ANode.Alpha = 1;
	ANode.Rate = 1;
	ANode.bAutoStart = true;
	ANode.bLoop = true;
	ANode.OwnerVehicle = self;
	ANode.AddBone('TurretArm', 12);
	BNode.Source = ANode;
	
	AnimSet.AddNode(BNode, 'StateNode');
	
	
	/* -- TurretArm --
	 * BlendInTime = 1
	 * BlendOutTime = 1
	**/
	SC = Spawn(Class'SkelControlBone', self);
	SC.Bone = 'TurretArm';
	SC.BoneRotation = rot(5461,0,0);
	SC.bApplyRotation = true;
	SC.TransActor = self;
	SC.bEaseInOut = true;
	//SC.RotationSpace = CS_ModelSpace;
	AnimSet.AddNode(SC, 'SkelControl0');
	
	/* -- TurretBody --
	 * BlendInTime = 1
	 * BlendOutTime = 1
	**/
	SC = Spawn(Class'SkelControlBone', self);
	SC.Bone = 'TurretBody';
	SC.BoneRotation = rot(-5461,0,0);
	SC.bApplyRotation = true;
	SC.TransActor = self;
	SC.bEaseInOut = true;
	//SC.RotationSpace = CS_ModelSpace;
	AnimSet.AddNode(SC, 'SkelControl1');
	
	Super.PostBeginPlay();
}

//
// Called when the driver leaves/enters the vehicle.
//
simulated event DrivingStatusChanged()
{
	Super(ONSTreadCraft).DrivingStatusChanged();
	
	if (bDriving)
	{
		SetTurretState(THS_Normal);
		PlayAnim('GetIn', 1, 0.2);
	}
	else
	{
		SetTurretState(THS_Lowered);
		//PlayAnim('GetIn', 1, 0.4);
	}
}

//
// Called every frame.
//
function Tick(float DeltaTime)
{
	local float EnginePitch;
	
	EnginePitch = 64.0 + VSize(Velocity) / MaxPitchSpeed * 64.0;
	SoundPitch = FClamp(EnginePitch, 64, 128);
	
	CheckJumpDuck();
	UpdateTurretRotation();
	
	Super.Tick(DeltaTime);
}

//
// Updates the turret's rotation.
//
function UpdateTurretRotation(optional bool bToZero)
{
	local Rotator TurretRotation;
	
	if (CurrentState != THS_Lowered)
	{
		TurretRotation.Yaw = -(DriverViewYaw - Rotation.Yaw);
		SetBoneRotation('TurretYaw', TurretRotation, 0, 1);
		
		TurretRotation.Yaw = 0;
		TurretRotation.Pitch = -(DriverViewPitch - Rotation.Pitch);
		SetBoneRotation('TurretPitfch', TurretRotation, 0, 1);
	}
	if (bToZero)
	{
		SetBoneRotation('TurretYaw', TurretRotation, 0, 1);
		SetBoneRotation('TurretPitfch', TurretRotation, 0, 1);
	}
}

//
// Start zooming.
//
function AltFire(optional float F)
{
	local PlayerController PC;

	PC = PlayerController(Controller);
	if (PC == None)
		return;

	bWeaponIsAltFiring = true;
	PC.ToggleZoomWithMax(0.5);
}

//
// Stop zooming.
//
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

//
// Remove the zoom.
//
simulated function ClientKDriverLeave(PlayerController PC)
{
	Super.ClientKDriverLeave(PC);

	bWeaponIsAltFiring = false;
	PC.EndZoom();
}

//
// Changes the state of the turret.
//
function SetTurretState(ETurretHeightState NewState)
{
	if (CurrentState != NewState)
	{
		LastState = CurrentState;
		CurrentState = NewState;
		ApplyTurretState();
		LastStateChange = Level.TimeSeconds;
		
		if (CurrentState == THS_Lowered)
			UpdateTurretRotation(true);
	}
}

//
// Plays state change animations and handles value changes.
//
function ApplyTurretState()
{
	local KarmaParams KP;
	
	KP = KarmaParams(KParams);

	// Animations.
	if (CurrentState == THS_Lowered)
		BlendNode(AnimSet.GetNode('StateNode')).SetAlpha(0, 0.5);
	else if (CurrentState == THS_Normal)
	{
		if (LastState == THS_Raised)
		{
			// Play 'GetOut' with the SkeletalControls ON and when going to lowered turn them off?
			BlendNode(AnimSet.GetNode('StateNode')).SetAlpha(0, 0);
			//AnimSet.GetNode('TurretRaised_0').SetAlpha(0, 0.6);
			//AnimSet.GetNode('TurretRaised_1').SetAlpha(0, 0.6);
			
			SkelControlBone(AnimSet.GetNode('SkelControl0')).SetActive(false);
			SkelControlBone(AnimSet.GetNode('SkelControl1')).SetActive(false);
			
			BlendNode(AnimSet.GetNode('StateNode')).SetAlpha(1, 0);
			AnimNode(BlendNode(AnimSet.GetNode('StateNode')).Target).AnimName = 'Normal';
			AnimNode(BlendNode(AnimSet.GetNode('StateNode')).Target).bLoop = true;
			AnimNode(BlendNode(AnimSet.GetNode('StateNode')).Target).Play();
		}
		else
		{
			BlendNode(AnimSet.GetNode('StateNode')).SetAlpha(1, 0);
			AnimNode(BlendNode(AnimSet.GetNode('StateNode')).Target).AnimName = 'GetIn';
			AnimNode(BlendNode(AnimSet.GetNode('StateNode')).Target).bLoop = false;
			AnimNode(BlendNode(AnimSet.GetNode('StateNode')).Target).Play();
		}
	}
	else if (CurrentState == THS_Raised)
	{
		BlendNode(AnimSet.GetNode('StateNode')).SetAlpha(0, 0);
		
		SkelControlBone(AnimSet.GetNode('SkelControl0')).SetActive(true);
		SkelControlBone(AnimSet.GetNode('SkelControl1')).SetActive(true);
		
		BlendNode(AnimSet.GetNode('StateNode')).SetAlpha(1, 0);
		AnimNode(BlendNode(AnimSet.GetNode('StateNode')).Target).AnimName = 'GetIn';
		AnimNode(BlendNode(AnimSet.GetNode('StateNode')).Target).bLoop = false;
		AnimNode(BlendNode(AnimSet.GetNode('StateNode')).Target).Play(0.2);
	}
	
	// Movement speed and fire rate.
	MaxThrust = Default.MaxThrust;
	KP.KMaxSpeed = NormalMaxSpeed;
	Weapons[0].FireInterval = Weapons[0].Default.FireInterval;
	if (CurrentState == THS_Lowered)
	{
		MaxThrust *= 2.2;
		KP.KMaxSpeed = LoweredMaxSpeed;
	}
	else if (CurrentState == THS_Raised)
	{
		MaxThrust *= 0.4;
		KP.KMaxSpeed = RaisedMaxSpeed;
		Weapons[0].FireInterval *= RaisedFiringRate;
	}
}

//
// Check if jump or crouch where pressed.
//
function CheckJumpDuck()
{
	if (Level.TimeSeconds - LastStateChange < 0.5)
		return;
	
	if (Rise > 0 && Bot(Controller) == None && AIController(Controller) == None)
	{
		if (CurrentState == THS_Lowered)
			SetTurretState(THS_Normal);
		else if (CurrentState == THS_Normal)
			SetTurretState(THS_Raised);
	}
	else if (Rise < 0 && Bot(Controller) == None && AIController(Controller) == None)
	{
		if (CurrentState == THS_Normal)
			SetTurretState(THS_Lowered);
		else if (CurrentState == THS_Raised)
			SetTurretState(THS_Normal);
	}
}

//
// Fixed camera when lowered.
//
function bool SpecialCalcView(out Actor ViewActor, out vector CameraLocation, out rotator CameraRotation)
{
	local Coords TurretLocation;
	
	if (CurrentState != THS_Lowered)
		return Super.SpecialCalcView(ViewActor, CameraLocation, CameraRotation);
	
	TurretLocation = GetBoneCoords('TurretYaw');
	
	CameraRotation = Rotation;
	CameraLocation = TurretLocation.Origin + (LoweredCameraOffset >> Rotation);
	return true;
}

//
// Lock the camera to the turret.
//
simulated function Vector GetCameraLocationStart()
{
	return GetBoneCoords('TurretYaw').Origin;
}

DefaultProperties
{
	// Looks.
	Mesh = SkeletalMesh'UT3NemesisAnims.Nemesis';
	RedSkin = Shader'UT3NemesisTex.UT3NemesisSkinRed';
	BlueSkin = Shader'UT3NemesisTex.UT3NemesisSkinBlue';
	
	// Strings.
	VehicleNameString = "UT3 Nemesis";
	VehiclePositionString = "in a Nemesis";
	
	// Other.
	FlagBone = Main;
	
	// Camera.
	LoweredCameraOffset = (X=-150,Y=0,Z=100);
	FPCamPos = (X=0,Y=0,Z=100);
	FPCamViewOffset = (X=-50,Y=0,Z=0);
	bFPNoZFromCameraPitch=True
	TPCamLookat=(X=0,Y=0,Z=0)
	TPCamWorldOffset=(X=0,Y=0,Z=150)
	TPCamDistance=600
	
	// Damage.
	DriverWeapons(0) = (WeaponClass=Class'Weap_UT3Nemesis',WeaponBone=TurretYaw)
	RaisedFiringRate = 0.75;
	Health = 600;
	HealthMax = 600;
	
	// Movement.
	NormalMaxSpeed = 500;
	RaisedMaxSpeed = 200; // NormalMaxSpeed * 0.4
	LoweredMaxSpeed = 1100;  // NormalMaxSpeed * 2.2
	MaxPitchSpeed = 1000;
	MaxThrust = 40; // 65
	bTurnInPlace = true;
	bCanStrafe = true;
	
	// Karma.
	Begin Object Class=KarmaParamsRBFull Name=KParams0
		KStartEnabled=True
		KFriction=0.5
		KLinearDamping=0
		KAngularDamping=0
		bKNonSphericalInertia=False
        bHighDetailOnly=False
        bClientOnly=False
		bKDoubleTickRate=True
		bKStayUpright=True
		bKAllowRotate=True
		kMaxSpeed=800.0
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
	
	// Treads.
	ThrusterOffsets(0)=(X=190,Y=145,Z=10)
	ThrusterOffsets(1)=(X=65,Y=145,Z=10)
	ThrusterOffsets(2)=(X=-20,Y=145,Z=10)
	ThrusterOffsets(3)=(X=-200,Y=145,Z=10)
	ThrusterOffsets(4)=(X=190,Y=-145,Z=10)
	ThrusterOffsets(5)=(X=65,Y=-145,Z=10)
	ThrusterOffsets(6)=(X=-20,Y=-145,Z=10)
	ThrusterOffsets(7)=(X=-200,Y=-145,Z=10)
	
	
	//
	
	GroundSpeed=520
	bDriverHoldsFlag=false
	FlagRotation=(Yaw=32768)

	bEnableProximityViewShake=true
	bOnlyViewShakeIfDriven=true
	ViewShakeRadius=600.0
	ViewShakeOffsetMag=(X=0.5,Y=0.0,Z=2.0)
	ViewShakeOffsetFreq=7.0

	HornSounds(0)=sound'ONSVehicleSounds-S.Horn09'
	HornSounds(1)=sound'ONSVehicleSounds-S.Horn02'

	MaxDesireability=0.8
	
	
	//
	
	DamagedEffectOffset=(X=100,Y=20,Z=26)
	DamagedEffectScale=1.5

	HoverSoftness=0.05
	HoverPenScale=1.5
	HoverCheckDist=65

	UprightStiffness=500
	UprightDamping=300

	MaxSteerTorque=100.0
	ForwardDampFactor=0.1
	LateralDampFactor=0.5
    ParkingDampFactor=0.8
	SteerDampFactor=100.0
	PitchTorqueFactor=0.0
	PitchDampFactor=0.0
	BankTorqueFactor=0.0
	BankDampFactor=0.0
	TurnDampFactor=0.0

	InvertSteeringThrottleThreshold=-0.1
	VehicleMass=12.0
	MomentumMult=0.3
	DriverDamageMult=0.0
	
	
	//
	
	DestroyedVehicleMesh=StaticMesh'ONSDeadVehicles-SM.TankDead'
    DestructionEffectClass=class'Onslaught.ONSVehicleExplosionEffect'
	DisintegrationEffectClass=class'Onslaught.ONSVehDeathHoverTank'
    DestructionLinearMomentum=(Min=250000,Max=400000)
    DestructionAngularMomentum=(Min=100,Max=300)

	DisintegrationHealth=-125
	CollisionHeight=+60.0
	CollisionRadius=+260.0
	bHasAltFire=false
	bSeparateTurretFocus=true
	RanOverDamageType=class'DamTypeTankRoadkill'
	CrushedDamageType=class'DamTypeTankPancake'

	IdleSound=sound'ONSVehicleSounds-S.Tank.TankEng01'
	StartUpSound=sound'ONSVehicleSounds-S.Tank.TankStart01'
	ShutDownSound=sound'ONSVehicleSounds-S.Tank.TankStop01'
	SoundVolume=200

	StartUpForce="TankStartUp"
	ShutDownForce="TankShutDown"

	bDrawDriverInTP=False
	bDrawMeshInFP=True
	bPCRelativeFPRotation=false
	
	MaxViewYaw=16000
	MaxViewPitch=16000

	DrivePos=(X=0.0,Y=0.0,Z=130.0)

	ExitPositions(0)=(X=0,Y=-200,Z=100)
	ExitPositions(1)=(X=0,Y=200,Z=100)

	EntryPosition=(X=0,Y=0,Z=0)
	EntryRadius=375.0
	
	
	/*Begin Object Class=SVehicleWheel Name=RWheel1
		BoneName = "RtTail1";
		SupportBoneName = "RtTail1";
		BoneOffset = (X=0.0,Y=35,Z=0.0);
		SuspensionTravel = 60.0;
		bPoweredWheel = true;
		WheelRadius = 30;
		
		BoneRollAxis=AXIS_Y
		BoneSteerAxis=AXIS_Z
		SupportBoneAxis=AXIS_X
		SteerType=VST_Steered
	End Object
	Begin Object Class=SVehicleWheel Name=RWheel2
		BoneName = "RtTail2";
		SupportBoneName = "RtTail2";
		BoneOffset = (X=0.0,Y=35.0,Z=0.0);
		SuspensionTravel = 60.0;
		bPoweredWheel = true;
		WheelRadius = 30;
		
		BoneRollAxis=AXIS_Y
		BoneSteerAxis=AXIS_Z
		SupportBoneAxis=AXIS_X
		SteerType=VST_Fixed
	End Object
	Begin Object Class=SVehicleWheel Name=RWheel3
		BoneName = "RtTail3";
		SupportBoneName = "RtTail3";
		BoneOffset = (X=0.0,Y=35.0,Z=0.0);
		SuspensionTravel = 60.0;
		bPoweredWheel = true;
		WheelRadius = 30;
		
		BoneRollAxis=AXIS_Y
		BoneSteerAxis=AXIS_Z
		SupportBoneAxis=AXIS_X
		SteerType=VST_Fixed
	End Object
	Begin Object Class=SVehicleWheel Name=RWheel4
		BoneName = "RtTail4";
		SupportBoneName = "RtTail4";
		BoneOffset = (X=0.0,Y=35.0,Z=0.0);
		SuspensionTravel = 60.0;
		bPoweredWheel = true;
		WheelRadius = 30;
		
		BoneRollAxis=AXIS_Y
		BoneSteerAxis=AXIS_Z
		SupportBoneAxis=AXIS_X
		SteerType=VST_Inverted
	End Object
	Begin Object Class=SVehicleWheel Name=RWheel5
		BoneName = "RtTail5";
		SupportBoneName = "RtTail5";
		BoneOffset = (X=0.0,Y=35.0,Z=0.0);
		SuspensionTravel = 60.0;
		bPoweredWheel = true;
		WheelRadius = 30;
		
		BoneRollAxis=AXIS_Y
		BoneSteerAxis=AXIS_Z
		SupportBoneAxis=AXIS_X
		SteerType=VST_Inverted
	End Object
	Begin Object Class=SVehicleWheel Name=LWheel1
		BoneName = "LtTail1";
		SupportBoneName = "LtTail1";
		BoneOffset = (X=0.0,Y=-35.0,Z=0.0);
		SuspensionTravel = 60.0;
		bPoweredWheel = true;
		WheelRadius = 30;
		
		BoneRollAxis=AXIS_Y
		BoneSteerAxis=AXIS_Z
		SupportBoneAxis=AXIS_X
		SteerType=VST_Steered
	End Object
	Begin Object Class=SVehicleWheel Name=LWheel2
		BoneName = "LtTail2";
		SupportBoneName = "LtTail2";
		BoneOffset = (X=0.0,Y=-35.0,Z=0.0);
		SuspensionTravel = 60.0;
		bPoweredWheel = true;
		WheelRadius = 30;
		
		BoneRollAxis=AXIS_Y
		BoneSteerAxis=AXIS_Z
		SupportBoneAxis=AXIS_X
		SteerType=VST_Fixed
	End Object
	Begin Object Class=SVehicleWheel Name=LWheel3
		BoneName = "LtTail3";
		SupportBoneName = "LtTail3";
		BoneOffset=(X=0.0,Y=-35.0,Z=0.0)
		SuspensionTravel = 60.0;
		bPoweredWheel = true;
		WheelRadius = 30;
		
		BoneRollAxis=AXIS_Y
		BoneSteerAxis=AXIS_Z
		SupportBoneAxis=AXIS_X
		SteerType=VST_Fixed
	End Object
	Begin Object Class=SVehicleWheel Name=LWheel4
		BoneName = "LtTail4";
		SupportBoneName = "LtTail4";
		BoneOffset = (X=0.0,Y=-35.0,Z=0.0);
		SuspensionTravel = 60.0;
		bPoweredWheel = true;
		WheelRadius = 30;
		
		BoneRollAxis=AXIS_Y
		BoneSteerAxis=AXIS_Z
		SupportBoneAxis=AXIS_X
		SteerType=VST_Inverted
	End Object
	Begin Object Class=SVehicleWheel Name=LWheel5
		BoneName = "LtTail5";
		SupportBoneName = "LtTail5";
		BoneOffset = (X=0.0,Y=-35.0,Z=0.0);
		SuspensionTravel = 60.0;
		bPoweredWheel = true;
		WheelRadius = 30;
		
		BoneRollAxis=AXIS_Y
		BoneSteerAxis=AXIS_Z
		SupportBoneAxis=AXIS_X
		SteerType=VST_Inverted
	End Object
	Wheels(0) = RWheel1;
	Wheels(1) = RWheel2;
	Wheels(2) = RWheel3;
	Wheels(3) = RWheel4;
	Wheels(4) = RWheel5;
	Wheels(5) = LWheel1;
	Wheels(6) = LWheel2;
	Wheels(7) = LWheel3;
	Wheels(8) = LWheel4;
	Wheels(9) = LWheel5;*/
}
