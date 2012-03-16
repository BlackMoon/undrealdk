class Gorod_VehicleContent extends Gorod_AIVehicle placeable config(VehicleContent);

/**
 * Цвет
 */
var config array<LinearColor> VehicleColors;

/**
 * Рекомендуемая скорость от
 */
var config float SpeedFrom;

/**
 * Рекомендуемая скорость до
 */
var config float SpeedTo;

var RepNotify LinearColor VehicleColor;

replication
{
	//проверить, что это сервер
	//if ( (Role==ROLE_Authority) && ...
	if(bNetInitial)
		VehicleColor;
}

simulated event ReplicatedEvent(Name VarName)
{
	if(VarName == 'VehicleColor')
	{
		SetColor(VehicleColor);
	}
}

/********************************/
/*          Цвет машины         */
/********************************/
simulated function SetColor(LinearColor col)
{
	local MaterialInstanceConstant MatInst;
	MatInst = new class'MaterialInstanceConstant';
	MatInst.SetParent(SMesh.GetMaterial(0));
	SMesh.SetMaterial(0, MatInst);
	MatInst.SetVectorParameterValue('Kuzov_Color', col);
}

simulated event PostBeginPlay()
{
	local int n;

	super.PostBeginPlay();

	if(Role == ROLE_Authority)
	{
		// выбираем цвет
		n = Rand(VehicleColors.Length);
		VehicleColor = VehicleColors[n];
		if (VehicleLightsController != none)
		{
			VehicleColor.R/=255;
			VehicleColor.G/=255;
			VehicleColor.B/=255;
			VehicleLightsController.SetColor(VehicleColor);
		}
		// выбираем предпочитаемую скорость из указанного диапазона и переводим у юниты в секунду
		n = Rand(SpeedTo - SpeedFrom + 1);
		FavoriteSpeed = 50*(SpeedFrom + n)/3.6;
	}
}

DefaultProperties
{
	///=======================================================================================================
	Begin Object Class=UDKVehicleSimCar Name=SimulationObject
		bClampedFrictionModel=true
		WheelSuspensionStiffness=100.0
		WheelSuspensionDamping=3.0
		WheelSuspensionBias=0.1
		MaxBrakeTorque=5.0
		StopThreshold=100
		WheelInertia=0.2
		
		MaxSteerAngleCurve=(Points=((InVal=0,OutVal=45),(InVal=600.0,OutVal=45.0),(InVal=1100.0,OutVal=45.0),(InVal=1300.0,OutVal=45.0),(InVal=1600.0,OutVal=25.0),(InVal=2500.0,OutVal=25.0)))
		SteerSpeed=100//1100         // скорость поворота колес
		ThrottleSpeed=0.05          // скорость разгона транспорта

		TorqueVSpeedCurve=(Points=((InVal=-600.0,OutVal=0.0),(InVal=-300.0,OutVal=80.0,InterpMode=CIM_CurveAuto),(InVal=0.0,OutVal=130.0,InterpMode=CIM_CurveAuto),(InVal=950.0,OutVal=130.0,InterpMode=CIM_CurveAuto),(InVal=1050.0,OutVal=10.0,InterpMode=CIM_CurveAuto),(InVal=1150.0,OutVal=1.0,InterpMode=CIM_CurveAuto)))		
		EngineRPMCurve=(Points=((InVal=-300.0,OutVal=3000.0),   (InVal=0.0,OutVal=500.0),    (InVal=579.0,OutVal=3000.0),(InVal=600.0,OutVal=2000.0),     (InVal=979.0,OutVal=4000.0),(InVal=1000.0,OutVal=2500.0),     (InVal=1279.0,OutVal=5000.0),(InVal=1300.0,OutVal=3000.0),     (InVal=1479.0,OutVal=6000.0),(InVal=1500.0,OutVal=3500.0),     (InVal=2500.0,OutVal=6500.0)))          // кривая зависимости оборотов двигателя от скорости
		
		EngineBrakeFactor=0.025      // скорость торможения двигателем

		SteeringReductionFactor=0.0
		SteeringReductionMinSpeed=1100.0
		SteeringReductionSpeed=1400.0
		bAutoHandbrake=true
		FrontalCollisionGripFactor=0.18
		ConsoleHardTurnGripFactor=1.0
		HardTurnMotorTorque=0.7

		SpeedBasedTurnDamping=20.0
		AirControlTurnTorque=40.0
		InAirUprightMaxTorque=15.0
		InAirUprightTorqueFactor=-30.0

		// Longitudinal tire model based on 10% slip ratio peak
		WheelLongExtremumSlip=0.1
		WheelLongExtremumValue=1.0
		WheelLongAsymptoteSlip=2.0
		WheelLongAsymptoteValue=0.6

		// Lateral tire model based on slip angle (radians)
   		WheelLatExtremumSlip=0.35     // 20 degrees
		WheelLatExtremumValue=0.9
		WheelLatAsymptoteSlip=1.4     // 80 degrees
		WheelLatAsymptoteValue=0.9

		bAutoDrive=false
		AutoDriveSteer=0.3
    End Object

    SimObj=SimulationObject
    Components.Add(SimulationObject)

    Begin Object Class=Gorod_AIVehicle_Wheel Name=RRWheel
		BoneOffset=(X=0.0,Y=20.0,Z=0.0)
		BoneName="b_rearrightwheel"
		SkelControlName="rearrightwheel"
    End Object
    Wheels(0)=RRWheel

    Begin Object Class=Gorod_AIVehicle_Wheel Name=LRWheel
		BoneOffset=(X=0.0,Y=-20.0,Z=0.0)
		BoneName="b_rearleftwheel"
		SkelControlName="rearleftwheel"
    End Object
    Wheels(1)=LRWheel

    Begin Object Class=Gorod_AIVehicle_Wheel Name=RFWheel
		BoneOffset=(X=0.0,Y=20.0,Z=0.0)
		BoneName="b_frontrightwheel"
		SteerFactor=1.0
		SkelControlName="frontrightwheel"
		bPoweredWheel=true
		LongSlipFactor=2.0
		LatSlipFactor=1.5
		HandbrakeLongSlipFactor=0.8
		HandbrakeLatSlipFactor=0.8
    End Object
    Wheels(2)=RFWheel

    Begin Object Class=Gorod_AIVehicle_Wheel Name=LFWheel
		BoneOffset=(X=0.0,Y=-20.0,Z=0.0)
		BoneName="b_frontleftwheel"
		SteerFactor=1.0
		bPoweredWheel=true
		SkelControlName="frontleftwheel"
		LongSlipFactor=2.0
		LatSlipFactor=1.5
		HandbrakeLongSlipFactor=0.8
		HandbrakeLatSlipFactor=0.8
    End Object
    Wheels(3)=LFWheel

	// ==============================================================================================================================
	// Sounds
	// Engine sound.

	Begin Object Class=AudioComponent Name=NexiaEngineSound
		SoundCue=SoundCue'Car_Sounds_1.Sound_cues.SND_Priora_Engine_4000RPM_CUE'
		VolumeMultiplier = 0.2
	End Object
	EngineSound=NexiaEngineSound
	Components.Add(NexiaEngineSound);

	/*Begin Object Class=AudioComponent Name=ScorpionTireSound
		SoundCue=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireDirt01Cue'
	End Object
	TireAudioComp=ScorpionTireSound
	Components.Add(ScorpionTireSound);


	TireSoundList(0)=(MaterialType=Dirt,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireDirt01Cue')
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
	WheelParticleEffects[3]=(MaterialType=Snow,ParticleTemplate=ParticleSystem'Envy_Level_Effects_2.Vehicle_Snow_Effects.P_Scorpion_Wheel_Snow')*/

	// ==============================================================================================================================

	COMOffset=(x=0.0,y=0.0,z=-5.0)
	UprightLiftStrength=280.0
	UprightTime=1.25
	UprightTorqueStrength=500.0
	bCanFlip=true
	bHasHandbrake=true
	HeavySuspensionShiftPercent=0.75f;

	MaxSpeed=30000.0
	GroundSpeed = 30000.000
	AirSpeed = 30000.000
}
