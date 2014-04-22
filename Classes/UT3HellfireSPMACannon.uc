/******************************************************************************
UT3HellfireSPMACannon

Creation date: 2009-02-09 16:18
Latest change: $Id$
Copyright (c) 2009, Wormbo
******************************************************************************/

class UT3HellfireSPMACannon extends ONSArtilleryCannon;


var Sound DistantFireSound, ReadyToFireSound;
var color TrajectoryLineColor;

/**
Last time CanAttack() returned a positive result.
Used to undeploy if no targets for bots.
*/
var float LastCanAttackTime;

var rotator TargetRotation;

var bool bCanFire;


/**
Filter fire attempts so player needs to launch and deploy a camera first.
*/
event bool AttemptFire(Controller C, bool bAltFire)
{
	if (MortarCamera == None || MortarCamera.bShotDown) {
		// always fire camera first
		return Super(ONSWeapon).AttemptFire(C, True);
	}
	else if (!bAltFire && MortarCamera.bDeployed) {
		// fire shell if camera is deployed
		return Super(ONSWeapon).AttemptFire(C, False);
	}
}


function Tick(float DeltaTime)
{
	if (!bCanFire && FireCountdown <= 0) {
		bCanFire = True;
		if (Instigator != None && PlayerController(Instigator.Controller) != None)
			PlayerController(Instigator.Controller).ClientPlaySound(ReadyToFireSound, true, 0.5);
	}
	else if (bCanFire && FireCountdown > AltFireInterval) {
		bCanFire = False;
	}
}


/**
Returns whether the target offset is reachable, assuming clear shot.
Outputs the fire rotation that will get the shot to the desired target area.
*/
simulated function bool GetFireDirection(vector TargetLocation, out rotator FireRotation, out float FireSpeedFactor)
{
	local float dxy, dz, g;
	local float vXY, vZ, bestV, thisV;
	local float bestVXY, bestVZ;
	local vector /*PitchBoneOrigin, YawBoneOrigin, FireOffset,*/ TargetDirection;
	
	/* FIXME: predict WeaponFireLocation for target direction
	// approximate fire start for target direction
	YawBoneOrigin = GetBoneCoords(YawBone).Origin;
	FireOffset = WeaponFireLocation - YawBoneOrigin;
	FireOffset = (FireOffset >> rot(0,-1,0) * WeaponFireRotation.Yaw) >> rot(0,1,0) * rotator(TargetLocation - YawBoneOrigin).Yaw;
	*/
	TargetDirection = TargetLocation - WeaponFireLocation;
	g = Instigator.PhysicsVolume.Gravity.Z;
	dz = TargetDirection.Z;
	TargetDirection.Z = 0;
	dxy = VSize(TargetDirection);
	
	bestVXY = MinSpeed;
	bestVZ = dz * bestVXY / dxy - 0.5 * g * dxy / bestVXY;
	bestV  = Sqrt(Square(bestVXY) + Square(bestVZ));
	
	for (vXY = bestVXY + 200; vXY <= MaxSpeed; vXY += 200) {
		vZ = dz * vXY / dxy - 0.5 * g * dxy / vXY;
		thisV = Sqrt(Square(vXY) + Square(vZ));
		if (thisV < bestV) {
			bestVXY = vXY;
			bestVZ = vZ;
			bestV  = thisV;
		}
	}
	
	TargetDirection = Normal(TargetDirection) * bestVXY;
	TargetDirection.Z = bestVZ;
	FireRotation = rotator(TargetDirection);
	FireSpeedFactor = FClamp((bestV - MinSpeed) / (MaxSpeed - MinSpeed), 0.0, 1.0);
	
	return bestV <= MaxSpeed;
}


simulated function bool TestTrajectory(vector TargetLocation, rotator FireRotation, bool bTraceToGround, optional out vector HitLocation)
{
	local vector x0, v0, gHalf, LastLoc, NextLoc;
	local float tMax, t;
	local vector HitNormal;
	
	x0 = WeaponFireLocation; //GetBoneCoords(PitchBone).Origin;
	v0 = Lerp(WeaponCharge, MinSpeed, MaxSpeed) * vector(FireRotation);
	gHalf = 0.5 * Instigator.PhysicsVolume.Gravity;
	tMax = VSize((TargetLocation - x0) * vect(1,1,0)) / VSize(v0 * vect(1,1,0));
	
	LastLoc = x0;
	for (t = TargetPredictionTimeStep; LastLoc.Z > Level.KillZ && (bTraceToGround || t < tMax); t += TargetPredictionTimeStep) {
		NextLoc = x0 + v0 * t + gHalf * Square(t);
		if (Trace(HitLocation, HitNormal, NextLoc, LastLoc, true, vect(0,0,0)) != None)
			return VSize(HitLocation - TargetLocation) < FMax(100.0, 0.001 * VSize(x0 - TargetLocation));
		
		LastLoc = NextLoc;
	}
	if (t > tMax) {
		if (Trace(HitLocation, HitNormal, TargetLocation, LastLoc, true, vect(0,0,0)) == None)
			HitLocation = TargetLocation;
	}
	else {
		HitLocation = LastLoc;
	}
	return true;
}


simulated function PredictTarget()
{
	local float Vel2D, Dist2D, NewWeaponCharge;
	
	if (UT3HellfireSPMACamera(MortarCamera) == None || !MortarCamera.bDeployed || AIController(Instigator.Controller) != None)
		return;
	
	CalcWeaponFire();
	if (Instigator.IsLocallyControlled()) {
		PredictedTargetLocation = UT3HellfireSPMACamera(MortarCamera).TargetLocation;
		bCanHitTarget = GetFireDirection(PredictedTargetLocation, TargetRotation, NewWeaponCharge);
		SetWeaponCharge(NewWeaponCharge);
		if (bCanHitTarget || UT3HellfireSPMACamera(MortarCamera).bTargetOutOfRange) {
			bCanHitTarget = TestTrajectory(PredictedTargetLocation, TargetRotation, UT3HellfireSPMACamera(MortarCamera).bTargetOutOfRange, PredictedTargetLocation) && bCanHitTarget;
		}
		MortarCamera.SetReticleStatus(bCanHitTarget);
		Vel2D = VSize(vector(TargetRotation) * vect(1,1,0)) * Lerp(WeaponCharge, MinSpeed, MaxSpeed);
		Dist2D = VSize((PredictedTargetLocation - WeaponFireLocation) * vect(1,1,0));
		PredicatedTimeToImpact = Dist2D / Vel2D;
	}
	else {
		// predict target location based on fire parameters send by client
		PredictTargetLocation(Lerp(WeaponCharge, MinSpeed, MaxSpeed), vector(UT3HellfireSPMA(Instigator).CustomAim));
	}
}


function PredictTargetLocation(float Speed, vector Direction)
{
	local vector x0, v0, gHalf, LastLoc, NextLoc;
	local float t, Vel2D, Dist2D;
	local vector HitNormal;
	
	x0 = WeaponFireLocation;
	v0 = Speed * Direction;
	gHalf = 0.5 * Instigator.PhysicsVolume.Gravity;
	
	LastLoc = x0;
	for (t = TargetPredictionTimeStep; LastLoc.Z > Level.KillZ; t += TargetPredictionTimeStep) {
		NextLoc = x0 + v0 * t + gHalf * Square(t);
		if (Trace(LastLoc, HitNormal, NextLoc, LastLoc, true, vect(0,0,0)) != None)
			break;
		
		LastLoc = NextLoc;
	}
	// LastLoc now is the impact location
	
	PredictedTargetLocation = LastLoc;
	Vel2D = VSize(v0 * vect(1,1,0));
	Dist2D = VSize((PredictedTargetLocation - x0) * vect(1,1,0));
	PredicatedTimeToImpact = Dist2D / Vel2D;
}


function bool CanAttack(Actor Other)
{
	local Bot B;
	local bool bResult;
	local rotator FireRotation;
	
	if (Instigator == None || Other == None)
		return false;
	
	B = Bot(Instigator.Controller);
	if (B != None && Level.TimeSeconds - UT3HellfireSPMA(Instigator).StartDrivingTime < 1)
		return false;
	
	if (!Other.IsStationary() && (VSize(Other.Velocity) > 1000 || Pawn(Other) != None && Pawn(Other).GroundSpeed > 1000))
		return false; // too fast, could probably attack but likely wouldn't hit
	
	CalcWeaponFire();
	bResult = GetFireDirection(Other.Location, FireRotation, WeaponCharge); // can assign WeaponCharge directly for bots
	if (bResult && MortarCamera != None) {
		// make sure can really see enemy via camera...
		if (!FastTrace(Other.Location, MortarCamera.Location))
			bResult = False;
		// ...and shot trajectory is not obstructed
		else if (!TestTrajectory(Other.Location, FireRotation, false))
			bResult = False;
	}
	
	if (bResult) {
		UT3HellfireSPMA(Instigator).CannonAim = FireRotation;
		LastCanAttackTime = Level.TimeSeconds;
	}
	else if (Level.TimeSeconds - LastCanAttackTime > 5.0 && B != None && !B.Squad.IsDefending(B) && UT3HellfireSPMA(Instigator).IsDeployed()) {
		// no good targets and bot doesn't defend, undeploy
		UT3HellfireSPMA(Instigator).bBotDeploy = True;
	}
	return bResult;
}


function byte BestMode()
{
	return 0;
}


function AllowCameraLaunch()
{
	Super.AllowCameraLaunch();
	
	if (Instigator != None && PlayerController(Instigator.Controller) != None && PlayerController(Instigator.Controller).ViewTarget == MortarCamera) {
		PlayerController(Instigator.Controller).SetViewTarget(Instigator);
	}
	MortarCamera = None;
}


simulated event OwnerEffects()
{
	if (UT3HellfireSPMA(Instigator).DeployState != DS_Deployed || MortarCamera != None && (bIsAltFire || !MortarCamera.bDeployed && !MortarCamera.bShotDown))
		return; // no owner effects, just deploying/disconnecting the camera
	
	if (MortarCamera == None)
		bIsAltFire = True; // no camera, always alt fire
	
	if (!bIsRepeatingFF) {
		if (bIsAltFire)
			ClientPlayForceFeedback(AltFireForce);
		else
			ClientPlayForceFeedback(FireForce);
	}
	ShakeView();
	
	if (Role < ROLE_Authority) {
		if (bIsAltFire)
			FireCountdown = AltFireInterval;
		else
			FireCountdown = FireInterval;
		
		AimLockReleaseTime = Level.TimeSeconds + FireCountdown * FireIntervalAimLock;
		
		FlashMuzzleFlash();
		
		if (AmbientEffectEmitter != None)
			AmbientEffectEmitter.SetEmitterStatus(true);
		
		// Play firing noise
		if (!bAmbientFireSound) {
			if (bIsAltFire)
				PlaySound(AltFireSoundClass, SLOT_None, FireSoundVolume/255.0,, AltFireSoundRadius,, false);
			else
				PlaySound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius,, true); // primary fire always heard from camera!
		}
	}
}


function Projectile SpawnProjectile(class<Projectile> ProjClass, bool bAltFire)
{
	local Projectile P;
	local vector StartLocation, HitLocation, HitNormal, Extent, TargetLoc;
	local ONSIncomingShellSound ShellSoundMarker;
	local Controller C;
	local bool bFailed;
	
	for (C = Level.ControllerList; C != None; C = C.nextController) {
		if (PlayerController(C) != None)
			PlayerController(C).ClientPlaySound(Sound'DistantBooms.DistantSPMA', true, 1);
	}
	if (AIController(Instigator.Controller) != None) {
		if (Instigator.Controller.Target == None) {
			if ( Instigator.Controller.Enemy != None )
				TargetLoc = Instigator.Controller.Enemy.Location;
			else
				TargetLoc = Instigator.Controller.FocalPoint;
		}
		else
			TargetLoc = Instigator.Controller.Target.Location;
		
		if (!bAltFire && ((MortarCamera == None) || MortarCamera.bShotDown)
			&& ((VSize(TargetLoc - WeaponFireLocation) > 4000) || !Instigator.Controller.LineOfSightTo(Instigator.Controller.Target)) )
		{
			ProjClass = AltFireProjectileClass;
			bAltFire = true;
		}
	}
	else if (!Instigator.IsLocallyControlled())
		PredictTarget();
	
	if (bDoOffsetTrace) {
		Extent = ProjClass.default.CollisionRadius * vect(1,1,0);
		Extent.Z = ProjClass.default.CollisionHeight;
		if (!Owner.TraceThisActor(HitLocation, HitNormal, WeaponFireLocation, WeaponFireLocation + vector(WeaponFireRotation) * (Owner.CollisionRadius * 1.5), Extent))
			StartLocation = HitLocation;
		else
			StartLocation = WeaponFireLocation + vector(WeaponFireRotation) * (ProjClass.default.CollisionRadius * 1.1);
	}
	else
		StartLocation = WeaponFireLocation;
	
	P = Spawn(ProjClass, self,, StartLocation, WeaponFireRotation);
	
	if (P != None) {
		if (AIController(Instigator.Controller) == None) {
			if (bAltFire)
				WeaponCharge = 1.0;
			P.Velocity = vector(WeaponFireRotation) * Lerp(WeaponCharge, MinSpeed, MaxSpeed);
		}
		else
		{
			if (ONSMortarCamera(P) != None) {
				P.Velocity = SetMuzzleVelocity(StartLocation, TargetLoc,0.25);
				ONSMortarCamera(P).TargetZ = TargetLoc.Z;
			}
			else
				P.Velocity = SetMuzzleVelocity(StartLocation, TargetLoc,0.5);
			WeaponFireRotation = Rotator(P.Velocity);
			ONSArtillery(Owner).bAltFocalPoint = true;
			ONSArtillery(Owner).AltFocalPoint = StartLocation + P.Velocity;
		}
		if (ONSMortarCamera(P) == None) {
			if (MortarCamera != None) {
				ONSMortarShell(P).StartTimer(FMax(0.6 * PredicatedTimeToImpact, 0.85 * PredicatedTimeToImpact - 0.7));
				ShellSoundMarker = Spawn(class'UT3HellfireSPMAIncomingSound',,, PredictedTargetLocation + vect(0,0,400));
				ShellSoundMarker.StartTimer(PredicatedTimeToImpact);
			}
			else
				P.LifeSpan = 2.0;
		}
		
		FlashMuzzleFlash();
		
		// Play firing noise
		if (bAltFire) {
			if (bAmbientAltFireSound)
				AmbientSound = AltFireSoundClass;
			else
				PlayOwnedSound(AltFireSoundClass, SLOT_None, FireSoundVolume/255.0,, AltFireSoundRadius,, false);
		}
		else {
			if (bAmbientFireSound)
				AmbientSound = FireSoundClass;
			else
				PlayOwnedSound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius,, true); // primary fire heard from camera
		}
		
		if (ONSMortarCamera(P) != None) {
			CameraAttempts = 0;
			LastCameraLaunch = Level.TimeSeconds;
			MortarCamera = ONSMortarCamera(P);
			if (ONSArtillery(Owner) != None)
				ONSArtillery(Owner).MortarCamera = MortarCamera;
		}
		else
			MortarShell = ONSMortarShell(P);
	}
	else if ( AIController(Instigator.Controller) != None )
	{
		bFailed = ONSMortarCamera(P) == None;
		if ( !bFailed )
		{
			// allow 2 tries
			CameraAttempts++;
			bFailed = ( CameraAttempts > 1 );
		}
		
		if (bFailed) {
			CameraAttempts = 0;
			LastCameraLaunch = Level.TimeSeconds;
			if (MortarCamera != None)
				MortarCamera.ShotDown();
		}
	}
	return P;
}


simulated function float ChargeBar()
{
	return FClamp(1.0 - (FireCountDown / FireInterval), 0.001, 0.999);
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
	bForceCenterAim    = True // rotation is initially disabled
	PitchUpLimit       = 16000
	WeaponFireOffset   = 0.0
	RotationsPerSecond = 1.0
	
	DistantFireSound  = Sound'DistantBooms.DistantSPMA'
	ReadyToFireSound  = Sound'WeaponSounds.BaseGunTech.BSeekLost1'
	FireSoundClass    = Sound'SPMACannonFire'
	FireInterval      = 3.5
	AltFireSoundClass = Sound'SPMACannonFire'
	AltFireInterval   = 1.5
	ProjectileClass        = class'UT3HellfireSPMAShell'
	AltFireProjectileClass = class'UT3HellfireSPMACamera'
}
