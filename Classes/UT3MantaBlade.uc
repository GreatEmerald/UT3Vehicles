//============================================================
// Blades for the manta
// Credits: 100GPing100(José Luís)
// Copytight José Luís, 2012
// Contact: zeluis.100@gmail.com
//============================================================
class UT3MantaBlade extends Actor;

/* Texture for when the blades are on. */
var Material BladesOnTex;
/* Texture for when the blades are off. */
var Material BladesOffTex;

DefaultProperties
{
	// Looks.
	StaticMesh = StaticMesh'UT3MantaSM.Blades';
	Skins(0) = TexRotator'UT3MantaTex.BladesOn';
	DrawType = DT_StaticMesh;
	BladesOnTex = TexRotator'UT3MantaTex.BladesOn';
	BladesOffTex = Texture'UT3MantaTex.BladesOff';
}
