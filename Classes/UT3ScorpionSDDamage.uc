//-----------------------------------------------------------
// UT3ScorpionSDDamage.uc
// Scorpion Self Destruct damage type
// 2009, GreatEmerald
//-----------------------------------------------------------
class UT3ScorpionSDDamage extends VehicleDamageType
  abstract;

DefaultProperties
{
    DeathString="%o was too close to %k's Scorpion self destruct."
    MaleSuicide="%o fried himself with his own Scorpion self destruct."
    FemaleSuicide="%o fried herself with her own Scorpion self destruct."
    FlashFog=(X=700.00000,Y=0.000000,Z=0.00000)
    bDetonatesGoop=true
    bDelayedDamage=true
    VehicleClass=class'UT3Scorpion'
    KDamageImpulse=12000.000000
}
