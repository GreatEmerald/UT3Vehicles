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

class UT3CicadaTurret extends ONSDualACGatlingGun;

DefaultProperties
{

    Drawscale = 1.0

    BeamEffectClass(0) = class'UT3CicadaTurretFire'
    BeamEffectClass(1) = class'UT3CicadaTurretFire'
    AltFireProjectileClass=class'UT3CicadaDecoy'

    FireSoundClass = Sound'UT3A_Vehicle_Cicada.UT3CicadaTurretFire.UT3CicadaTurretFireCue'
    FireSoundVolume = 3.0 //GE: Again it's a FLOAT!!
    //FireForce=""

    Mesh = SkeletalMesh'UT3VH_Cicada_Anims.VH_Cicada_MainTurret'
    RedSkin = Shader'UT3CicadaTex.CicadaSkin'
    BlueSkin = Shader'UT3CicadaTex.CicadaSkinBlue'
    PitchBone = MainTurret_Pitch
    YawBone = MainTurret_Yaw
    WeaponFireAttachmentBone = MainTurret_Pitch
    DualFireOffset=34 //15
    WeaponFireOffset=120
}
