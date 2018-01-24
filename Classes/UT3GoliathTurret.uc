//-----------------------------------------------------------
// UT3GoliathTurret.uc
// I don't think the sounds will initially work...
// Copyright © 2008, 2014, 2017 GreatEmerald
// Copyright © 2012, 2017 Luís 'zeluisping' Guimarães <zeluis.100@gmail.com> (visuals + fixed sounds)
// Copyright © 2017 HellDragon 2017
//------------------------------------------------------
class UT3GoliathTurret extends ONSTankSecondaryTurret;

DefaultProperties
{

    Drawscale = 1.0

    //===============
    // @100GPing100
    Mesh = SkeletalMesh'UT3GoliathAnims.GoliathMachineGun';
    RedSkin = Shader'UT3GoliathTex.Goliath.GoliathSkin';
    BlueSkin = Shader'UT3GoliathTex.Goliath.GoliathSkinBlue';

    YawBone = "Object10";
    PitchBone = "Object03";
    WeaponFireAttachmentBone = "Object02";

    FireSoundClass = Sound'UT3A_Vehicle_Goliath.Singles.A_Vehicle_Goliath_TurretFire03';
    // @100GPing100
    //======END======

    PitchUpLimit=11000
    WeaponFireOffset=30.0 //85.0
    DualFireOffset=0.0
    DamageType=class'UT3DmgType_GoliathMachineGun'
    Spread=0.05  //0.03
    DamageMin=16 //18
    DamageMax=16 //18
    AIInfo(0)=(bInstantHit=true,AimError=600)
}
