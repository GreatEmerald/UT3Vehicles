/******************************************************************************
UT3LeviathanTurretWeaponShock

Creation date: 2007-12-30 14:14
Last change: Alpha 2
Copyright (c) 2007 and 2009, Wormbo and GreatEmerald
******************************************************************************/

class UT3LeviathanTurretWeaponShock extends UT3LeviathanTurretWeapon;


//=============================================================================
// Imports
//=============================================================================

#exec obj load file=ONSVehicleSounds-S.uax


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
	ProjectileClass = class'UT3LeviathanShockBall'
	FireSoundClass  = Sound'UT3Weapons.ShockRifle.ShockRifleAlt'
	FireInterval    = 0.5
}
