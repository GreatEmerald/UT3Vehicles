/*
 * Copyright © 2009, 2014 GreatEmerald
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 *     (1) Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *
 *     (2) Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimers in
 *     the documentation and/or other materials provided with the
 *     distribution.
 *
 *     (3) The name of the author may not be used to
 *     endorse or promote products derived from this software without
 *     specific prior written permission.
 *
 *     (4) The use, modification and redistribution of this software must
 *     be made in compliance with the additional terms and restrictions
 *     provided by the Unreal Tournament 2004 End User License Agreement.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
 * IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *
 * This software is not supported by Atari, S.A., Epic Games, Inc. or any
 * of such parties' affiliates and subsidiaries.
 */

class UT3ScorpionBallBlue extends EONSScorpionEnergyProjectileRed;

var class<Emitter>  ProjectileEffectClass2;
var Emitter         ProjectileEffect2;

simulated function PostBeginPlay()
{
    local Rotator R;

    if (Level.NetMode != NM_DedicatedServer)
    {
        ProjectileEffect = spawn(ProjectileEffectClass, self,, Location, Rotation);
        ProjectileEffect2 = spawn(ProjectileEffectClass2, self,, Location, Rotation);
        ProjectileEffect.SetBase(self);
        ProjectileEffect2.SetBase(self);
    }

    Super(Projectile).PostBeginPlay();

    Velocity = Speed * Vector(Rotation);
    R = Rotation;
    R.Roll = 32768;
    SetRotation(R);
    Velocity.z += TossZ;
    initialDir = Velocity;

    //Use the timer for electromagnetic shocks while travelling
    SetTimer(0.10, True);
    bEffects = false;
}

simulated function Destroyed()
{
    Super.Destroyed();

    if (ProjectileEffect2 != None)
        ProjectileEffect2.Destroy();
}

/*simulated function SpawnEffects( vector HitLocation, vector HitNormal )
{
    if ( EffectIsRelevant(Location,false) )
    {
        if (bZap)
        {
           spawn(class'xEffects.GoopSparks',,,Location);
           PlaySound(sound'WeaponSounds.BioRifle.BioRifleGoo1',,8*TransientSoundVolume);
        }
        else
        {
           PlaySound(ImpactSound,,4*TransientSoundVolume);
        }

        spawn(ExplosionEmitterClass,,,Location);

        if ( (ExplosionDecal != None) && (Level.NetMode != NM_DedicatedServer) )
            Spawn(ExplosionDecal,self,,HitLocation, rotator(-HitNormal));
    }
}  */

simulated function ProcessTouch (Actor Other, vector HitLocation) //GE: For reflecting off shieldguns
{
    local Vector X, RefNormal, RefDir;

    if (Other == Instigator) return;
    if (Other == Owner) return;

    if (Other.IsA('xPawn') && xPawn(Other).CheckReflect(HitLocation, RefNormal, Damage*0.25))
    {
        if (Role == ROLE_Authority)
        {
            X = Normal(Velocity);
            RefDir = X - 2.0*RefNormal*(X dot RefNormal);
            Spawn(Class, Other,, HitLocation+RefDir*20, Rotator(RefDir));
        }
        Destroy();
    }
    else if ( (!Other.IsA('Projectile') || Other.bProjTarget) && Other != Instigator )
    {
        SpawnEffects(HitLocation, -1 * Normal(Velocity) );
        bEffects = true;
        Explode(HitLocation,Normal(HitLocation-Other.Location));
    }
}

/*simulated function Timer() //GE: This function gives us some odd warnings
{
    //local Vehicle Other;
    local Controller C, NextC;
    local xEmitter HitEmitter;
    local int TempDamage;

    bZap = false;

    C = Level.ControllerList;

    //Instead of using ForEach VisibleCollidingActors, lets traverse the Controller List, it may be faster    //ForEach VisibleCollidingActors(class'Vehicle',Other,FlyingDamageRadius)
    while (C != None)
    {
       NextC = C.NextController;

       //If the controller's pawn is a vehicle (that isn't the vehicle shooting this projectile) of a certain type,
       //isn't dead, isn't on our team, is within the range of being struck, and has a clear path to being zapped
       //then zap it.
       if ( C.Pawn != None && Vehicle(C.Pawn) != None && C.Pawn != Instigator && C.Pawn.Health > 0 && !C.SameTeamAs(Instigator.Controller) && VSize(C.Pawn.Location - Self.Location) < FlyingDamageRadius && FastTrace(C.Pawn.Location, Self.Location) && (Vehicle(C.Pawn).IsA('ONSHoverBike') || Vehicle(C.Pawn).IsA('ONSAttackCraft') || Vehicle(C.Pawn).IsA('ONSDualAttackCraft') || Vehicle(C.Pawn).IsA('ONSHoverCraft') ) )
       {
          if ( Role == ROLE_Authority )
			    {
			       if (C.Pawn.Health < 100 && C.Pawn.Health > 25)
			       {
                TempDamage = Max(1,(C.Pawn.Health - 25));
                C.Pawn.TakeDamage( TempDamage, Instigator, C.Pawn.Location, Normal(Location-C.Pawn.Location), MyDamageType);
                Vehicle(C.Pawn).DriverRadiusDamage( (TempDamage/3)+Rand(10), DamageRadius, Instigator.Controller, MyDamageType, MomentumTransfer, (C.Pawn.Location + VRand()*30) ); //We may need to change Hitlocation to Other.Location
                Vehicle(C.Pawn).EjectDriver();
                bZap = true;
             }
             else
             {
				        C.Pawn.TakeDamage(Damage, Instigator, C.Pawn.Location, Normal(Location-C.Pawn.Location), MyDamageType);
                Vehicle(C.Pawn).DriverRadiusDamage( (Damage/3)+Rand(10), DamageRadius, Instigator.Controller, MyDamageType, MomentumTransfer, C.Pawn.Location );
                bZap = true;
             }

             //Log("Applying damage to nearby vehicle: "$(FlyingDamageRadius-(VSize(Location-Other.Location))) * Default.FlyingDamage/FlyingDamageRadius);
          }

          //Once this projectile has zapped something, draw the zap and then the projectile goes away.
          if (bZap)
          {
             HitEmitter = spawn(HitEmitterClass,,, Self.Location, rotator(C.Pawn.Location - Self.Location));
				     if (HitEmitter != None)
					      HitEmitter.mSpawnVecA = C.Pawn.Location;
					   C.Pawn.PlaySound(ImpactSound,,4*TransientSoundVolume);
             Self.Destroy();
          }
       }

       C = NextC;
	  }

	  if (Velocity.Z > -1000)
	  {
       Velocity.Z -= 60;
	  }
}   */

DefaultProperties
{
  Speed=4000.000000
  DamageRadius=220.000000
  MomentumTransfer=40000.000000
  LifeSpan=1.600000
  TossZ=3.5
  ProjectileEffectClass=class'UT3ScorpionBallProjB'
  ProjectileEffectClass2=class'UT3ScorpionBallProj2B'
  CollisionHeight=30
  CollisionRadius=30
  ForceScale=10.0
  //AmbientSound=Sound'UT3Vehicles.SCORPION.ScorpionBallAmb'
  ImpactSound=Sound'UT3Weapons2.BioRifle.BioRifleExplode' // GEm: FIXME, should not depend on UT3Weapons2
  MyDamageType=class'UT3ScorpionBallDamage'
  ExplosionEmitterClass=class'ONSPlasmaHitBlue'
}
