//============================================================
// UT3 Paladin Shield
// Copyright (c) 2012, José Luís '100GPing100'
// Contact: zeluis.100@gmail.com
//============================================================
class UT3PaladinShield extends ONSShockTankShield;

#exec audio import group=Sounds file=..\Sounds\UT3Paladin\ShieldActivate.wav
#exec audio import group=Sounds file=..\Sounds\UT3Paladin\ShieldDeactivate.wav
#exec audio import group=Sounds file=..\Sounds\UT3Paladin\ShieldAmbient.wav

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
	ShieldActivateSound = Sound'UT3Paladin.Sounds.ShieldActivate';
	ShieldDeactivateSound = Sound'UT3Paladin.Sounds.ShieldDeactivate';
	ShieldAmbientSound = Sound'UT3Paladin.Sounds.ShieldAmbient';
}
