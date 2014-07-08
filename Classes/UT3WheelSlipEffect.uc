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

class UT3WheelSlipEffect extends ONSDirtSlipEffect;

simulated function UpdateDust(SVehicleWheel t, float DustSlipRate, float DustSlipThresh)
{
    local float SpritePPS, MeshPPS;

    //Log("Material:"$t.GroundMaterial$" OnGround:"$t.bTireOnGround);

    // If wheel is on ground, and slipping above threshold..
    if(t.bWheelOnGround && t.SlipVel > DustSlipThresh)
    {
        SpritePPS = FMin(DustSlipRate * (t.SlipVel - DustSlipThresh), MaxSpritePPS);

        Emitters[0].ParticlesPerSecond = SpritePPS;
        Emitters[0].InitialParticlesPerSecond = SpritePPS;
        Emitters[0].AllParticlesDead = false;

        MeshPPS = FMin(DustSlipRate * (t.SlipVel - DustSlipThresh), MaxMeshPPS);

        Emitters[1].ParticlesPerSecond = MeshPPS;
        Emitters[1].InitialParticlesPerSecond = MeshPPS;
        Emitters[1].AllParticlesDead = false;

        // GEm: Looks like SoundGroups and AmbientSound don't mix
        /*SoundVolume = MeshPPS/float(MaxMeshPPS)*255.0;
        if (AmbientSound == None)
            AmbientSound = DirtSlipSound;*/

        if (t.SlipVel > DustSlipThresh*3.0)
            PlaySound(DirtSlipSound, SLOT_Interact, MeshPPS/float(MaxMeshPPS)*2.0, , SoundRadius);
    }
    else // ..otherwise, switch off.
    {
        Emitters[0].ParticlesPerSecond = 0;
        Emitters[0].InitialParticlesPerSecond = 0;

        Emitters[1].ParticlesPerSecond = 0;
        Emitters[1].InitialParticlesPerSecond = 0;

        //AmbientSound = None;
    }
}

defaultproperties
{
    DirtSlipSound = Sound'UT3A_Vehicle_Scorpion.SoundCues.A_Vehicle_Scorpion_Slide'
}
