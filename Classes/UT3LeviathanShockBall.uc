/******************************************************************************
UT3LeviathanShockBall

Creation date: 2007-12-30 18:03
Last change: $Id$
Copyright (c) 2007 and 2009, Wormbo and GreatEmerald
******************************************************************************/

class UT3LeviathanShockBall extends UT3ShockBall; //GE: I'll just set it to UT3ShockBall.


//=============================================================================
// Variables
//=============================================================================

var bool bCanHitShields;


simulated function Explode(vector HitLocation, vector HitNormal)
{
	SuperExplosion();
}


simulated function ProcessTouch (Actor Other, vector HitLocation)
{
	if (bCanHitShields || UT3LeviathanShield(Other) == None) {
		Super.ProcessTouch(Other, HitLocation);
	}
}


simulated function Timer()
{
	bCanHitShields = True;
}


function SuperExplosion()
{
	local Actor HitActor, ExpFX;
	local vector HitLocation, HitNormal;

	HurtRadius(Damage, DamageRadius, MyDamageType, MomentumTransfer, Location);

	ExpFX = Spawn(class'ONSPRVComboEffect');
	if (Level.NetMode == NM_DedicatedServer) {
		if (ExpFX != None)
			ExpFX.LifeSpan = 0.25;
	}
	else if (EffectIsRelevant(Location,false)) {
		HitActor = Trace(HitLocation, HitNormal, Location - vect(0,0,120), Location,false);
		if (HitActor != None)
			Spawn(class'ComboDecal', self,, HitLocation, rotator(vect(0,0,-1)));
	}
	PlaySound(ComboSound, SLOT_None, 1.0,, 800);
	DestroyTrails();
	Destroy();
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
	Speed            =   1500.0
	MaxSpeed         =   1500.0
	Damage           =    120.0
	DamageRadius     =    300.0
}
