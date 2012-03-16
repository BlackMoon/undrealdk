// The following ifdef block is the standard way of creating macros which make exporting 
// from a DLL simpler. All files within this DLL are compiled with the KAMAZSIGNAL_EXPORTS
// symbol defined on the command line. This symbol should not be defined on any project
// that uses this DLL. This way any other project whose source files include this file see 
// SIGNAL_API functions as being imported from a DLL, whereas this DLL sees symbols
// defined with this macro as being exported.
#ifdef KAMAZSIGNAL_EXPORTS
#define SIGNAL_API __declspec(dllexport)
#else
#define SIGNAL_API __declspec(dllimport)
#endif

void COMPortOpen();
void COMPortClose();
void UpdateAll();

extern CRITICAL_SECTION objCriticalSection;

struct in_signals
{
	int wheel;						// рулевое колесо
	int gas_pedal;					// педаль газа
	int coupling_pedal;				// педаль сцеплени€
	int brake_pedal;				// педаль тормоза

	BOOL brake;						// сто€ночный тормоз
	BOOL left_turn;					// левый повототник
	BOOL right_turn;				// правый поворотник
	BOOL change_camera;				// смена вида
	BOOL dimensional_fires;			// габаритные огни
	BOOL passing_light;				// ближний свет
	BOOL headlight;					// дальний свет
	BOOL screen_wiper;				// стеклоочиститель
	BOOL look_at_left;				// взгл€д влево
	BOOL look_at_right;				// взгл€д вправо
	BOOL ignition;					// зажигание
	BOOL starter;					// стартер
	BOOL alarm_signal;				// аварийна€ сигнализаци€
	BOOL weight_switching_off;		// отключение массы
	BOOL first_step;				// перва€ передача
	BOOL second_step;				// втора€ передача
	BOOL third_step;				// трет€€ передача
	BOOL fourth_step;				// четвЄрта передача
	BOOL fifth_step;				// п€та€ передача
	BOOL back_step;					// задн€€ передача
	BOOL belt_on;					// пристЄгивание ремн€
	BOOL transfers_divider;			// делитель передач
	BOOL interaxle_differential;	// межосевой дифференциал
	BOOL interwheel_differential_1;	// межколЄсный дифференциал 1
	BOOL interwheel_differential_2;	// межколЄсный дифференциал 2
	BOOL electrotorch_device;		// электрофакельное устройство (Ё‘”)
};

extern "C"
{
	SIGNAL_API in_signals* InSignals();

	SIGNAL_API void Speedometr(int i_speedometr);
	SIGNAL_API void OilPressure(int i_oil_pressure);
	SIGNAL_API void Fuel(int i_fuel);
	SIGNAL_API void EngineTemperature(int i_engine_temperature);
	SIGNAL_API void AccumulatorCharge(int i_accumulator_charge);
	SIGNAL_API void PneumaticsPressure(int i_pneumatics_pressure);
	SIGNAL_API void Tachometer(int i_tachometer);

	SIGNAL_API void ElectrotorchDeviceLamp(BOOL i_electrotorch_device_lamp);	// лампа Ё‘”
	SIGNAL_API void TurnLamp(BOOL i_turn_lamp);									// контрольна€ лампа включени€ указателей поворота
	SIGNAL_API void Circuit_1(BOOL i_circuit_1);								// контуры
	SIGNAL_API void Circuit_2(BOOL i_circuit_2);
	SIGNAL_API void Circuit_3(BOOL i_circuit_3);
	SIGNAL_API void Circuit_4(BOOL i_circuit_4);
	SIGNAL_API void StopBrakeLamp(BOOL i_stop_brake_lamp);						// контрольна лампа включени€ сто€ночого тормоза
	SIGNAL_API void InteraxleDifferential(BOOL i_interaxle_differential);		// межосевой дифференциал
	SIGNAL_API void InterwheelDifferential_1(BOOL i_interwheel_differential_1);	// межколЄсный дифференциал 1
	SIGNAL_API void InterwheelDifferential_2(BOOL i_interwheel_differential_2);	// межколЄсный дифференциал 2
	SIGNAL_API void AccumulatorLamp(BOOL i_accumulator_lamp);					// аккумул€тор
	SIGNAL_API void OilPressureLamp(BOOL i_oil_pressure_lamp);					// лампа падени€ давлени€ масла
	SIGNAL_API void WaterTempLamp(BOOL i_water_temp_lamp);						// лампа температуры воды
	SIGNAL_API void FuelLamp(BOOL i_fuel_lamp);									// топливо
}