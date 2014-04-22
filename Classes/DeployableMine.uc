//============================================================
// Base class for deployable objects.
// Credits: 100GPing100(José Luís)
// Copytight José Luís, 2012
// Contact: zeluis.100@gmail.com
//============================================================
class DeployableMine extends Actor;

/* The deployer's controller. */
var Controller Controller;
/* Indicates wether or not we've deployed. */
var bool bDeployed;
/* The team of the deployable. */
var byte Team;


replication
{
	reliable if (Role == ROLE_Authority && bNetDirty)
		bDeployed, Team;
}


function PostBeginPlay()
{
	Super.PostBeginPlay();
	
	if (Instigator != None)
	{
		Controller = Instigator.Controller;
		Team = Controller.PlayerReplicationInfo.Team.TeamIndex;
	}
}
simulated function Deploy()
{
	bDeployed = true;
}
event Landed(vector HitNormal)
{
	// We want to deploy after we land.
	Deploy();
	bCollideWorld=false;
	SetCollision(false, false, false);
}
static function bool DeployablesNearby(Actor MyActor, vector StartLocation, float CheckRadius)
{
	local float Dist;
	local DeployableMine DeployedActor;
	
	if (MyActor.Instigator == None)
		return true;
	
	foreach MyActor.DynamicActors(class'DeployableMine', DeployedActor)
	{
		Dist = VSize(DeployedActor.Location - StartLocation);
		if (Dist < CheckRadius)
		{
			if (DeployableMine(MyActor) != None && DeployedActor.Team == DeployableMine(MyActor).Team)
				return true;
			else if (Pawn(MyActor) != None && DeployedActor.Team == Pawn(MyActor).Controller.PlayerReplicationInfo.Team.TeamIndex)
				return true;
		}
	}
	
	return false;
}


DefaultProperties
{
	// Looks.
	StaticMesh=StaticMesh'2k4ChargerMeshes.ChargerMeshes.HealthChargerMESH-DS';
	DrawType=DT_StaticMesh;	
	
	// Collision.
	bCollideWorld=true;
	bCollideActors=true;
	bBlockActors=true;
	CollisionHeight = 0;
	
	// Network.
	bReplicateInstigator=true;
	bReplicateAnimations=true;
	RemoteRole=ROLE_SimulatedProxy;
	
	// Movement.
	Physics=PHYS_Falling;
}
