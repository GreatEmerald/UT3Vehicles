//-----------------------------------------------------------
// UT3ScorpionBallProj2R.uc
// A very nice emitter effect for the ball.
// 2009, GreatEmerald
//-----------------------------------------------------------
class UT3ScorpionBallProj2R extends Emitter;

DefaultProperties
{
   bNoDelete=false
   bBlockActors=False
   RemoteRole=ROLE_None
   Physics=PHYS_None
   bHardAttach=True

    Begin Object Class=MeshEmitter Name=MeshEmitter1
        StaticMesh=StaticMesh'XGame_rc.BombEffectMesh'
        SpinParticles=True
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        MaxParticles=1
        Name="MeshEmitter1"
        UseRotationFrom=PTRS_Offset
        SpinsPerSecondRange=(Y=(Min=1.000000,Max=1.000000),Z=(Min=1.000000,Max=1.000000))
        SpinCCWorCW=(Y=0.000000,Z=0.0)
        //RotationNormal=(X=1.000000)
        LifetimeRange=(Min=99,Max=99)
        FadeIn=True
        FadeInEndTime=0.5
        CoordinateSystem=PTCS_Relative
        WarmupTicksPerSecond=1
        RelativeWarmupTime=99
    End Object
    Emitters(0)=MeshEmitter'MeshEmitter1'

    Skins(0)=Shader'XGameShaders.BRShaders.BombIconRS'
}
