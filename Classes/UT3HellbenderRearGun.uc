/*
 * Copyright © 2008, 2014 GreatEmerald
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 *     (1) Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *
 *     (2) Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimers in
 *     the documentation and/or other materials provided with the
 *     distribution.
 *
 *     (3) The name of the author may not be used to
 *     endorse or promote products derived from this software without
 *     specific prior written permission.
 *
 *     (4) The use, modification and redistribution of this software must
 *     be made in compliance with the additional terms and restrictions
 *     provided by the Unreal Tournament 2004 End User License Agreement.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
 * IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *
 * This software is not supported by Atari, S.A., Epic Games, Inc. or any
 * of such parties' affiliates and subsidiaries.
 */

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
    Mesh = SkeletalMesh'UT3VH_Hellbender_Anims.HellbenderMainTurret'
    RedSkin = Shader'UT3HellbenderTex.UT3HellbenderSkinRed'
    BlueSkin = Shader'UT3HellbenderTex.UT3HellbenderSkinBlue'
    PitchBone = MainTurretPitch
    YawBone = MainTurretYaw
    WeaponFireAttachmentBone = MainTurretBarrel
    GunnerAttachmentBone = MainTurretYaw
    FireSoundClass=sound'UT3A_Vehicle_Hellbender.Sounds.A_Vehicle_Hellbender_TurretFire01'
    //BeamEffectClass=class'ShockBeamEffect'//'ONSChargeBeamEffect'
    FireInterval=0.5
    DamageMin=180
    DamageMax=180
    Momentum=75000
    MaxHoldTime=3.0
    //MinDamageScale=1.0
    bShowChargingBar=False
    TraceRange=20000
    bDoOffsetTrace=true
    AIInfo(0)=(bInstantHit=true,RefireRate=0.5,bFireOnRelease=false)//0.85
    FlashEmitterClass=class'ONSPRVRearGunCharge'
    ChargingSound=None
    ChargedLoop=None
    bHoldingFire=True
}

