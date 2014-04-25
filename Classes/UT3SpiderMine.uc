/*
 * Copyright © 2012 100GPing100
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

class UT3SpiderMine extends Projectile;


#exec audio import group=SpiderSounds file=../UT3Vehicles/Sounds/UT3Nightshade/SpiderMine/Spider_Explode01.wav
#exec audio import group=SpiderSounds file=../UT3Vehicles/Sounds/UT3Nightshade/SpiderMine/Spider_Explode02.wav
#exec audio import group=SpiderSounds file=../UT3Vehicles/Sounds/UT3Nightshade/SpiderMine/Spider_Explode03.wav
#exec audio import group=SpiderSounds file=../UT3Vehicles/Sounds/UT3Nightshade/SpiderMine/Spider_Attack01.wav
#exec audio import group=SpiderSounds file=../UT3Vehicles/Sounds/UT3Nightshade/SpiderMine/Spider_Attack02.wav
#exec audio import group=SpiderSounds file=../UT3Vehicles/Sounds/UT3Nightshade/SpiderMine/Spider_Attack03.wav
#exec audio import group=SpiderSounds file=../UT3Vehicles/Sounds/UT3Nightshade/SpiderMine/Spider_Walk01.wav
#exec audio import group=SpiderSounds file=../UT3Vehicles/Sounds/UT3Nightshade/SpiderMine/Spider_Walk02.wav
#exec audio import group=SpiderSounds file=../UT3Vehicles/Sounds/UT3Nightshade/SpiderMine/Spider_Walk03.wav


var float DetectionTimer; // check target every this many seconds
/** check for targets within this many units of us */
var float DetectionRange;
/** extra range beyond DetectionRange in which we keep an already acquired target */
var float KeepTargetExtraRange;
var float ScurrySpeed, ScurryAnimRate;
var float HeightOffset;

var     Pawn    TargetPawn;
var     byte     TeamNum;

var	bool	bClosedDown;
var	bool	bGoToTargetLoc;
var	vector	TargetLoc;
var	int	TargetLocFuzz;

/** the UTSpiderMineTrap that this mine is bound to. If it becomes None, the mine will blow itself up
 * The mine will return to it if it has nothing to do
 */
var UT3SpiderMineTrap Lifeline;

/** mine starts returning to its trap (if it has one) after this many seconds of inactivity */
var float ReturnToTrapDelay;
/** set when mine is trying to return to its trap */
var bool bReturning;
/** set when the mine is being destroyed because it successfully returned to a trap (so don't play explosion effects) */
var bool bReturnedToTrap;

/** The battle cry */
//var AudioComponent AttackScreechSoundComponent; // line 430

/** Minimum floor normal.Z that spider can walk on */
var float MinSpiderFloorZ;
var Actor ImpactedActor;		// Actor hit or touched by this projectile.  Gets full damage, even if radius effect projectile, and then ignored in HurtRadius


// MY VARS, MY!
var float ReturnToTrapTime;
var bool ReturnToTrapEnabled;
var array<Sound> ExplosionSnd;
var array<Sound> AttackScreechSnd;
var array<Sound> WalkingSnd;


replication
{
	reliable if (bNetInitial)
		KeepTargetExtraRange;
	reliable if (bNetDirty)
		bGoToTargetLoc, bReturning, bReturnedToTrap;
	reliable if (bNetDirty && (bGoToTargetLoc || bReturning))
		TargetLoc;
	reliable if (bNetDirty && !bGoToTargetLoc && !bReturning)
		TargetPawn;
}

simulated function Destroyed()
{
	super.Destroyed();

	if ( LifeLine != None )
	{
		LifeLine.DeployedMines--;
	}
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if (Role < ROLE_Authority && Physics == PHYS_None)
	{
		bProjTarget = true;
		GotoState('OnGround');
	}

	PlayAnim('Wakeup', 1.0);
}

function Init(vector Direction)
{
	//Super.Init(Direction);
	// From UT3 class 'Projectile'.Init:
	SetRotation(Rotator(Direction));
	Velocity = Speed * Direction;

	SetRotation(Rotation + rot(16384,0,0));
}

simulated event TornOff()
{
	if (bReturnedToTrap)
	{
		//bSuppressExplosionFX = true;
	}
	Destroy();
}

simulated function ProcessTouch(Actor Other, Vector HitNormal)
{
	ImpactedActor = Other;
	if (UT3SpiderMine(Other) != None)
	{
		if ( Other.Instigator != Instigator )
			Explode(Location, HitNormal);
		else if (Physics == PHYS_Falling)
			Velocity = vect(0,0,200) + 150 * VRand();
	}
	else if (Pawn(Other) != None)
	{
		if ( Other != Instigator && !OnSameTeam(Other) )
			Explode(Location, HitNormal);
	}
	else if (Other.bCanBeDamaged && Other.Base != self)
		Explode(Location, HitNormal);

	ImpactedActor = None;
}

simulated function AdjustSpeed()
{
	ScurrySpeed = default.ScurrySpeed / (Attached.length + 1);
	ScurryAnimRate = default.ScurryAnimRate / (Attached.length + 1);
}

simulated function Attach(Actor Other)
{
	AdjustSpeed();
}

simulated function Detach(Actor Other)
{
	AdjustSpeed();
}

function AcquireTarget()
{
	local Pawn A;
	local float Dist, BestDist;

	TargetPawn = None;

	foreach VisibleCollidingActors(class'Pawn', A, DetectionRange)
	{
		if ( A != Instigator && A.Health > 0 && !OnSameTeam(A) //&& !A.IsA('UTVehicle_DarkWalker')
		 && (Vehicle(A) == None || Vehicle(A).Driver != None || Vehicle(A).bTeamLocked) )
		{
			Dist = VSize(A.Location - Location);
			if (TargetPawn == None || Dist < BestDist)
			{
				TargetPawn = A;
				BestDist = Dist;
			}
		}
	}

	WarnTarget();
}

function WarnTarget()
{
	if (TargetPawn != None && TargetPawn.Controller != None)
	{
		TargetPawn.Controller.ReceiveProjectileWarning(self);

		if (AIController(TargetPawn.Controller) != None && AIController(TargetPawn.Controller).Skill >= 3.0 + 2*FRand() && !TargetPawn.IsFiring())
		{
			TargetPawn.Controller.Focus = self;
			TargetPawn.Controller.FireWeaponAt(self);
		}
	}
}

event TakeDamage(int DamageAmount, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType)
{
	if (DamageAmount > 0 && !OnSameTeam(EventInstigator))
		Explode(Location, Normal(Momentum));
}

simulated function PhysicsVolumeChange(PhysicsVolume NewVolume)
{
	//local UTSlowVolume SlowVolume;

	if (NewVolume.bPainCausing)
	{
		Explode(Location, vector(Rotation));
	}
	// No Slow Volumes yet.
	/*else
	{
		// check if left slow volume
		SlowVolume = UTSlowVolume(PhysicsVolume);
		if (SlowVolume != None)
		{
			ScurrySpeed /= SlowVolume.ScalingFactor;
			ScurryAnimRate /= SlowVolume.ScalingFactor;
		}

		// check if entered slow volume
		SlowVolume = UTSlowVolume(NewVolume);
		if (SlowVolume != None)
		{
			ScurrySpeed *= SlowVolume.ScalingFactor;
			ScurryAnimRate *= SlowVolume.ScalingFactor;
		}
	}*/
}

auto state Flying
{
	simulated event Landed( vector HitNormal )
	{
		local rotator NewRot;

		bProjTarget = True;

		NewRot = rotator(HitNormal);
		NewRot.Pitch -= 16384;
		SetRotation(NewRot);

		//GotoState((TargetPawn != None) ? 'Scurrying' : 'OnGround');
		if (TargetPawn != None)
			GotoState('Scurrying');
		else
			GotoState('OnGround');
	}

	simulated event HitWall( vector HitNormal, Actor Wall )
	{
		if ( Instigator != None && Pawn(Wall) != None )
		{
			if (!OnSameTeam(Wall))
			{
				ImpactedActor = Wall;
				Explode(Location, HitNormal);
				ImpactedActor = None;
			}
		}
		Velocity = 0.8 * (Velocity - 2.0 * HitNormal * (Velocity dot HitNormal));
		if ( HitNormal.Z > MinSpiderFloorZ )
		{
			Landed(HitNormal);
		}
	}

	simulated function BeginState()
	{
		SetPhysics(PHYS_Falling);
		Lifespan = 6.0;
	}

	simulated function EndState()
	{
		Lifespan = 0.0;
	}
}

simulated state OnGround
{
	ignores Landed, HitWall;

	simulated function Timer()
	{
		if (Role < ROLE_Authority)
		{
			if (TargetPawn != None)
			{
				GotoState('Scurrying');
			}
			else if (bGoToTargetLoc)
			{
				GotoState('ScurryToTargetLoc');
			}
			else if (bReturning)
			{
				GotoState('Returning');
			}

			return;
		}

		// Die if no lifeline.
		if (Lifeline == None || Lifeline.bDeleteMe)
			Explode(Location, vector(Rotation));

		AcquireTarget();

		if (TargetPawn != None)
			GotoState('Scurrying');
	}

	/** returns the spider mine to its trap, if it has one */
	function ReturnToTrap()
	{
		if (Lifeline == None || Lifeline.bDeleteMe)
			Explode(Location, vector(Rotation));
		else
			GotoState('Returning');
	}

	function bool SetScurryTarget(vector NewTargetLoc, Pawn NewInstigator)
	{
		local bool bResult;

		bResult = Global.SetScurryTarget(NewTargetLoc, NewInstigator);
		//if (bResult && IsTimerActive('ReturnToTrap'))
		if (bResult && !ReturnToTrapEnabled)
		{
			ReturnToTrapTime = Level.TimeSeconds;
			ReturnToTrapEnabled = true;
		}

		return bResult;
	}

	simulated function BeginState()
	{
		if (Role == ROLE_Authority && Lifeline != None)
		{
			ReturnToTrapTime = Level.TimeSeconds;
			ReturnToTrapEnabled = true;
		}
		SetPhysics(PHYS_None);
		Velocity = vect(0,0,0);
		SetTimer(DetectionTimer, True);
		Timer();
		LifeSpan = 2 * ReturnToTrapDelay;
	}

	simulated function EndState()
	{
		SetTimer(0, False);
		ReturnToTrapEnabled = false;
		LifeSpan = 0.0;
	}

	function Tick(float DeltaTime)
	{
		if (ReturnToTrapEnabled && DeltaTime - ReturnToTrapTime >= ReturnToTrapDelay)
		{
			ReturnToTrapEnabled = false;
			ReturnToTrap();
		}
	}

Begin:
	Sleep(0.4);
	LoopAnim('Sleep_Idle',1.0);
	bClosedDown = true;
}

simulated state Scurrying
{
	simulated function Timer()
	{
		local vector NewLoc;
		local rotator TargetDirection;
		local float TargetDist;

		if (TargetPawn == None || TargetPawn.bDeleteMe)
		{
			TargetPawn = None;
			GotoState('Flying');
		}
		else if (Physics == PHYS_Walking)
		{
			NewLoc = TargetPawn.Location - Location;
			TargetDist = VSize(NewLoc);

			if (TargetDist < DetectionRange + KeepTargetExtraRange)
			{
				NewLoc.Z = 0.f;
				Velocity = Normal(NewLoc) * ScurrySpeed;
				if (TargetDist < 225.0)
				{
					GotoState('Flying');
					Velocity *= 1.2;
					Velocity.Z = 350;

					//Play a nice screeching sound (not in WarnTarget because its meant only for on the 'jump')
					PlaySound(AttackScreechSnd[Rand(4) - 1], SLOT_None, 1.0);

					WarnTarget();
				}
				else
				{
					TargetDirection = Rotator(NewLoc);
					TargetDirection.Yaw -= 16384;
					TargetDirection.Roll = 0;
					SetRotation(TargetDirection);
					LoopAnim('RunFwd', ScurryAnimRate);
				}
			}
			else
			{
				TargetPawn = None;
				GotoState('Flying');
			}
		}
	}

	simulated event Landed(vector HitNormal)
	{
		SetPhysics(PHYS_Walking);
		//SetBase(FloorActor);
		// FloorActor is the actor it hited.
	}

	function BeginState()
	{
		WarnTarget();
	}

	simulated function EndState()
	{
		SetTimer(0.0, False);
		AmbientSound = none;
	}

Begin:
	SetPhysics(PHYS_Walking);
	if (bClosedDown)
	{
		PlayAnim('Wakeup', 1.0);
		bClosedDown = false;
		Sleep(0.25);
	}
	AmbientSound = WalkingSnd[Rand(4) - 1];
	SetTimer(DetectionTimer * 0.5, true);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	local int i;

	//make sure anything attached gets blown up too
	for (i = 0; i < Attached.length; i++)
	{
		Attached[i].TakeDamage(Damage, InstigatorController.Pawn, Attached[i].Location, vect(0,0,0), MyDamageType);
	}

	//Super.Explode(HitLocation, HitNormal);
	// From UT:'Projectile'.Explode:
	if (Damage > 0 && DamageRadius > 0)
	{
		if ( Role == ROLE_Authority )
		{
			MakeNoise(1.0);
			PlaySound(ExplosionSnd[Rand(4) - 1], SLOT_None, 1.0);
		}
		HurtRadius(Damage, DamageRadius, MyDamageType, MomentumTransfer, HitLocation);
	}
	Destroy();
}

/** NewInstigator is asking the mine to go to NewTargetLoc
 * @return whether the mine will follow the request
 */
function bool SetScurryTarget(vector NewTargetLoc, Pawn NewInstigator)
{
	local bool bCanControl;

	if (TargetPawn == None)
	{
		//bCanControl = Level.GRI.bTeamGame ? OnSameTeam(NewInstigator) : (InstigatorController == NewInstigator.Controller);
		if (Level.GRI.bTeamGame)
			bCanControl = OnSameTeam(NewInstigator);
		else
			bCanControl = InstigatorController == NewInstigator.Controller;
		if ( bCanControl && NewInstigator.Health > 0 && (FastTrace(NewTargetLoc, Location + vect(0,0,32)) || FastTrace(NewTargetLoc + vect(0,0,32), Location + vect(0,0,32))))
		{
			// give this player control of the mine
			Instigator = NewInstigator;
			InstigatorController = Instigator.Controller;

			if (VSize(NewTargetLoc - Location) > TargetLocFuzz)
			{
				TargetLoc = NewTargetLoc + VRand() * Rand(TargetLocFuzz);
				bGoToTargetLoc = true;
				GotoState('ScurryToTargetLoc');
			}
			return true;
		}
	}

	return false;
}

simulated state ScurryToTargetLoc extends Scurrying
{
	function bool SetScurryTarget(vector NewTargetLoc, Pawn NewInstigator)
	{
		if (Instigator == NewInstigator)
		{
			TargetLoc = NewTargetLoc + VRand() * Rand(TargetLocFuzz);
			return true;
		}
		else
		{
			return false;
		}
	}

	simulated function Timer()
	{
		local vector NewLoc;
		local rotator TargetDirection;

		if (Physics == PHYS_Walking)
		{
			NewLoc = TargetLoc - Location;
			NewLoc.Z = 0;
			if (VSize(NewLoc) < 250.f)
			{
				AcquireTarget();
				if (TargetPawn != None)
				{
					GotoState('Scurrying');
				}
				else
				{
					GotoState('Flying');
				}
			}
			else
			{
				Velocity = Normal(NewLoc) * ScurrySpeed;
				TargetDirection = rotator(NewLoc);
				TargetDirection.Yaw -= 16384;
				TargetDirection.Roll = 0;
				SetRotation(TargetDirection);
				LoopAnim('RunFwd', ScurryAnimRate);
			}
		}
	}

	simulated function EndState()
	{
		SetTimer(0.0, False);
		AmbientSound = none;
		bGoToTargetLoc = false;
	}
}

simulated function bool OnSameTeam(Actor Other)
{
	if (Instigator == Other)
		return true;
	else if (!Level.GRI.bTeamGame)
		return false;
	else if (Level.GRI.bTeamGame)
		return Instigator.Controller.PlayerReplicationInfo.Team.TeamIndex == Pawn(Other).Controller.PlayerReplicationInfo.Team.TeamIndex;
}

simulated singular event HitWall(vector HitNormal, actor Wall)
{
	if ( (Pawn(Wall) != None) && !OnSameTeam(Wall) )
	{
		ImpactedActor = Wall;
		Explode(Location, HitNormal);
		ImpactedActor = None;
		return;
	}
	if ( HitNormal.Z > MinSpiderFloorZ )
	{
		SetPhysics(PHYS_Walking);
		SetBase(Wall);
		return;
	}
	if ( Physics == PHYS_Falling )
	{
		Velocity = 0.8 * (Velocity - 2.0 * HitNormal * (Velocity dot HitNormal));
	}
	//LifeSpan = (LifeSpan == 0.0) ? 5.0 : FMin(LifeSpan, 5.0);
	if (LifeSpan == 0.0)
		LifeSpan = 5.0;
	else
		LifeSpan = FMin(LifeSpan, 5.0);
	SetPhysics(PHYS_Falling);
	Velocity.Z = 300.0;
}

simulated state Returning extends Scurrying
{
	event Bump(Actor Other)
	{
		if (Other == Lifeline)
		{
			Lifeline.AvailableMines++;
			// destroy delayed (give time to replicate) and without explosion
			bReturnedToTrap = true;
			//bWaitForEffects = true;
			ShutDown();
			LifeSpan = 1.0;
		}
	}

	simulated function Timer()
	{
		local vector NewLoc;
		local rotator TargetDirection;
		local float Dist;

		if (Physics == PHYS_Walking)
		{
			if (Role == ROLE_Authority && (Lifeline == None || Lifeline.bDeleteMe))
			{
				Explode(Location, vector(Rotation));
			}
			else
			{
				if (Role == ROLE_Authority && TargetLoc != Lifeline.Location)
				{
					TargetLoc = Lifeline.Location;
				}

				NewLoc = TargetLoc - Location;
				NewLoc.Z = 0;
				Dist = VSize(NewLoc);
				if ( Dist <= 24.0 )
				{
					if (Role == ROLE_Authority)
					{
						Bump(Lifeline);
					}
				}
				else
				{

					if ( Dist < 200.0 )
					{
						Velocity = Normal(NewLoc) * 0.5*ScurrySpeed;
						if ( FRand() < 0.15 )
						{
							SetTimer(DetectionTimer * 0.25, true);
						}
					}
					else
					{
						Velocity = Normal(NewLoc) * ScurrySpeed;
					}
					TargetDirection = rotator(NewLoc);
					TargetDirection.Yaw -= 16384;
					TargetDirection.Roll = 0;
					SetRotation(TargetDirection);
					LoopAnim('RunFwd', ScurryAnimRate);
				}
			}
		}
	}

	simulated function BeginState()
	{
		//Super.BeginState(PrevStateName);

		LifeSpan = 10.0;
		if (Role == ROLE_Authority)
		{
			bReturning = true;
			TargetLoc = Lifeline.Location;
		}
	}

	simulated function EndState()
	{
		LifeSpan = 0.0;
		SetTimer(0.0, false);
		bReturning = false;
	}
}

// YEY!
simulated event ShutDown()
{
	// Shut down physics
	SetPhysics(PHYS_None);
	// shut down collision
	SetCollision(false, false);
	/*if (CollisionComponent != None)
	{
		CollisionComponent.SetBlockRigidBody(false);
	}*/

	// shut down rendering
	//SetHidden(true);
	bHidden = true;
	// ignore if in a non rendered zone
	bStasis = true;

	// we can't set bTearOff here as that will prevent newly joining clients from receiving the state changes
	// so we just set a really low NetUpdateFrequency
	NetUpdateFrequency = 0.1;
}

defaultproperties
{
	MinSpiderFloorZ=0.1
	Speed=800.0
	MaxSpeed=800.0
	ScurrySpeed=525.0
	ScurryAnimRate=1.0
	TossZ=0.0
	Damage=95.0
	DamageRadius=250.0
	MomentumTransfer=50000
	Physics=PHYS_Falling
	RotationRate=(Pitch=20000)
	DetectionTimer=0.50
	DetectionRange=750.0
	KeepTargetExtraRange=250.0
	bProjTarget=true
	bCollideWorld=True
	bBlockActors=true

	RemoteRole=ROLE_SimulatedProxy
	bNetTemporary=False
	bUpdateSimulatedPosition=True
	LifeSpan=0.0
	TargetLocFuzz=250
	ReturnToTrapDelay=5.0
	bSwitchToZeroCollision=false

	bBounce=True
	bHardAttach=True

	Mesh=SkeletalMesh'UT3NightshadeAnims.Spider_1P';
	CollisionRadius=10.000000
	CollisionHeight=10.000000
	bBlockKarma=True

	// Sound.
	ExplosionSnd(0) = Sound'Spider_Explode01';
	ExplosionSnd(1) = Sound'Spider_Explode02';
	ExplosionSnd(2) = Sound'Spider_Explode03';
	AttackScreechSnd(0) = Sound'Spider_Attack01';
	AttackScreechSnd(1) = Sound'Spider_Attack02';
	AttackScreechSnd(2) = Sound'Spider_Attack03';
	WalkingSnd(0) = Sound'Spider_Walk01';
	WalkingSnd(1) = Sound'Spider_Walk02';
	WalkingSnd(2) = Sound'Spider_Walk03';
}
