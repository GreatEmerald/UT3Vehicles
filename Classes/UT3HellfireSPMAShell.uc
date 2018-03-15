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

class UT3HellfireSPMAShell extends ONSMortarShell;


var Sound AirExplosionSound;
var class<Projectile> ChildProjectileClass;
var float SpreadFactor;
var Emitter SmokeTrail;

// flight correction hack
var float t0, v0, h0, g0;


simulated function PostBeginPlay()
{
    Super(Projectile).PostBeginPlay();

    if (Level.NetMode != NM_DedicatedServer)
        SmokeTrail = Spawn(class'UT3HellfireSPMAShellTrail', self);
}


/*simulated function Tick(float DeltaTime)
{
    local float t, h;

    Super.Tick(DeltaTime);

    // flight correction hack
    if (t0 == 0) {
        t0 = Level.TimeSeconds;
        v0 = Velocity.Z;
        h0 = Location.Z;
        g0 = PhysicsVolume.Gravity.Z;
    }
    if (g0 != PhysicsVolume.Gravity.Z || PhysicsVolume.bWaterVolume) {
        // no longer correct trajectory after gravity/water change
        g0 = 0;
        return;
    }
    t = Level.TimeSeconds - t0;

    h = h0 + v0 * t + 0.5 * g0 * Square(t);
    if (h > Location.Z /*|| h < Location.Z - 50*/) {
        log ("Correcting:"@t@h@Location.Z);
        Velocity.Z += (h - Location.Z);
    }
}*/


simulated function Destroyed()
{
    if (SmokeTrail != None)
        SmokeTrail.Kill();
    SmokeTrail = None;
    Super.Destroyed();
}

simulated function Timer()
{
    local int i, j;
    local Projectile Child;
    local float Mag;
    local vector CurrentVelocity;

    if (Level.NetMode != NM_DedicatedServer)
        Spawn(class'ONSArtilleryShellSplit', self, , Location, Rotation);

    CurrentVelocity = 0.85 * Velocity;

    // one shell in each of 9 zones
    for (i = -1; i < 2; i++) {
        for (j= -1; j < 2; j++) {
            if (Abs(i) + Abs(j) > 1)
                Mag = 0.7;
            else
                Mag = 1.0;
            Child = Spawn(ChildProjectileClass, self,, Location);
            if (Child != None) {
                Child.Velocity = CurrentVelocity;
                Child.Velocity.X += RandRange(0.3, 1.0) * Mag * i * SpreadFactor;
                Child.Velocity.Y += RandRange(0.3, 1.0) * Mag * j * SpreadFactor;
                Child.Velocity.Z = Child.Velocity.Z + SpreadFactor * (FRand() - 0.5);
                Child.InstigatorController = InstigatorController;
            }
        }
    }
    ExplodeInAir();
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
    PlaySound(AirExplosionSound, SLOT_None, 2.0);
    if (Level.NetMode != NM_DedicatedServer)
        Spawn(AirExplosionEffectClass);

    Explode(Location, vect(0,0,0));
    Destroy();
}



//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
    AirExplosionSound = Sound'UT3A_Vehicle_SPMA.UT3SPMAShellBrakingExplode.UT3SPMAShellBrakingExplodeCue'
    ImpactSound       = Sound'UT3A_Vehicle_SPMA.UT3SPMAShellFragmentExplode.UT3SPMAShellFragmentExplodeCue'
    AmbientSound      = None
    LifeSpan          = 8.0

    TransientSoundRadius = 500.0

    ChildProjectileClass = class'UT3HellfireSPMAShellChild'
    SpreadFactor = 400.0

    ExplosionEffectClass    = class'UT3HellfireSPMAAirExplosion'
    AirExplosionEffectClass = class'UT3HellfireSPMAAirExplosion'
}
