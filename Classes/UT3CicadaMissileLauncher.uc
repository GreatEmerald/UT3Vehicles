//-----------------------------------------------------------
// UT3 Cicada Missile Launcher
// Last change: Alpha 2
// 2009, GreatEmerald
//-----------------------------------------------------------
class UT3CicadaMissileLauncher extends ONSDualACSideGun;

var(Sound) sound LoadSound;

event bool AttemptFire(Controller C, bool bAltFire) //GE: More control over when we altfire.
{
    if(Role != ROLE_Authority || bForceCenterAim )
        return False;

    if (bAltFire)
    {
        if ( Bot(C) != None )
        {
            if ( (Vehicle(Instigator).Rise <= 0) && FastTrace(Instigator.Location - vect(0,0,500),Instigator.Location) )
                Vehicle(Instigator).Rise = -0.5;
            else
                Vehicle(Instigator).Rise = 1;
        }
        if (!bLocked && LoadedShotCount == 0)   // Handle Alt Fire
            ChangeTargetLock();

        if ( !bDumpingLoad && FireCountdown <= 0 )
        {
            if ( LoadedShotCount < MaxShotCount)
            {
                LoadedShotCount++;
                PlaySound(LoadSound);
                FireCountdown = AltFireInterval;
                Instigator.MakeNoise(1.0);
            }
        }
    }
    else
    {
        if ( Bot(Instigator.Controller) != None )
            Vehicle(Instigator).Rise = 0;
        if (LoadedShotCount==0 && FireCountdown <= 0)
            FireSingle(C,false, false); //GE: Not Don't Skip so it would fire one at a time
    }

    return False;
}

function Projectile SpawnProjectile(class<Projectile> ProjClass, bool bAltFire) //GE: Attempting the UT3 values for ejecting.
{
    local Projectile P;
    local vector StartLocation, StartVelocity;
    local rotator WFR, UpRot;
    local float Rand;

    // We want projectiles to "eject" from this gun then take flight.  Part is handled here, part in
    // the projectile.

    if ( Bot(Instigator.Controller) != None )
        Vehicle(Instigator).Rise = 0;
    StartLocation = WeaponFireLocation;
    Rand = ( (400.0 * FRand()) - 100.0 ) * ( FRand() * 2.f);   // This is our range for the ejection. //GE: Default: (400 * frand()) + 200

    // if we are going forward, apply the ships velocity to the projectile,
    // if we are going backwards, apply the 1/4 the inverse X/Y.

    WFR = WeaponFireRotation;
    if (bLocked)
        WFR.Pitch += 2048;

    StartVelocity = Instigator.Velocity;

    // Modify the start velocity so it ejects to the proper side.

    if (bFiresRight)
        StartVelocity += (Vector(WFR) cross vect(0,0,-1)) * 450;
    else
        StartVelocity += (Vector(WFR) cross vect(0,0,1)) * 450;

    // Always kick it up a little bit more

    if ( bAltFire )
        StartVelocity.Z += (Rand * ( frand()*2));
    else
        StartVelocity.Z = 200;

    P = spawn(ProjClass, self, , StartLocation, WFR);

    P.Velocity = StartVelocity; // Apply the velocity
    if ( bAltFire && bLocked && (Bot(Instigator.Controller) != None) && !FastTrace(LockedTarget,P.Location) )
    {
        UpRot = WeaponFireRotation;
        UpRot.Pitch = 12000;
        if ( !FastTrace(P.Location + 3000*vector(UpRot),P.Location) )
            UpRot.Pitch = 16000;
        ONSDualACRocket(P).Target = FindInitialTarget(WeaponFireLocation, UpRot);
    }
    else
        ONSDualACRocket(P).Target = FindInitialTarget(WeaponFireLocation, WeaponFireRotation);

    if (!bAltFire)
        ONSDualACRocket(P).DesiredDistanceToAxis = 64;
    else
        ONSDualACRocket(P).KillRange=4500;

    if (bLocked)
    {
        ONSDualACRocket(P).bFinalTarget     = false;
        ONSDualACRocket(P).SecondTarget     = LockedTarget;
        ONSDualACRocket(P).SwitchTargetTime = 0.5;
    }
    else
        ONSDualACRocket(P).bFinalTarget = true;

    // Play effects

    if (P != None)
    {
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
            else
                PlayOwnedSound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius,, false);
        }

    }

    return P;
}


DefaultProperties
{
    FireInterval=0.25
    AltFireInterval=0.5
    ProjectileClass=class'UT3CicadaRocket'
    AltFireProjectileClass=class'UT3CicadaRocket'
    LoadSound=sound'UT3Vehicles.Cicada.Cicada_MissleLoad01'
    FireSoundClass=Sound'UT3Vehicles.Cicada.Cicada_MissleEject01'
    AltFireSoundClass=Sound'UT3Vehicles.Cicada.Cicada_MissleEject01'
}
