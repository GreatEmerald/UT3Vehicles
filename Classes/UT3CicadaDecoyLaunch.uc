/*
 * Copyright © 2018 GreatEmerald
 * Copyright © 2018 HellDragon
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
class UT3CicadaDecoyLaunch extends ONSDecoyLaunch;

var(Sound) sound TurretAltFireSound;

simulated function PostNetBeginPlay()
{
	super.PostNetBeginPlay();
	PlaySound(TurretAltFireSound, SLOT_None, 1.0);
}


defaultproperties
{
    TurretAltFireSound=sound'UT3A_Vehicle_Cicada.TurretAltFire.TurretAltFireCue'
	
    Begin Object Class=SpriteEmitter Name=SpriteEmitter16
        UseDirectionAs=PTDU_Normal
        ProjectionNormal=(X=1.000000,Z=0.000000)
        UseColorScale=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorScale(1)=(RelativeTime=0.200000,Color=(B=113,G=255,R=244))
        ColorScale(2)=(RelativeTime=0.600000,Color=(B=130,G=196,R=255))
        ColorScale(3)=(RelativeTime=1.000000)
        CoordinateSystem=PTCS_Relative
        MaxParticles=2
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=0.250000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        InitialParticlesPerSecond=500.000000
        Texture=Texture'AW-2004Particles.Weapons.PlasmaFlare'
        LifetimeRange=(Min=0.250000,Max=0.250000)
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter16'

	AutoDestroy=true
    bNoDelete=false
}
