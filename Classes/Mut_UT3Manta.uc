//============================================================
// UT3 Manta Mutator
// Credits: 100GPing100(José Luís)
// Copyright José Luís, 2012
// Contact: zeluis.100@gmail.com
//============================================================
class Mut_UT3Manta extends Mutator
	config(UT3Manta);

/* Name displayed for the setting. */
var localized string GUIDisplayText;
/* Description of the setting. */
var localized string GUIDescText;

/* Holds the value of the setting. */
var() config bool bAllowTransport;

//
// Replaces the old manta with the new one.
//
function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (SVehicleFactory(Other) != None && SVehicleFactory(Other).VehicleClass == Class'ONSHoverBike')
		SVehicleFactory(Other).VehicleClass = class'UT3Manta';
	
	return Super.CheckReplacement(Other, bSuperRelevant);
}

//
// Returns the description of PropName.
//
static event string GetDescriptionText(string PropName)
{
	if (PropName == "bAllowTransport")
		return default.GUIDescText;
	
	return Super.GetDescriptionText(PropName);
}

//
// Creates the configurable variables.
//
static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super.FillPlayInfo(PlayInfo);
	
	PlayInfo.AddSetting(default.RulesGroup, "bAllowTransport", default.GUIDisplayText, 0, 0, "Check");
}

//
// Apply the settings.
//
event PreBeginPlay()
{
	class'UT3Manta'.default.bCanBeBaseForPawns = bAllowTransport;
	
	Super.PreBeginPlay();
}

DefaultProperties
{
	// Strings.
	GroupName="Manta";
	FriendlyName="UT3 Manta";
	Description="This mutator replaces the Manta with the one from UT3. (Has settings)"
	
	// Settings.
	bAllowTransport = true;
	GUIDisplayText = "Allow carry";
	GUIDescText = "Whether or not you're able to carry players on top of the manta.";
	
	// Misc.
	bAlwaysRelevant=true;
	RemoteRole=ROLE_SimulatedProxy;
	bAddToServerPackages=true;
}