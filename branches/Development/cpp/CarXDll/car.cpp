//#pragma hdrstop

#include "stdafx.h"
#include "car.h"

const float WheelInertia = 9.0f;
const float EngineInertia = 1.3f;

// Запуск двигателя
void TCar::toRun() 
{
	if (!run) 
	{
		engine.toRun();
		run = true;
	}
}

// Остановка двигателя
void TCar::toStop() 
{
	if (run) 
	{
		engine.toStop();
		run = false;
	}
}

TCar::TCar() :	run(false), mass(1000.f), 
				FCd(0.3f),	// Ародинамическое сопротивление
				FS(2.2f),	// Фронтальная плащадь автомобиля 
				fSpeed(Vector0),
				fBrake(0.f),
				fHandBrake(0.f)
{
}

//  Пересчет состояния автомобиля исходя из входных данных
void TCar::progress(float dt) 
{
	float wRPM;
	#ifndef _MSC_VER
	Vector a = Flong() / mass;
	fSpeed += dt * a;

	if (fSpeed != Vector0) 
	{
		float znak = -(fSpeed/fSpeed.length()- fU).length() + 1;
		wheels.progress(znak*getSpeed().length(), dt);
	}
	#endif

	// Поулчаем крутящий момент с двигателя
	_engineTorque = engine.engineOutputTorque();

	// Получаем разницу вов ращении между колесами и двигателем
	// И получаем компенсирующий крутящий момент на двигатель и на колеса
	_baseTorque = (1 + _engineTorque) * baseTorque();

	// # ToDo коэфф. 40 и 2 магические, подобраны для соответствия большинства передачь, проблема сейчас для 1 пониженной, у нее очень большой крутящий момент из-за
	// большого коэфф. на коробке передачь, машина двигаеться рывками, для решения данной проблемы нужно попробывать созадть индивидуальный костыль под эту передачу, с этими коэфф.
	// 
	_MotorTorque = 40*toMotorTorque(_baseTorque);
	_WheelsTorque = 2*toWheelsTorque(_baseTorque);

	engine.setClutchTorque(_MotorTorque);

	if (fabs(_engineTorque) > 0.1f) 
		wheels.setClutchTorque(_WheelsTorque);
	if (fabs (_baseTorque) > 0.1)
		wheels.setTorque(gearbox.transTorqK(_engineTorque + _WheelsTorque));
	else 
		wheels.setTorque(1);
	wRPM = wheelRPM();

	engine.progress(dt);

	/*engine.setRpm(
		(1.0-getClutch()) * engine.rpm() + 
		getClutch()* (( 3* engine.rpm() - wheelRPM()) / 2.0)
	);*/


	// =============== Распределение крутящего момента между колесами =================================

	// Сила блокировки дифиренцала 
	//float DiffForce = 0.f;
	//float wheelDiff;

	for (idx = 0; idx < wheels.WheelsNum; idx++)
	{
		if ((gearbox.getGearType() == GEAR_FWD) && ((idx == 0) || (idx == 1))) 
		{
			wheels.wheels[idx].torque = 0.f;
			continue;
		}

		if ((gearbox.getGearType() == GEAR_RWD) && ((idx == 2) || (idx == 3))) 
		{
			wheels.wheels[idx].torque = 0.f;
			continue;
		}

		/*if (gearbox.getGearType() == GEAR_RWD) 
		{
			wheelDiff =  wheels.wheels[0].rpm - wheels.wheels[1].rpm;
			wheels.wheels[0].rpm -= wheelDiff * 0.5f * DiffForce * engine.throttle * getClutch();
			wheels.wheels[1].rpm += wheelDiff * 0.5f * DiffForce * engine.throttle * getClutch();
		}

		if (gearbox.getGearType() == GEAR_FWD) 
		{
			wheelDiff =  wheels.wheels[0].rpm - wheels.wheels[1].rpm;
			wheels.wheels[0].rpm -= wheelDiff * 0.5f * DiffForce * engine.throttle * getClutch();
			wheels.wheels[1].rpm += wheelDiff * 0.5f * DiffForce * engine.throttle * getClutch();

			wheelDiff =  wheels.wheels[2].rpm - wheels.wheels[3].rpm;
			wheels.wheels[2].rpm -= wheelDiff * 0.5f * DiffForce * engine.throttle * getClutch();
			wheels.wheels[3].rpm += wheelDiff * 0.5f * DiffForce * engine.throttle * getClutch();
		}*/

		wheels.wheels[idx].rpm = wheels.rpm();
		if ((gearbox.getGearType() == GEAR_RWD) || (gearbox.getGearType() == GEAR_FWD))
			wheels.wheels[idx].torque = wheels.getTorque() * 0.5f;
		else
			wheels.wheels[idx].torque = wheels.getTorque() * 0.25f;
	}
}

// Установка Вектора нормали автомобиля
void TCar::setU(Vector3D const u) 
{
	fU = u;
}

// Получение текущего вектора номрмали автомобиля
const Vector TCar::getU() 
{
	return fU;
}

// Установка текущего вектора скорости
void TCar::setSpeed(Vector3D const speed) 
{
	fSpeed = speed;
}

// Получение текущего вектора скорости автомобиля
const Vector TCar::getSpeed() 
{
	return fSpeed;
}

// Базовый неизрасходванный на колесах крутящий момент
float TCar::baseTorque() 
{
	if (gearbox.transRpm() == 0) 
        return 0;
	float WheelRPM = wheelRPM();
	float EngineRPM = getRPM();
	
	float K = (WheelRPM - EngineRPM) == 0.f ? 0.f : (WheelRPM - EngineRPM) / EngineRPM;
	float Result = (int)(1000.f * K * engine.clutch / (wheels.inertia + engine.inertia))/1000.0f;
	return Result;
}

// Возвращенный крутящий момент на двигатель, от колес
float TCar::toMotorTorque(float baseTorque) 
{
	return (baseTorque * engine.inertia);
}

// Дополнительный крутящий момент на колеса
float TCar::toWheelsTorque(float baseTorque) 
{
	float znak = (gearbox.getGear() == GEAR_BACK ? -1.f : 1.f);
	znak = 1.f;
	float Result = - znak* baseTorque * wheels.inertia; //#todo
	Result = Result;
	//Result = pow (Result, 3);
	return Result;
}

// Установка значения уровня поднятия дросселя 
void TCar::setThrottle(float throttle) 
{
	if (throttle >= 0) 
	{
		engine.throttle = throttle;
		if (gearbox.getGear() == GEAR_BACK )
		    gearbox.setGear(GEAR_FIRST);
	}
	else 
	{
		engine.throttle = - throttle;
		gearbox.setGear(GEAR_BACK);
	}

}

// Текущее положение дроселя
float TCar::getThrottle() 
{
	return engine.throttle;
}

// нажате на сцепление
// val(0..1)
void TCar::setClutch(float clutch) 
{
	engine.clutch = clutch;
}

// Значение сетпени нажатия на педаль сцепления
float TCar::getClutch() 
{
	return engine.clutch;
}

// Текущее значение RPM двигателя
float TCar::getRPM() 
{
	return engine.rpm();
}

// Установить значение RPM двигателя
void TCar::setRPM(float rpm) 
{
	engine.setRpm(rpm);
}

// Значение RPM колес машины в оборотах двигателя
float TCar::wheelRPM() 
{
	float Result = wheels.rpm() * gearbox.transRpm();
	return Result;
}

// Установить номер передачи 
void TCar::setGear(int n) 
{
	gearbox.setGear((Gear)n);
}


// установить степень нажатия на тормоз
// val(0..1)
void TCar::setBrake(float val) 
{
	fBrake = val;
}

// Текущее значение нажатия на тормоз
float TCar::getBrake()
{
	return fBrake;
}

// установить включения ручника
// val(0..1)
void TCar::setHandBrake(float val)
{
	fHandBrake = val;
}

// Ручник включен?
float TCar::getHandBrake()
{
	return fHandBrake;
}

// =========================== АЭРОДИНАМИКА ====================================
// В текущий момент Айродинамика не учитываеться в работе машины
// =============================================================================

// Коэффицент афродинамического сопротивления 
float TCar::Cdrag() 
{
	return (0.5f * FCd * FS * RHO);
}

// Коэффицент инерционного сопротивления колесс
float TCar::Crr() 
{
	return mass * 0.015f; //0.015f;
}

// Коэффицент сопротивления тормозной системы
float TCar::Cbraking() 
{
	const float kCbraking = 100.0f;
	return getBrake() * kCbraking;
}

// Реузльтирующая сила действующая на автомобиль во время движения 
const Vector TCar::Flong() 
{
	Vector Result = Ftraction() + Fdrag() + Frr() + Fbraking();
	return Result;
}

// Сила действующая на колеса с двигателя
const Vector TCar::Ftraction() 
{
	Vector Result = (engine.engineOutputTorque() + wheels.getClutchTorque()) * gearbox.transTorqK() * fU / wheels.R;
	return Result;
}

// Аэродинамическое сопротивление оказываеммое воздухом на автомобиль
const Vector TCar::Fdrag()
{
	Vector Result = - Cdrag() * getSpeed().length() * getSpeed();
	return Result;
}

// Сила сопротивления инерции колес
const Vector TCar::Frr() 
{
	return Vector0;
	Vector Result = - Crr() * getSpeed();
	return Result;
}

// Сила сопротивления тормозной системы
const Vector TCar::Fbraking() 
{
	//	return (stateCar->velocity.length() != 0) ? -stateCar->u * Cbraking();
	Vector Result;
	if (getSpeed().length() != 0)
		Result = - Cbraking() * getSpeed() / getSpeed().length();
	else 
		Result = Vector0;
	return Result;
}
