//============================================================
// UT3 Viper's Weapon
// Credits: 100GPing100(José Luís)
// Copytight José Luís, 2012
// Contact: zeluis.100@gmail.com
//============================================================
class Weap_ViperGun extends ONSWeapon;

#exec audio import group=Sounds file=..\Sounds\UT3Viper\Fire.wav
#exec audio import group=Sounds file=..\Sounds\UT3Viper\Rotate01.wav

DefaultProperties
{
	// Looks && Classes.
	Mesh=Mesh'ONSWeapons-A.PlasmaGun';
	ProjectileClass=Class'UT3Viper.Proj_ViperBolt';
	
	// Sound.
	FireSoundClass=Sound'UT3Viper.Sounds.Fire';
	RotateSound=Sound'UT3Viper.Sounds.Rotate01';
	AmbientSoundScaling=0.5;
	
	// Aim
	FireInterval=0.2;
	PitchDownLimit=57000; // 60000
	YawBone=Rt_Front_TopFin;
	PitchBone=Rt_Front_TopFin;
	WeaponFireAttachmentBone=Rt_ShieldArm3_Damage;
	
	// AI.
	AIInfo(0)=ONSWeaponAIInfo(bTrySplash=false, bLeadTarget=true, bInstantHit=false, AimError=750.0);
	
	// ForceFeedback.
	FireForce="HoverBikeFire";
}
