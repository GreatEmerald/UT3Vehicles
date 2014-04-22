/******************************************************************************
UT3HellfireSPMATargetReticle

Creation date: 2009-02-17 15:58
Latest change: $Id$
Copyright (c) 2009, 2013 Wormbo, GreatEmerald
******************************************************************************/

class UT3HellfireSPMATargetReticle extends ONSMortarTargetBeam;


//=============================================================================
// Imports
//=============================================================================

#exec obj load file=UT3SPMAReticle.usx


//=============================================================================
// Properties
//=============================================================================

var float ReachableInitScale, ReachableScale, UnreachableScale;
var StaticMesh ReachableMesh, UnreachableMesh;


// controlled directly by camera
function Tick(float DeltaTime)
{
	// TODO: draw arc here?
}


function SetStatus(bool bActivated)
{
	if (bReticleActivated != bActivated) {
		bReticleActivated = bActivated;
		if (bReticleActivated) {
			SetTimer(0.3, false);
			SetStaticMesh(ReachableMesh);
			SetDrawScale(ReachableInitScale);
		}
		else {
			SetTimer(0.0, false);
			SetStaticMesh(UnreachableMesh);
			SetDrawScale(UnreachableScale);
		}
	}
}


function Timer()
{
	SetDrawScale(ReachableScale);
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
	DrawScale3D = (X=1,Y=1,Z=1)
	DrawScale   = 1.0
	StaticMesh  = StaticMesh'SPMAReticle'

	ReachableInitScale = 1.25
	ReachableScale     = 1.0
	UnreachableScale   = 0.8
	ReachableMesh      = StaticMesh'SPMAReticleLock'
	UnreachableMesh    = StaticMesh'SPMAReticle'
	bReticleActivated  = False
}
