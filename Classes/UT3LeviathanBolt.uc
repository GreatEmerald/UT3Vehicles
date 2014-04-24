/******************************************************************************
UT3LeviathanBolt

Creation date: 2007-12-30 18:58
Last change: $Id$
Copyright (c) 2007, Wormbo
******************************************************************************/

class UT3LeviathanBolt extends ONSMASRocketProjectile;


var float AccelRate;


simulated function PostNetBeginPlay()
{
	Acceleration = AccelRate * Normal(Velocity);
}


function Timer();


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
	Speed=1200
	MaxSpeed=3500
	AccelRate=20000.0
	
	Damage=100
	DamageRadius=300
	MomentumTransfer=4000
	
	DrawType   = DT_StaticMesh
	StaticMesh = StaticMesh'WeaponStaticMesh.FlakChunk'
}
