class CarX_Vehicle_Pickup_Content extends CarX_Vehicle placeable;
/**
 * Copyright 1998-2011 Epic Games, Inc. All Rights Reserved.
 */

// #ToDo Нужно будет обновить весь контент до камазовского 
defaultproperties
{
	Mass = 7000

	/*Begin Object Name=CollisionCylinder
		CollisionHeight=0.0
		CollisionRadius=0.0
		Translation=(X=-25.0)
	End Object*/
	
	Components.Remove(CollisionCylinder);
	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'Kamaz.SkelMeshes.Kamaz_skel' //SkeletalMesh'VH_UW2_MonsterPickup.Mesh.SK_VHUW2_FramePickup_SH'
		AnimTreeTemplate=AnimTree'Kamaz.AnimSets.AT_Kamaz_skel' //AnimTree'VH_UW2_MonsterPickup.Anims.AT_VHUW2_MonsterPickup_SH' //
		PhysicsAsset=PhysicsAsset'Kamaz.SkelMeshes.PA_Kamaz_skel' //PhysicsAsset'VH_UW2_MonsterPickup.Mesh.PA_VHUW2_FramePickup_SH'
		RBCollideWithChannels=(Default=TRUE,BlockingVolume=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE,Vehicle=TRUE,Untitled4=TRUE)
	End Object

	DrawScale=1.2
	//IconCoords=(U=831,UL=21,V=39,VL=29)

	Seats(0)={(
				TurretVarPrefix="",
				SeatIconPos=(X=	0.415,Y=0.5),
				CameraTag=CameraViewSocket,
				CameraBaseOffset=(X=-50.0),
				CameraOffset=-175
				)}

	// Sounds
	// Engine sound.
	Begin Object Class=AudioComponent Name=KamazEngineSound
		SoundCue=SoundCue'Kamaz.Sounds.Engine_Cue'
	End Object
	EngineSound=KamazEngineSound
	Components.Add(KamazEngineSound);
	
	/*Begin Object Class=AudioComponent Name=ScorpionTireSound
		SoundCue=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireDirt01Cue'
	End Object
	TireAudioComp=ScorpionTireSound
	Components.Add(ScorpionTireSound);*/


	/*TireSoundList(0)=(MaterialType=Dirt,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireDirt01Cue')
	TireSoundList(1)=(MaterialType=Foliage,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireFoliage01Cue')
	TireSoundList(2)=(MaterialType=Grass,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireGrass01Cue')
	TireSoundList(3)=(MaterialType=Metal,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireMetal01Cue')
	TireSoundList(4)=(MaterialType=Mud,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireMud01Cue')
	TireSoundList(5)=(MaterialType=Snow,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireSnow01Cue')
	TireSoundList(6)=(MaterialType=Stone,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireStone01Cue')
	TireSoundList(7)=(MaterialType=Wood,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireWood01Cue')
	TireSoundList(8)=(MaterialType=Water,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireWater01Cue')

	WheelParticleEffects[0]=(MaterialType=Generic,ParticleTemplate=ParticleSystem'Envy_Level_Effects_2.Vehicle_Dust_Effects.P_Scorpion_Wheel_Dust')
	WheelParticleEffects[1]=(MaterialType=Dirt,ParticleTemplate=ParticleSystem'VH_Scorpion.Effects.PS_Wheel_Rocks')
	WheelParticleEffects[2]=(MaterialType=Water,ParticleTemplate=ParticleSystem'Envy_Level_Effects_2.Vehicle_Water_Effects.P_Scorpion_Water_Splash')
	WheelParticleEffects[3]=(MaterialType=Snow,ParticleTemplate=ParticleSystem'Envy_Level_Effects_2.Vehicle_Snow_Effects.P_Scorpion_Wheel_Snow')

	// Wheel squealing sound.
	Begin Object Class=AudioComponent Name=ScorpionSquealSound
		SoundCue=SoundCue'A_Vehicle_Scorpion.SoundCues.A_Vehicle_Scorpion_Slide'
	End Object
	SquealSound=ScorpionSquealSound
	Components.Add(ScorpionSquealSound);*/

	CollisionSound=SoundCue'Kamaz.Sounds.Door_close_Cue'
	EnterVehicleSound=SoundCue'Kamaz.Sounds.Door_open_Cue'
	ExitVehicleSound=SoundCue'Kamaz.Sounds.Door_close_Cue'
	//StarterVehicleSound=SoundCue'Kamaz.Sounds.Engine_On_Cue'

	Begin Object Class=AudioComponent Name=TurnSignaOnSound
		SoundCue=SoundCue'Kamaz.Sounds.Povorotnik_Cue'
	End Object
	TurnSignaSound=TurnSignaOnSound
	Components.Add(TurnSignaOnSound);

	//TurnSignaOnVehicleSound=SoundCue'Kamaz.Sounds.Povorotnik_Cue'
	TurnSignaOffVehicleSound=SoundCue'Kamaz.Sounds.Povorotnik_Off_Cue'

	// Initialize sound parameters.
	SquealThreshold=0.1
	SquealLatThreshold=0.02
	LatAngleVolumeMult = 30.0
	EngineStartOffsetSecs=2.0
	EngineStopOffsetSecs=1.0

	/*VehicleEffects(0)=(EffectStartTag=BoostStart,EffectEndTag=BoostStop,EffectTemplate=ParticleSystem'VH_Scorpion.Effects.PS_Scorpion_Booster_Red',EffectTemplate_Blue=ParticleSystem'VH_Scorpion.Effects.PS_Scorpion_Booster',EffectSocket=Booster01)
	VehicleEffects(1)=(EffectStartTag=BoostStart,EffectEndTag=BoostStop,EffectTemplate=ParticleSystem'VH_Scorpion.Effects.PS_Scorpion_Booster_Red',EffectTemplate_Blue=ParticleSystem'VH_Scorpion.Effects.PS_Scorpion_Booster',EffectSocket=Booster02)
	VehicleEffects(2)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'Envy_Effects.Vehicle_Damage.P_Vehicle_Damage_1_Scorpion',EffectSocket=DamageSmoke01)
	VehicleEffects(3)=(EffectStartTag=MuzzleFlash,EffectTemplate=ParticleSystem'VH_Scorpion.Effects.PS_Scorpion_Gun_MuzzleFlash_Red',EffectTemplate_Blue=ParticleSystem'VH_Scorpion.Effects.PS_Scorpion_Gun_MuzzleFlash',EffectSocket=TurretFireSocket)

	DamageMorphTargets(0)=(InfluenceBone=LtFront_Fender,MorphNodeName=MorphNodeW_LtFrontFender,LinkedMorphNodeName=MorphNodeW_Hood,Health=30,DamagePropNames=(Damage2))
	DamageMorphTargets(1)=(InfluenceBone=RtFront_Fender,MorphNodeName=MorphNodeW_RtFrontFender,LinkedMorphNodeName=MorphNodeW_Hood,Health=30,DamagePropNames=(Damage2))
	DamageMorphTargets(2)=(InfluenceBone=LtRear_Fender,MorphNodeName=MorphNodeW_LtRearFender,LinkedMorphNodeName=MorphNodeW_Hatch,Health=40,DamagePropNames=(Damage1,Damage5))
	DamageMorphTargets(3)=(InfluenceBone=RtRear_Fender,MorphNodeName=MorphNodeW_RtRearFender,LinkedMorphNodeName=MorphNodeW_Hatch,Health=40,DamagePropNames=(Damage1,Damage5))
	DamageMorphTargets(4)=(InfluenceBone=Hood,MorphNodeName=MorphNodeW_Hood,LinkedMorphNodeName=MorphNodeW_Hatch,Health=100,DamagePropNames=(Damage3,Damage1))
	DamageMorphTargets(5)=(InfluenceBone=Hatch_Slide,MorphNodeName=MorphNodeW_Hatch,LinkedMorphNodeName=MorphNodeW_Body,Health=125,DamagePropNames=(Damage1))
	DamageMorphTargets(6)=(InfluenceBone=Main_Root,MorphNodeName=MorphNodeW_Body,Health=175,DamagePropNames=(Damage6,Damage7))

	DamageParamScaleLevels(0)=(DamageParamName=Damage1,Scale=1.0)
	DamageParamScaleLevels(1)=(DamageParamName=Damage2,Scale=1.0)
	DamageParamScaleLevels(2)=(DamageParamName=Damage3,Scale=1.0)
	DamageParamScaleLevels(3)=(DamageParamName=Damage5,Scale=1.0)
	DamageParamScaleLevels(4)=(DamageParamName=Damage6,Scale=1.0)
	DamageParamScaleLevels(5)=(DamageParamName=Damage7,Scale=1.0)*/
}
