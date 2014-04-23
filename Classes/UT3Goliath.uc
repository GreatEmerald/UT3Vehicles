/******************************************************************************
UT3Goliath

Creation date: 2008-05-02 20:50
Last change: $Id$
Copyright (c) 2008, Wormbo
Copyright (c) 2012, 100GPing100 (visuals + fixed sounds)
Copyright (c) 2014, GreatEmerald
******************************************************************************/

class UT3Goliath extends ONSHoverTank;


//=====================
// @100GPing100
#exec obj load file=../Animations/UT3GoliathAnims.ukx
#exec obj load file=../Textures/UT3GoliathTex.utx


simulated function SetupTreads()
{
	LeftTreadPanner = VariableTexPanner(Level.ObjectPool.AllocateObject(class'VariableTexPanner'));
	if ( LeftTreadPanner != None )
	{
		LeftTreadPanner.Material = Skins[1];
		//LeftTreadPanner.PanDirection = rot(0, 16384, 0);
		LeftTreadPanner.PanDirection = rot(0,-16384,0);
		LeftTreadPanner.PanRate = 0.0;
		Skins[1] = LeftTreadPanner;
	}
	RightTreadPanner = VariableTexPanner(Level.ObjectPool.AllocateObject(class'VariableTexPanner'));
	if ( RightTreadPanner != None )
	{
		RightTreadPanner.Material = Skins[2];
		//RightTreadPanner.PanDirection = rot(0, 16384, 0);
		RightTreadPanner.PanDirection = rot(0,-16384,0);
		RightTreadPanner.PanRate = 0.0;
		Skins[2] = RightTreadPanner;
	}
	//local a;
}
// @100GPing100
//=========END=========



//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
	//===============
	// @100GPing100
	Mesh = SkeletalMesh'UT3GoliathAnims.Goliath';
	RedSkin = Shader'UT3GoliathTex.Goliath.GoliathSkin';
	BlueSkin = Shader'UT3GoliathTex.Goliath.GoliathSkinBlue';

	Skins(1) = Shader'UT3GoliathTex.GoliathWheels.GoliathWheelsSkin';
	Skins(2) = Shader'UT3GoliathTex.GoliathWheels.GoliathWheelsSkin';

	DriverWeapons(0)=(WeaponClass=class'UT3GoliathCannon',WeaponBone=Chassis)
	PassengerWeapons(0)=(WeaponPawnClass=class'UT3GoliathTurretPawn',WeaponBone=Object10)

	IdleSound = Sound'UT3A_Vehicle_Goliath.Sounds.A_Vehicle_Goliath_EngineLoop01';
	StartUpSound = Sound'UT3A_Vehicle_Goliath.Sounds.A_Vehicle_Goliath_Start01';
	ShutDownSound = Sound'UT3A_Vehicle_Goliath.Sounds.A_Vehicle_Goliath_Stop01';

	ImpactDamageSounds(0) = Sound'UT3A_Vehicle_Goliath.Sounds.A_Vehicle_Goliath_Collide01';
	ImpactDamageSounds(1) = Sound'UT3A_Vehicle_Goliath.Sounds.A_Vehicle_Goliath_Collide01';
	ImpactDamageSounds(2) = Sound'UT3A_Vehicle_Goliath.Sounds.A_Vehicle_Goliath_Collide01';
	ImpactDamageSounds(3) = Sound'UT3A_Vehicle_Goliath.Sounds.A_Vehicle_Goliath_Collide01';
	ImpactDamageSounds(4) = Sound'UT3A_Vehicle_Goliath.Sounds.A_Vehicle_Goliath_Collide01';
	ImpactDamageSounds(5) = Sound'UT3A_Vehicle_Goliath.Sounds.A_Vehicle_Goliath_Collide01';
	ImpactDamageSounds(6) = Sound'UT3A_Vehicle_Goliath.Sounds.A_Vehicle_Goliath_Collide01';
	ExplosionSounds(0) = Sound'UT3A_Vehicle_Goliath.Sounds.A_Vehicle_Goliath_Explode01';
	ExplosionSounds(1) = Sound'UT3A_Vehicle_Goliath.Sounds.A_Vehicle_Goliath_Explode01';
	ExplosionSounds(2) = Sound'UT3A_Vehicle_Goliath.Sounds.A_Vehicle_Goliath_Explode01';
	ExplosionSounds(3) = Sound'UT3A_Vehicle_Goliath.Sounds.A_Vehicle_Goliath_Explode01';
	ExplosionSounds(4) = Sound'UT3A_Vehicle_Goliath.Sounds.A_Vehicle_Goliath_Explode01';

	TreadVelocityScale = 146.25; // Based on the new MaxThrust value: (65/200)*450
	// @100GPing100
	//======END======


	VehicleNameString = "UT3 Goliath"
	MaxGroundSpeed=600.0
	GroundSpeed=500
	SoundVolume=255
	MaxThrust=200.000000//GE: was 65, maybe the tank is too fast now?
}
