class SlowVolume extends Actor;

/* General speed scaling factor. */
var float ScalingFactor;
/* Speed scaling factor for projectiles. */
var float ProjectileScalingFactor;
/* How much life a pawn inside of the stasis drains to it. */
var float PawnLifeDrainPerSec;
/* The mine base. */
var DeployableMine MineBase;
/* The list of the currently slowed pawns. */
var array<Pawn> SlowedPawns;


simulated event Destroyed()
{
	Super.Destroyed();
	
	if (Role == ROLE_Authority)
	{
		//PlaySound(DestroySound);
	}
	
	MineBase.Destroy();
}
simulated function SlowPawn(Pawn Other)
{
	local SVehicle V;
	
	Level.Game.BroadCast(self, "SlowingPawn.", 'Say');
	V = SVehicle(Other);
	if (V != None)
		KarmaParamsRBFull(V.KParams).KMaxSpeed = KarmaParamsRBFull(V.KParams).Default.KMaxSpeed * ScalingFactor;
	else
	{
		Other.GroundSpeed = Other.Default.GroundSpeed * ScalingFactor;
		Other.AirSpeed = Other.Default.AirSpeed * ScalingFactor;
	}
}
simulated function RestorePawn(Pawn Other)
{
	local SVehicle V;
	
	Level.Game.BroadCast(self, "RestoringPawn.", 'Say');
	V = SVehicle(Other);
	if (V != None)
		KarmaParamsRBFull(V.KParams).KMaxSpeed = KarmaParamsRBFull(V.KParams).Default.KMaxSpeed;
	else
	{
		Other.GroundSpeed = Other.Default.GroundSpeed;
		Other.AirSpeed = Other.Default.AirSpeed;
	}
}
function Tick(float DeltaTime)
{
	local Pawn P;
	local int i;
	local bool bFound;
	
	// Check if all slowedpawns are still inside.
	for (i = 0; i < SlowedPawns.Length; i++)
	{
		bFound = false;
		foreach TouchingActors(class'Pawn', P)
		{
			if (SlowedPawns[i] != None && SlowedPawns[i] == P)
			{
				break;
				bFound = true;
			}
		}
		if (!bFound)
		{
			RestorePawn(P);
			SlowedPawns[i] = none;
		}
	}
	
	// Check for new pawns.
	foreach TouchingActors(class'Pawn', P)
	{
		bFound = false;
		for (i = 0; i < SlowedPawns.Length; i++)
		{
			if (P == SlowedPawns[i])
			{
				bFound = true;
				break;
			}
		}
		if (!bFound)
		{
			AddPawn(P);
			SlowPawn(P);
		}
	}
}
function AddPawn(Pawn P)
{
	local int i;
	
	while (true)
	{
		if (SlowedPawns[i] == None)
		{
			SlowedPawns[i] = P;
			break;
		}
		i++;
	}
}

DefaultProperties
{
	// Looks.
	StaticMesh = StaticMesh'UT3NightshadeSM.SlowVolumeCube';
	DrawType = DT_StaticMesh;
	
	// Misc.
	LifeSpan = 180.0;
	
	// Collision.
	bProjTarget = true;
	bCollideActors = true;
	bBlockActors = false;
	bStatic = false;
	bNoDelete = false;
	bHidden = false;
	
	// Vars.
	ScalingFactor = 0.2;
	ProjectileScalingFactor = 0.125;
	PawnLifeDrainPerSec = 3.0;
	//Gravity = (X=0,Y=0,Z=-190);
	
	// Network.
	RemoteRole = ROLE_Authority;
	bNetInitialRotation = true;
	NetUpdateFrequency = 1.0;
}
