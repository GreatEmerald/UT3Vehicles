/*-----------------------------------------------------------
* UT3GoliathProjectile.uc
* Yeap, it's here.
* Copyright © 2014 GreatEmerald
* Copyright © 2017 HellDragon
*-----------------------------------------------------------
*/
class UT3GoliathProjectile extends ONSRocketProjectile;

var(Sound) sound ExplosionSound;

simulated function Explode(vector HitLocation, vector HitNormal)
{
    PlaySound(ExplosionSound,,5.5*TransientSoundVolume);
    if ( EffectIsRelevant(Location,false) )
    {
        Spawn(class'ONSTankHitRockEffect',,,HitLocation + HitNormal*16, rotator(HitNormal) + rot(-16384,0,0));
        if ( (ExplosionDecal != None) && (Level.NetMode != NM_DedicatedServer) )
            Spawn(ExplosionDecal,self,,Location, rotator(-HitNormal));
    }

    BlowUp(HitLocation);
    Destroy();
}

DefaultProperties
{
   Damage=360.000000
   DamageRadius=630.000000
   MomentumTransfer=150000.000000
   MyDamageType=Class'UT3Vehicles.UT3DmgType_GoliathTankShell'
   AmbientSound=sound'UT3A_Weapon_RocketLauncher.UT3RocketSingles.UT3RocketTravel01'
   ExplosionSound=Sound'UT3A_Vehicle_Goliath.Explode.UT3GoliathExplodeCue'
}
