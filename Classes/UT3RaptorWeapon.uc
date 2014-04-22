/******************************************************************************
UT3RaptorWeapon

Creation date: 2008-05-02 20:34
Last change: Alpha 2
Copyright (c) 2008 and 2009, Wormbo and GreatEmerald
Copyright (c) 2012 100GPing100
******************************************************************************/

class UT3RaptorWeapon extends ONSAttackCraftGun;

var(Sound) Sound HomingSound;

state ProjectileFireMode
{
    function Fire(Controller C)
    {
        if (Vehicle(Owner) != None && Vehicle(Owner).Team < 2)
            ProjectileClass = TeamProjectileClasses[Vehicle(Owner).Team];
        else
            ProjectileClass = TeamProjectileClasses[0];

        Super.Fire(C);
    }

    function AltFire(Controller C)
    {
        local ONSAttackCraftMissle M;
        local Vehicle V, Best;
        local float CurAim, BestAim;

        M = ONSAttackCraftMissle(SpawnProjectile(AltFireProjectileClass, True));
        if (M != None)
        {
            if (AIController(Instigator.Controller) != None)
            {
                V = Vehicle(Instigator.Controller.Enemy);
                if (V != None && (V.bCanFly || V.IsA('ONSHoverCraft')) && Instigator.FastTrace(V.Location, Instigator.Location))
                    M.SetHomingTarget(V);
            }
            else
            {
                BestAim = MinAim;
                for (V = Level.Game.VehicleList; V != None; V = V.NextVehicle)
                    if (V.Health > 0 && (V.bCanFly || V.IsA('ONSHoverCraft')) && V != Instigator && Instigator.GetTeamNum() != V.GetTeamNum())
                    {
                        CurAim = Normal(V.Location - WeaponFireLocation) dot vector(WeaponFireRotation);
                        if (CurAim > BestAim && Instigator.FastTrace(V.Location, Instigator.Location))
                        {
                            Best = V;
                            BestAim = CurAim;
                        }
                    }
                if (Best != None) {
                    M.SetHomingTarget(Best);
                    PlayOwnedSound(HomingSound, SLOT_Interact, 2.5*TransientSoundVolume);
                }
            }
        }
    }
}

//===========================
// @100GPing100
#exec audio import group=Sounds file=..\Sounds\UT3Raptor\Fire.wav
#exec audio import group=Sounds file=..\Sounds\UT3Raptor\FireRocket.wav
#exec audio import group=Sounds file=..\Sounds\UT3Raptor\LockOn.wav
// @100GPing100
//============EDN============


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
	//===========================
	// @100GPing100
	FireSoundClass = Sound'UT3Raptor.Sounds.Fire';
	AltFireSoundClass = Sound'UT3Raptor.Sounds.FireRocket';
	HomingSound = Sound'UT3Raptor.Sounds.LockOn';
	WeaponFireAttachmentBone = 'Fuselage';
	WeaponFireOffset = 150;
	DualFireOffset = 35;
	// @100GPing100
	//============EDN============
	FireInterval    = 0.2
	AltFireInterval = 1.2
	ProjectileClass=class'UT3RaptorProjRed'
    TeamProjectileClasses(0)=class'UT3RaptorProjRed'
    TeamProjectileClasses(1)=class'UT3RaptorProjBlue'
    RotationsPerSecond=0.11 //GE: Maybe too low?
    MinAim=0.930
    AltFireProjectileClass=class'UT3RaptorRocket'
    //HomingSound=Sound'UT3Weapons2.Generic.LockOn'
    //FireSoundClass=sound'UT3Vehicles.RAPTOR.RaptorFire'
    //AltFireSoundClass=sound'UT3Vehicles.RAPTOR.RaptorAltFire'
}
