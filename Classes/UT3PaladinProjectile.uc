//-----------------------------------------------------------
// UT3PaladinProjectile.uc
// This got a nice overhaul.
// Last change: Alpha 2
// By GreatEmerald, 2009
//-----------------------------------------------------------
class UT3PaladinProjectile extends ONSShockTankProjectile;

function SuperExplosion()
{
    local actor HitActor;
    local vector HitLocation, HitNormal;

    HurtRadius(ComboDamage, ComboRadius, class'UT3DmgType_PaladinShockBall', ComboMomentumTransfer, Location ); //different class here

    Spawn(class'ONSShockTankShockExplosion');
    if ( (Level.NetMode != NM_DedicatedServer) && EffectIsRelevant(Location,false) )
    {
    HitActor = Trace(HitLocation, HitNormal,Location - Vect(0,0,120), Location,false);
    if ( HitActor != None )
    Spawn(class'ComboDecal',self,,HitLocation, rotator(vect(0,0,-1)));
    }
    PlaySound(ComboSound, SLOT_None,1.0,,800);
    DestroyTrails();
    Destroy();
}

DefaultProperties
{
    Damage=200.000000             //GE: Everything increased!!
    DamageRadius=450.000000
    MomentumTransfer=200000.000000
    ComboSound=sound'UT3A_Vehicle_Paladin.Sounds.A_Vehicle_Paladin_ComboExplosion01'
}
