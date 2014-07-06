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

class UT3HoverboardInteraction extends Interaction;

var float LastCallTime;

function bool KeyEvent(EInputKey Key, EInputAction Action, FLOAT Delta )
{
    local array<EInputKey> Keys;
    local int i;
    local Pawn LocalPawn;
    local Vehicle NewHoverboard;

    LocalPawn = ViewportOwner.Actor.Pawn;
    Keys = GetKeyBindNum("SwitchWeapon 10", ViewportOwner.Actor);
    for (i = 0; i < Keys.length; i++)
    {
        if (Action == IST_Press && Key == Keys[i]
            && LocalPawn != None && LocalPawn.Health > 0)
        {
            if (Vehicle(LocalPawn) == None && !LocalPawn.PhysicsVolume.bWaterVolume
                && ViewportOwner.Actor.Level.TimeSeconds > LastCallTime + 1.0)
            {
                // GEm: Spawn a hoverboard and autoenter it
                NewHoverboard = LocalPawn.Spawn(class'UT3Hoverboard');
                if (NewHoverboard != None)
                    NewHoverboard.TryToDrive(LocalPawn);
            }
            else if (UT3Hoverboard(LocalPawn) != None)
            {
                UT3Hoverboard(LocalPawn).KDriverLeave(false);
                LastCallTime = ViewportOwner.Actor.Level.TimeSeconds;
            }
        }
    }

    return false;
}

static function array<EInputKey> GetKeyBindNum( string Cmd, PlayerController Ref )
{
    local string BindStr;
    local array<string> Bindings;
    local array<EInputKey> Results;
    local int i, idx, Key;

    if ( Ref == None || Cmd == "" )
        return Results;

    BindStr = Ref.ConsoleCommand("BINDINGTOKEY" @ "\"" $ Cmd $ "\"");
    if ( BindStr != "" )
    {
        Split(BindStr, ",", Bindings);
        if ( Bindings.Length > 0 )
        {
            for ( i = 0; i < Bindings.Length; i++ )
            {
                Key = int(Ref.ConsoleCommand("KEYNUMBER"@Bindings[i]));
                if (Key != -1)
                {
                    Results[idx] = EInputKey(Key);
                    idx++;
                }
            }
        }
    }

    return Results;
}

function NotifyLevelChange()
{
    Master.RemoveInteraction(self);
}

defaultproperties
{
    bActive = true
}
