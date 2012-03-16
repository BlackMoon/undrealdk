//=============================================================================
// Класс сигналов устройств, Форсаж
//=============================================================================
class Forsage_Signals extends Object	
	DLLBind(ForsageSignal) 	
	implements (ICommonSignals, Zarnitza_ICalibrate)
	config(Forsage_Signals);

//  сигналы
var private struct in_signals
{
	var float wheel;					// рулевое колесо
	
	var int gas_pedal;					// педаль газа
	var int coupling_pedal;				// педаль сцепления
	var int brake_pedal;				// педаль тормоза

	var int brake;						// стояночный тормоз
	var int left_turn;					// левый повототник
	var int right_turn;				    // правый поворотник
	var int change_camera;				// смена вида
	var int dimensional_fires;			// габаритные огни	
	var int passing_light;				// ближний свет
	var int headlight;					// дальний свет
	var int screen_wiper;				// стеклоочиститель	
	var int look_at_left;				// взгляд влево
	var int look_at_right;				// взгляд вправо
	var int ignition;					// зажигание
	var int starter;					// стартер
	var int alarm_signal;				// аварийная сигнализация
	var int first_step;				    // 1я передача
	var int second_step;				// 2я передача
	var int third_step;				    // 3я передача
	var int fourth_step;				// 4я передача
	var int fifth_step;				    // 5я передача
	var int back_step;					// задняя передача	
	var int belt_on;					// пристёгивание ремня
	var int hooter;                     // гудок
	var int flasher;                    
} m_Signals;

/** Максимальное значение диапазона резистора */
var config float MaxResistorValue;
/** Максимальное значение, соответствующее крайнему правому положению ползунка при калибровке стрелочных приборов  */
var config float MaxSliderValue;

// Педаль газа
var config float GasPedalMin;
var config float GasPedalMax;
// Педаль тормоза
var config float BrakePedalMin;
var config float BrakePedalMax;
// Педаль сцепления
var config float ClutchPedalMin;
var config float ClutchPedalMax;
// Рулевое колесо
var config float WheelMax;
var config float WheelMin;
var config float WheelCentral;
/* Структура для хранения откалиброванных значений стрелочных приборов */
var struct ArrowDeviceData
{
	var float min;      // минимальное откалиброванное значение, соответствующее минимальному на стрелочном приборе
	var float val_1;    // значение, соответствующее 1\3 на стрелочном приборе
	var float val_2;    // значение, соответствующее 2\3 на стрелочном приборе
	var float max;      // максимальное откалиброванное значение, соответствующее максимальному на стрелочном приборе

	// коэффициенты домножения для устранения погрешностей (рассчитываются исходя из полученных значений калибровки (выше). 
	// Введены для облегчения расчета откалиброванного значения)
	var float koeff_1;
	var float koeff_2;
	var float koeff_3;

	// диапазон значений на панели стрелочного прибора. Например, диапазон для панели спидометра со шкалой (0-120)(км\ч) будет равен 120
	// ВНИМАНИЕ! калибровка работает только в том случае, если диапазон начинается от 0 (что, по-моему, встречается в 99% случаев)
	// пока задается вручную в ini-файле (может быть, в будущем добавится возможность задавать это значение из меню калибровки)
	var float UnitsRange;

	// коэффициент соотношения диапазона значений UnitsRange к разности между max и min;
	// рассчитывается единожды при инициализации, введено для повышения производительности при расчете откалиброванного значения
	var float UnitsRange_MaxMinDiff_Scale;

	// 33% от UnitsRange
	// 66% от UnitsRange
	// эти значения рассчитываются единожды при инициализации, введены для повышения производительности при расчете откалиброванного значения
	var float UnitsRange_33percent;
	var float UnitsRange_66percent;

	// разность между (min - 1\3)
	// разность между (1\3 - 2\3)
	// разность между (2\3 - 3\3)
	// эти значения рассчитываются единожды при завершении калибровки, введены для повышения производительности при расчете откалиброванного значения
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
	// если приходит так называемый iNanSignal
	return (m_Signals.belt_on == 1234);
}
/** Функция рассчитывает вспогогательные значения для расчета откалиброванных значений */
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


/** Функции, передающие в тренажер нормализованные значения (базирующиеся на калибровке)
 *  если normalized - true - передаются нормализованные значения, если false - обычные
 *  */
function private setArrowDeviceData(out ArrowDeviceData data, int val, delegate<dlgArrowDeviceFunc> fn)
{
	// отрицательные значения не допускаются
	if(val < 0)
		val = 0;

	// также не допускаются значения, которые выше диапазона прибора
	if(val > data.UnitsRange)
		val = data.UnitsRange; 



	// определяем, в какой диапазон вошло значение val 
	if(val <= data.UnitsRange_33percent)
	{
		// вошло в диапазон от 0 - 33%
		// рассчитываем откалиброванное значение
		fn( data.min + (val * data.UnitsRange_MaxMinDiff_Scale * data.koeff_1));
	}
	else if(val <= data.UnitsRange_66percent)
	{
		// вошло в диапазон от 33 - 66%
		fn( data.min + data.Diff_Between_Min_13   + (val * data.UnitsRange_MaxMinDiff_Scale * data.koeff_2));
	}
	else
	{
		// вошло в диапазон от 66 - 100%
		fn( data.min + data.Diff_Between_Min_13 + data.Diff_Between_13_23   + (val * data.UnitsRange_MaxMinDiff_Scale * data.koeff_3));
	}

	// если откалиброванное минимальное значение меньше максимального
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
	// больше максимума (инвертированное)
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

//// get - функции для доступа к данным сигналов
/** Рулевое колесо (откалибровано в Форсаж) */
function float getSteering(bool normalized = true) 
{	
	return m_Signals.wheel;	
}
/** Педаль газа */
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
/** Педаль сцепления */
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
/** Педаль тормоза */
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
/** Стояночный тормоз */
function bool GetHandBrake() { return bool(m_Signals.brake); }
/** Левый повототник */
function bool GetLeftTurn() { return bool(m_Signals.left_turn); }
/** Правый повототник */
function bool GetRightTurn() { return bool(m_Signals.right_turn); }
/** Смена вида */
function bool GetViewChange() { return bool(m_Signals.change_camera); }
/** Габаритные огни */
function bool GetDimensionalFires() { return bool(m_Signals.dimensional_fires); }
/** Ближный свет */
function bool GetPassingLight() { return bool(m_Signals.passing_light); }
/** Дальний свет */
function bool GetHeadLight() { return bool(m_Signals.headlight); }
/** Стеклоочиститель */
function bool GetScreenWiper() { return bool(m_Signals.screen_wiper); }
/** Взгляд влево */
function bool GetLookAtLeft() { return bool(m_Signals.look_at_left); }
/** Взгляд вправо */
function bool GetLookAtRight() { return bool(m_Signals.look_at_right); }
/** Зажигание */
function bool GetIgnition() { return bool(m_Signals.ignition); }
/** Стартер */
function bool GetStarter() { return bool(m_Signals.starter); }
/** Аварийная сигнализация */
function bool GetAlarmSignal() { return bool(m_Signals.alarm_signal); }
/** Отключение массы */
function bool GetWeightSwitchingOff() {	return false; }
/** 1-я передача */
function bool GetFirstStep() { return bool(m_Signals.first_step); }
/** 2-я передача */
function bool GetSecondStep() { return bool(m_Signals.second_step); }
/** 3-я передача */
function bool GetThirdStep() { return bool(m_Signals.third_step); }
/** 4-я передача */
function bool GetFourthStep() { return bool(m_Signals.fourth_step); }
/** 5-я передача */
function bool GetFifthStep() { return bool(m_Signals.fifth_step); }
/** Задняя передача */
function bool GetBackStep() { return bool(m_Signals.back_step); }
/** Нейтралка */
function bool GetNeutral() { return (!bool(m_Signals.first_step)   &&   !bool(m_Signals.second_step)   &&   !bool(m_Signals.third_step)   &&   !bool(m_Signals.fourth_step)   &&   !bool(m_Signals.fifth_step)   &&   !bool(m_Signals.back_step));  }
/** Пристегивание ремня */
function bool GetBeltOn() { return bool(m_Signals.belt_on); }
/** Делитель передач */
function bool GetTransfersDivider() { return false; }
/** Межосевой дифференциал */
function bool GetInteraxleDifferential() { return false; }
/** Межколесный дифференциал 1 */
function bool GetDifferencial_1() { return false; }
/** Межколесный дифференциал 2 */
function bool GetDifferencial_2() { return false; }
/** Электрофакельное устройство (ЭФУ) */
function bool GetElectrotouchDevice() { return false; }

/** returns sirena signal */
function bool GetSirenaSignal() { return bool(m_Signals.flasher); }
/** returns hooter signal */
function bool GetHooterSignal() { return bool(m_Signals.hooter); }

/** InSignals - возвращает структуру водных сигналов из тренажера  */
dllimport final function in_signals InSignals();

/** Калибровочные фукции, calibration.h */
//---------------------------------------------------------------------------
//	функция для добавки калибровочных данных								|
//..........................................................................|
//	id	:	идентификатор устройства										|
//	r	:	значение резистора												|
//	v	:	значение на устройстве											|
//---------------------------------------------------------------------------
dllimport final function int AddCalibrationData(int id, int r, float v);
//---------------------------------------------------------------------------
//	команда на калибровку устройства										|
//..........................................................................|
//	id			:	идентификатор устройства								|
//	[retval]	:	возвращается номер ошибки								|
//---------------------------------------------------------------------------
dllimport final function int CalibrateDevice(int id);
//---------------------------------------------------------------------------
//	функция для очистки калибровочных данных устройства						|
//..........................................................................|
//	id	:	идентификатор устройства										|
//---------------------------------------------------------------------------
dllimport final function int ClearCalibrationData(int id);
//---------------------------------------------------------------------------
//	функция для задания значения на панели прибора в откалиброванном состоянии
//---------------------------------------------------------------------------
//	id			:	идентификатор устройства								|
//  v			:	требуемое значение										|
//	[retval]	:	возвращается номер ошибки								|
//---------------------------------------------------------------------------
dllimport final function int ShowDeviceValue(int id, float v);
//---------------------------------------------------------------------------
//	функция для задания значения резистора в неоткалиброванном устройстве	|
//---------------------------------------------------------------------------
//	id			:	идентификатор устройства								|
//  r			:	требуемое значение										|
//	[retval]	:	возвращается номер ошибки								|
//---------------------------------------------------------------------------
dllimport final function int ShowDeviceResistor(int id, int r);


function bool Initialize() 
{ 	
	InitDevices();
	return true;
}

/** Проверка ID всех устройств */
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
/** Update - обновляет структуру входных сигналов */
final function bool Update()
{
	m_Signals = InSignals();
	return true;
}

/** Функции управления приборами индикации на тренажере, ForsageSignal.h */
dllimport final function Speedometer(int i_speedometr);                                 // скорость
dllimport final function Fuel(int i_fuel);                                              // топливо
dllimport final function Temperature(int i_temperature);                                // температура охлаждающей жидкости
dllimport final function Tachometer(int i_tachometer);                                  // тахометр
/** Функции управления рулем, ForsageSignal.h */
dllimport final function bool WheelInit();                                              // инициализирован руль или нет
dllimport final function WheelPush(int i_mscs, int i_direct);	                        // задание силы и направления рывка руля
dllimport final function CarSpeed(float f_car_speed);                                   // задание скорости машины для возврата руля
dllimport final function Finalize(int b_final);                                         // выключение приборов (b_final = [0, 1])      
/** следующие функции должны принимать в качестве параметров true или false, 
 *  но т.к. этот тип не поддерживается DLLimopt`ом, нужно передавать в параметре 0 или 1   */
dllimport final function LeftTurn(int i_left_turn);                                     // левый поворотник
dllimport final function RightTurn(int i_right_turn);                                   // правый поворотник
dllimport final function Alarm(int i_alarm);                                            // аварийка
dllimport final function HeadLight(int i_headlight);				                    // дальний свет
dllimport final function DimensionalFires(int i_dimensional_fires);	                    // габаритные огни
dllimport final function Belt(int i_belt);							                    // ремень
dllimport final function Oil(int i_oil);							                    // масло
dllimport final function Accumulator(int i_accumulator);			                    // аккумулятор
dllimport final function CheckEngine(int i_check_engine);			                    // проверка двигателя
dllimport final function Illumination(int i_illumination);			                    // подсветка приборной панели
dllimport final function Brake(int i_brake);					        	            // ручник
dllimport final function FuelLamp(int i_fuel_lamp);					                    // топливо



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
