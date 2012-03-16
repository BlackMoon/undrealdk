#include "windows.h"
#include <stdio.h>
#include "KamazSignal.h"
#include <string>
#include <Shlobj.h>

HANDLE				HCOM					= NULL;		// HANDLE COM-порта
CRITICAL_SECTION	objCriticalSection		= {0};		// критическая секция доступа к данным

const int iNanSignal = 123;

// структура, содержащая входные сигналы
in_signals is_struct = {iNanSignal, iNanSignal, iNanSignal, iNanSignal, iNanSignal, iNanSignal, iNanSignal, iNanSignal, iNanSignal, iNanSignal, 
	iNanSignal, iNanSignal, iNanSignal, iNanSignal, iNanSignal, iNanSignal, iNanSignal, iNanSignal, iNanSignal, iNanSignal,
	iNanSignal, iNanSignal, iNanSignal, iNanSignal, iNanSignal, iNanSignal, iNanSignal, iNanSignal, iNanSignal, iNanSignal}; 

/////////////////////////////////////////////////////////////////////////
//////////////////////////   ВЫХОДНЫЕ СИГНАЛЫ   /////////////////////////
/////////////////////////////////////////////////////////////////////////

int speedometr = 0;
int oil_pressure = 0;
int fuel = 0;
int engine_temperature = 0;
int accumulator_charge = 0;
int pneumatics_pressure = 0;
int tachometer = 0;

BOOL electrotorch_device_lamp = 0;			// лампа ЭФУ
BOOL turn_lamp = 0;							// контрольная лампа включения указателей поворота
BOOL circuit_1 = 0;							// контуры
BOOL circuit_2 = 0;
BOOL circuit_3 = 0;
BOOL circuit_4 = 0;
BOOL stop_brake_lamp = 0;					// контрольна лампа включения стояночого тормоза
BOOL interaxle_differential_lamp = 0;		// межосевой дифференциал
BOOL interwheel_differential_1_lamp = 0;	// межколёсный дифференциал 1
BOOL interwheel_differential_2_lamp = 0;	// межколёсный дифференциал 2
BOOL accumulator_lamp = 0;					// аккумулятор
BOOL oil_pressure_lamp = 0;					// лампа падения давления масла
BOOL water_temp_lamp = 0;					// лампа температуры воды
BOOL fuel_lamp = 0;							// топливо

void COMPortOpen()
{
	HCOM = CreateFile(L"COM1", GENERIC_READ|GENERIC_WRITE, 0, 0, OPEN_EXISTING, 0, 0);

	if(HCOM == INVALID_HANDLE_VALUE)
	{
		//open_port = false;
		return;
	}

	DCB DCB_;
	int Sys = GetCommState(HCOM, &DCB_);
	if(Sys == 0)
	{
		//open_port = false;
		return;
	}

	DCB_.BaudRate = 57600;
	DCB_.ByteSize = 8;
	DCB_.Parity = NOPARITY;
	DCB_.StopBits = ONESTOPBIT;
	Sys=SetCommState(HCOM, &DCB_);
	if(Sys == 0)
	{
		//open_port = false;
		return;
	}

	SetCommMask(HCOM, EV_TXEMPTY);

	COMMTIMEOUTS Timeout;
	GetCommTimeouts(HCOM, &Timeout);
	Timeout.ReadIntervalTimeout = 10;
	Timeout.ReadTotalTimeoutConstant  = 10;
	Timeout.ReadTotalTimeoutMultiplier = 5;
	SetCommTimeouts(HCOM, &Timeout);

	SetupComm(HCOM, 1000, 1000);

	//open_port = true;
}

void COMPortClose()
{
	if (!((HCOM == INVALID_HANDLE_VALUE) || (HCOM == NULL)))
	{
		PurgeComm(HCOM, PURGE_TXCLEAR|PURGE_RXCLEAR);
		CloseHandle(HCOM);
		HCOM = NULL;

		//open_port = false;
	}
}

void UpdateAll()
{
	int res = 0;

	unsigned char buff_in[140] = {0};
	DWORD rw_len = 0;

	if ((HCOM == INVALID_HANDLE_VALUE) || (HCOM == NULL))
		return;

	// отправляем запрос на прием данных с контроллера
	WriteFile(HCOM, "i", 1, &rw_len, NULL);

	// принимаем информацию о входах контроллера 
	ReadFile(HCOM, (LPVOID)buff_in, sizeof(buff_in), &rw_len, NULL);

	if((buff_in[0] == 's')&&(buff_in[1] == 'p'))
	{
		// первый переменный резистор первой платы
		res = (buff_in[2] << 8) | buff_in[3];
		//if(res < 367)
		//	res = 367;
		//if(res > 664)
		//	res = 664;

		is_struct.wheel = res;//int((res - 515.5) / 1.485);

		// второй переменный резистор первой платы
		res = (buff_in[4] << 8) | buff_in[5];
		//if(res < 103)
		//	res = 103;
		//if(res > 320)
		//	res = 320;
		 
		is_struct.gas_pedal = res;//int((res - 103) / 2.17);

		// третий переменный резистор первой платы
		res = (buff_in[6] << 8) | buff_in[7];
		//if(res < 195)
		//	res = 195;
		//if(res > 590)
		//	res = 590;
		 
		is_struct.coupling_pedal = res;//int((res - 195) / 3.95);

		// четвёртый переменный резистор первой платы
		res = (buff_in[8] << 8) | buff_in[9];
		//if(res < 190)
		//	res = 190;
		//if(res > 352)
		//	res = 352;
		 
		is_struct.brake_pedal = res;//int((res - 190) / 1.62);

		//int byte_9 = buff_in[10]; if(byte_9 < 0) byte_9 = 256 + byte_9; // пятый переменный резистор первой платы
		//int byte_10 = buff_in[11]; if(byte_10 < 0) byte_10 = 256 + byte_10;

		//res_5 = byte_9 * 256 + byte_10;

		//int byte_11 = buff_in[12]; if(byte_11 < 0) byte_11 = 256 + byte_11; // шестой переменный резистор первой платы
		//int byte_12 = buff_in[13]; if(byte_12 < 0) byte_12 = 256 + byte_12;

		//res_6 = byte_11 * 256 + byte_12;

		char bit[2][4][8];	// две платы по 4 байта (8 бит)

		for(int boards = 0; boards < 2; boards++)
			for(int bytes = 0; bytes < 4; bytes++)
				for(int bits = 0; bits < 8; bits++)
					bit[boards][bytes][bits] = (buff_in[14 + bytes + (boards << 2)] >> bits) & 1;


		is_struct.brake = !bit[0][1][1];						// стояночный тормоз
		is_struct.left_turn = bit[1][0][4];					// левый повототник
		is_struct.right_turn = bit[1][0][3];				// правый поворотник
		is_struct.change_camera = bit[1][0][1];				// смена вида
		is_struct.dimensional_fires = bit[1][0][7];			// габаритные огни
		is_struct.passing_light = bit[1][2][2];				// ближний свет
		is_struct.headlight = bit[1][0][0];					// дальний свет
		is_struct.screen_wiper = bit[1][0][2];				// стеклоочиститель
		is_struct.look_at_left = bit[1][3][4];				// взгляд влево
		is_struct.look_at_right = bit[1][3][5];				// взгляд вправо
		is_struct.ignition = bit[0][1][0];					// зажигание
		is_struct.starter = bit[1][3][7];					// стартер
		is_struct.alarm_signal = bit[1][0][6];				// аварийная сигнализация
		is_struct.weight_switching_off = bit[1][0][5];		// отключение массы
		is_struct.first_step = bit[1][1][0];				// первая передача
		is_struct.second_step = bit[1][1][2];				// вторая передача
		is_struct.third_step = bit[1][1][3];				// третяя передача
		is_struct.fourth_step = bit[1][1][4];				// четвёрта передача
		is_struct.fifth_step = bit[0][1][2];				// пятая передача
		is_struct.back_step = bit[1][1][1];					// назад
		is_struct.belt_on = bit[1][3][6];					// пристёгивание ремня
		is_struct.transfers_divider = bit[1][2][6];			// делитель передач
		is_struct.interaxle_differential = bit[1][2][4];	// межосевой дифференциал
		is_struct.interwheel_differential_1 = bit[1][2][5];	// межколёсный дифференциал 1
		is_struct.interwheel_differential_2 = bit[1][2][3];	// межколёсный дифференциал 2
		is_struct.electrotorch_device = bit[1][3][3];		// электрофакельное устройство (ЭФУ)
	}

	char buff_out[11];

	buff_out[0] = 'u';

	////////////// вторая выходная плата /////////////

	buff_out[3] = speedometr;

	buff_out[4] = oil_pressure;

	buff_out[5] = fuel;

	buff_out[6] = engine_temperature;

	buff_out[7] = accumulator_charge;

	buff_out[8] = pneumatics_pressure;

	buff_out[9] = (tachometer == 51 ? 50 : tachometer);

	buff_out[10] = (fuel_lamp << 7)|(water_temp_lamp << 6)|(oil_pressure_lamp << 5)|(accumulator_lamp << 4)|
					(0 << 3)|(0 << 2)|(0 << 1)|(0);

	////////////// первая выходная плата /////////////

	buff_out[1] = (0 << 7)|(0 << 6)|(0 << 5)|(0 << 4)|
					(turn_lamp << 3)|(electrotorch_device_lamp << 2)|(0 << 1)|(0);

	buff_out[2] = (interwheel_differential_2_lamp << 7)|(interwheel_differential_1_lamp << 6)|(interaxle_differential_lamp << 5)|(stop_brake_lamp << 4)|
					(circuit_4 << 3)|(circuit_3 << 2)|(circuit_2 << 1)|(circuit_1);

	WriteFile(HCOM, buff_out, sizeof(buff_out), &rw_len, NULL);
}

extern "C"
{	
	SIGNAL_API in_signals* InSignals()
	{
		return &is_struct;
	}


	SIGNAL_API void Speedometr(int i_speedometr) // спидометр
	{
		//switch(i_speedometr)
		//{
		//case 0: speedometr = 210; break;
		//case 5: speedometr = 148; break;
		//case 10: speedometr = 114; break;
		//case 15: speedometr = 95; break;
		//case 20: speedometr = 80; break;
		//case 25: speedometr = 69; break;
		//case 30: speedometr = 61; break;
		//case 35: speedometr = 55; break;
		//case 40: speedometr = 50; break;
		//case 45: speedometr = 46; break;
		//case 50: speedometr = 42; break;
		//case 55: speedometr = 39; break;
		//case 60: speedometr = 36; break;
		//case 65: speedometr = 34; break;
		//case 70: speedometr = 32; break;
		//case 75: speedometr = 30; break;
		//case 80: speedometr = 28; break;
		//case 85: speedometr = 27; break;
		//case 90: speedometr = 26; break;
		//case 95: speedometr = 25; break;
		//case 100: speedometr = 24; break;
		//case 105: speedometr = 23; break;
		//case 110: speedometr = 22; break;
		//case 115: speedometr = 21; break;
		//default:
		//	{
		//		if(i_speedometr < 0)
		//			speedometr = 210;
		//		if(i_speedometr > 115)
		//			speedometr = 21;
		//	}
		//}
		speedometr = i_speedometr;
	}

	SIGNAL_API void OilPressure(int i_oil_pressure) // давление масла
	{
		//if(i_oil_pressure < 0)
		//	i_oil_pressure = 0;
		//if(i_oil_pressure > 100)
		//	i_oil_pressure = 100;

		//oil_pressure = i_oil_pressure + 95;
		oil_pressure = i_oil_pressure;
	}

	SIGNAL_API void Fuel(int i_fuel) // топливо
	{
		//if(i_fuel < 0)
		//	i_fuel = 0;
		//if(i_fuel > 100)
		//	i_fuel = 100;

		//fuel = 255 - 1.35 * i_fuel;
		fuel = i_fuel;
	}

	SIGNAL_API void EngineTemperature(int i_engine_temperature) // температура охлаждающей жидкости
	{
		//if(i_engine_temperature < 0)
		//	i_engine_temperature = 0;
		//if(i_engine_temperature > 120)
		//	i_engine_temperature = 120;

		//engine_temperature = 2 * i_engine_temperature;
		engine_temperature = i_engine_temperature;
	}

	SIGNAL_API void AccumulatorCharge(int i_accumulator_charge) // заряд
	{
		//if(i_accumulator_charge < 16)
		//	i_accumulator_charge = 16;
		//if(i_accumulator_charge > 32)
		//	i_accumulator_charge = 32;

		//accumulator_charge = 15 * (i_accumulator_charge - 16);
		accumulator_charge = i_accumulator_charge;
	}

	SIGNAL_API void PneumaticsPressure(int i_pneumatics_pressure) // пневматика
	{
		//switch(i_pneumatics_pressure)
		//{
		//case 0: pneumatics_pressure = 255; break;
		//case 1: pneumatics_pressure = 55; break;
		//case 2: pneumatics_pressure = 34; break;
		//case 3: pneumatics_pressure = 26; break;
		//case 4: pneumatics_pressure = 22; break;
		//case 5: pneumatics_pressure = 19; break;
		//case 6: pneumatics_pressure = 17; break;
		//case 7: pneumatics_pressure = 14; break;
		//case 8: pneumatics_pressure = 12; break;
		//case 9: pneumatics_pressure = 11; break;
		//case 10: pneumatics_pressure = 10; break;
		//default:
		//	{
		//		if(i_pneumatics_pressure < 0)
		//			pneumatics_pressure = 255;
		//		if(i_pneumatics_pressure > 10)
		//			pneumatics_pressure = 10;
		//	}
		//}
		pneumatics_pressure = i_pneumatics_pressure;
	}

	SIGNAL_API void Tachometer(int i_tachometer) // тахометр
	{
		//switch(i_tachometer)
		//{
		//case 0: tachometer = 60; break;
		//case 1: tachometer = 44; break;
		//case 2: tachometer = 40; break;
		//case 3: tachometer = 36; break;
		//case 4: tachometer = 33; break;
		//case 5: tachometer = 29; break;
		//case 6: tachometer = 27; break;
		//case 7: tachometer = 25; break;
		//case 8: tachometer = 23; break;
		//case 9: tachometer = 21; break;
		//case 10: tachometer = 20; break;
		//case 12: tachometer = 18; break;
		//case 14: tachometer = 16; break;
		//case 17: tachometer = 14; break;
		//case 21: tachometer = 12; break;
		//case 23: tachometer = 11; break;
		//case 26: tachometer = 10; break;
		//case 30: tachometer = 9; break;
		//case 32: tachometer = 8; break;
		//case 36: tachometer = 7; break;
		//case 40: tachometer = 6; break;
		//default:
		//	{
		//		if(i_tachometer < 0)
		//			tachometer = 49;
		//		if(i_tachometer > 40)
		//			tachometer = 6;
		//	}
		//}
		if(i_tachometer < 14)
			tachometer = 14;
		else
			tachometer = i_tachometer;
	}

	SIGNAL_API void ElectrotorchDeviceLamp(BOOL i_electrotorch_device_lamp)	// лампа ЭФУ
	{
		electrotorch_device_lamp = i_electrotorch_device_lamp;
	}

	SIGNAL_API void TurnLamp(BOOL i_turn_lamp)	// контрольная лампа включения указателей поворота
	{
		turn_lamp = i_turn_lamp;
	}

	SIGNAL_API void Circuit_1(BOOL i_circuit_1)	// контуры
	{
		circuit_1 = i_circuit_1;
	}

	SIGNAL_API void Circuit_2(BOOL i_circuit_2)
	{
		circuit_2 = i_circuit_2;
	}

	SIGNAL_API void Circuit_3(BOOL i_circuit_3)
	{
		circuit_3 = i_circuit_3;
	}

	SIGNAL_API void Circuit_4(BOOL i_circuit_4)
	{
		circuit_4 = i_circuit_4;
	}

	SIGNAL_API void StopBrakeLamp(BOOL i_stop_brake_lamp)						// контрольна лампа включения стояночого тормоза
	{
		stop_brake_lamp = i_stop_brake_lamp;
	}

	SIGNAL_API void InteraxleDifferential(BOOL i_interaxle_differential)		// межосевой дифференциал
	{
		interaxle_differential_lamp = i_interaxle_differential;
	}

	SIGNAL_API void InterwheelDifferential_1(BOOL i_interwheel_differential_1)	// межколёсный дифференциал 1
	{
		interwheel_differential_1_lamp = i_interwheel_differential_1;
	}

	SIGNAL_API void InterwheelDifferential_2(BOOL i_interwheel_differential_2)	// межколёсный дифференциал 2
	{
		interwheel_differential_2_lamp = i_interwheel_differential_2;
	}

	SIGNAL_API void AccumulatorLamp(BOOL i_accumulator_lamp)	// аккумулятор
	{
		accumulator_lamp = i_accumulator_lamp;
	}

	SIGNAL_API void OilPressureLamp(BOOL i_oil_pressure_lamp)	// лампа падения давления масла
	{
		oil_pressure_lamp = i_oil_pressure_lamp;
	}

	SIGNAL_API void WaterTempLamp(BOOL i_water_temp_lamp)	// лампа температуры воды
	{
		water_temp_lamp = i_water_temp_lamp;
	}

	SIGNAL_API void FuelLamp(BOOL i_fuel_lamp)	// топливо
	{
		fuel_lamp = i_fuel_lamp;
	}
}