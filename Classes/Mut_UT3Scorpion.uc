//============================================================
// UT3 Scorpion Mutator
// Credits: 100GPing100(José Luís)
// Copytight José Luís, 2012
// Contact: zeluis.100@gmail.com
//============================================================
class Mut_UT3Scorpion extends Mutator;

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (SVehicleFactory(Other) != None)
	{
		if (SVehicleFactory(Other).VehicleClass == Class'ONSRV')
			SVehicleFactory(Other).VehicleClass = Class'UT3Scorpion';
	}
	
	return Super.CheckReplacement(Other, bSuperRelevant);
}

DefaultProperties
{
	// Strings.
	GroupName="Scorpion";
	FriendlyName="UT3 Scorpion";
	Description="This mutator replaces the Scorpion with the Scorpion from UT3."
	
	// Misc.
	bAlwaysRelevant=true;
	RemoteRole=ROLE_SimulatedProxy;
	bAddToServerPackages=true;
}