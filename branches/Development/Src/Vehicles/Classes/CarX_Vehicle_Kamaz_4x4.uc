class CarX_Vehicle_Kamaz_4x4 extends CarX_Vehicle placeable;
/**
 * Copyright 1998-2011 Epic Games, Inc. All Rights Reserved.
 */

simulated function InitPanel()
{
}


// #ToDo Нужно будет обновить весь контент до камазовского 
defaultproperties
{
	Mass = 7000

	Components.Remove(CollisionCylinder);

	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'Kamaz.SkelMeshes.Kamaz_skel' 
		AnimTreeTemplate=AnimTree'Kamaz.AnimSets.AT_Kamaz_skel'
		PhysicsAsset=PhysicsAsset'Kamaz.SkelMeshes.PA_Kamaz_skel'
		RBCollideWithChannels=(Default=TRUE,BlockingVolume=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE,Vehicle=TRUE,Untitled4=TRUE)
		ScriptRigidBodyCollisionThreshold = 1
		bNotifyRigidBodyCollision = true
	End Object

	DrawScale=1.2

	Seats(0)={(
				TurretVarPrefix="",
				SeatIconPos=(X=	0.415,Y=0.5),
				CameraTag=CameraViewSocket,
				CameraBaseOffset=(X=-50.0),
				CameraOffset=-175
				)}

	// Sounds
	// Engine sound.
	// Звук двигателя 
	/*Begin Object Class=AudioComponent Name=KamazEngineSound
		SoundCue=SoundCue'Kamaz.Sounds.Engine_Cue'
	End Object
	EngineSound=KamazEngineSound
	Components.Add(KamazEngineSound);*/

	//Begin Object Class=AudioComponent Name=KamazEngineSound
	//	//SoundCue=SoundCue'Kamaz.Sounds.Engine_Cue'
	//	//SoundCue=SoundCue'Kamaz.Sounds.Engine_Cue2' // 0.4 - 2.0
	//	SoundCue=SoundCue'Kamaz.Sounds.Engine_al50'
	//	//SoundCue=SoundCue'A_Vehicle_UnWheel2.SoundCues.A_Vehicle_Car2_EngineLoop' // 0.4 - 2.0
	//End Object
	//EngineSound=KamazEngineSound
	//Components.Add(KamazEngineSound);

	CollisionSound=SoundCue'Kamaz.Sounds.Door_close_Cue'
	EnterVehicleSound=SoundCue'Kamaz.Sounds.Door_open_Cue'
	ExitVehicleSound=SoundCue'Kamaz.Sounds.Door_close_Cue'
	
	//// Звук стартера
	//Begin Object Class=AudioComponent Name=StarterVehicleOnSound
	//	SoundCue=SoundCue'Kamaz.Sounds.Engine_On_Cue'
	//End Object
	//StarterVehicleSound=StarterVehicleOnSound
	//Components.Add(StarterVehicleOnSound);

	// Звук работающих поворотников
	Begin Object Class=AudioComponent Name=TurnSignaOnSound
		SoundCue=SoundCue'Kamaz.Sounds.Povorotnik_Cue'
	End Object
	TurnSignaSound=TurnSignaOnSound
	Components.Add(TurnSignaOnSound);

	// Звук выключения поворотников 
	TurnSignaOffVehicleSound=SoundCue'Kamaz.Sounds.Povorotnik_Off_Cue'

	

	// Initialize sound parameters.
	SquealThreshold=0.1
	SquealLatThreshold=0.02
	LatAngleVolumeMult = 30.0
	EngineStartOffsetSecs=2.0
	EngineStopOffsetSecs=1.0

	//CameraTag = CameraCenterViewSocket
}
