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

//=====================
// @100GPing100
#exec obj load file=../Animations/UT3GoliathAnims.ukx
#exec obj load file=../Textures/UT3GoliathTex.utx
#exec OBJ LOAD FILE=..\textures\EpicParticles.utx
#exec OBJ LOAD FILE=..\textures\VMVehicles-TX.utx

//var(ONSWheeledCraft) float ChassisTorqueScale; //doesn't work yet

var()   array<vector>                   TrailEffectPositions;
var     class<ONSAttackCraftExhaust>    TrailEffectClass;
var     array<ONSAttackCraftExhaust>    TrailEffects;

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

function DrivingStatusChanged()
{
    local vector RotX, RotY, RotZ;
    local int i;
    
    Super.DrivingStatusChanged();

    if (Driver == None) // The default value is set by the mutator.
    {    bCanBeBaseForPawns = default.bCanBeBaseForPawns;
    }
    else
    {    bCanBeBaseForPawns = false;
    }

    if (bDriving && Level.NetMode != NM_DedicatedServer && !bDropDetail)
    {
        GetAxes(Rotation,RotX,RotY,RotZ);

        if (TrailEffects.Length == 0)
        {
            TrailEffects.Length = TrailEffectPositions.Length;

            for(i=0;i<TrailEffects.Length;i++)
                if (TrailEffects[i] == None)
                {
                    TrailEffects[i] = spawn(TrailEffectClass, self,, Location + (TrailEffectPositions[i] >> Rotation) );
                    TrailEffects[i].SetBase(self);
                    TrailEffects[i].SetRelativeRotation( rot(0,32768,0) );
                }
        }
    }
    else
    {
        if (Level.NetMode != NM_DedicatedServer)
        {
            for(i=0;i<TrailEffects.Length;i++)
               TrailEffects[i].Destroy();

            TrailEffects.Length = 0;
        
        }
    }
}

function Tick(float DeltaTime)
{
    local int i;
    local float ThrustAmount;
    local TrailEmitter T;
    local vector RelVel;
    local bool bIsBehindView;
    local PlayerController PC;
        
        if(Level.NetMode != NM_DedicatedServer)
    {

        RelVel = Velocity << Rotation;

        PC = Level.GetLocalPlayerController();
        if (PC != None && PC.ViewTarget == self)
            bIsBehindView = PC.bBehindView;
        else
            bIsBehindView = True;

        // Adjust Engine FX depending on being drive/velocity
        if (!bIsBehindView)
        {
            for(i=0; i<TrailEffects.Length; i++)
                TrailEffects[i].SetThrustEnabled(false);
        }
        else
        {
            ThrustAmount = FClamp(OutputThrust, 0.0, 1.0);

            for(i=0; i<TrailEffects.Length; i++)
            {
                TrailEffects[i].SetThrustEnabled(true);
                TrailEffects[i].SetThrust(ThrustAmount);
            }
        }
    }

    Super.Tick(DeltaTime);
}

simulated function Destroyed()
{
    local int i;
    
    if(Level.NetMode != NM_DedicatedServer)
    {
        for(i=0;i<TrailEffects.Length;i++)
             TrailEffects[i].Destroy();
        TrailEffects.Length = 0;
    }

    Super.Destroyed();
}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
    local int i;

    if(Level.NetMode != NM_DedicatedServer)
    {
        for(i=0;i<TrailEffects.Length;i++)
            TrailEffects[i].Destroy();
        TrailEffects.Length = 0;
    }

    Super.Died(Killer, damageType, HitLocation);
}

//=============================================================================
// Default values
//=============================================================================

defaultproperties
{

    //===============
    // @100GPing100
    Drawscale = 1.0
    Mesh = SkeletalMesh'UT3GoliathAnims.Goliath';
    RedSkin = Shader'UT3GoliathTex.Goliath.GoliathSkin';
    BlueSkin = Shader'UT3GoliathTex.Goliath.GoliathSkinBlue';

    Skins(1) = Shader'UT3GoliathTex.GoliathWheels.GoliathWheelsSkin';
    Skins(2) = Shader'UT3GoliathTex.GoliathWheels.GoliathWheelsSkin';

    DriverWeapons(0)=(WeaponClass=class'UT3GoliathCannon',WeaponBone=Chassis)
    PassengerWeapons(0)=(WeaponPawnClass=class'UT3GoliathTurretPawn',WeaponBone=Object10)

    Health=900
    HealthMax=900

    IdleSound = Sound'UT3A_Vehicle_Goliath.UT3GoliathSingles.UT3GoliathEngineLoop01CueTreadsMix';
    //IdleSound = Sound'UT3A_Vehicle_Goliath.UT3GoliathSingles.UT3GoliathEngineLoop01Cue';
    StartUpSound = SoundGroup'UT3A_Vehicle_Goliath.UT3GoliathEngineStart.UT3GoliathEngineStartCue';
    ShutDownSound = SoundGroup'UT3A_Vehicle_Goliath.UT3GoliathEngineStop.UT3GoliathEngineStopCue';
    DamagedEffectHealthSmokeFactor=0.65 //0.5
    DamagedEffectHealthFireFactor=0.40 //0.25
    DamagedEffectFireDamagePerSec=2.0 //0.75
    ImpactDamageSounds=()
    ImpactDamageSounds(0) = Sound'UT3A_Vehicle_Goliath.UT3GoliathCollide.UT3GoliathCollideCue';
    ExplosionSounds=()
    ExplosionSounds(0) = Sound'UT3A_Vehicle_Goliath.UT3GoliathExplode.UT3GoliathExplodeCue';
    BulletSounds = ()
    BulletSounds(0) = Sound'UT3A_Weapon_BulletImpacts.UT3BulletImpactMetal.UT3BulletImpactMetalCue'
    SoundVolume = 255
   
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
    
    TrailEffectPositions(0)=(X=-250.000000,Y=-80.000000,Z=19.000000)
    TrailEffectPositions(1)=(X=-250.000000,Y=80.000000,Z=19.000000)
    TrailEffectClass=Class'Onslaught.ONSAttackCraftExhaust'
    
    DamagedEffectOffset=(X=0,Y=120,Z=100)  //Right Treads Fire Point
    DamagedEffectScale=1.7                 //Right Treads Fire Size
    //DamagedEffectOffset=(X=170,Y=-40,Z=80)
    //DamagedEffectScale=1.0
    
    HeadlightCoronaOffset(0)=(X=222,Y=135,Z=58)
    HeadlightCoronaOffset(1)=(X=222,Y=-135,Z=58)
    HeadlightCoronaMaterial=Material'EpicParticles.FlashFlare1'
    HeadlightCoronaMaxSize=115  //95 looks good to me as well

    HeadlightProjectorOffset=(X=220,Y=0,Z=90)
    HeadlightProjectorRotation=(Yaw=0,Pitch=-1500,Roll=0)
    //HeadlightProjectorMaterial=Texture'VMVehicles-TX.HoverTankGroup.TankProjector'
    HeadlightProjectorMaterial=Texture'VMVehicles-TX.NewPRVGroup.PRVProjector'
    HeadlightProjectorScale=0.80
    
}
