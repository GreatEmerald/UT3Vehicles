//-----------------------------------------------------------
// UT3GoliathCannon.uc
// Go over to the Projectile.
// GreatEmerald, 2008
// Copyright (c) 2012, 100GPing100 (visuals + fixed sounds)
// Copyright (c) 2014, GreatEmerald
//-----------------------------------------------------------
class UT3GoliathCannon extends ONSHoverTankCannon;

//var()   sound           ReloadSoundClass;

function Projectile SpawnProjectile(class<Projectile> ProjClass, bool bAltFire)
{
    local Projectile P;
    local ONSWeaponPawn WeaponPawn;
    local vector StartLocation, HitLocation, HitNormal, Extent;

    if (bDoOffsetTrace)
    {
        Extent = ProjClass.default.CollisionRadius * vect(1,1,0);
        Extent.Z = ProjClass.default.CollisionHeight;
        WeaponPawn = ONSWeaponPawn(Owner);
        if (WeaponPawn != None && WeaponPawn.VehicleBase != None)
        {
            if (!WeaponPawn.VehicleBase.TraceThisActor(HitLocation, HitNormal, WeaponFireLocation, WeaponFireLocation + vector(WeaponFireRotation) * (WeaponPawn.VehicleBase.CollisionRadius * 1.5), Extent))
            StartLocation = HitLocation;
        else
            StartLocation = WeaponFireLocation + vector(WeaponFireRotation) * (ProjClass.default.CollisionRadius * 1.1);
    }
    else
    {
        if (!Owner.TraceThisActor(HitLocation, HitNormal, WeaponFireLocation, WeaponFireLocation + vector(WeaponFireRotation) * (Owner.CollisionRadius * 1.5), Extent))
            StartLocation = HitLocation;
        else
            StartLocation = WeaponFireLocation + vector(WeaponFireRotation) * (ProjClass.default.CollisionRadius * 1.1);
    }
    }
    else
        StartLocation = WeaponFireLocation;

    P = spawn(ProjClass, self, , StartLocation, WeaponFireRotation);

    if (P != None)
    {
        if (bInheritVelocity)
            P.Velocity = Instigator.Velocity;

        FlashMuzzleFlash();

        // Play firing noise
        if (bAltFire)
        {
            if (bAmbientAltFireSound)
                AmbientSound = AltFireSoundClass;
            else
                PlayOwnedSound(AltFireSoundClass, SLOT_None, FireSoundVolume/255.0,, AltFireSoundRadius,, false);
        }
        else
        {
            if (bAmbientFireSound)
                AmbientSound = FireSoundClass;
            else {
                PlayOwnedSound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius,, false);
                SetTimer(1.2, false);
            }
        }
    }

    return P;
}

//Simulated Function Timer()
//{
//  PlaySound(ReloadSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius,, false);
//}

DefaultProperties
{
	//===============
	// @100GPing100
	Mesh = SkeletalMesh'UT3GoliathAnims.GoliathCannon';
	RedSkin = Shader'UT3GoliathTex.Goliath.GoliathSkin';
	BlueSkin = Shader'UT3GoliathTex.Goliath.GoliathSkinBlue';

	YawBone = "Object01";
	PitchBone = "Object09";
	WeaponFireAttachmentBone = "Object08";

	FireSoundClass = Sound'UT3A_Vehicle_Goliath.UT3GoliathFire.UT3GoliathFireCue';
	//ReloadSoundClass = Sound'UT3A_Vehicle_Goliath.Sounds.A_Vehicle_Goliath_Reload02';
	// @100GPing100
	//======END======

	ProjectileClass=class'UT3GoliathProjectile'
}
