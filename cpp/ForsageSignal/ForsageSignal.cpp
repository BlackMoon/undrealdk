#include "windows.h"
#include <stdio.h>
#include "ForsageSignal.h"
#include <string>
#include <Shlobj.h>

#define STEP 0.03

HANDLE				HCOM					= NULL;		// HANDLE COM-порта
CRITICAL_SECTION	objCriticalSection		= {0};		// критическая секция доступа к данным

const wheel_dynamics globalEmptyObject = {0};
const int iNanSignal = 123;

// структура, содержащая входные сигналы
in_signals is_struct = {iNanSignal, iNanSignal, iNanSignal, iNanSignal, iNanSignal, iNanSignal, iNanSignal, iNanSignal, iNanSignal, iNanSignal, 
						iNanSignal, iNanSignal, iNanSignal, iNanSignal, iNanSignal, iNanSignal, iNanSignal, iNanSignal, iNanSignal, iNanSignal, iNanSignal}; 

/////////////////////////////////////////////////////////////////////////
//////////////////////////   ВЫХОДНЫЕ СИГНАЛЫ   /////////////////////////
/////////////////////////////////////////////////////////////////////////

int speedometer;		// Спидометр
int tachometer;		// Тахометр
int fuel;			// Уровень топлива
int temperature;	// Температура двигателя

BOOL left_turn;			// левый поворотник
BOOL right_turn;		// правый поворотник
BOOL alarm;				// аварийка
BOOL headlight;			// дальний свет
BOOL dimensional_fires;	// габаритные огни
BOOL belt;				// ремень
BOOL oil;				// масло
BOOL accumulator;		// аккумулятор
BOOL check_engine;		// проверка двигателя
BOOL illumination;		// подсветка приборной панели
BOOL brake;				// ручник
BOOL fuel_lamp;			// топливо

float car_speed = 0;		// скорость машины

bool wheel_init = false;

// структура, содержащая параметры руля
wheel_dynamics wd_struct = {0, 0, 0, 0, 0};

// интерактивные параметры руля
wheel_push wp_struct = {0, 0};

//
bool final = false;

// функция инициализации руля
bool WheelInitialize()
{
	bool res = false;

	static int initial_tick = GetTickCount();

	static bool wheel_right = false;	// датчик фиксации правого крйнего положения
	static bool wheel_left = false;		// датчик фиксации левого крайнего положения
	static bool wheel_zero = false;		// датчик нулевого положения руля

	if(!wheel_right)
	{
		wd_struct.direct = 1;
		wd_struct.force = 3;

		if(GetTickCount() - initial_tick > 5000)
		{
			wd_struct.right_data = is_struct.wheel;

			wd_struct.direct = 0;
			wd_struct.force = 0;

			wheel_right = true;
		}
	}
	else
		if(!wheel_left)
		{
			wd_struct.direct = 2;
			wd_struct.force = 3;

			if(GetTickCount() - initial_tick > 10000)
			{
				wd_struct.left_data = is_struct.wheel;

				wd_struct.direct = 0;
				wd_struct.force = 0;

				wheel_left = true;
			}
		}
		else
			if(!wheel_zero)	// возвращение руля в нейтральное положение при условии правильной калибровки
			{
				if(abs(wd_struct.left_data - wd_struct.right_data) > 100)	// проверка правильности калибровки
				{
					if((wd_struct.wheel_pos < min(wd_struct.left_data, wd_struct.right_data) + 
						abs(wd_struct.left_data - wd_struct.right_data) / 2 - 100 * STEP) ||
						(wd_struct.wheel_pos > min(wd_struct.left_data, wd_struct.right_data) + 
						abs(wd_struct.left_data - wd_struct.right_data) / 2 + 100 * STEP))
					{
						wd_struct.direct = 1;
						wd_struct.force = 2;
					}
					else
					{
						wd_struct.direct = 1;
						wd_struct.force = 1;

						wheel_zero = true;
					}
				}
				else
					wheel_zero = true;
			}
			else
			{
				if(abs(wd_struct.left_data - wd_struct.right_data) > 100)	// проверка правильности калибровки
				{
					res = true;												// в этом случае возвращается true


					// далее, исходя из значений крайних положений, следует калибровка руля
					if(wd_struct.left_data > wd_struct.right_data)
					{
						if(wd_struct.wheel_pos > wd_struct.left_data)
							wd_struct.wheel_pos = wd_struct.left_data;
						if(wd_struct.wheel_pos < wd_struct.right_data)
							wd_struct.wheel_pos = wd_struct.right_data;

						wd_struct.wheel_pos = (wd_struct.wheel_pos - (wd_struct.left_data + wd_struct.right_data) / 2) * 2 / (wd_struct.left_data - wd_struct.right_data);
					}
					else
						if(wd_struct.left_data < wd_struct.right_data)
						{
							if(wd_struct.wheel_pos < wd_struct.left_data)
								wd_struct.wheel_pos = wd_struct.left_data;
							if(wd_struct.wheel_pos > wd_struct.right_data)
								wd_struct.wheel_pos = wd_struct.right_data;

							wd_struct.wheel_pos = -(wd_struct.wheel_pos - (wd_struct.right_data + wd_struct.left_data) / 2) * 2 / (wd_struct.right_data - wd_struct.left_data);
						}
				}
			}

	return res;
}

// возврат руля в среднее положение и рывки
void WheelDynamics(bool b_wheel_init)
{
	static int initial_tick = 0;

	if(b_wheel_init)
	{
		// определение возвращающего усилия в зависимости от скорости и величины поворота руля
		if((car_speed > 1) && (abs(wd_struct.wheel_pos) > STEP))
		{
			// определение силы возврата
			wd_struct.force = int((sqrt(abs(car_speed)) * abs(100 * wd_struct.wheel_pos)) / 70);

			// приведение величины силы к правильному виду
			if(wd_struct.force > 7)
				wd_struct.force = 7;
			if(wd_struct.force < 2)
				wd_struct.force = 2;

			// определение направления возврата 
			wd_struct.direct = (wd_struct.wheel_pos > 0 ? 1 : 2);
		}
		else
		{
			wd_struct.force = 1;
			wd_struct.direct = (wd_struct.wheel_pos > 0 ? 1 : 2);
		}
		
		//// наложение рывков
		//if(wp_struct.direct)
		//{
		//	push_timer++;

		//	if(push_timer >= 5)
		//	{
		//		push_timer = 0;

		//		wp_struct.push = 0;
		//		wp_struct.direct = 0;
		//	}

		//	if(wp_struct.direct == wd_struct.direct)	// случай одинакового направления рывка и возвратного движения
		//		wd_struct.force += wp_struct.push;
		//	else										// и случай разного направления
		//	{
		//		if(wd_struct.force > wp_struct.push)	// случай, когда возвратная сила больше силы рывка
		//			wd_struct.force -= wp_struct.push;
		//		else									// и обратный случай
		//		{
		//			wd_struct.force = 1 + wp_struct.push - wd_struct.force;
		//			wd_struct.direct = wp_struct.direct;
		//		}
		//	}

		// наложение рывков
		if(wp_struct.direct)
		{
			if(!initial_tick)
				initial_tick = GetTickCount();

			wd_struct.direct = wp_struct.direct;
			wd_struct.force = 5;

			if(GetTickCount() - initial_tick >= wp_struct.mscs)
			{
				initial_tick = 0;

				wp_struct.direct = 0;
			}

			// приведение величины силы к правильному виду
			if(wd_struct.force > 7)
				wd_struct.force = 7;
			if(wd_struct.force < 1)
				wd_struct.force = 1;
		}
	}
}

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

	unsigned char buff_in[28] = {0};
	DWORD rw_len = 0;

	if ((HCOM == INVALID_HANDLE_VALUE) || (HCOM == NULL))
		return;

	// отправляем запрос на прием данных с контроллера
	WriteFile(HCOM, "i", 1, &rw_len, NULL);

	// принимаем информацию о входах контроллера 
	ReadFile(HCOM, (LPVOID)buff_in, sizeof(buff_in), &rw_len, NULL);

	if((buff_in[0] == 's') && (buff_in[1] == 'p'))
	{
		// первый переменный резистор первой платы
		wd_struct.wheel_pos = (buff_in[2] << 8) | buff_in[3];

		wheel_init = WheelInitialize();
		is_struct.wheel = (wheel_init == true ? wd_struct.wheel_pos : wd_struct.wheel_pos);	// определение значения положения руля
																							// в зависимости от калибровки руль принимает либо значения
																							// от МИН до МАКС (-1 до 1), либо в диапазоне от 0 до 1023

		// второй переменный резистор первой платы
		is_struct.gas_pedal = (buff_in[4] << 8) | buff_in[5];

		// третий переменный резистор первой платы
		is_struct.coupling_pedal = (buff_in[6] << 8) | buff_in[7];

		// четвёртый переменный резистор первой платы
		is_struct.brake_pedal = (buff_in[8] << 8) | buff_in[9];

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


		is_struct.brake = bit[1][0][3];						// стояночный тормоз
		is_struct.left_turn = bit[1][3][7];					// левый повототник
		is_struct.right_turn = bit[1][2][2];				// правый поворотник
		is_struct.change_camera = bit[1][0][1];				// смена вида
		is_struct.dimensional_fires = bit[1][0][2];			// габаритные огни
		is_struct.passing_light = bit[1][3][6];				// ближний свет
		is_struct.headlight = bit[1][3][5];					// дальний свет
		is_struct.screen_wiper = bit[1][2][3];				// стеклоочиститель
		is_struct.look_at_left = bit[1][0][4];				// взгляд влево
		is_struct.look_at_right = bit[1][0][5];				// взгляд вправо
		is_struct.ignition = bit[1][3][4];					// зажигание
		is_struct.starter = bit[1][3][3];					// стартер
		is_struct.alarm_signal = bit[1][0][7];				// аварийная сигнализация
		is_struct.first_step = bit[1][1][4];				// первая передача
		is_struct.second_step = bit[1][1][3];				// вторая передача
		is_struct.third_step = bit[1][1][2];				// третяя передача
		is_struct.fourth_step = bit[1][1][1];				// четвёрта передача
		is_struct.fifth_step = bit[1][1][0];				// пятая передача
		is_struct.back_step = bit[1][0][0];					// назад
		is_struct.belt_on = bit[1][0][6];					// пристёгивание ремня
		is_struct.hooter = bit[1][2][4];					// гудок
		is_struct.flasher = bit[1][2][5];					// мигалка
	}

	WheelDynamics(wheel_init);

	if(final)
	{
		left_turn = 0;
		right_turn = 0;
		alarm = 0;
		headlight = 0;
		dimensional_fires = 0;
		belt = 0;
		oil = 0;
		accumulator = 0;
		check_engine = 0;
		illumination = 0;
		brake = 0;
		fuel_lamp = 0;
		wd_struct = globalEmptyObject;
	}

	char buff_out[14];

	buff_out[0] = 'u';

	////////////// первая выходная плата /////////////

	buff_out[1] =	(left_turn << 7)|	// порт A
					(right_turn << 6)|
					(alarm << 5)|
					(headlight << 4)|
					(dimensional_fires << 3)|
					(belt << 2)|
					(oil << 1)|
					(accumulator << 0);

	buff_out[2] =	(0 << 4)|	// порт В
					(fuel_lamp << 3)|
					(brake << 2)|
					(illumination << 1)|
					(check_engine << 0);

	buff_out[3] = wd_struct.force << 2;
					//(0 << 6)|	// порт С
					//(0 << 5)|
					//(0 << 4)|
					//(0 << 3)|
					//(0 << 2);

	buff_out[4] = wd_struct.direct << 3;
					//(0 << 7)|	// порт D
					//(0 << 6)|
					//(0 << 5)|
					//(0 << 4)|
					//(0 << 3);

	////////////// вторая выходная плата /////////////

	buff_out[5] = speedometer >> 8;
	buff_out[6] = speedometer;

	buff_out[7] = tachometer >> 8;
	buff_out[8] = tachometer;

	buff_out[9] = 0;//fuel >> 8;
	buff_out[10] = 0;//fuel;

	buff_out[11] = 0;//temperature >> 8;
	buff_out[12] = 0;//temperature;

	buff_out[13] = 1;

	WriteFile(HCOM, buff_out, sizeof(buff_out), &rw_len, NULL);
}



extern "C"
{	
	SIGNAL_API in_signals* InSignals()
	{
		return &is_struct;
	}


	SIGNAL_API void Speedometer(int i_speedometer) // спидометр
	{
		EnterCriticalSection(&objCriticalSection);
		speedometer = i_speedometer;
		LeaveCriticalSection(&objCriticalSection);
	}

	SIGNAL_API void Tachometer(int i_tachometer) // тахометр
	{
		EnterCriticalSection(&objCriticalSection);
		tachometer = i_tachometer;
		LeaveCriticalSection(&objCriticalSection);
	}

	SIGNAL_API void Fuel(int i_fuel)				// Уровень топлива
	{
		EnterCriticalSection(&objCriticalSection);
		fuel = i_fuel;
		LeaveCriticalSection(&objCriticalSection);
	}

	SIGNAL_API void Temperature(int i_temperature)	// Температура двигателя
	{
		EnterCriticalSection(&objCriticalSection);
		temperature = i_temperature;
		LeaveCriticalSection(&objCriticalSection);
	}

	SIGNAL_API void LeftTurn(BOOL i_left_turn)					// левый поворотник
	{
		EnterCriticalSection(&objCriticalSection);
		left_turn = i_left_turn;
		LeaveCriticalSection(&objCriticalSection);
	}

	SIGNAL_API void RightTurn(BOOL i_right_turn)				// правый поворотник
	{
		EnterCriticalSection(&objCriticalSection);
		right_turn = i_right_turn;
		LeaveCriticalSection(&objCriticalSection);
	}

	SIGNAL_API void Alarm(BOOL i_alarm)						// аварийка
	{
		EnterCriticalSection(&objCriticalSection);
		alarm = i_alarm;
		LeaveCriticalSection(&objCriticalSection);
	}

	SIGNAL_API void HeadLight(BOOL i_headlight)				// дальний свет
	{
		EnterCriticalSection(&objCriticalSection);
		headlight = i_headlight;
		LeaveCriticalSection(&objCriticalSection);
	}

	SIGNAL_API void DimensionalFires(BOOL i_dimensional_fires)	// габаритные огни
	{
		EnterCriticalSection(&objCriticalSection);
		dimensional_fires = i_dimensional_fires;
		LeaveCriticalSection(&objCriticalSection);
	}

	SIGNAL_API void Belt(BOOL i_belt)							// ремень
	{
		EnterCriticalSection(&objCriticalSection);
		belt = i_belt;
		LeaveCriticalSection(&objCriticalSection);
	}

	SIGNAL_API void Oil(BOOL i_oil)							// масло
	{
		EnterCriticalSection(&objCriticalSection);
		oil = i_oil;
		LeaveCriticalSection(&objCriticalSection);
	}

	SIGNAL_API void Accumulator(BOOL i_accumulator)			// аккумулятор
	{
		EnterCriticalSection(&objCriticalSection);
		accumulator = i_accumulator;
		LeaveCriticalSection(&objCriticalSection);
	}

	SIGNAL_API void CheckEngine(BOOL i_check_engine)			// проверка двигателя
	{
		EnterCriticalSection(&objCriticalSection);
		check_engine = i_check_engine;
		LeaveCriticalSection(&objCriticalSection);
	}

	SIGNAL_API void Illumination(BOOL i_illumination)			// подсветка приборной панели
	{
		EnterCriticalSection(&objCriticalSection);
		illumination = i_illumination;
		LeaveCriticalSection(&objCriticalSection);
	}

	SIGNAL_API void Brake(BOOL i_brake)						// ручник
	{
		EnterCriticalSection(&objCriticalSection);
		brake = i_brake;
		LeaveCriticalSection(&objCriticalSection);
	}

	SIGNAL_API void FuelLamp(BOOL i_fuel_lamp)					// топливо
	{
		EnterCriticalSection(&objCriticalSection);
		fuel_lamp = i_fuel_lamp;
		LeaveCriticalSection(&objCriticalSection);
	}

	SIGNAL_API void WheelPush(int i_mscs, int i_direct)	// задание силы и направления рывка руля
	{
		EnterCriticalSection(&objCriticalSection);
		wp_struct.direct = i_direct;
		wp_struct.mscs = i_mscs;

		if((wp_struct.direct > 2) || (wp_struct.direct < 0))
			wp_struct.direct = 0;

		if(wp_struct.mscs < 0)
			wp_struct.mscs = 0;
		LeaveCriticalSection(&objCriticalSection);
	}

	SIGNAL_API bool WheelInit()
	{
		return wheel_init;
	}

	SIGNAL_API void CarSpeed(float f_car_speed)
	{
		EnterCriticalSection(&objCriticalSection);
		car_speed = f_car_speed;
		LeaveCriticalSection(&objCriticalSection);
	}

	SIGNAL_API void Finalize(BOOL b_final)
	{
		EnterCriticalSection(&objCriticalSection);
		final = b_final;
		LeaveCriticalSection(&objCriticalSection);
	}
}