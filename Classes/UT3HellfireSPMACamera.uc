/******************************************************************************
UT3HellfireSPMACamera

Creation date: 2009-02-12 22:53
Last change: $Id$
Copyright (c) 2009, Wormbo
******************************************************************************/

class UT3HellfireSPMACamera extends ONSMortarCamera;


/** Camera view offset scale. Interpolated to 0 while deploying. */
var float CVScale;

/** Maximum target trace range from camera. */
var float MaxTargetRange;

var Sound DeploySound, DeployedAmbientSound;

var bool bTargetOutOfRange;

/** Player's aiming target location. */
var vector TargetLocation, TargetNormal;

var float NextAIDeployCheck;


var UT3HellfireSPMATrajectory Trajectory;


function BeginPlay()
{
	// set up deploy check/message
	NextAIDeployCheck = Level.TimeSeconds + 1;
	SetTimer(0.25, false);
}

simulated function Destroyed()
{
	if (Trajectory != None)
		Trajectory.Destroy();
	
	Super.Destroyed();
}


// unused by camera
function StartTimer(float Fuse);

// send deployment hint
function Timer()
{
	if (Instigator != None && PlayerController(Instigator.Controller) != None && PlayerController(Instigator.Controller).ViewTarget == Self) {
		PlayerController(Instigator.Controller).ReceiveLocalizedMessage(class'ONSOnslaughtMessage', 34);
	}
}

function bool IsStationary()
{
	return bDeployed;
}

function Deploy()
{
	AnnounceTargetTime = Level.TimeSeconds + 1.5;
	DeployCamera();
}


simulated function DeployCamera()
{
	if (bShotDown) {
		// can't deploy if already disconnected
		return;
	}
	bDeployed = True;
	Velocity = vect(0,0,0);
	SetPhysics(PHYS_Projectile);
	bOrientToVelocity = False;
	DesiredRotation = rot(-16384,0,0);
	RotationRate = rot(16384,16384,16384);
	bRotateToDesired = True;
	PlaySound(DeploySound);
	AmbientSound = DeployedAmbientSound;
	PlayAnim('Deploy', 1.0, 0.0);
	if (Trajectory == None)
		Trajectory = Spawn(class'UT3HellfireSPMATrajectory', Self, '', Location);
}


simulated event EndedRotation()
{
	bRotateToDesired = False;
	RotationRate = rot(0,0,0);
}


simulated function Tick(float DeltaTime)
{
	local vector HitLocation, HitNormal;
	
	if (bShotDown || UT3HellfireSPMA(Instigator) == None || UT3HellfireSPMA(Instigator).Driver == None) {
		if (!bShotDown)
			ShotDown();
		Disable('Tick');
		return;
	}
	
	if (!bDeployed) {
		TargetLocation = Location;
	}
	else {
		if (CVScale > 0) {
			CVScale -= DeltaTime * 0.8;
			if (CVScale <= 0)
				CVScale = 0;
			if (CVScale < 0.25 && !bOwnerNoSee)
				bOwnerNoSee = true;
		}
		if (Instigator.IsLocallyControlled() && Instigator.IsHumanControlled()) {
			if (Trace(HitLocation, HitNormal, Location + vector(Instigator.Controller.Rotation) * MaxTargetRange,, True) == None) {
				HitLocation = Location + vector(Instigator.Controller.Rotation) * MaxTargetRange;
				HitNormal = vect(0,0,1);
			}
			else {
				HitLocation += HitNormal * 50.0;
			}
			UpdateTargetLocation(HitLocation, HitNormal);
			UT3HellfireSPMACannon(Owner).PredictTarget();
			
			if (Trajectory != None) {
				if (UT3HellfireSPMACannon(Owner).bCanHitTarget && UT3HellfireSPMACannon(Owner).FireCountdown <= 0 && vector(UT3HellfireSPMACannon(Owner).WeaponFireRotation) dot vector(UT3HellfireSPMACannon(Owner).TargetRotation) > 0.99)
					Trajectory.UpdateTrajectory(True, UT3HellfireSPMACannon(Owner).WeaponFireLocation, vector(UT3HellfireSPMACannon(Owner).WeaponFireRotation) * Lerp(UT3HellfireSPMACannon(Owner).WeaponCharge, UT3HellfireSPMACannon(Owner).MinSpeed, UT3HellfireSPMACannon(Owner).MaxSpeed), -PhysicsVolume.Gravity.Z, Region.Zone.KillZ);
				else
					Trajectory.UpdateTrajectory(False);
			}
		}
	}
	
	if (Role < ROLE_Authority)
		return;
	// following code is serverside-only
	
	if (!bDeployed) {
		if (Instigator != None && AIController(Instigator.Controller) != None && NextAIDeployCheck <= Level.TimeSeconds) {
			if (Instigator.Controller.Target != None && FastTrace(Instigator.Controller.Target.Location)) {
				Deploy();
			}
			else {
				NextAIDeployCheck = Level.TimeSeconds + 0.1;
			}
		}
	}
	else if (Level.TimeSeconds > AnnounceTargetTime) {
		AnnounceTargetTime = Level.TimeSeconds + 1.5;
		ShowSelf(True);
	}
}


// obsolete
function SetTarget(vector loc);

simulated function UpdateTargetLocation(vector NewTargetLocation, vector NewTargetNormal)
{
	local vector X, Y;
	
	TargetLocation = NewTargetLocation;
	TargetNormal   = NewTargetNormal;
	
	if (TargetBeam == None) {
		TargetBeam = Spawn(class'UT3HellfireSPMATargetReticle', self,, Location, rot(0,0,0));
		TargetBeam.ArtilleryLocation = Instigator.Location;
	}
	if (TargetBeam != None) {
		TargetBeam.SetLocation(TargetLocation);
		
		// reticle StaticMesh uses TargetNormal as Z direction
		Y = Normal(TargetNormal Cross (TargetLocation - Instigator.Location));
		X = -(TargetNormal Cross Y);
		TargetBeam.SetRotation(OrthoRotation(X, Y, TargetNormal));
	}
}


/**
Reveal the camera to enemy bots, giving them a chance to target it.
*/
function ShowSelf(bool bCheckFOV)
{
	local Controller C;
	local Bot B;
	
	if (!bShotDown) {
		for (C = Level.ControllerList; C != None; C = C.NextController) {
			B = Bot(C);
			if (B != None && !B.SameTeamAs(Instigator.Controller) && B.Pawn != None && !B.Pawn.IsFiring() && (B.Enemy == None || B.Enemy == Instigator || B.Skill > 2.0 + 2.0 * FRand() && !B.EnemyVisible()) && (!bCheckFOV || Normal(B.FocalPoint - B.Pawn.Location) dot (Location - B.Pawn.Location) > B.Pawn.PeripheralVision) && B.LineOfSightTo(self)) {
				// give B a chance to shoot at me
				B.GoalString = "Destroy Mortar Camera";
				B.Target = self;
				B.SwitchToBestWeapon();
				if (B.Pawn.CanAttack(self)) {
					B.DoRangedAttackOn(self);
					if (FRand() < 0.5)
						break;
				}
			}
		}
	}
}

// non-tick part of UT3 CalcCamera()
simulated function bool SpecialCalcView(out Actor ViewActor, out vector CameraLocation, out rotator CameraRotation, bool bBehindView)
{
	local vector HitNormal, HitLocation;
	
	ViewActor = Self;
	
	CameraLocation = Location + ((MortarCameraOffset * CVScale) >> CameraRotation);
	if (Trace(HitLocation, HitNormal, CameraLocation, Location, false, vect(12,12,12)) != None)
		CameraLocation = HitLocation;
	
	return True;
}


simulated function ShotDown()
{
	if (Instigator != None && PlayerController(Instigator.Controller) != None && PlayerController(Instigator.Controller).ViewTarget == Self) {
		if (Instigator.Controller.Pawn != None) {
			PlayerController(Instigator.Controller).bBehindView = Instigator.Controller.Pawn.PointOfView();
			PlayerController(Instigator.Controller).SetViewTarget(Instigator.Controller.Pawn);
		}
		else {
			PlayerController(Instigator.Controller).bBehindView = False;
			PlayerController(Instigator.Controller).SetViewTarget(Instigator.Controller);
		}
	}
	
	if (TargetBeam != None)
		TargetBeam.Destroy();
	
	if (Trajectory != None)
		Trajectory.Destroy();
	
	Super.ShotDown();
	bShotDown = True;
}


/**
Slightly modified verion of ONSMortarCamera::PostNetReceive() to account for
bDeployed reverting to False when shot down or manually disconnected.
*/
simulated function PostNetReceive()
{
	Super(ONSMortarShell).PostNetReceive();
	
	if (bDeployed != bLastDeployed) {
		bLastDeployed = bDeployed;
		if (bDeployed)
			DeployCamera();
	}
	
	if (bShotDown != bLastShotDown) {
		bLastShotDown = bShotDown;
		if (bShotDown)
			ShotDown();
	}
	
	if (RealLocation != LastRealLocation) {
		SetLocation(RealLocation);
		LastRealLocation = RealLocation;
	}
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
	MortarCameraOffset = (X=-256.0,Z=128.0)
	CVScale = 1.0
	MaxTargetRange = 10240.0
	Speed = 4000.0
	
	ImpactSound       = Sound'SPMAShellFragmentExplode'
	bOrientToVelocity = True
	bAlwaysRelevant   = True
	TransientSoundRadius = 500.0
}
