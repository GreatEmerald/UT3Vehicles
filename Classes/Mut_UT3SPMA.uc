class Mut_UT3SPMA extends Mutator;

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    if (SVehicleFactory(Other) != none && SVehicleFactory(Other).VehicleClass == class'ONSArtillery') {
        SVehicleFactory(Other).VehicleClass = class'UT3HellfireSPMA';
    }
    
    return super.CheckReplacement(Other, bSuperRelevant);
}

DefaultProperties
{
    // Strings.
	GroupName = "SPMA";
	FriendlyName = "UT3 SPMA";
	Description = "This mutator replaces the SPMA with the one from UT3.";
	
	// Misc.
	bAlwaysRelevant = true;
	RemoteRole = ROLE_SimulatedProxy;
	bAddToServerPackages = true;
}
