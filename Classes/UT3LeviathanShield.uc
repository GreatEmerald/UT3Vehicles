/******************************************************************************
UT3LeviathanShield

Creation date: 2007-12-30 13:23
Last change: $Id$
Copyright (c) 2007, Wormbo
******************************************************************************/

class UT3LeviathanShield extends ONSShockTankShield;


function TakeDamage(int Dam, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType)
{
	if (UT3LeviathanTurretWeapon(Owner) != None)
		UT3LeviathanTurretWeapon(Owner).NotifyShieldHit();
}


simulated function SpawnHitEffect(byte TeamNum)
{
	if (Level.NetMode != NM_DedicatedServer) {
		if (ShockShieldEffect != None) {
			if (TeamNum == 1)
				ShockShieldHitEffect = Spawn(class'UT3LeviathanShieldHitEffectBlue', self);
			else
				ShockShieldHitEffect = Spawn(class'UT3LeviathanShieldHitEffectRed', self);
		}
		
		if (ShockShieldHitEffect != None && Owner != None && UT3LeviathanTurretWeapon(Owner) != None)
			Owner.AttachToBone(ShockShieldEffect, UT3LeviathanTurretWeapon(Owner).ShieldAttachmentBone);
	}
}


simulated function ActivateShield(byte TeamNum)
{
	SetCollision(True, False, False);
	
	if (Level.NetMode != NM_DedicatedServer) {
		if (ShockShieldEffect == None) {
			if (TeamNum == 1)
				ShockShieldEffect = Spawn(class'UT3LeviathanShieldEffectBlue', self);
			else
				ShockShieldEffect = Spawn(class'UT3LeviathanShieldEffectRed', self);
			
			PlaySound(Sound'ONSBPSounds.ShockTank.ShieldActivate', SLOT_None, 2.0);
		}
		
		if (ShockShieldEffect != None && Owner != None && UT3LeviathanTurretWeapon(Owner) != None)
			Owner.AttachToBone(ShockShieldEffect, UT3LeviathanTurretWeapon(Owner).ShieldAttachmentBone);
	}
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
	DrawScale3D = (X=0.6,Y=0.75,Z=1.0)
}
