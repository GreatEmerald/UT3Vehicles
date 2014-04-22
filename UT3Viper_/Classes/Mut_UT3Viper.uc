//============================================================
// UT3 Viper Mutator
// Credits: 100GPing100(José Luís)
// Copytight José Luís, 2012
// Contact: zeluis.100@gmail.com
//============================================================
class Mut_UT3Viper extends Mutator;

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (SVehicleFactory(Other) != None)
	{
		if (SVehicleFactory(Other).VehicleClass == Class'ONSHoverBike')
			SVehicleFactory(Other).VehicleClass = Class'UT3Viper.UT3Viper';
	}
	
	return Super.CheckReplacement(Other, bSuperRelevant);
}

DefaultProperties
{
	// Strings.
	GroupName="Manta";
	FriendlyName="UT3 Viper";
	Description="This mutator replaces the Manta with the Viper from UT3."
	
	// Misc.
	bAlwaysRelevant=true;
	RemoteRole=ROLE_SimulatedProxy;
	bAddToServerPackages=true;
}
