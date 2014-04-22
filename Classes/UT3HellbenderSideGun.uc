//==============================================================================
// UT3HellbenderSideGun.uc
// This is so fun!
// 2008, GreatEmerald
//==============================================================================

class UT3HellbenderSideGun extends ONSPRVSideGun;

defaultproperties
{
    FireSoundClass=sound'UT3Vehicles.HELLBENDER.HellbenderFire'
    AltFireSoundClass=sound'UT3Vehicles.HELLBENDER.HellbenderAltFire'
    ProjectileClass=class'UT3HBShockBall'
}
