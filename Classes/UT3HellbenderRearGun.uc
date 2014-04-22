//==============================================================================
// UT3HellbenderRearGun.uc
// This is not so fun.
// 2008, GreatEmerald
//==============================================================================

class UT3HellbenderRearGun extends ONSPRVRearGun;

var bool bCeaseNow;

state InstantFireMode
{
    simulated function OwnerEffects()
    {
        if (Role < ROLE_Authority && !bHoldingFire)
        {
            bHoldingFire = true;
            StartHoldTime = Level.TimeSeconds;
            if (FlashEmitter != None)
                FlashEmitter.Reset();
        }
    }

    simulated function ClientStopFire(Controller C, bool bWasAltFire)
    {
        Super(ONSWeapon).ClientStopFire(C, bWasAltFire);

        if (FireCountdown <= 0)
        {
            ClientPlayForceFeedback(FireForce);
            ShakeView();
        }

        if (Role < ROLE_Authority)
        {
            bHoldingFire = false;
            if (FireCountdown <= 0)
            {
                if (bIsAltFire)
                    FireCountdown = AltFireInterval;
                else
                    FireCountdown = FireInterval;

                FlashMuzzleFlash();

                if (!bIsAltFire)
                    PlaySound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius,, false);
            }
        }

    }

    function Fire(Controller C)
    {
       if (!bHoldingFire)
            return;

        ClientPlayForceFeedback(FireForce);

        AmbientSound = None;

        CalcWeaponFire();

        if (bCorrectAim)
            WeaponFireRotation = AdjustAim(false);

        DamageScale = FClamp((Level.TimeSeconds - StartHoldTime) / MaxHoldTime, MinDamageScale, 1.0);
        DamageMin = default.DamageMin * DamageScale;
        DamageMax = default.DamageMax * DamageScale;
        Momentum = default.Momentum * DamageScale;
        FireSoundPitch = 2.0 - DamageScale;

        Super(ONSWeapon).Fire(C);
        FireCountdown = FireInterval;
        SetTimer(0.5, False);
        bCeaseNow = true;
        bHoldingFire = false;
    }

    function Timer()
    {
        if (bHoldingFire)
            AmbientSound = ChargedLoop;
        if (bCeaseNow){//(!bHoldingFire){
            CeaseFire(Instigator.Controller); //Prasideda "cooldown" efektas
            bCeaseNow=False;
        }
    }

    function CeaseFire(Controller C)
    {
        if (!bHoldingFire)
        {
            StartHoldTime = Level.TimeSeconds;
            bHoldingFire = true;
            if (FlashEmitter != None)
                FlashEmitter.Reset();
            bClientTrigger = !bClientTrigger;
            AmbientSound = ChargingSound;
            SetTimer(MaxHoldTime, False);
        }


    }

    simulated function ClientTrigger()
    {
        if (Instigator != None && !Instigator.IsLocallyControlled() && FlashEmitter != None)
            FlashEmitter.Reset();
    }
}

defaultproperties
{
     MaxHoldTime=3.000000
     bHoldingFire=True
     ChargingSound=None
     ChargedLoop=None
     bShowChargingBar=False
     FireInterval=0.500000
     FireSoundClass=Sound'UT3Vehicles.HELLBENDER.HellbenderSecondFire'
     DamageMin=180
     DamageMax=180
     Momentum=75000.000000
     AIInfo(0)=(bFireOnRelease=False,RefireRate=0.500000)
}
