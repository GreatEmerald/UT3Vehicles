/*
 * Copyright © 2008-2009 Wormbo
 * Copyright © 2008-2009, 2014 GreatEmerald
 * Copyright © 2012 100GPing100
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

class UT3RaptorWeapon extends ONSAttackCraftGun;

var(Sound) Sound HomingSound;

state ProjectileFireMode
{
    function Fire(Controller C)
    {
        if (Vehicle(Owner) != None && Vehicle(Owner).Team < 2)
            ProjectileClass = TeamProjectileClasses[Vehicle(Owner).Team];
        else
            ProjectileClass = TeamProjectileClasses[0];

        Super.Fire(C);
    }

    function AltFire(Controller C)
    {
        local ONSAttackCraftMissle M;
        local Vehicle V, Best;
        local float CurAim, BestAim;

        M = ONSAttackCraftMissle(SpawnProjectile(AltFireProjectileClass, True));
        if (M != None)
        {
            if (AIController(Instigator.Controller) != None)
            {
                V = Vehicle(Instigator.Controller.Enemy);
                if (V != None && (V.bCanFly || V.IsA('ONSHoverCraft')) && Instigator.FastTrace(V.Location, Instigator.Location))
                    M.SetHomingTarget(V);
            }
            else
            {
                BestAim = MinAim;
                for (V = Level.Game.VehicleList; V != None; V = V.NextVehicle)
                    if (V.Health > 0 && (V.bCanFly || V.IsA('ONSHoverCraft')) && V != Instigator && Instigator.GetTeamNum() != V.GetTeamNum())
                    {
                        CurAim = Normal(V.Location - WeaponFireLocation) dot vector(WeaponFireRotation);
                        if (CurAim > BestAim && Instigator.FastTrace(V.Location, Instigator.Location))
                        {
                            Best = V;
                            BestAim = CurAim;
                        }
                    }
                if (Best != None) {
                    M.SetHomingTarget(Best);
                    PlayOwnedSound(HomingSound, SLOT_Interact, 2.5*TransientSoundVolume);
                }
            }
        }
    }
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
    //===========================
    // @100GPing100
    FireSoundClass = Sound'UT3A_Vehicle_Raptor.Sounds.A_Vehicle_Raptor_Fire01';
    AltFireSoundClass = Sound'UT3A_Vehicle_Raptor.Sounds.A_Vehicle_Raptor_AltFire01_Dup';
    HomingSound = Sound'UT3A_Vehicle_Cicada.Sounds.A_Vehicle_Cicada_TargetLock01';
    Mesh = SkeletalMesh'UT3VH_Raptor_Anims.RaptorRightGunOnly'
    RedSkin = Shader'UT3RaptorTex.RaptorSkin'
    BlueSkin = Shader'UT3RaptorTex.RaptorSkinBlue'
    PitchBone = 'rt_gun'
    WeaponFireAttachmentBone = 'rt_gun';
    WeaponFireOffset = 10;
    DualFireOffset = 35;
    // @100GPing100
    //============EDN============
    FireInterval    = 0.2
    AltFireInterval = 1.2
    ProjectileClass=class'UT3RaptorProjRed'
    TeamProjectileClasses(0)=class'UT3RaptorProjRed'
    TeamProjectileClasses(1)=class'UT3RaptorProjBlue'
    RotationsPerSecond=0.11 //GE: Maybe too low?
    MinAim=0.930
    AltFireProjectileClass=class'UT3RaptorRocket'
    //HomingSound=Sound'UT3Weapons2.Generic.LockOn'
    //FireSoundClass=sound'UT3Vehicles.RAPTOR.RaptorFire'
    //AltFireSoundClass=sound'UT3Vehicles.RAPTOR.RaptorAltFire'
}
