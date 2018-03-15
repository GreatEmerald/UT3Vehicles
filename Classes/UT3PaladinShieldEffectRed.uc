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

class UT3PaladinShieldEffectRed extends ONSShockTankShieldEffectRed;

#exec obj load file=..\StaticMeshes\UT3PaladinSM.usx

DefaultProperties
{
	Begin Object Class=MeshEmitter Name=MeshEmitter18
		StaticMesh = StaticMesh'UT3PaladinSM.PaladinShield';
		UseParticleColor=True
		UseColorScale=True
		AutomaticInitialSpawning=False
		ColorScale(0)=(Color=(B=64,G=64,R=255))
		ColorScale(1)=(RelativeTime=1.000000,Color=(B=64,G=64,R=255))
		CoordinateSystem=PTCS_Relative
		MaxParticles=1
		UniformSize=false
		StartSizeRange=(X=(Min=2.200000,Max=2.200000),Y=(Min=2.2000000,Max=2.2000000),Z=(Min=2.200000,Max=2.200000))
		InitialParticlesPerSecond=5000.000000
		LifetimeRange=(Min=0.100000,Max=0.100000)
	End Object
	Emitters(0) = MeshEmitter18;
	PrePivot=(X=-100,Y=30.0,Z=-20)
}
