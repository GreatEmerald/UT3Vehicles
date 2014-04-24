/*
 * Copyright © 2008, 2014 GreatEmerald
 * Copyright © 2008-2009 Wormbo
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

class UT3Cicada extends ONSDualAttackCraft;

var(Sound) sound TargetLockSound;

//=======================
// @100GPing100
/* Holds the name of the animation currently being played. */
var string CurrentAnim;

#exec obj load file=..\Animations\UT3CicadaAnims.ukx
#exec obj load file=..\Textures\UT3CicadaTex.utx

function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	AnimateVehicle();
}
function AnimateVehicle()
{
	if (CurrentAnim == "GetIn" && !IsAnimating())
	{
		LoopAnim('Idle', 1.0);
		CurrentAnim = "Idle";
	}
}
simulated function DrivingStatusChanged()
{
	/* Animations list:
	ActiveStill [2]
	GetIn [90]
	GetOut [51]
	Idle [201]
	InActiveStill [2]
	*/
	Super.DrivingStatusChanged();
	if (Driver == None)
	{
		PlayAnim('GetOut', 1.0, 0.2);
		CurrentAnim = "GetOut";
	}
	else
	{
		PlayAnim('GetIn', 1.0);
		CurrentAnim = "GetIn";
	}
}
// @100GPing100
//==========END==========

simulated function DrawHUD(Canvas Canvas) //GE: Lock-on sound
{
	local vector X,Y,Z, Dir, LockedTarget;
	local float Dist,scale,xl,yl,posy;
	local PlayerController PC;
	local HudCDeathmatch H;

	local bool bIsLocked;
	local float DeltaTime;

	local string CoPilot;

	if ( !ONSDualACSideGun(Weapons[0]).bLocked )
		super.DrawHud(Canvas);

    DeltaTime = Level.TimeSeconds - LastHudRenderTime;
	LastHudRenderTime = Level.TimeSeconds;

	bIsLocked = ONSDualACSideGun(Weapons[0]).bLocked;

	PC = PlayerController(Owner);
	if (PC==None)
		return;

	H = HudCDeathmatch(PC.MyHud);
	if (H==None)
		return;

	if ( ONSDualACSideGun(Weapons[0]).bLocked )
	{
		if (bIsLocked != bLastLockType)	// Initialize the Crosshair
			ResetAnimation();

		Animate(Canvas,DeltaTime);

	    GetAxes(PC.GetViewRotation(), X,Y,Z);

	    LockedTarget = ONSDualACSideGun(Weapons[0]).LockedTarget;
	    if (OldLockedTarget != LockedTarget)
			PlaySound(TargetLockSound, SLOT_None, 2.0);

	    OldLockedTarget = LockedTarget;

		Dir = LockedTarget - Location;
		Dist = VSize(Dir);
		Dir = Dir/Dist;

	    if ( (Dir dot X) > 0.4 )
	    {
			// Draw the Locked on Symbol
			Dir = Canvas.WorldToScreen( LockedTarget );
			scale = float(Canvas.SizeX) / 1600;

			// new Stuff

			Canvas.SetDrawColor( 64,255,64,Value(SpinFade[0]) );
			CenterDraw(Canvas, SpinCircles[0], Dir.X, Dir.Y, Value(SpinScale[0])*Scale, Value(SpinScale[0])*Scale );
			Canvas.SetDrawColor(64,255,64,Value(SpinFade[1]) );
			CenterDraw(Canvas, SpinCircles[1], Dir.X, Dir.Y, Value(SpinScale[1])*Scale, Value(SpinScale[1])*Scale );

			Canvas.SetDrawColor(128,255,128,Value(BracketFade));
			DrawBrackets(Canvas,Dir.X,Dir.Y,Scale);
			DrawMissiles(Canvas,Dir.X,Dir.Y,Scale);

		}
	}

	bLastLockType = bIsLocked;

	HudMissileCount.Tints[0] = H.HudColorRed;
	HudMissileCount.Tints[1] = H.HudColorBlue;

	H.DrawSpriteWidget( Canvas, HudMissileCount );
	H.DrawSpriteWidget( Canvas, HudMissileIcon );
	HudMissileDigits.Value = ONSDualACSideGun(Weapons[0]).LoadedShotCount;
	H.DrawNumericWidget(Canvas, HudMissileDigits, DigitsBig);

	if (WeaponPawns[0]!=none && WeaponPawns[0].PlayerReplicationInfo!=None)
	{
		CoPilot = WeaponPawns[0].PlayerReplicationInfo.PlayerName;
		Canvas.Font = H.GetMediumFontFor(Canvas);
		Canvas.Strlen(CoPilot,xl,yl);
		posy = Canvas.ClipY*0.7;
		Canvas.SetPos(Canvas.ClipX-xl-5, posy);
		Canvas.SetDrawColor(255,255,255,255);
		Canvas.DrawText(CoPilot);

		Canvas.Font = H.GetConsoleFont(Canvas);
        Canvas.StrLen(CoPilotLabel,xl,yl);
        Canvas.SetPos(Canvas.ClipX-xl-5,posy-5-yl);
		Canvas.SetDrawColor(160,160,160,255);
		Canvas.DrawText(CoPilotLabel);
	}

}

//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
	//=======================
	// @100GPing100
	VehiclePositionString = "in a UT3 Cicada";

	Mesh = SkeletalMesh'UT3CicadaAnims.Cicada';
	RedSkin = Shader'UT3CicadaTex.CicadaSkin';
	BlueSkin = Shader'UT3CicadaTex.CicadaSkinBlue';

	DriverWeapons(0)=(WeaponClass=class'UT3CicadaMissileLauncher',WeaponBone=Rt_Gun_Pitch);
	DriverWeapons(1)=(WeaponClass=class'UT3CicadaMissileLauncher',WeaponBone=Lt_Gun_Pitch);
	PassengerWeapons(0)=(WeaponPawnClass=Class'UT3CicadaTurretPawn',WeaponBone="GatlingGunAttach")
	// @100GPing100
	//==========END==========
	  VehicleNameString = "UT3 Cicada"

      GroundSpeed=2000
      CollisionHeight=70.000000
      //DriverWeapons(0)=(WeaponClass=class'UT3CicadaMissileLauncher',WeaponBone=RightRLAttach);
      //DriverWeapons(1)=(WeaponClass=class'UT3CicadaMissileLauncher',WeaponBone=LeftRLAttach);
      TargetLockSound=sound'UT3A_Vehicle_Cicada.Sounds.A_Vehicle_Cicada_TargetLock01'
      IdleSound=Sound'UT3A_Vehicle_Cicada.Sounds.A_Vehicle_Cicada_EngineLoop02'
      StartUpSound=Sound'UT3A_Vehicle_Cicada.Sounds.A_Vehicle_Cicada_Start01'
      ShutDownSound=Sound'UT3A_Vehicle_Cicada.Sounds.A_Vehicle_Cicada_Stop01'//8/10
      ExplosionSounds=()
      ExplosionSounds(0)=Sound'UT3A_Vehicle_Cicada.Sounds.A_Vehicle_Cicada_Explode02'
      ImpactDamageSounds=()
      ImpactDamageSounds(0)=Sound'UT3A_Vehicle_Cicada.SoundCues.A_Vehicle_Cicada_Collide'
      //PassengerWeapons(0)=(WeaponPawnClass=Class'UT3CicadaTurretPawn',WeaponBone="GatlingGunAttach")
}
