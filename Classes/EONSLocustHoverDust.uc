class EONSLocustHoverDust extends ONSHoverBikeHoverDust;

#exec OBJ LOAD FILE=..\Textures\AW-2004Particles.utx

defaultproperties
{
    bNoDelete=false
    bBlockActors=False
    RemoteRole=ROLE_None
    Physics=PHYS_None
    bHardAttach=True
    CullDistance=8000.0

    Begin Object Class=SpriteEmitter Name=SpriteEmitter0
        UseColorScale=True
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        BlendBetweenSubdivisions=True
        UseRandomSubdivision=True
        UseVelocityScale=True
        Acceleration=(Z=500.000000)
        ColorScale(0)=(Color=(B=96,G=128,R=164))
        ColorScale(1)=(RelativeTime=0.200000,Color=(B=96,G=128,R=164,A=255))
        ColorScale(2)=(RelativeTime=0.500000,Color=(B=64,G=100,R=128,A=255))
        ColorScale(3)=(RelativeTime=1.000000,Color=(B=68,G=104,R=125))
        FadeOutStartTime=0.500000
        FadeInEndTime=0.350000
        MaxParticles=50
        StartLocationShape=PTLS_Polar
        StartLocationPolarRange=(X=(Min=16384.000000,Max=16384.000000),Y=(Max=65536.000000),Z=(Min=20.000000,Max=20.000000))
        UseRotationFrom=PTRS_Actor
        SizeScale(0)=(RelativeSize=0.300000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.600000)
        StartSizeRange=(X=(Min=50.000000,Max=90.000000),Y=(Min=0.000000,Max=0.000000),Z=(Min=0.000000,Max=0.000000))
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'AW-2004Particles.Weapons.SmokePanels2'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        LifetimeRange=(Min=0.500000,Max=0.800000)
        StartVelocityRange=(X=(Min=70.000000,Max=70.000000))
        StartVelocityRadialRange=(Min=-600.000000,Max=-800.000000)
        GetVelocityDirectionFrom=PTVD_AddRadial
        VelocityScale(0)=(RelativeVelocity=(X=1.000000,Y=1.000000,Z=1.000000))
        VelocityScale(1)=(RelativeTime=0.200000,RelativeVelocity=(X=0.350000,Y=0.350000,Z=0.350000))
        VelocityScale(2)=(RelativeTime=0.500000,RelativeVelocity=(X=0.100000,Y=0.100000,Z=0.100000))
        VelocityScale(3)=(RelativeTime=1.000000)
        RespawnDeadParticles=False
        AutomaticInitialSpawning=False
        ParticlesPerSecond=50
        InitialParticlesPerSecond=50
        Name="SpriteEmitter0"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter0'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter1
        UseDirectionAs=PTDU_Normal
        ProjectionNormal=(X=1.000000,Z=0.000000)
        UseColorScale=True
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        ColorScale(1)=(RelativeTime=0.450000,Color=(B=128,G=128,R=128))
        ColorScale(2)=(RelativeTime=0.550000,Color=(B=128,G=128,R=128))
        ColorScale(3)=(RelativeTime=1.000000)
        Opacity=0.2500000
        StartLocationOffset=(Z=6.000000)
        CoordinateSystem=PTCS_Relative
        MaxParticles=3
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=0.500000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.500000)
        StartSizeRange=(X=(Min=25.000000,Max=30.000000))
        Texture=Texture'AW-2004Particles.SmallBang'
        LifetimeRange=(Min=0.300000,Max=0.300000)
        AutomaticInitialSpawning=true
        Name="SpriteEmitter1"
    End Object
    Emitters(1)=SpriteEmitter'SpriteEmitter1'
}
