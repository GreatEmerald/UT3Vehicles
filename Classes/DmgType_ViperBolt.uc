//============================================================
// UT3 Viper Weapon Projectile's Damage Type
// Credits: 100GPing100(José Luís)
// Copytight José Luís, 2012
// Copyright GreatEmerald, 2014
// Contact: zeluis.100@gmail.com
//============================================================
class DmgType_ViperBolt extends WeaponDamageType
	abstract;

DefaultProperties
{
	// Strings.
	DeathString="%k kills %o with a Viper Gun.";
	MaleSuicide="%o kills himself with his own Viper Gun.";
	FemaleSuicide="%o kills herself with her own Viper Gun.";

	// Vehicle.
	VehicleMomentumScaling=1.0;
	VehicleDamageScaling=0.7;

	// Misc.
	WeaponClass=class'Weap_ViperGun';
	bCausesBlood=false;
}
