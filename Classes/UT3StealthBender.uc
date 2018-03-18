/*
 * Copyright © 2012 100GPing100
 * Copyright © 2014 GreatEmerald
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

class UT3StealthBender extends ONSWheeledCraft;

// Load packages.
#exec obj load file=..\Textures\UT3StealthBenderTex.utx
#exec obj load file=..\Animations\UT3StealthBenderAnims.ukx

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
var array<UT3DeployableMine> Mines;
/* The radius to check for deployables. */
var float DeployCheckRadius;
/* The min distance, to the back, to be from an obstacle to deploy. */
var float DeployCheckDistance;
/* The currently selected mine. 0 = none, 1 = SpiderMine, 2 = SlowVolume, 3 = EMPMine, 4 = ShieldMine */
var byte SelectedMine;
/* The items to be displayed on the HUD. */
var array<UT3HUDItem> HUDItems;
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

var Material RedSkinB, BlueSkinB;

//
// Check if jump was pressed.
//
simulated function CheckJump()
{
	if (Rise > 0 && Bot(Controller) == None && AIController(Controller) == None)
	{
		if ((CurrentState == VS_Undeployed || CurrentState == VS_Cloaked) && IsOnGround() && CheckNearby() && NoObstacle() && bHasAmmo() && !bOnWater())
		{
			// Select a mine if we don't have one selected already.
			if (SelectedMine == 0)
				SelectNextMine();

			ArmMine = Spawn(MineObjectClasses[SelectedMine - 1], Driver,, Location);
			AttachToBone(ArmMine, 'ArmWrist');

			Cloak(false);

			CurrentState = VS_Deploying;
			PlaySound(DeploySnd, SLOT_None);
			PlayAnim('ArmExtend', 1.6, 0.2);
			CurrentAnim = "ArmExtend";

			// Do not allow to move or rotate.
			GroundSpeed = 0;
			//KarmaParamsRBFull(KParams).KMaxSpeed = 0.0;
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

//
// Check if we're on water.
//
function bool bOnWater()
{
	local int i;
	for(i = 0; i < KarmaParams(KParams).Repulsors.Length; i++)
		if (KarmaParams(KParams).Repulsors[i].bRepulsorOnWater)
			return true;

	return false;
}

//
// Check if there is any obstacle for the deployment.
//
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

//
// Show a message.
//
function ShowMessage(byte Type, int Switch)
{
	/* » Type:
	 * 0: General message.
	 * 1: Mine select message.
	*/
	if (Type == 0)
		class'UT3NightshadeMessage'.static.ClientReceive(PlayerController(Controller), Switch);
	else if (Type == 1)
		class'UT3NightshadeMineMessage'.static.ClientReceive(PlayerController(Controller), Switch);
}

//
// Check if there are any deployables nearby.
//
function bool CheckNearby()
{
	return !(class'UT3DeployableMine'.static.DeployablesNearby(self, Location, DeployCheckRadius));
}

//
// Check if we're on the ground.
//
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

//
// Called when the player preses altfire.
//
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

//
// Called when the player presses fire.
//
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
			Mines[0] = Spawn(Class'UT3SpiderMineTrap', Driver,, ArmMine.Location);
			PlaySound(DropItemSnd);

			if (!bHasAmmo(1))
				SelectNextMine();
		}
		else if (Mines[1] == None && SelectedMine == 1)
		{
			Mines[1] = Spawn(Class'UT3SpiderMineTrap', Driver,, ArmMine.Location);
			PlaySound(DropItemSnd);

			if (!bHasAmmo(1))
				SelectNextMine();
		}
		else if (Mines[2] == None && SelectedMine == 2)
		{
			ShowMessage(0, 4); // "Only in next beta (have a shield :D)"
			Mines[2] = Spawn(Class'UT3DeployableEnergyShield', Driver,, ArmMine.Location);
			PlaySound(DropItemSnd);

			if (!bHasAmmo(2))
				SelectNextMine();
		}
		else if (Mines[3] == None && SelectedMine == 3)
		{
			Mines[3] = Spawn(Class'UT3EMPMine', Driver,, ArmMine.Location);
			PlaySound(DropItemSnd);

			if (!bHasAmmo(3))
				SelectNextMine();
		}
		else if (Mines[4] == None && SelectedMine == 4)
		{
			Mines[4] = Spawn(Class'UT3DeployableEnergyShield', Driver,, ArmMine.Location);
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

//
// Called by the engine every tick.
//
function Tick(float DeltaTime)
{
	// If we have ammo available and we have no mine selected, select one right away!
	if (bHasAmmo(0) && SelectedMine == 0)
		SelectNextMine();

	CheckJump();
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
		GroundSpeed = Default.GroundSpeed;
		Cloak(true); // KMaxSpeed gets reset here.
		CurrentState = VS_Cloaked;
	}
}
simulated event TeamChanged()
{

    Super(SVehicle).TeamChanged();

    if (Team == 0 && RedSkin != None)
    {
        Skins[0] = RedSkin;
        Skins[1] = RedSkinB;
    }
    else if (Team == 1 && BlueSkin != None)
    {
        Skins[0] = BlueSkin;
        Skins[1] = BlueSkinB;
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
			Skins[1] = Default.RedSkinB;
			Weapons[0].Skins[0] = Weapons[0].Default.RedSkin;
		}
		else
		{
			Skins[0] = Default.BlueSkin;
			Skins[1] = Default.BlueSkinB;
			Weapons[0].Skins[0] = Weapons[0].Default.BlueSkin;
		}
		Visibility = Default.Visibility;
		bDrawVehicleShadow = true;

		GroundSpeed = Default.GroundSpeed;
		//KarmaParamsRBFull(KParams).KMaxSpeed = Default.GroundSpeed;
	}
	else
	{
		// Cloak.
		Skins[0] = CloakedSkin;
		Skins[1] = CloakedSkin;
		Weapons[0].Skins[0] = CloakedSkin;
		Visibility = 0;
		bDrawVehicleShadow = false;
		GroundSpeed = Default.GroundSpeed * CloakedSpeedModifier;
		//KarmaParamsRBFull(KParams).KMaxSpeed = Default.GroundSpeed * CloakedSpeedModifier;
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

		GroundSpeed = Default.GroundSpeed;
		Cloak(false);

		PlayAnim('Idle', 1, 0.7);
		CurrentAnim = "Idle";
		CurrentState = VS_Undeployed;

		GroundSpeed = Default.GroundSpeed;
		//KarmaParamsRBFull(KParams).KMaxSpeed = Default.GroundSpeed;
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
		GroundSpeed = 0;
		//KarmaParamsRBFull(KParams).KMaxSpeed = 0.0;
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
    VehiclePositionString="in a Stealthbender"
    VehicleNameString="Stealthbender"

    // Looks.
    Mesh = SkeletalMesh'UT3StealthBenderAnims.StealthBender';
    RedSkin = Shader'UT3StealthBenderTex.HELLBENDER.HellbenderSkin';
    RedSkinB = Shader'UT3StealthBenderTex.StealthBender.StealthBenderSkin';
    BlueSkin = Shader'UT3StealthBenderTex.HELLBENDER.HellbenderSkinBlue';
    BlueSkinB = Shader'UT3StealthBenderTex.StealthBender.StealthBenderSkinBlue';
    CloakedSkin = FinalBlend'XEffectMat.Combos.InvisOverlayFB';
    bDrawDriverInTP = false;
    bAdjustDriversHead = false;
    MineObjectClasses(0) = class'UT3SpiderMineObject';
    MineObjectClasses(1) = class'UT3StasisFieldObject';
    MineObjectClasses(2) = class'UT3EMPObject';
    MineObjectClasses(3) = class'UT3ShieldObject';

    // HUD.
    Begin Object Class=UT3HUDItem Name=HUDSpidermineTrap
        DrawColor = (R=128,G=128,B=128,A=255);
        Icon = Texture'UT3NightshadeTex.SpiderMine.Icon_SpiderMineTrap';
        Scale = 0.5;
    End Object
    HUDItems(0) = HUDSpidermineTrap
    Begin Object Class=UT3HUDItem Name=HUDStasisField
        DrawColor = (R=128,G=128,B=128,A=255);
        Icon = Texture'UT3NightshadeTex.SlowField.Icon_SlowFieldGenerator';
        Scale = 0.5;
    End Object
    HUDItems(1) = HUDStasisField
    Begin Object Class=UT3HUDItem Name=HUDEMP
        DrawColor = (R=128,G=128,B=128,A=255);
        Icon = Texture'UT3NightshadeTex.EMPMine.Icon_EMPMine';
        Scale = 0.5;
    End Object
    HUDItems(2) = HUDEMP
    Begin Object Class=UT3HUDItem Name=HUDShield
        DrawColor = (R=128,G=128,B=128,A=255);
        Icon = Texture'UT3NightshadeTex.ShieldGenerator.Icon_ShieldGenerator';
        Scale = 0.5;
    End Object
    HUDItems(3) = HUDShield

	// Damage.
	DriverWeapons(0) = (WeaponClass=Class'Onslaught.ONSHoverBikePlasmaGun',WeaponBone="SecondaryTurretBarrel")
	Health = 600;
	HealthMax = 600;
	MeleeRange = -100;
	DriverDamageMult = 0;
	SelectedMine 0 1;
	Mines(0) = none;
	Mines(1) = none;
	Mines(2) = none;
	Mines(3) = none;
	Mines(4) = none;

	// Checks.
	DeployCheckRadius = 1800.0;
	DeployCheckDistance = 375.0;

	// Movement.
	CloakedSpeedModifier = 0.45;

	//PassengerWeapons(0)=(WeaponPawnClass=class'Onslaught.ONSPRVSideGunPawn',WeaponBone=Dummy01);
	//PassengerWeapons(1)=(WeaponPawnClass=class'Onslaught.ONSPRVRearGunPawn',WeaponBone=Dummy02);

	DestroyedVehicleMesh=StaticMesh'ONSDeadVehicles-SM.NewPRVDead'
    DestructionEffectClass=class'Onslaught.ONSVehicleExplosionEffect'
	DisintegrationEffectClass=class'Onslaught.ONSVehDeathPRV'
    DestructionLinearMomentum=(Min=250000,Max=400000)
    DestructionAngularMomentum=(Min=100,Max=150)
    DisintegrationHealth=-100
	ImpactDamageMult=0.0010

	MomentumMult=2.0
	RanOverDamageType=class'DamTypePRVRoadkill'
	CrushedDamageType=class'DamTypePRVPancake'

	CollisionRadius=175.0

	FPCamPos=(X=20,Y=-40,Z=50)
	TPCamLookat=(X=0,Y=0,Z=0)
	TPCamWorldOffset=(X=0,Y=0,Z=100)
	TPCamDistance=375

	bDoStuntInfo=true
	DaredevilThreshInAirSpin=90.0
	DaredevilThreshInAirPitch=300.0
	DaredevilThreshInAirRoll=300.0
	DaredevilThreshInAirTime=1.2
	DaredevilThreshInAirDistance=17.0

	AirTurnTorque=35.0
	AirPitchTorque=55.0
	AirPitchDamping=35.0
	AirRollTorque=35.0
	AirRollDamping=35.0

	bDrawMeshInFP=True
	bHasHandbrake=True
	bAllowBigWheels=True

	MaxViewYaw=16000
	MaxViewPitch=16000

	IdleSound=sound'ONSVehicleSounds-S.PRV.PRVEng01'
	StartUpSound=sound'ONSVehicleSounds-S.PRV.PRVStart01'
	ShutDownSound=sound'ONSVehicleSounds-S.PRV.PRVStop01'
	EngineRPMSoundRange=10000
	IdleRPM=500
	RevMeterScale=4000
	SoundVolume=180
	SoundRadius=200

	StartUpForce="PRVStartUp"
	ShutDownForce="PRVShutDown"

	SteerBoneName="Base"
	SteerBoneAxis=AXIS_Z
	SteerBoneMaxAngle=90

	EntryPosition=(X=20,Y=-60,Z=10)
	EntryRadius=190.0

	ExitPositions(0)=(X=0,Y=-165,Z=100)
	ExitPositions(1)=(X=0,Y=165,Z=100)
	ExitPositions(2)=(X=0,Y=-165,Z=-100)
	ExitPositions(3)=(X=0,Y=165,Z=-100)

	HeadlightCoronaOffset(0)=(X=140,Y=45,Z=11)
	HeadlightCoronaOffset(1)=(X=140,Y=-45,Z=11)
	HeadlightCoronaMaterial=Material'EpicParticles.flashflare1'
	//HeadlightCoronaMaxSize=100

	HeadlightProjectorOffset=(X=145,Y=0,Z=11)
	HeadlightProjectorRotation=(Yaw=0,Pitch=-1000,Roll=0)
	HeadlightProjectorMaterial=Texture'VMVehicles-TX.NewPRVGroup.PRVProjector'
	HeadlightProjectorScale=0.65

	DamagedEffectOffset=(X=100,Y=-10,Z=35)
	DamagedEffectScale=1.2

	WheelPenScale=1.5
	WheelPenOffset=0.01
	WheelSoftness=0.04
	WheelRestitution=0.1
	WheelAdhesion=0.0
	WheelLongFrictionFunc=(Points=((InVal=0,OutVal=0.0),(InVal=100.0,OutVal=1.0),(InVal=200.0,OutVal=0.9),(InVal=10000000000.0,OutVal=0.9)))
	WheelLongFrictionScale=1.1
	WheelLatFrictionScale=1.5
	WheelLongSlip=0.001
	WheelLatSlipFunc=(Points=((InVal=0.0,OutVal=0.0),(InVal=30.0,OutVal=0.009),(InVal=45.0,OutVal=0.00),(InVal=10000000000.0,OutVal=0.00)))

	WheelHandbrakeSlip=0.01
	WheelHandbrakeFriction=0.1
	WheelSuspensionTravel=25.0
	WheelSuspensionOffset=-10.0
	WheelSuspensionMaxRenderTravel=25.0

	TurnDamping=35

	HandbrakeThresh=200
	FTScale=0.03
	ChassisTorqueScale=0.7

	MinBrakeFriction=4.0
	MaxBrakeTorque=20.0
	MaxSteerAngleCurve=(Points=((InVal=0,OutVal=25.0),(InVal=1500.0,OutVal=8.0),(InVal=1000000000.0,OutVal=8.0)))
	SteerSpeed=110
	StopThreshold=100
	TorqueCurve=(Points=((InVal=0,OutVal=9.0),(InVal=200,OutVal=10.0),(InVal=1500,OutVal=11.0),(InVal=2500,OutVal=0.0)))
	EngineBrakeFactor=0.0001
	EngineBrakeRPMScale=0.1
	EngineInertia=0.1
	WheelInertia=0.1

	TransRatio=0.11
	GearRatios[0]=-0.5
	GearRatios[1]=0.4
	GearRatios[2]=0.65
	GearRatios[3]=0.85
	GearRatios[4]=1.1
	ChangeUpPoint=2000
	ChangeDownPoint=1000
	LSDFactor=1.0

	VehicleMass=4.0

	Begin Object Class=KarmaParamsRBFull Name=KParams0
		KStartEnabled=True
		KFriction=0.5
		KLinearDamping=0.05
		KAngularDamping=0.05
		KImpactThreshold=500
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
		BoneOffset=(X=-15.0,Y=0.0,Z=0.0)
		WheelRadius = 35;
		bPoweredWheel=True
		bHandbrakeWheel=True
		SteerType=VST_Fixed
		SupportBoneName="Rt_Rear_Suspension"
		SupportBoneAxis=AXIS_Y
	End Object
	Wheels(0)=SVehicleWheel'RRWheel'

	Begin Object Class=SVehicleWheel Name=LRWheel
		BoneName="Lt_Rear_Tire"
		BoneRollAxis=AXIS_Y
		BoneSteerAxis=AXIS_Z
		BoneOffset=(X=15.0,Y=0.0,Z=0.0)
		WheelRadius = 35;
		bPoweredWheel=True
		bHandbrakeWheel=True
		SteerType=VST_Fixed
		SupportBoneName="Lt_Rear_Suspension"
		SupportBoneAxis=AXIS_Y
	End Object
	Wheels(1)=SVehicleWheel'LRWheel'

	Begin Object Class=SVehicleWheel Name=RFWheel
		BoneName="Rt_Front_Tire"
		BoneRollAxis=AXIS_Y
		BoneSteerAxis=AXIS_Z
		BoneOffset=(X=-15.0,Y=0.0,Z=0.0)
		WheelRadius = 35;
		bPoweredWheel=True
		SteerType=VST_Steered
		SupportBoneName="Rt_Front_Suspension"
		SupportBoneAxis=AXIS_Y
	End Object
	Wheels(2)=SVehicleWheel'RFWheel'

	Begin Object Class=SVehicleWheel Name=LFWheel
		BoneName="Lt_Front_Tire"
		BoneRollAxis=AXIS_Y
		BoneSteerAxis=AXIS_Z
		BoneOffset=(X=15.0,Y=0.0,Z=0.0)
		WheelRadius = 35;
		bPoweredWheel=True
		SteerType=VST_Steered
		SupportBoneName="Lt_Front_Suspension"
		SupportBoneAxis=AXIS_Y
	End Object
	Wheels(3)=SVehicleWheel'LFWheel'

	GroundSpeed=840
	bDriverHoldsFlag=false
	//FlagBone=Dummy01
	FlagRotation=(Yaw=32768)

	HornSounds(0)=sound'ONSVehicleSounds-S.Horn09'
	HornSounds(1)=sound'ONSVehicleSounds-S.Horn04'
	//VehicleIcon=(Material=Texture'AS_FX_TX.HUD.AssaultHUD',X=380,Y=83,SizeX=130,SizeY=64)
	VehicleIcon=(Material=Texture'AS_FX_TX.Icons.OBJ_HellBender',X=0,Y=0,SizeX=64,SizeY=64,bIsGreyScale=true)

	ObjectiveGetOutDist=1500.0
	bCanDoTrickJumps=true

	SwitchDeployableSnd = Sound'UT3A_Vehicle_Nightshade.Sounds.A_Vehicle_Nightshade_SwitchDeployables'
}

