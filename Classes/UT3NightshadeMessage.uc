//============================================================
// Messages used by the Nightshade.
// Credits: 100GPing100(José Luís)
// Copytight José Luís, 2012
// Contact: zeluis.100@gmail.com
//============================================================
class UT3NightshadeMessage extends LocalMessage;

/* Messages available for display. */
var localized array<string> MessageText;

static function string GetString(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject)
{
	return Default.MessageText[Switch];
}
static function ClientReceive(
    PlayerController P,
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject)
{
	Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
}

DefaultProperties
{
	// Draw parameters.
	DrawColor = (R=255,G=255,B=128,A=255);
	bIsPartiallyUnique = true;
	bIsUnique = true;
	bFadeMessage = true;
	FontSize = 0;
	PosY = 0.15;
	
	// Messages.
	MessageText(0) = "Obstacle blocking deployment.";
	MessageText(1) = "No deployable ammunition available.";
	MessageText(2) = "Close proximity to other deployables, unable to deploy.";
	MessageText(3) = "Cannot deploy while on water.";
	MessageText(4) = "Only in next beta (have a shiled :D)";
}
