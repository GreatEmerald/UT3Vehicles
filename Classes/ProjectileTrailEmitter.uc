/******************************************************************************
ProjectileTrailEmitter

Creation date: 2009-02-18 15:08
Latest change: $Id$
Copyright (c) 2009, Wormbo
******************************************************************************/

class ProjectileTrailEmitter extends Emitter notplaceable;


//=============================================================================
// Properties
//=============================================================================

struct TVelocitySpawnInfo {
var int EmitterIndex;
var float ParticlesPerUU;
var float _Remainder;
};

var() array<TVelocitySpawnInfo> VelocitySpawnInfo;

var float SpawnTime;


simulated function PostBeginPlay()
{
SpawnTime = Level.TimeSeconds;
SetBase(Owner);
}


simulated function Tick(float DeltaTime)
{
local int i;
local float LocDiff, NumParticles;

if (VelocitySpawnInfo.Length > 0 && OldLocation != Location) {
LocDiff = VSize(Location - OldLocation);
do {
if (Level.TimeSeconds - SpawnTime > Emitters[VelocitySpawnInfo[i].EmitterIndex].InitialDelayRange.Min) {
NumParticles = VelocitySpawnInfo[i]._Remainder + LocDiff * VelocitySpawnInfo[i].ParticlesPerUU;
VelocitySpawnInfo[i]._Remainder = NumParticles - int(NumParticles);
Emitters[VelocitySpawnInfo[i].EmitterIndex].SpawnParticle(int(NumParticles));
}
} until (++i == VelocitySpawnInfo.Length);
}
}

simulated function Kill()
{
// prevent spawning additional
VelocitySpawnInfo.Length = 0;
Super.Kill();
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
bNoDelete = False
bHardAttach = True
}
