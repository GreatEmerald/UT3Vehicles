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

class UT3RagdollInventory extends RagdollInventory;

simulated function StartRagdoll(float Duration, bool bForced)
{

    local KarmaParamsSkel SkelParams;
    local String RagSkelName;
    local Controller C;
    local PlayerController PC;
    local xPawn P;
    local vector PawnVel;


    //log(self@"StartRagdoll: Start, DummyPawn"@DummyPawn@"Instigator"@Instigator@Instigator.Physics@Level.TimeSeconds);
    if(Instigator.Health <= 0)
    {
        Destroy();
        return;
    }
    if(!bRagdolling)
    {
        P = xPawn(Instigator);
        if(Instigator.DrivenVehicle != none)
            Instigator.DrivenVehicle.KDriverLeave(true);

        Instigator.bOwnerNoSee = false; //just to update pawn's mesh so that it is turned in the right direction
        Instigator.SetTwistLook(0,0);

        if(bPlayDeathSound)
            Instigator.PlayDyingSound();
        C = Instigator.Controller;
        if(C != none)
        {
            PC = PlayerController(C);
            if(PC != none)
                bLastBehindView = PC.bBehindView;
            DummyPawn = Spawn(class'UT3RagdollDummy',Instigator,,Instigator.Location);
            DummyPawn.MyPawn = Instigator;
            DummyPawn.SetRotation(Instigator.Rotation);
            //DummyPawn.SetOwner(Instigator);
            //Instigator.AttachToBone(DummyPawn, 'righthand');
            C.UnPossess();
            Instigator.SetOwner(C);
            C.Possess(DummyPawn);
            Instigator.PlayerReplicationInfo = C.PlayerReplicationInfo;
            if(PC != None && !class'UT3RagdollDummy'.default.bHeadView && !bLastBehindView)
                PC.ToggleBehindView(); //Check after DummyPawn is possessed
        }
        C = none;

        if(P.RagdollOverride != "")
            RagSkelName = P.RagdollOverride;
        else
            RagSkelName = P.Species.static.GetRagSkelName(P.GetMeshName());
        Instigator.KMakeRagdollAvailable();
        Instigator.bReplicateAnimations = false;

        if (!KIsRagdollAvailable())
        {
            bRagdolling = true;
            EndRagdoll();
            return;
        }
        skelParams = KarmaParamsSkel(Instigator.KParams);
        skelParams.KSkeleton = RagSkelName;
        PawnVel = Instigator.Velocity;
        if(Instigator.Base != none)
            PawnVel += Instigator.Base.Velocity;
        skelParams.KStartLinVel = PawnVel;
        //Instigator.KParams = skelParams;

        Instigator.KSetBlockKarma(true);

        Instigator.SetPhysics(PHYS_KarmaRagdoll);

        skelParams.bKImportantRagdoll = true;

        if (P.WeaponAttachment != None && WeaponMode != WM_Nothing)
        {
            if (bForced && WeaponMode == WM_Drop)
                Instigator.TossWeapon(Vector(Instigator.Rotation)*250);
            P.WeaponAttachment.Hide(true);
        }
    }
    bRagdolling = true;
    bForcedRagdoll = bForced;
    if(Duration > 0.0)
        RagdollTime = Level.TimeSeconds + Duration;
    LastToggleTime = Level.TimeSeconds;
    Instigator.bCanTeleport = false;
    //log(self@"StartRagdoll: End, DummyPawn"@DummyPawn@DummyPawn.Physics@"Instigator"@Instigator@Instigator.Physics);
    Enable('Tick');

    for (C=Level.ControllerList;C!=None;C=C.NextController)
    {
        if(C != none && C.Enemy == Instigator)
        C.Enemy = none;
    }
}

/*function Tick(float DeltaTime)
{
    if (bRagdolling && (DummyPawn == None || Instigator.Physics != PHYS_KarmaRagdoll))
    {
        log(self@"Tick: We have lost the ragdoll! Bail out!!!"@DummyPawn==None@DummyPawn.Physics@Instigator@Instigator.Physics);
        bForcedRagdoll = false;
        EndRagdoll(); // GEm: This disables Tick, too
        return;
    }
    Super.Tick(DeltaTime);
}

function bool EndRagdoll()
{
    log(self@"EndRagdoll: DummyPawn"@DummyPawn@DummyPawn.Physics@"Instigator"@Instigator@Instigator.Physics);
    return Super.EndRagdoll();
}*/

function Destroyed()
{
    if ( DummyPawn != None )
    {
        if (Instigator.Health > 0)
        {
            // GEm: Inventory is killed due to parent pawn getting axed in Karma's Excessive Joint Error. Needs a rewrite to fix.
            warn(self@"Destroyed: Karma killed the ragdoll and took the player with it!");
            bForcedRagdoll = false;
            EndRagdoll();
        }
        DummyPawn.Destroy();
    }
    Super(Inventory).Destroyed();
}

defaultproperties
{
    FeignDeathLimit = 1.0
    bPlayDeathSound = false
    LandDamageScale = 0.0
    bNoWallDamage = true
    bWaitForLowVel = true
    WeaponMode = WM_Hide
}
