//============================================================
// Spider Mine (spawns spiders to kill close enemies).
// Credits: 100GPing100(José Luís)
// Copytight José Luís, 2012
// Contact: zeluis.100@gmail.com
//============================================================
class SpiderMine extends DeployableMine;


#exec audio import group=SpiderSounds file=..\Sounds\UT3Nightshade\SpiderMine\SpiderMine_Active01.wav
#exec audio import group=SpiderSounds file=..\Sounds\UT3Nightshade\SpiderMine\SpiderMine_Active02.wav
#exec audio import group=SpiderSounds file=..\Sounds\UT3Nightshade\SpiderMine\SpiderMine_Active03.wav
#exec audio import group=SpiderSounds file=..\Sounds\UT3Nightshade\SpiderMine\SpiderMine_Drop.wav


/* Max range for detecting enemies. */
var float DetectionRange;
/*  */
var int AvailableMines;
/*  */
var int DeployedMines;
/*  */
var array<Sound> ActivateSnd;
/*  */
var Sound DropSnd;


event Landed(vector HitNormal)
{
	Super.Landed(HitNormal);
	SetTimer(0.5, false);
	if (Team == 0)
		Level.Game.BroadCast(self, "red", 'Say');
	else if (Team == 1)
		Level.Game.BroadCast(self, "blue", 'Say');
	else
		Level.Game.BroadCast(self, Team, 'Say');
}
function Deploy()
{
	Super.Deploy();
	PlayAnim('Deploy', 1, 0);
}
function SpawnMine(Pawn Target, vector TargetDir)
{
	// ONSMineProjectile.
	local Spider Mine;
	local Vector X,Y,Z;
	
	if (AvailableMines > 0)
	{
		PlaySound(ActivateSnd[Rand(4) - 1], SLOT_None, 1.0);
		GetAxes(Rotation, X,Y,Z);
		Mine = Spawn(Class'Spider',,, Location + 25*Z);
		if (Mine == None)
		{
			Mine = Spawn(Class'Spider',,, Location + Vect(0,0, 10));
		}
		Mine.Lifeline = self;
		Mine.InstigatorController = Instigator.Controller;
		Mine.TeamNum = Team;
		Mine.TargetPawn = Target;
		Mine.KeepTargetExtraRange = FMax(0.f, DetectionRange - Mine.DetectionRange);
		Mine.TossZ = 300.0;
		Mine.Init(TargetDir);
		AvailableMines--;
		DeployedMines++;
	}
}
function CheckForEnemies()
{
	local Pawn P;
	local bool spawnedmine;
	
	if (Controller != None)
	{
		if (Controller.Pawn != None)
			Instigator = Controller.Pawn;
	}
	else
	{
		// Noone to get the kills.
		Destroy();
		return;
	}
	
	if (Team != Controller.PlayerReplicationInfo.Team.TeamIndex && Controller.PlayerReplicationInfo.Team != None)
	{
		// Deployable and controller are not off the same team
		// and the controller has no Team info.
		Destroy();
		return;
	}
	
	if (AvailableMines + DeployedMines <= 0)
	{
		// UT3: Out of mines.
		// @100GPing100: won't ever be true since the addition
		// will allways be the start count of mines.
		
		// @100GPing100: as I said, it's never true.
		Destroy();
		return;
	}
	
	if (!bDeleteMe)
	{
		spawnedmine = false;
		foreach RadiusActors(class'Pawn', P, DetectionRange, Location)
		{
			if (Vehicle(P) != None)
			{
				if (Vehicle(P).GetTeamNum() != Team && Vehicle(P).Driver != None && Vehicle(P).Health > 0 && FastTrace(Vehicle(P).Location, Location))
				{
					SpawnMine(P, Normal(P.Location - Location));
					SpawnedMine = true;
					break; // Only spawn one spider at a time.
				}
			}
			else if (P.GetTeamNum() != Team && P.Health > 0 && FastTrace(P.Location, Location))
			{
				SpawnMine(P, Normal(P.Location - Location));
				spawnedmine = true;
				break; // Only spawn one spider at a time.
			}
		}
		if (spawnedmine)
			SetTimer(1.5, false);
		else
			SetTimer(0.5, false);
	}
}
event Timer()
{
	CheckForEnemies();
}


DefaultProperties
{
	// Looks.
	Mesh=SkeletalMesh'UT3NightshadeAnims.SpiderMine';
	DrawType=DT_Mesh;
	
	// Damage.
	DetectionRange=1500.0;
	AvailableMines=15;
	
	// Sound.
	ActivateSnd(0) = Sound'UT3Nightshade.SpiderSounds.SpiderMine_Active01';
	ActivateSnd(1) = Sound'UT3Nightshade.SpiderSounds.SpiderMine_Active02';
	ActivateSnd(2) = Sound'UT3Nightshade.SpiderSounds.SpiderMine_Active03';
	DropSnd = Sound'UT3Nightshade.SpiderSounds.SpiderMine_Drop';
	
	// Misc.
	LifeSpan=150.0;
	bOrientOnSlope=true;
}
