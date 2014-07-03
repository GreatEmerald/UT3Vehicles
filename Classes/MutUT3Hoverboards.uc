/*
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

class MutUT3Hoverboards extends Mutator;

var bool bHasInteraction; //GE: True if a player owns an Interaction object

simulated function Tick(float DeltaTime)
{
    local PlayerController PC;

    //UEWiki: If the player has an interaction already, exit function.
    if (bHasInteraction || !Level.Game.bAllowVehicles)
        Return;
    PC = Level.GetLocalPlayerController();

    //UEWiki: Run a check to see whether this mutator should create an interaction for the player
    if ( PC != None && !PC.PlayerReplicationInfo.bIsSpectator )
    {
        PC.Player.InteractionMaster.AddInteraction(string(class'UT3HoverboardInteraction'), PC.Player); //UEWiki: Create the interaction
        bHasInteraction = True; //UEWiki: Set the variable so this lot isn't called again
    }
}

defaultproperties
{
    FriendlyName = "UT3 Hoverboards"
    Description = "Allows using hoverboards in vehicular gametypes (press the translocator button to mount)."
    GroupName = "Translocator"
    RemoteRole = ROLE_SimulatedProxy //GE: Needed for Interactions.
    bAlwaysRelevant = true           //GE: Needed for Interactions.
}
