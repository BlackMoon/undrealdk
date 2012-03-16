// The following ifdef block is the standard way of creating macros which make exporting 
// from a DLL simpler. All files within this DLL are compiled with the FORSAGESIGNAL_EXPORTS
// symbol defined on the command line. This symbol should not be defined on any project
// that uses this DLL. This way any other project whose source files include this file see 
// SIGNAL_API functions as being imported from a DLL, whereas this DLL sees symbols
// defined with this macro as being exported.
#ifdef FORSAGESIGNAL_EXPORTS
#define SIGNAL_API __declspec(dllexport)
#else
#define SIGNAL_API __declspec(dllimport)
#endif

void COMPortOpen();
void COMPortClose();
void UpdateAll();

extern CRITICAL_SECTION objCriticalSection;

struct wheel_dynamics
{
	float wheel_pos;	// положение рулевого колеса
	int direct;			// направление вращения (1 - вправо, 2 - влево)
	int force;			// сила вращения (от 0 до 7)
	int right_data;		// правое крайнее положение
	int left_data;		// левое крайнее положение
};

struct wheel_push
{
	int mscs;		// длительность рывка (в миллисекундах)
	int direct;		// направление рывка (1 - вправо, 2 - влево)
	int vibration;	// вибрация
};

struct in_signals
{
	float wheel;					// рулевое колесо
	int gas_pedal;					// педаль газа
	int coupling_pedal;				// педаль сцепления
	int brake_pedal;				// педаль тормоза

	BOOL brake;						// стояночный тормоз
	BOOL left_turn;					// левый повототник
	BOOL right_turn;				// правый поворотник
	BOOL change_camera;				// смена вида
	BOOL dimensional_fires;			// габаритные огни
	BOOL passing_light;				// ближний свет
	BOOL headlight;					// дальний свет
	BOOL screen_wiper;				// стеклоочиститель
	BOOL look_at_left;				// взгляд влево
	BOOL look_at_right;				// взгляд вправо
	BOOL ignition;					// зажигание
	BOOL starter;					// стартер
	BOOL alarm_signal;				// аварийная сигнализация
	BOOL first_step;				// первая передача
	BOOL second_step;				// вторая передача
	BOOL third_step;				// третяя передача
	BOOL fourth_step;				// четвёрта передача
	BOOL fifth_step;				// пятая передача
	BOOL back_step;					// задняя передача
	BOOL belt_on;					// пристёгивание ремня
	BOOL hooter;					// гудок
	BOOL flasher;					// мигалка
};

extern "C"
{
	SIGNAL_API in_signals* InSignals();

	SIGNAL_API void Speedometer(int i_speedometer);	// Спидометр
	SIGNAL_API void Tachometer(int i_tachometer);	// Тахометр
	SIGNAL_API void Fuel(int i_fuel);				// Уровень топлива
	SIGNAL_API void Temperature(int i_temperature);	// Температура двигателя

	SIGNAL_API void LeftTurn(BOOL i_left_turn);					// левый поворотник
	SIGNAL_API void RightTurn(BOOL i_right_turn);				// правый поворотник
	SIGNAL_API void Alarm(BOOL i_alarm);						// аварийка
	SIGNAL_API void HeadLight(BOOL i_headlight);				// дальний свет
	SIGNAL_API void DimensionalFires(BOOL i_dimensional_fires);	// габаритные огни
	SIGNAL_API void Belt(BOOL i_belt);							// ремень
	SIGNAL_API void Oil(BOOL i_oil);							// масло
	SIGNAL_API void Accumulator(BOOL i_accumulator);			// аккумулятор
	SIGNAL_API void CheckEngine(BOOL i_check_engine);			// проверка двигателя
	SIGNAL_API void Illumination(BOOL i_illumination);			// подсветка приборной панели
	SIGNAL_API void Brake(BOOL i_brake);						// ручник
	SIGNAL_API void FuelLamp(BOOL i_fuel_lamp);					// топливо

	// Активный руль
	SIGNAL_API bool WheelInit();							// инициализация руля, если true, то руль активный и готов к работе
	SIGNAL_API void CarSpeed(float f_car_speed);			// пердача скорости машины в км/ч
	SIGNAL_API void WheelPush(int i_mscs, int i_direct);	// задание длительности и направления рывка руля
															// i_mscs в миллисекундах, i_direct - 1 - вправо, 2 - влево
	
	SIGNAL_API void Finalize(BOOL b_final);	// выключение приборов
}