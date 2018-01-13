/*
 * Copyright © 2008, 2014 GreatEmerald
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

class UT3HellbenderSideGun extends ONSPRVSideGun;

#exec obj load file=..\Animations\UT3VH_Hellbender_Anims.ukx
#exec OBJ LOAD FILE=..\textures\EpicParticles.utx
#exec OBJ LOAD FILE=..\textures\VMVehicles-TX.utx

var		array<ONSHeadlightCorona>	HeadlightCorona;
var()	array<vector>				HeadlightCoronaOffset;
var()	Material					HeadlightCoronaMaterial;
var()	float						HeadlightCoronaMaxSize;

var		ONSHeadlightProjector		HeadlightProjector;
var()	Material					HeadlightProjectorMaterial; // If null, do not create projector.
var()	vector						HeadlightProjectorOffset;
var()	rotator						HeadlightProjectorRotation;
var()	float						HeadlightProjectorScale;

simulated function PostNetBeginPlay()
{
    local int i;

    Super.PostNetBeginPlay();

	if(Level.NetMode != NM_DedicatedServer && Level.bUseHeadlights && !(Level.bDropDetail || (Level.DetailMode == DM_Low)))
	{
		HeadlightCorona.Length = HeadlightCoronaOffset.Length;

		for(i=0; i<HeadlightCoronaOffset.Length; i++)
		{
			HeadlightCorona[i] = spawn( class'ONSHeadlightCorona', self,, Location + (HeadlightCoronaOffset[i] >> Rotation) );
			HeadlightCorona[i].SetBase(self);
			HeadlightCorona[i].SetRelativeRotation(rot(0,0,0));
			HeadlightCorona[i].Skins[0] = HeadlightCoronaMaterial;
			HeadlightCorona[i].ChangeTeamTint(Team);
			HeadlightCorona[i].MaxCoronaSize = HeadlightCoronaMaxSize * Level.HeadlightScaling;
		}

		if(HeadlightProjectorMaterial != None && Level.DetailMode == DM_SuperHigh)
		{
			HeadlightProjector = spawn( class'ONSHeadlightProjector', self,, Location + (HeadlightProjectorOffset >> Rotation) );
			HeadlightProjector.SetBase(self);
			HeadlightProjector.SetRelativeRotation( HeadlightProjectorRotation );
			HeadlightProjector.ProjTexture = HeadlightProjectorMaterial;
			HeadlightProjector.SetDrawScale(HeadlightProjectorScale);
			HeadlightProjector.CullDistance	= ShadowCullDistance;
		}
	}

    SetTeamNum(Team);
	TeamChanged();
}

simulated function Destroyed()
{
    local int i;

	Super.Destroyed();

    // Destroy the effects
	if(Level.NetMode != NM_DedicatedServer)
	{
		for(i=0;i<HeadlightCorona.Length;i++)
			HeadlightCorona[i].Destroy();
		HeadlightCorona.Length = 0;

		if(HeadlightProjector != None)
			HeadlightProjector.Destroy();

	}

	TriggerEvent(Event, self, None);
}

simulated event TeamChanged()
{
    local int i;

    Super.TeamChanged();

    if (Team == 0 && RedSkin != None)
        Skins[0] = RedSkin;
    else if (Team == 1 && BlueSkin != None)
        Skins[0] = BlueSkin;

    if (Level.NetMode != NM_DedicatedServer && Team <= 2 && SpawnOverlay[0] != None && SpawnOverlay[1] != None)
        SetOverlayMaterial(SpawnOverlay[Team], 1.5, True);

    for (i = 0; i < Weapons.Length; i++)
        Weapons[i].SetTeam(Team);

	if (Level.NetMode != NM_DedicatedServer)
	{
		for(i = 0; i < HeadlightCorona.Length; i++)
			HeadlightCorona[i].ChangeTeamTint(Team);
	}
}

simulated event DestroyAppearance()
{
	local int i;

    // Destroy the effects
	if(Level.NetMode != NM_DedicatedServer)
	{
		bNoTeamBeacon = true;

		for(i=0;i<HeadlightCorona.Length;i++)
			HeadlightCorona[i].Destroy();
		HeadlightCorona.Length = 0;

		if(HeadlightProjector != None)
			HeadlightProjector.Destroy();
	}

}

simulated event SVehicleUpdateParams()
{
	local int i;

	// This code just for making it easy to position coronas etc.
	if(Level.NetMode != NM_DedicatedServer)
	{
		for(i=0; i<HeadlightCorona.Length; i++)
		{
			HeadlightCorona[i].SetBase(None);
			HeadlightCorona[i].SetLocation( Location + (HeadlightCoronaOffset[i] >> Rotation) );
			HeadlightCorona[i].SetBase(self);
			HeadlightCorona[i].Skins[0] = HeadlightCoronaMaterial;
			HeadlightCorona[i].MaxCoronaSize = HeadlightCoronaMaxSize * Level.HeadlightScaling;
		}

		if(HeadlightProjector != None)
		{
			HeadlightProjector.SetBase(None);
			HeadlightProjector.SetLocation( Location + (HeadlightProjectorOffset >> Rotation) );
			HeadlightProjector.SetBase(self);
			HeadlightProjector.SetRelativeRotation( HeadlightProjectorRotation );
			HeadlightProjector.ProjTexture = HeadlightProjectorMaterial;
			HeadlightProjector.SetDrawScale(HeadlightProjectorScale);
		}
	}
}

static function StaticPrecache(LevelInfo L)
{

	if (Default.HeadlightCoronaMaterial != None)
		L.AddPrecacheMaterial(Default.HeadLightCoronaMaterial);

	if (Default.HeadlightProjectorMaterial != None)
		L.AddPrecacheMaterial(Default.HeadLightProjectorMaterial);

}

simulated function UpdatePrecacheMaterials()
{
	if (HeadlightCoronaMaterial != None)
		Level.AddPrecacheMaterial(HeadLightCoronaMaterial);

	if (HeadlightProjectorMaterial != None)
		Level.AddPrecacheMaterial(HeadLightProjectorMaterial);

	Super.UpdatePrecacheMaterials();
}

defaultproperties
{

    DrawScale = 1.0
    Mesh = SkeletalMesh'UT3VH_Hellbender_Anims.HellbenderSecondaryTurret'
    RedSkin = Shader'UT3HellbenderTex.UT3HellbenderSkinRed'
    BlueSkin = Shader'UT3HellbenderTex.UT3HellbenderSkinBlue'
    PitchBone=SecondaryTurretPitch
    YawBone=SecondaryTurretYaw
    WeaponFireAttachmentBone=SecondaryTurretBarrel
    DamageType=class'UT3DmgType_HellbenderLaser'
    FireSoundClass = Sound'UT3A_Vehicle_Hellbender.Sounds.A_Vehicle_Hellbender_BallFire01'
    AltFireSoundClass = Sound'UT3A_Vehicle_Hellbender.Sounds.A_Vehicle_Hellbender_BeamFire01'
    PitchUpLimit=9600  //16000 is about what UT3 is but we don't have UT3's camera collision meaning we see under and through the Hellbender in UT2004
    PitchDownLimit=59200
    bInstantRotation=False
    ProjectileClass = class'UT3HBShockBall'
    
    HeadlightCoronaOffset=()
    HeadlightCoronaOffset(0)=(X=40.0,Y=0.0,Z=-20.0)
    HeadlightCoronaMaterial=Material'EpicParticles.FlashFlare1'
    
    HeadlightProjectorOffset=(X=35,Y=0,Z=-30)
    HeadlightProjectorRotation=(Yaw=0,Pitch=-1000,Roll=0)
    HeadlightProjectorMaterial=Texture'VMVehicles-TX.RVGroup.RVProjector'
    HeadlightProjectorScale=0.02
}
