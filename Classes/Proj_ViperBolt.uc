//============================================================
// UT3 Viper Weapon's Projectile
// Credits: 100GPing100(José Luís)
// Copytight José Luís, 2012
// Contact: zeluis.100@gmail.com
//============================================================
class Proj_ViperBolt extends ONSPlasmaProjectile;

#exec audio import group=Sounds file=..\Sounds\UT3Viper\ProjImpact.wav

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
    	TextToSpeech("TAKE THAT!", 1.0);
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
	//MyDamageType=class'UT3Viper.DmgType_ViperBolt';
	
	// Sound.
	ExplosionSound=Sound'UT3Viper.Sounds.ProjImpact';
	
	// Misc.
	LifeSpan=1.6;
	bBounce=true;
	bFixedRotationDir=true;
	
	// Parent (to be changed).
	HitEffectClass=class'Onslaught.ONSPlasmaHitPurple';
	PlasmaEffectClass=class'Onslaught.ONSPurplePlasmaSmallFireEffect';
}
