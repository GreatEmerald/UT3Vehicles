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

class UT3DeployableMine extends Actor;

/* The deployer's controller. */
var Controller Controller;
/* Indicates wether or not we've deployed. */
var bool bDeployed;
/* The team of the deployable. */
var byte Team;


replication
{
	reliable if (Role == ROLE_Authority && bNetDirty)
		bDeployed, Team;
}


function PostBeginPlay()
{
	Super.PostBeginPlay();

	if (Instigator != None)
	{
		Controller = Instigator.Controller;
		Team = Controller.PlayerReplicationInfo.Team.TeamIndex;
	}
}
simulated function Deploy()
{
	bDeployed = true;
}
event Landed(vector HitNormal)
{
	// We want to deploy after we land.
	Deploy();
	bCollideWorld=false;
	SetCollision(false, false, false);
}
static function bool DeployablesNearby(Actor MyActor, vector StartLocation, float CheckRadius)
{
	local float Dist;
	local UT3DeployableMine DeployedActor;

	if (MyActor.Instigator == None)
		return true;

	foreach MyActor.DynamicActors(class'UT3DeployableMine', DeployedActor)
	{
		Dist = VSize(DeployedActor.Location - StartLocation);
		if (Dist < CheckRadius)
		{
			if (UT3DeployableMine(MyActor) != None && DeployedActor.Team == UT3DeployableMine(MyActor).Team)
				return true;
			else if (Pawn(MyActor) != None && DeployedActor.Team == Pawn(MyActor).Controller.PlayerReplicationInfo.Team.TeamIndex)
				return true;
		}
	}

	return false;
}


DefaultProperties
{
	// Looks.
	StaticMesh=StaticMesh'2k4ChargerMeshes.ChargerMeshes.HealthChargerMESH-DS';
	DrawType=DT_StaticMesh;

	// Collision.
	bCollideWorld=true;
	bCollideActors=true;
	bBlockActors=true;
	CollisionHeight = 0;

	// Network.
	bReplicateInstigator=true;
	bReplicateAnimations=true;
	RemoteRole=ROLE_SimulatedProxy;

	// Movement.
	Physics=PHYS_Falling;
}
