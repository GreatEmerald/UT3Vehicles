class EMPMine extends DeployableMine;

#exec audio import group=EMPSounds file=..\Sounds\UT3Nightshade\EMPMine\EMP_Drop.wav
#exec audio import group=EMPSounds file=..\Sounds\UT3Nightshade\EMPMine\EMP_Shock.wav

/*  */
var float EMPRadius;
/*  */
var Sound DropSnd;
/*  */
var Sound ShockSnd;

event Landed(vector HitNormal)
{
	local vector HitLocation, TraceHitNormal;
	local Actor HitActor;
	
	Super.Landed(HitNormal);
	
	//Trace(HitLocation, HitNormal, TraceEnd, Location, true)
	HitActor = Trace(HitLocation, TraceHitNormal, Location - vect(0,0,10), Location, true);
	
	if (Vehicle(HitActor) != None)
		LifeSpan = FMin(LifeSpan, 30.0);
	
	if (!bDeleteMe)
		SetTimer(0.1, true);
}
simulated function Deploy()
{
	Super.Deploy();
	PlaySound(DropSnd, SLOT_None);
	PlayAnim('Deploy');
}
function CheckEMP()
{
	local Vehicle V;
	local Controller C, NextC;
	local bool bActivated;
	
	C = Level.ControllerList;
	while (C != None)
	{
		NextC = C.NextController;
		
		V = Vehicle(C.Pawn);
		//if (C.Pawn != None && Vehicle(C.Pawn) != None && Vehicle(C.Pawn).Health > 0 && Vehicle(C.Pawn).Driver != None && C.GetTeamNum() != Team && VSize(C.Pawn.Location - Location) < EMPRadius && FastTrace(Location, C.Pawn.Location))
		if (V != None && V.Health > 0 && V.Driver != None && C.GetTeamNum() != Team && VSize(V.Location - Location) < EMPRadius && FastTrace(Location, V.Location))
		{
			//V.EjectDriver();
			V.KDriverLeave(true);
			
			// 254 = EMP'ed team.
			if (V.Team != 254)
			{
				PlaySound(ShockSnd, SLOT_None);
				DisableVehicle(V);
				bActivated = true;
			}
		}
		
		C = NextC;
	}
	
	if (bActivated)
	{
		MakeNoise(1.0);
		// PlayEffect()?
	}
}
function DisableVehicle(Vehicle V)
{
	local EMPDisabler Disabler;
	
	Disabler = Spawn(class'EMPDisabler',,, Location);
	Disabler.Team = V.Team;
	
	V.Team = 254;
	V.bTeamLocked = true;
	
	Disabler.GiveTo(V);
}
event Timer()
{
	CheckEMP();
}

DefaultProperties
{
	EMPRadius = 500.0;
	
	Mesh = SkeletalMesh'UT3NightshadeAnims.EMPMine';
	DrawType = DT_Mesh;
	
	bCollideActors = false;
	bBlockActors = false;
	bBlockKarma = false;
	
	LifeSpan = 60.0;
	
	// Sound.
	DropSnd = Sound'UT3Nightshade.EMPSounds.EMP_Drop';
	ShockSnd = Sound'UT3Nightshade.EMPSounds.EMP_Shock';
}
