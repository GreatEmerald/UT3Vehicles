//-----------------------------------------------------------------------------
// UT3MantaPlasmaGun.uc
// Sounds increased by 25%...
// GreatEmerald, 2008
//-----------------------------------------------------------------------------

class UT3MantaPlasmaGun extends ONSHoverBikePlasmaGun;

// @100GPing100
#exec audio import group=Sounds file=..\Sounds\UT3Manta\Fire.wav

function float SuggestAttackStyle()
{
    local xBot B;

    B = xBot(Instigator.Controller);
    if ( (Pawn(Instigator.Controller.Focus) == None) || (B == None) || (B.Skill < 3) )
    {
        return -0.2;
    }

    return 0.2;
}

defaultproperties
{
	// @100GPing100
	FireSoundClass = Sound'UT3Manta.Sounds.Fire';
	
	//FireSoundClass=sound'UT3Vehicles.Manta.MantaFire'
	TransientSoundVolume=0.4
	ProjectileClass=class'UT3MantaPlasmaProjectile'
}
