//-----------------------------------------------------------
//
//-----------------------------------------------------------
class UT3PaladinShieldHitEffectRed extends ONSShockTankShieldHitEffectRed;

#exec OBJ LOAD FILE="..\Textures\AW-2004Particles.utx"
#exec OBJ LOAD FILE="..\Textures\AW-2k4XP.utx"
#exec obj load file=..\StaticMeshes\UT3PaladinSM.usx

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter2
         StaticMesh = StaticMesh'UT3PaladinSM.PaladinShield';
         UseParticleColor=True
         UseColorScale=True
         RespawnDeadParticles=False
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=70,G=70,R=255))
         ColorScale(1)=(RelativeTime=1.000000)
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         StartSizeRange=(X=(Min=2.200000,Max=2.200000),Y=(Min=2.2000000,Max=2.2000000),Z=(Min=2.200000,Max=2.200000))
         InitialParticlesPerSecond=5000.000000
         LifetimeRange=(Min=0.200000,Max=0.200000)
     End Object
     Emitters(0) = MeshEmitter2;

     AutoDestroy=True
     bNoDelete=False
     AmbientGlow=254
     PrePivot=(X=-100,Y=30.0,Z=-20)
}
