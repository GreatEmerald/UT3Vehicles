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

class UT3Proj_ViperBolt extends ONSPlasmaProjectile;

/* Sound played on impact and explosion. */
var Sound ExplosionSound;
/* Number of times it can bounce before exploding. */
var int Bounces;


simulated event HitWall(vector HitNormal, Actor HitWall)
{
	if (HitWall.bCanBeDamaged) {
		Explode(Location, HitNormal);
	}

	SetPhysics(PHYS_Falling);
	if (Bounces > 0) {
		PlaySound(ExplosionSound);
		Velocity = 0.8 * (Velocity - 2.0 * HitNormal * (Velocity dot HitNormal));
		SetRotation(rotator(Velocity));
		Acceleration = AccelerationMagnitude * Normal(Velocity);
		--Bounces;
	} else {
		Explode(Location, HitNormal);
	}
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	if (EffectIsRelevant(Location, false)) {
		Spawn(HitEffectClass,,, HitLocation + HitNormal * 5, rotator(-HitNormal));
	}

	PlaySound(ExplosionSound);

	Destroy();
}

simulated function ProcessTouch(Actor Other, vector HitLocation)
{
    if (Other != Instigator && (Vehicle(Instigator) == None || Vehicle(Instigator).Driver != Other))
    {
	    Other.TakeDamage(Damage, Instigator, HitLocation, Normal(Velocity) * MomentumTransfer, MyDamageType);
		Explode(HitLocation, Normal(HitLocation-Other.Location));
    }
}


DefaultProperties
{
	// Movement.
	Speed=750.0;
	MaxSpeed=7000;
	AccelerationMagnitude=16000.0;
	Bounces=3;

	// Damage.
	Damage=36;
	DamageRadius=0;
	MomentumTransfer=4000;
	//MyDamageType=class'DmgType_ViperBolt';

	// Sound.
	ExplosionSound=Sound'UT3A_Vehicle_Viper.Singles.A_Vehicle_Viper_PrimaryFireImpact';

	// Misc.
	LifeSpan=1.6;
	bBounce=true;
	bFixedRotationDir=true;

	// Parent (to be changed).
	HitEffectClass=class'Onslaught.ONSPlasmaHitPurple';
	PlasmaEffectClass=class'Onslaught.ONSPurplePlasmaSmallFireEffect';
}
