//============================================================
// UT3 Nightshade Mutator
// Credits: 100GPing100(José Luís)
// Copytight José Luís, 2012
// Contact: zeluis.100@gmail.com
//============================================================
class Mut_UT3Nightshade extends Mutator;

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (SVehicleFactory(Other) != None)
	{
		if (SVehicleFactory(Other).VehicleClass == Class'ONSRV')
			SVehicleFactory(Other).VehicleClass = Class'UT3Nightshade.UT3Nightshade';
		//SVehicleFactory(Other).VehicleClass = Class'UT3Nightshade.UT3Nightshade';
	}
	
	return Super.CheckReplacement(Other, bSuperRelevant);
}

DefaultProperties
{
	// Strings.
	GroupName="Scorpion";
	FriendlyName="UT3 Nightshade";
	Description="This mutator replaces the Scorpion with the Nightshade from UT3."
	
	// Misc.
	bAlwaysRelevant=true;
	RemoteRole=ROLE_SimulatedProxy;
	bAddToServerPackages=true;
}