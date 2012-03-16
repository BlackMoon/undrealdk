class Gorod_TestPlayerCar extends PlayerCarBase placeable;

DefaultProperties
{
	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'Cars.Skel_Meshes.Audi_Skel'
		PhysicsAsset=PhysicsAsset'Cars.Skel_Meshes.Audi_Skel_Physics'
		AnimTreeTemplate(0)=AnimTree'Cars.Skel_Meshes.Audi_Skel_AnimTree'
    end object
	/*
	SMesh = SVehicleMesh;
	*/

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

    Begin Object Class=PlayerCarBase_Wheel Name=RRWheel
		BoneOffset=(X=0.0,Y=20.0,Z=0.0)
		BoneName="B_R_Tire"
		SkelControlName="B_R_Tire"
    End Object
    Wheels(0)=RRWheel

    Begin Object Class=PlayerCarBase_Wheel Name=LRWheel
		BoneOffset=(X=0.0,Y=-20.0,Z=0.0)
		BoneName="B_L_Tire"
		SkelControlName="B_L_Tire"
    End Object
    Wheels(1)=LRWheel

    Begin Object Class=PlayerCarBase_Wheel Name=RFWheel
		BoneOffset=(X=0.0,Y=20.0,Z=0.0)
		BoneName="F_R_Tire"
		SteerFactor=1.0
		SkelControlName="F_R_Tire"
		bPoweredWheel=true
		LongSlipFactor=2.0
		LatSlipFactor=1.5
		HandbrakeLongSlipFactor=0.8
		HandbrakeLatSlipFactor=0.8
    End Object
    Wheels(2)=RFWheel

    Begin Object Class=PlayerCarBase_Wheel Name=LFWheel
		BoneOffset=(X=0.0,Y=-20.0,Z=0.0)
		BoneName="F_L_Tire"
		SteerFactor=1.0
		bPoweredWheel=true
		SkelControlName="F_L_Tire"
		LongSlipFactor=2.0
		LatSlipFactor=1.5
		HandbrakeLongSlipFactor=0.8
		HandbrakeLatSlipFactor=0.8
    End Object
    Wheels(3)=LFWheel
}