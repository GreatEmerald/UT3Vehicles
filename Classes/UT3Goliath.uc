/*
 * Copyright © 2008 Wormbo
 * Copyright © 2012 100GPing100
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



//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
    //===============
    // @100GPing100
    Mesh = SkeletalMesh'UT3GoliathAnims.Goliath';
    RedSkin = Shader'UT3GoliathTex.Goliath.GoliathSkin';
    BlueSkin = Shader'UT3GoliathTex.Goliath.GoliathSkinBlue';

    Skins(1) = Shader'UT3GoliathTex.GoliathWheels.GoliathWheelsSkin';
    Skins(2) = Shader'UT3GoliathTex.GoliathWheels.GoliathWheelsSkin';

    DriverWeapons(0)=(WeaponClass=class'UT3GoliathCannon',WeaponBone=Chassis)
    PassengerWeapons(0)=(WeaponPawnClass=class'UT3GoliathTurretPawn',WeaponBone=Object10)

    IdleSound = Sound'UT3A_Vehicle_Goliath.Sounds.A_Vehicle_Goliath_EngineLoop01';
    StartUpSound = Sound'UT3A_Vehicle_Goliath.Sounds.A_Vehicle_Goliath_Start01';
    ShutDownSound = Sound'UT3A_Vehicle_Goliath.Sounds.A_Vehicle_Goliath_Stop01';

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
    MaxGroundSpeed=600.0
    GroundSpeed=500
    SoundVolume=255
    MaxThrust=200.000000//GE: was 65, maybe the tank is too fast now?
}
