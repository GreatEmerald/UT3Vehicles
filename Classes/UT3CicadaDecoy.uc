/*
 * Copyright © 2018 GreatEmerald
 * Copyright © 2018 HellDragon
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
class UT3CicadaDecoy extends ONSDecoy;

var class<emitter> 	DecoyFlightSFXClass; 	// Class of the emitter to spawn for the effect
var class<emitter> 	DecoyLaunchSFXClass;	// Class of the emitter to spawn when launched
var emitter			DecoyFlightSFX;			// The actual effect
var float 			DecoyRange;				// Much much range before the decoy says look at me

var ONSDualAttackCraft	ProtectedTarget;	// Protect this vehicle

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	Velocity = Speed * Vector(Rotation);
}

simulated function PostNetBeginPlay()
{
	super.PostNetBeginPlay();

	if ( EffectIsRelevant(Location, false) )
		Spawn(DecoyLaunchSFXClass,,,location,Rotation);

	if ( (Level.NetMode != NM_DedicatedServer) && (DecoyFlightSFXClass != None) )
	{
		DecoyFlightSFX = spawn(DecoyFlightSFXClass);
		if (DecoyFlightSFX!=None)
			DecoyFlightSFX.SetBase(self);
	}
}

function bool CheckRange(actor Aggressor)
{
	return vsize(Aggressor.Location - location) <= DecoyRange;
}

simulated event Destroyed()	// Remove it from the Dual Attack craft's array
{
	local int i;

	super.Destroyed();

	if (ProtectedTarget!=None)
	{
		for (i=0;i<ProtectedTarget.Decoys.Length;i++)
		{
			if (ProtectedTarget.Decoys[i]!=none && ProtectedTarget.Decoys[i] == self)
			{
				ProtectedTarget.Decoys.Remove(i,1);
				return;
			}
		}
	}

	if (DecoyFlightSFX!=None)
		DecoyFlightSFX.Destroy();
}


simulated function Landed( vector HitNormal )
{
	super.Landed(HitNormal);
	Destroy();
}

defaultproperties
{
	LifeSpan=5.0
	DecoyFlightSFXClass=class'ONSDecoyFlight'
	DecoyLaunchSFXClass=class'UT3CicadaDecoyLaunch'
	DecoyRange=2048
    Speed=1000
    MaxSpeed=1500
    MomentumTransfer=10000
    Damage=50.0
    DamageRadius=250.0
    RemoteRole=ROLE_SimulatedProxy
    bBounce=true
    bNetTemporary=True
    Physics=PHYS_Falling
    AmbientSound=sound'CicadaSnds.Decoy.DecoyFlight'
}