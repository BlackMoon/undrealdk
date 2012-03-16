class CarX_Vehicle extends PlayerCarBase  dependson (CarX, Zarnitza_KamazSignals);

/** ***************************************************************************** 
 *  ���� ������
 * ******************************************************************************/

/** ����������� */
enum TurnSignal 
{
	TURN_SIGNAL_NONE, // ��������� 
	TURN_SIGNAL_LEFT, // �����
	TURN_SIGNAL_RIGHT, // �������
	TURN_SIGNAL_ALARM // ��������
};

const cHandBrakeForce = 300;
const BrakePedalForce = 15;

/** ������ �� ������ ��� ��������� ������ �� �������� ����� */
var Zarnitza_KamazSignals KamazSignals;

//=======================================================================
// ��������� ������
/** ��������� �� ����� */
var bool bMass;
var CarX_Gear FCurrentGear;
/** ��� ������� */
var CarX_GearType FGearType;
/** ��� ������� */
var CarX_GearShiftType FGearShiftType;
var CarX_TransferGear fTransfersDivider;
// ��������� ������ =======================================================================

/** CarX Dll*/
var CarX FCarX;

/** ������� ������ �� ��������� */
var() name CameraTag;
/** ������� ������� ������  */
var int CamType;
/** ������� ������ ������ ������, ����� �������������� ������ � ������ */
var HandRotation CamHandRotation;

var private int MinMass, SecMass;
var private int iTickIdx;

var Zarnitza_SceneCapture2DActor leftMirror;
var Zarnitza_SceneCapture2DActor rightMirror;

//==========================================================================
// ���. ���������� ����������� ��������� ������
var float TurnSteering;
var bool bFrontLamps;
// ���. ���������� ==========================================================================


//=============================================================================
// �����
var(Sounds) AudioComponent TurnSignaSound;
//var(Sounds) SoundCue TurnSignaOnVehicleSound;
var(Sounds) SoundCue TurnSignaOffVehicleSound;
// ����� =============================================================================

//var(Sounds) AudioComponent SirenaSound;

simulated function PostBeginPlay()
{
	`Entry ();
	Super.PostBeginPlay();

	FCarX = Spawn (class'CarX');
	`warn("FCarX == none", FCarX == none);

	if(SimObj.bAutoDrive)
		SetDriving(true);

	InitMirror();
	InitMaterial();
	InitPanel();

	setFrontLamps (true);

	`Exit();
}

simulated function SetupCCM(ICommonSignals refCS)
{
}

function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation)
{
	// �������� ������� �� �������
	return false;
}

/** ***************************************************************************** 
 *  �������������
 * ******************************************************************************/

simulated function InitPanel()
{
}

/** ����������������� MaterialInstanceConstant ������ */
simulated function InitMaterial() 
{
	local MaterialInstanceConstant MatInst;

	//MaterialInstanceConstant'Kamaz.Materials.KAMAZ_baza_mINST';
	MatInst = new class'MaterialInstanceConstant'; 
	// ������������� ������������ �������� �� ��� ������
	MatInst.SetParent(Mesh.GetMaterial(1));
	// ������������� ������� ������ ����������� � ���� �� �����
	Mesh.SetMaterial(1, MatInst);

	MatInst = new class'MaterialInstanceConstant'; 
	// ������������� ������������ �������� �� ��� ������
	MatInst.SetParent(Mesh.GetMaterial(4));
	// ������������� ������� ������ ����������� � ���� �� �����
	Mesh.SetMaterial(4, MatInst);
}

/** ������������ ������ ������� ���� */
simulated function InitMirror()
{
	//
}

/** ***************************************************************************** 
 *  ����������
 * ******************************************************************************/
function SetGasPedal(float val)
{
	GasPedal = val;
	if(GasPedal < 0.3)
		GasPedal = 0.3;
}

/** ������������� ����� ������������, ��������� �� ���� Ignition */
exec simulated function  Car_SwitchMass() 
{
	local int Year, Month, DayOfWeek, Day, Hour, Min, Sec, MSec;

	`Entry("bMass"$bMass$"\nSecMass"$SecMass);
	if (SecMass >= 0)
	{
		GetSystemTime(Year, Month, DayOfWeek, Day, Hour, Min, Sec, MSec);
		if (Sec != SecMass || Min != MinMass)
		{
			SecMass = -1;
			MinMass = -1;
			SetMass(!bMass);
		}
	}
	else 
	{
		SetMass(!bMass);
		GetSystemTime(Year, Month, DayOfWeek, Day, Hour, MinMass, SecMass, MSec);
	}
	`Exit("bMass"$bMass$"\nSecMass"$SecMass);
}

function SetMass(bool val)
{
	bMass = val;
}

simulated function Car_SetTransfersDivider (CarX_TransferGear TransferGear)
{
	fTransfersDivider = TransferGear;
}

exec simulated function Car_SwitchTransfersDivider ()
{
	if (fTransfersDivider == TRANSFER_LOW)
		Car_SetTransfersDivider (TRANSFER_HIGH);
	else
		Car_SetTransfersDivider (TRANSFER_LOW);
}

// �������������� =============================================================

//#Todo Object.ParameterGroups.ParameterGroups[0].Object.ParameterValue 1.000000
/** 
 *  ���� ������ */
simulated function BrakeLamp()
{
	if (BrakePedal == 0)
		MaterialInstanceConstant (Mesh.GetMaterial(1)).SetScalarParameterValue (Name("StopLights_On/Off"), 0.0);
	else
		MaterialInstanceConstant (Mesh.GetMaterial(1)).SetScalarParameterValue (Name("StopLights_On/Off"), 1.0);
}

/** 
 *  */
simulated function FrontLamp()
{
	//#Todo 
	if (false)
		MaterialInstanceConstant (Mesh.GetMaterial(1)).SetScalarParameterValue (Name("FrontLights_On/Off"), 0.0);
	else
		MaterialInstanceConstant (Mesh.GetMaterial(1)).SetScalarParameterValue (Name("FrontLights_On/Off"), 1.0);
}

/** 
 *  ����� ������� ���� */
simulated function BackMoveLamp()
{
	if (CurrentGear == -1)
	{
		MaterialInstanceConstant (Mesh.GetMaterial(1)).SetScalarParameterValue (Name("BackLights_On/Off"), 1.0);
	}
	else
	{
		MaterialInstanceConstant (Mesh.GetMaterial(1)).SetScalarParameterValue (Name("BackLights_On/Off"), 0.0);
	}
	
}


/** ���������� �������� � ������������� */
simulated function TurnSignalLamp()
{
	local TurnSignal turSignal;
	
	turSignal = LeftTurn ? TURN_SIGNAL_LEFT : TURN_SIGNAL_NONE;
	turSignal = RightTurn ? TURN_SIGNAL_RIGHT : turSignal;
	turSignal = AlarmSignal ? TURN_SIGNAL_ALARM : turSignal;

	switch (turSignal)
	{
		case TURN_SIGNAL_LEFT: // ����� 
			MaterialInstanceConstant (Mesh.GetMaterial(1)).SetScalarParameterValue (Name("LeftLamp_On/Off"), 1.0);
			MaterialInstanceConstant (Mesh.GetMaterial(1)).SetScalarParameterValue (Name("RightLamp_On/Off"), 0.0);
			TurnSteering = Steer;
		break;
		case TURN_SIGNAL_RIGHT: // ������ 
			MaterialInstanceConstant (Mesh.GetMaterial(1)).SetScalarParameterValue (Name("LeftLamp_On/Off"), 0.0);
			MaterialInstanceConstant (Mesh.GetMaterial(1)).SetScalarParameterValue (Name("RightLamp_On/Off"), 1.0);
			TurnSteering = Steer;
		break;
		case TURN_SIGNAL_ALARM: // �������
			//MaterialInstanceConstant (Mesh.GetMaterial(1)).SetScalarParameterValue (Name("BothLamp_On/Off"), 1.0);
			MaterialInstanceConstant (Mesh.GetMaterial(1)).SetScalarParameterValue (Name("LeftLamp_On/Off"), 1.0);
			MaterialInstanceConstant (Mesh.GetMaterial(1)).SetScalarParameterValue (Name("RightLamp_On/Off"), 1.0);
		break;
		default: // ���������
			//MaterialInstanceConstant (Mesh.GetMaterial(1)).SetScalarParameterValue (Name("BothLamp_On/Off"), 0.0);
			MaterialInstanceConstant (Mesh.GetMaterial(1)).SetScalarParameterValue (Name("LeftLamp_On/Off"), 0.0);
			MaterialInstanceConstant (Mesh.GetMaterial(1)).SetScalarParameterValue (Name("RightLamp_On/Off"), 0.0);
		break;
	}

	/* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	if (turSignal != TURN_SIGNAL_NONE)
	{
		//TurnSignaSound.Play();
		//PlaySound(TurnSignaOnVehicleSound, false);
	}
	else
	{
		//TurnSignaSound.Stop();
		//PlaySound(TurnSignaOffVehicleSound);
	}
	*/
}

/** */
exec function Car_SetSirenaSignal(bool value)
{
	bSirenaSignal = value;
	MaterialInstanceConstant (Mesh.GetMaterial(1)).SetScalarParameterValue (Name("Sirena_On/Off"), bSirenaSignal ? 1.0 : 0.0);
	MaterialInstanceConstant (Mesh.GetMaterial(4)).SetScalarParameterValue (Name("Sirena_On/Off"), bSirenaSignal ? 1.0 : 0.0);

	//Object.ParameterGroups.ParameterGroups[0].Object.ParameterValue False


	//if (bSirenaSignal)
	//	SirenaSound.Play();
	//else 
	//	SirenaSound.Stop();
}

exec simulated function switchSirenaSignal()
{
	setSirenaSignal(!bSirenaSignal);
}

/** */
exec simulated function setFrontLamps(bool value)
{
	bFrontLamps = value;
	MaterialInstanceConstant (Mesh.GetMaterial(1)).SetScalarParameterValue (Name("FrontLamps_On/Off"), bFrontLamps ? 1.0 : 0.0);
	MaterialInstanceConstant (Mesh.GetMaterial(1)).SetScalarParameterValue (Name("MarkerLights_On/Off"), bFrontLamps ? 1.0 : 0.0);
}

exec simulated function switchFrontLamps()
{
	setFrontLamps(!bFrontLamps);
}


/** ���������� ������
 *  #ToDo ��������, ������ �� ����������, ����� ����� ���������� */
exec function OpenDoor(string FB, string LR, string OC)
{
	local UDKSkelControl_Rotate ASkelControl;
	local Name ASkelControlName;
	local vector SocketLoc;
    local rotator SocketRot;
	
	if (FB == "front") 
	{
		if (LR == "left")
		{
			ASkelControlName = name ("F_L_Door_Rotate");
			
		}
		else 
		if (LR == "right")
		{
			ASkelControlName = name ("F_R_Door_Rotate");
		}
	}
	else 
	if (FB == "back")
	{
		if (LR == "left")
		{
			ASkelControlName = name ("B_L_Door_Rotate");
		}
		else 
		if (LR == "right")
		{
			ASkelControlName = name ("B_R_Door_Rotate");
		}
	}

	// #ToDo ����� ����� ������� ������� ���������� � ����������
	ASkelControl = UDKSkelControl_Rotate (Mesh.FindSkelControl (ASkelControlName));
	if (OC == "open")
		{
			//ASkelControl.DesiredBoneRotation = ASkelControl.BoneRotation;
			//ASkelControl.DesiredBoneRotationRate = ASkelControl.BoneRotation/5;
			//ASkelControl.BoneRotation = MakeRotator(0,0,0);
			ASkelControl.ControlStrength = 1;
		}
	else 
	if (OC == "close")
		{
			/*ASkelControl.DesiredBoneRotation.Pitch = 0;
			ASkelControl.DesiredBoneRotation.Roll = 0;
			ASkelControl.DesiredBoneRotation.Yaw = 0;*/
			//ASkelControl.DesiredBoneRotation = MakeRotator(0,0,0);

			//ASkelControl.DesiredBoneRotationRate = ASkelControl.BoneRotation/(-5);
			ASkelControl.ControlStrength = 0;
		}

	if (FB == "front")
	{
		Mesh.GetSocketWorldLocationAndRotation(name("Left_mirror"), SocketLoc, SocketRot);
		leftMirror.SetLocation (SocketLoc);
		leftMirror.SetRotation (SocketRot);	

		Mesh.GetSocketWorldLocationAndRotation(name("Right_mirror"), SocketLoc, SocketRot);
		rightMirror.SetLocation (SocketLoc);
		rightMirror.SetRotation (SocketRot);	
	}
}

/** ***************************************************************************** 
 *  
 * ******************************************************************************/
/** ����������� ������ �� ����� */
exec simulated function Car_SwitchViewChange()
{
	CamType = (CamType + 1) % 5;    //add 1 to CamType
}

exec simulated function Car_SetLookAtLeft(bool value)
{
	if (value)
		CamHandRotation = HR_LEFT;
	else
		CamHandRotation = HR_NONE;
}

exec function car_SetLookAtRight(bool value)
{
	if (value)
		CamHandRotation = HR_RIGHT;
	else
		CamHandRotation = HR_NONE;
}

/* */
simulated function ProcessWheelHandling() 
{
	//local out_signals outsig;

	if (CS != none)
	{
		if (CS.GetLookAtLeft())
		{
			SetLookAtLeft(true);
			//CamHandRotation = HR_LEFT;
		}
		else if (CS.GetLookAtRight())
		{
			//CamHandRotation = HR_RIGHT;
			SetLookAtRight(true);
		}
		else 
		{
			//CamHandRotation = HR_NONE;
			SetLookAtRight(false);
			SetLookAtLeft(false);
		}

		/*
		if(KamazSignals != none)
		{
			outsig.stop_brake_lamp = HandBrake; // ������
			outsig.tachometer = FCarX.car.rpm; // ��������
			outsig.turn_lamp = LeftTurn || RightTurn || AlarmSignal; // ����������
		
			KamazSignals.SetSignals(outsig);
		}
		*/
	}
}

/** �������� ������� �������� ������� �� 10% */
exec function Car_PrevThrottle()
{
	GasPedal -= 0.1;
	if (GasPedal <=0.3)
		GasPedal = 0.3;
}
/** �������� ������� �������� ������� �� 10% */
exec function Car_NextThrottle()
{
	GasPedal += 0.1;
	if (GasPedal >=1)
		GasPedal = 1;
}


/** ������� ������  */
function Vector U() {
	return Normal(vector(Rotation));
}

/** �� ������ Tick ���������� ������ ������ */
simulated event Tick(float deltaSeconds)
{
	super.Tick(deltaSeconds);

	if (LeftTurn) 
	{
		if (TurnSteering > Steer + 0.2)
			SetLeftTurn(false);
	}
	else 
	if (RightTurn)
	{
		if (TurnSteering < Steer - 0.2)
			SetRightTurn(false);
	}	

	FCurrentGear = CarX_Gear(CurrentGear + 1);
	Steering = Steer;

	if (FCarX != None)
	{
		//  �������� � ��������� ������� ��������� ������  ====================================================
		FCarX.car.ignition = (Ignition && bMass) ? 1 : 0;
		FCarX.car.starter = Starter ? 1 : 0;

		FCarX.car.throttle = GasPedal;
		FCarX.car.clutch = ClutchPedal;
		//FCarX.car.handBrake = FHandBrake;
		FCarX.car.brake = BrakePedal;
		FCarX.car.gear = FCurrentGear;
		FCarX.car.countWheel = 4;
		FCarX.car.gearType = TYPE_4WD;
		FCarX.car.transfer = fTransfersDivider;

		FCarX.car.speed = Velocity;
		FCarX.car.u = U();

		for (iTickIdx = 0; iTickIdx < 4; iTickIdx++) 
		{
			FCarX.car.wheels[iTickIdx].rpm = 60 * Wheels[iTickIdx].SpinVel / 6.283f; // ������� � �������, �� �������� � ������
			FCarX.car.wheels[iTickIdx].brakeTorque = 0; //Wheels[i].BrakeTorque;
			FCarX.car.wheels[iTickIdx].chassisTorque = 0;
			FCarX.car.wheels[iTickIdx].torque = 0;
		}
	
		//if (FCarX.car.rpm > 500.f)
		//{
		//	if (!EngineSound.IsPlaying())
		//		EngineSound.Play();
		//	EngineSound.PitchMultiplier = (5 - 1)*(GetRPM() - 700) / (3000 - 700) + 1;
		//}
		//else 
		//	EngineSound.Stop();

		// ��������� ������ � CarX =============================================================================
		FCarX.STick(deltaSeconds);

		// ��������� ���������� ������ � ������ ================================================================
	
		//bIgnition = FCarX.car.ignition == 1;
		//getPlayerController().car = FCarX.car;

		for (iTickIdx = 0; iTickIdx < Wheels.Length; iTickIdx++) 
		{
			// ����������� ��������� �������
			if (iTickIdx < 2)
				Wheels[iTickIdx].BrakeTorque = Abs(FCarX.car.wheels[iTickIdx].brakeTorque) + Abs(HandBrake ? cHandBrakeForce  + BrakePedal*BrakePedalForce : BrakePedal*BrakePedalForce);
			else
				Wheels[iTickIdx].BrakeTorque = FCarX.car.wheels[iTickIdx].brakeTorque + BrakePedal*BrakePedalForce;

			Wheels[iTickIdx].MotorTorque     = FCarX.car.wheels[iTickIdx].torque;
			Wheels[iTickIdx].ChassisTorque   = FCarX.car.wheels[iTickIdx].chassisTorque * 0.0001f; // �������� �� ����� ���������, � �� �������.
		}
	}

	//Velocity = FCarX.car.speed;
	//Wheels[i].SpinVel = FCarX.car.wheels[i].rpm * 6.283;
	//force
}

/** *********************************************************************
 *  ������� ������� ��������� ����� �� �� �������� ������
 *  *********************************************************************/
event bool DriverLeave( bool bForceLeave )
{
	//return false;
	
	if (getBelt())
		return false;
	else 
		return super.DriverLeave(bForceLeave);
}

function bool getBelt()
{
	return BeltOn;
}

/** *********************************************************************
 *  ������ ���������� 
 *  #ToDo ����� ����� �������� ��� �� �� ��������� ���� �� ������������� 
 *  **********************************************************************/
exec simulated function Car_SwitchBelt()
{
	BeltOn = !BeltOn;
}

simulated function Car_SetBelt(bool value)
{
	BeltOn = value;
}

/** ����� HUD */
simulated function DrawHUD( HUD H ) 
{
	local int PosY;
	PosY = 500;

	super.DrawHud(H);
	/*
	if (CCM != none && KamazSignals == none)
		KamazSignals = CCM.GetKamazSimulatorObject();

	if (KamazSignals != none)
	{
		KamazSignals.SetSpeedometer(GetSpeedInKMpH());
		KamazSignals.SetTahometer(GetRPM());
	}

	if (gfxSpeedometer != none && gfxSpeedometer.bMovieIsOpen) 
	{
		gfxSpeedometer.SetMaxValue (200);
		gfxSpeedometer.SetCurrentValue(VSize (Velocity) * 0.06857);
	}
	if (gfxTachometer != none && FCarX != none && gfxTachometer.bMovieIsOpen) 
	{
		gfxTachometer.SetMaxValue(3000);
		gfxTachometer.SetCurrentValue(FCarX.car.rpm);
	}
	*/

	H.Canvas.SetDrawColor(0,255,0);
	H.Canvas.SetPos(10, PosY, 0);
	if (FCarX != none)
	{
		H.Canvas.DrawText("Sig :" $ CS);
		H.Canvas.DrawText("Pedals:" @ ClutchPedal @ BrakePedal @ GasPedal);
		H.Canvas.DrawText("Steer:" @ Steer);
		H.Canvas.DrawText("RPM :"$FCarX.car.rpm);
		H.Canvas.DrawText("GEAR :"$ CarX_Gear(FCarX.car.gear));
		H.Canvas.DrawText("GEAR TYPE:"$ CarX_GearType(FCarX.car.gearType));
		H.Canvas.DrawText("GEAR TRANSFER:"$ CarX_TransferGear(FCarX.car.transfer));
	}

	H.Canvas.SetPos(10, PosY+100, 0);
	H.Canvas.DrawText("BELT:", False);
	if (getBelt())
		H.Canvas.DrawText("Ok");
	else 
	{
		H.Canvas.SetDrawColor(255, 0,0);
		H.Canvas.DrawText("Fasten");
		H.Canvas.SetDrawColor(0,255,0);
	}

	H.Canvas.SetPos(10, PosY+73, 0);
	H.Canvas.DrawText("MASS:", False);
	if (bMass)
		H.Canvas.DrawText("Ok");
	else 
	{
		H.Canvas.SetDrawColor(255, 0,0);
		H.Canvas.DrawText("Off");
		H.Canvas.SetDrawColor(0,255,0);
	}
	H.Canvas.SetPos(10, PosY+85, 0);
	H.Canvas.DrawText("IGNITION:", false);
	if (Ignition)
		H.Canvas.DrawText("Ok");
	else 
	{
		H.Canvas.SetDrawColor(255, 0,0);
		H.Canvas.DrawText("Off");
		H.Canvas.SetDrawColor(0,255,0);
	}	

	H.Canvas.SetPos(10, PosY+97, 0);
	H.Canvas.DrawText("HandBreak:", false);
	if (!HandBrake)
		H.Canvas.DrawText("Off");
	else 
	{
		H.Canvas.SetDrawColor(255, 0,0);
		H.Canvas.DrawText("On");
		H.Canvas.SetDrawColor(0,255,0);
	}

	H.Canvas.SetPos(10, PosY+200, 0);
	H.Canvas.DrawText("Velocity:"$ 3.6*VSize(Velocity)/50);
}

/** *************************************************************************
 *  ������� ���������������� ��� ������ �������������� ������ 
 *  **************************************************************************/
simulated function DisplayDebug(HUD HUD, out float out_YL, out float out_YPos) 
{
	local Color SaveColor;
	//local float GraphScale;
	local Array<String>	DebugInfo;
	local int i;
	//local vector WorldLoc, ScreenLoc, X, Y, Z;

	//GraphScale = 100.0f;
    SaveColor = HUD.Canvas.DrawColor;

	super.DisplayDebug(HUD, out_YL, out_YPOS);

	GetSVehicleDebug( DebugInfo );

	Hud.Canvas.SetDrawColor(0,255,0);
	for (i=0;i<DebugInfo.Length;i++)
	{
		Hud.Canvas.DrawText( "  " @ DebugInfo[i] );
		out_YPos += out_YL;
		Hud.Canvas.SetPos(4, out_YPos);
	}

    // Uncomment to see detailed per-wheel debug info
	DisplayWheelsDebug(HUD, out_YL);


	Hud.Canvas.SetDrawColor(0,255,0);

	if (FCarX != none)
	DebugInfo.AddItem (
			"\ncar.u"@FCarX.car.u$
			"\ncar.Flong"@FCarX.car.Flong$
			"\ncar.speed"@FCarX.car.speed$
			"\ncar.a"@FCarX.car.a$

			"\ncar.ignition"@FCarX.car.ignition$
			"\ncar.starter"@FCarX.car.starter$
			"\ncar.clutch="@FCarX.car.clutch$
			"\ncar.throttle="@FCarX.car.throttle$

			"\ncar.gear"@FCarX.car.gear$
			"\ncar.rpm="@FCarX.car.rpm$
			"\ncar.w_rpm="@FCarX.car.wheels[0].rpm$
			"\ncar.w_torque="@FCarX.car.wheels[0].torque$
			"\ncar.w_chassisTorque="@FCarX.car.wheels[0].chassisTorque

			);
	
	for (i=0;i<DebugInfo.Length;i++)
	{
		Hud.Canvas.DrawText( "  " @ DebugInfo[i] );
		out_YPos += out_YL;
		Hud.Canvas.SetPos(500, out_YPos);
	}

	DisplayWheelsDebug(HUD, out_YL);

	HUD.Canvas.DrawColor = SaveColor;
}


function float GetThrottle()
{
	return GasPedal;
}

function float GetBrake()
{
	return BrakePedal;
}

function float GetClutch()
{
	return ClutchPedal;
}

function int GetGear()
{
	return CurrentGear;
}

function bool GetIgnition()
{
	return Ignition;
}

function bool GetMass()
{
	return bMass;
}

function bool GetHandBrake()
{
	return HandBrake;
}

function bool GetLeftTurnSignal()
{
	return LeftTurn;
}

function bool GetRightTurnSignal()
{
	return RightTurn;
}

function float GetRPM()
{
	return FCarX.car.rpm;
}

function StartSendSignals()
{
	SetTimer(0.5, true, 'SetSignalsForSimulator');
}

function SetSignalsForSimulator()
{
	if(KamazSignals == none)
		return;

	// ���������
	KamazSignals.ShowCalibratedValue(0, 3.6*VSIze(Velocity)/50);
	// ��������
	KamazSignals.ShowCalibratedValue(1, FCarX.car.rpm);
	// �������� �����
	// ����������� ���������
	// ����� ������������
	// �������
	// �������������� ��������
	
	// ����� ���

	/*
	if(!bOldAlarmSignal && bAlarmSignal)
	{
		bTurnSignalsOn = true;
	}
	else if(bOldAlarmSignal && !bAlarmSignal)
	{
		bTurnSignalsOn = false;
	}
	*/

	// ����������� ����� ��������� ���������� ��������
	/*
	if(GetLeftTurnSignal() || GetRightTurnSignal())
	{
		bTurnSignalOn = !bTurnSignalOn;
		KamazSignals.TurnLamp(bTurnSignalOn ? 1 : 0);
	}
	else
		KamazSignals.TurnLamp(0);	
	*/

	// �������
	// ���������� ����� ��������� ���������� �������
	KamazSignals.StopBrakeLamp(GetHandBrake() ? 1 : 0);
	// ��������� ������������
	KamazSignals.InteraxleDifferential(FCarX.car.diff_axle);
	// ���������� ������������ 1
	KamazSignals.InterwheelDifferential_1(FCarX.car.diff_wheels1);
	// ���������� ������������ 2
	KamazSignals.InterwheelDifferential_2(FCarX.car.diff_wheels2);
	// �����������
	// ����� ������� �������� �����
	// ����� ����������� ����
	// �������
}

/*
simulated function SetInputs(float InForward, float InStrafe, float InUp) 
{
	if(InputMode != IM_Keyboard)
		ProcessWheelHandling();
	else	
		super.SetInputs(InForward, InStrafe, InUp);	
}
*/

protected function Update()
{
	super.Update();

	// �������, ������� �� ����� ������� ������� ����
	if(InputMode != IM_Joystick)
	{
		bMass = KamazSignals.GetWeightSwitchingOff();
	}
}

/* �� ������� ������ ������� ����� ����������� ����� � ��������� */
defaultproperties
{
	Health=3000

	COMOffset=(x=-40.0,y=0.0,z=-36.0)

	UprightLiftStrength=280.0
	UprightTime=1.25
	UprightTorqueStrength=500.0
	bCanFlip=true
	bSeparateTurretFocus=true
	bHasHandbrake=true	
	MaxSpeed = 50000
	GroundSpeed=0
	AirSpeed=0


	ObjectiveGetOutDist=1500.0
	HeavySuspensionShiftPercent=0.75f;

	/*
	Begin Object Name=SVehicleMesh
		CastShadow=true
		bCastDynamicShadow=true
		bOverrideAttachmentOwnerVisibility=true
		bAcceptsDynamicDecals=FALSE
		bPerBoneMotionBlur=true
    end object
	*/

	Begin Object Class=UDKVehicleSimCar Name=SimObject
		WheelSuspensionStiffness=1000.0
		WheelSuspensionDamping=100.0
		WheelSuspensionBias=0.05
		ChassisTorqueScale=0.0
		MaxBrakeTorque=5.0
		StopThreshold=100

		MaxSteerAngleCurve=(Points=((InVal=0,OutVal=45),(InVal=600.0,OutVal=15.0),(InVal=1100.0,OutVal=10.0),(InVal=1300.0,OutVal=6.0),(InVal=1600.0,OutVal=1.0)))
		SteerSpeed=110

		//TorqueVSpeedCurve=(Points=((InVal=-600.0,OutVal=0.0),(InVal=-300.0,OutVal=80.0),(InVal=0.0,OutVal=130.0),(InVal=950.0,OutVal=130.0),(InVal=1050.0,OutVal=10.0),(InVal=1150.0,OutVal=0.0)))
		//EngineRPMCurve=(Points=((InVal=-500.0,OutVal=-100.0),(InVal=0.0,OutVal=0.0),(InVal=500.0,OutVal=100.0),(InVal=1000.0,OutVal=1000.0),(InVal=5000.0,OutVal=4500.0)))
		//EngineRPMCurve=(Points=((InVal=-500.0,OutVal=2500.0),(InVal=0.0,OutVal=300.0),(InVal=1149.0,OutVal=5500.0),(InVal=1150.0,OutVal=2500.0),(InVal=2149.0,OutVal=5500.0),(InVal=2150.0,OutVal=2500.0),(InVal=2850.0,OutVal=5500.0),(InVal=2851.0,OutVal=2500.0),(InVal=3850.0,OutVal=5500.0),(InVal=3851.0,OutVal=2500.0),(InVal=4100.0,OutVal=5500.0)))

		LSDFactor=0.0
		EngineBrakeFactor=0.025
		ThrottleSpeed=0.1
		WheelInertia=2.0
		NumWheelsForFullSteering=4
		SteeringReductionFactor=0.0
		SteeringReductionMinSpeed=1100.0
		SteeringReductionSpeed=1400.0
		bAutoHandbrake=true
		bClampedFrictionModel=true
		FrontalCollisionGripFactor=0.18
		ConsoleHardTurnGripFactor=1.0
		HardTurnMotorTorque=0.7

		SpeedBasedTurnDamping=20.0
		AirControlTurnTorque=40.0
		InAirUprightMaxTorque=15.0
		InAirUprightTorqueFactor=-30.0

		// Longitudinal tire model based on 10% slip ratio peak
		WheelLongExtremumSlip=0.1
		WheelLongExtremumValue=0.2
		WheelLongAsymptoteSlip=0.7
		WheelLongAsymptoteValue=0.4

		// Lateral tire model based on slip angle (radians)
   		WheelLatExtremumSlip=0.2     // 20 degrees
		WheelLatExtremumValue=0.4
		WheelLatAsymptoteSlip=0.8     // 80 degrees
		WheelLatAsymptoteValue=0.6

		bAutoDrive=false
		AutoDriveSteer=0.3
	End Object
	SimObj=SimObject
	Components.Add(SimObject)

	// ==== 4 ������, �������� ������ ����������� ==================================
	Begin Object Class=UDKVehicleWheel Name=RRWheel
		BoneOffset=(X=0.0,Y=20.0,Z=0.0)
		BoneName="B_R_Tire"
		Side = SIDE_Right
		SkelControlName="B_R_Tire_Cont"		
		LongSlipFactor=2.0
		LatSlipFactor=2.75
		HandbrakeLongSlipFactor=0.7
		HandbrakeLatSlipFactor=0.3
		ParkedSlipFactor=10.0
		WheelRadius = 29
    End Object
    Wheels(0)=RRWheel

	Begin Object Class=UDKVehicleWheel Name=LRWheel
		BoneOffset=(X=0.0,Y=-20.0,Z=0.0)
		BoneName="B_L_Tire"
		Side = SIDE_Left
		SkelControlName="B_L_Tire_Cont"
		LongSlipFactor=2.0
		LatSlipFactor=2.75
		HandbrakeLongSlipFactor=0.7
		HandbrakeLatSlipFactor=0.3
		ParkedSlipFactor=10.0
		WheelRadius = 29
    End Object
    Wheels(1)=LRWheel

    Begin Object Class=UDKVehicleWheel Name=RFWheel
		BoneOffset=(X=0.0,Y=20.0,Z=0.0)
		BoneName="F_R_Tire"
		Side = SIDE_Right
		SkelControlName="F_R_Tire_Cont"		
		SteerFactor=1.0
		LongSlipFactor=2.0
		LatSlipFactor=2.75
		HandbrakeLongSlipFactor=0.7
		HandbrakeLatSlipFactor=0.3
		ParkedSlipFactor=10.0
		WheelRadius = 29
    End Object
    Wheels(2)=RFWheel

    Begin Object Class=UDKVehicleWheel Name=LFWheel
		BoneOffset=(X=0.0,Y=-20.0,Z=0.0)
		BoneName="F_L_Tire"
		Side = SIDE_Left
		SkelControlName="F_L_Tire_Cont"
		SteerFactor=1.0
		LongSlipFactor=2.0
		LatSlipFactor=2.75
		HandbrakeLongSlipFactor=0.7
		HandbrakeLatSlipFactor=0.3
		ParkedSlipFactor=10.0
		WheelRadius = 29
    End Object
    Wheels(3)=LFWheel

	BaseEyeheight=30
	Eyeheight=30

	MomentumMult=0.5

	NonPreferredVehiclePathMultiplier=1.5

	Ignition = false
	bMass = false
	ClutchPedal = 1.0
	GasPedal = 0.3
	HandBrake = true
	BrakePedal = 0

	FGearType = TYPE_RWD
	FGearShiftType = SHIFT_MANUAL
	CurrentGear = 1

	//change GunViewSocket to whatever your socket is called
	CameraTag = CameraViewSocket
	SecMass = -1
}