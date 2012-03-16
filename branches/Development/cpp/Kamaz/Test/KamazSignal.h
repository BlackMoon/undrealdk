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
	int wheel;						// ������� ������
	int gas_pedal;					// ������ ����
	int coupling_pedal;				// ������ ���������
	int brake_pedal;				// ������ �������

	BOOL brake;						// ���������� ������
	BOOL left_turn;					// ����� ����������
	BOOL right_turn;				// ������ ����������
	BOOL change_camera;				// ����� ����
	BOOL dimensional_fires;			// ���������� ����
	BOOL passing_light;				// ������� ����
	BOOL headlight;					// ������� ����
	BOOL screen_wiper;				// ����������������
	BOOL look_at_left;				// ������ �����
	BOOL look_at_right;				// ������ ������
	BOOL ignition;					// ���������
	BOOL starter;					// �������
	BOOL alarm_signal;				// ��������� ������������
	BOOL weight_switching_off;		// ���������� �����
	BOOL first_step;				// ������ ��������
	BOOL second_step;				// ������ ��������
	BOOL third_step;				// ������ ��������
	BOOL fourth_step;				// ������� ��������
	BOOL fifth_step;				// ����� ��������
	BOOL back_step;					// ������ ��������
	BOOL belt_on;					// ������������ �����
	BOOL transfers_divider;			// �������� �������
	BOOL interaxle_differential;	// ��������� ������������
	BOOL interwheel_differential_1;	// ���������� ������������ 1
	BOOL interwheel_differential_2;	// ���������� ������������ 2
	BOOL electrotorch_device;		// ���������������� ���������� (���)
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

	SIGNAL_API void ElectrotorchDeviceLamp(BOOL i_electrotorch_device_lamp);	// ����� ���
	SIGNAL_API void TurnLamp(BOOL i_turn_lamp);									// ����������� ����� ��������� ���������� ��������
	SIGNAL_API void Circuit_1(BOOL i_circuit_1);								// �������
	SIGNAL_API void Circuit_2(BOOL i_circuit_2);
	SIGNAL_API void Circuit_3(BOOL i_circuit_3);
	SIGNAL_API void Circuit_4(BOOL i_circuit_4);
	SIGNAL_API void StopBrakeLamp(BOOL i_stop_brake_lamp);						// ���������� ����� ��������� ���������� �������
	SIGNAL_API void InteraxleDifferential(BOOL i_interaxle_differential);		// ��������� ������������
	SIGNAL_API void InterwheelDifferential_1(BOOL i_interwheel_differential_1);	// ���������� ������������ 1
	SIGNAL_API void InterwheelDifferential_2(BOOL i_interwheel_differential_2);	// ���������� ������������ 2
	SIGNAL_API void AccumulatorLamp(BOOL i_accumulator_lamp);					// �����������
	SIGNAL_API void OilPressureLamp(BOOL i_oil_pressure_lamp);					// ����� ������� �������� �����
	SIGNAL_API void WaterTempLamp(BOOL i_water_temp_lamp);						// ����� ����������� ����
	SIGNAL_API void FuelLamp(BOOL i_fuel_lamp);									// �������
}