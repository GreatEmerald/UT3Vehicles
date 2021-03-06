/*
 * Copyright © 2008 Wormbo
 * Copyright © 2012 100GPing100
 * Copyright © 2014 GreatEmerald
 * Copyright © 2017-2018 HellDragon
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

class UT3Goliath extends ONSHoverTank;

//var(ONSWheeledCraft) float ChassisTorqueScale; //doesn't work yet

//=====================
// @100GPing100
#exec obj load file=../Animations/UT3GoliathAnims.ukx
#exec obj load file=../Textures/UT3GoliathTex.utx


simulated function SetupTreads()
{
    LeftTreadPanner = VariableTexPanner(Level.ObjectPool.AllocateObject(class'VariableTexPanner'));
    if ( LeftTreadPanner != None )
    {
        LeftTreadPanner.Material = Skins[1];
        //LeftTreadPanner.PanDirection = rot(0, 16384, 0);
        LeftTreadPanner.PanDirection = rot(0,-16384,0);
        LeftTreadPanner.PanRate = 0.0;
        Skins[1] = LeftTreadPanner;
    }
    RightTreadPanner = VariableTexPanner(Level.ObjectPool.AllocateObject(class'VariableTexPanner'));
    if ( RightTreadPanner != None )
    {
        RightTreadPanner.Material = Skins[2];
        //RightTreadPanner.PanDirection = rot(0, 16384, 0);
        RightTreadPanner.PanDirection = rot(0,-16384,0);
        RightTreadPanner.PanRate = 0.0;
        Skins[2] = RightTreadPanner;
    }
    //local a;
}
// @100GPing100
//=========END=========

simulated function TeamChanged()
{
    local int i;

    Super.TeamChanged();

    if (Level.NetMode != NM_DedicatedServer)
    {
        for(i = 0; i < HeadlightCorona.Length; i++)
        {
            HeadlightCorona[i].LightSaturation = 0;
            if (Team == 0)
                HeadlightCorona[i].LightHue = 0;
            if (Team == 1)
                HeadlightCorona[i].LightHue = 175;
        }
    }
}

//=============================================================================
// Default values
//=============================================================================

defaultproperties
{

    //Drawscale = 1.35

    //===============
    // @100GPing100
    Mesh = SkeletalMesh'UT3GoliathAnims.Goliath';
    RedSkin = Shader'UT3GoliathTex.Goliath.GoliathSkin';
    BlueSkin = Shader'UT3GoliathTex.Goliath.GoliathSkinBlue';

    Skins(1) = Shader'UT3GoliathTex.GoliathWheels.GoliathWheelsSkin';
    Skins(2) = Shader'UT3GoliathTex.GoliathWheels.GoliathWheelsSkin';

    DriverWeapons(0)=(WeaponClass=class'UT3GoliathCannon',WeaponBone=Chassis)
    PassengerWeapons(0)=(WeaponPawnClass=class'UT3GoliathTurretPawn',WeaponBone=Object10)

	Health=900
	HealthMax=900

    IdleSound = Sound'UT3A_Vehicle_Goliath.Sounds.A_Vehicle_Goliath_EngineLoop01RealTreadsMix';
    //IdleSound = Sound'UT3A_Vehicle_Goliath.Sounds.A_Vehicle_Goliath_EngineLoop01';
    StartUpSound = Sound'UT3A_Vehicle_Goliath.Sounds.A_Vehicle_Goliath_Start01';
    ShutDownSound = Sound'UT3A_Vehicle_Goliath.Sounds.A_Vehicle_Goliath_Stop01';
    DamagedEffectHealthSmokeFactor=0.65 //0.5
    DamagedEffectHealthFireFactor=0.40 //0.25
    DamagedEffectFireDamagePerSec=2.0 //0.75
    ImpactDamageSounds(0) = Sound'UT3A_Vehicle_Goliath.Sounds.A_Vehicle_Goliath_Collide01';
    ImpactDamageSounds(1) = Sound'UT3A_Vehicle_Goliath.Sounds.A_Vehicle_Goliath_Collide01';
    ImpactDamageSounds(2) = Sound'UT3A_Vehicle_Goliath.Sounds.A_Vehicle_Goliath_Collide01';
    ImpactDamageSounds(3) = Sound'UT3A_Vehicle_Goliath.Sounds.A_Vehicle_Goliath_Collide01';
    ImpactDamageSounds(4) = Sound'UT3A_Vehicle_Goliath.Sounds.A_Vehicle_Goliath_Collide01';
    ImpactDamageSounds(5) = Sound'UT3A_Vehicle_Goliath.Sounds.A_Vehicle_Goliath_Collide01';
    ImpactDamageSounds(6) = Sound'UT3A_Vehicle_Goliath.Sounds.A_Vehicle_Goliath_Collide01';
    ExplosionSounds(0) = Sound'UT3A_Vehicle_Goliath.Sounds.A_Vehicle_Goliath_Explode01';
    ExplosionSounds(1) = Sound'UT3A_Vehicle_Goliath.Sounds.A_Vehicle_Goliath_Explode01';
    ExplosionSounds(2) = Sound'UT3A_Vehicle_Goliath.Sounds.A_Vehicle_Goliath_Explode01';
    ExplosionSounds(3) = Sound'UT3A_Vehicle_Goliath.Sounds.A_Vehicle_Goliath_Explode01';
    ExplosionSounds(4) = Sound'UT3A_Vehicle_Goliath.Sounds.A_Vehicle_Goliath_Explode01';

    TreadVelocityScale = 12.0;
    // @100GPing100
    //======END======


    VehicleNameString = "UT3 Goliath"
    MaxGroundSpeed=900.0 //600.0
    GroundSpeed=520 //500
    MaxAirSpeed=900.0  //5000.0
    MaxSteerTorque=70.0
    ForwardDampFactor=0.13
    //ChassisTorqueScale=5.0 compiles but is ignored in-game
    SoundVolume=255
    MaxThrust=80.0 //GE val 200.000000//GE: was 65, maybe the tank is too fast now?
    MaxDesireability=1.25
    
    MomentumMult=0.1 //0.3
    
    Begin Object Class=KarmaParamsRBFull Name=KParams0
        KStartEnabled=True
        KFriction=0.5
        KLinearDamping=0
        KAngularDamping=0
        bKNonSphericalInertia=False
        bHighDetailOnly=False
        bClientOnly=False
        bKDoubleTickRate=True
        bKStayUpright=True
        bKAllowRotate=True
        kMaxSpeed=900.0  //800
        KInertiaTensor(0)=1.3
        KInertiaTensor(1)=0.0
        KInertiaTensor(2)=0.0
        KInertiaTensor(3)=4.0
        KInertiaTensor(4)=0.0
        KInertiaTensor(5)=4.5
        KCOMOffset=(X=0.0,Y=0.0,Z=0.0)
        bDestroyOnWorldPenetrate=True
        bDoSafetime=True
        Name="KParams0"
    End Object
    KParams=KarmaParams'KParams0'
    
    EntryRadius=350.0
    
    ExitPositions(0)=(X=2,Y=-250,Z=30)
    ExitPositions(1)=(X=2,Y=250,Z=30)
    ExitPositions(2)=(X=-100,Y=0,Z=200)
    
    FPCamPos=(X=-70,Y=0,Z=160)
    
    //Aerial View
    //TPCamWorldOffset=(X=0,Y=0,Z=200)
    
    HeadlightCoronaOffset(0)=(X=222,Y=135,Z=58)
    HeadlightCoronaOffset(1)=(X=222,Y=-135,Z=58)
    HeadlightCoronaMaterial=Material'EpicParticles.FlashFlare1'
    //HeadlightCoronaMaterial=Material'EmitterTextures.Flares.EFlareOY'
    HeadlightCoronaMaxSize=115  //95 looks good to me as well

    HeadlightProjectorOffset=(X=220,Y=0,Z=90)
    HeadlightProjectorRotation=(Yaw=0,Pitch=-1500,Roll=0)
    //HeadlightProjectorMaterial=Texture'VMVehicles-TX.HoverTankGroup.TankProjector'
    HeadlightProjectorMaterial=Texture'VMVehicles-TX.NewPRVGroup.PRVProjector'
    HeadlightProjectorScale=0.80
    
}
