class DeployableSlowVolume extends DeployableMine;

/*  */
var SlowVolume OwnedVolume;

function Deploy()
{
	local rotator rot;
	
	Super.Deploy();
	
	OwnedVolume = Spawn(class'SlowVolume', Instigator,, Location, Rotation);
	OwnedVolume.MineBase = self;
	
	rot = Rotation;
	rot.Pitch = 0;
	rot.Roll = 0;
	
	SetRotation(rot);
	OwnedVolume.SetRotation(rot);
}

event Destroyed()
{
	if (OwnedVolume != None)
		OwnedVolume.Destroy();
	
	Super.Destroyed();
}
