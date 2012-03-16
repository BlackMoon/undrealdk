//---------------------------------------------------------------------------
#pragma hdrstop

#ifndef _MSC_VER
#pragma package(smart_init)
#endif

#include "car.h"
#include "udk\realloc.h"

// Колеса
struct TWheelX 
{
	// Вращение в RPM
	float rpm;
	// Тормозной крутящий момент
	float brakeTorque;
	// Крутящий момент на Шасси
	float chassisTorque;
	// Крутящий момент на колеса
	float torque;
};

// ---------------------------------------------------------------------------
struct TCarX 
{
	// Нормаль
	Vector u;
	// Обороты двигателя
	float rpm;
	//float deltaWheelRpm;
	// (bool) Зажигание 
	int ignition;
	// (bool)Стартер
	int starter;
	//int isRun;
	// Тормоз 
	float brake;
	// Сцепление
	float clutch;
	// Ручиник
	float handBrake;
	// Передача
	int gear;	
	// Дросель
	float throttle;
	// Вектор силы на машину
	Vector Flong;
	// Скорость
	Vector speed;
	// Ускорение
	Vector a;
	
	// gearbox 
	// Тип коробки передачь: полный, передний или задний привод
	int gearType;
	// Повышающая понижающая передача
	int transfer;
	/** Межосевой дифференциал */
	int diffAxle;
	/** Межколесный дифференциал 1 */
	int diffWheels1;
	/** Межколесный дифференциал 2 */
	int diffWheels2;

	// Wheel
	// кол-во колес
	int countWheel;
	// Массив колес
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

