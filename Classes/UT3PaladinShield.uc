/*
 * Copyright © 2014 GreatEmerald
 * Copyright © 2012-2017 Luís 'zeluisping' Guimarães <zeluis.100@gmail.com>
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

class UT3PaladinShield extends ONSShockTankShield;

/* Sound played when the shield is actiavted. */
var Sound ShieldActivateSound;
/* Sound played when the shield if deactivated. */
var Sound ShieldDeactivateSound;
/* Sound played while the shield is active. */
var Sound ShieldAmbientSound;

simulated function SpawnHitEffect(byte TeamNum)
{
    if (Level.NetMode != NM_DedicatedServer)
    {
        if (ShockShieldEffect != None)
        {
            if (TeamNum == 1)
                ShockShieldHitEffect = spawn(class'ONSShockTankShieldHitEffectBlue', self);
            else
                ShockShieldHitEffect = spawn(class'ONSShockTankShieldHitEffectRed', self);
        }

        if (ShockShieldHitEffect != None && Owner != None && ONSShockTankCannon(Owner) != None)
            Owner.AttachToBone(ShockShieldEffect, 'Shield_Pitch');
    }
}
simulated function ActivateShield(byte TeamNum)
{
    SetCollision(True, False, False);

    if (Level.NetMode != NM_DedicatedServer)
    {
        if (ShockShieldEffect == None)
        {
            if (TeamNum == 1)
                ShockShieldEffect = spawn(class'UT3PaladinShieldEffectBlue', self);
            else
                ShockShieldEffect = spawn(class'UT3PaladinShieldEffectRed', self);

            PlaySound(ShieldActivateSound, SLOT_None, 2.0);
        }

        if (ShockShieldEffect != None && Owner != None && ONSShockTankCannon(Owner) != None)
            Owner.AttachToBone(ShockShieldEffect, 'Shield_Pitch');
    }

	AmbientSound = ShieldAmbientSound;
}

simulated function DeactivateShield()
{
    SetCollision(False, False, False);

	// Let's play the deactivation sound only if there was a shield effect.
    if (ShockShieldEffect != None)
	{
        ShockShieldEffect.Destroy();
		if (Level.NetMode != NM_DedicatedServer)
			PlaySound(ShieldDeactivateSound, SLOT_None, 2.0);
	}

	AmbientSound = None;
}

DefaultProperties
{
	ShieldActivateSound = Sound'UT3A_Vehicle_Paladin.Sounds.A_Vehicle_Paladin_ShieldActivate01';
	ShieldDeactivateSound = Sound'UT3A_Vehicle_Paladin.Sounds.A_Vehicle_Paladin_ShieldOff01';
	ShieldAmbientSound = Sound'UT3A_Vehicle_Paladin.Sounds.A_Vehicle_Paladin_ShieldAmbient01';
}
