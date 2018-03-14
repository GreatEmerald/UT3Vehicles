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

class Weap_UT3Nightshade extends ONSWeapon;


/* The beam effect. */
var LinkBeamEffect Beam;
/* Actor we're currently linked to. */
var Actor LinkedTo;
/* True if we're currently firing. */
var bool bIsFiring;
/* Sound played when we start firing. */
var Sound FireStart;
/* Sound played when we stop firing. */
var Sound FireEnd;
/* Damage saved as time passes, used so we do not heal too
fast at high framerates or too slow at low framerates. */
var float SavedDamage;
/* Damage/Health to give (per second). */
var int Damage;
/* Minimum damage/health to give. */
var float MinimumDamage;


replication
{
	reliable if (Role == ROLE_Authority)
		LinkedTo;
}


simulated function vector GetLinkedToLocation()
{
	if (LinkedTo == None)
		return vect(0,0,0);
	else if (Pawn(LinkedTo) != None)
		return LinkedTo.Location + Pawn(LinkedTo).BaseEyeHeight * vect(0,0,0.5);
	else
		return LinkedTo.Location;
}
simulated function bool OnSameTeam(Actor Other)
{
	if (Instigator == Other)
		return true;
	else if (!Level.GRI.bTeamGame)
		return false;
	else if (Level.GRI.bTeamGame)
		return Instigator.Controller.PlayerReplicationInfo.Team.TeamIndex == Pawn(Other).GetTeamNum();
}
function byte BestMode()
{
	return 1;
}
state InstantFireMode
{
	function Fire(Controller C)
	{
		local Vector HitLocation, HitNormal, TraceStart, TraceEnd;
		local Actor HitActor;

		if (!bIsFiring)
		{
			bIsFiring = true;

			PlaySound(FireStart, SLOT_None);

			TraceStart = WeaponFireLocation;
			TraceEnd = TraceStart + Vector(CurrentAim + Rotation) * TraceRange;
			HitActor = Trace(HitLocation, HitNormal, TraceEnd, TraceStart, true);

			// Spawm the beam, the rest is done in Tick.
			if (Beam != None)
				Beam.Destroy();
			Beam = Spawn(class'UT3NightshadeBeamEffect', Instigator);

			if (Team == 1)
				Beam.LinkColor = 2; // Blue.
			else
				Beam.LinkColor = 1; // Red.

			UpdateBeam();
		}
	}
	function UpdateBeam()
	{
		local Vector HitLocation, HitNormal, TraceStart, TraceEnd;
		local Actor HitActor;

		// @TODO: Change the trace info on the other functions.
		TraceStart = WeaponFireLocation;
		TraceEnd = TraceStart + Vector(CurrentAim + Rotation) * TraceRange;
		HitActor = Trace(HitLocation, HitNormal, TraceEnd, TraceStart, true);

		Beam.StartEffect = TraceStart;
		if (HitActor != None)
		{
			if (HitActor.IsA('Vehicle') && OnSameTeam(HitActor))
			{
				LinkedTo = HitActor;
				Beam.EndEffect = GetLinkedToLocation();
			}
			else
				Beam.EndEffect = HitLocation;
		}
		else
			Beam.EndEffect = TraceEnd;
	}
	function Tick(float DeltaTime)
	{
		if (bIsFiring)
		{
			FlashMuzzleFlash();

			if (AmbientEffectEmitter != None)
			{
				AmbientEffectEmitter.SetEmitterStatus(true);
			}

			// Play firing noise
			if (bAmbientFireSound)
				AmbientSound = FireSoundClass;
			else
				PlayOwnedSound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius, FireSoundPitch, False);

			// Increase SavedDamage.
			SavedDamage += Damage * DeltaTime;

			UpdateBeam();
			ProcessBeam();
		}
	}
	simulated function ProcessBeam()
	{
		local Vector HitLocation, HitNormal, TraceStart, TraceEnd;
		local Actor HitActor;
		local int DamageAmount;

		TraceStart = WeaponFireLocation;
		TraceEnd = TraceStart + Vector(CurrentAim + Rotation) * TraceRange;
		HitActor = Trace(HitLocation, HitNormal, TraceEnd, TraceStart, true);

		DamageAmount = int(SavedDamage);

		// We didn't hit anything, but were still linked, so unlink.
		if (HitActor == None && LinkedTo != None)
			BreakLink();
		else if (LinkedTo != None)
		{
			// If the hit actor or it's owner aren't LinkedTo, break the link.
			if (LinkedTo != HitActor && LinkedTo != HitActor.Owner)
				BreakLink();
			else if (DamageAmount >= MinimumDamage)
			{
				// If we're still linked, heal it.
				SavedDamage -= DamageAmount;
				LinkedTo.HealDamage(DamageAmount * 1.5, Instigator.Controller, DamageType);
			}
		}
		else
		{
			// Check if we can link to HitActor.
			if (HitActor.IsA('Vehicle') && OnSameTeam(HitActor))
			{
				LinkedTo = HitActor;
				Beam.LinkedPawn = Pawn(HitActor);
				Beam.bLockedOn = true;
			}
			else if (HitActor.IsA('DestroyableObjective') && DestroyableObjective(HitActor).TeamLink(Team))
				LinkedTo = DestroyableObjective(HitActor);
			else if (HitActor.IsA('ONSPowerNodeShield') && DestroyableObjective(HitActor.Owner) != None && DestroyableObjective(HitActor.Owner).TeamLink(Team))
				LinkedTo = DestroyableObjective(HitActor.Owner);

			// If we didn't link to anything, deal damage.
			if (HitActor != None && LinkedTo == None && DamageAmount >= MinimumDamage)
			{
				SavedDamage -= DamageAmount;
				HitActor.TakeDamage(DamageAmount, Instigator, HitLocation, vect(0,0,1) + Normal(Normal(Normal(HitLocation - Location) Cross vect(0,0,1)) * (Normal(Normal(HitLocation - Location) Cross vect(0,0,1)) dot (HitLocation - HitActor.Location))), DamageType);
			}
		}
	}
	function BreakLink()
	{
		LinkedTo = None;
		Beam.bLockedOn = false;
		Beam.LinkedPawn = None;
	}
}
function CeaseFire(Controller C)
{
	Super.CeaseFire(C);

	PlaySound(FireEnd, SLOT_None);

	// Destroy the beam.
	if (Beam != None)
		Beam.Destroy();

	bIsFiring = false;
}

DefaultProperties
{
	// Looks.
	Mesh = SkeletalMesh'UT3NightshadeAnims.NightshadeWeap';
	RedSkin = Shader'UT3NightshadeTex.Nightshader.NightshadeSkin';
	BlueSkin = Shader'UT3NightshadeTex.Nightshader.NightshadeSkinBlue';

	// Bones.
	YawBone = "Turret_Yaw";
	PitchBone = "Turret_Pitch";
	WeaponFireAttachmentBone = "Turret_Pitch";

	// Fire offset/speed.
	FireInterval = 0.0;
	AltFireInterval = 0.0;
	WeaponFireOffset = 5.0;

	// Damage/Aim.
	bInstantFire = true;
	TraceRange = 900;
	AimTraceRange = 900;
	Momentum = 50000.0;
	Damage = 120;
	MinimumDamage = 5.0;

	// Sound.
	FireStart = Sound'UT3A_Vehicle_Nightshade.UT3NightshadeFireStart.UT3NightshadeFireStartCue';
        FireSoundClass = Sound'UT3A_Vehicle_Nightshade.UT3NightshadeSingles.UT3NightshadeFireLoop01';
        FireEnd = Sound'UT3A_Vehicle_Nightshade.UT3NightshadeFireStop.UT3NightshadeFireStopCue';
	bAmbientFireSound = true;

	// Force feedback.
	FireForce = "LinkActivated";

	// AI.
	AIInfo(0)=(bLeadTarget=True,bInstantHit=True,AimError=100,bTrySplash=False,bTossed=False,bLeadTarget=True,bFireOnRelease=False,RefireRate=0.0)
}
