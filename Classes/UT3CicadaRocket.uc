/*
 * Copyright © 2009, 2014 GreatEmerald
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

class UT3CicadaRocket extends ONSDualACRocket;

var(Sound) sound ExplosionSound;

simulated function Timer() //GE: Change the sound volume to something bearable
{
	local float dist,travelTime;
	local PlayerController PC;

	SetCollision(true,true);

	if (Level.NetMode != NM_DedicatedServer)
	{
		SmokeTrailEffect = Spawn(class'ONSDualMissileSmokeTrail',self);

		if ( EffectIsRelevant(location,false) )
		{
			PC = Level.GetLocalPlayerController();
			if ( (PC.ViewTarget != None) && (VSize(PC.ViewTarget.Location - Location) < 3000) )
				Spawn(class'ONSDualMissileIgnite',,,location,rotation);
		}

		SetDrawType(DT_None);

		PlaySound(IgniteSound, SLOT_Misc, 1.0, true, 512);
        //GE: Whoever did this apparently had no idea that this was a float, not a byte.
		AmbientSound = FlightSound;
	}

	Velocity = vector(Rotation) * MaxSpeed;

	if (!bFinalTarget)
	{
		Dist = vsize(Target - Location);
		TravelTime = Dist / vsize(Velocity);
		if ( FastTrace(SecondTarget, Location) )
		{
			if ( TravelTime < (SwitchTargetTime*0.9) )
			{
				Target = SecondTarget;
				bFinalTarget = true;
			}
		}
		else
		{

			if (TravelTime < SwitchTargetTime)
				SwitchTargetTime = TravelTime * 0.9;
		}

		GotoState('Spiraling');
	}
	else
	{
		if ( Vsize(Location - Target) <= KillRange )
		{
			GotoState('Homing');
		}
		else
		{

			GotoState('Spiraling');
		}
	}
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
    local PlayerController PC;

    PlaySound(ExplosionSound,,2.5*TransientSoundVolume);

    if ( EffectIsRelevant(Location,false) )
    {
            PC = Level.GetLocalPlayerController();
            if ( (PC.ViewTarget != None) && (VSize(PC.ViewTarget.Location - Location) < 8000) )
                Spawn(class'ONSDualMissileExplosion',,,HitLocation + HitNormal*20,rotator(HitNormal));
    }

    BlowUp(HitLocation);
    Destroy();
}

DefaultProperties
{
   Speed=1000.000000
   MaxSpeed=4000.000000
   MomentumTransfer=40000.000000
   DamageRadius=220.000000
   KillRange=2000.000000
   IgniteSound=Sound'UT3A_Vehicle_Cicada.UT3CicadaMissileIgnite.UT3CicadaMissileIgniteCue'
   ExplosionSound=SoundGroup'UT3A_Weapon_RocketLauncher.UT3RocketImpact.UT3RocketImpactCue'
}
