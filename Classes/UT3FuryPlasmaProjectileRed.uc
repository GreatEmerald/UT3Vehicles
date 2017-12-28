//-----------------------------------------------------------
//
//-----------------------------------------------------------
class UT3FuryPlasmaProjectileRed extends ONSPlasmaProjectile;

defaultproperties
{
     HitEffectClass=Class'Onslaught.ONSPlasmaHitRed'
     PlasmaEffectClass=Class'Onslaught.ONSRedPlasmaFireEffect'
    AccelerationMagnitude=20000.0
    Speed=2000
    MaxSpeed=12500.000000
    Damage=20.000000
    DamageRadius=200.000000
    MomentumTransfer=4000
    LifeSpan=1.6
    MyDamageType=Class'UT3DmgType_FuryPlasma'
}
