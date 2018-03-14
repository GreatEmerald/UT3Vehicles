/*
 * Copyright © 2009, 2014 GreatEmerald
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

class UT3CicadaTurretFire extends ONSTurretBeamEffect; //GE: ONSBellyTurretFire is borked.

var(Sound) sound TurretFireSound;

simulated function PostNetBeginPlay()
{
	local float pitch;
	super.PostNetBeginPlay();

	pitch = 0.80 + (frand() * 0.4);
	PlaySound(TurretFireSound, SLOT_None, 1.0,, 300,1, false); //GE: 5 is too much!
}

DefaultProperties
{
   TurretFireSound=sound'UT3A_Vehicle_Cicada.TurretFire.A_Vehicle_Cicada_TurretFire'
        Begin Object Class=BeamEmitter Name=BeamEmitter0
         BeamDistanceRange=(Min=512.000000,Max=512.000000)
         DetermineEndPointBy=PTEP_Distance
         RotatingSheets=3
         LowFrequencyPoints=2
         HighFrequencyPoints=2
         BranchProbability=(Max=1.000000)
         BranchSpawnAmountRange=(Max=2.000000)
         UseColorScale=True
         RespawnDeadParticles=False
         AlphaTest=False
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=89,G=180,R=210))
         ColorScale(1)=(RelativeTime=1.000000,Color=(G=25,R=40))
         MaxParticles=1
         UseRotationFrom=PTRS_Actor
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.250000)
         StartSizeRange=(X=(Min=-25.000000,Max=-25.000000),Y=(Min=30.000000,Max=30.000000))
         InitialParticlesPerSecond=5000.000000
         Texture=Texture'AW-2k4XP.Cicada.LongSpark'
         LifetimeRange=(Min=0.300000,Max=0.300000)
         StartVelocityRange=(X=(Min=500.000000,Max=500.000000))
     End Object
     Emitters(0)=BeamEmitter'OnslaughtBP.ONSBellyTurretFire.BeamEmitter0'

     Begin Object Class=BeamEmitter Name=BeamEmitter1
         BeamDistanceRange=(Min=512.000000,Max=512.000000)
         DetermineEndPointBy=PTEP_Distance
         RotatingSheets=3
         LowFrequencyPoints=2
         HighFrequencyPoints=2
         BranchProbability=(Max=1.000000)
         BranchSpawnAmountRange=(Max=2.000000)
         UseColorScale=True
         RespawnDeadParticles=False
         AlphaTest=False
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(G=128,R=255))
         ColorScale(1)=(RelativeTime=0.800000,Color=(G=128,R=255))
         ColorScale(2)=(RelativeTime=1.000000)
         Opacity=0.250000
         MaxParticles=1
         UseRotationFrom=PTRS_Actor
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=30.000000,Max=30.000000),Y=(Min=30.000000,Max=30.000000))
         InitialParticlesPerSecond=5000.000000
         Texture=Texture'AW-2k4XP.Cicada.LongSpark'
         LifetimeRange=(Min=0.500000,Max=0.500000)
         StartVelocityRange=(X=(Min=500.000000,Max=500.000000))
     End Object
     Emitters(1)=BeamEmitter'OnslaughtBP.ONSBellyTurretFire.BeamEmitter1'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter3
         UseDirectionAs=PTDU_Normal
         ProjectionNormal=(X=1.000000,Z=0.000000)
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=32,G=128,R=192))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=16,G=64,R=96))
         MaxParticles=1
         UseRotationFrom=PTRS_Actor
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=150.000000,Max=200.000000))
         InitialParticlesPerSecond=2000.000000
         Texture=Texture'AW-2004Particles.Weapons.PlasmaStar2'
         LifetimeRange=(Min=0.200000,Max=0.200000)
     End Object
     Emitters(2)=SpriteEmitter'OnslaughtBP.ONSBellyTurretFire.SpriteEmitter3'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter11
         UseColorScale=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         UseRandomSubdivision=True
         ColorScale(0)=(Color=(G=128,R=235))
         ColorScale(1)=(RelativeTime=0.800000,Color=(G=128,R=235))
         ColorScale(2)=(RelativeTime=1.000000)
         Opacity=0.400000
         MaxParticles=1
         StartLocationOffset=(X=10.000000)
         StartLocationRange=(X=(Max=20.000000))
         UseRotationFrom=PTRS_Actor
         SizeScale(0)=(RelativeSize=0.100000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=60.000000))
         InitialParticlesPerSecond=2000.000000
         Texture=Texture'AW-2004Particles.Weapons.PlasmaFlare'
         LifetimeRange=(Min=0.200000,Max=0.200000)
     End Object
     Emitters(3)=SpriteEmitter'OnslaughtBP.ONSBellyTurretFire.SpriteEmitter11'
}
