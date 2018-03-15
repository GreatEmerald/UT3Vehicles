//============================================================
// UT3 Fury
// Credits: 100GPing100(José Luís)
// Copytight José Luís, 2012
// Contact: zeluis.100@gmail.com
//============================================================
class UT3Fury extends ONSAttackCraft;

#exec obj load file=..\Textures\UT3FuryTex.utx
#exec obj load file=..\Animations\UT3FuryAnims.ukx


/*  */
var string CurrentAnim;


function Tick(float DeltaTime)
{
	Animate();
	
	Super.Tick(DeltaTime);
}
function Animate()
{
	/*
	AimDn
	AimLt
	AimRt
	AimUp
	Boost
	Compress
	DodgeLt
	DodgeRt
	Idle
	Idle_Boost
	Idle_Compressed
	Land
	Skewer_RipApart
	TakeOff
	UnCompress
	*/
	if (CurrentAnim != "Idle" && !IsAnimating())
	{
		LoopAnim('Idle', 1, 0.2);
		CurrentAnim = "Idle";
	}
}
simulated event DrivingStatusChanged()
{
	if (Driver == None)
	{
		PlayAnim('Land', 1, 0.2);
		CurrentAnim = "Land";
	}
	else if (Driver != None)
	{
		PlayAnim('TakeOff', 1, 0.1);
		CurrentAnim = "TakeOff";
	}
	
	Super.DrivingStatusChanged();
}

/* Bones
	UpRt_Arm08
	UpLt_Arm08
	LwRt_Arm08
	LwLt_Arm08
	RightCannon
	LeftCannon
*/
DefaultProperties
{

    Drawscale = 1.0

    // Strings.
    VehiclePositionString="in a UT3 Fury";
    VehicleNameString="UT3 Fury";
    
    IdleSound = Sound'UT3A_Vehicle_Fury.UT3FurySingles.UT3FuryEngineLoop01'; //Loop is not modulated
    StartUpSound = Sound'UT3A_Vehicle_Fury.UT3FuryEngineStart.UT3FuryEngineStartCue';
    ShutDownSound = Sound'UT3A_Vehicle_Fury.UT3FuryEngineStop.UT3FuryEngineStopCue';
    ExplosionSounds=()
    ExplosionSounds(0) = Sound'UT3A_Vehicle_Cicada.UT3CicadaExplode.UT3CicadaExplodeCue';
    ImpactDamageSounds=()
    ImpactDamageSounds(0) = Sound'UT3A_Vehicle_Fury.UT3FuryCollide.UT3FuryCollideCue';
    BulletSounds = ()
    BulletSounds(0) = Sound'UT3A_Weapon_BulletImpacts.UT3BulletImpactMetal.UT3BulletImpactMetalCue'
    SoundVolume=255
    
    ImpactDamageMult = 0.00003
    
    // Looks.
    Mesh=SkeletalMesh'UT3FuryAnims.UT3Fury';
    RedSkin=Shader'UT3FuryTex.Fury.FurySkin';
    BlueSkin=Shader'UT3FuryTex.Fury.FurySkinBlue';
	
    // Damage.
    DriverWeapons(0)=(WeaponClass=Class'Onslaught.ONSAttackCraftGun',WeaponBone="UpRt_Arm08")
	
    // Misc
    EntryPosition=(X=0,Y=0,Z=20);
    EntryRadius=250.0;

}
