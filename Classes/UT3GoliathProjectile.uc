//-----------------------------------------------------------
// UT3GoliathProjectile.uc
// Yeap, it's here.
// GreatEmerald, 2008
// HellDragon (Just added the DmgType and changed Radius to UT3 value is all I've done here)
//-----------------------------------------------------------
class UT3GoliathProjectile extends ONSRocketProjectile;

DefaultProperties
{
   Damage=360.000000
   DamageRadius=600.000000
   MomentumTransfer=150000.000000
   MyDamageType=Class'UT3Vehicles.UT3DmgType_GoliathTankShell'
}
