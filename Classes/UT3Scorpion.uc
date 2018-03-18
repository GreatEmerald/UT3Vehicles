/*
 * Copyright © 2008, 2014 GreatEmerald
 * Copyright © 2008-2009 Wormbo
 * Copyright © 2012 100GPing100
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

class UT3Scorpion extends EONSScorpion;

var IntBox BoostIconCoords, EjectIconCoords;
var float LastBoostAttempt, SpeedAtBoost;
var() float MinEjectSpeed;
var int AirBoost;
var Sound DriverEjectSnd;

event KImpact(actor other, vector pos, vector impactVel, vector impactNorm) //Modified so we would have control over when we detonate
{
    if (bPrimed)
    {
        bImminentDestruction = true;
//      if (Other != None && Other.IsA('ONSPRV'))
//         ImpactVel = vect(0,0,0);
        Super(ONSRV).KImpact(Other, Pos, ImpactVel, ImpactNorm);
    }
    if (VSize(impactVel) > MinEjectSpeed && bImminentDestruction)
    {
        ImpactVel /= 100;
        if (Other != None && Other.IsA('ONSPRV'))
            ImpactVel = vect(0,0,0);
        SuperEjectDriver();
        HurtRadius(SelfDestructDamage, SelfDestructDamageRadius, SelfDestructDamageType, SelfDestructMomentum, Location);
        TakeDamage(SelfDestructDamage*3, Self, Location, vect(0,0,0), SelfDestructDamageType);
        Super(ONSRV).KImpact(Other, Pos, ImpactVel, ImpactNorm);
    }
}

simulated function DrawHUD(Canvas C)
{
    local PlayerController PC;

    Super.DrawHUD(C);

    // don't draw if we are dead, scoreboard is visible, etc
    PC = PlayerController(Controller);
    if (Health < 1 || PC == None || PC.myHUD == None || PC.MyHUD.bShowScoreboard
        || VSize(Velocity) <= 0)
        return;

    // draw tooltips
    // GEm: FIXME: UT3HudOverlay should be in UT3HUD.u (used by both UT3Style and UT3Vehicles)
    if (Gear > 1 && BoostCount > 0 && !bBoost) //GE: BoostCount > 0 == bReadyToBoost ;)
        class'UT3HudOverlay'.static.DrawToolTip(C, PC, "Jump", C.ClipX*0.5, C.ClipY * 0.92, BoostIconCoords);
    else if (bBoost && (Velocity dot Vector(Rotation)) >= MinEjectSpeed)
        class'UT3HudOverlay'.static.DrawToolTip(C, PC, "Use", C.ClipX*0.5, C.ClipY * 0.92, EjectIconCoords);
}

simulated function Tick(float DT)
{
    local Coords ArmBaseCoords, ArmTipCoords;
    local vector HitLocation, HitNormal;
    local actor Victim;

    Super(ONSWheeledCraft).Tick(DT);

    if (Role == ROLE_Authority && IsHumanControlled() && Rise > 0
        && Level.TimeSeconds - LastBoostAttempt > 1 && Gear > 1)
    {
        Boost();
        LastBoostAttempt = Level.TimeSeconds;
    }

    //If bImminentDestruction, then we have already primed the detonator and hit something - We detonate here because detonating in KImpact seemed to cause General Protection Faults in some circumstances
    if (bImminentDestruction)
    {
        GoToState('Ejecting');              //GE: Eject + delay + explosion
        return;
    }

    //If bAfterburnersOn and boost state don't agree
    if (bBoost != bAfterburnersOn)
    {
        // it means we need to change the state of the vehicle (bAfterburnersOn)
        // to match the desired state (bBoost)
        EnableAfterburners(bBoost); // show/hide afterburner smoke

        // if we just enabled afterburners, set the timer
        // to turn them off after set time has expired
        if (bBoost)
        {
            SetTimer(BoostTime, false);
        }
    }

    if (Role == ROLE_Authority)
    {
        // Afterburners recharge after the change in time exceeds the specified charge duration
        BoostRechargeCounter+=DT;
        if (BoostRechargeCounter > BoostRechargeTime)
        {
            if (BoostCount < 1)
            {
                BoostCount++;
                if( PlayerController(Controller) != None)
                    PlayerController(Controller).ClientPlaySound(BoostReadySound,,,SLOT_Misc);
                //PlaySound(BoostReadySound, SLOT_Misc,128);
            }
            BoostRechargeCounter = 0;
        }
    }
    //=======================
    // @100GPing100
    // Left Blade Arm System
    if (Role == ROLE_Authority && bWeaponIsAltFiring && !bLeftArmBroke)
    {
        //ArmBaseCoords = GetBoneCoords('CarLShoulder');
        //ArmTipCoords = GetBoneCoords('LeftBladeDummy');
        ArmBaseCoords = GetBoneCoords('Blade_L1');
        ArmTipCoords = GetBoneCoords('Blade_L2');
        ArmTipCoords.Origin += vect(0,-80,0) >> Rotation;
        Victim = Trace(HitLocation, HitNormal, ArmTipCoords.Origin, ArmBaseCoords.Origin);

        if (Victim != None && Victim.bBlockActors)
        {
            if (Victim.IsA('Pawn') && !Victim.IsA('Vehicle'))
                Pawn(Victim).TakeDamage(1000, self, HitLocation, Velocity * 100, class'UT3DmgType_ScorpionBlades');
            else
            {
                bLeftArmBroke = True;
                bClientLeftArmBroke = True;
                BladeBreakOff(4, 'Blade_L2', class'ONSRVLeftBladeBreakOffEffect');
                // We use slot 4 here because slots 0-3 can be used by BigWheels mutator.
            }
        }
    }
    if (Role < ROLE_Authority && bClientLeftArmBroke)
    {
        bLeftArmBroke = True;
        bClientLeftArmBroke = False;
        BladeBreakOff(4, 'Blade_L2', class'ONSRVLeftBladeBreakOffEffect');
    }

    // Right Blade Arm System
    if (Role == ROLE_Authority && bWeaponIsAltFiring && !bRightArmBroke)
    {
        //ArmBaseCoords = GetBoneCoords('CarRShoulder');
        //ArmTipCoords = GetBoneCoords('RightBladeDummy');
        ArmBaseCoords = GetBoneCoords('Blade_R1');
        ArmTipCoords = GetBoneCoords('Blade_R2');
        ArmTipCoords.Origin += vect(0,80,0) >> Rotation;
        Victim = Trace(HitLocation, HitNormal, ArmTipCoords.Origin, ArmBaseCoords.Origin);

        if (Victim != None && Victim.bBlockActors)
        {
            if (Victim.IsA('Pawn') && !Victim.IsA('Vehicle'))
                Pawn(Victim).TakeDamage(1000, self, HitLocation, Velocity * 100, class'UT3DmgType_ScorpionBlades');
            else
            {
                bRightArmBroke = True;
                bClientRightArmBroke = True;
                BladeBreakOff(5, 'Blade_R2', class'ONSRVRightBladeBreakOffEffect');
            }
        }
    }
    if (Role < ROLE_Authority && bClientRightArmBroke)
    {
        bRightArmBroke = True;
        bClientRightArmBroke = False;
        BladeBreakOff(5, 'Blade_R2', class'ONSRVRightBladeBreakOffEffect');
    }
    // @100GPing100
    //==========END==========
}

simulated state Ejecting {
Begin:
    SuperEjectDriver();
    Sleep(1.0);
    HurtRadius(SelfDestructDamage, SelfDestructDamageRadius, SelfDestructDamageType, SelfDestructMomentum, Location);
    TakeDamage(SelfDestructDamage*3, Self, Location, vect(0,0,0), SelfDestructDamageType);
}

event Touch(actor Other)
{
    if (Other.IsA('Vehicle'))
    {
        Super.Touch(Other);
        if (bPrimed)
            bImminentDestruction = true;
    }
}

function Boost()
{
    //If we're already boosting, then prime the detonator
    /*if (bBoost)
    {
        bImminentDestruction = true;
        PlaySound(BoostReadySound, SLOT_Misc, 128,,,160);
    }*/

    // If we have a boost ready and we're not currently using it
    //log("UT3: Entering Boost!");
    //log("UT3: BoostRechargeTime: "@BoostRechargeTime);
    //log("UT3: BoostRechargeCounter: "@BoostRechargeCounter);
    if (BoostCount > 0 && !bBoost)
    {
        //log("UT3: Boosting!");
        BoostRechargeCounter=0;
        PlaySound(BoostSound, SLOT_Misc, 128,,,); //Boost sound Pitch 160
        bBoost = true;
        BoostCount--;
        SpeedAtBoost = Velocity dot Vector(Rotation);
        AirBoost = int(!bVehicleOnGround);
    }
    /*else if ((Velocity dot Vector(Rotation)) >= MinEjectSpeed)
    {
        //log("UT3: Kamikadze!");
        bImminentDestruction = true;
        PlaySound(BoostReadySound, SLOT_Misc, 128,,,160);
    }*/
}

/*function VehicleFire(bool bWasAltFire)
{
    if (bWasAltFire)
    {
        Boost();
    }

    else Super(ONSWheeledCraft).VehicleFire(bWasAltFire);   //So we wouldn't shoot when boosting
}*/

function VehicleFire(bool bWasAltFire)
{
    if (bWasAltFire)
    {
        // Boost();
        PlayAnim('Blades_out');
        if (!bLeftArmBroke || !bRightArmBroke)
        {
            PlaySound(ArmExtendSound, SLOT_None, 2.0,,,, False);
            bWeaponIsAltFiring = True;
            ClientPlayForceFeedback(ArmExtendForce);
        }
    }
    else
        Super(ONSWheeledCraft).VehicleFire(bWasAltFire);
}

function AltFire(optional float F)
{
    //avoid sending altfire to weapon
    Super(Vehicle).AltFire(F);
}

function ClientVehicleCeaseFire(bool bWasAltFire)
{
    //avoid sending altfire to weapon
    if (bWasAltFire)
        Super(Vehicle).ClientVehicleCeaseFire(bWasAltFire);
    else
        Super(ONSWheeledCraft).ClientVehicleCeaseFire(bWasAltFire);
}

function ChooseFireAt(Actor A)
{
    if (Pawn(A) != None && Vehicle(A) == None && VSize(A.Location - Location) < 1500 && Controller.LineOfSightTo(A))
    {
        if (!bWeaponIsAltFiring)
            AltFire(0);
    }
    else if (bWeaponIsAltFiring)
        VehicleCeaseFire(true);

    Fire(0);
}

function VehicleCeaseFire(bool bWasAltFire)
{
    if (bWasAltFire)
    {
        PlayAnim('Blades_in');
        if (!bLeftArmBroke || !bRightArmBroke)
        {
            PlaySound(ArmRetractSound, SLOT_None, 2.0,,,, False);
            bWeaponIsAltFiring = False;
            ClientPlayForceFeedback(ArmRetractForce);
        }
    }
    else
        Super.VehicleCeaseFire(bWasAltFire);
}

function SuperEjectDriver()
{
    local Pawn OldPawn;
    local Vector EjectVel;

    OldPawn = Driver;
    KDriverLeave(True);
    if (OldPawn == None)
        return;

    EjectVel = VRand();
    EjectVel.Z = 0.0;
    EjectVel = (Normal(EjectVel) * 0.2 + vect(0.00,0.00,1.00)) * EjectMomentum;
    OldPawn.Velocity = EjectVel;
    OldPawn.SpawnTime = Level.TimeSeconds;
    OldPawn.PlayTeleportEffect(False,False);
    
    PlaySound(DriverEjectSnd, SLOT_None, 1.0, true);
    
}

function bool KDriverLeave(bool bForceLeave)
{
    if (Role == ROLE_Authority && IsHumanControlled() && !bForceLeave && bBoost
        && (Velocity dot Vector(Rotation) >= MinEjectSpeed))
    {
        bImminentDestruction = true;
        PlaySound(BoostReadySound, SLOT_Misc, 128,,,160);
        return false;
    }
    return Super.KDriverLeave(bForceLeave);
}

// GEm: Don't hurt the instigator
simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
    local actor Victims;
    local float damageScale, dist;
    local vector dir;

    if( bHurtEntry )
        return;

    bHurtEntry = true;
    foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
    {
        // don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
        if( (Victims != self) && (Victims != Instigator) && (Victims.Role == ROLE_Authority) && (!Victims.IsA('FluidSurfaceInfo')) )
        {
            dir = Victims.Location - HitLocation;
            dist = FMax(1,VSize(dir));
            dir = dir/dist;
            damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
            Victims.TakeDamage
            (
                damageScale * DamageAmount,
                Instigator,
                Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
                (damageScale * Momentum * dir),
                DamageType
            );
            if (Instigator != None && Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
                Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, Instigator.Controller, DamageType, Momentum, HitLocation);
        }
    }
    bHurtEntry = false;
}

// GEm: Take 150% damage while boosting, 200% damage while detonating
// GEm: TODO: Add Denied! announcement
function TakeDamage (int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, Class<DamageType> DamageType)
{
    if ( bBoost && (instigatedBy != None) && (instigatedBy != self) )
    {
        if (Driver == None)
            Damage *= 2.0;
        else
            Damage *= 1.5;
    }
    Super(ONSRV).TakeDamage(Damage,instigatedBy,HitLocation,Momentum,DamageType);
}

simulated function EnableAfterburners(bool bEnable)
{
    if (bEnable)
    {
        SteerSpeed *= 0.2;
        if (Level.NetMode != NM_DedicatedServer)
        {
            AnimBlendParams(1, 1.0, , , 'Booster_Main2');
            PlayAnim('boosters_out', 1.0, 0.0, 1);
            Afterburner[0] = Spawn(AfterburnerClass[Team],self,,Location + (AfterburnerOffset[0] >> Rotation));
            Afterburner[0].SetBase(self);
            Afterburner[0].SetRelativeRotation(AfterburnerRotOffset[0]);
            Afterburner[1] = Spawn(AfterburnerClass[Team],self,,Location + (AfterburnerOffset[1] >> Rotation));
            Afterburner[1].SetBase(self);
            Afterburner[1].SetRelativeRotation(AfterburnerRotOffset[1]);
        }
    }
    else
    {
        SteerSpeed /= 0.2;
        if (Level.NetMode != NM_DedicatedServer)
        {
            if (Afterburner[0] != None)
            {
                Afterburner[0].Destroy();
            }
            if (Afterburner[1] != None)
            {
                Afterburner[1].Destroy();
            }
            AnimBlendParams(1, 1.0, , , 'Booster_Main2');
            PlayAnim('boosters_in', 1.0, 0.0, 1);
        }
    }
    bAfterburnersOn = bEnable;
}

simulated event KApplyForce(out Vector Force, out Vector Torque)
{
    Super(ONSRV).KApplyForce(Force, Torque);
    // GEm: In UT3 it boosts in the air as well, but increasing force causes antigrav in UT2004
    if (bBoost && (bVehicleOnGround || AirBoost > 0))
    {
        Force += Vector(Rotation);
        Force += Normal(Force) * FMax(BoostForce * FMin(SpeedAtBoost/700.0, 1.0), 1.0);
        if (AirBoost > 0)
            AirBoost++;
        if (AirBoost > 6)
            AirBoost = 0;
    }
}

function DriverLeft()
{
    GoToState('');
    PlayAnim('hatch_open', 1.0, 0.1);

    Super.DriverLeft();
}

event PostBeginPlay()
{
    PlayAnim('hatch_open_Idle', 1.0, 0.0);

    super.PostBeginPlay();
}

event KDriverEnter(Pawn P)
{
    GoToState('Idle');

    super.KDriverEnter(P);
}

simulated state Idle
{
    Begin:
    PlayAnim('hatch_close', 1.0, 0.0);
    FinishAnim();
    LoopAnim('Idle', 1.0, 0.0);
}

// GEm: Gosh darn it Epic and your hardcoded classes
simulated event DrivingStatusChanged()
{
    local int i;
    local Coords WheelCoords;

    Super(ONSVehicle).DrivingStatusChanged();

    if (bDriving && Level.NetMode != NM_DedicatedServer && !bDropDetail)
    {
        Dust.length = Wheels.length;
        for(i=0; i<Wheels.Length; i++)
            if (Dust[i] == None)
            {
                // Create wheel dust emitters.
                WheelCoords = GetBoneCoords(Wheels[i].BoneName);
                Dust[i] = spawn(class'UT3WheelSlipEffect', self,, WheelCoords.Origin + ((vect(0,0,-1) * Wheels[i].WheelRadius) >> Rotation));
                Dust[i].SetBase(self);
                Dust[i].SetDirtColor( Level.DustColor );
            }

        if(bMakeBrakeLights)
        {
            for(i=0; i<2; i++)
                if (BrakeLight[i] == None)
                {
                    BrakeLight[i] = spawn(class'ONSBrakelightCorona', self,, Location + (BrakeLightOffset[i] >> Rotation) );
                    BrakeLight[i].SetBase(self);
                    BrakeLight[i].SetRelativeRotation( rot(0,32768,0) ); // Point lights backwards.
                    BrakeLight[i].Skins[0] = BrakeLightMaterial;
                }
        }
    }
    else
    {
        if (Level.NetMode != NM_DedicatedServer)
        {
            for(i=0; i<Dust.Length; i++)
                Dust[i].Destroy();

            Dust.Length = 0;

            if(bMakeBrakeLights)
            {
                for(i=0; i<2; i++)
                    if (BrakeLight[i] != None)
                        BrakeLight[i].Destroy();
            }
        }

        TurnDamping = 0.0;
    }
}

simulated function AttachDriver(Pawn P)

{
    Local rotator FootDriveL,FootDriveR;
    Local rotator ArmDriveL,ArmDriveR;
    Local rotator ForeArmDriveL, ForeArmDriveR;
    Local rotator ThighDriveL,ThighDriveR;
    Local rotator CalfDriveL,CalfDriveR;
    Local rotator SpineDrive;
    Local rotator NeckDrive;
    super.AttachDriver(P);

    ArmDriveL.Yaw=5000;
    P.SetBoneRotation('Bip01 L UpperArm',ArmDriveL);
    ArmDriveR.Yaw=5000;
    P.SetBoneRotation('Bip01 R UpperArm',ArmDriveR);
    ForeArmDriveL.Yaw=3000;
    ForeArmDriveL.Roll=12000;
    P.SetBoneRotation('Bip01 L ForeArm',ForeArmDriveL);
    ForeArmDriveR.Roll=-12000;
    P.SetBoneRotation('Bip01 R ForeArm',ForeArmDriveR);
    ThighDriveL.Yaw=-10000;
    ThighDriveL.Pitch=2000;
    P.SetBoneRotation('Bip01 L Thigh',ThighDriveL);
    ThighDriveR.Yaw=-10000;
    ThighDriveR.Pitch=-2000;
    P.SetBoneRotation('Bip01 R Thigh',ThighDriveR);
    CalfDriveL.Yaw=2000;
    CalfDriveL.Roll=14000;
    P.SetBoneRotation('Bip01 L Calf',CalfDriveL);
    CalfDriveR.Yaw=1000;
    CalfDriveR.Roll=-14000;
    P.SetBoneRotation('Bip01 R Calf',CalfDriveR);
    SpineDrive.Yaw=2000;
    P.SetBoneRotation('Bip01 Spine',SpineDrive);
    NeckDrive.Yaw=4000;
    P.SetBoneRotation('Bip01 Head',NeckDrive);
    FootDriveL.Yaw=8000;
    P.SetBoneRotation('Bip01 L Foot',FootDriveL);
    FootDriveR.Yaw=8000;
    P.SetBoneRotation('Bip01 R Foot',FootDriveR);
}

simulated function DetachDriver(Pawn P)
{
    P.SetBoneRotation('Bip01 Head');
    P.SetBoneRotation('Bip01 Spine');
    P.SetBoneRotation('Bip01 Spine1');
    P.SetBoneRotation('Bip01 Spine2');
    P.SetBoneRotation('Bip01 L Clavicle');
    P.SetBoneRotation('Bip01 R Clavicle');
    P.SetBoneRotation('Bip01 L UpperArm');
    P.SetBoneRotation('Bip01 R UpperArm');
    P.SetBoneRotation('Bip01 L ForeArm');
    P.SetBoneRotation('Bip01 R ForeArm');
    P.SetBoneRotation('Bip01 L Thigh');
    P.SetBoneRotation('Bip01 R Thigh');
    P.SetBoneRotation('Bip01 L Calf');
    P.SetBoneRotation('Bip01 R Calf');
    P.SetBoneRotation('Bip01 L Foot');
    P.SetBoneRotation('Bip01 R Foot');
    
    Super.DetachDriver(P);
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
    VehicleNameString = "UT3 Scorpion"
    VehiclePositionString="in a Scorpion"

//=============================================================================
// Appearance
//=============================================================================
    DrawScale=1.0
    Mesh = SkeletalMesh'UT3VH_Scorpion_Anims.SK_VH_Scorpion';
    RedSkin = Shader'UT3ScorpionTex.ScorpionSkin';
    BlueSkin = Shader'UT3ScorpionTex.ScorpionSkinBlue';
    //RedSkin=Shader'VMVehicles-TX.RVGroup.RVChassisFinalRED'
    //BlueSkin=Shader'VMVehicles-TX.RVGroup.RVChassisFinalBLUE'

    DrivePos=(X=-20.0,Y=0.0,Z=60.0) //DrivePos=(X=2.0,Y=0.0,Z=50.0)
    DriveRot=(Pitch=8000)

    DriverWeapons(0)=(WeaponClass=Class'UT3ScorpionTurret',WeaponBone="gun_rotate")
    //DriverWeapons(0)=(WeaponClass=Class'UT3ScorpionTurret',WeaponBone="ChainGunAttachment")

    AfterburnerOffset(0) = (X=-80.0,Y=-16.0,Z=21.0)
    AfterburnerOffset(1) = (X=-80.0,Y=16.0,Z=21.0)

    //DamagedEffectOffset=(X=60,Y=10,Z=10)  //Hood Fire Point
    DamagedEffectOffset=(X=-12,Y=-40,Z=0)   //Body Fire Point
    DamagedEffectScale=0.6                  //Body Fire Size
    //DamagedEffectOffset=(X=-80,Y=20,Z=30)   //Booster Fire Point, scale probably needs to be larger than 1.0
    
    HeadlightCoronaOffset(0)=(X=77,Y=39.0,Z=25)
    HeadlightCoronaOffset(1)=(X=77,Y=-39.0,Z=25)
    HeadlightCoronaMaterial=Material'EpicParticles.FlashFlare1'
    //HeadlightCoronaMaterial=Material'EmitterTextures.Flares.EFlareOY'
    HeadlightCoronaMaxSize=45 //45 //65 looks good but probably too large with FlashFlare...except it's also the default UT2004 value

    HeadlightProjectorOffset=(X=75,Y=0,Z=25) //(X=90,Y=0,Z=7)
    HeadlightProjectorRotation=(Yaw=0,Pitch=-1000,Roll=0)
    HeadlightProjectorMaterial=Texture'VMVehicles-TX.RVGroup.RVProjector'
    HeadlightProjectorScale=0.3

    bMakeBrakeLights=true
    BrakeLightOffset(0)=(X=-86,Y=0,Z=45)
    BrakeLightOffset(1)=(X=-92,Y=0,Z=42)
    BrakeLightMaterial=Material'EpicParticles.FlashFlare1' //Material'EpicParticles.FlickerFlare'

//=============================================================================
// Sound
//=============================================================================
    IdleSound = sound'UT3A_Vehicle_Scorpion.UT3ScorpionSingles.UT3ScorpionEngineLoop01Cue'
    StartUpSound = sound'UT3A_Vehicle_Scorpion.UT3ScorpionEngineStart.UT3ScorpionEngineStartCue'
    ShutDownSound = sound'UT3A_Vehicle_Scorpion.UT3ScorpionEngineStop.UT3ScorpionEngineStopCue'
    ArmExtendSound = sound'UT3A_Vehicle_Scorpion.UT3ScorpionBladeExtend.UT3ScorpionBladeExtendCue'
    ArmRetractSound = sound'UT3A_Vehicle_Scorpion.UT3ScorpionBladeRetract.UT3ScorpionBladeRetractCue'
    BladeBreakSound = sound'UT3A_Vehicle_Scorpion.UT3ScorpionBladeBreakOff.UT3ScorpionBladeBreakOffCue'
    BoostSound = Sound'UT3A_Vehicle_Scorpion.UT3ScorpionSingles.UT3ScorpionEjectReadyBeepThrustStartMix'
    BoostReadySound = None
    DriverEjectSnd=Sound'UT3A_Vehicle_Scorpion.UT3ScorpionSingles.UT3ScorpionEject01DestructionWarningMix';
    ImpactDamageSounds = ();
    ImpactDamageSounds(0) = Sound'UT3A_Vehicle_Scorpion.UT3ScorpionCollide.UT3ScorpionCollideCue';
    ExplosionSounds = ();
    ExplosionSounds(0) = Sound'UT3A_Vehicle_Scorpion.UT3ScorpionExplode.UT3ScorpionExplodeCue';
    BulletSounds = ()   
    BulletSounds(0) = Sound'UT3A_Weapon_BulletImpacts.UT3BulletImpactMetal.UT3BulletImpactMetalCue'
   
    SoundVolume=255
//=============================================================================
// Health & Damage
//=============================================================================
    bHasAltFire=False
    MomentumMult=0.25 //?
    DamagedEffectHealthSmokeFactor=0.65
    DamagedEffectHealthFireFactor=0.40 
    DamagedEffectFireDamagePerSec=2.0
    CrushedDamageType=class'DamTypeRVPancake'
    RanOverDamageType=class'DamTypeRVRoadkill'
    SelfDestructDamageType=class'UT3ScorpionSDDamage'
    SelfDestructDamage = 600.0
    SelfDestructDamageRadius = 600.0
    SelfDestructMomentum = 20000
    
//=============================================================================
// Movement
//=============================================================================
    bAllowAirControl = false
    bHasHandBrake=False //GE: Override for the space bar?
    GroundSpeed=950.0000
    EngineBrakeFactor=0.001 //0.0001 def
    EngineInertia=0.008
    SteerBoneName = "Main_Root";
    SteerSpeed=200.00 //200.00 //160 def
    TurnDamping=10 //35 def
    TransRatio=0.18 //0.15 def UT2004
    WheelInertia=0.008
    
    ChassisTorqueScale=0.45 //0.4
    MaxBrakeTorque=22.0 //20 def 
    WheelSuspensionOffset=3.0
    WheelSoftness=0.045  //.025
    WheelSuspensionTravel=35.0  //15
    WheelSuspensionMaxRenderTravel=35.0  //15
    
    BoostForce = 1800.0
    BoostRechargeTime = 5.0
    MinEjectSpeed = 700.0 // GEm: Originally 900, but it feels too much in comparison

    Begin Object Class=SVehicleWheel Name=RRWheel
        BoneName = "B_R_Tire";
        SupportBoneName = "B_R_Axle";

        BoneRollAxis = AXIS_Y;
        BoneSteerAxis = AXIS_Z;
        SupportBoneAxis = AXIS_X;
        SteerType = VST_Fixed;
        BoneOffset = (X=0.0,Y=20.0,Z=-6.0);

        WheelRadius = 20; //27
        //SuspensionTravel = 40;
        bPoweredWheel = true;
        //bHandbrakeWheel = true;
    End Object
    Begin Object Class=SVehicleWheel Name=LRWheel
        BoneName = "B_L_Tire";
        SupportBoneName = "B_L_Axle";

        BoneRollAxis = AXIS_Y;
        BoneSteerAxis = AXIS_Z;
        SupportBoneAxis = AXIS_X;
        SteerType = VST_Fixed;
        BoneOffset = (X=0.0,Y=-20.0,Z=-6.0);

        WheelRadius = 20;
        //SuspensionTravel = 0;
        bPoweredWheel = true;
        //bHandbrakeWheel = true;
    End Object
    Begin Object Class=SVehicleWheel Name=RFWheel
        BoneName = "F_R_Tire";
        SupportBoneName = "F_R_Axle";

        BoneRollAxis = AXIS_Y;
        BoneSteerAxis = AXIS_Z;
        SupportBoneAxis = AXIS_X;
        SteerType = VST_Steered;
        BoneOffset = (X=0.0,Y=20.0,Z=-6.0);

        WheelRadius = 20;
        //SuspensionTravel = 40;
        bPoweredWheel = true;
    End Object
    Begin Object Class=SVehicleWheel Name=LFWheel
        BoneName = "F_L_Tire";
        SupportBoneName = "F_L_Axle";

        BoneRollAxis = AXIS_Y;
        BoneSteerAxis = AXIS_Z;
        SupportBoneAxis = AXIS_X;
        SteerType = VST_Steered;
        BoneOffset = (X=0.0,Y=-20.0,Z=-6.0);

        WheelRadius = 20;
        //SuspensionTravel = 40;
        bPoweredWheel = true;
    End Object
    Wheels(0) = RRWheel;
    Wheels(1) = LRWheel;
    Wheels(2) = RFWheel;
    Wheels(3) = LFWheel;

    Begin Object Class=KarmaParamsRBFull Name=KParams0
        KStartEnabled=True
        KFriction=0.5
        KLinearDamping=0.05
        KAngularDamping=0.05
        KImpactThreshold=700
        KMaxSpeed=2000
        bKNonSphericalInertia=True
        bHighDetailOnly=False
        bClientOnly=False
        bKDoubleTickRate=True
        KInertiaTensor(0)=1.0
        KInertiaTensor(1)=0.0
        KInertiaTensor(2)=0.0
        KInertiaTensor(3)=3.0
        KInertiaTensor(4)=0.0
        KInertiaTensor(5)=3.0
        KCOMOffset=(X=-0.25,Y=0.0,Z=-0.4)
        bDestroyOnWorldPenetrate=True
        bDoSafetime=True
        Name="KParams0"
    End Object
    KParams=KarmaParams'KParams0'

//=============================================================================
// HUD
//=============================================================================
    BoostIconCoords = (X1=2,Y1=843,X2=97,Y2=50)
    EjectIconCoords = (X1=92,Y1=317,X2=50,Y2=50)

//=============================================================================
// Entry & Exit
//=============================================================================
    ExitPositions(0)=(X=0,Y=-150,Z=50)  //Left
    ExitPositions(1)=(X=0,Y=150,Z=50)   //Right
    ExitPositions(2)=(X=0,Y=-150,Z=-50) //Left Below
    ExitPositions(3)=(X=0,Y=150,Z=-50)  //Right Below
    ExitPositions(4)=(X=150,Y=0,Z=50)   //Front
    ExitPositions(5)=(X=0,Y=0,Z=100)    //Roof
    ExitPositions(6)=(X=150,Y=0,Z=-50)  //Front Below
    ExitPositions(7)=(X=-150,Y=0,Z=-50) //Rear Below
    ExitPositions(8)=(X=-150,Y=0,Z=50)  //Rear
    
//=============================================================================
// Entry & Exit
//============================================================================= 
    FPCamPos=(X=-70,Y=0,Z=105)
    TPCamDistance=250.000000
    TPCamLookat=(X=-70,Y=0,Z=0) //X-40
    TPCamWorldOffset=(X=0,Y=0,Z=140) //170-200 is better for aiming high up but to me it makes ground level aim feel awkward
     
}
