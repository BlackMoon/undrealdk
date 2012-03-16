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
	float wheel_pos;	// ��������� �������� ������
	int direct;			// ����������� �������� (1 - ������, 2 - �����)
	int force;			// ���� �������� (�� 0 �� 7)
	int right_data;		// ������ ������� ���������
	int left_data;		// ����� ������� ���������
};

struct wheel_push
{
	int mscs;		// ������������ ����� (� �������������)
	int direct;		// ����������� ����� (1 - ������, 2 - �����)
	int vibration;	// ��������
};

struct in_signals
{
	float wheel;					// ������� ������
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
	BOOL first_step;				// ������ ��������
	BOOL second_step;				// ������ ��������
	BOOL third_step;				// ������ ��������
	BOOL fourth_step;				// ������� ��������
	BOOL fifth_step;				// ����� ��������
	BOOL back_step;					// ������ ��������
	BOOL belt_on;					// ������������ �����
	BOOL hooter;					// �����
	BOOL flasher;					// �������
};

extern "C"
{
	SIGNAL_API in_signals* InSignals();

	SIGNAL_API void Speedometer(int i_speedometer);	// ���������
	SIGNAL_API void Tachometer(int i_tachometer);	// ��������
	SIGNAL_API void Fuel(int i_fuel);				// ������� �������
	SIGNAL_API void Temperature(int i_temperature);	// ����������� ���������

	SIGNAL_API void LeftTurn(BOOL i_left_turn);					// ����� ����������
	SIGNAL_API void RightTurn(BOOL i_right_turn);				// ������ ����������
	SIGNAL_API void Alarm(BOOL i_alarm);						// ��������
	SIGNAL_API void HeadLight(BOOL i_headlight);				// ������� ����
	SIGNAL_API void DimensionalFires(BOOL i_dimensional_fires);	// ���������� ����
	SIGNAL_API void Belt(BOOL i_belt);							// ������
	SIGNAL_API void Oil(BOOL i_oil);							// �����
	SIGNAL_API void Accumulator(BOOL i_accumulator);			// �����������
	SIGNAL_API void CheckEngine(BOOL i_check_engine);			// �������� ���������
	SIGNAL_API void Illumination(BOOL i_illumination);			// ��������� ��������� ������
	SIGNAL_API void Brake(BOOL i_brake);						// ������
	SIGNAL_API void FuelLamp(BOOL i_fuel_lamp);					// �������

	// �������� ����
	SIGNAL_API bool WheelInit();							// ������������� ����, ���� true, �� ���� �������� � ����� � ������
	SIGNAL_API void CarSpeed(float f_car_speed);			// ������� �������� ������ � ��/�
	SIGNAL_API void WheelPush(int i_mscs, int i_direct);	// ������� ������������ � ����������� ����� ����
															// i_mscs � �������������, i_direct - 1 - ������, 2 - �����
	
	SIGNAL_API void Finalize(BOOL b_final);	// ���������� ��������
}