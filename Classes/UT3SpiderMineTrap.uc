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

class UT3SpiderMineTrap extends UT3DeployableMine;


/* Max range for detecting enemies. */
var float DetectionRange;
/*  */
var int AvailableMines;
/*  */
var int DeployedMines;
/*  */
var array<Sound> ActivateSnd;
/*  */
var Sound DropSnd;


event Landed(vector HitNormal)
{
	Super.Landed(HitNormal);
	SetTimer(0.5, false);
	if (Team == 0)
		Level.Game.BroadCast(self, "red", 'Say');
	else if (Team == 1)
		Level.Game.BroadCast(self, "blue", 'Say');
	else
		Level.Game.BroadCast(self, Team, 'Say');
}
function Deploy()
{
	Super.Deploy();
	PlayAnim('Deploy', 1, 0);
}
function SpawnMine(Pawn Target, vector TargetDir)
{
	// ONSMineProjectile.
	local UT3SpiderMine Mine;
	local Vector X,Y,Z;

	if (AvailableMines > 0)
	{
		PlaySound(ActivateSnd[Rand(4) - 1], SLOT_None, 1.0);
		GetAxes(Rotation, X,Y,Z);
		Mine = Spawn(Class'UT3SpiderMine',,, Location + 25*Z);
		if (Mine == None)
		{
			Mine = Spawn(Class'UT3SpiderMine',,, Location + Vect(0,0, 10));
		}
		Mine.Lifeline = self;
		Mine.InstigatorController = Instigator.Controller;
		Mine.TeamNum = Team;
		Mine.TargetPawn = Target;
		Mine.KeepTargetExtraRange = FMax(0.f, DetectionRange - Mine.DetectionRange);
		Mine.TossZ = 300.0;
		Mine.Init(TargetDir);
		AvailableMines--;
		DeployedMines++;
	}
}
function CheckForEnemies()
{
	local Pawn P;
	local bool spawnedmine;

	if (Controller != None)
	{
		if (Controller.Pawn != None)
			Instigator = Controller.Pawn;
	}
	else
	{
		// Noone to get the kills.
		Destroy();
		return;
	}

	if (Team != Controller.PlayerReplicationInfo.Team.TeamIndex && Controller.PlayerReplicationInfo.Team != None)
	{
		// Deployable and controller are not off the same team
		// and the controller has no Team info.
		Destroy();
		return;
	}

	if (AvailableMines + DeployedMines <= 0)
	{
		// UT3: Out of mines.
		// @100GPing100: won't ever be true since the addition
		// will allways be the start count of mines.

		// @100GPing100: as I said, it's never true.
		Destroy();
		return;
	}

	if (!bDeleteMe)
	{
		spawnedmine = false;
		foreach RadiusActors(class'Pawn', P, DetectionRange, Location)
		{
			if (Vehicle(P) != None)
			{
				if (Vehicle(P).GetTeamNum() != Team && Vehicle(P).Driver != None && Vehicle(P).Health > 0 && FastTrace(Vehicle(P).Location, Location))
				{
					SpawnMine(P, Normal(P.Location - Location));
					SpawnedMine = true;
					break; // Only spawn one spider at a time.
				}
			}
			else if (P.GetTeamNum() != Team && P.Health > 0 && FastTrace(P.Location, Location))
			{
				SpawnMine(P, Normal(P.Location - Location));
				spawnedmine = true;
				break; // Only spawn one spider at a time.
			}
		}
		if (spawnedmine)
			SetTimer(1.5, false);
		else
			SetTimer(0.5, false);
	}
}
event Timer()
{
	CheckForEnemies();
}


DefaultProperties
{
    // Looks.
    Mesh=SkeletalMesh'UT3DeployableAnims.SpiderMine';
    DrawType=DT_Mesh;

    // Damage.
    DetectionRange=1500.0;
    AvailableMines=15;

    // Sound.
    ActivateSnd(0) = Sound'UT3A_Pickups_Deployables.SpiderMine.SpiderMine_Activate01';
    ActivateSnd(1) = Sound'UT3A_Pickups_Deployables.SpiderMine.SpiderMine_Activate02';
    ActivateSnd(2) = Sound'UT3A_Pickups_Deployables.SpiderMine.SpiderMine_Activate03';
    DropSnd = Sound'UT3A_Pickups_Deployables.SpiderMine.SpiderMine_Drop';

    // Misc.
    LifeSpan=150.0;
    bOrientOnSlope=true;
}
