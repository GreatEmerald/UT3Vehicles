//-----------------------------------------------------------
//
//-----------------------------------------------------------
class UT3LeviathanShieldEffectBlue extends Emitter;

#exec OBJ LOAD FILE="..\Textures\AW-2004Particles.utx"
#exec OBJ LOAD FILE="..\Textures\AW-2k4XP.utx"

DefaultProperties
{
    Begin Object Class=MeshEmitter Name=MeshEmitter18
        StaticMesh=StaticMesh'AW-2k4XP.Weapons.ShockShield2'
        UseParticleColor=True
        UseColorScale=True
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=255,G=64,R=64))
        ColorScale(1)=(RelativeTime=1.0,Color=(B=255,G=64,R=64))
        CoordinateSystem=PTCS_Relative
        MaxParticles=1
        UniformSize=false
        StartSizeRange=(X=(Min=0.6,Max=0.6),Y=(Min=0.75,Max=0.75),Z=(Min=1.0,Max=1.0))
        InitialParticlesPerSecond=5000.0
        LifetimeRange=(Min=0.1,Max=0.1)
    End Object
    Emitters(0)=MeshEmitter'MeshEmitter18'

    bNoDelete=false
    AmbientGlow=254
    bHardAttach=true
}
