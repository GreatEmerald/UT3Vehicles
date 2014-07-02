/*
 * Copyright © 2008 Wormbo
 * Copyright © 2014 GreatEmerald
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 *     (1) Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *
 *     (2) Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimers in
 *     the documentation and/or other materials provided with the
 *     distribution.
 *
 *     (3) The name of the author may not be used to
 *     endorse or promote products derived from this software without
 *     specific prior written permission.
 *
 *     (4) The use, modification and redistribution of this software must
 *     be made in compliance with the additional terms and restrictions
 *     provided by the Unreal Tournament 2004 End User License Agreement.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
 * IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *
 * This software is not supported by Atari, S.A., Epic Games, Inc. or any
 * of such parties' affiliates and subsidiaries.
 */

class MutUT3NecrisVehicles extends Mutator;

//var bool bHasInteraction; //GE: True if a player owns an Interaction object

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
            Factory.VehicleClass = class'UT3Fury';
            break;


        case class'ONSArtillery':
            Factory.VehicleClass = class'UT3Nightshade';
            break;
        case class'ONSDualAttackCraft':
            Factory.VehicleClass = class'UT3Fury';
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
            Factory.VehicleClass = class'UT3Viper';
            break;
        case class'ONSPRV':
            Factory.VehicleClass = class'UT3Stealthbender';
            break;
        }
    }
    return Super.CheckReplacement(Other, bSuperRelevant);
}

/*
===========
GE: Spawn an Interaction. UT3 vehicles tend to use special keys, and this is
a great way of replicating such behavioiur. See UT3Scorpion for a use example.
GEm: No they don't, they use Rise and KDriverLeave you dummy
===========
*/

/*simulated function Tick(float DeltaTime)
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
}*/


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
    FriendlyName = "UT3 Necris Vehicles (experimental)"
    Description  = "Replaces UT2004 vehicles with versions similar to their UT3 Necris counterparts. This is just a preview, they are not yet ready for prime time."
    GroupName    = "VehicleArena"
    //RemoteRole=ROLE_SimulatedProxy //GE: Needed for Interactions.
    //bAlwaysRelevant=true           //GE: Needed for Interactions.
}
