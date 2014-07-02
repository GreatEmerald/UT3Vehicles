//============================================================
// UT3 Goliath Mutator
// Copyright (c) José Luís, 2012
// Contact: 100gping100@gmail.com
//============================================================
class Mut_UT3Goliath extends Mutator;

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	local int a;
	
	if (SVehicleFactory(Other) != None && SVehicleFactory(Other).VehicleClass == Class'ONSHoverTank')
		SVehicleFactory(Other).VehicleClass = Class'UT3Goliath';
	
	return Super.CheckReplacement(Other, bSuperRelevant);
}

DefaultProperties
{
	// Strings.
	GroupName = "Goliath";
	FriendlyName = "UT3 Goliath";
	Description = "This mutator replaces the Goliath with the Goliath from UT3."
	
	// Misc.
	bAlwaysRelevant = true;
	RemoteRole = ROLE_SimulatedProxy;
	bAddToServerPackages = true;
}