/******************************************************************************
UT3LeviathanTurretWeaponBeam

Creation date: 2007-12-30 14:13
Last change: $Id$
Copyright (c) 2007, Wormbo
******************************************************************************/

class UT3LeviathanTurretWeaponBeam extends UT3LeviathanTurretWeapon;

#exec obj load file=ONSWeapons-A.ukx
#exec obj load file=TurretParticles.utx

var class<ONSTurretBeamEffect> BeamEffectClass[2];

static function StaticPrecache(LevelInfo L)
{
	L.AddPrecacheMaterial(Material'TurretParticles.Beams.TurretBeam5');
	L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaMuzzleBlue');
	L.AddPrecacheMaterial(Material'EpicParticles.Flares.SoftFlare');
	L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaStar2');
	L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.SmokePanels1');
	L.AddPrecacheMaterial(Material'XEffectMat.shock_flare_a');
	L.AddPrecacheMaterial(Material'XEffectMat.Shock_ring_b');
	L.AddPrecacheMaterial(Material'XEffectMat.Shock.shock_mark_heat');
	L.AddPrecacheMaterial(Material'XEffectMat.shock_core');
}

simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial(Material'TurretParticles.Beams.TurretBeam5');
	Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaMuzzleBlue');
	Level.AddPrecacheMaterial(Material'EpicParticles.Flares.SoftFlare');
	Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaStar2');
	Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.SmokePanels1');
	Level.AddPrecacheMaterial(Material'XEffectMat.shock_flare_a');
	Level.AddPrecacheMaterial(Material'XEffectMat.Shock_ring_b');
	Level.AddPrecacheMaterial(Material'XEffectMat.Shock.shock_mark_heat');
	Level.AddPrecacheMaterial(Material'XEffectMat.shock_core');

	Super.UpdatePrecacheMaterials();
}


function TraceFire(Vector Start, Rotator Dir)
{
	local Vector X, End, HitLocation, HitNormal;
	local Actor Other;
	local int Damage;

	X = Vector(Dir);
	End = Start + TraceRange * X;

	//skip past vehicle driver
	if (ONSVehicle(Instigator) != None && ONSVehicle(Instigator).Driver != None) {
		ONSVehicle(Instigator).Driver.bBlockZeroExtentTraces = False;
		Other = Trace(HitLocation, HitNormal, End, Start, True);
		ONSVehicle(Instigator).Driver.bBlockZeroExtentTraces = true;
	}
	else
		Other = Trace(HitLocation, HitNormal, End, Start, True);

	if (Other != None) {
		if (!Other.bWorldGeometry) {
			Damage = (DamageMin + Rand(DamageMax - DamageMin));
			Other.TakeDamage(Damage, Instigator, HitLocation, Momentum * X, DamageType);
			HitNormal = vect(0,0,0);
		}
	}
	else {
		HitLocation = End;
		HitNormal = Vect(0,0,0);
	}

	HitCount++;
	LastHitLocation = HitLocation;
	SpawnHitEffects(Other, HitLocation, HitNormal);
}

state InstantFireMode
{
	simulated function SpawnHitEffects(actor HitActor, vector HitLocation, vector HitNormal)
	{
		local ONSTurretBeamEffect Beam;

		if (Level.NetMode != NM_DedicatedServer) {
			if (Role < ROLE_Authority) {
				CalcWeaponFire();
				DualFireOffset *= -1;
			}

			Beam = Spawn(BeamEffectClass[Team],,, WeaponFireLocation, rotator(HitLocation - WeaponFireLocation));
			BeamEmitter(Beam.Emitters[0]).BeamDistanceRange.Min = VSize(WeaponFireLocation - HitLocation);
			BeamEmitter(Beam.Emitters[0]).BeamDistanceRange.Max = VSize(WeaponFireLocation - HitLocation);
			BeamEmitter(Beam.Emitters[1]).BeamDistanceRange.Min = VSize(WeaponFireLocation - HitLocation);
			BeamEmitter(Beam.Emitters[1]).BeamDistanceRange.Max = VSize(WeaponFireLocation - HitLocation);
			Beam.SpawnEffects(HitLocation, HitNormal);
		}
	}
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
	bInstantFire = True
	DamageMin    = 35
	DamageMax    = 35
	Spread(0)    = 0
	Momentum     = 60000.0
	DamageType   = class'DamTypeTurretBeam'
	FireInterval = 0.3

	FireSoundClass = Sound'UT3Weapons.ShockRifle.ShockRiflePrimary'

	BeamEffectClass(0) = class'ONSTurretBeamEffect'
	BeamEffectClass(1) = class'ONSTurretBeamEffectBlue'
}
