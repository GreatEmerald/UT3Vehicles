class EONSLocustThrusterEffectRed extends Emitter;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter0
        UseColorScale=True
        FadeOut=True
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        ColorScale(0)=(Color=(B=96,G=160,R=255))
        ColorScale(1)=(RelativeTime=0.500000,Color=(B=48,G=128,R=255))
        ColorScale(2)=(RelativeTime=0.900000,Color=(B=48,G=128,R=255))
        ColorScale(3)=(RelativeTime=1.000000)
        CoordinateSystem=PTCS_Relative
        MaxParticles=12
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=0.150000,RelativeSize=4.000000)
        SizeScale(2)=(RelativeTime=0.500000,RelativeSize=2.500000)
        SizeScale(3)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=1.250000,Max=2.500000))                  //0.625, 1.25
        InitialParticlesPerSecond=2000.000000
        Texture=Texture'EpicParticles.Flares.FlashFlare1'
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=0.500000,Max=0.500000)
        StartVelocityRange=(X=(Min=-47.000000,Max=-47.000000))          //23.5
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter0'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter1
        UseColorScale=True
        SpinParticles=True
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorScale(1)=(RelativeTime=0.330000,Color=(B=64,G=112,R=220,A=255))
        ColorScale(2)=(RelativeTime=0.660000,Color=(B=64,G=112,R=220,A=255))
        ColorScale(3)=(RelativeTime=1.000000)
        Opacity=0.660000
        CoordinateSystem=PTCS_Relative
        MaxParticles=1
        SpinCCWorCW=(X=0.000000,Y=0.000000,Z=0.000000)
        SpinsPerSecondRange=(X=(Min=0.050000,Max=0.050000))
        StartSpinRange=(X=(Max=1.000000))
        StartSizeRange=(X=(Min=9.000000,Max=16.000000))                 //4.5, 8
        InitialParticlesPerSecond=10.000000
        DrawStyle=PTDS_Brighten
        Texture=Texture'AS_FX_TX.Flares.Laser_Flare'
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=1.000000,Max=2.000000)
    End Object
    Emitters(1)=SpriteEmitter'SpriteEmitter1'

    bNoDelete=false
    bHardAttach=true
    AutoDestroy=true
}