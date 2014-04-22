/******************************************************************************
UT3HellfireSPMAIncomingSound

Creation date: 2009-02-13 21:21
Last change: $Id$
Copyright (c) 2009, Wormbo
******************************************************************************/

class UT3HellfireSPMAIncomingSound extends ONSIncomingShellSound;


function StartTimer(float TimeToImpact)
{
	if (TimeToImpact > SoundLength)
		SetTimer(TimeToImpact - SoundLength, false);
	else
		Destroy();
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
	SoundLength = 3.5
	ShellSound  = Sound'SPMAShellIncoming'
}
