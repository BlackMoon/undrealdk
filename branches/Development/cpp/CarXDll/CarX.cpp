//---------------------------------------------------------------------------
#pragma hdrstop

#ifndef _MSC_VER
#pragma package(smart_init)
#endif

#include "car.h"
#include "udk\realloc.h"

// ������
struct TWheelX 
{
	// �������� � RPM
	float rpm;
	// ��������� �������� ������
	float brakeTorque;
	// �������� ������ �� �����
	float chassisTorque;
	// �������� ������ �� ������
	float torque;
};

// ---------------------------------------------------------------------------
struct TCarX 
{
	// �������
	Vector u;
	// ������� ���������
	float rpm;
	//float deltaWheelRpm;
	// (bool) ��������� 
	int ignition;
	// (bool)�������
	int starter;
	//int isRun;
	// ������ 
	float brake;
	// ���������
	float clutch;
	// �������
	float handBrake;
	// ��������
	int gear;	
	// �������
	float throttle;
	// ������ ���� �� ������
	Vector Flong;
	// ��������
	Vector speed;
	// ���������
	Vector a;
	
	// gearbox 
	// ��� ������� ��������: ������, �������� ��� ������ ������
	int gearType;
	// ���������� ���������� ��������
	int transfer;
	/** ��������� ������������ */
	int diffAxle;
	/** ����������� ������������ 1 */
	int diffWheels1;
	/** ����������� ������������ 2 */
	int diffWheels2;

	// Wheel
	// ���-�� �����
	int countWheel;
	// ������ �����
	TUdkArray<TWheelX> wheels;
};

/* RPM */

int idx;

extern "C" __declspec(dllexport) int progressX(TCarX* fCar, float dt) 
{
	TCar car;

	car.setU(fCar->u);
	car.setClutch(fCar->clutch);
	car.setThrottle(fCar->throttle);
	car.setGear(fCar->gear);		
	car.setBrake(fCar->brake);
	car.setHandBrake(fCar->handBrake);
	car.gearbox.setGearType(fCar->gearType);
	car.gearbox.setTransferGear((TransferGear)fCar->transfer);

	if (fCar->ignition && fCar->starter)
		car.toRun();	
	else 
	{
		car.engine.isRun = (fCar->ignition == 1) && (fCar->rpm > 500);
		car.setRPM(fCar->rpm);
	}

	car.setSpeed(fCar->speed);

	for (idx = 0; idx < fCar->wheels.ArrayNum; idx++) 
	{
		car.wheels.wheels[idx].rpm = fCar->wheels.Data[idx].rpm;
		//car->wheels->wheels[i].torque = fCar->wheels.Data[i].torque;
	}
	//car.setDeltaWheelRpm(fCar->deltaWheelRpm);

	car.progress(dt);

	//fCar->ignition 
	//fCar->isRun	= car->engine->isRun;
	fCar->rpm = car.getRPM();
	fCar->throttle = car.getThrottle();
	fCar->speed = car.getSpeed();
	fCar->Flong = car.Flong();
	fCar->a = fCar->Flong / car.mass;

	for (idx = 0; idx < fCar->wheels.ArrayNum; idx++) 
	{
		fCar->wheels.Data[idx].rpm = (car.wheels.wheels[idx].rpm + fCar->wheels.Data[idx].rpm)/2;
		fCar->wheels.Data[idx].torque = (car.wheels.wheels[idx].torque + fCar->wheels.Data[idx].torque)/2;
		if (idx < 2)
			fCar->wheels.Data[idx].chassisTorque = car.wheels.getClutchTorque();
	}
	return 0;
}

