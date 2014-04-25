/*
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

class UT3SlowVolume extends Actor;

/* General speed scaling factor. */
var float ScalingFactor;
/* Speed scaling factor for projectiles. */
var float ProjectileScalingFactor;
/* How much life a pawn inside of the stasis drains to it. */
var float PawnLifeDrainPerSec;
/* The mine base. */
var UT3DeployableMine MineBase;
/* The list of the currently slowed pawns. */
var array<Pawn> SlowedPawns;


simulated event Destroyed()
{
	Super.Destroyed();

	if (Role == ROLE_Authority)
	{
		//PlaySound(DestroySound);
	}

	MineBase.Destroy();
}
simulated function SlowPawn(Pawn Other)
{
	local SVehicle V;

	Level.Game.BroadCast(self, "SlowingPawn.", 'Say');
	V = SVehicle(Other);
	if (V != None)
		KarmaParamsRBFull(V.KParams).KMaxSpeed = KarmaParamsRBFull(V.KParams).Default.KMaxSpeed * ScalingFactor;
	else
	{
		Other.GroundSpeed = Other.Default.GroundSpeed * ScalingFactor;
		Other.AirSpeed = Other.Default.AirSpeed * ScalingFactor;
	}
}
simulated function RestorePawn(Pawn Other)
{
	local SVehicle V;

	Level.Game.BroadCast(self, "RestoringPawn.", 'Say');
	V = SVehicle(Other);
	if (V != None)
		KarmaParamsRBFull(V.KParams).KMaxSpeed = KarmaParamsRBFull(V.KParams).Default.KMaxSpeed;
	else
	{
		Other.GroundSpeed = Other.Default.GroundSpeed;
		Other.AirSpeed = Other.Default.AirSpeed;
	}
}
function Tick(float DeltaTime)
{
	local Pawn P;
	local int i;
	local bool bFound;

	// Check if all slowedpawns are still inside.
	for (i = 0; i < SlowedPawns.Length; i++)
	{
		bFound = false;
		foreach TouchingActors(class'Pawn', P)
		{
			if (SlowedPawns[i] != None && SlowedPawns[i] == P)
			{
				break;
				bFound = true;
			}
		}
		if (!bFound)
		{
			RestorePawn(P);
			SlowedPawns[i] = none;
		}
	}

	// Check for new pawns.
	foreach TouchingActors(class'Pawn', P)
	{
		bFound = false;
		for (i = 0; i < SlowedPawns.Length; i++)
		{
			if (P == SlowedPawns[i])
			{
				bFound = true;
				break;
			}
		}
		if (!bFound)
		{
			AddPawn(P);
			SlowPawn(P);
		}
	}
}
function AddPawn(Pawn P)
{
	local int i;

	while (true)
	{
		if (SlowedPawns[i] == None)
		{
			SlowedPawns[i] = P;
			break;
		}
		i++;
	}
}

DefaultProperties
{
	// Looks.
	StaticMesh = StaticMesh'UT3NightshadeSM.SlowVolumeCube';
	DrawType = DT_StaticMesh;

	// Misc.
	LifeSpan = 180.0;

	// Collision.
	bProjTarget = true;
	bCollideActors = true;
	bBlockActors = false;
	bStatic = false;
	bNoDelete = false;
	bHidden = false;

	// Vars.
	ScalingFactor = 0.2;
	ProjectileScalingFactor = 0.125;
	PawnLifeDrainPerSec = 3.0;
	//Gravity = (X=0,Y=0,Z=-190);

	// Network.
	RemoteRole = ROLE_Authority;
	bNetInitialRotation = true;
	NetUpdateFrequency = 1.0;
}
