/*
 * Copyright © 2008 Wail of Suicide
 * Based on the Locust Hoverboard by gel
 * Additional thanks to ChaosUT2 Team for help figuring out Player collision
 * while on driving, Monarch, and LordSimeon for assistance on driver positioning
 *
 * Copyright © 2014 GreatEmerald
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
//// NEW Maybe try this for the Animations file
//#exec MESH  MODELIMPORT MESH=TankVictimMesh MODELFILE=models\tank_victim.PSK RIGID=1


#exec OBJ LOAD FILE=..\StaticMeshes\EONSLocustSM.usx
#exec OBJ LOAD FILE=..\Animations\EONSLocustA.ukx
#exec OBJ LOAD FILE=..\Textures\EONSLocustTex.utx

#exec OBJ LOAD FILE=..\Sounds\ONSVehicleSounds-S.uax
#exec OBJ LOAD FILE=..\textures\EpicParticles.utx
#exec OBJ LOAD FILE=..\StaticMeshes\ONSWeapons-SM.usx
#exec OBJ LOAD FILE=..\textures\VMVehicles-TX.utx

class UT3Hoverboard extends ONSHoverCraft;

var()   float   MaxPitchSpeed;

var()   float   JumpDuration;
var()   float   JumpForceMag;
var     float   JumpCountdown;
var     float   JumpDelay, LastJumpTime;

var()   float   DuckDuration;
var()   float   DuckForceMag;
var     float   DuckCountdown;

var()   array<vector>                   BikeDustOffset;
var()   float                           BikeDustTraceDistance;

var()   Sound                           JumpSound;
var()   Sound                           AltFireSound;
var() Sound WaterDisruptSound;

// Force Feedback
var()   string                          JumpForce;

var     array<ONSHoverBikeHoverDust>    BikeDust;
var     array<vector>                   BikeDustLastNormal;

var     bool                            DoBikeJump;
var     bool                            OldDoBikeJump;

var     bool                            DoBikeDuck;
var     bool                            OldDoBikeDuck;
var     bool                            bHoldingDuck;
var     bool                            bOverWater;
var     bool                            bWasOverWater;

// Variables below by gel
var()	array<vector>	         BikeDustOffsetTemp;
var     int                  jumpMult;       // Multiplier for the jump (int b/c i don't know how to compare floats accurately)
var     bool                 bDuckReleased;

//Other
var bool bAttachedDriver;
var int  DriverHealth;

Var rotator ArmDriveL,ArmDriveR;
Var rotator ForeArmDriveL, ForeArmDriveR;

var () class<Emitter>	TrailClass[2];
var Emitter				TrailEmitter[2];
var () Vector			TrailOffset[2];
var () Rotator		TrailRotOffset[2];

var() float MaxGroundSpeed, MaxWaterSpeed;
var float MaxMovementSpeed;
var float OldVelocityZ;
var vector EnterVelocity;
var float WaterCounter;

var class<DamageType> LastDamageType;
var vector LastHitLocation;

//==================================================


replication
{
   reliable if (bNetDirty && Role == ROLE_Authority)
      DoBikeJump, DriverHealth;
}


// AI hint
function bool FastVehicle()
{
   return true;
}


function ShouldTargetMissile(Projectile P)
{
    if ( (Bot(Controller) != None)
        && (Level.Game.GameDifficulty > 4 + 4*FRand())
        && (VSize(P.Location - Location) < VSize(P.Velocity)) )
    {
        KDriverLeave(false);
        TeamUseTime = Level.TimeSeconds + 4;
        return;
    }
    Super.ShouldTargetMissile(P);
}


function bool TooCloseToAttack(Actor Other)
{
    if ( xPawn(Other) != None )
        return true;
    return super.TooCloseToAttack(Other);
}


function Pawn CheckForHeadShot(Vector loc, Vector ray, float AdditionalScale)
{
    local vector X, Y, Z, newray;

    GetAxes(Rotation,X,Y,Z);

    if (Driver != None)
    {
        // Remove the Z component of the ray
        newray = ray;
        newray.Z = 0;
        if (abs(newray dot X) < 0.7 && Driver.IsHeadShot(loc, ray, AdditionalScale))
            return Driver;
    }

    return None;
}


simulated function Destroyed()
{
    local int i;

    if (Level.NetMode != NM_DedicatedServer)
    {
        for (i = 0; i < BikeDust.Length; i++)
            BikeDust[i].Destroy();

        BikeDust.Length = 0;

        if (TrailEmitter[0] != None)
           TrailEmitter[0].Destroy();
        if (TrailEmitter[1] != None)
           TrailEmitter[1].Destroy();
    }

    Super.Destroyed();
}


simulated function DestroyAppearance()
{
    local int i;

    if (Level.NetMode != NM_DedicatedServer)
    {
       for (i = 0; i < BikeDust.Length; i++)
           BikeDust[i].Destroy();

       BikeDust.Length = 0;

       if (TrailEmitter[0] != None)
          TrailEmitter[0].Destroy();
       if (TrailEmitter[1] != None)
          TrailEmitter[1].Destroy();
    }

    Super.DestroyAppearance();
}


function bool Dodge(eDoubleClickDir DoubleClickMove)
{
    Rise = 1;
    ServerPlayHorn(1);
    return true;
}


function ChooseFireAt(Actor A)
{
    if (Pawn(A) != None && Vehicle(A) == None && Controller.LineOfSightTo(A))
    {
       if (!bWeaponIsAltFiring)
          AltFire(0);
    }
    else if (bWeaponIsAltFiring)
          VehicleCeaseFire(true);
}


simulated event DrivingStatusChanged()
{
    local int i;

    Super.DrivingStatusChanged();

    if (bDriving && Level.NetMode != NM_DedicatedServer && BikeDust.Length == 0 && !bDropDetail)
    {
        BikeDust.Length = BikeDustOffset.Length;
        BikeDustLastNormal.Length = BikeDustOffset.Length;

        for (i=0; i<BikeDustOffset.Length; i++)
            if (BikeDust[i] == None)
            {
                BikeDust[i] = spawn( class'EONSLocustHoverDust', self,, Location + (BikeDustOffset[i] >> Rotation) );
                BikeDust[i].SetDustColor( Level.DustColor );
                BikeDustLastNormal[i] = vect(0,0,1);
            }

        // Create trail emitters.
        if (TrailEmitter[0] == None)
        {
            TrailEmitter[0] = spawn(TrailClass[Team], self,, Location + (TrailOffset[0] >> Rotation) );
            TrailEmitter[0].SetBase(self);
            TrailEmitter[0].SetRelativeRotation(TrailRotOffset[0]);
        }
        if (TrailEmitter[1] == None)
        {
            TrailEmitter[1] = spawn(TrailClass[Team], self,, Location + (TrailOffset[1] >> Rotation) );
            TrailEmitter[1].SetBase(self);
            TrailEmitter[1].SetRelativeRotation(TrailRotOffset[1]);
        }
    }
    else
    {
        if (Level.NetMode != NM_DedicatedServer)
        {
            for(i=0; i<BikeDust.Length; i++)
                BikeDust[i].Destroy();

            BikeDust.Length = 0;
        }
        JumpCountDown = 0.0;

        if (TrailEmitter[0] != None)
           TrailEmitter[0].Destroy();
        if (TrailEmitter[1] != None)
           TrailEmitter[1].Destroy();
    }
}

simulated function Tick(float DeltaTime)
{
    local float EnginePitch, HitDist;
    local int i;
    local vector TraceStart, TraceEnd, HitLocation, HitNormal;
    local actor HitActor;
    local Emitter JumpEffect;
    local KarmaParams kp;
    //local int    gravity;
    local rotator MyRotator;
    local float MyVelocity, Multiplier;

    //gravity = -1;

    Super.Tick(DeltaTime);

    // Check for water
    WaterCounter += DeltaTime;
    if (WaterCounter > 0.1/HoverPenScale)
        bOverWater = false;
    kp = KarmaParams(KParams);
    for(i=0;i<kp.Repulsors.Length;i++)
    {
        if (kp.Repulsors[i].bRepulsorOnWater)
        {
            bOverWater = true;
            WaterCounter = 0.0;
            break;
        }
    }
    if (bOverWater && !bWasOverWater)
        GoOnWater();
    else if (!bOverWater && bWasOverWater)
        GoOffWater();
    bWasOverWater = bOverWater;

    // GEm: Kill adding force if speed is above threshold (doesn't affect gravity, woo)
    if (VSize(Velocity) >= MaxMovementSpeed)
        MaxThrustForce = 0.0;
    else
        MaxThrustForce = default.MaxThrustForce;
    // GEm: Needs to play some nice animation
    if (OldVelocityZ < Velocity.Z-(0.5 * MaxFallSpeed))
        TakeFallingDamage();
    OldVelocityZ = Velocity.Z;

    JumpCountdown -= DeltaTime;

    CheckJumpDuck();

    if (DoBikeJump != OldDoBikeJump)
    {
        JumpCountdown = JumpDuration;
        OldDoBikeJump = DoBikeJump;
        if ( (Controller != Level.GetLocalPlayerController()) && EffectIsRelevant(Location,false) )
        {
            JumpEffect = Spawn(class'EONSLocustJumpEffect');
            JumpEffect.SetBase(Self);
            ClientPlayForceFeedback(JumpForce);
        }
    }

    if ( Level.NetMode != NM_DedicatedServer )
    {
        EnginePitch = 64.0 + VSize(Velocity)/MaxPitchSpeed * 64.0;
        SoundPitch = FClamp(EnginePitch, 64, 128);

        if (TrailEmitter[0] != None && TrailEmitter[1] != None)
        {
           MyVelocity = Normal(Velocity) dot Normal(vector(Rotation));
           if (MyVelocity > 0)
              Multiplier = -1;
           if (MyVelocity < 0)
              Multiplier = 1;

           MyRotator.Pitch=(16384 + (Multiplier * VSize(Velocity)/MaxPitchSpeed * 8192));

           TrailEmitter[0].SetRelativeRotation(MyRotator);
           TrailEmitter[1].SetRelativeRotation(MyRotator);
        }

        if( !bDropDetail )
        {
            for(i=0; i<BikeDust.Length; i++)
            {
                BikeDust[i].bDustActive = false;

                TraceStart = Location + (BikeDustOffset[i] >> Rotation);
                TraceEnd = TraceStart - ( BikeDustTraceDistance * vect(0,0,1) );

                HitActor = Trace(HitLocation, HitNormal, TraceEnd, TraceStart, true);

                if(HitActor == None)
                {
                    BikeDust[i].UpdateHoverDust(false, 0);
                }
                else
                {
                    HitDist = VSize(HitLocation - TraceStart);

                    BikeDust[i].SetLocation( HitLocation + 10*HitNormal);

                    BikeDustLastNormal[i] = Normal( 3*BikeDustLastNormal[i] + HitNormal );
                    BikeDust[i].SetRotation( Rotator(BikeDustLastNormal[i]) );

                    BikeDust[i].UpdateHoverDust(!bOverWater, HitDist/BikeDustTraceDistance);

                    // If dust is just turning on, set OldLocation to current Location to avoid spawn interpolation.
                    if(!BikeDust[i].bDustActive)
                        BikeDust[i].OldLocation = BikeDust[i].Location;

                    if (bOverWater)
                        BikeDust[i].bDustActive = false;
                    else
                        BikeDust[i].bDustActive = true;
                }
            }
        }
    } //--End if Level.NetMode

    // Spin Attack - Removed

    if (Driver != None && Driver.Health > 0 && DriverHealth > Driver.Health)
    {
        if (DriverHealth >= Driver.Health+10){
            //log(self@"Tick: Health watchdog eject when old health"@DriverHealth@"new health"@Driver.Health);
            EjectDriver();}
        DriverHealth = Driver.Health;
    }
}

function TakeFallingDamage()
{
    local float Shake, EffectiveSpeed;

    if (OldVelocityZ < -0.5 * MaxFallSpeed)
    {
        if ( Role == ROLE_Authority )
        {
            MakeNoise(1.0);
            if (OldVelocityZ < -1 * MaxFallSpeed)
            {
                EffectiveSpeed = OldVelocityZ;
                if ( TouchingWaterVolume() )
                    EffectiveSpeed = FMin(0, EffectiveSpeed + 100);
                if ( EffectiveSpeed < -1 * MaxFallSpeed )
                    TakeDamage(-100 * (EffectiveSpeed + MaxFallSpeed)/MaxFallSpeed, None, Location, vect(0,0,0), class'Fell');
            }
        }
        if ( Controller != None )
        {
            Shake = FMin(1, -1 * OldVelocityZ/MaxFallSpeed);
            Controller.DamageShake(Shake);
        }
    }
    else if (OldVelocityZ < -1.4 * JumpZ)
        MakeNoise(0.5);
}

simulated function float ChargeBar()
{
    // Clamp to 0.999 so charge bar doesn't blink when maxed
    if (Level.TimeSeconds - JumpDelay < LastJumpTime)
        return (FMin((Level.TimeSeconds - LastJumpTime) / JumpDelay, 0.999));
    else
        return 0.999;
}


simulated function CheckJumpDuck()
{
    local KarmaParams KP;
    local Emitter JumpEffect;
    local bool bOnGround;
    local int i;

    KP = KarmaParams(KParams);

    // Can only start a jump when in contact with the ground.
    bOnGround = false;
    for (i=0; i<KP.Repulsors.Length; i++)
    {
        if( KP.Repulsors[i] != None && KP.Repulsors[i].bRepulsorInContact )
            bOnGround = true;
    }

    // If we are on the ground, and press Rise, and we not currently in the middle of a jump, start a new one.
    if (JumpCountdown <= 0.0 && bOnGround && !bOverWater
        && ((Rise > 0 && !bHoldingDuck) || (Rise >= 0 && bDuckReleased))
        && Level.TimeSeconds - JumpDelay >= LastJumpTime)
    {
        PlaySound(JumpSound,,1.0);

        if (Role == ROLE_Authority)
           DoBikeJump = !DoBikeJump;

        if (Level.NetMode != NM_DedicatedServer)
        {
           JumpEffect = Spawn(class'EONSLocustJumpEffect');
           JumpEffect.SetBase(Self);
           ClientPlayForceFeedback(JumpForce);
        }

        if ( AIController(Controller) != None )
           Rise = 0;

        LastJumpTime = Level.TimeSeconds;
        bDuckReleased = false;
    }
    else if (Rise < 0 && bOnGround)
    {
        if (!bHoldingDuck)
        {
            bHoldingDuck = true;
            DriveAnim = 'Crouch';
            Driver.LoopAnim(DriveAnim, , 0.25);
            Driver.SetCollisionSize(Driver.default.CollisionRadius, Driver.CrouchHeight);
        }

        bDuckReleased = false;
        jumpMult += 15;

        if (jumpMult > 1500)
        {
           jumpMult = 1500;
        }
    }
    else if (DuckCountdown <= 0.0 && Rise < 0)
    {
        if (!bHoldingDuck)
        {
            bHoldingDuck = True;

            DriveAnim = 'Crouch';
            Driver.LoopAnim(DriveAnim, , 0.25);
            Driver.SetCollisionSize(Driver.default.CollisionRadius, Driver.CrouchHeight);

            if ( AIController(Controller) != None )
                Rise = 0;

            JumpCountdown = 0.0; // Stops any jumping that was going on.
        }
    }
    else
    {
        if (bOnGround && bHoldingDuck
            && Driver.SetCollisionSize(Driver.default.CollisionRadius, Driver.default.CollisionHeight))
        {
            bHoldingDuck = False;
            bDuckReleased = true;
            DriveAnim = default.DriveAnim;
            Driver.LoopAnim(DriveAnim, , 0.25);
        }
    }
}

// GEm: Also needs some repulsor visual effect
simulated function GoOnWater()
{
    MaxMovementSpeed = MaxWaterSpeed;
    PlaySound(WaterDisruptSound, , 1.0);
}

simulated function GoOffWater()
{
    MaxMovementSpeed = MaxGroundSpeed;
}


simulated function KApplyForce(out vector Force, out vector Torque)
{
    Super.KApplyForce(Force, Torque);

    if (bDriving && JumpCountdown > 0.0)
    {
        Force += vect(0,0,1) * JumpForceMag;
    }
    if (VSize(EnterVelocity) != 0.0)
    {
        Force += EnterVelocity;
        EnterVelocity = vect(0.0,0.0,0.0);
    }
}

//==================================================

event TakeDamage (int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType)
{
    //Don't take damage from Avrils, this is a hack because we basically don't want Avrils locking on hoverboards in the first place
    //Unfortunately the only way we can handle that is by replacing the Avril, and there's no guarantee all mappers will use a modified Avril
    //if (DamageType == class'DamTypeONSAVRiLRocket')
    //{
    //   Damage *= 0;
    //   Momentum *= 0;
    //}
    local Pawn OldPawn;

    //log(self@"TakeDamage: Health"@Driver.Health@"Damage"@Damage@"Instigator"@EventInstigator@"Momentum"@Momentum@"Damage Type"@DamageType);

    OldPawn = Driver;

    // GEm: Take momentum but not damage
    Super.TakeDamage(0, EventInstigator, HitLocation, Momentum, DamageType);

    //Eject driver after suffering any damage.
    if (Controller != None && Driver != None)
    {
        if (!Controller.bGodMode && (EventInstigator == None || (EventInstigator.GetTeamNum() != Driver.GetTeamNum() || EventInstigator == Driver))
            && Damage > 0 )
        {
            if (EventInstigator != None && EventInstigator.GetTeamNum() != Driver.GetTeamNum()
                && Damage < Driver.Health) // GEm: Don't bother ejecting if the driver's dead meat anyway
            {
                EjectDriver();
                OldPawn.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType);
            }
            else
                Driver.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType);
            LastDamageType = DamageType;
            LastHitLocation = HitLocation;
        }
    }
}


event Bump(actor Other)
{
   if (xPawn(Other) != None)
      Velocity = vect(0,0,0);
}


event Touch( Actor Other )
{
    if ( xPawn(Other) != none )
       Velocity = vect(0,0,0);
}


function KDriverEnter (Pawn P)
{
    EnterVelocity = P.Velocity;

    Super.KDriverEnter(P); // calls the normal function

    SetCollision(true, true);

    DriverHealth = P.Health;
    BikeDustOffsetTemp[0] = BikeDustOffset[0];
    BikeDustOffsetTemp[1] = BikeDustOffset[1];

    // Tweaks so players can be damaged while on the board
    Driver.SetCollision(true,false,false);
    Driver.bCanPickupInventory=false;
}


function bool KDriverLeave (bool bForceLeave)
{
    DriverHealth = 0;
    if (Driver != None) // GEm: Prevent exploits
        Driver.SetCollisionSize(Driver.default.CollisionRadius, Driver.default.CollisionHeight);

    if (Driver != None)
       Driver.bCanPickupInventory=Driver.default.bCanPickupInventory;

    if ( PlayerReplicationInfo != None && PlayerReplicationInfo.HasFlag != None)
        Driver.HoldFlag(PlayerReplicationInfo.HasFlag);

    if (Driver != None)
        Driver.Velocity = Velocity;

    return Super.KDriverLeave(bForceLeave);
}

function DriverLeft()
{
    Super.DriverLeft();
    Destroy();
}


function DriverDied()
{
    if (Driver != None)
       Driver.bCanPickupInventory=Driver.default.bCanPickupInventory;
    if ( PlayerReplicationInfo != None && PlayerReplicationInfo.HasFlag != None)
        PlayerReplicationInfo.HasFlag.Drop(0.5 * Velocity);

    Super.DriverDied();

    Destroy();
}


simulated event StartDriving(Vehicle V)
{
    Super.StartDriving(V);
    V.AttachDriver( Self );
}


//If we have a Karma impact, eject
event KImpact(actor Other, vector Pos, vector ImpactVel, vector ImpactNorm)
{
    if (Role == ROLE_Authority)
    {
        ImpactInfo.Other = Other;
        ImpactInfo.Pos = Pos;
        ImpactInfo.ImpactVel = ImpactVel;
        ImpactInfo.ImpactNorm = ImpactNorm;
        ImpactInfo.ImpactAccel = KParams.KAcceleration;
        ImpactTicksLeft = ImpactDamageTicks;

        // if we hit a solid object going too fast eject the driver
        if ( Other != None && !ClassIsChildOf(Other.class, class'TerrainInfo') && Vsize(ImpactVel) > 8000){      //2000
            //log(self@"KImpact: Ejecting due to impact, health"@Driver.Health);
           EjectDriver();}
    }
}


// New Eject
function EjectDriver()
{
    local Pawn	OldPawn;
    local vector	EjectVel;
    //local UT3HoverboardRagdolliser HR;
    local UT3RagdollInventory RI;

    OldPawn = Driver;

    KDriverLeave( true );

    if ( OldPawn == None )
        return;

    EjectVel = Velocity;
    OldPawn.Velocity = Velocity;

    /*HR = Spawn(class'UT3HoverboardRagdolliser', OldPawn);
    if (HR != None)
        HR.Ragdollise(LastDamageType, LastHitLocation);*/

    if (xPawn(OldPawn) != None)
        OldPawn.PlaySound(xPawn(OldPawn).GetSound(EST_LandGrunt), SLOT_Interact);

    RI = UT3RagdollInventory(OldPawn.FindInventoryType(class'UT3RagdollInventory'));
    if (RI != None)
        RI.StartRagdoll(class'UT3RagdollInventory'.default.FeignDeathLimit, true);
}

// GEm: Don't do any damage on dying
function VehicleExplosion(vector MomentumNormal, float PercentMomentum);

function AltFire(optional float F)
{
    MaxYawRate = 0.1;
    PlaySound(AltFireSound, , 1.0);
    bWeaponIsAltFiring = true;
}

function VehicleCeaseFire(bool bWasAltFire)
{
    Super.VehicleCeaseFire(bWasAltFire);

    if (bWasAltFire)
    {
        MaxYawRate = default.MaxYawRate;
        bWeaponIsAltFiring = false;
    }
}

//==================================================


simulated function AttachDriver(Pawn P)
{
    Super.AttachDriver(P);
    bAttachedDriver=true;

    //Arms
    //LeftArm
    ArmDriveL.Yaw=5000; //9000;
    ArmDriveL.Pitch=-4000;
    P.SetBoneRotation('Bip01 L UpperArm',ArmDriveL);
    ForeArmDriveL.Yaw=10000; //3000;
    ForeArmDriveL.Roll=-7000; //32678;
    P.SetBoneRotation('Bip01 L ForeArm',ForeArmDriveL);
    //RightArm
    ArmDriveR.Yaw=4000; //9000;
    ArmDriveR.Pitch=-2000; //6000;
    P.SetBoneRotation('Bip01 R UpperArm',ArmDriveR);
    ForeArmDriveR.Yaw=11000; //3000;
    ForeArmDriveR.Pitch=1000; //3000;
    P.SetBoneRotation('Bip01 R ForeArm',ForeArmDriveR);
}

simulated function DetachDriver(Pawn P)
{
    P.SetBoneRotation('Bip01 Head');
    P.SetBoneRotation('Bip01 Spine');
    P.SetBoneRotation('Bip01 Spine1');
    P.SetBoneRotation('Bip01 Spine2');
    P.SetBoneRotation('Bip01 L Clavicle');
    P.SetBoneRotation('Bip01 R Clavicle');
    P.SetBoneRotation('Bip01 L UpperArm');
    P.SetBoneRotation('Bip01 R UpperArm');
    P.SetBoneRotation('Bip01 L ForeArm');
    P.SetBoneRotation('Bip01 R ForeArm');
    P.SetBoneRotation('Bip01 L Thigh');
    P.SetBoneRotation('Bip01 R Thigh');
    P.SetBoneRotation('Bip01 L Calf');
    P.SetBoneRotation('Bip01 R Calf');

    bAttachedDriver=false;
    Super.DetachDriver(P);
}


//==================================================


static function StaticPrecache(LevelInfo L)
{
    Super.StaticPrecache(L);

    L.AddPrecacheStaticMesh(StaticMesh'UT3HoverboardSM');
    L.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris2');
    L.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris1');
    L.AddPrecacheStaticMesh(StaticMesh'ONSWeapons-SM.PC_MantaJumpBlast');

    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp2_frames');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp1_frames');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.we1_frames');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.MuchSmoke1');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.NapalmSpot');
    L.AddPrecacheMaterial(Material'EpicParticles.Fire.SprayFire1');
    L.AddPrecacheMaterial(Material'WeaponSkins.Skins.RocketTex0');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Energy.JumpDuck');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Energy.AirBlast');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.GrenExpl');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.SmokePanels2');
    L.AddPrecacheMaterial(Material'Engine.GRADIENT_Fade');

}

simulated function UpdatePrecacheStaticMeshes()
{
    Level.AddPrecacheStaticMesh(StaticMesh'UT3HoverboardSM');
    Level.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris2');
    Level.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris1');
    Level.AddPrecacheStaticMesh(StaticMesh'ONSWeapons-SM.PC_MantaJumpBlast');
    Super.UpdatePrecacheStaticMeshes();
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp2_frames');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp1_frames');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.we1_frames');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.MuchSmoke1');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.NapalmSpot');
    Level.AddPrecacheMaterial(Material'EpicParticles.Fire.SprayFire1');
    Level.AddPrecacheMaterial(Material'WeaponSkins.Skins.RocketTex0');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Energy.JumpDuck');
    Level.AddPrecacheMaterial(Material'VMVehicles-TX.RVGroup.RVbladesSHAD');
    Level.AddPrecacheMaterial(Material'VMVehicles-TX.HoverBikeGroup.NewHoverCraftNOcolor');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Energy.AirBlast');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.GrenExpl');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.SmokePanels2');
    Level.AddPrecacheMaterial(Material'Engine.GRADIENT_Fade');

	Super.UpdatePrecacheMaterials();
}

//==================================================

defaultproperties
{

//==================================================
// Identity
//==================================================
    VehicleNameString="UT3 Hoverboard"
    VehiclePositionString="on a hoverboard"
   
    CollisionHeight=1.0
    MaxDesireability=0.5
    VehicleMass=1.5 //2.0
   
//==================================================
// Appearance
//==================================================
    DrawScale3D=(X=1.2,Y=1.2,Z=1.2)
    Mesh=Mesh'UT3Hoverboard'
    Skins(0)=Material'EONSLocustTex.UT3HoverboardGrey'
    RedSkin=Material'EONSLocustTex.UT3HoverboardGrey'
    BlueSkin=Material'EONSLocustTex.UT3HoverboardGrey'

    DestroyedVehicleMesh=StaticMesh'EONSLocustSM.UT3HoverboardSM'
    DestructionEffectClass=class'Onslaught.ONSSmallVehicleExplosionEffect'
    DisintegrationEffectClass=class'Onslaught.ONSVehicleExplosionEffect'

    bCanCarryFlag=true
    bDriverHoldsFlag=true
    DriveAnim="Idle_Biggun"
    DrivePos=(X=0.000000,Y=0.000000,Z=61.000000)
    DriveRot=(Yaw=6000)
    FlagBone="trail2"
    FlagOffset=(Z=45.000000)
    FlagRotation=(Yaw=32768)

    BikeDustOffset(0)=(X=30.000000,Z=10.000000)
    BikeDustOffset(1)=(X=-30.000000,Z=10.000000)
    BikeDustTraceDistance=100.000000

    DamagedEffectScale=0.500000
    DamagedEffectOffset=(X=28.000000,Y=-10.000000,Z=10.000000)

    ThrusterOffsets(0)=(X=50.000000,Z=10.000000)
    ThrusterOffsets(1)=(X=-50.000000,Z=10.000000)
    ThrusterOffsets(2)=(Z=0.000000)

    TrailClass(0)=class'EONSLocustThrusterEffectRed'
    TrailClass(1)=class'EONSLocustThrusterEffectBlue'
    TrailOffset(0)=(X=25.000000,Y=0.000000,Z=2.000000)
    TrailOffset(1)=(X=-25.000000,Y=0.000000,Z=6.000000)
    TrailRotOffset(0)=(Pitch=15000)   //Pitch=16384
    TrailRotOffset(1)=(Pitch=15000)

//==================================================
// Sound
//==================================================
    IdleSound=Sound'UT3A_Vehicle_Hoverboard.UT3HoverboardSingles.UT3HoverboardEngine01Cue'
    StartUpSound=Sound'UT3A_Vehicle_Hoverboard.UT3HoverboardEngineStart.UT3HoverboardEngineStartCue'
    ShutDownSound=Sound'UT3A_Vehicle_Hoverboard.UT3HoverboardEngineStop.UT3HoverboardEngineStopCue'
    JumpSound=Sound'UT3A_Vehicle_Hoverboard.UT3HoverboardJump.UT3HoverboardJumpCue'
    AltFireSound=Sound'UT3A_Vehicle_Hoverboard.UT3HoverboardGrappleFail.UT3HoverboardGrappleFailCue'
    WaterDisruptSound=Sound'UT3A_Vehicle_Hoverboard.UT3HoverboardWaterDisrupt.UT3HoverboardWaterDisruptCue'
    HornSounds(0)=Sound'ONSVehicleSounds-S.Horns.Horn02'
    HornSounds(1)=Sound'ONSVehicleSounds-S.Horns.La_Cucharacha_Horn'
    ImpactDamageSounds=()
    ImpactDamageSounds(0) = Sound'UT3A_Vehicle_Hoverboard.UT3HoverboardCollide.UT3HoverboardCollideCue'
    StolenAnnouncement=None                        //
    StolenSound=None                               //sound'ONSVehicleSounds-S.CarAlarm01'
    
    MaxPitchSpeed=1200.000000
    SoundVolume=255
    SoundRadius=600.000000

    StartUpForce="HoverBikeStartUp"
    ShutDownForce="HoverBikeShutDown"
    JumpForce="HoverBikeJump"

//==================================================
// Health & Damage
//==================================================
    bBlockActors = false // GEm: This is so we don't instantly die, KDriverEnter unsets this
    bEjectDriver = true
    bHasAltFire=False
    Health=1
    HealthMax=1.000000
    DestructionLinearMomentum=(Min=62000.000000,Max=100000.000000)
    DestructionAngularMomentum=(Min=25.000000,Max=75.000000)
    DisintegrationHealth=-25
    LinkHealMult=1.000000
    DriverDamageMult=1.0
    ImpactDamageMult=0.00008
    MomentumMult=2.0
    MeleeRange=-200.000000    
    MinRunOverSpeed=100000

    // GEm: Should make sure none of the below ever happen
    //RanOverDamageType=class'DamTypeEONSLocustHeadshot'
    //CrushedDamageType=class'DamTypeEONSLocustPancake'

//==================================================
// Movement
//==================================================
    bCanFlip=True
    bCanStrafe=false
    bDriverCollideActors=True
    bDuckReleased=false
    bScriptedRise=True
    bTurnInPlace=True
    bZeroPCRotOnEntry=false
    bSetPCRotOnPossess=false

    GroundSpeed=700.000000
    MaxGroundSpeed=900.0
    MaxWaterSpeed=300.0
    MaxMovementSpeed=900.0

    UprightStiffness=400.000000
    UprightDamping=300.000000

    MaxThrustForce=40.000000                     //20.000
    LongDamping=0.020000

    MaxStrafeForce=2.000000
    LatDamping=0.100000

    TurnTorqueFactor=1000.000000
    TurnTorqueMax=150.000000                     //50
    TurnDamping=30.000000                        //15, 30.000
    MaxYawRate=12.000000                         //6, 3.5

    PitchTorqueFactor=250.000000
    PitchTorqueMax=10.000000
    PitchDamping=30.000000

    RollTorqueTurnFactor=550.000000
    RollTorqueStrafeFactor=400.000000
    RollTorqueMax=15.000000
    RollDamping=10.000000

    StopThreshold=200.000000

    JumpDuration=0.100000
    JumpForceMag=160.0
    JumpDelay=1.000000
    jumpMult=1000

    bTraceWater=True
    HoverSoftness=0.0 // GEm: Controls amortisation. We don't need that at all.
    HoverPenScale=2.0 // GEm: Controls how well the board follows land curves. High values create "bounciness".
    HoverCheckDist=50.0

    Begin Object Class=KarmaParamsRBFull Name=KParams0
        kMaxSpeed=12000.0 // GEm: Around 3000 is the falling speed off the Torlan tower, 1200 is the fall damage threshold
        KInertiaTensor(0)=1.300000
        KInertiaTensor(3)=3.000000
        KInertiaTensor(5)=3.500000
        KLinearDamping=0.150000
        KAngularDamping=0.000000
        KStartEnabled=True
        bHighDetailOnly=False
        bClientOnly=False
        bKDoubleTickRate=True
        bKStayUpright=True
        bKAllowRotate=True
        bDestroyOnWorldPenetrate=True
        bDoSafetime=True
        KFriction=0.500000
        KImpactThreshold=700.000000
    End Object
    KParams=KarmaParamsRBFull'KParams0'

//==================================================
// HUD
//==================================================
    bShowChargingBar=True
    bShowDamageOverlay=True
    bSpecialHUD=True
    CrosshairColor=(R=0,G=255,B=0,A=255)
    CrosshairX=32
    CrosshairY=32
    CrosshairTexture=Texture'ONSInterface-TX.MineLayerReticle' //Texture'ONSInterface-TX.tankBarrelAligned'
    NoEntryTexture=Texture'HUDContent.NoEntry'
    TeamBeaconTexture=Texture'ONSInterface-TX.HealthBar'
    TeamBeaconBorderMaterial=Material'InterfaceContent.BorderBoxD'
    VehicleIcon=(Material=Texture'AS_FX_TX.HUD.TrackedVehicleIcon',X=0,Y=0,SizeX=64,SizeY=64)

//==================================================
// Entry & Exit
//==================================================
    bTeamLocked=False
    EntryPosition=(X=0,Y=0,Z=0)
    EntryRadius=140.0
    ExitPositions(0)=(Z=60.000000)
    ExitPositions(1)=(Z=60.000000)
    ExitPositions(2)=(Z=60.000000)
    ExitPositions(3)=(Z=60.000000)
    ExitPositions(4)=(Z=60.000000)
    ExitPositions(5)=(Z=60.000000)
    ExitPositions(6)=(Z=60.000000)
    ExitPositions(7)=(Z=60.000000)
    ObjectiveGetOutDist=10.000000

//==================================================
// Camera
//==================================================
    bDrawDriverInTP=True
    bDrawMeshInFP=True

    MaxViewYaw=16000
    MaxViewPitch=16000

    FPCamPos=(Z=50.000000)

    //Normal
    TPCamDistance=250.000000 //NOTE: Be sure TO DELETE THIS LINE from USER.INI as it overrides this value and wil be re-added to the ini as soon as you use the vehicle, all this does here is make it the starting distance
    TPCamLookat=(X=10.000000,Z=0.000000)
    TPCamWorldOffset=(Z=140.000000)

    //Gears or Outsider Style
    //TPCamDistance=150.000000
    //TPCamLookat=(X=0.000000,Y=40.000000,Z=0.000000)  //Gears Style, more Y is needed for a true Gears style, 40 is more Outsider
    //TPCamWorldOffset=(Z=100.000000)
    
}
