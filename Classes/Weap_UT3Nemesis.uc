//============================================================
// UT3 Nemesis Mutator
// Contact: zeluis.100@gmail.com
// Copyright (c) 2012, José Luís '100GPing100'
//============================================================
class Weap_UT3Nemesis extends ONSWeapon;

/* Red and blue team beam effect classes. */
var class<ONSTurretBeamEffect> BeamEffectClass[2];

function TraceFire(Vector Start, Rotator Dir)
{
	local Vector HitLocation, HitNormal, End;
	local Actor Other;
	
	Super.TraceFire(Start, Dir);
	
	Vehicle(Owner).Driver.bBlockZeroExtentTraces = false;
	Other = Trace(HitLocation, HitNormal, Start + TraceRange * Vector(Dir), Start, true);
	Vehicle(Owner).Driver.bBlockZeroExtentTraces = true;
	
	if (Other == None)
		SpawnHitEffects(None, End, Vect(0,0,0));
	else
		SpawnHitEffects(Other, HitLocation, HitNormal);
}

state InstantFireMode
{
	simulated function SpawnHitEffects(actor HitActor, vector HitLocation, vector HitNormal)
	{
		local ONSTurretBeamEffect Beam;

		if (Level.NetMode != NM_DedicatedServer)
		{
			if (Role < ROLE_Authority)
			{
				CalcWeaponFire();
				DualFireOffset *= -1;
			}

			Beam = Spawn(BeamEffectClass[Team],,, WeaponFireLocation + (vect(100,0,25) >> rotator(HitLocation - WeaponFireLocation)), rotator(HitLocation - WeaponFireLocation));
			BeamEmitter(Beam.Emitters[0]).BeamDistanceRange.Min = VSize(WeaponFireLocation - HitLocation);
			BeamEmitter(Beam.Emitters[0]).BeamDistanceRange.Max = VSize(WeaponFireLocation - HitLocation);
			BeamEmitter(Beam.Emitters[1]).BeamDistanceRange.Min = VSize(WeaponFireLocation - HitLocation);
			BeamEmitter(Beam.Emitters[1]).BeamDistanceRange.Max = VSize(WeaponFireLocation - HitLocation);
			Beam.SpawnEffects(HitLocation, HitNormal);
		}
	}
}

DefaultProperties
{
	// Looks.
	Mesh = SkeletalMesh'UT3NemesisAnims.Nemesis_Turret';
	RedSkin = Shader'UT3NemesisTex.UT3NemesisSkinRed';
	BlueSkin = Shader'UT3NemesisTex.UT3NemesisSkinBlue';
	BeamEffectClass(0)=class'ONSTurretBeamEffect'
    BeamEffectClass(1)=class'ONSTurretBeamEffectBlue'
	DrawType = DT_None;
	
	// Other.
	RotationsPerSecond = 0.8;
	DualFireOffset = 55;
	FireInterval = 0.36;
	bAimable = true;
	
	// Bones.
	//YawBone = TurretYaw;
	//PitchBone = TurretPitfch;
	WeaponFireAttachmentBone = 'BarrelOffset';
	
	// Sound.
	FireSoundClass = Sound'WeaponSounds.ShockRifle.ShockRifleFire';
	
	// Instant Fire.
	bInstantFire = true;
	bDualIndependantTargeting=True
	DamageType = Class'DamTypeShockBeam';
	DamageMin = 50;
	DamageMax = 50;
	TraceRange = 17000;
	Momentum = 75000;
}
