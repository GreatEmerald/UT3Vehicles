//============================================================
// HUD item, used to display available mines.
// Credits: 100GPing100(José Luís)
// Copytight José Luís, 2012
// Contact: zeluis.100@gmail.com
//============================================================
class HUDItem extends Actor;

/* The color to drawn the image with. */
var Color DrawColor;
/* Position of where the image will be drawn. */
var float PosX, PosY;
/* The image that will be drawn */
var Texture Icon;
/* The scale that the image will be drawn with. */
var float Scale;

DefaultProperties
{
	DrawColor = (R=255,G=255,B=255,A=255);
	PosX = 0.0;
	PosY = 0.0;
	Scale = 1.0;
}
