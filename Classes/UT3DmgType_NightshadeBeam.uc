/*
 * Copyright © 2017, 2018 Luís 'zeluisping' Guimarães (100GPing100)
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

class UT3DmgType_NightshadeBeam extends WeaponDamageType
	abstract;

DefaultProperties
{
	DeathString="%o was carved up by %k's Nightshade shaft.";
	MaleSuicide="%o shafted himself.";
	FemaleSuicide="%o shafted herself.";

	WeaponClass=class'UT3Weap_NightshadeBeam';

	bDetonatesGoop=true
    bCausesBlood=false
	bLeaveBodyEffect=true
	bSkeletize=true

    //DamageOverlayMaterial=Material'XGameShaders.PlayerShaders.LinkHit'
    //DamageOverlayTime=0.5

	//DeathOverlayMaterial=Material'XGameShaders.PlayerShaders.LinkHit'
    //DeathOverlayTime=1.0

	VehicleMomentumScaling=0.1;
	VehicleDamageScaling=0.8;

	KDamageImpulse=100
}
