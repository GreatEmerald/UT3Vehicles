class UT3PaladinShieldEffectBlue extends ONSShockTankShieldEffectBlue;

#exec obj load file=..\StaticMeshes\UT3PaladinSM.usx

DefaultProperties
{
	Begin Object Class=MeshEmitter Name=MeshEmitter18
		StaticMesh = StaticMesh'UT3PaladinSM.PaladinShield';
		UseParticleColor=True
		UseColorScale=True
		AutomaticInitialSpawning=False
		ColorScale(0)=(Color=(B=255,G=64,R=64))
		ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=64,R=64))
		CoordinateSystem=PTCS_Relative
		MaxParticles=1
		UniformSize=false
		//StartSizeRange=(X=(Min=2.000000,Max=2.000000),Y=(Min=3.000000,Max=3.000000),Z=(Min=3.000000,Max=3.000000))
                StartSizeRange=(X=(Min=3.000000,Max=3.000000),Y=(Min=1.500000,Max=1.500000),Z=(Min=2.000000,Max=2.000000))
		InitialParticlesPerSecond=5000.000000
		LifetimeRange=(Min=0.100000,Max=0.100000)
	End Object
	Emitters(0) = MeshEmitter18;
}
