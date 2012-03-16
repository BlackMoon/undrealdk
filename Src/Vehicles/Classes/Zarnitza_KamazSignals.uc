class Zarnitza_KamazSignals extends Object 
	DLLBind(KamazSignal) 
	implements (ICommonSignals, Zarnitza_ICalibrate)
	config(Zarnitza_KamazSignals);

enum HandRotation {HR_NONE, HR_LEFT, HR_RIGHT, HR_TOP, HR_DOWN};

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

/** ��������� ��� �������� ��������������� �������� ���������� �������� */
struct ArrowDeviceData
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
};

var ArrowDeviceData SpeedometerData;
var ArrowDeviceData TahometerData;
var ArrowDeviceData OilPressureData;
var ArrowDeviceData EngineTemperatureData;
var ArrowDeviceData AccumulatorChargeData;
var ArrowDeviceData FuelData;
var ArrowDeviceData PneumaticPressureData;

// CALIBRATION DEVICES
var config CalibrationDevice CD_Speedometer;
var config CalibrationDevice CD_Tahometer;
var config CalibrationDevice CD_OilPressure;
var config CalibrationDevice CD_EngineTemperature;
var config CalibrationDevice CD_AccumulatorCharge;
var config CalibrationDevice CD_Fuel;
var config CalibrationDevice CD_PneumaticPressure;

var array<CalibrationDevice> CalibDevices;


/** ��������� in_signals ��������� ������� �������, ���������� �� ��������� */
struct in_signals
{
	var int wheel;						// ������� ������
	
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
	var int weight_switching_off;		// ���������� �����
	
	var int first_step;				    // ������ ��������
	var int second_step;				// ������ ��������
	var int third_step;				    // ������ ��������
	var int fourth_step;				// ������� ��������
	var int fifth_step;				    // ����� ��������
	var int back_step;					// ������ ��������
	
	var int belt_on;					// ������������ �����

	var int transfers_divider;			// �������� �������
	var int interaxle_differential;	    // ��������� ������������
	var int interwheel_differential_1;	// ���������� ������������ 1
	var int interwheel_differential_2;	// ���������� ������������ 2

	var int electrotorch_device;		// ���������������� ���������� (���)
};
//  �������
var private in_signals m_Signals;

delegate dlgArrowDeviceFunc(int val);


function bool GetDllIsReady()
{
	// ���� �������� ��� ���������� iNanSignal
	if(m_Signals.belt_on == 1234)
		return false;
	else
		return true;
}

//// Get - ������� ��� ������� � ������ ��������
/** ������� ������ */
function float GetSteering(bool normalized = true) 
{
	if(normalized == false)
		return m_Signals.wheel;

	if(m_Signals.wheel > WheelCentral)
	{
		if(m_Signals.wheel >= WheelMax)
			m_Signals.wheel = WheelMax;

		return (m_Signals.wheel - WheelCentral)  /  -(WheelMax - WheelCentral);
	}

	else if(m_Signals.wheel < WheelCentral)
	{
		if(m_Signals.wheel <= WheelMin)
			m_Signals.wheel = WheelMin;

		return (WheelCentral - m_Signals.wheel)  /  (WheelCentral - WheelMin);
	}

	else
	{
		return float(0); 
	}
}

/** ������ ���� */
function float GetGasPedal(bool normalized = true) 
{
	if(normalized == false)
		return m_Signals.gas_pedal;

	if(m_Signals.gas_pedal > GasPedalMin)
		return (m_Signals.gas_pedal - GasPedalMin)  /  (GasPedalMax - GasPedalMin);
	else
		return 0;
}

/** ������ ��������� */
function float GetClutchPedal(bool normalized = true)
{ 
	local float Result;
	if(normalized == false)
		//Result = m_Signals.coupling_pedal;
		Result = (m_Signals.coupling_pedal - ClutchPedalMin)  /  (ClutchPedalMax - ClutchPedalMin);
	else
	if(m_Signals.coupling_pedal > ClutchPedalMin)
		Result = 1 - (m_Signals.coupling_pedal - ClutchPedalMin)  /  (ClutchPedalMax - ClutchPedalMin);
	else
		Result = 1;
	return Result;
}

/** ������ ������� */
function float GetBrakePedal(bool normalized = true) 
{ 
	if(normalized == false)
		return m_Signals.brake_pedal;

	if(m_Signals.brake_pedal > BrakePedalMin)
		return (m_Signals.brake_pedal - BrakePedalMin)  /  (BrakePedalMax - BrakePedalMin);
	else
		return 0;
}

/** ���������� ������ */
function bool GetHandBrake() { return bool(m_Signals.brake); }

/** ����� ���������� */
function bool GetLeftTurn() { return bool(m_Signals.left_turn); }

/** ������ ���������� */
function bool GetRightTurn() { return bool(m_Signals.right_turn); }

/** ����� ���� */
function bool GetViewChange() { 
	return bool(m_Signals.change_camera);
}

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
function bool GetWeightSwitchingOff() {	return bool(m_Signals.weight_switching_off); }

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
function bool GetTransfersDivider() { return bool(m_Signals.transfers_divider); }

/** ��������� ������������ */
function bool GetInteraxleDifferential() { return bool(m_Signals.interaxle_differential); }

/** ����������� ������������ 1 */
function bool GetDifferencial_1() { return bool(m_Signals.interwheel_differential_1); }

/** ����������� ������������ 2 */
function bool GetDifferencial_2() { return bool(m_Signals.interwheel_differential_2); }

/** ���������������� ���������� (���) */
function bool GetElectrotorchDevice() { return bool(m_Signals.electrotorch_device); }


/** InSignals - ���������� ��������� ������ �������� �� ���������  */
dllimport final function in_signals InSignals();

/** Update - ��������� ��������� ������� �������� */
final function bool Update()
{
	m_Signals = InSignals();
	return true;
}

/** ������� ���������� ��������� ��������� �� ��������� */
dllimport final function Speedometr(int i_speedometr);                                  // ��������
dllimport final function OilPressure(int i_oil_pressure);                               // �������� �����
dllimport final function Fuel(int i_fuel);                                              // �������
dllimport final function EngineTemperature(int i_engine_temperature);                   // ����������� ����������� ��������
dllimport final function AccumulatorCharge(int i_accumulator_charge);                   // ����� ������������
dllimport final function PneumaticsPressure(int i_pneumatics_pressure);                 // ����������
dllimport final function Tachometer(int i_tachometer);                                  // ��������
dllimport final function DLL_Speedometer(int val);
dllimport final function DLL_Tachometer(int val);
dllimport final function DLL_Fuel(int val);

/** ��������� ������� ������ ��������� � �������� ���������� true ��� false, 
 *  �� �.�. ���� ��� �� �������������� DLLimopt`��, ����� ���������� � ��������� 0 ��� 1
 *  */
dllimport final function ElectrotorchDeviceLamp(/*bool*/int i_electrotorch_device_lamp);	    // ����� ��� (0 ��� 1)
dllimport final function TurnLamp(/*bool*/int i_turn_lamp);							        // ����������� ����� ��������� ���������� ��������
dllimport final function Circuit_1(/*bool*/int i_circuit_1);								    // �������
dllimport final function Circuit_2(/*bool*/int i_circuit_2);
dllimport final function Circuit_3(/*bool*/int i_circuit_3);
dllimport final function Circuit_4(/*bool*/int i_circuit_4);
dllimport final function StopBrakeLamp(/*bool*/int i_stop_brake_lamp);						    // ���������� ����� ��������� ���������� �������
dllimport final function InteraxleDifferential(/*bool*/int i_interaxle_differential);		    // ��������� ������������
dllimport final function InterwheelDifferential_1(/*bool*/int i_interwheel_differential_1);	// ���������� ������������ 1
dllimport final function InterwheelDifferential_2(/*bool*/int i_interwheel_differential_2);	// ���������� ������������ 2
dllimport final function AccumulatorLamp(/*bool*/int i_accumulator_lamp);					    // �����������
dllimport final function OilPressureLamp(/*bool*/int i_oil_pressure_lamp);					    // ����� ������� �������� �����
dllimport final function WaterTempLamp(/*bool*/int i_water_temp_lamp);						    // ����� ����������� ����
dllimport final function FuelLamp(/*bool*/int i_fuel_lamp);	                                // ����� ��������� ���������� ����

function bool Initialize() 
{ 
	CalculateHelperValuesForADD();

	InitDevices();

	return true;
}

/** �������� ID ���� ��������� */
function CheckDeviceIDs()
{
	local bool bNeedSaveConfig;

	if(CD_Speedometer.ID != 0)
	{
		CD_Speedometer.ID = 0;	
		bNeedSaveConfig = true;
	}

	if(CD_Tahometer.ID != 1)
	{
		CD_Tahometer.ID = 1;	
		bNeedSaveConfig = true;
	}
	if(CD_OilPressure.ID != 2)
	{
		CD_OilPressure.ID = 2;	
		bNeedSaveConfig = true;
	}
	if(CD_EngineTemperature.ID != 3)
	{
		CD_EngineTemperature.ID = 3;
		bNeedSaveConfig = true;
	}
	if(CD_AccumulatorCharge.ID != 4)
	{
		CD_AccumulatorCharge.ID = 4;
		bNeedSaveConfig = true;
	}
	if(CD_Fuel.ID != 5)
	{
		CD_Fuel.ID = 5;	
		bNeedSaveConfig = true;
	}
    if(CD_PneumaticPressure.ID != 6)
    {
		CD_PneumaticPressure.ID = 6;	
		bNeedSaveConfig = true;
    }

	if(bNeedSaveConfig == true)
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

	foreach CD_Tahometer.CDUs(cdu)
	{
		AddCalibrationData(CD_Tahometer.ID, cdu.ResistorVal, cdu.DeviceVal);
	}

	foreach CD_OilPressure.CDUs(cdu)
	{
		AddCalibrationData(CD_OilPressure.ID, cdu.ResistorVal, cdu.DeviceVal);
	}

	foreach CD_EngineTemperature.CDUs(cdu)
	{
		AddCalibrationData(CD_EngineTemperature.ID, cdu.ResistorVal, cdu.DeviceVal);
	}

	foreach CD_AccumulatorCharge.CDUs(cdu)
	{
		AddCalibrationData(CD_AccumulatorCharge.ID, cdu.ResistorVal, cdu.DeviceVal);
	}

	foreach CD_Fuel.CDUs(cdu)
	{
		AddCalibrationData(CD_Fuel.ID, cdu.ResistorVal, cdu.DeviceVal);
	}

	foreach CD_PneumaticPressure.CDUs(cdu)
	{
		AddCalibrationData(CD_PneumaticPressure.ID, cdu.ResistorVal, cdu.DeviceVal);
	}

	if(CalibrateDevice(0) != 0)
		`warn("Device int calibration failed. DevID: "$ 0);
	if(CalibrateDevice(1) != 0)
		`warn("Device int calibration failed. DevID: "$ 1);
	if(CalibrateDevice(2) != 0)
		`warn("Device int calibration failed. DevID: "$ 2);
	if(CalibrateDevice(3) != 0)
		`warn("Device int calibration failed. DevID: "$ 3);
	if(CalibrateDevice(4) != 0)
		`warn("Device int calibration failed. DevID: "$ 4);
	if(CalibrateDevice(5) != 0)
		`warn("Device int calibration failed. DevID: "$ 5);
	if(CalibrateDevice(6) != 0)
		`warn("Device int calibration failed. DevID: "$ 6);
}

/** ������� ������������ ��������������� �������� ��� ������� ��������������� �������� */
function CalculateHelperValuesForADD()
{
	local float k_33precent;
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
	if(normalized)
	{
		setArrowDeviceData(SpeedometerData, val, DLL_Speedometer);
	}
	else
		DLL_Speedometer(val);
}



function SetTahometer(int val, optional bool normalized = true)
{
	if(normalized)
	{
		setArrowDeviceData(TahometerData, val, DLL_Tachometer);
	}
	else
		DLL_Tachometer(val);
}

function SetOilPressure(int val, optional bool normalized = true)
{
	if(normalized)
	{
		setArrowDeviceData(OilPressureData, val, OilPressure);
	}
	else
		OilPressure(val);
}

function SetEngineTemperature(int val, optional bool normalized = true)
{
	if(normalized)
	{
		setArrowDeviceData(EngineTemperatureData, val, EngineTemperature);
	}
	else
		EngineTemperature(val);
}

function SetAccumulatorCharge(int val, optional bool normalized = true)
{
	if(normalized)
	{
		setArrowDeviceData(AccumulatorChargeData, val, AccumulatorCharge);
	}
	else
		AccumulatorCharge(val);
}

function SetFuel(int val, optional bool normalized = true)
{
	if(normalized)
	{
		setArrowDeviceData(FuelData, val, DLL_Fuel);
	}
	else
		DLL_Fuel(val);
}

function SetPneumaticsPressure(int val, optional bool normalized = true)
{
	if(normalized)
	{
		setArrowDeviceData(PneumaticPressureData, val, PneumaticsPressure);
	}
	else
		PneumaticsPressure(val);
}

/*
function SetSignals(out_signals outsignals)
{
	if(outsignals.speedometr >= 0 && outsignals.speedometr<=115)
	{
		
		m_outSignals.speedometr=outsignals.speedometr;
		Speedometr(m_outSignals.speedometr);
	}

	if(outsignals.oil_pressure >= 0 && outsignals.oil_pressure<=100)
	{
		m_outSignals.oil_pressure = outsignals.oil_pressure;
		OilPressure(m_outSignals.oil_pressure);
	}

	if(outsignals.fuel>= 0 && outsignals.fuel<=100)
	{
		m_outSignals.fuel = outsignals.fuel;
		Fuel(outsignals.fuel);
	}

	if(outsignals.engine_temperature>= 0 && outsignals.engine_temperature<=120)
	{
		m_outSignals.engine_temperature = outsignals.engine_temperature;
		EngineTemperature(m_outSignals.engine_temperature);
	}

	if(outsignals.accumulator_charge>= 0 && outsignals.accumulator_charge<=120)
	{
		m_outSignals.accumulator_charge = outsignals.accumulator_charge;
		AccumulatorCharge(m_outSignals.accumulator_charge);
	}

	if(outsignals.accumulator_charge>= 0 && outsignals.accumulator_charge<=120)
	{
		m_outSignals.accumulator_charge = outsignals.accumulator_charge;
		AccumulatorCharge(m_outSignals.accumulator_charge);
	}
	if(outsignals.pneumatics_pressure >= 0 && outsignals.pneumatics_pressure <=10)
	{
		m_outSignals.pneumatics_pressure = outsignals.pneumatics_pressure;
		AccumulatorCharge(m_outSignals.pneumatics_pressure);
	}
	if(outsignals.tachometer >= 0 && outsignals.tachometer<=40)
	{
		m_outSignals.tachometer= outsignals.tachometer;
		AccumulatorCharge(m_outSignals.tachometer);
	}
	/////////////////////////////////////////////////////////////////////////
	/************************************************************************/
	//                    "���������" ���������                             //
	/************************************************************************/
	if(m_outSignals.electrotorch_device !=outsignals.electrotorch_device)
	{
		m_outSignals.electrotorch_device = outsignals.electrotorch_device;
		if(m_outSignals.electrotorch_device)
			ElectrotorchDeviceLamp(1);
		else
			ElectrotorchDeviceLamp(0);
	}

	if(m_outSignals.turn_lamp !=outsignals.turn_lamp)
	{
		m_outSignals.turn_lamp = outsignals.turn_lamp;
		if(m_outSignals.turn_lamp)
			TurnLamp(1);
		else
			TurnLamp(0);
	}

	if(m_outSignals.circuit_1 !=outsignals.circuit_1)
	{
		m_outSignals.circuit_1 = outsignals.circuit_1;
		if(m_outSignals.circuit_1)
			Circuit_1(1);
		else
			Circuit_1(0);
	}
	if(m_outSignals.circuit_2 !=outsignals.circuit_2)
	{
		m_outSignals.circuit_2 = outsignals.circuit_2;
		if(m_outSignals.circuit_2)
			Circuit_2(1);
		else
			Circuit_2(0);
	}
	if(m_outSignals.circuit_3 !=outsignals.circuit_3)
	{
		m_outSignals.circuit_3 = outsignals.circuit_3;
		if(m_outSignals.circuit_3)
			Circuit_3(1);
		else
			Circuit_3(0);
	}
	if(m_outSignals.circuit_4 !=outsignals.circuit_4)
	{
		m_outSignals.circuit_4 = outsignals.circuit_4;
		if(m_outSignals.circuit_4)
			Circuit_4(1);
		else
			Circuit_4(0);
	}
	if(m_outSignals.stop_brake_lamp !=outsignals.stop_brake_lamp)
	{
		m_outSignals.stop_brake_lamp = outsignals.stop_brake_lamp;
		if(m_outSignals.stop_brake_lamp)
			StopBrakeLamp(1);
		else
			StopBrakeLamp(0);
	}

	if(m_outSignals.interaxle_differential !=outsignals.interaxle_differential)
	{
		m_outSignals.interaxle_differential = outsignals.interaxle_differential;
		if(m_outSignals.interaxle_differential)
			InteraxleDifferential(1);
		else
			InteraxleDifferential(0);
	}

	if(m_outSignals.interwheel_differential_1 !=outsignals.interwheel_differential_1)
	{
		m_outSignals.interwheel_differential_1 = outsignals.interwheel_differential_1;
		if(m_outSignals.interwheel_differential_1)
			InterwheelDifferential_1(1);
		else
			InterwheelDifferential_1(0);
	}

	if(m_outSignals.interwheel_differential_2 !=outsignals.interwheel_differential_2)
	{
		m_outSignals.interwheel_differential_2 = outsignals.interwheel_differential_2;
		if(m_outSignals.interwheel_differential_2)
			InterwheelDifferential_2(1);
		else
			InterwheelDifferential_2(0);
	}

	if(m_outSignals.accumulator_lamp !=outsignals.accumulator_lamp)
	{
		m_outSignals.accumulator_lamp = outsignals.accumulator_lamp;
		if(m_outSignals.accumulator_lamp)
			AccumulatorLamp(1);
		else
			AccumulatorLamp(0);
	}

	if(m_outSignals.oil_pressure_lamp !=outsignals.oil_pressure_lamp)
	{
		m_outSignals.oil_pressure_lamp = outsignals.oil_pressure_lamp;
		if(m_outSignals.oil_pressure_lamp)
			OilPressureLamp(1);
		else
			OilPressureLamp(0);
	}

	if(m_outSignals.water_temp_lamp !=outsignals.water_temp_lamp)
	{
		m_outSignals.water_temp_lamp = outsignals.water_temp_lamp;
		if(m_outSignals.water_temp_lamp)
			WaterTempLamp(1);
		else
			WaterTempLamp(0);
	}
	if(m_outSignals.fuel_lamp !=outsignals.fuel_lamp)
	{
		m_outSignals.fuel_lamp = outsignals.fuel_lamp;
		if(m_outSignals.fuel_lamp)
			FuelLamp(1);
		else
			FuelLamp(0);
	}

	//var bool fuel_lamp;                  // ����� �������

}
*/

//============================================================================================
//---------------------------------------------------------------------------
//	������� ��� ������� ������������� ������ ����������						|
//..........................................................................|
//	id	:	������������� ����������										|
//---------------------------------------------------------------------------
dllimport final function int ClearCalibrationData(int id);

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


// IMPLEMENTING ZARNITZA_ICALIBRATE INTERFACE
function int AddCalibrationInfo(int id, int resval, float deviceVal)
{
	local CalibrationDataUnit cdu;

	`log("AddCalibrationInfo: " @ id @ resval @ deviceVal );

	switch(id)
	{
	case 0:
		cdu.DeviceVal = deviceVal;
		cdu.ResistorVal = resval;
		CD_Speedometer.CDUs.AddItem(cdu);
		break;

	case 1:
		cdu.DeviceVal = deviceVal;
		cdu.ResistorVal = resval;
		CD_Tahometer.CDUs.AddItem(cdu);
		break;

	case 2:
		cdu.DeviceVal = deviceVal;
		cdu.ResistorVal = resval;
		CD_OilPressure.CDUs.AddItem(cdu);
		break;

	case 3:
		cdu.DeviceVal = deviceVal;
		cdu.ResistorVal = resval;
		CD_EngineTemperature.CDUs.AddItem(cdu);
		break;

	case 4:
		cdu.DeviceVal = deviceVal;
		cdu.ResistorVal = resval;
		CD_AccumulatorCharge.CDUs.AddItem(cdu);
		break;

	case 5:
		cdu.DeviceVal = deviceVal;
		cdu.ResistorVal = resval;
		CD_Fuel.CDUs.AddItem(cdu);
		break;

	case 6:
		cdu.DeviceVal = deviceVal;
		cdu.ResistorVal = resval;
		CD_PneumaticPressure.CDUs.AddItem(cdu);
		break;

	default:
		`warn("Unknown device");
	}

	return AddCalibrationData(id, ResVal, deviceVal);
}

function LoadCalibrationData();

function ClearAllCalibDataFromDevice()
{
	ClearCalibrationData(CD_Speedometer.ID);
	ClearCalibrationData(CD_Tahometer.ID);
	ClearCalibrationData(CD_OilPressure.ID);
	ClearCalibrationData(CD_EngineTemperature.ID);
	ClearCalibrationData(CD_AccumulatorCharge.ID);
	ClearCalibrationData(CD_Fuel.ID);
	ClearCalibrationData(CD_PneumaticPressure.ID);
}

function SaveCalibration()
{
	`log("Kamaz_Save");
	SaveConfig();
}

function int Calibrate(int deviceID)
{
	`log("Kamaz_Calibrate: " @ DeviceID);
	return CalibrateDevice(deviceID);
}

function int ResetCalibrationData(int deviceID)
{
	switch(deviceID)
	{
	case 0:
		CD_Speedometer.CDUs.Remove(0, CD_Speedometer.CDUs.Length);
		break;

	case 1:
		CD_Tahometer.CDUs.Remove(0, CD_Tahometer.CDUs.Length);
		break;

	case 2:
		CD_OilPressure.CDUs.Remove(0, CD_OilPressure.CDUs.Length);
		break;

	case 3:
		CD_EngineTemperature.CDUs.Remove(0, CD_EngineTemperature.CDUs.Length);
		break;

	case 4:
		CD_AccumulatorCharge.CDUs.Remove(0, CD_AccumulatorCharge.CDUs.Length);
		break;

	case 5:
		CD_Fuel.CDUs.Remove(0, CD_Fuel.CDUs.Length);
		break;

	case 6:
		CD_PneumaticPressure.CDUs.Remove(0, CD_PneumaticPressure.CDUs.Length);
		break;

	default:
		`warn("Unknown device reset");
	}
	`log("Reset: " @ DeviceID);

	return ClearCalibrationData(DeviceID);
}

function int ShowCalibratedValue(int DeviceID, float val)
{
	return ShowDeviceValue(DeviceID, val);
}

function int ShowValue(int DeviceID, int val)
{
	return ShowDeviceResistor(DeviceID, val);
}

DefaultProperties
{
	//
}
