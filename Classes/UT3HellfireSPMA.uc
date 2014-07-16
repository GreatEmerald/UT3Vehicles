/*
 * Copyright © 2009 Wormbo
 * Copyright © 2013-2014 José Luís '100GPing100'
 * Copyright © 2013-2014 GreatEmerald
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

class UT3HellfireSPMA extends ONSArtillery;


//=============================================================================
// Inports
//=============================================================================

#exec obj load file=UT3SPMA.uax
//#exec obj load file=../Animations/UT3SPMAAnims.ukx


//=============================================================================
// Properties
//=============================================================================

var float MaxDeploySpeed;
var float DeployTime, UndeployTime;
var Sound DeploySound, UndeploySound;
var IntBox DeployIconCoords;


//=============================================================================
// Variables
//=============================================================================

var enum EDeployState {
    DS_Undeployed,
    DS_Deploying,
    DS_Deployed,
    DS_Undeploying
} DeployState, LastDeployState;
var bool bBotDeploy; // delayed bot deploy flag

var float LastDeployStartTime, LastDeployCheckTime, LastDeployAttempt;
var bool bDrawCanDeployTooltip;

var rotator CannonAim;

var float OldWheelPitch[2];

var VariableTexPanner TreadPanner;
var float TreadVelocityScale;

var Actor BotTarget;

//=============================================================================
// Replication
//=============================================================================

replication
{
    reliable if (Role < ROLE_Authority)
        ServerToggleDeploy;

    reliable if (bNetDirty)
        DeployState;

    reliable if (!bNetOwner)
        CannonAim;
}


simulated function DrawHUD(Canvas C)
{
    local PlayerController PC;

    Super.DrawHUD(C);

    // don't draw if we are dead, scoreboard is visible, etc
    PC = PlayerController(Controller);
    if (Health < 1 || PC == None || PC.myHUD == None || PC.MyHUD.bShowScoreboard || DeployState != DS_Undeployed)
        return;

    // draw deploy tooltip
    if (bDrawCanDeployTooltip)
        class'UT3HudOverlay'.static.DrawToolTip(C, PC, "Jump", C.ClipX * 0.5, C.ClipY * 0.92, DeployIconCoords);
}


simulated function Tick(float DeltaTime)
{
    local DestroyableObjective ObjectiveTarget;
    local int i;

    Super(ONSWheeledCraft).Tick(DeltaTime);

    if (bBotDeploy || Role == ROLE_Authority && IsHumanControlled() && Rise > 0 && Level.TimeSeconds - LastDeployAttempt > 0.1)
    {
        if (bBotDeploy)
        {
            Throttle = 0;
            Steering = 0;
            Rise = 1; // handbrake to quickly slow down
        }
        ServerToggleDeploy();
        if (bBotDeploy && LastDeployStartTime == Level.TimeSeconds)
        {
            bBotDeploy = False;
            Rise = 0;
        }
        LastDeployAttempt = Level.TimeSeconds;
    }
    if (Level.NetMode != NM_DedicatedServer)
    {
        if (Driver != None && DeployState != DS_Undeployed)
        {
            // override brake lights
            for (i = 0; i < 2; ++i)
            {
                if (BrakeLight[i] != None)
                    BrakeLight[i].UpdateBrakelightState(0, 1);
            }

            TreadPanner.PanRate = 0.0;
        }
        else
        {
            // GEm: Stop wheels from rotating (saves performance by piggy-backing as an else code, woo)
            FixFenderRotation('RtFrontFender', 'RtFrontTire', 0);
            FixFenderRotation('LtFrontFender', 'LtFrontTire', 1);

            CopyTreadRotationLeft();
            CopyTreadRotationRight();

            if (TreadPanner != None)
            {
                TreadPanner.PanRate = VSize(Velocity) / TreadVelocityScale;
                if (Velocity Dot Vector(Rotation) < 0)
                    TreadPanner.PanRate = -1 * TreadPanner.PanRate;
            }
        }
    }
    if (IsLocallyControlled() && IsHumanControlled() && Level.TimeSeconds - LastDeployCheckTime > 0.25)
    {
        // check if can be deployed
        bDrawCanDeployTooltip = DeployState == DS_Undeployed && Driver != None && CanDeploy(True);
        LastDeployCheckTime = Level.TimeSeconds;
    }

    if (MortarCamera != None)
    {
        // mouse view aiming for SPMA camera
        bCustomAiming = True;
        bAltFocalPoint = true; // for bots

        if (IsLocallyControlled() && IsHumanControlled())
        {
            if (!MortarCamera.bShotDown && PlayerController(Controller).ViewTarget != MortarCamera)
            {
                PlayerController(Controller).SetViewTarget(MortarCamera);
                PlayerController(Controller).bBehindView = False;
                PlayerController(Controller).ClientSetBehindView(False);
            }

            CustomAim = UT3HellfireSPMACannon(Weapons[ActiveWeapon]).TargetRotation;

            if (bJustDeployed || Level.TimeSeconds - ClientUpdateTime > 0.0222 && CustomAim != LastAim)
            {
                ClientUpdateTime = Level.TimeSeconds;
                ServerAim((CustomAim.Yaw & 0xffff) | (CustomAim.Pitch << 16));
                LastAim = CustomAim;
                bJustDeployed = false;
            }
        }
        else
        {
            if (IsLocallyControlled() && !IsHumanControlled())
            {
                // AI-controlled
                if (Controller.Target != None)
                {
                    if (MortarCamera.bDeployed)
                    {
                        if ( ShootTarget(Controller.Target) != None )
                            ObjectiveTarget = DestroyableObjective(Controller.Target.Owner);
                        else
                            ObjectiveTarget = DestroyableObjective(Controller.Target);
                    }
                    if (ObjectiveTarget != None && (!ObjectiveTarget.LegitimateTargetOf(Bot(Controller)) || !Weapons[ActiveWeapon].CanAttack(ObjectiveTarget)))
                    {
                        //log(self@Instigator.Controller.GetTeamNum()@"Tick: Camera disabled: ObjectiveTarget"@ObjectiveTarget@!ObjectiveTarget.LegitimateTargetOf(Bot(Controller))@"(and see CanAttack above)");
                        MortarCamera.ShotDown();
                        Weapons[ActiveWeapon].FireCountDown = Weapons[ActiveWeapon].AltFireInterval;
                    }

                    AltFocalPoint = Weapons[ActiveWeapon].Location + vector(CustomAim) * Weapons[ActiveWeapon].MaxRange();
                    Controller.Focus = None;
                }
                else
                {
                    // no target, retry later
                    // GEm: Rather wait around a bit, the cannon watchdog will decide to move eventually if we continue not having targets
                    //log(self@Instigator.Controller.GetTeamNum()@"Tick: Camera disabled: No targets");
                    bAltFocalPoint = false;
                    //MortarCamera.ShotDown();
                    //Weapons[ActiveWeapon].FireCountDown = Weapons[ActiveWeapon].AltFireInterval;
                }
            }
            CustomAim = CannonAim;
        }
        Throttle = 0.0;
        Steering = 0.0;
    }
    else
    {
        bCustomAiming = False;
        if (PlayerController(Controller) != None) {
            if (PlayerController(Controller).ViewTarget == MortarCamera)
                PlayerController(Controller).SetViewTarget(Self);
            if (PlayerController(Controller).ViewTarget == Self && PlayerController(Controller).bBehindView != PointOfView()) {
                PlayerController(Controller).bBehindView = PointOfView();
                PlayerController(Controller).ClientSetBehindView(PointOfView());
            }
        }
        else if (IsDeployed() && AIController(Controller) != None)
        {
            bAltFocalPoint = true;
            bCustomAiming = true;
            if (Controller.Target != None)
                CustomAim.Yaw = rotator(Controller.Target.Location - Location).Yaw;
            CustomAim.Pitch = 8192; // 45 degrees up, to fire camera in the target's general direction
            AltFocalPoint = Weapons[ActiveWeapon].Location + vector(CustomAim) * Weapons[ActiveWeapon].MaxRange();
            Controller.Focus = None;
        }
        else
        {
            bAltFocalPoint = false;
        }
    }
}

simulated function FixFenderRotation(name BoneToSet, name BoneToCopy, byte i)
{
    local rotator NewRotation;

    // GEm: Still acts weirdly, unfortunately.
    NewRotation = GetBoneRotation(BoneToSet);
    NewRotation.Pitch = OldWheelPitch[i]-NewRotation.Pitch;
    NewRotation.Roll = 32768;
    NewRotation.Yaw = 32768;
    SetBoneRotation(BoneToSet, NewRotation);
    OldWheelPitch[i] = NewRotation.Pitch;
}

// GEm: Could also copy location, but GetBoneCoords gives absolute, SetBoneLocation takes relative
simulated function CopyTreadRotationLeft()
{
    local rotator NewRotation;

    NewRotation = GetBoneRotation('LtTread_Wheel3');
    SetBoneDirection('LtTread_Wheel1', NewRotation, , , 1);
    SetBoneDirection('LtTread_Wheel2', NewRotation, , , 1);
    SetBoneDirection('LtTread_Wheel4', NewRotation, , , 1);
}

simulated function CopyTreadRotationRight()
{
    local rotator NewRotation;

    NewRotation = GetBoneRotation('RtTread_Wheel3');
    SetBoneDirection('RtTread_Wheel1', NewRotation, , , 1);
    SetBoneDirection('RtTread_Wheel2', NewRotation, , , 1);
    SetBoneDirection('RtTread_Wheel4', NewRotation, , , 1);
}

function ServerAim(int NewYaw)
{
    CustomAim.Yaw = NewYaw & 0xffff;
    CustomAim.Pitch = NewYaw >>> 16;
    CustomAim.Roll = 0;
    CannonAim = CustomAim;
}


function bool CanAttack(Actor Other)
{
    local Pawn P;
    local bool bResult;

    // if far away or objective, check if can hit with deployed artillery
    if (DeployState == DS_Undeployed && (Controller.PlayerReplicationInfo.Team == None || Controller.PlayerReplicationInfo.Team.Size > 1) && VSize(Other.Location - Location) > 1000.0 && (VSize(Velocity) > MaxDeploySpeed || CanDeploy()) && (Other.IsA('Pawn') || Other.IsA('GameObjective')))
    {
        P = Pawn(Other);
        if ((P == None || P.bStationary || (!P.bCanFly && VSize(Other.Location - Location) > 5000.0)) && Weapons[1].CanAttack(Other)) {
            BotTarget = Other;
            bBotDeploy = True;
            return true;
        }
    }

    bResult = Super.CanAttack(Other);
    /*if (ActiveWeapon == 1)
        log(self@Weapons[ActiveWeapon]@"CanAttack"@Other@bResult@"Bot orders"@Bot(Instigator.Controller).GoalString);*/
    return bResult;
}


function ShouldTargetMissile(Projectile P)
{
    if (Health < 200 && Bot(Controller) != None && Level.Game.GameDifficulty > RandRange(4, 8) && VSize(P.Location - Location) < VSize(P.Velocity)) {
        // not much health left, so get out to avoid getting killed
        KDriverLeave(false);
        TeamUseTime = Level.TimeSeconds + 4;
        return;
    }

    // otherwise maybe try shooting down incoming AVRiLs if not deployed
    if (DeployState == DS_Undeployed)
        Super(ONSWheeledCraft).ShouldTargetMissile(P);
}


/**
Check whether the SPMA can be deployed.
*/
simulated function bool CanDeploy(optional bool bNoMessage)
{
    local int i;
    local bool bOneUnstable;

    if (VSize(Velocity) > MaxDeploySpeed) {
        if (!bNoMessage && PlayerController(Controller) != None)
            PlayerController(Controller).ReceiveLocalizedMessage(class'UT3DeployMessage', 0);
        return false;
    }

    if (IsFiring())
        return false;

    Rise = 0;
    for (i = 0; i < Wheels.Length; i++) {
        if (!Wheels[i].bWheelOnGround) {
            if (!bOneUnstable) {
                // ignore if just one of the six wheels is unstable
                bOneUnstable = True;
                continue;
            }
            if (!bNoMessage && PlayerController(Controller) != None)
                PlayerController(Controller).ReceiveLocalizedMessage(class'UT3DeployMessage', 1);
            return false;
        }
    }
    return true;
}


function bool IsDeployed()
{
    return DeployState == DS_Deployed;
}


function ServerToggleDeploy()
{
    if (CanDeploy())
        GotoState('Deploying');
}


function ChangeDeployState(EDeployState NewState)
{
    DeployState = NewState;
    Level.NetUpdateTime = Level.TimeSeconds - 1;
    DeployStateChanged();
}


simulated function PostNetReceive()
{
    Super.PostNetReceive();

    if (LastDeployState != DeployState)
    {
        LastDeployState = DeployState;
        DeployStateChanged();
    }
}


simulated function DeployStateChanged()
{
    switch (DeployState)
    {
        case DS_Deploying:
            LastDeployStartTime = Level.TimeSeconds;
            SetVehicleDeployed();
            if (DeploySound != None)
                PlaySound(DeploySound, SLOT_Misc, 1.0);
            break;

        case DS_Deployed:
            BotRetryTarget();
            break;

        case DS_UnDeploying:
            LastDeployStartTime = Level.TimeSeconds;
            SetVehicleUndeploying();
            if (UndeploySound != None)
                PlaySound(UndeploySound, SLOT_Misc, 1.0);
            break;

        case DS_Undeployed:
            SetVehicleUnDeployed();
            break;
    }
}

simulated function SetVehicleDeployed()
{
    local int i;

    // play shutdown sound
    if (Driver != None && ShutdownSound != None)
        PlaySound(ShutdownSound, SLOT_None, 1.0);
    if (AmbientSound != None)
        AmbientSound = None;

    // HACK: don't play engine sounds when entering/leaving while deployed
    IdleSound = None;
    StartupSound = None;
    ShutdownSound = None;

    // make immobile
    SetPhysics(PHYS_None);
    SetBase(None); // Ensure we are not hooked on something (eg another vehicle)
    bStationary = true;
    bMovable = false;
    bCannotBeBased = true;
    SetActiveWeapon(1);
    Weapons[1].bForceCenterAim = False;
    Weapons[1].FireCountdown = DeployTime;

    // stop wheels and dirt effects
    for (i = 0; i < Wheels.Length; ++i) {
        Wheels[i].SpinVel = 0.0;
        Wheels[i].SlipVel = 0.0;
    }
}

simulated function SetVehicleUndeployed()
{
    // restore engine sounds after undeplocing
    IdleSound = default.IdleSound;
    StartupSound = default.StartupSound;
    ShutdownSound = default.ShutdownSound;

    if (Driver != None && Health > 0) {
        // play startup sounds
        AmbientSound = IdleSound;
        if (StartupSound != None)
            PlaySound(StartupSound, SLOT_None, 1.0);
    }

    // restore mobility
    bCannotBeBased = false;
    bStationary = false;
    bMovable = true;
    SetPhysics(PHYS_Karma);
    SetActiveWeapon(0);
}

simulated function SetVehicleUndeploying()
{
    Weapons[1].bForceCenterAim = True;
    //log(self@Instigator.Controller.GetTeamNum()@"SetVehicleUndeploying: Camera disabled"@MortarCamera);
    if (MortarCamera != None)
        MortarCamera.ShotDown();
}

function BotRetryTarget()
{
    local Bot B;

    if (Instigator == None)
        return;

    B = Bot(Instigator.Controller);

    if (B == None)
        return;

    if (BotTarget != None && CanAttack(BotTarget))
    {
        //log(self@Instigator.Controller.GetTeamNum()@"BotRetryTarget: resuming firing at"@BotTarget);
        ChooseFireAt(BotTarget);
    }
    else if (B.Enemy != None && CanAttack(B.Enemy))
    {
        //log(self@Instigator.Controller.GetTeamNum()@"BotRetryTarget: Lost orginal target, but found new:"@B.Enemy);
        ChooseFireAt(B.Enemy);
    }
    else
    {
        //log(self@Instigator.Controller.GetTeamNum()@"BotRetryTarget: Lost target, welp, that was wasted time...");
        bBotDeploy = true;
    }

}

function int LimitPitch(int Pitch)
{
    if (MortarCamera != None)
        return Clamp(Pitch, -16384, 16383);

    return Super(ONSWheeledCraft).LimitPitch(Pitch);
}


function VehicleFire(bool bWasAltFire)
{
    if (MortarCamera != None && (bWasAltFire || !MortarCamera.bDeployed && !MortarCamera.bShotDown)) {
        bWasAltFire = True;
        if (!MortarCamera.bDeployed) {
            if (AIController(Instigator.Controller) != None)
                return;

            MortarCamera.Deploy();
            CustomAim = Weapons[ActiveWeapon].WeaponFireRotation;
            Weapons[ActiveWeapon].FireCountdown = Weapons[ActiveWeapon].AltFireInterval;
            return;
        }
        else if (AIController(Instigator.Controller) != None) {
            bWasAltFire = false;
        }
        else {
            //log(self@Instigator.Controller.GetTeamNum()@"VehicleFire: No AI controller, Camera disabled");
            MortarCamera.ShotDown();
            return;
        }
    }
    Super(ONSWheeledCraft).VehicleFire(bWasAltFire);
}


simulated function PrevWeapon()
{
    Super(ONSWheeledCraft).PrevWeapon(); // skip ONSArtillery implementation
}

simulated function NextWeapon()
{
    Super(ONSWheeledCraft).NextWeapon(); // skip ONSArtillery implementation
}


event ApplyFireImpulse(bool bAltFire)
{
    Super(ONSWheeledCraft).ApplyFireImpulse(bAltFire); // skip ONSArtillery implementation
}


function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
    bMovable = True;
    SetPhysics(PHYS_Karma); // ONSVehicle expects PHYS_Karma when dying
    //log(self@Instigator.Controller.GetTeamNum()@"Died: Camera disabled"@MortarCamera);
    if (MortarCamera != None)
        MortarCamera.ShotDown();

    Super.Died(Killer, damageType, HitLocation);
}


state Deployed
{
    function MayUndeploy()
    {
        ServerToggleDeploy();
    }

    function ServerToggleDeploy()
    {
        if (!IsFiring())
            GotoState('Undeploying');
    }

    /**
    Makes sure the wheels are still on stable ground, otherwise undeploys.
    */
    function CheckStability()
    {
        local int i, Count;
        local vector WheelLoc, XAxis, YAxis, ZAxis, HL, HN;

        GetAxes(Rotation, XAxis, YAxis, ZAxis);

        for (i = 0; i < Wheels.Length && Count <= 1; i++) {
            WheelLoc = Location + (Wheels[i].WheelPosition >> Rotation);
            if (Trace(HL, HN, WheelLoc - (ZAxis * (Wheels[i].WheelRadius + Wheels[i].SuspensionTravel)), WheelLoc, false, vect(1,1,1)) == None)
                Count++;
        }
        if (Count > 1) {
            // unstable!
            SetPhysics(PHYS_Karma);
            GotoState('UnDeploying');
            return;
        }
    }

    function BeginState()
    {
        ChangeDeployState(DS_Deployed);
        if (Role == ROLE_Authority)
            SetTimer(1.0, true); // start checking stability
    }

    function EndState()
    {
        SetTimer(0.0, false);
    }
}

state UnDeploying
{
    ignores ServerToggleDeploy;

    function BeginState()
    {
        /* 100GPing100 BEGIN */
        PlayAnim('UnDeploying', 1.0, 0.1);
        /* 100GPing100 END */
        SetTimer(UnDeployTime, False);
        ChangeDeployState(DS_UnDeploying);
    }

    function Timer()
    {
        ChangeDeployState(DS_UnDeployed);
        GotoState('');
    }
}

state Deploying
{
    ignores ServerToggleDeploy;

    function BeginState()
    {
        /* 100GPing100 BEGIN */
        PlayAnim('Deploying', 1.0, 0.1);
        /* 100GPing100 END */
        SetTimer(DeployTime, False);
        ChangeDeployState(DS_Deploying);
    }

    function Timer()
    {
        GotoState('Deployed');
    }
}


simulated event Destroyed()
{
    //log(self@Instigator.Controller.GetTeamNum()@"Destroyed: Camera disabled"@MortarCamera);
    if (MortarCamera != None)
        MortarCamera.ShotDown();

    if (TreadPanner != None )
    {
        Level.ObjectPool.FreeObject(TreadPanner);
        TreadPanner = None;
    }

    Super(ONSWheeledCraft).Destroyed();
}

function DriverLeft()
{
    //log(self@"DriverLeft: Camera disabled"@MortarCamera);
    if (MortarCamera != None)
        MortarCamera.ShotDown();

    /* 100GPing100 BEGIN */
    PlayAnim('GetOut', 1.0, 0.1);
    /* 100GPing100 END */

    Super(ONSWheeledCraft).DriverLeft();
}


/* 100GPing100 BEGIN */
event PostBeginPlay()
{
    PlayAnim('InActiveStill', 1.0, 0.0);

    if ( Level.NetMode != NM_DedicatedServer )
        SetupTreads();

    super.PostBeginPlay();
}

simulated function SetupTreads()
{
    TreadPanner = VariableTexPanner(Level.ObjectPool.AllocateObject(class'VariableTexPanner'));
    if (TreadPanner != None)
    {
        TreadPanner.Material = Skins[1];
        TreadPanner.PanDirection = rot(0, 16384, 0);
        TreadPanner.PanRate = 0.0;
        Skins[1] = TreadPanner;
    }
}

simulated event DrivingStatusChanged()
{
    Super.DrivingStatusChanged();

    if (!bDriving && TreadPanner != None)
        TreadPanner.PanRate = 0.0;
}

event KDriverEnter(Pawn P)
{
    PlayAnim('GetIn', 1.0, 0.0);

    super.KDriverEnter(P);
}
/* 100GPing100 END */

simulated event SVehicleUpdateParams()
{
    local int i;

    Super(ONSVehicle).SVehicleUpdateParams();

    for(i=0; i<Wheels.Length; i++)
    {
        Wheels[i].Softness = WheelSoftness;
        Wheels[i].PenScale = WheelPenScale;
        Wheels[i].PenOffset = WheelPenOffset;
        Wheels[i].LongSlip = WheelLongSlip;
        Wheels[i].LatSlipFunc = WheelLatSlipFunc;
        Wheels[i].Restitution = WheelRestitution;
        Wheels[i].Adhesion = WheelAdhesion;
        Wheels[i].WheelInertia = WheelInertia;
        Wheels[i].LongFrictionFunc = WheelLongFrictionFunc;
        Wheels[i].HandbrakeFrictionFactor = WheelHandbrakeFriction;
        Wheels[i].HandbrakeSlipFactor = WheelHandbrakeSlip;
        //Wheels[i].SuspensionTravel = WheelSuspensionTravel;
        //Wheels[i].SuspensionOffset = WheelSuspensionOffset;
        //Wheels[i].SuspensionMaxRenderTravel = WheelSuspensionMaxRenderTravel;
    }

    if(Level.NetMode != NM_DedicatedServer && bMakeBrakeLights)
    {
        for(i=0; i<2; i++)
        {
            if (BrakeLight[i] != None)
            {
                BrakeLight[i].SetBase(None);
                BrakeLight[i].SetLocation( Location + (BrakelightOffset[i] >> Rotation) );
                BrakeLight[i].SetBase(self);
                BrakeLight[i].SetRelativeRotation( rot(0,32768,0) );
                BrakeLight[i].Skins[0] = BrakeLightMaterial;
            }
        }
    }
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> DamageType)
{                            //Make sure you don't hurt yourself with a combo
    if (InstigatedBy != self || DamageType == VehicleDrowningDamType)
        Super.TakeDamage(Damage, instigatedBy, Hitlocation, Momentum, damageType);
}

/*function ChooseFireAt(Actor A)
{
    if (ActiveWeapon == 1)
        log(self@Instigator.Controller.GetTeamNum()@"ChooseFireAt"@A);
    Super.ChooseFireAt(A);
}*/


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
    /* 100GPing100 BEGIN */

    Mesh = SkeletalMesh'UT3VH_SPMA_Anims.SK_VH_SPMA';
    RedSkin = Shader'UT3SPMATex.Body.RedSkin';
    BlueSkin = Shader'UT3SPMATex.Body.BlueSkin';
    Skins(1) = Shader'UT3SPMATex.Threads.ThreadsSkin'

    FlagBone = 'Body';

    DriverWeapons = ();
    DriverWeapons(0) = (WeaponClass=class'UT3HellfireSPMASideGun',WeaponBone="SecondaryTurret_YawLift");
    DriverWeapons(1) = (WeaponClass=class'UT3HellfireSPMACannon',WeaponBone="MainTurret_Yaw");

    Wheels = ();
    Begin Object Class=SVehicleWheel Name=LWheel1
        BoneName="LtFrontTire"
        BoneRollAxis=AXIS_Y
        BoneSteerAxis=AXIS_Z
        BoneOffset=(X=0.0,Y=-17.0,Z=0.0)
        WheelRadius=40
        bPoweredWheel=True
        bHandbrakeWheel=True
        SteerType=VST_Steered
    End Object
    Wheels(0)=SVehicleWheel'LWheel1'

    Begin Object Class=SVehicleWheel Name=LWheel2
        BoneName="LtTread_Wheel3"
        BoneRollAxis=AXIS_Y
        BoneSteerAxis=AXIS_Z
        BoneOffset=(X=30.0,Y=15.0,Z=18.0) // GEm: Or Y is 4/15, Z is 5/18 (more truthful but not symmetric)
        WheelRadius=40
        bPoweredWheel=True
        bHandbrakeWheel=True
        bTrackWheel=True
        bLeftTrack=True
        SuspensionTravel=10.0
        SuspensionMaxRenderTravel=0.0
        SuspensionOffset=0.0
        SteerType=VST_Fixed
    End Object
    Wheels(1)=SVehicleWheel'LWheel2'

    Begin Object Class=SVehicleWheel Name=RWheel2
        BoneName="RtTread_Wheel3"
        BoneRollAxis=AXIS_Y
        BoneSteerAxis=AXIS_Z
        BoneOffset=(X=30.0,Y=-15.0,Z=18.0)
        WheelRadius=40
        bPoweredWheel=True
        bHandbrakeWheel=True
        bTrackWheel=True
        SuspensionTravel=10.0
        SuspensionMaxRenderTravel=0.0
        SuspensionOffset=0.0
        SteerType=VST_Fixed
    End Object
    Wheels(2)=SVehicleWheel'RWheel2'

    Begin Object Class=SVehicleWheel Name=RWheel1
        BoneName="RtFrontTire"
        BoneRollAxis=AXIS_Y
        BoneSteerAxis=AXIS_Z
        BoneOffset=(X=0.0,Y=17.0,Z=0.0)
        WheelRadius=40
        bPoweredWheel=True
        bHandbrakeWheel=True
        SteerType=VST_Steered
    End Object
    Wheels(3)=SVehicleWheel'RWheel1'

    /* 100GPing100 END */

    VehiclePositionString="in a Hellfire SPMA"
    VehicleNameString = "UT3 Hellfire SPMA"

    DeployIconCoords = (X1=2,Y1=371,X2=124,Y2=115)

    PassengerWeapons = ()
    FireImpulse      = (X=0) // sidegun shouldn't recoil and main cannon is fired when deployed
    bAllowViewChange = false // who would want to use it 1st-person anyway

    GroundSpeed = 650.0

    bStasis = False // would interfer with aiming when deployed

    bNetNotify      = True
    DeployState     = DS_Undeployed
    LastDeployState = DS_Undeployed

    MaxDeploySpeed = 100.0
    DeployTime     = 2.1
    UndeployTime   = 2.0
    DeploySound    = Sound'SPMADeploy'
    UndeploySound  = Sound'SPMADeploy'

    SoundVolume    = 255
    SoundRadius    = 300
    IdleSound      = Sound'SPMAEngineIdle'
    StartUpSound   = Sound'SPMAEngineStart'
    ShutDownSound  = Sound'SPMAEngineStop'

    bDrawDriverInTP = false
    DriverDamageMult = 0.0
    TreadVelocityScale = 30.0

    HeadlightCoronaOffset(0)=(X=195,Y=85,Z=70)
    HeadlightCoronaOffset(1)=(X=195,Y=-85,Z=70)
    HeadlightCoronaMaterial=Material'EmitterTextures.Flares.EFlareOY'
    HeadlightCoronaMaxSize=75
    HeadlightProjectorMaterial=None

    BrakeLightOffset(0)=(X=-145,Y=37,Z=55)
    BrakeLightOffset(1)=(X=-145,Y=-37,Z=55)
    BrakeLightMaterial=Material'EpicParticles.FlickerFlare'
}
