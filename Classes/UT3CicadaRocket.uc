//-----------------------------------------------------------
// UT3 Cicada Rocket, primary fire projectile
// Last change: Alpha 2
// 2009, GreatEmerald
//-----------------------------------------------------------
class UT3CicadaRocket extends ONSDualACRocket;

simulated function Timer() //GE: Change the sound volume to something bearable
{
	local float dist,travelTime;
	local PlayerController PC;

	SetCollision(true,true);

	if (Level.NetMode != NM_DedicatedServer)
	{
		SmokeTrailEffect = Spawn(class'ONSDualMissileSmokeTrail',self);

		if ( EffectIsRelevant(location,false) )
		{
			PC = Level.GetLocalPlayerController();
			if ( (PC.ViewTarget != None) && (VSize(PC.ViewTarget.Location - Location) < 3000) )
				Spawn(class'ONSDualMissileIgnite',,,location,rotation);
		}

		SetDrawType(DT_None);

		PlaySound(IgniteSound, SLOT_Misc, 1.0, true, 512);
        //GE: Whoever did this apparently had no idea that this was a float, not a byte.
		AmbientSound = FlightSound;
	}

	Velocity = vector(Rotation) * MaxSpeed;

	if (!bFinalTarget)
	{
		Dist = vsize(Target - Location);
		TravelTime = Dist / vsize(Velocity);
		if ( FastTrace(SecondTarget, Location) )
		{
			if ( TravelTime < (SwitchTargetTime*0.9) )
			{
				Target = SecondTarget;
				bFinalTarget = true;
			}
		}
		else
		{

			if (TravelTime < SwitchTargetTime)
				SwitchTargetTime = TravelTime * 0.9;
		}

		GotoState('Spiraling');
	}
	else
	{
		if ( Vsize(Location - Target) <= KillRange )
		{
			GotoState('Homing');
		}
		else
		{

			GotoState('Spiraling');
		}
	}
}

DefaultProperties
{
   Speed=1000.000000
   MaxSpeed=4000.000000
   MomentumTransfer=40000.000000
   DamageRadius=220.000000
   KillRange=2000.000000
   IgniteSound=Sound'UT3Vehicles.Cicada.Cicada_Fire'
}
