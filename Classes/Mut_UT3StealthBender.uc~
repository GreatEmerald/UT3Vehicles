//============================================================
// UT3 StealthBender Mutator
// Contact: zeluis.100@gmail.com
// Copyright José Luís '100GPing100', 2012
//============================================================
class Mut_UT3StealthBender extends Mutator;

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (SVehicleFactory(Other) != None)
	{
		if (SVehicleFactory(Other).VehicleClass == Class'ONSPRV')
			SVehicleFactory(Other).VehicleClass = Class'UT3StealthBender';
	}
	
	return Super.CheckReplacement(Other, bSuperRelevant);
}

DefaultProperties
{
	// Strings.
	GroupName="Hellbender";
	FriendlyName="UT3 StealthBender";
	Description="This mutator replaces the Hellbender with the StealthBender from UT3."
	
	// Misc.
	bAlwaysRelevant=true;
	RemoteRole=ROLE_SimulatedProxy;
	bAddToServerPackages=true;
}