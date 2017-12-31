//============================================================
// UT3 Paladin Shield
// Copyright (c) 2012, José Luís '100GPing100'
// Copyright (c) 2014, GreatEmerald
// Contact: zeluis.100@gmail.com
//============================================================
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
                ShockShieldHitEffect = spawn(class'UT3PaladinShieldHitEffectBlue', self);
            else
                ShockShieldHitEffect = spawn(class'UT3PaladinShieldHitEffectRed', self);
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
