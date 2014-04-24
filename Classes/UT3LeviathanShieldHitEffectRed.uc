//-----------------------------------------------------------
//
//-----------------------------------------------------------
class UT3LeviathanShieldHitEffectRed extends Emitter;

#exec OBJ LOAD FILE="..\Textures\AW-2004Particles.utx"
#exec OBJ LOAD FILE="..\Textures\AW-2k4XP.utx"

DefaultProperties
{
    Begin Object Class=MeshEmitter Name=MeshEmitter2
        StaticMesh=StaticMesh'AW-2k4XP.Weapons.ShockShield'
        UseParticleColor=True
        UseColorScale=True
        RespawnDeadParticles=False
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=70,G=70,R=255))
        ColorScale(1)=(RelativeTime=1.0)
        CoordinateSystem=PTCS_Relative
        MaxParticles=1
        UniformSize=false
        StartSizeRange=(X=(Min=0.6,Max=0.6),Y=(Min=0.75,Max=0.75),Z=(Min=1.0,Max=1.0))
        InitialParticlesPerSecond=5000.0
        LifetimeRange=(Min=0.2,Max=0.2)
    End Object
    Emitters(0)=MeshEmitter'MeshEmitter2'

    bNoDelete=False
    AutoDestroy=True
    AmbientGlow=254
}
