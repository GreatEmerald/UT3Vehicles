//-----------------------------------------------------------
// UT3CicadaTurret.uc
// Last change: Alpha 2
// 2009, GreatEmerald
//-----------------------------------------------------------
class UT3CicadaTurret extends ONSDualACGatlingGun;

DefaultProperties
{
     BeamEffectClass(0)=Class'UT3CicadaTurretFire'
     BeamEffectClass(1)=Class'UT3CicadaTurretFire'

     FireSoundClass=sound'UT3Vehicles.Cicada.Cicada_TurretFire'
     FireSoundVolume=3.000000 //GE: Again it's a FLOAT!!
     //FireForce=""
}
