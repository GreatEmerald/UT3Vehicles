/*
 * Copyright © 2008, 2014 GreatEmerald
 * Copyright © 2008-2009 Wormbo
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

class UT3Cicada extends ONSDualAttackCraft;

var(Sound) sound TargetLockSound;
var() rotator TrailEffectRotation;

//=======================
// @100GPing100
/* Holds the name of the animation currently being played. */
var string CurrentAnim;

#exec obj load file=..\Animations\UT3VH_Cicada_Anims.ukx
#exec obj load file=..\Textures\UT3CicadaTex.utx

function Tick(float DeltaTime)
{
    Super.Tick(DeltaTime);

    AnimateVehicle();
}
function AnimateVehicle()
{
    if (CurrentAnim == "GetIn" && !IsAnimating())
    {
        LoopAnim('Idle', 1.0);
        CurrentAnim = "Idle";
    }
}

simulated function DrivingStatusChanged()
{

    local vector RotX, RotY, RotZ;
    local int i;

    super(ONSChopperCraft).DrivingStatusChanged();

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
                    TrailEffects[i].SetRelativeRotation( TrailEffectRotation );
                }
        }
        if (StreamerEffect.Length == 0)
        {
            StreamerEffect.Length = StreamerEffectOffset.Length;

            for(i=0; i<StreamerEffect.Length; i++)
                if (StreamerEffect[i] == None)
                {
                    StreamerEffect[i] = spawn(StreamerEffectClass, self,, Location + (StreamerEffectOffset[i] >> Rotation) );
                    StreamerEffect[i].SetBase(self);
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
            
            for(i=0; i<StreamerEffect.Length; i++)
                StreamerEffect[i].Destroy();

            StreamerEffect.Length = 0;
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

    /* Animations list:
    ActiveStill [2]
    GetIn [90]
    GetOut [51]
    Idle [201]
    InActiveStill [2]
    */

    if (Driver == None)
    {
        PlayAnim('GetOut', 1.0, 0.2);
        CurrentAnim = "GetOut";
    }
    else
    {
        PlayAnim('GetIn', 1.0);
        CurrentAnim = "GetIn";
    }
}
// @100GPing100
//==========END==========

simulated function DrawHUD(Canvas Canvas) //GE: Lock-on sound
{
    local vector X,Y,Z, Dir, LockedTarget;
    local float Dist,scale,xl,yl,posy;
    local PlayerController PC;
    local HudCDeathmatch H;

    local bool bIsLocked;
    local float DeltaTime;

    local string CoPilot;

    if ( !ONSDualACSideGun(Weapons[0]).bLocked )
        super.DrawHud(Canvas);

    DeltaTime = Level.TimeSeconds - LastHudRenderTime;
    LastHudRenderTime = Level.TimeSeconds;

    bIsLocked = ONSDualACSideGun(Weapons[0]).bLocked;

    PC = PlayerController(Owner);
    if (PC==None)
        return;

    H = HudCDeathmatch(PC.MyHud);
    if (H==None)
        return;

    if ( ONSDualACSideGun(Weapons[0]).bLocked )
    {
        if (bIsLocked != bLastLockType)	// Initialize the Crosshair
            ResetAnimation();

        Animate(Canvas,DeltaTime);

        GetAxes(PC.GetViewRotation(), X,Y,Z);

        LockedTarget = ONSDualACSideGun(Weapons[0]).LockedTarget;
        if (OldLockedTarget != LockedTarget)
            PlaySound(TargetLockSound, SLOT_None, 2.0);

        OldLockedTarget = LockedTarget;

        Dir = LockedTarget - Location;
        Dist = VSize(Dir);
        Dir = Dir/Dist;

        if ( (Dir dot X) > 0.4 )
        {
            // Draw the Locked on Symbol
            Dir = Canvas.WorldToScreen( LockedTarget );
            scale = float(Canvas.SizeX) / 1600;

            // new Stuff

            Canvas.SetDrawColor( 64,255,64,Value(SpinFade[0]) );
            CenterDraw(Canvas, SpinCircles[0], Dir.X, Dir.Y, Value(SpinScale[0])*Scale, Value(SpinScale[0])*Scale );
            Canvas.SetDrawColor(64,255,64,Value(SpinFade[1]) );
            CenterDraw(Canvas, SpinCircles[1], Dir.X, Dir.Y, Value(SpinScale[1])*Scale, Value(SpinScale[1])*Scale );

            Canvas.SetDrawColor(128,255,128,Value(BracketFade));
            DrawBrackets(Canvas,Dir.X,Dir.Y,Scale);
            DrawMissiles(Canvas,Dir.X,Dir.Y,Scale);

        }
    }

    bLastLockType = bIsLocked;

    HudMissileCount.Tints[0] = H.HudColorRed;
    HudMissileCount.Tints[1] = H.HudColorBlue;

    H.DrawSpriteWidget( Canvas, HudMissileCount );
    H.DrawSpriteWidget( Canvas, HudMissileIcon );
    HudMissileDigits.Value = ONSDualACSideGun(Weapons[0]).LoadedShotCount;
    H.DrawNumericWidget(Canvas, HudMissileDigits, DigitsBig);

    if (WeaponPawns[0]!=none && WeaponPawns[0].PlayerReplicationInfo!=None)
    {
        CoPilot = WeaponPawns[0].PlayerReplicationInfo.PlayerName;
        Canvas.Font = H.GetMediumFontFor(Canvas);
        Canvas.Strlen(CoPilot,xl,yl);
        posy = Canvas.ClipY*0.7;
        Canvas.SetPos(Canvas.ClipX-xl-5, posy);
        Canvas.SetDrawColor(255,255,255,255);
        Canvas.DrawText(CoPilot);

        Canvas.Font = H.GetConsoleFont(Canvas);
        Canvas.StrLen(CoPilotLabel,xl,yl);
        Canvas.SetPos(Canvas.ClipX-xl-5,posy-5-yl);
        Canvas.SetDrawColor(160,160,160,255);
        Canvas.DrawText(CoPilotLabel);
    }

}

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

//=============================================================================
// Identity
//=============================================================================
    VehiclePositionString = "in a UT3 Cicada";
    VehicleNameString = "UT3 Cicada"

    CollisionHeight=70.000000

//=============================================================================
// Appearance
//=============================================================================
    Drawscale = 1.0
    Mesh = SkeletalMesh'UT3VH_Cicada_Anims.VH_Cicada_Anims';
    RedSkin = Shader'UT3CicadaTex.CicadaSkin';
    BlueSkin = Shader'UT3CicadaTex.CicadaSkinBlue';

    DriverWeapons(0)=(WeaponClass=class'UT3CicadaMissileLauncher',WeaponBone=Rt_Gun_Yaw);
    DriverWeapons(1)=(WeaponClass=class'UT3CicadaMissileLauncherLeft',WeaponBone=Lt_Gun_Yaw);
    PassengerWeapons(0)=(WeaponPawnClass=Class'UT3CicadaTurretPawn',WeaponBone=MainTurret_Yaw)
    
     //DriverWeapons(0)=(WeaponClass=class'UT3CicadaMissileLauncher',WeaponBone=RightRLAttach);
    //DriverWeapons(1)=(WeaponClass=class'UT3CicadaMissileLauncher',WeaponBone=LeftRLAttach);
    //PassengerWeapons(0)=(WeaponPawnClass=Class'UT3CicadaTurretPawn',WeaponBone="GatlingGunAttach")
    
    //DamagedEffectOffset=(X=-10,Y=50,Z=120)   //Engine Fire Point
    //DamagedEffectScale=1.2                   //Engine Fire Size
    DamagedEffectOffset=(X=210,Y=-40,Z=-17)    //Front Fire Point
    DamagedEffectScale=1.0                     //Front Fire Size
    
    HeadlightCoronaOffset=()
    HeadlightCoronaOffset(0)=(X=243,Y=0,Z=67)
    HeadlightCoronaMaterial=Material'EpicParticles.FlashFlare1'
    HeadlightCoronaMaxSize=45

    HeadlightProjectorOffset=(X=240.0,Y=0,Z=67) //(X=82.5,Y=0,Z=55.5)
    HeadlightProjectorRotation=(Yaw=0,Pitch=-1000,Roll=0)
    HeadlightProjectorMaterial=Texture'VMVehicles-TX.NewPRVGroup.PRVProjector'
    HeadlightProjectorScale=0.20

    StreamerEffectOffset(0)=(X=175,Y=-95,Z=-33);
    StreamerEffectOffset(1)=(X=175,Y=95,Z=-33);
    StreamerEffectOffset(2)=(X=-250,Y=-100,Z=130);
    StreamerEffectOffset(3)=(X=-250,Y=100,Z=130);
    StreamerEffectOffset(4)=(X=-40,Y=-195,Z=67);
    StreamerEffectOffset(5)=(X=-40,Y=195,Z=67);
    StreamerOpacityRamp=(Min=1200.000000,Max=1600.000000)
    StreamerOpacityChangeRate=1.0
    StreamerOpacityMax=0.25 //0.7
    StreamerEffectClass=class'Onslaught.ONSAttackCraftStreamer'
    
    TrailEffectRotation=(Yaw=32768)
    TrailEffectPositions(0)=(X=-63,Y=-42.5,Z=118) //(X=-53,Y=-33,Z=63)
    TrailEffectPositions(1)=(X=-63,Y=42.5,Z=118)

//=============================================================================
// Sound
//=============================================================================   
    IdleSound=Sound'UT3A_Vehicle_Cicada.UT3CicadaSingles.UT3CicadaEngineLoop02Cue'
    StartUpSound=Sound'UT3A_Vehicle_Cicada.UT3CicadaEngineStart.UT3CicadaEngineStartCue'
    ShutDownSound=Sound'UT3A_Vehicle_Cicada.UT3CicadaEngineStop.UT3CicadaEngineStopCue'
    TargetLockSound=sound'UT3A_Vehicle_Cicada.UT3CicadaSingles.UT3CicadaTargetLock01'
    ExplosionSounds=()
    ExplosionSounds(0)=Sound'UT3A_Vehicle_Cicada.UT3CicadaExplode.UT3CicadaExplodeCue'
    ImpactDamageSounds=()
    ImpactDamageSounds(0)=Sound'UT3A_Vehicle_Cicada.UT3CicadaCollide.UT3CicadaCollideCue'
    BulletSounds = ()
    BulletSounds(0) = Sound'UT3A_Weapon_BulletImpacts.UT3BulletImpactMetal.UT3BulletImpactMetalCue'
    
    SoundVolume=255

//=============================================================================
// Health & Damage
//=============================================================================
    ImpactDamageMult = 0.00003
    MomentumMult=0.400000
    DamagedEffectHealthSmokeFactor=0.65
    DamagedEffectHealthFireFactor=0.40
    DamagedEffectFireDamagePerSec=2.0 

//=============================================================================
// Movement
//=============================================================================

    GroundSpeed=1600
    MaxThrustForce=80.0 //80.0
    LongDamping=0.8 //0.3
    MaxYawRate=1.8 //1.5
    TurnDamping=65.0 //50.0
    MaxRiseForce=130.0 //200
    UpDamping=0.08 //0.05
    MaxStrafeForce=45.0 //65.0
    LatDamping=0.08 //0.05
      
    RollTorqueMax=60 //100
    RollTorqueStrafeFactor=130 //100
    RollTorqueTurnFactor=250 //750
    RollDamping=100.0 //30.0
    PitchTorqueFactor=50.0 //200.0
    PitchTorqueMax=20.0 //35.0
    TurnTorqueFactor=600.0
    TurnTorqueMax=220.0 //200.0   
    
    MaxRandForce=2.0
    RandForceInterval=0.95
    
//=============================================================================
// Entry & Exit
//============================================================================= 
    EntryRadius=300
    EntryPosition=(X=40,Y=0,Z=0)
    ExitPositions(0)=(X=80,Y=-210,Z=25)
    ExitPositions(1)=(X=80,Y=210,Z=25)
    ExitPositions(2)=(X=330,Y=0,Z=35)
    ExitPositions(3)=(X=90,Y=0,Z=160) 
 
//=============================================================================
// Camera
//============================================================================= 
    bDrawMeshInFP=True
    //FPCamPos=(X=265,Y=0,Z=40) //Front Cam
    FPCamPos=(X=40,Y=100,Z=80)  //Launcher Cam, I prefer this one but I encouarge trying both
    
    //Normal
    TPCamDistance=600.000000
    TPCamLookAt=(X=50.0,Y=0.0,Z=0)
    TPCamWorldOffset=(Z=260)
    
}
