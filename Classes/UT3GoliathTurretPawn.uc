//-----------------------------------------------------------
// UT3GoliathTurretPawn.uc
// That small turret mounted on top of Goliaths
// GreatEmerald, 2008 (almost 2009)
//-----------------------------------------------------------
class UT3GoliathTurretPawn extends ONSTankSecondaryTurretPawn;

DefaultProperties
{
  GunClass=class'UT3GoliathTurret'
  
  FPCamPos=(X=-80,Y=0,Z=0)
  
  //Aerial View
  TPCamWorldOffset=(X=0,Y=0,Z=90)
}
