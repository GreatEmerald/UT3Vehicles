/*
 * Copyright © 2007 Wormbo
 * Copyright © 2014 GreatEmerald
 * Copyright © 2017 HellDragon
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

class UT3LeviathanTurretBeam extends UT3LeviathanTurret;


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
    GunClass=class'UT3LeviathanTurretWeaponBeam'
    VehiclePositionString="in a Leviathan beam turret"
    VehicleNameString="Leviathan Beam Turret"

    EnterAnim = "lt_front_turret_deplying"
    LeaveAnim = "lt_front_turret_undeplyed"
    ArmBone = "Lt_Front_TurretArm1"
    //CameraBone = "Lt_Front_Turret_Barrel"
    CameraBone = "LT_Front_TurretPitch"

    ExitPositions(0)=(X=450,Y=-410,Z=210)
    ExitPositions(1)=(X=580,Y=-120,Z=210)
    ExitPositions(2)=(X=580,Y=-410,Z=180)
    ExitPositions(3)=(X=450,Y=-120,Z=180)
    ExitPositions(4)=(X=230,Y=-90,Z=280)
    
    FPCamPos=(X=50,Y=0,Z=50)
    TPCamLookAt=(X=-100,Y=0,Z=0)
    TPCamWorldOffset=(X=0.0,Y=0.0,Z=80.0)
    TPCamDistance=95.000000
    
}
