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

class UT3EMPMine extends UT3DeployableMine;

/*  */
var float EMPRadius;
/*  */
var Sound DropSnd;
/*  */
var Sound ShockSnd;

event Landed(vector HitNormal)
{
	local vector HitLocation, TraceHitNormal;
	local Actor HitActor;

	Super.Landed(HitNormal);

	//Trace(HitLocation, HitNormal, TraceEnd, Location, true)
	HitActor = Trace(HitLocation, TraceHitNormal, Location - vect(0,0,10), Location, true);

	if (Vehicle(HitActor) != None)
		LifeSpan = FMin(LifeSpan, 30.0);

	if (!bDeleteMe)
		SetTimer(0.1, true);
}
simulated function Deploy()
{
	Super.Deploy();
	PlaySound(DropSnd, SLOT_None);
	PlayAnim('Deploy');
}
function CheckEMP()
{
	local Vehicle V;
	local Controller C, NextC;
	local bool bActivated;

	C = Level.ControllerList;
	while (C != None)
	{
		NextC = C.NextController;

		V = Vehicle(C.Pawn);
		//if (C.Pawn != None && Vehicle(C.Pawn) != None && Vehicle(C.Pawn).Health > 0 && Vehicle(C.Pawn).Driver != None && C.GetTeamNum() != Team && VSize(C.Pawn.Location - Location) < EMPRadius && FastTrace(Location, C.Pawn.Location))
		if (V != None && V.Health > 0 && V.Driver != None && C.GetTeamNum() != Team && VSize(V.Location - Location) < EMPRadius && FastTrace(Location, V.Location))
		{
			//V.EjectDriver();
			V.KDriverLeave(true);

			// 254 = EMP'ed team.
			if (V.Team != 254)
			{
				PlaySound(ShockSnd, SLOT_None);
				DisableVehicle(V);
				bActivated = true;
			}
		}

		C = NextC;
	}

	if (bActivated)
	{
		MakeNoise(1.0);
		// PlayEffect()?
	}
}
function DisableVehicle(Vehicle V)
{
	local UT3EMPDisabler Disabler;

	Disabler = Spawn(class'UT3EMPDisabler',,, Location);
	Disabler.Team = V.Team;

	V.Team = 254;
	V.bTeamLocked = true;

	Disabler.GiveTo(V);
}
event Timer()
{
	CheckEMP();
}

DefaultProperties
{
    EMPRadius = 500.0;

    Mesh = SkeletalMesh'UT3DeployableAnims.EMPMine';
    DrawType = DT_Mesh;

    bCollideActors = false;
    bBlockActors = false;
    bBlockKarma = false;

    LifeSpan = 60.0;

    // Sound.
    DropSnd = Sound'UT3A_Pickups_Deployables.EMPMine.EMPMine_Drop';
    ShockSnd = Sound'UT3A_Pickups_Deployables.EMPMine.EMPMine_Shock';
}
