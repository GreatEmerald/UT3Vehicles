/******************************************************************************
MutUT3Vehicles

Creation date: 2008-05-02 17:59
Last change: $Id$
Copyright (c) 2008, Wormbo
******************************************************************************/

class MutUT3Vehicles extends Mutator;

var bool bHasInteraction; //GE: True if a player owns an Interaction object

/**
Modifies vehicle factories that originally spawn Onslaught vehicles to spawn
the corresponding UT3 vehicles instead.
*/
function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	local SVehicleFactory Factory;

	if (SVehicleFactory(Other) != None) {
		Factory = SVehicleFactory(Other);
		switch (Factory.VehicleClass) {
		case class'ONSMobileAssaultStation':
			Factory.VehicleClass = class'UT3Leviathan';
			break;
		case class'ONSAttackCraft':
			Factory.VehicleClass = class'UT3Raptor';
			break;


		case class'ONSArtillery':
			Factory.VehicleClass = class'UT3HellfireSPMA';
			break;
		case class'ONSDualAttackCraft':
			Factory.VehicleClass = class'UT3Cicada';
			break;
		case class'ONSShockTank':
			Factory.VehicleClass = class'UT3Paladin';
			break;
		case class'ONSRV':
			Factory.VehicleClass = class'UT3Scorpion';
			break;
        case class'ONSHoverTank':
			Factory.VehicleClass = class'UT3Goliath';
			break;
        case class'ONSHoverBike':
			Factory.VehicleClass = class'UT3Manta';
			break;
        case class'ONSPRV':
			Factory.VehicleClass = class'UT3Hellbender';
			break;
		}
	}
	return Super.CheckReplacement(Other, bSuperRelevant);
}

/*
===========
GE: Spawn an Interaction. UT3 vehicles tend to use special keys, and this is
a great way of replicating such behavioiur. See UT3Scorpion for a use example.
===========
*/

simulated function Tick(float DeltaTime)
{
        local PlayerController PC;

        //UEWiki: If the player has an interaction already, exit function.
        if (bHasInteraction)
                Return;
        PC = Level.GetLocalPlayerController();

        //UEWiki: Run a check to see whether this mutator should create an interaction for the player
        if ( PC != None && !PC.PlayerReplicationInfo.bIsSpectator )  //TODO !!GE: if PC.Pawn.IsA('UT3Scorpion')
        {
        //        PC.Player.InteractionMaster.AddInteraction("UT3Style.UT3ScorpionInteraction", PC.Player); //UEWiki: Create the interaction
                bHasInteraction = True; //UEWiki: Set the variable so this lot isn't called again
        }
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
	FriendlyName = "UT3 Vehicles"
	Description  = "Replaces UT2004 vehicles with versions similar to their UT3 Axon counterparts."
	GroupName    = "VehicleArena"
    RemoteRole=ROLE_SimulatedProxy //GE: Needed for Interactions.
    bAlwaysRelevant=true           //GE: Needed for Interactions.
}
