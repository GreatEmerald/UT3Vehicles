/*
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

class UT3Emitter_ViperDust extends ONSHoverBikeHoverDust;

simulated function UpdateHoverDust(bool bActive, float HoverHeight)
{
	local float Force;

	Force = 1 - HoverHeight;

	if(!bActive)
	{
		Emitters[0].ParticlesPerSecond = 0;
		Emitters[0].InitialParticlesPerSecond = 0;
		Emitters[1].Disabled = true;
		return;
	}
	else
	{
		Emitters[0].ParticlesPerSecond = 5; // 100
		Emitters[0].InitialParticlesPerSecond = 5; // 100
		Emitters[0].AllParticlesDead = false;
		//Emitters[1].Disabled = (Level.DetailMode == DM_Low);
		Emitters[1].Disabled = true;
	}

	// Dust
	Emitters[0].StartVelocityRadialRange.Min = -325 + (Force * -100); // -650 + (Force * -100)
	Emitters[0].StartVelocityRadialRange.Max = Emitters[0].StartVelocityRadialRange.Min - 100;

	Emitters[0].StartLocationPolarRange.Z.Min = 10 + (HoverHeight * 30);
	Emitters[0].StartLocationPolarRange.Z.Max = Emitters[0].StartLocationPolarRange.Z.Min;
}

simulated function SetDustColor(color DustColor)
{
	Super.SetDustColor(DustColor);

	// Reduce opacity.
	Emitters[0].ColorScale[1].Color.A = 200;
	Emitters[0].ColorScale[2].Color.A = 200;
}
