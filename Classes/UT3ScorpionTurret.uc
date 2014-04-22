//-----------------------------------------------------------
// UT3ScorpionTurret.uc
// A great elecroball launcher.
// 2009, GreatEmerald
// Copyright (c) 2012, 100GPing100
//-----------------------------------------------------------
class UT3ScorpionTurret extends EONSScorpionProjectileLauncher;

simulated function float MaxRange() //GE: Makes bots look further
{
    AimTraceRange = 7000;

    return AimTraceRange;
}

DefaultProperties
{
	//=======================
	// @100GPing100
	Mesh = SkeletalMesh'UT3ScorpionAnims.Scorpion_Turret';
	RedSkin = Shader'UT3ScorpionTex.ScorpionSkin';
	BlueSkin = Shader'UT3ScorpionTex.ScorpionSkinBlue';
	
	YawBone = "gun_rotate";
	PitchBone = "gun_rotate";
	WeaponFireAttachmentBone = "gun_rotate";
	// @100GPing100
	//==========END==========

   ProjectileClass=Class'UT3ScorpionBallRed'
   TeamProjectileClasses(0)=class'UT3ScorpionBallRed'
   TeamProjectileClasses(1)=class'UT3ScorpionBallBlue'
   FireSoundClass=Sound'UT3Vehicles.SCORPION.ScorpionFire'
   AIInfo(0)=(aimerror=650.000000,bTrySplash=True,bLeadTarget=True)
}
