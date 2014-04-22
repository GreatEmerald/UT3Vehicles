//============================================================
// Self Destruct Damage Type
// Credits: 100GPing100(José Luís)
// Copytight José Luís, 2012
// Contact: zeluis.100@gmail.com
//============================================================
class DmgType_SelfDestruct extends VehicleDamageType
	abstract;


static function IncrementKills (Controller KillerRI)
{
	super.IncrementKills(KillerRI);
}


DefaultProperties
{
	// Strings.
	DeathString="%k stung %o with a Viper self-destruct.";
	MaleSuicide="%o stung himself with his own Viper self-destruct."
	FemaleSuicide="%o stung herself with her own Viper self-destruct."
	
	// Misc.
	VehicleClass=Class'UT3Viper.UT3Viper';
	bDelayedDamage=true;
	bDetonatesGoop=true;
	FlashFog=(X=700.0);
}
