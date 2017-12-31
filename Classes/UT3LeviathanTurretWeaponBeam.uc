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

class UT3LeviathanTurretWeaponBeam extends UT3LeviathanTurretWeapon;

#exec obj load file=ONSWeapons-A.ukx
#exec obj load file=TurretParticles.utx

var class<ONSTurretBeamEffect> BeamEffectClass[2];

static function StaticPrecache(LevelInfo L)
{
    L.AddPrecacheMaterial(Material'TurretParticles.Beams.TurretBeam5');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaMuzzleBlue');
    L.AddPrecacheMaterial(Material'EpicParticles.Flares.SoftFlare');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaStar2');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.SmokePanels1');
    L.AddPrecacheMaterial(Material'XEffectMat.shock_flare_a');
    L.AddPrecacheMaterial(Material'XEffectMat.Shock_ring_b');
    L.AddPrecacheMaterial(Material'XEffectMat.Shock.shock_mark_heat');
    L.AddPrecacheMaterial(Material'XEffectMat.shock_core');
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'TurretParticles.Beams.TurretBeam5');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaMuzzleBlue');
    Level.AddPrecacheMaterial(Material'EpicParticles.Flares.SoftFlare');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaStar2');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.SmokePanels1');
    Level.AddPrecacheMaterial(Material'XEffectMat.shock_flare_a');
    Level.AddPrecacheMaterial(Material'XEffectMat.Shock_ring_b');
    Level.AddPrecacheMaterial(Material'XEffectMat.Shock.shock_mark_heat');
    Level.AddPrecacheMaterial(Material'XEffectMat.shock_core');

    Super.UpdatePrecacheMaterials();
}


function TraceFire(Vector Start, Rotator Dir)
{
    local Vector X, End, HitLocation, HitNormal;
    local Actor Other;
    local int Damage;

    X = Vector(Dir);
    End = Start + TraceRange * X;

    //skip past vehicle driver
    if (ONSVehicle(Instigator) != None && ONSVehicle(Instigator).Driver != None) {
        ONSVehicle(Instigator).Driver.bBlockZeroExtentTraces = False;
        Other = Trace(HitLocation, HitNormal, End, Start, True);
        ONSVehicle(Instigator).Driver.bBlockZeroExtentTraces = true;
    }
    else
        Other = Trace(HitLocation, HitNormal, End, Start, True);

    if (Other != None) {
        if (!Other.bWorldGeometry) {
            Damage = (DamageMin + Rand(DamageMax - DamageMin));
            Other.TakeDamage(Damage, Instigator, HitLocation, Momentum * X, DamageType);
            HitNormal = vect(0,0,0);
        }
    }
    else {
        HitLocation = End;
        HitNormal = Vect(0,0,0);
    }

    HitCount++;
    LastHitLocation = HitLocation;
    SpawnHitEffects(Other, HitLocation, HitNormal);
}

state InstantFireMode
{
    simulated function SpawnHitEffects(actor HitActor, vector HitLocation, vector HitNormal)
    {
        local ONSTurretBeamEffect Beam;

        if (Level.NetMode != NM_DedicatedServer) {
            if (Role < ROLE_Authority) {
                CalcWeaponFire();
                DualFireOffset *= -1;
            }

            Beam = Spawn(BeamEffectClass[Team],,, WeaponFireLocation, rotator(HitLocation - WeaponFireLocation));
            BeamEmitter(Beam.Emitters[0]).BeamDistanceRange.Min = VSize(WeaponFireLocation - HitLocation);
            BeamEmitter(Beam.Emitters[0]).BeamDistanceRange.Max = VSize(WeaponFireLocation - HitLocation);
            BeamEmitter(Beam.Emitters[1]).BeamDistanceRange.Min = VSize(WeaponFireLocation - HitLocation);
            BeamEmitter(Beam.Emitters[1]).BeamDistanceRange.Max = VSize(WeaponFireLocation - HitLocation);
            Beam.SpawnEffects(HitLocation, HitNormal);
        }
    }
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
    bInstantFire = True
    DamageMin    = 35
    DamageMax    = 35
    Spread(0)    = 0
    Momentum     = 60000.0
    DamageType   = class'UT3DmgType_LeviathanBeam'
    FireInterval = 0.3
    AIInfo(0)=(bInstantHit=true,AimError=600)

    FireSoundClass = Sound'UT3Weapons.ShockRifle.ShockRiflePrimary'

    BeamEffectClass(0) = class'ONSTurretBeamEffect'
    BeamEffectClass(1) = class'ONSTurretBeamEffectBlue'

    Mesh = SkeletalMesh'UT3VH_Leviathan_Anims.Leviathan_LeftFrontTurret'
    RedSkin = Shader'UT3LeviathanTex.LeviTurret.TurretSkin'
    BlueSkin = Shader'UT3LeviathanTex.LeviTurret.TurretSkinBlue'
    SkinSlot = 3
    PitchBone = "LT_Front_TurretPitch"
    YawBone = "LT_Front_TurretYaw"
    WeaponFireAttachmentBone = "Lt_Front_Turret_Barrel"
    GunnerAttachmentBone = "LT_Front_TurretPitch"
    ShieldAttachmentBone = "Lt_Front_Turret_Barrel"
    DualFireOffset = 11 //14.0
}
