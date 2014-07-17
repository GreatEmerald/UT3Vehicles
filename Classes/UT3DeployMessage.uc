/******************************************************************************
UT3DeployMessage

Creation date: 2009-02-09 11:03
Last change: $Id$
Copyright (c) 2009, Wormbo
******************************************************************************/

class UT3DeployMessage extends CriticalEventPlus;


var localized string DeployMessages[3];


static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	if (Switch < 0 || Switch > ArrayCount(default.DeployMessages))
		return "";

	return default.DeployMessages[Switch];
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
	DeployMessages[0] = "Cannot deploy while moving."
	DeployMessages[1] = "Cannot deploy while wheels are unstable."
	DeployMessages[2] = "Press [FIRE] to deploy camera."

	bIsUnique = False
	bIsPartiallyUnique = True
	DrawColor = (R=255,G=255,B=128,A=255)
	StackMode = SM_Down
}
