//-----------------------------------------------------------
//
//-----------------------------------------------------------
class UT3LeviathanShieldHitEffectBlue extends Emitter;

#exec OBJ LOAD FILE="..\Textures\AW-2004Particles.utx"
#exec OBJ LOAD FILE="..\Textures\AW-2k4XP.utx"

DefaultProperties
{
    Begin Object Class=MeshEmitter Name=MeshEmitter2
        StaticMesh=StaticMesh'UT3PaladinSM.PaladinShield' //'AW-2k4XP.Weapons.ShockShield2'
        UseParticleColor=True
        UseColorScale=True
        RespawnDeadParticles=False
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=255,G=80,R=80))
        ColorScale(1)=(RelativeTime=1.0)
        CoordinateSystem=PTCS_Relative
        MaxParticles=1
        UniformSize=false
        //StartSizeRange=(X=(Min=0.7,Max=0.7),Y=(Min=1.4,Max=1.4),Z=(Min=1.6,Max=1.6))
        StartSizeRange=(X=(Min=1.0,Max=1.0),Y=(Min=1.0,Max=1.0),Z=(Min=1.0,Max=1.0))
        InitialParticlesPerSecond=5000.0
        LifetimeRange=(Min=0.2,Max=0.2)
    End Object
    Emitters(0)=MeshEmitter'MeshEmitter2'

    bNoDelete=False
    AutoDestroy=True
    AmbientGlow=254
    PrePivot=(X=20,Y=0.0,Z=-30)
}
