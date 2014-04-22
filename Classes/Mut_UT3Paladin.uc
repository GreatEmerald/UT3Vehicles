//============================================================
// UT3 Paladin Mutator
// Credits: 100GPing100(José Luís)
// Copytight José Luís, 2012
// Contact: zeluis.100@gmail.com
//============================================================
class Mut_UT3Paladin extends Mutator;

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (SVehicleFactory(Other) != None && SVehicleFactory(Other).VehicleClass == Class'ONSShockTank')
		SVehicleFactory(Other).VehicleClass = Class'UT3Paladin';
	
	return Super.CheckReplacement(Other, bSuperRelevant);
}

DefaultProperties
{
	// Strings.
	GroupName="Paladin";
	FriendlyName="UT3 Paladin";
	Description="This mutator replaces the Paladin with the one from UT3."
	
	// Misc.
	bAlwaysRelevant=true;
	RemoteRole=ROLE_SimulatedProxy;
	bAddToServerPackages=true;
}