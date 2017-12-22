/*
 * Copyright © 2007 Wormbo
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

class UT3LeviathanTurretWeapon extends ONSMASSideGun;


//=============================================================================
// Properties
//=============================================================================

var name ShieldAttachmentBone;


//=============================================================================
// Variables
//=============================================================================

var UT3LeviathanShield Shield;
var bool bShieldActive, bLastShieldActive;
var byte ShieldHitCount, LastShieldHitCount;

var byte SkinSlot;


//=============================================================================
// Replication
//=============================================================================

replication
{
    reliable if (True)
        bShieldActive, ShieldHitCount;
}


simulated function PostNetBeginPlay()
{
    Super.PostNetBeginPlay();

    Shield = Spawn(class'UT3LeviathanShield', self);

    if (Shield != None)
        AttachToBone(Shield, ShieldAttachmentBone);
}


simulated function PostNetReceive()
{
    Super.PostNetReceive();

    if (bShieldActive != bLastShieldActive) {
        if (bShieldActive)
            ActivateShield();
        else
            DeactivateShield();

        bLastShieldActive = bShieldActive;
    }

    if (Shield != None && ShieldHitCount != LastShieldHitCount) {
        Shield.SpawnHitEffect(Team);

        LastShieldHitCount = ShieldHitCount;
    }
}


simulated function ActivateShield()
{
    bShieldActive = True;
    if (Shield != None)
        Shield.ActivateShield(Team);
}


simulated function DeactivateShield()
{
    bShieldActive = False;
    if (Shield != None)
        Shield.DeactivateShield();
}


function NotifyShieldHit()
{
    ShieldHitCount++;
    if (Shield != None)
        Shield.SpawnHitEffect(Team);
}


simulated function Destroyed()
{
    if (Shield != None)
        Shield.Destroy();

    Super.Destroyed();
}

simulated function SetTeam(byte T)
{
    Team = T;
    if (T == 0 && RedSkin != None)
    {
        Skins[SkinSlot] = RedSkin;
        RepSkin = RedSkin;
    }
    else if (T == 1 && BlueSkin != None)
    {
        Skins[SkinSlot] = BlueSkin;
        RepSkin = BlueSkin;
    }
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
    bNetNotify = True

    WeaponFireOffset     = 40.0
    ShieldAttachmentBone = Object84
    PitchDownLimit=55000
}
