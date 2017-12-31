/*
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

class UT3LeviathanPrimaryWeapon extends ONSMASCannon;

var bool bCurrentlyFiring;

var Material RedSkinB, BlueSkinB;

simulated state InstantFireMode
{
	
    function Explosion(float DamRad)
	{
    	local actor Victims;
    	local float damageScale, dist;
    	local vector Dir;

    	if (Role < ROLE_Authority)
    	   return;

    	foreach VisibleCollidingActors(class 'Actor', Victims, DamRad, GHitLocation)
    	{
    		if( (Victims != self) && (Victims != Instigator) && (Victims.Role == ROLE_Authority) && (!Victims.IsA('FluidSurfaceInfo')) )
    		{
    			Dir = Victims.Location - GHitLocation;
     			dist = FMax(1,VSize(Dir));
    			Dir = Dir/dist;
    			Dir.Z *= 5.0;
    			Dir = Normal(Dir);
    			damageScale = 1;

                if (Pawn(Victims) != None && Pawn(Victims).GetTeamNum() == Instigator.GetTeamNum())
                    damageScale = 0;

    			Victims.TakeDamage(
                    				damageScale * DamageMax,
                    				Instigator,
                    				Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * Dir,
                    				(damageScale * Momentum * Dir),
                    				DamageType
                    			  );
    		}
    	}
	}
	
	function AltFire(Controller C)
    {
	}

ImplodeExplode:
    Sleep(0.8);
    if (Level.NetMode != NM_DedicatedServer)
        Spawn(class'ONSMASCannonImplosionEffect',,, GHitLocation, rotator(GHitNormal));
    Sleep(2.3);
    Explosion(DamageRadius*0.125);
    Sleep(0.5);
    Explosion(DamageRadius*0.300);
    Sleep(0.2);
    Explosion(DamageRadius*0.475);
    Sleep(0.2);
    Explosion(DamageRadius*0.650);
    Sleep(0.2);
    Explosion(DamageRadius*0.825);
    Sleep(0.2);
    Explosion(DamageRadius*1.000);
}

simulated function SetTeam(byte T)
{
    Team = T;
    if (T == 0 && RedSkin != None)
    {
        Skins[0] = RedSkin;
        Skins[1] = RedSkinB;
        // GEm: TODO: Replication
        RepSkin = RedSkin;
    }
    else if (T == 1 && BlueSkin != None)
    {
        Skins[0] = BlueSkin;
        Skins[1] = BlueSkinB;
        RepSkin = BlueSkin;
    }
}

defaultproperties
{
    FireSoundClass = Sound'UT3A_Vehicle_Leviathan.Sounds.A_Vehicle_Leviathan_CannonFire01'

    Mesh = SkeletalMesh'UT3VH_Leviathan_Anims.Leviathan_MainTurreta'
    RedSkin = Shader'UT3LeviathanTex.Levi1.LeviathanSkin1'
    BlueSkin = Shader'UT3LeviathanTex.Levi1.LeviathanSkin1Blue'
    RedSkinB = Shader'UT3LeviathanTex.Levi2.LeviathanSkin2'
    BlueSkinB = Shader'UT3LeviathanTex.Levi2.LeviathanSkin2Blue'
    YawBone = "MainTurretYaw"
    PitchBone = "MainTurretPitch"
    WeaponFireAttachmentBone = "MainTurretPitch"
    DamageType=class'UT3DmgType_LeviathanCannon'
    RotationsPerSecond=0.22
    DamageMin=250
    DamageMax=250
    DamageRadius=2000
    Momentum=250000.0
}
