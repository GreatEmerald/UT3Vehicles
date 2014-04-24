/******************************************************************************
UT3LeviathanTurretWeaponRocket

Creation date: 2007-12-30 14:14
Last change: Alpha 2
Copyright (c) 2007 and 2009, Wormbo and GreatEmerald
******************************************************************************/

class UT3LeviathanTurretWeaponRocket extends UT3LeviathanTurretWeapon;


//=============================================================================
// Imports
//=============================================================================

#exec obj load file=WeaponSounds.uax


//=============================================================================
// Properties
//=============================================================================

var int RocketBurstSize;
var float RocketBurstInterval;


//=============================================================================
// Variables
//=============================================================================

var int RemainingRockets;
var Controller FireController;


state ProjectileFireMode
{
	function Fire(Controller C)
	{
		RemainingRockets = RocketBurstSize;
		ActuallyFire();
	}

	function Timer()
	{
		// begin copy/paste from AttemptFire()
		CalcWeaponFire();
		if (bCorrectAim)
			WeaponFireRotation = AdjustAim(false);
		if (Spread > 0)
			WeaponFireRotation = rotator(vector(WeaponFireRotation) + VRand() * FRand() * Spread);

		DualFireOffset *= -1;
		Instigator.MakeNoise(1.0);
		// end copy/paste from AttemptFire()

		ActuallyFire();
	}

	function ActuallyFire()
	{
		if (Instigator != None && Instigator.Controller != None) {
			RemainingRockets--;
		}
		else {
			RemainingRockets = 0;
			return;
		}
		SpawnProjectile(ProjectileClass, false);

		if (RemainingRockets > 0)
			SetTimer(RocketBurstInterval, false);
	}
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
	ProjectileClass     = Class'UT3LeviathanRocket'
	FireSoundClass      = Sound'UT3Weapons2.RocketLauncher.RocketLauncherFire'
	RocketBurstSize     = 4
	RocketBurstInterval = 0.15
	FireInterval        = 2.0
}
