//=============================================================================
// ����� �������� ���������, ������
//=============================================================================
class Forsage_Signals extends Object	
	DLLBind(ForsageSignal) 	
	implements (ICommonSignals, Zarnitza_ICalibrate)
	config(Forsage_Signals);

//  �������
var private struct in_signals
{
	var float wheel;					// ������� ������
	
	var int gas_pedal;					// ������ ����
	var int coupling_pedal;				// ������ ���������
	var int brake_pedal;				// ������ �������

	var int brake;						// ���������� ������
	var int left_turn;					// ����� ����������
	var int right_turn;				    // ������ ����������
	var int change_camera;				// ����� ����
	var int dimensional_fires;			// ���������� ����	
	var int passing_light;				// ������� ����
	var int headlight;					// ������� ����
	var int screen_wiper;				// ����������������	
	var int look_at_left;				// ������ �����
	var int look_at_right;				// ������ ������
	var int ignition;					// ���������
	var int starter;					// �������
	var int alarm_signal;				// ��������� ������������
	var int first_step;				    // 1� ��������
	var int second_step;				// 2� ��������
	var int third_step;				    // 3� ��������
	var int fourth_step;				// 4� ��������
	var int fifth_step;				    // 5� ��������
	var int back_step;					// ������ ��������	
	var int belt_on;					// ������������ �����
	var int hooter;                     // �����
	var int flasher;                    
} m_Signals;

/** ������������ �������� ��������� ��������� */
var config float MaxResistorValue;
/** ������������ ��������, ��������������� �������� ������� ��������� �������� ��� ���������� ���������� ��������  */
var config float MaxSliderValue;

// ������ ����
var config float GasPedalMin;
var config float GasPedalMax;
// ������ �������
var config float BrakePedalMin;
var config float BrakePedalMax;
// ������ ���������
var config float ClutchPedalMin;
var config float ClutchPedalMax;
// ������� ������
var config float WheelMax;
var config float WheelMin;
var config float WheelCentral;
/* ��������� ��� �������� ��������������� �������� ���������� �������� */
var struct ArrowDeviceData
{
	var float min;      // ����������� ��������������� ��������, ��������������� ������������ �� ���������� �������
	var float val_1;    // ��������, ��������������� 1\3 �� ���������� �������
	var float val_2;    // ��������, ��������������� 2\3 �� ���������� �������
	var float max;      // ������������ ��������������� ��������, ��������������� ������������� �� ���������� �������

	// ������������ ���������� ��� ���������� ������������ (�������������� ������ �� ���������� �������� ���������� (����). 
	// ������� ��� ���������� ������� ���������������� ��������)
	var float koeff_1;
	var float koeff_2;
	var float koeff_3;

	// �������� �������� �� ������ ����������� �������. ��������, �������� ��� ������ ���������� �� ������ (0-120)(��\�) ����� ����� 120
	// ��������! ���������� �������� ������ � ��� ������, ���� �������� ���������� �� 0 (���, ��-�����, ����������� � 99% �������)
	// ���� �������� ������� � ini-����� (����� ����, � ������� ��������� ����������� �������� ��� �������� �� ���� ����������)
	var float UnitsRange;

	// ����������� ����������� ��������� �������� UnitsRange � �������� ����� max � min;
	// �������������� �������� ��� �������������, ������� ��� ��������� ������������������ ��� ������� ���������������� ��������
	var float UnitsRange_MaxMinDiff_Scale;

	// 33% �� UnitsRange
	// 66% �� UnitsRange
	// ��� �������� �������������� �������� ��� �������������, ������� ��� ��������� ������������������ ��� ������� ���������������� ��������
	var float UnitsRange_33percent;
	var float UnitsRange_66percent;

	// �������� ����� (min - 1\3)
	// �������� ����� (1\3 - 2\3)
	// �������� ����� (2\3 - 3\3)
	// ��� �������� �������������� �������� ��� ���������� ����������, ������� ��� ��������� ������������������ ��� ������� ���������������� ��������
	var float Diff_Between_Min_13;
	var float Diff_Between_13_23;
	var float Diff_Between_23_Max;
} FuelData, SpeedometerData, TachometerData, TemperatureData;
// CALIBRATION DEVICES
var config CalibrationDevice CD_Fuel;
var config CalibrationDevice CD_Speedometer;
var config CalibrationDevice CD_Tachometer;
var config CalibrationDevice CD_Temperature;

delegate dlgArrowDeviceFunc(int val);

function bool GetDllIsReady()
{	
	// ���� �������� ��� ���������� iNanSignal
	return (m_Signals.belt_on == 1234);
}
/** ������� ������������ ��������������� �������� ��� ������� ��������������� �������� */
function CalculateHelperValuesForADD()
{
/*	local float k_33precent;
	local float k_66precent;

	k_33precent = 0.333333;
	k_66precent = 0.666666;

	SpeedometerData.UnitsRange_33percent = SpeedometerData.UnitsRange * k_33precent;
	SpeedometerData.UnitsRange_66percent = SpeedometerData.UnitsRange * k_66precent;
	if(SpeedometerData.UnitsRange != 0.0)
		SpeedometerData.UnitsRange_MaxMinDiff_Scale = (SpeedometerData.max - SpeedometerData.min) / SpeedometerData.UnitsRange;

	TahometerData.UnitsRange_33percent = TahometerData.UnitsRange * k_33precent;
	TahometerData.UnitsRange_66percent = TahometerData.UnitsRange * k_66precent;
	if(TahometerData.UnitsRange != 0.0)
		TahometerData.UnitsRange_MaxMinDiff_Scale = (TahometerData.max - TahometerData.min) / TahometerData.UnitsRange;
	

	OilPressureData.UnitsRange_33percent = OilPressureData.UnitsRange * k_33precent;
	OilPressureData.UnitsRange_66percent = OilPressureData.UnitsRange * k_66precent;
	if(OilPressureData.UnitsRange != 0.0)
		OilPressureData.UnitsRange_MaxMinDiff_Scale = (OilPressureData.max - OilPressureData.min) / OilPressureData.UnitsRange;

	EngineTemperatureData.UnitsRange_33percent = EngineTemperatureData.UnitsRange * k_33precent;
	EngineTemperatureData.UnitsRange_66percent = EngineTemperatureData.UnitsRange * k_66precent;
	if(EngineTemperatureData.UnitsRange != 0.0)
		EngineTemperatureData.UnitsRange_MaxMinDiff_Scale = (EngineTemperatureData.max - EngineTemperatureData.min) / EngineTemperatureData.UnitsRange;

	AccumulatorChargeData.UnitsRange_33percent = AccumulatorChargeData.UnitsRange * k_33precent;
	AccumulatorChargeData.UnitsRange_66percent = AccumulatorChargeData.UnitsRange * k_66precent;
	if(AccumulatorChargeData.UnitsRange != 0.0)
		AccumulatorChargeData.UnitsRange_MaxMinDiff_Scale = (AccumulatorChargeData.max - AccumulatorChargeData.min) / AccumulatorChargeData.UnitsRange;
		
	FuelData.UnitsRange_33percent = FuelData.UnitsRange * k_33precent;
	FuelData.UnitsRange_66percent = FuelData.UnitsRange * k_66precent;
	if(FuelData.UnitsRange != 0.0)
		FuelData.UnitsRange_MaxMinDiff_Scale = (FuelData.max - FuelData.min) / FuelData.UnitsRange;

	PneumaticPressureData.UnitsRange_33percent = PneumaticPressureData.UnitsRange * k_33precent;
	PneumaticPressureData.UnitsRange_66percent = PneumaticPressureData.UnitsRange * k_66precent;
	if(PneumaticPressureData.UnitsRange != 0.0)
		PneumaticPressureData.UnitsRange_MaxMinDiff_Scale = (PneumaticPressureData.max - PneumaticPressureData.min) / PneumaticPressureData.UnitsRange;
*/
}


/** �������, ���������� � �������� ��������������� �������� (������������ �� ����������)
 *  ���� normalized - true - ���������� ��������������� ��������, ���� false - �������
 *  */
function private setArrowDeviceData(out ArrowDeviceData data, int val, delegate<dlgArrowDeviceFunc> fn)
{
	// ������������� �������� �� �����������
	if(val < 0)
		val = 0;

	// ����� �� ����������� ��������, ������� ���� ��������� �������
	if(val > data.UnitsRange)
		val = data.UnitsRange; 



	// ����������, � ����� �������� ����� �������� val 
	if(val <= data.UnitsRange_33percent)
	{
		// ����� � �������� �� 0 - 33%
		// ������������ ��������������� ��������
		fn( data.min + (val * data.UnitsRange_MaxMinDiff_Scale * data.koeff_1));
	}
	else if(val <= data.UnitsRange_66percent)
	{
		// ����� � �������� �� 33 - 66%
		fn( data.min + data.Diff_Between_Min_13   + (val * data.UnitsRange_MaxMinDiff_Scale * data.koeff_2));
	}
	else
	{
		// ����� � �������� �� 66 - 100%
		fn( data.min + data.Diff_Between_Min_13 + data.Diff_Between_13_23   + (val * data.UnitsRange_MaxMinDiff_Scale * data.koeff_3));
	}

	// ���� ��������������� ����������� �������� ������ �������������
	/*if(data.min < data.max)
	{
		if(val <= data.min)
			fn (data.min);
		else if(val <= data.val_1)
			fn (val * data.koeff_1);
		else if(val <= data.val_2)
			fn (val * data.koeff_2);
		else if(val < data.max)
			fn (val * data.koeff_3);
		else
			fn(data.max);
	}
	// ������ ��������� (���������������)
	else
	{
		if(val <= data.max)
			fn (data.max);
		else if(val <= data.val_2)
			fn (val * data.koeff_3);
		else if(val <= data.val_1)
			fn (val * data.koeff_2);
		else if(val < data.min)
			fn (val * data.koeff_1);
		else
			fn(data.min);
	}*/
}

function SetSpeedometer(int val, optional bool normalized = true)
{
 
	
	if (normalized)
	{
		//setArrowDeviceData(SpeedometerData, val, DLL_Speedometer);
		 ShowDeviceValue(1, val);
	}
	else
		ShowDeviceResistor(1, val);
		//DLL_Speedometer(val);
}

function SetTachometer(int val, optional bool normalized = true)
{
/*	if (normalized)
	{
		setArrowDeviceData(TahometerData, val, DLL_Tachometer);
	}
	else
		DLL_Tachometer(val);*/
}

function SetTemperature(int val, optional bool normalized = true)
{
/*	if (normalized)
	{
		setArrowDeviceData(TemperatureData, val, Temperature);
	}
	else
		Temperature(val);*/
}

function SetFuel(int val, optional bool normalized = true)
{
/*	if(normalized)
	{
		setArrowDeviceData(FuelData, val, DLL_Fuel);
	}
	else
		DLL_Fuel(val);*/
}

//// get - ������� ��� ������� � ������ ��������
/** ������� ������ (������������� � ������) */
function float getSteering(bool normalized = true) 
{	
	return m_Signals.wheel;	
}
/** ������ ���� */
function float GetGasPedal(bool normalized = true) 
{
	local float fval;
	fval = 0;

	if (normalized)
	{
		if (m_Signals.gas_pedal >= GasPedalMin)
			fval = (m_Signals.gas_pedal - GasPedalMin)  /  (GasPedalMax - GasPedalMin);	
	}
	else fval = m_Signals.gas_pedal;
	return fval;	
}
/** ������ ��������� */
function float GetClutchPedal(bool normalized = true)
{ 		
	local float fval;
	fval = 0;	

	if (normalized)
	{
		if (m_Signals.coupling_pedal >= ClutchPedalMin)
			fval = (m_Signals.coupling_pedal - ClutchPedalMin)  /  (ClutchPedalMax - ClutchPedalMin);
	}
	else fval = m_Signals.coupling_pedal;	
	return fval;	
}
/** ������ ������� */
function float GetBrakePedal(bool normalized = true) 
{ 
	local float fval;
	fval = 0;	

	if (normalized)
	{
		if (m_Signals.brake_pedal >= BrakePedalMin)
			fval = (m_Signals.brake_pedal - BrakePedalMin)  /  (BrakePedalMax - BrakePedalMin);
	}
	else fval = m_Signals.brake_pedal;
	return fval;		
}
/** ���������� ������ */
function bool GetHandBrake() { return bool(m_Signals.brake); }
/** ����� ���������� */
function bool GetLeftTurn() { return bool(m_Signals.left_turn); }
/** ������ ���������� */
function bool GetRightTurn() { return bool(m_Signals.right_turn); }
/** ����� ���� */
function bool GetViewChange() { return bool(m_Signals.change_camera); }
/** ���������� ���� */
function bool GetDimensionalFires() { return bool(m_Signals.dimensional_fires); }
/** ������� ���� */
function bool GetPassingLight() { return bool(m_Signals.passing_light); }
/** ������� ���� */
function bool GetHeadLight() { return bool(m_Signals.headlight); }
/** ���������������� */
function bool GetScreenWiper() { return bool(m_Signals.screen_wiper); }
/** ������ ����� */
function bool GetLookAtLeft() { return bool(m_Signals.look_at_left); }
/** ������ ������ */
function bool GetLookAtRight() { return bool(m_Signals.look_at_right); }
/** ��������� */
function bool GetIgnition() { return bool(m_Signals.ignition); }
/** ������� */
function bool GetStarter() { return bool(m_Signals.starter); }
/** ��������� ������������ */
function bool GetAlarmSignal() { return bool(m_Signals.alarm_signal); }
/** ���������� ����� */
function bool GetWeightSwitchingOff() {	return false; }
/** 1-� �������� */
function bool GetFirstStep() { return bool(m_Signals.first_step); }
/** 2-� �������� */
function bool GetSecondStep() { return bool(m_Signals.second_step); }
/** 3-� �������� */
function bool GetThirdStep() { return bool(m_Signals.third_step); }
/** 4-� �������� */
function bool GetFourthStep() { return bool(m_Signals.fourth_step); }
/** 5-� �������� */
function bool GetFifthStep() { return bool(m_Signals.fifth_step); }
/** ������ �������� */
function bool GetBackStep() { return bool(m_Signals.back_step); }
/** ��������� */
function bool GetNeutral() { return (!bool(m_Signals.first_step)   &&   !bool(m_Signals.second_step)   &&   !bool(m_Signals.third_step)   &&   !bool(m_Signals.fourth_step)   &&   !bool(m_Signals.fifth_step)   &&   !bool(m_Signals.back_step));  }
/** ������������� ����� */
function bool GetBeltOn() { return bool(m_Signals.belt_on); }
/** �������� ������� */
function bool GetTransfersDivider() { return false; }
/** ��������� ������������ */
function bool GetInteraxleDifferential() { return false; }
/** ����������� ������������ 1 */
function bool GetDifferencial_1() { return false; }
/** ����������� ������������ 2 */
function bool GetDifferencial_2() { return false; }
/** ���������������� ���������� (���) */
function bool GetElectrotouchDevice() { return false; }

/** returns sirena signal */
function bool GetSirenaSignal() { return bool(m_Signals.flasher); }
/** returns hooter signal */
function bool GetHooterSignal() { return bool(m_Signals.hooter); }

/** InSignals - ���������� ��������� ������ �������� �� ���������  */
dllimport final function in_signals InSignals();

/** ������������� ������, calibration.h */
//---------------------------------------------------------------------------
//	������� ��� ������� ������������� ������								|
//..........................................................................|
//	id	:	������������� ����������										|
//	r	:	�������� ���������												|
//	v	:	�������� �� ����������											|
//---------------------------------------------------------------------------
dllimport final function int AddCalibrationData(int id, int r, float v);
//---------------------------------------------------------------------------
//	������� �� ���������� ����������										|
//..........................................................................|
//	id			:	������������� ����������								|
//	[retval]	:	������������ ����� ������								|
//---------------------------------------------------------------------------
dllimport final function int CalibrateDevice(int id);
//---------------------------------------------------------------------------
//	������� ��� ������� ������������� ������ ����������						|
//..........................................................................|
//	id	:	������������� ����������										|
//---------------------------------------------------------------------------
dllimport final function int ClearCalibrationData(int id);
//---------------------------------------------------------------------------
//	������� ��� ������� �������� �� ������ ������� � ��������������� ���������
//---------------------------------------------------------------------------
//	id			:	������������� ����������								|
//  v			:	��������� ��������										|
//	[retval]	:	������������ ����� ������								|
//---------------------------------------------------------------------------
dllimport final function int ShowDeviceValue(int id, float v);
//---------------------------------------------------------------------------
//	������� ��� ������� �������� ��������� � ����������������� ����������	|
//---------------------------------------------------------------------------
//	id			:	������������� ����������								|
//  r			:	��������� ��������										|
//	[retval]	:	������������ ����� ������								|
//---------------------------------------------------------------------------
dllimport final function int ShowDeviceResistor(int id, int r);


function bool Initialize() 
{ 	
	InitDevices();
	return true;
}

/** �������� ID ���� ��������� */
function CheckDeviceIDs()
{
	local bool bNeedToSave;

	if (CD_Speedometer.ID != 0)
	{
		CD_Speedometer.ID = 0;	
		bNeedToSave = true;
	}
	if (CD_Tachometer.ID != 1)
	{
		CD_Tachometer.ID = 1;	
		bNeedToSave = true;
	}	
	if (CD_Temperature.ID != 2)
	{
		CD_Temperature.ID = 2;
		bNeedToSave = true;
	}	
	if (CD_Fuel.ID != 3)
	{
		CD_Fuel.ID = 3;	
		bNeedToSave = true;
	}    
	if (bNeedToSave == true)
		SaveConfig();
}

private function InitDevices()
{
	local CalibrationDataUnit cdu;

	CheckDeviceIDs();
	foreach CD_Speedometer.CDUs(cdu)
	{
		AddCalibrationData(CD_Speedometer.ID, cdu.ResistorVal, cdu.DeviceVal);
	}

	foreach CD_Tachometer.CDUs(cdu)
	{
		AddCalibrationData(CD_Tachometer.ID, cdu.ResistorVal, cdu.DeviceVal);
	}	

	/*foreach CD_Temperature.CDUs(cdu)
	{
		AddCalibrationData(CD_Temperature.ID, cdu.ResistorVal, cdu.DeviceVal);
	}	

	foreach CD_Fuel.CDUs(cdu)
	{
		AddCalibrationData(CD_Fuel.ID, cdu.ResistorVal, cdu.DeviceVal);
	}	*/

	if (CalibrateDevice(0) != 0)
		`warn("Device int calibration failed. DevID: "$ 0);
	if (CalibrateDevice(1) != 0)
		`warn("Device int calibration failed. DevID: "$ 1);
	/*if (CalibrateDevice(2) != 0)
		`warn("Device int calibration failed. DevID: "$ 2);
	if (CalibrateDevice(3) != 0)
		`warn("Device int calibration failed. DevID: "$ 3);	*/
}
// IMPLEMENTING ZARNITZA_ICALIBRATE INTERFACE
function int AddCalibrationInfo(int id, int resval, float deviceVal)
{
	local CalibrationDataUnit cdu;
	switch (id)
	{
		case 0:
			cdu.DeviceVal = deviceVal;
			cdu.ResistorVal = resval;
			CD_Speedometer.CDUs.AddItem(cdu);
			break;
		case 1:
			cdu.DeviceVal = deviceVal;
			cdu.ResistorVal = resval;
			CD_Tachometer.CDUs.AddItem(cdu);
			break;		
		case 2:
			cdu.DeviceVal = deviceVal;
			cdu.ResistorVal = resval;
			CD_Temperature.CDUs.AddItem(cdu);
			break;
		case 3:
			cdu.DeviceVal = deviceVal;
			cdu.ResistorVal = resval;
			CD_Fuel.CDUs.AddItem(cdu);
			break;
		default:
			`warn("Unknown device");
	}
	return AddCalibrationData(id, ResVal, deviceVal);
}

function ClearAllCalibDataFromDevice()
{
	ClearCalibrationData(CD_Speedometer.ID);
	ClearCalibrationData(CD_Tachometer.ID);
	ClearCalibrationData(CD_Temperature.ID);	
	ClearCalibrationData(CD_Fuel.ID);	
}

function LoadCalibrationData();
/** Update - ��������� ��������� ������� �������� */
final function bool Update()
{
	m_Signals = InSignals();
	return true;
}

/** ������� ���������� ��������� ��������� �� ���������, ForsageSignal.h */
dllimport final function Speedometer(int i_speedometr);                                 // ��������
dllimport final function Fuel(int i_fuel);                                              // �������
dllimport final function Temperature(int i_temperature);                                // ����������� ����������� ��������
dllimport final function Tachometer(int i_tachometer);                                  // ��������
/** ������� ���������� �����, ForsageSignal.h */
dllimport final function bool WheelInit();                                              // ��������������� ���� ��� ���
dllimport final function WheelPush(int i_mscs, int i_direct);	                        // ������� ���� � ����������� ����� ����
dllimport final function CarSpeed(float f_car_speed);                                   // ������� �������� ������ ��� �������� ����
dllimport final function Finalize(int b_final);                                         // ���������� �������� (b_final = [0, 1])      
/** ��������� ������� ������ ��������� � �������� ���������� true ��� false, 
 *  �� �.�. ���� ��� �� �������������� DLLimopt`��, ����� ���������� � ��������� 0 ��� 1   */
dllimport final function LeftTurn(int i_left_turn);                                     // ����� ����������
dllimport final function RightTurn(int i_right_turn);                                   // ������ ����������
dllimport final function Alarm(int i_alarm);                                            // ��������
dllimport final function HeadLight(int i_headlight);				                    // ������� ����
dllimport final function DimensionalFires(int i_dimensional_fires);	                    // ���������� ����
dllimport final function Belt(int i_belt);							                    // ������
dllimport final function Oil(int i_oil);							                    // �����
dllimport final function Accumulator(int i_accumulator);			                    // �����������
dllimport final function CheckEngine(int i_check_engine);			                    // �������� ���������
dllimport final function Illumination(int i_illumination);			                    // ��������� ��������� ������
dllimport final function Brake(int i_brake);					        	            // ������
dllimport final function FuelLamp(int i_fuel_lamp);					                    // �������



function int Calibrate(int deviceID)
{
	return CalibrateDevice(deviceID);
}

function int ResetCalibrationData(int deviceID)
{
	return 0;
}

function SaveCalibration()
{
	SaveConfig();
}

function int ShowValue(int DeviceID, int val)
{
	return ShowDeviceResistor(DeviceID, val);
}

function int ShowCalibratedValue(int DeviceID, float val)
{
	return ShowDeviceValue(DeviceID, val);
}

DefaultProperties
{
}
