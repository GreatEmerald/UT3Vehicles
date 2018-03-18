/*
 * Copyright © 2009 Wormbo
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

class UT3HellfireSPMAShellChild extends ONSArtilleryShellSmall;


simulated function PostBeginPlay()
{
    local Rotator R;
    local PlayerController PC;

    if (!PhysicsVolume.bWaterVolume && Level.NetMode != NM_DedicatedServer) {
        PC = Level.GetLocalPlayerController();
        if (PC.ViewTarget != None && VSize(PC.ViewTarget.Location - Location) < 6000)
            Trail = Spawn(class'UT3HellfireSPMAChildTrail', self);
        Glow = Spawn(class'FlakGlow', self);
    }

    Super(Projectile).PostBeginPlay();
    R = Rotation;
    R.Roll = 32768;
    SetRotation(R);
}


simulated function SpawnEffects(vector HitLocation, vector HitNormal)
{
    local PlayerController PC;

    PlaySound(ImpactSound, SLOT_None, 2.0);
    if (EffectIsRelevant(Location, false)) {
        PC = Level.GetLocalPlayerController();
        if (PC.ViewTarget != None && VSize(PC.ViewTarget.Location - Location) < 3000)
            Spawn(ExplosionEffectClass,,, HitLocation + HitNormal * 16);
        Spawn(ExplosionEffectClass,,, HitLocation + HitNormal * 16);
        if (ExplosionDecal != None && Level.NetMode != NM_DedicatedServer)
            Spawn(ExplosionDecal, self,, HitLocation, rotator(-HitNormal));
    }
}

simulated function ExplodeInAir()
{
    bExploded = true;
    PlaySound(sound'ONSBPSounds.Artillery.ShellFragmentExplode', SLOT_None, 2.0);
    if ( Level.NetMode != NM_DedicatedServer )
        spawn(AirExplosionEffectClass);

    Explode(Location, vect(0,0,0));
    Destroy();
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{

//=============================================================================
// Appearance
//=============================================================================
    AirExplosionEffectClass = class'UT3HellfireSPMAAirExplosion'
    ExplosionEffectClass    = class'UT3HellfireSPMAAirExplosion'
  
//=============================================================================
// Sound
//=============================================================================
    ImpactSound  = Sound'UT3A_Vehicle_SPMA.UT3SPMAShellFragmentExplode.UT3SPMAShellFragmentExplodeCue'
    AmbientSound = None
    TransientSoundRadius = 500.0

//=============================================================================
// Health & Damage
//=============================================================================
    Damage       = 220.0
    DamageRadius = 500.0

}
