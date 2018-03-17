//-----------------------------------------------------------
// UT3RaptorRocket.uc
// The (homing) rocket of the UT3 Raptor
// Last Change: Alpha 2
// GreatEmerald, 2009
//-----------------------------------------------------------
class UT3RaptorRocket extends ONSAttackCraftMissle;

var(Sound) sound ExplosionSound;

simulated function Explode(vector HitLocation, vector HitNormal)
{
    local PlayerController PC;

    PlaySound(ExplosionSound,, 2.5*TransientSoundVolume);

    if ( TrailEmitter != None )
    {
        TrailEmitter.Kill();
        TrailEmitter = None;
    }

    if ( EffectIsRelevant(Location,false) )
    {
        Spawn(class'NewExplosionA',,,HitLocation + HitNormal*16,rotator(HitNormal));
        PC = Level.GetLocalPlayerController();
        if ( (PC.ViewTarget != None) && VSize(PC.ViewTarget.Location - Location) < 5000 )
            Spawn(class'ExplosionCrap',,, HitLocation, rotator(HitNormal));

        if ( (ExplosionDecal != None) && (Level.NetMode != NM_DedicatedServer) )
            Spawn(ExplosionDecal,self,,Location, rotator(-HitNormal));
    }

    BlowUp(HitLocation+HitNormal*2.f);
    Destroy();
}

DefaultProperties
{
   AccelRate=16000.000000 //GE: This is already ungodly fast. Now even faster!
   //AmbientSound=Sound'UT3A_Weapon_RocketLauncher.UT3RocketSingles.UT3RocketTravel01'
   ExplosionSound=Sound'UT3A_Weapon_RocketLauncher.UT3RocketImpact.UT3RocketImpactCue'
}
