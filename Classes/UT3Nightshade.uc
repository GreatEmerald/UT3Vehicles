//============================================================
// UT3 Nightshade
// Credits: 100GPing100(José Luís)
// Copyright José Luís, 2012
// Copyright GreatEmerald, 2014
// Contact: zeluis.100@gmail.com
//============================================================
class UT3Nightshade extends ONSHoverBike;


// Load packages.
#exec obj load file=../Textures/UT3NightShadeTex.utx
#exec obj load file=../Animations/UT3NightShadeAnims.ukx


/* The ammount of normal speed to have when cloaked. */
var float CloakedSpeedModifier;
/* The various states possible. */
enum VState
{
	VS_Deployed,
	VS_Undeployed,
	VS_Cloaked,
	VS_Deploying,
	VS_Undeploying,
};
/* Holds the state of the vehicle. */
var VState CurrentState;
/* Holds the name of the animation currently being played. */
var string CurrentAnim;
/* Skin used when cloaked. */
var Material CloakedSkin;
/* Sound played when deploying. */
var Sound DeploySnd;
/* Sound played when undeploying. */
var Sound UndeploySnd;
/* Mines deployed. */
var array<DeployableMine> Mines;
/* Max speed when not cloaked. */
var float MaxVisibleSpeed;
/* The radius to check for deployables. */
var float DeployCheckRadius;
/* The min distance, to the back, to be from an obstacle to deploy. */
var float DeployCheckDistance;
/* The currently selected mine. 0 = none, 1 = SpiderMine, 2 = SlowVolume, 3 = EMPMine, 4 = ShieldMine */
var byte SelectedMine;
/* The items to be displayed on the HUD. */
var array<HUDItem> HUDItems;
/* Only used once to initialize the position of the menu items. */
var bool bItemsInitialized;
/* Sound played when a new deployable is selected. */
var Sound SwitchDeployableSnd;
/* Sound played when a deployable is dropped. */
var Sound DropItemSnd;
/* Last time bot tried to drop a deployable. */
var float LastDropAttemptTime;
/* THe classes available for deploy. */
var array< class<Actor> > MineObjectClasses;
/* The mine that's on the arm when we deploy. */
var Actor ArmMine;


simulated function CheckJumpDuck()
{
	// Only check for jump.
	if (Rise > 0 && Bot(Controller) == None && AIController(Controller) == None)
	{
		if ((CurrentState == VS_Undeployed || CurrentState == VS_Cloaked) && IsOnGround() && CheckNearby() && NoObstacle() && bHasAmmo() && !bOnWater())
		{
			// Select a mine if we don't have one selected already.
			if (SelectedMine == 0)
				SelectNextMine();

			ArmMine = Spawn(MineObjectClasses[SelectedMine - 1], Driver,, Location);
			AttachToBone(ArmMine, 'Object');

			Cloak(false);

			CurrentState = VS_Deploying;
			PlaySound(DeploySnd, SLOT_None);
			PlayAnim('ArmExtend', 1.6, 0.2);
			CurrentAnim = "ArmExtend";

			// Do not allow to move or rotate.
			MaxThrustForce = 0.0;
			MaxStrafeForce = 0.0;
			KarmaParamsRBFull(KParams).KMaxSpeed = 0.0;
			TurnTorqueMax = 0.0;
		}
		else if (CurrentState == VS_Deployed)
		{
			CurrentState = VS_Undeploying;
			PlaySound(UndeploySnd, SLOT_None);
			PlayAnim('ArmRetract', 4.8, 0.2);
			CurrentAnim = "ArmRetract";
		}
		else if (!CheckNearby() && (CurrentState == VS_Cloaked || CurrentState == VS_Undeployed))
			ShowMessage(0, 2);
		else if (!NoObstacle() && (CurrentState == VS_Cloaked || CurrentState == VS_Undeployed))
			ShowMessage(0, 0);
		else if (bOnWater() && (CurrentState == VS_Cloaked || CurrentState == VS_Undeployed))
			ShowMessage(0, 3);
	}
}
function bool bOnWater()
{
	local int i;
	for(i = 0; i < KarmaParams(KParams).Repulsors.Length; i++)
		if (KarmaParams(KParams).Repulsors[i].bRepulsorOnWater)
			return true;

	return false;
}
function bool NoObstacle()
{
	local vector HitLocation, HitNormal, TraceEnd, Direction;

	Direction = -Vector(Rotation);
	TraceEnd = Location - vect(0,0,5) + Direction * DeployCheckDistance;

	if (Trace(HitLocation, HitNormal, TraceEnd, Location, true) == None)
		return true;
	else
		return false;
}
/* » Type:
 * 0: General message.
 * 1: Mine select message.
*/
function ShowMessage(byte Type, int Switch)
{
	if (Type == 0)
		class'UT3NightshadeMessage'.static.ClientReceive(PlayerController(Controller), Switch);
	else if (Type == 1)
		class'UT3NightshadeMineMessage'.static.ClientReceive(PlayerController(Controller), Switch);
}
function bool CheckNearby()
{
	return !(class'DeployableMine'.static.DeployablesNearby(self, Location, DeployCheckRadius));
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
function AltFire(optional float F)
{
	if (CurrentState == VS_Undeployed)
	{
		// Cloak
		Cloak(true);
		CurrentState = VS_Cloaked;
	}
	else if (CurrentState == VS_Cloaked)
	{
		Cloak(false);
		CurrentState = VS_Undeployed;
	}
}
function Fire(optional float F)
{
	// Do not fire if deploying or undeploying.
	if (CurrentState == VS_Deploying || CurrentState == VS_Undeploying)
		return;

	if (CurrentState == VS_Deployed)
	{
		/* Actor Spawn (class<Actor> SpawnClass,
		optional Actor SpawnOwner,
		optional name SpawnTag,
		optional Object.Vector SpawnLocation,
		optional Object.Rotator SpawnRotation)*/
		if (Mines[0] == None && SelectedMine == 1)
		{
			Mines[0] = Spawn(Class'SpiderMine', Driver,, ArmMine.Location);
			PlaySound(DropItemSnd);

			if (!bHasAmmo(1))
				SelectNextMine();
		}
		else if (Mines[1] == None && SelectedMine == 1)
		{
			Mines[1] = Spawn(Class'SpiderMine', Driver,, ArmMine.Location);
			PlaySound(DropItemSnd);

			if (!bHasAmmo(1))
				SelectNextMine();
		}
		else if (Mines[2] == None && SelectedMine == 2)
		{
			ShowMessage(0, 4); // "Only in next beta (have a shield :D)"
			Mines[2] = Spawn(Class'EnergyShield', Driver,, ArmMine.Location);
			PlaySound(DropItemSnd);

			if (!bHasAmmo(2))
				SelectNextMine();
		}
		else if (Mines[3] == None && SelectedMine == 3)
		{
			Mines[3] = Spawn(Class'EMPMine', Driver,, ArmMine.Location);
			PlaySound(DropItemSnd);

			if (!bHasAmmo(3))
				SelectNextMine();
		}
		else if (Mines[4] == None && SelectedMine == 4)
		{
			Mines[4] = Spawn(Class'EnergyShield', Driver,, ArmMine.Location);
			PlaySound(DropItemSnd);

			if (!bHasAmmo(4))
				SelectNextMine();
		}

		ArmMine.Destroy();

		// Undeploy.
		CurrentState = VS_Undeploying;
		PlaySound(UndeploySnd, SLOT_None);
		PlayAnim('ArmRetract', 4.8, 0.2);
		CurrentAnim = "ArmRetract";
	}
	else
		Super.Fire(F);
}
function Tick(float DeltaTime)
{
	// If we have ammo available and we have no mine selected, select one right away!
	if (bHasAmmo(0) && SelectedMine == 0)
		SelectNextMine();

	CheckState();
	super.Tick(DeltaTime);
}
function CheckState()
{
	/* Animations:
	ArmExtend [121]
	ArmExtendIdle [1]
	ArmRelease [1]
	ArmRetract [121] (Made by me. Reverse of ArmExtend)
	Idle [1]
	*/
	if (CurrentState == VS_Deploying && CurrentAnim == "ArmExtend" && !IsAnimating())
	{
		CurrentState = VS_Deployed;
	}
	else if (CurrentState == VS_Undeploying && CurrentAnim == "ArmRetract" && !IsAnimating())
	{
		if (ArmMine != None)
			ArmMine.Destroy();
		// Reset these.
		MaxThrustForce = Default.MaxThrustForce;
		MaxStrafeForce = Default.MaxStrafeForce;
		TurnTorqueMax = Default.TurnTorqueMax;
		Cloak(true); // KMaxSpeed gets reset here.
		CurrentState = VS_Cloaked;
	}
}
function Cloak(bool OnOff)
{
	/* byte Visibility
	0   : Invisible.
	128 : Normal.
	255 : Higly visible.
	*/
	if (!OnOff)
	{
		// Uncloak.
		if (Team == 0)
		{
			Skins[0] = Default.RedSkin;
			Weapons[0].Skins[0] = Weapons[0].Default.RedSkin;
		}
		else
		{
			Skins[0] = Default.BlueSkin;
			Weapons[0].Skins[0] = Weapons[0].Default.BlueSkin;
		}
		Visibility = Default.Visibility;
		bDrawVehicleShadow = true;
		KarmaParamsRBFull(KParams).KMaxSpeed = MaxVisibleSpeed;
	}
	else
	{
		// Cloak.
		Skins[0] = CloakedSkin;
		Weapons[0].Skins[0] = CloakedSkin;
		Visibility = 0;
		bDrawVehicleShadow = false;
		KarmaParamsRBFull(KParams).KMaxSpeed = MaxVisibleSpeed * CloakedSpeedModifier;
	}
}
simulated event DrivingStatusChanged()
{
	// Do not call it in ONSHoverBike because of the dust effects.
	Super(ONSHoverCraft).DrivingStatusChanged();

	if (Driver == None)
	{
		if (ArmMine != None)
			ArmMine.Destroy();

		MaxThrustForce = Default.MaxThrustForce;
		MaxStrafeForce = Default.MaxStrafeForce;
		TurnTorqueMax = Default.TurnTorqueMax;
		Cloak(false);

		PlayAnim('Idle', 1, 0.7);
		CurrentAnim = "Idle";
		CurrentState = VS_Undeployed;

		// Reset these.
		PitchTorqueMax = Default.PitchTorqueMax;
		TurnTorqueMax = Default.TurnTorqueMax;
		RollTorqueMax = Default.RollTorqueMax;

		KarmaParamsRBFull(KParams).KMaxSpeed = MaxVisibleSpeed;
	}
	else
	{
		if (ArmMine != None)
			ArmMine.Destroy();
		Cloak(true);
		CurrentState = VS_Cloaked;
	}

	if (Role == ROLE_Authority)
	{
		if (Bot(Controller) != None || AIController(Controller) != None)
			SetTimer(1.0, true);
		else
			SetTimer(0.0, false);
	}
}
state QuickRedeploying
{
Begin:
	// Prevents driver from firing.
	CurrentAnim = "ArmRetract";
	CurrentState = VS_Deploying;

	// Undeploy.
	PlaySound(UndeploySnd, SLOT_None);
	PlayAnim('ArmRetract', 4.8, 0.2);

	// Wait for the animation to end.
	FinishAnim();

	// Update mine object.
	if (ArmMine != None)
		ArmMine.Destroy();
	ArmMine = Spawn(MineObjectClasses[SelectedMine - 1], Driver,, Location);
	AttachToBone(ArmMine, 'Object');

	// Deploy.
	PlaySound(DeploySnd, SLOT_None);
	PlayAnim('ArmExtend', 1.6, 0.2);

	// Will change it back to VS_Deployed in CheckState().
	CurrentAnim = "ArmExtend";
}
simulated function NextWeapon()
{
	if (CurrentState == VS_Deployed)
	{
		switch (SelectedMine)
		{
			case 1:
				if (!bHasAmmo(2))
				{
					if (!bHasAmmo(SelectedMine))
						SelectNextMine();
					break;
				}
				SelectedMine = 2;
				PlaySound(SwitchDeployableSnd, SLOT_None);
				ShowMessage(1, 1); // "Stasis Field"
				break;
			case 2:
				if (!bHasAmmo(3))
				{
					if (!bHasAmmo(SelectedMine))
						SelectNextMine();
					break;
				}
				SelectedMine = 3;
				PlaySound(SwitchDeployableSnd, SLOT_None);
				ShowMessage(1, 2); // "EMP"
				break;
			case 3:
				if (!bHasAmmo(4))
				{
					if (!bHasAmmo(SelectedMine))
						SelectNextMine();
					break;
				}
				SelectedMine = 4;
				PlaySound(SwitchDeployableSnd, SLOT_None);
				ShowMessage(1, 3); // "Shield Generator"
				break;
			case 4:
				if (!bHasAmmo(1))
				{
					if (!bHasAmmo(SelectedMine))
						SelectNextMine();
					break;
				}
				SelectedMine = 1;
				PlaySound(SwitchDeployableSnd, SLOT_None);
				ShowMessage(1, 0); // "Spidermine Trap"
				break;
		}
		GoToState('QuickRedeploying');
	}
	else
		Super.NextWeapon();
}
simulated function PrevWeapon()
{
	if (CurrentState == VS_Deployed)
	{
		switch (SelectedMine)
		{
			case 1:
				if (!bHasAmmo(4))
				{
					if (!bHasAmmo(SelectedMine))
						SelectNextMine();
					break;
				}
				SelectedMine = 4;
				PlaySound(SwitchDeployableSnd, SLOT_None);
				ShowMessage(1, 3); // "Shield Generator"
				break;
			case 2:
				if (!bHasAmmo(1))
				{
					if (!bHasAmmo(SelectedMine))
						SelectNextMine();
					break;
				}
				SelectedMine = 1;
				PlaySound(SwitchDeployableSnd, SLOT_None);
				ShowMessage(1, 0); // "Spidermine Trap"
				break;
			case 3:
				if (!bHasAmmo(2))
				{
					if (!bHasAmmo(SelectedMine))
						SelectNextMine();
					break;
				}
				SelectedMine = 2;
				PlaySound(SwitchDeployableSnd, SLOT_None);
				ShowMessage(1, 1); // "Stasis Field"
				break;
			case 4:
				if (!bHasAmmo(3))
				{
					if (!bHasAmmo(SelectedMine))
						SelectNextMine();
					break;
				}
				SelectedMine = 3;
				PlaySound(SwitchDeployableSnd, SLOT_None);
				ShowMessage(1, 2); // "EMP"
				break;
		}
		GoToState('QuickRedeploying');
	}
	else
		Super.PrevWeapon();
}
simulated function SwitchWeapon(byte F)
{
	if (F == SelectedMine)
		return;
	switch (F)
	{
		case 1:
			if (!bHasAmmo(1))
			{
				if (!bHasAmmo(SelectedMine))
					SelectNextMine();
				break;
			}
			SelectedMine = 1;
			PlaySound(SwitchDeployableSnd, SLOT_None);
			ShowMessage(1, 0); // "Spidermine Trap"
			break;
		case 2:
			if (!bHasAmmo(2))
			{
				if (!bHasAmmo(SelectedMine))
					SelectNextMine();
				break;
			}
			SelectedMine = 2;
			PlaySound(SwitchDeployableSnd, SLOT_None);
			ShowMessage(1, 1); // "Stasis Field"
			break;
		case 3:
			if (!bHasAmmo(3))
			{
				if (!bHasAmmo(SelectedMine))
					SelectNextMine();
				break;
			}
			SelectedMine = 3;
			PlaySound(SwitchDeployableSnd, SLOT_None);
			ShowMessage(1, 2); // "EMP"
			break;
		case 4:
			if (!bHasAmmo(4))
			{
				if (!bHasAmmo(SelectedMine))
					SelectNextMine();
				break;
			}
			SelectedMine = 4;
			PlaySound(SwitchDeployableSnd, SLOT_None);
			ShowMessage(1, 3); // "Shield Generator"
			break;
	}
	if (CurrentState == VS_Deployed)
		GoToState('QuickRedeploying');
}
function bool bHasAmmo(optional byte Mode)
{
	if (Mode == 0 && (Mines[0] == none || Mines[1] == none || Mines[2] == none || Mines[3] == none || Mines[4] == none))
		return true;
	else if (Mode == 0)
		return false;
	else if (Mode == 1 && (Mines[0] == none || Mines[1] == none))
		return true;
	else if (Mode == 1)
		return false;
	else if (Mode == 2 && Mines[2] == none)
		return true;
	else if (Mode == 2)
		return false;
	else if (Mode == 3 && Mines[3] == none)
		return true;
	else if (Mode == 3)
		return false;
	else if (Mode == 4 && Mines[4] == none)
		return true;
	else if (Mode == 4)
		return false;
	else
		return false;
}
function SelectNextMine()
{
	if (Mines[0] == none)
		SelectedMine = 1;
	else if (Mines[1] == none)
		SelectedMine = 1;
	else if (Mines[2] == none)
		SelectedMine = 2;
	else if (Mines[3] == none)
		SelectedMine = 3;
	else if (Mines[4] == none)
		SelectedMine = 4;
	else
		SelectedMine = 0;

	switch (SelectedMine)
	{
		case 1:
			ShowMessage(1, 0); // "Spidermine Trap"
			break;
		case 2:
			ShowMessage(1, 1); // "Stasis Field"
			break;
		case 3:
			ShowMessage(1, 2); // "EMP"
			break;
		case 4:
			ShowMessage(1, 3); // "Shield Generator"
			break;
	}
}

//=================================
// HUD.
function DrawHUD(Canvas Canvas)
{
	local int i;

	// Do not draw the HUD on bots.
	if (Bot(Controller) != None || AIController(Controller) != None)
		return;
	// SizeX, SizeY.
	// Initialize the Items' positions if we did not already.
	if (!bItemsInitialized)
	{
		HUDItems[0].PosX = Canvas.ClipX * 0.5 - 138;
		HUDItems[0].PosY = Canvas.ClipY * 0.90;
		HUDItems[1].PosX = Canvas.ClipX * 0.5 - 69;
		HUDItems[1].PosY = Canvas.ClipY * 0.90;
		HUDItems[2].PosX = Canvas.ClipX * 0.5 + 5;
		HUDItems[2].PosY = Canvas.ClipY * 0.90;
		HUDItems[3].PosX = Canvas.ClipX * 0.5 + 74;
		HUDItems[3].PosY = Canvas.ClipY * 0.90;
		bItemsInitialized = true;
	}

	if (SelectedMine != 0)
	{
		// Draw the selected mine with normal colours.
		Canvas.SetDrawColor(255,255,255,255);
		Canvas.SetPos(HUDItems[SelectedMine - 1].PosX - 16, HUDItems[SelectedMine - 1].PosY - 32);
		Canvas.DrawIcon(HUDItems[SelectedMine - 1].Icon, 0.75);
		// Draw the other mines darkened.
		for (i = 0; i < HUDItems.Length; i++)
		{
			if (i != SelectedMine - 1)
			{
				Canvas.SetDrawColor(HUDItems[i].DrawColor.R, HUDItems[i].DrawColor.G, HUDItems[i].DrawColor.B, HUDItems[i].DrawColor.A);
				Canvas.SetPos(HUDItems[i].PosX, HUDItems[i].PosY);
				Canvas.DrawIcon(HUDItems[i].Icon, HUDItems[i].Scale);
			}
		}
	}
	else
	{
		// Draw the mines darkened.
		for (i = 0; i < HUDItems.Length; i++)
		{
			Canvas.SetDrawColor(HUDItems[i].DrawColor.R, HUDItems[i].DrawColor.G, HUDItems[i].DrawColor.B, HUDItems[i].DrawColor.A);
			Canvas.SetPos(HUDItems[i].PosX, HUDItems[i].PosY);
			Canvas.DrawIcon(HUDItems[i].Icon, HUDItems[i].Scale);
		}
	}
}
// HUD End.
//===============END===============

//=================================
// AI.
function CheckAICloak()
{
	local Bot b;
	local AIController AI;

	b = Bot(Controller);
	AI = AIController(Controller);
	if (b != None || AI != None)
	{
		if ((CurrentState == VS_Deploying || CurrentState == VS_Deployed || CurrentState == VS_Undeploying) && Skins[0] == CloakedSkin)
			Cloak(false);
		else // 503 = LATENT_MOVETOWARD
			Cloak(b.Enemy != None || b.MoveTarget == None || !b.InLatentExecution(503));
	}
	else // No bot, no timer.
		SetTimer(0.0, false);
}
function bool BotDropDeployable()
{
	if (CurrentState == VS_Undeployed || CurrentState == VS_Cloaked)
	{
		Cloak(false);

		// Select a mine if we don't have one selected already.
		if (SelectedMine == 0)
			SelectNextMine();

		ArmMine = Spawn(MineObjectClasses[SelectedMine - 1], Driver,, Location);
		AttachToBone(ArmMine, 'Object');

		Cloak(false);

		CurrentState = VS_Deploying;
		PlaySound(DeploySnd, SLOT_None);
		PlayAnim('ArmExtend', 1.6, 0.2);
		CurrentAnim = "ArmExtend";

		// Do not allow to move or rotate.
		MaxThrustForce = 0.0;
		MaxStrafeForce = 0.0;
		KarmaParamsRBFull(KParams).KMaxSpeed = 0.0;
		TurnTorqueMax = 0.0;
	}
	else if (CurrentState == VS_Deployed)
	{
		LastDropAttemptTime = Level.TimeSeconds;
		Fire(0);

		CurrentState = VS_Undeploying;
		PlaySound(UndeploySnd, SLOT_None);
		PlayAnim('ArmRetract', 4.8, 0.2);
		CurrentAnim = "ArmRetract";

		if (ArmMine != None)
			ArmMine.Destroy();
	}

	return false;
}
function bool ShouldDropDeployable()
{
	local Bot b;
	local vector EnemyDir;
	local GameObjective O;

	SelectNextMine();

	if (CurrentState == VS_Deployed)
	{
		BotDropDeployable();
		return true;
	}


	b = Bot(Controller);
	if (b != None && Level.TimeSeconds - LastDropAttemptTime > 7.0)
	{
		if (!CheckNearby() || bOnWater() || !NoObstacle() || !IsOnGround())
		{
			LastDropAttemptTime = Level.TimeSeconds;
			return false;
		}

		if (b.Enemy == None)
		{
			EnemyDir = b.Enemy.Location - Location;
			if (VSize(EnemyDir) > 3000.0 && Normal(EnemyDir) dot Normal(B.Enemy.Velocity) > 0.5 && b.LineOfSightTo(b.Enemy))
			{
				BotDropDeployable();
				return true;
			}
		}
		else
		{
			// Consider dropping a deployable if near a relevant objective.
			foreach RadiusActors(class'GameObjective', O, 1024.0)
			{
				if (!CheckNearby())
				{
					// Would deploy but there is already a deployable here
					LastDropAttemptTime = Level.TimeSeconds;
					return false;
				}
				else
				{
					BotDropDeployable();
					return true;
				}
			}
		}
	}
	return false;
}
function bool FastVehicle()
{
	return false;
}
function bool IsDeployed()
{
	return CurrentState == VS_Deployed;
}
function bool TooCloseToAttack(Actor Other)
{
	if (VSize(Other.Location - Location) > Weapons[0].TraceRange)
		return true;
	else
		return Super.TooCloseToAttack(Other);
}
function bool CanHeal(Actor Other)
{
	if (DestroyableObjective(Other) != None && DestroyableObjective(Other).LinkHealMult > 0)
		return DestroyableObjective(Other).TeamLink(Team);
	else
		return (Vehicle(Other) != None && Vehicle(Other).LinkHealMult > 0);
}

// AI End.
//===============END===============

event Timer()
{
	CheckAICloak();
	ShouldDropDeployable();
}


DefaultProperties
{
	// Strings.
	VehiclePositionString = "in a UT3 Nightshade";
	VehicleNameString = "UT3 Nightshade";

	// Looks.
	Mesh = SkeletalMesh'UT3NightshadeAnims.Nightshade';
	RedSkin = Shader'UT3NightshadeTex.Nightshader.NightshadeSkin';
	BlueSkin = Shader'UT3NightshadeTex.Nightshader.NightshadeSkinBlue';
	CloakedSkin = FinalBlend'XEffectMat.Combos.InvisOverlayFB';
	bDrawDriverInTP = False;
	HeadlightCoronaMaxSize = 0.0;
	BikeDustTraceDistance = 0.0;
	bAdjustDriversHead = false;
	MineObjectClasses(0) = class'SpidermineObject';
	MineObjectClasses(1) = class'StasisFieldObject';
	MineObjectClasses(2) = class'EMPObject';
	MineObjectClasses(3) = class'ShieldObject';

	// HUD.
	bShowChargingBar = false;
	Begin Object Class=HUDItem Name=HUDSpidermineTrap
		DrawColor = (R=128,G=128,B=128,A=255);
		Icon = Texture'UT3NightshadeTex.SpiderMine.Icon_SpiderMineTrap';
		Scale = 0.5;
	End Object
	HUDItems(0) = HUDSpidermineTrap
	Begin Object Class=HUDItem Name=HUDStasisField
		DrawColor = (R=128,G=128,B=128,A=255);
		Icon = Texture'UT3NightshadeTex.SlowField.Icon_SlowFieldGenerator';
		Scale = 0.5;
	End Object
	HUDItems(1) = HUDStasisField
	Begin Object Class=HUDItem Name=HUDEMP
		DrawColor = (R=128,G=128,B=128,A=255);
		Icon = Texture'UT3NightshadeTex.EMPMine.Icon_EMPMine';
		Scale = 0.5;
	End Object
	HUDItems(2) = HUDEMP
	Begin Object Class=HUDItem Name=HUDShield
		DrawColor = (R=128,G=128,B=128,A=255);
		Icon = Texture'UT3NightshadeTex.ShieldGenerator.Icon_ShieldGenerator';
		Scale = 0.5;
	End Object
	HUDItems(3) = HUDShield

	// Damage.
	//DriverWeapons(0) = (WeaponClass=Class'Onslaught.ONSHoverBikePlasmaGun',WeaponBone="Turret_Pitch")
	DriverWeapons(0) = (WeaponClass=Class'Weap_UT3Nightshade',WeaponBone="Base");
	Health = 600;
	HealthMax = 600;
	MeleeRange = -100;
	DriverDamageMult = 0.0;
	SelectedMine = 1;
	Mines(0) = none;
	Mines(1) = none;
	Mines(2) = none;
	Mines(3) = none;
	Mines(4) = none;

	// Sound.
	IdleSound = Sound'UT3A_Vehicle_Nightshade.Sounds.A_Vehicle_Nightshade_EngineLoop01';
	StartUpSound = Sound'UT3A_Vehicle_Nightshade.Sounds.A_Vehicle_Nightshade_EngineStart01';
	ShutDownSound = Sound'UT3A_Vehicle_Nightshade.Sounds.A_Vehicle_Nightshade_EngineStop01';
	DeploySnd = Sound'UT3A_Vehicle_Nightshade.Sounds.A_Vehicle_Nightshade_ArmsExtend01';
	UndeploySnd = Sound'UT3A_Vehicle_Nightshade.Sounds.A_Vehicle_Nightshade_ArmsRetract01';
	SwitchDeployableSnd = Sound'UT3A_Vehicle_Nightshade.Sounds.A_Vehicle_Nightshade_SwitchDeployables';
	DropItemSnd = Sound'UT3A_Vehicle_Nightshade.Sounds.A_Vehicle_Nightshade_DropItem02';
	MaxPitchSpeed = 1250; // 1000
	ImpactDamageSounds(0) = Sound'UT3A_Vehicle_Nightshade.Sounds.A_Vehicle_Nightshade_Impact01';
	ImpactDamageSounds(1) = Sound'UT3A_Vehicle_Nightshade.Sounds.A_Vehicle_Nightshade_Impact02';
	ImpactDamageSounds(2) = Sound'UT3A_Vehicle_Nightshade.Sounds.A_Vehicle_Nightshade_Impact01';
	ImpactDamageSounds(3) = Sound'UT3A_Vehicle_Nightshade.Sounds.A_Vehicle_Nightshade_Impact02';
	ImpactDamageSounds(4) = Sound'UT3A_Vehicle_Nightshade.Sounds.A_Vehicle_Nightshade_Impact01';
	ImpactDamageSounds(5) = Sound'UT3A_Vehicle_Nightshade.Sounds.A_Vehicle_Nightshade_Impact02';
	ImpactDamageSounds(6) = Sound'UT3A_Vehicle_Nightshade.Sounds.A_Vehicle_Nightshade_Impact01';

	// Movement.
	MaxThrustForce = 15.0;
	MaxStrafeForce = 15.0;
	CloakedSpeedModifier = 0.45; // 0.45
	MaxVisibleSpeed = 900;
	MomentumMult = 0.3;
	PitchTorqueMax = 0.0;
	RollTorqueMax = 0.0;
	UprightDamping = 0.0; // 300.0
	UprightStiffness = 1000.0; // 500.0
	Begin Object Class=KarmaParamsRBFull Name=KParams0
		KInertiaTensor(0) = 1.30000 // 1.3
		KInertiaTensor(3) = 4.000000
		KInertiaTensor(5) = 4.500000
		KLinearDamping = 0.15 // 0.15
		KAngularDamping = 0.0
		KStartEnabled = True
		bHighDetailOnly = False
		bClientOnly = False
		bKDoubleTickRate = True
		bKStayUpright = True
		bKAllowRotate = True
		bDestroyOnWorldPenetrate = True
		bDoSafetime = True
		KFriction = 0.500000
		KImpactThreshold = 700.000000
		KMass = 500
		KMaxSpeed = MaxVisibleSpeed
	End Object
	KParams = KParams0;

	// AI.
	ObjectiveGetOutDist = 750.0;
	MaxDesireability = 0.5;

	// Checks.
	DeployCheckRadius = 1800.0; // 1440000.0
	DeployCheckDistance = 375.0; // 375.0

	// Misc.
	EntryRadius = 200.0; // 140.0
}
