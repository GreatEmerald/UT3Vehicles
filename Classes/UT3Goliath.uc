/*
 * Copyright © 2008 Wormbo
 * Copyright © 2012, 2017 Luís 'zeluisping' Guimarães <zeluis.100@gmail.com>
 * Copyright © 2014 GreatEmerald
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


#exec obj load file=../Animations/UT3GoliathAnims.ukx
#exec obj load file=../Textures/UT3GoliathTex.utx


//var(ONSWheeledCraft) float ChassisTorqueScale; doesn't work yet


function Tick(float DeltaTime) {
    local KarmaParamsRBFull KP;

    KP = KarmaParamsRBFull(KParams);

    if (Throttle == 0) {
        KP.KLinearDamping = 1;
    } else {
        KP.KLinearDamping = 0;
    }

    super.Tick(DeltaTime);
}

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


//=============================================================================
// Default values
//=============================================================================
defaultproperties
{
    Mesh=SkeletalMesh'UT3GoliathAnims.Goliath';
    RedSkin=Shader'UT3GoliathTex.Goliath.GoliathSkin';
    BlueSkin=Shader'UT3GoliathTex.Goliath.GoliathSkinBlue';

    Skins(1)=Shader'UT3GoliathTex.GoliathWheels.GoliathWheelsSkin';
    Skins(2)=Shader'UT3GoliathTex.GoliathWheels.GoliathWheelsSkin';

    DriverWeapons(0)=(WeaponClass=class'UT3GoliathCannon',WeaponBone=Chassis)
    PassengerWeapons(0)=(WeaponPawnClass=class'UT3GoliathTurretPawn',WeaponBone=Object10)

	Health=900
	HealthMax=900

    IdleSound=Sound'UT3A_Vehicle_Goliath.Sounds.A_Vehicle_Goliath_EngineLoop01RealTreadsMix';
    //IdleSound = Sound'UT3A_Vehicle_Goliath.Sounds.A_Vehicle_Goliath_EngineLoop01';
    StartUpSound=Sound'UT3A_Vehicle_Goliath.Sounds.A_Vehicle_Goliath_Start01';
    ShutDownSound=Sound'UT3A_Vehicle_Goliath.Sounds.A_Vehicle_Goliath_Stop01';
    DamagedEffectHealthSmokeFactor=0.65 //0.5
    DamagedEffectHealthFireFactor=0.40 //0.25
    DamagedEffectFireDamagePerSec=2.0 //0.75
    ImpactDamageSounds=();
    ImpactDamageSounds(0)=Sound'UT3A_Vehicle_Goliath.Sounds.A_Vehicle_Goliath_Collide01';
    ExplosionSounds=();
    ExplosionSounds(0)=Sound'UT3A_Vehicle_Goliath.Sounds.A_Vehicle_Goliath_Explode01';

    TreadVelocityScale = 12.0;

    VehicleNameString="UT3 Goliath"
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
    
    ExitPositions(0)=(X=0,Y=-200,Z=30)
    ExitPositions(1)=(X=0,Y=200,Z=30)
    
    HeadlightCoronaOffset(0)=(X=167,Y=99.5,Z=34)
    HeadlightCoronaOffset(1)=(X=167,Y=-99.5,Z=34)
    HeadlightCoronaMaterial=Material'EmitterTextures.Flares.EFlareOY'
    HeadlightCoronaMaxSize=115  //95 looks  good to me as well

    HeadlightProjectorOffset=(X=167,Y=0,Z=34)
    HeadlightProjectorRotation=(Yaw=0,Pitch=-1500,Roll=0)
    //HeadlightProjectorMaterial=Texture'VMVehicles-TX.HoverTankGroup.TankProjector'
    HeadlightProjectorMaterial=Texture'VMVehicles-TX.NewPRVGroup.PRVProjector'
    HeadlightProjectorScale=0.80
}
