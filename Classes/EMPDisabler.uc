class EMPDisabler extends Inventory;

/*  */
var byte Team;

function Destroyed()
{
	local Vehicle V;
	
	V = Vehicle(Owner);
	
	if (V != None)
	{
		V.Team = Team;
		V.bTeamLocked = false;
	}
	
	Super.Destroyed();
}

DefaultProperties
{
	// UTVehicle.DisabledTime;
	LifeSpan = 20.0;
}
