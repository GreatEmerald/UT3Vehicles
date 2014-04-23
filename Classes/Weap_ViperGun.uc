//============================================================
// UT3 Viper's Weapon
// Credits: 100GPing100(José Luís)
// Copytight José Luís, 2012
// Copyright GreatEmerald, 2014
// Contact: zeluis.100@gmail.com
//============================================================
class Weap_ViperGun extends ONSWeapon;

DefaultProperties
{
	// Looks && Classes.
	Mesh=Mesh'ONSWeapons-A.PlasmaGun';
	ProjectileClass=Class'Proj_ViperBolt';

	// Sound.
	FireSoundClass=Sound'UT3A_Vehicle_Viper.Sounds.A_Vehicle_Viper_PrimaryFire';
	//RotateSound=Sound'UT3A_Vehicle_Viper.Sounds.Rotate01';
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
