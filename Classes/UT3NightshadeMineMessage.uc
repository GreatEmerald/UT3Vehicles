//============================================================
// Messages used by the Nightshade when switching mines.
// Credits: 100GPing100(José Luís)
// Copytight José Luís, 2012
// Contact: zeluis.100@gmail.com
//============================================================
class UT3NightshadeMineMessage extends LocalMessage;

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
	PosY = 0.80;
	
	// Messages.
	MessageText(0) = "Spidermine Trap";
	MessageText(1) = "Stasis Field";
	MessageText(2) = "EMP";
	MessageText(3) = "Shield Generator";
}
