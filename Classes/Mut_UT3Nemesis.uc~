//============================================================
// UT3 Nemesis Mutator
// Contact: zeluis.100@gmail.com
// Copyright (c) 2012, José Luís '100GPing100'
//============================================================
class Mut_UT3Nemesis extends Mutator;

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (SVehicleFactory(Other) != None)
	{
		if (SVehicleFactory(Other).VehicleClass == Class'ONSShockTank')
			SVehicleFactory(Other).VehicleClass = Class'UT3Nemesis';
	}
	
	return Super.CheckReplacement(Other, bSuperRelevant);
}

DefaultProperties
{
	// Strings.
	GroupName="Paladin";
	FriendlyName="UT3 Nemesis";
	Description="This mutator replaces the Paladin with the Nemesis from UT3."
	
	// Misc.
	bAlwaysRelevant=true;
	RemoteRole=ROLE_SimulatedProxy;
	bAddToServerPackages=true;
}
