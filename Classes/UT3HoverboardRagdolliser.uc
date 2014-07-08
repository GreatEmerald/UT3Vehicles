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

class UT3HoverboardRagdolliser extends ReplicationInfo;

var Pawn Puppet;
var Pawn NewPawn;

simulated function Ragdollise(class<DamageType> DamType, vector HitLoc)
{
    if (Pawn(Owner) != None)
        Puppet = Pawn(Owner);
    else
        Destroy(); // GEm: If we don't have a puppet to ragdollise, life has no purpose

    //if (Puppet.Controller != None)
    //    Puppet.Controller.ClientDying(DamType, HitLoc);
    //Puppet.ShouldCrouch(true);
    if (xPawn(Puppet) != None)
        xPawn(Puppet).PlayDyingAnimation(DamType, HitLoc);
    if (PlayerController(Puppet.Controller) != None)
        PlayerController(Puppet.Controller).BehindView(true);
}

simulated function Destroyed()
{
    local Controller Puppeteer;

    if (Puppet == None)
    {
        Super.Destroyed();
        return;
    }

    //Puppet.ShouldCrouch(false);

    Puppeteer = Puppet.Controller;




    if ( Puppeteer.PawnClass != None )
        NewPawn = Spawn(Puppeteer.PawnClass,,,Puppet.Location,Puppet.Rotation);

    if( NewPawn==None )
    {
        NewPawn = Spawn(Level.Game.GetDefaultPlayerClass(Puppeteer),,,Puppet.Location,Puppet.Rotation);
    }
    if ( NewPawn == None )
    {
        log("UT3HoverboardRagdolliser: Could not spawn player of type "$Puppeteer.PawnClass);
        Puppeteer.GotoState('Dead');
        if ( PlayerController(Puppeteer) != None )
            PlayerController(Puppeteer).ClientGotoState('Dead','Begin');
        return;
    }
    NewPawn.Anchor = Puppet.Anchor;
    NewPawn.LastStartSpot = Puppet.LastStartSpot;
    NewPawn.LastStartTime = Puppet.LastStartTime;
    NewPawn.Inventory = Puppet.Inventory;

    if (Puppeteer != None)
        Puppeteer.UnPossess();
    Puppeteer.Possess(NewPawn);

    Puppeteer.ClientSetRotation(NewPawn.Rotation);
    if (PlayerController(Puppet.Controller) != None)
    {
        //PlayerController(Puppet.Controller).Restart();
        //PlayerController(Puppet.Controller).BehindView(false);
        //PlayerController(Puppet.Controller).EnterStartState();
    }
    //Puppet.DropToGround();
    //Puppet.SetAnimAction(Puppet.IdleWeaponAnim);
    Puppet.Destroy();
}

defaultproperties
{
    LifeSpan = 2.0
}
