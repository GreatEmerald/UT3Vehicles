//-----------------------------------------------------------
// UT3PaladinCannon.uc
// The main Paladin gun.
// Last change: Alpha 2
// By GreatEmerald, 2009
//-----------------------------------------------------------
class UT3PaladinCannon extends ONSShockTankCannon;

#exec audio import group=Sounds file=..\Sounds\UT3Paladin\Fire.wav
#exec audio import group=Sounds file=..\Sounds\UT3Paladin\FireImpact.wav

/* Name of the shield's pitch bone. */
var name ShieldPitchBone;
/* Sound played on projectile impact. */
var Sound FireImpact;

function ProximityExplosion() //Instant shock combo
{
    local Emitter ComboHit;

    ComboHit = Spawn(class'ONSShockTankShieldComboHit', self);
	if ( Level.NetMode == NM_DedicatedServer )
	{
		ComboHit.LifeSpan = 0.6;
	}
    AttachToBone(ComboHit, PitchBone); // @100GPing100: Changed bone name.
    ComboHit.SetRelativeLocation(vect(300,0,0));
    SetTimer(0.1, false);
}

//===============
// @100GPing100
simulated function PostNetBeginPlay()
{
    Super(ONSWeapon).PostNetBeginPlay();

    ShockShield = spawn(class'UT3PaladinShield', self);

    if (ShockShield != None)
        //AttachToBone(ShockShield, 'ElectroGun');
		AttachToBone(ShockShield, ShieldPitchBone);
}

function Timer()
{
    PlaySound(FireImpact, SLOT_None,1.0,,800);
    Spawn(class'ONSShockTankProximityExplosion', self,, Location + vect(0,0,-70));
    HurtRadius(200, 900, class'DamTypeShockTankProximityExplosion', 150000, Location);
}

function Tick(float DeltaTime)
{
	local Rotator Aim, NewAim, AimRotatorWorld, rot;
	local float YawDelta, PitchDelta;
	local vector AimVectorWorld, AimVectorLocal;
	
	Super.Tick(DeltaTime);
	
	// Apply pitch rotation to the shield arm too.
	if (bForceCenterAim)
		Aim = rot(0,0,0);
	else
	{
		AimVectorWorld = CurrentHitLocation - WeaponFireLocation;
		AimVectorWorld = Normal(AimVectorWorld);
		AimRotatorWorld = Rotator(AimVectorWorld);
		AimVectorLocal = AimVectorWorld >> Rotation;
		Aim = Rotator(AimVectorLocal);
	}
	
	NewAim.Yaw = 0;
	NewAim.Pitch = 0;
	NewAim.Roll = 0;
	
	YawDelta = ShortestAngularDelta(Aim.Yaw, CurrentAim.Yaw);
	PitchDelta = ShortestAngularDelta(Aim.Pitch, CurrentAim.Pitch);
	
	NewAim = SmoothRotate(YawDelta, PitchDelta, CurrentAim, RotationsPerSecond, DeltaTime);
	
	rot.Pitch = -NewAim.Pitch;
	rot.Yaw = 0;
	rot.Roll = 0;
	
	SetBoneRotation(ShieldPitchBone, rot, 0, 1);
}

state ProjectileFireMode
{
	function Fire(Controller C)
	{
		Super.Fire(C);
		
		PlayAnim('Fire');
	}
}

// From ONSWeapon.cpp
function float ShortestAngularDelta(float EndAngle, float StartAngle)
{
	local float DeltaCW, DeltaCCW;
	
	DeltaCW = CWAngularDelta(EndAngle, StartAngle);
	DeltaCCW = CCWAngularDelta(EndAngle, StartAngle);
	
	if (DeltaCW < 32768)
		return DeltaCW;
	else
		return DeltaCCW;
}
function float CCWAngularDelta(float EndAngle, float StartAngle)
{
	return -(ClampAngle(StartAngle - EndAngle));
}
function float CWAngularDelta(float EndAngle, float StartAngle)
{
	return ClampAngle(EndAngle - StartAngle);
}
function float ClampAngle(float Angle)
{
	//return (float)((int)Angle & 65536);
	return Clamp(Angle, 0, 65536);
}
function rotator SmoothRotate(float YawDelta, float PitchDelta, rotator CurrentRotation, float RPS, float deltaSeconds)
{
	local float AngularDistance;
	local Rotator Aim;
	
	AngularDistance = ClampAngle(deltaSeconds * RPS * 65536);
	
	Aim.Yaw = CurrentRotation.Yaw + Clamp(YawDelta, -AngularDistance, AngularDistance);
	Aim.Pitch = CurrentRotation.Pitch + Clamp(PitchDelta, -AngularDistance, AngularDistance);
	Aim.Roll = 0;
	
	return Aim;
}
// @100GPing100
//======END======

DefaultProperties
{
	//===============
	// @100GPing100
	Mesh = SkeletalMesh'UT3PaladinAnims.PaladinCannon';
	RedSkin = Shader'UT3PaladinTex.Paladin.PaladinSkin';
	BlueSkin = Shader'UT3PaladinTex.Paladin.PaladinSkinBlue';
	
	FireSoundClass = Sound'UT3Paladin.Sounds.Fire';
	FireImpact = Sound'UT3Paladin.Sounds.FireImpact';
    //RotateSound=sound'ONSBPSounds.ShockTank.TurretHorizontal'
	
	YawBone=Turret_Yaw
	PitchBone=Cannon_Pitch
	ShieldPitchBone=Shield_Pitch
	WeaponFireAttachmentBone=CannonBarrel
	// @100GPing100
	//======END======
	
	
	MaxShieldHealth=1200.000000    //GE: Exact Copy-Paste of the UT3 code
	MaxDelayTime=2.500000          //Increased
	ShieldRechargeRate=350.000000  //Decreased
	CurrentShieldHealth=1200.000000//Maximum Shield health is lower, but current is higher
	ProjectileClass=class'UT3PaladinProjectile'
}
