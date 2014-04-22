//============================================================
// UT3 Fury Mutator
// Credits: 100GPing100(José Luís)
// Copytight José Luís, 2012
// Contact: zeluis.100@gmail.com
//============================================================
class Mut_UT3Fury extends Mutator;

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (SVehicleFactory(Other) != None)
	{
		if (SVehicleFactory(Other).VehicleClass == Class'ONSAttackCraft')
			SVehicleFactory(Other).VehicleClass = Class'UT3Fury.UT3Fury';
	}
	
	return Super.CheckReplacement(Other, bSuperRelevant);
}

DefaultProperties
{
	// Strings.
	GroupName="Raptor";
	FriendlyName="UT3 Fury";
	Description="This mutator replaces the Raptor with the Fury from UT3."
	
	// Misc.
	bAlwaysRelevant=true;
	RemoteRole=ROLE_SimulatedProxy;
	bAddToServerPackages=true;
}
