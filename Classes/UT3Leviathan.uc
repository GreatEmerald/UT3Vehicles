/*******************************************************************************
UT3Leviathan

Creation date: 2007-12-30 13:00
Last change: $Id$
Copyright (c) 2007 and 2009, Wormbo and GreatEmerald
*******************************************************************************/

class UT3Leviathan extends ONSMobileAssaultStation;


//=============================================================================
// Variables
//=============================================================================



//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
	VehicleNameString = "UT3 Leviathan"

	Health = 6500

	DriverWeapons(0) = (WeaponClass=class'UT3LeviathanDriverWeapon')

	PassengerWeapons(0) = (WeaponPawnClass=class'UT3LeviathanTurretBeam')
	PassengerWeapons(1) = (WeaponPawnClass=class'UT3LeviathanTurretRocket')
	PassengerWeapons(2) = (WeaponPawnClass=class'UT3LeviathanTurretStinger')
	PassengerWeapons(3) = (WeaponPawnClass=class'UT3LeviathanTurretShock')

	CollisionHeight=100.0
      LSDFactor=1.000000
      ChassisTorqueScale=0.200000
      MaxSteerAngleCurve=(Points=((OutVal=30.000000),(InVal=1500.000000,OutVal=20.000000)))
      SteerSpeed=50.000000
      //EngineBrakeFactor=0.020000
      MaxBrakeTorque=8.000000
      //StopThreshold=500.000000
}
