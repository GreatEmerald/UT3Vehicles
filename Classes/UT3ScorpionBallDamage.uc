//-----------------------------------------------------------
// UT3ScorpionBallDamage.uc
// Scorpion Plasma Ball damage type
// 2009, GreatEmerald
//-----------------------------------------------------------
class UT3ScorpionBallDamage extends VehicleDamageType
  abstract;

DefaultProperties
{
    DeathString="%k's Scorpion blasted %o into oblivion."
    MaleSuicide="%o blasted himself."
    FemaleSuicide="%o blasted herself."
    FlashFog=(X=700.00000,Y=0.000000,Z=0.00000)
    bDetonatesGoop=true
    bDelayedDamage=true
    VehicleClass=class'UT3Scorpion'
    VehicleDamageScaling=0.750000
}
