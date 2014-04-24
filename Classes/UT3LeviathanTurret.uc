/******************************************************************************
UT3LeviathanTurret

Creation date: 2007-12-30 13:10
Last change: $Id$
Copyright (c) 2007, Wormbo
******************************************************************************/

class UT3LeviathanTurret extends ONSMASSideGunPawn abstract;


//=============================================================================
// Properties
//=============================================================================

var float ShieldDuration;
var float ShieldRecharge;


//=============================================================================
// Variables
//=============================================================================

var float ShieldAvailableTime;


/**
Best mode is always primary. Shield activation is handled separately for bots.
*/
function byte BestMode()
{
	return 0;
}

/*
/**
React to incoming AVRiLs.
*/
function ShouldTargetMissile(Projectile P)
{
	local vector ;
	
	if (Bot(Controller) != None && Bot(Controller).Skill >= 3.0) {
		GetAxes(VehicleBase.Rotation, X, Y, Z);
	}
}
*/


/**
Shield charge bar fill percentage.
*/
simulated function float ChargeBar()
{
	if (UT3LeviathanTurretWeapon(Gun) != None && !bHasAltFire) {
		if (UT3LeviathanTurretWeapon(Gun).bShieldActive)
			return FClamp(1.0 - TimerCounter / ShieldDuration, 0.0, 0.999);
		else
			return FClamp(1.0 - (ShieldAvailableTime - Level.TimeSeconds) / ShieldRecharge, 0.0, 0.999);
	}
	return 0;
}


/**
Activate shield on alt-fire.
*/
function AltFire(optional float F)
{
	if (!bHasAltFire) {
		ActivateShield();
	}
	else {
		Super.AltFire(F);
	}
}


/**
Deactivate the shield and set its recharge delay.
*/
function ActivateShield()
{
	if (UT3LeviathanTurretWeapon(Gun) != None && Level.TimeSeconds >= ShieldAvailableTime) {
		ShieldAvailableTime = Level.TimeSeconds + ShieldDuration + ShieldRecharge;
		SetTimer(ShieldDuration, false);
		UT3LeviathanTurretWeapon(Gun).ActivateShield();
	}
}


/**
Deactivate the shield and set its recharge delay.
*/
function DeactivateShield()
{
	if (UT3LeviathanTurretWeapon(Gun) != None && UT3LeviathanTurretWeapon(Gun).bShieldActive) {
		ShieldAvailableTime = Level.TimeSeconds + ShieldRecharge;
		UT3LeviathanTurretWeapon(Gun).DeactivateShield();
	}
}


/**
Deactivate shield after its time runs out.
*/
function Timer()
{
	DeactivateShield();
}


function DriverLeft()
{
	DeactivateShield();
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
	bShowChargingBar = True
	bHasAltFire      = False
	ShieldDuration   = 4.0
	ShieldRecharge   = 5.0
}
