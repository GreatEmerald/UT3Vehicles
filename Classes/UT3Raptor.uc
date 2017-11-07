/*
 * Copyright © 2008-2009 Wormbo
 * Copyright © 2008-2009, 2014 GreatEmerald
 * Copyright © 2012 100GPing100
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

class UT3Raptor extends ONSAttackCraft;


//===========================
// @100GPing100
#exec obj load file=../Animations/UT3VH_Raptor_Anims.ukx
#exec obj load file=../Textures/UT3RaptorTex.utx

/* Wing's rotation rate. */
var float WingsRPS;
/* Current rotation of the wings. */
var Rotator WingsRotation;
/* Current rudders' rotation. */
var Rotator RuddersRotation;

var int RudderYawContraint;

//
// Called when spawned.
//
event PostBeginPlay()
{
    WingsRotation = rot(16384,0,0);

    SetBoneRotation('Rt_Wing', WingsRotation, 0, 1);
    SetBoneRotation('Lft_Wing', WingsRotation, 0, 1);

    Super.PostBeginPlay();
}

simulated function PostNetBeginPlay()
{
    Super.PostNetBeginPlay();

    if (Role == ROLE_Authority)
        if (Weapons.Length == 2 && ONSLinkableWeapon(Weapons[0]) != None)
            ONSLinkableWeapon(Weapons[0]).ChildWeapon = Weapons[1];
}

//
// Called when the driver leaves the vehicle.
//
function bool KDriverLeave(bool bForceLeave)
{
    SetTimer(0.05, true);

    return super.KDriverLeave(bForceLeave);
}

//
// Close the wings after the driver leaves.
//
event Timer()
{
    if (WingsRotation.Pitch < 16384)
    {
        WingsRotation.Pitch += WingsRPS * 0.05 * 100;
        if (WingsRotation.Pitch > 16384)
        {
            WingsRotation.Pitch = 16384;
            SetTimer(0, false);
        }
    }

    WingsRotation.Yaw = 0;
    WingsRotation.Roll = 0;

    SetBoneRotation('Rt_Wing', WingsRotation, 0, 1);
    SetBoneRotation('Lft_Wing', WingsRotation, 0, 1);
}

//
// Self-explanatory...
//
function Tick(float DeltaTime)
{
    Super.Tick(DeltaTime);

    Wings(DeltaTime);
    Rudders(DeltaTime);
    Guns();
}

//
// Animate the wings depending on thrust.
//
function Wings(float DeltaTime)
{
    // 90° = 16384 RUU
    if (OutputThrust > 0 && WingsRotation.Pitch < 16384)
    {
        WingsRotation.Pitch += WingsRPS * DeltaTime * 100;
        if (WingsRotation.Pitch > 16384)
            WingsRotation.Pitch = 16384;
    }
    else if (OutputThrust == 0 && WingsRotation.Pitch > 0)
    {
        WingsRotation.Pitch -= WingsRPS * DeltaTime * 100;
        if (WingsRotation.Pitch < 0)
            WingsRotation.Pitch = 0;
    }
    else if (OutputThrust < 0 && WingsRotation.Pitch > 0)
    {
        WingsRotation.Pitch -= WingsRPS * 2 * DeltaTime * 100;
        if (WingsRotation.Pitch < 0)
            WingsRotation.Pitch = 0;
    }

    WingsRotation.Yaw = 0;
    WingsRotation.Roll = 0;

    SetBoneRotation('Rt_Wing', WingsRotation, 0, 1);
    SetBoneRotation('Lft_Wing', WingsRotation, 0, 1);
}

//
// Animate the rudders depending on the rotation change.
//
function Rudders(float DeltaTime)
{
    local Rotator NewRotation, NewDriverYaw;

    // Normalize Rotation and DriverViewYaw or we get weird values..
    SetRotation(Normalize(Rotation));
    NewDriverYaw.Yaw = DriverViewYaw;
    DriverViewYaw = Normalize(NewDriverYaw).Yaw;

    // 3000 = The angle at which the angle of the rudders is of 30°
    NewRotation.Yaw = RudderYawContraint * (Rotation.Yaw - DriverViewYaw) / 3000;

    // Limit the angle.
    if (NewRotation.Yaw > RudderYawContraint)
        NewRotation.Yaw = RudderYawContraint;
    else if (NewRotation.Yaw < -RudderYawContraint)
        NewRotation.Yaw = -RudderYawContraint;

    // Update rudders' rotation.
    if (NewRotation.Yaw > 1000 || NewRotation.Yaw < -1000)
        RuddersRotation.Yaw += 182 * DeltaTime * NewRotation.Yaw / 100;
    else
    {
        // Not turning.
        if (RuddersRotation.Yaw > 200)
            RuddersRotation.Yaw -= 182 * DeltaTime * 30;
        else if (RuddersRotation.Yaw < -200)
            RuddersRotation.Yaw += 182 * DeltaTime * 30;
    }

    // Limit the current angle.
    if (RuddersRotation.Yaw > RudderYawContraint)
        RuddersRotation.Yaw = RudderYawContraint;
    else if (RuddersRotation.Yaw < -RudderYawContraint)
        RuddersRotation.Yaw = -RudderYawContraint;

    RuddersRotation.Roll = 0;
    RuddersRotation.Pitch = 0;

    // Apply the new rotation.
    SetBoneRotation('Rudder_Rt', RuddersRotation, 0, 1);
    SetBoneRotation('Rudder_left', RuddersRotation, 0, 1);
}

//
// Animates the guns depending on the driver's view.
//
function Guns()
{
    local Rotator GunsRotation;

    GunsRotation.Pitch = -DriverViewPitch;

    SetBoneRotation('rt_gun', GunsRotation, 0, 1);
    SetBoneRotation('left_gun', GunsRotation, 0, 1);
}

//
// The next 3 functions { Died, Destroyed, DrivingStatusChanged } have been
// overriden to disable the streams.
//
function Died(Controller Killer, class<DamageType> DmgType, Vector HitLocation)
{
    local int i;

    if (Level.NetMode != NM_DedicatedServer)
    {
        for (i = 0; i < TrailEffects.Length; i++)
            TrailEffects[i].Destroy();
        TrailEffects.Length = 0;
    }
    Super(ONSChopperCraft).Died(Killer, DmgType, HitLocation);
}
simulated function Destroyed()
{
    local int i;

    if (Level.NetMode != NM_DedicatedServer)
    {
        for (i = 0; i < TrailEffects.Length; i++)
            TrailEffects[i].Destroy();
        TrailEffects.Length = 0;
    }
    Super(ONSChopperCraft).Destroyed();
}
simulated event DrivingStatusChanged()
{
    local int i;

    if (bDriving && Level.NetMode != NM_DedicatedServer && !bDropDetail)
    {
        if (TrailEffects.Length == 0)
        {
            TrailEffects.Length = TrailEffectPositions.Length;

            for(i=0;i<TrailEffects.Length;i++)
            {
                if (TrailEffects[i] == None)
                {
                    TrailEffects[i] = spawn(TrailEffectClass, self,, Location + (TrailEffectPositions[i] >> Rotation) );
                    TrailEffects[i].SetBase(self);
                    TrailEffects[i].SetRelativeRotation( rot(0,32768,0) );
                }
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

    Super(ONSChopperCraft).DrivingStatusChanged();
}
// @100GPing100
//============END============


//=============================================================================
// Default values
//=============================================================================

/*
GE: Test log
Testing values from UT3 code without changes ;)
Test 1: Woah! The Raptor flies looking downwards and spinning like crazy!
Test 2: Commented out all the Damping values. It's now good, but sinks!
Test 3: Sinks because of a huge MaxRiseForce. 500 is unacceptable. The Raptor is too agile now! Let's try splitting in two.
Test 4: 275 works well, although it still gives slight sinkness. But that's OK.
*/

defaultproperties
{
    //===========================
    // @100GPing100
    Mesh = SkeletalMesh'UT3VH_Raptor_Anims.SK_VH_Raptor';
    RedSkin = Shader'UT3RaptorTex.RaptorSkin';
    BlueSkin = Shader'UT3RaptorTex.RaptorSkinBlue';

    TrailEffectPositions(0) = (X=-105,Y=-35,Z=-15);
    TrailEffectPositions(1) = (X=-105,Y=35,Z=-15);

    VehiclePositionString = "in a UT3 Raptor";

    DriverWeapons[0] = (WeaponClass=class'UT3RaptorWeapon',WeaponBone="rt_gun")
    DriverWeapons[1] = (WeaponClass=class'UT3RaptorWeaponLeft',WeaponBone="left_gun")

    WingsRPS = 182; // 182 ~= 1°
    RudderYawContraint = 2048 // 30° ~= 5461 RUU

    // Sounds.
    IdleSound = Sound'UT3A_Vehicle_Raptor.Sounds.A_Vehicle_Raptor_EngineLoop01';
    StartUpSound = Sound'UT3A_Vehicle_Raptor.Sounds.A_Vehicle_Raptor_Start01';
    ShutDownSound = Sound'UT3A_Vehicle_Raptor.Sounds.A_Vehicle_Raptor_Stop01';
    ImpactDamageSounds(0) = Sound'UT3A_Vehicle_Raptor.Sounds.A_Vehicle_Raptor_Collide01';
    ImpactDamageSounds(1) = Sound'UT3A_Vehicle_Raptor.Sounds.A_Vehicle_Raptor_Collide02';
    ImpactDamageSounds(2) = Sound'UT3A_Vehicle_Raptor.Sounds.A_Vehicle_Raptor_Collide01';
    ImpactDamageSounds(3) = Sound'UT3A_Vehicle_Raptor.Sounds.A_Vehicle_Raptor_Collide02';
    ImpactDamageSounds(4) = Sound'UT3A_Vehicle_Raptor.Sounds.A_Vehicle_Raptor_Collide01';
    ImpactDamageSounds(5) = Sound'UT3A_Vehicle_Raptor.Sounds.A_Vehicle_Raptor_Collide02';
    ImpactDamageSounds(6) = Sound'UT3A_Vehicle_Raptor.Sounds.A_Vehicle_Raptor_Collide01';
    ExplosionSounds(0) = Sound'UT3A_Vehicle_Raptor.Sounds.A_Vehicle_Raptor_Explode01';
    ExplosionSounds(1) = Sound'UT3A_Vehicle_Raptor.Sounds.A_Vehicle_Raptor_Explode01';
    ExplosionSounds(2) = Sound'UT3A_Vehicle_Raptor.Sounds.A_Vehicle_Raptor_Explode01';
    ExplosionSounds(3) = Sound'UT3A_Vehicle_Raptor.Sounds.A_Vehicle_Raptor_Explode01';
    ExplosionSounds(4) = Sound'UT3A_Vehicle_Raptor.Sounds.A_Vehicle_Raptor_Explode01';
    // @100GPing100
    //============EDN============
    VehicleNameString = "UT3 Raptor"

    //DriverWeapons[0] = (WeaponClass=class'UT3RaptorWeapon',WeaponBone=PlasmaGunAttachment)

    //SCREW THOSE UT3 CODE OPTIONS, THEY'RE ALL FAKE!!!
    /*UprightStiffness=400.000000 //GE: Decreased by 100, whatever that does
    //UprightDamping=20.000000    //Decreased from 300, but according to the manual this has no effect
    MaxThrustForce=750.000000   //Increased a lot. Might give strange side effects!
    //LongDamping=0.700000        //Increased a lot. Might give strange side effects!
    MaxStrafeForce=450.000000   //Increased a lot. Might give strange side effects!
    //LatDamping=0.700000         //Increased a lot. Might give strange side effects!
    //MaxRiseForce=500.000000     //Increased a lot. Might give strange side effects!
    //UpDamping=0.700000          //Increased a lot. Might give strange side effects!
    TurnTorqueFactor=8000.000000//Increased a lot. Might give strange side effects!
    TurnTorqueMax=10000.000000  //Increased a lot. Might give strange side effects!
    //TurnDamping=1.200000        //Decreased a lot. Might give strange side effects!
    PitchTorqueFactor=450.000000//Increased a lot. Might give strange side effects!
    PitchTorqueMax=60.000000    //Increased a lot. Might give strange side effects!
    //PitchDamping=0.300000       //Decreased a lot. Might give strange side effects!
    //RollDamping=0.100000        //Decreased a lot. Might give strange side effects!
    MaxRandForce=25.000000      //Increased a lot. Might give strange side effects!
    RandForceInterval=0.500000  //Somewhat decreased
    */
    /*UprightStiffness=450.000000 //GE: Decreased
    UprightDamping=160.000000    //Decreased from 300, but according to the manual this has no effect
    MaxThrustForce=200.000000   //Increased. Increased all below too.
    //LongDamping=0.375000
    MaxStrafeForce=265.000000
    //LatDamping=0.375000
    MaxRiseForce=275.000000
    //UpDamping=0.375000
    TurnTorqueFactor=4300.000000
    TurnTorqueMax=5100.000000
    //TurnDamping=25.600000        //Decreased here.
    PitchTorqueFactor=325.000000
    PitchTorqueMax=47.500000
    //PitchDamping=10.150000       //Decreased here.
    //RollDamping=15.050000        //Decreased here.
    MaxRandForce=14.000000
    RandForceInterval=0.625000  Somewhat decreased */
    GroundSpeed=2500            //We are faster now! This should be a true option.
    //IdleSound=sound'UT3Vehicles.RAPTOR.RaptorEngine'
    //StartUpSound=sound'UT3Vehicles.RAPTOR.RaptorTakeOff'
    //ShutDownSound=sound'UT3Vehicles.RAPTOR.RaptorLand'

    EntryRadius = 230.0
}
