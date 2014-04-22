//-----------------------------------------------------------
// UT3ScorpionBallProjR.uc
// A very nice emitter effect for the ball.
// 2009, GreatEmerald
//-----------------------------------------------------------
class UT3ScorpionBallProjR extends Emitter;

DefaultProperties
{
   bNoDelete=false
   bBlockActors=False
   RemoteRole=ROLE_None
   Physics=PHYS_None
   bHardAttach=True

    Begin Object Class=MeshEmitter Name=MeshEmitter0
        StaticMesh=StaticMesh'WarEffectsMeshes.N_ball_M_jm'
        FadeIn=True
        UseRegularSizeScale=False
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        FadeInEndTime=0.5
        MaxParticles=1
        Name="CenterBall"
        //SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=99,Max=99)
        StartSizeRange=(X=(Min=0.6,Max=0.6),Y=(Min=0.6,Max=0.6),Z=(Min=0.6,Max=0.6))
        CoordinateSystem=PTCS_Relative
        WarmupTicksPerSecond=1
        RelativeWarmupTime=99
    End Object
    Emitters(0)=MeshEmitter'MeshEmitter0'

    Skins(0)=Shader'XGameShadersB.TransB.TransRingRed'
}
