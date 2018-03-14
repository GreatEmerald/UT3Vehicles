/*==============================================================================
* UT3HBShockBall.uc
* This is an improvement.
* Copyright © 2008, GreatEmerald
* Copyright © 2018, HellDragon
*==============================================================================
*/

class UT3HBShockBall extends ONSSkyMine;

function SuperExplosion()
{
   local actor HitActor;
   local vector HitLocation, HitNormal;
   local Emitter E;

   HurtRadius(ComboDamage, ComboRadius, class'UT3DmgType_HellbenderCombo', ComboMomentumTransfer, Location );

   E = Spawn(class'ONSPRVComboEffect');
   if ( Level.NetMode == NM_DedicatedServer )
   {
       if ( E != None )
         E.LifeSpan = 0.25;
   }
   else if ( EffectIsRelevant(Location,false) )
   {
      HitActor = Trace(HitLocation, HitNormal,Location - Vect(0,0,120), Location,false);
      if ( HitActor != None )
         Spawn(class'ComboDecal',self,,HitLocation, rotator(vect(0,0,-1)));
   }
   PlaySound(ComboSound, SLOT_None,1.0,,800);
   DestroyTrails();

   if (bDoChainReaction)
   {
      SetPhysics(PHYS_None);
      SetCollision(false);
      bHidden = true;
      SetTimer(ChainReactionDelay, false);
   }
   else
      Destroy();
}

defaultproperties
{
   ComboDamageType=class'UT3DmgType_HellbenderLaser'
   Speed=1400.000000
   MaxSpeed=1400.000000
   AmbientSound=Sound'UT3A_Weapon_ShockRifle.UT3ShockSingles.UT3ShockAltFireTravel01'
   ImpactSound=Sound'UT3A_Weapon_ShockRifle.UT3ShockAltFireImpact.UT3ShockAltFireImpactCue'
   ComboSound=Sound'UT3A_Weapon_ShockRifle.UT3ShockComboExplosion.UT3ShockComboExplosionCue'
   
}

