/******************************************************************************
UT3LeviathanTurretWeapon

Creation date: 2007-12-30 13:56
Last change: $Id$
Copyright (c) 2007, Wormbo
******************************************************************************/

class UT3LeviathanTurretWeapon extends ONSMASSideGun;


//=============================================================================
// Properties
//=============================================================================

var name ShieldAttachmentBone;


//=============================================================================
// Variables
//=============================================================================

var UT3LeviathanShield Shield;
var bool bShieldActive, bLastShieldActive;
var byte ShieldHitCount, LastShieldHitCount;


//=============================================================================
// Replication
//=============================================================================

replication
{
    reliable if (True)
        bShieldActive, ShieldHitCount;
}


simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();
	
	Shield = Spawn(class'UT3LeviathanShield', self);
	
	if (Shield != None)
		AttachToBone(Shield, ShieldAttachmentBone);
}


simulated function PostNetReceive()
{
	Super.PostNetReceive();
	
	if (bShieldActive != bLastShieldActive) {
		if (bShieldActive)
			ActivateShield();
		else
			DeactivateShield();
		
		bLastShieldActive = bShieldActive;
	}
	
	if (Shield != None && ShieldHitCount != LastShieldHitCount) {
		Shield.SpawnHitEffect(Team);
		
		LastShieldHitCount = ShieldHitCount;
	}
}


simulated function ActivateShield()
{
	bShieldActive = True;
	if (Shield != None)
		Shield.ActivateShield(Team);
}


simulated function DeactivateShield()
{
	bShieldActive = False;
	if (Shield != None)
		Shield.DeactivateShield();
}


function NotifyShieldHit()
{
	ShieldHitCount++;
	if (Shield != None)
		Shield.SpawnHitEffect(Team);
}


simulated function Destroyed()
{
	if (Shield != None)
		Shield.Destroy();
	
	Super.Destroyed();
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
	bNetNotify = True
	
	WeaponFireOffset     = 40.0
	DualFireOffset       = 30.0
	ShieldAttachmentBone = Object84
}
