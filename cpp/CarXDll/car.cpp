//#pragma hdrstop

#include "stdafx.h"
#include "car.h"

const float WheelInertia = 9.0f;
const float EngineInertia = 1.3f;

// ������ ���������
void TCar::toRun() 
{
	if (!run) 
	{
		engine.toRun();
		run = true;
	}
}

// ��������� ���������
void TCar::toStop() 
{
	if (run) 
	{
		engine.toStop();
		run = false;
	}
}

TCar::TCar() :	run(false), mass(1000.f), 
				FCd(0.3f),	// ��������������� �������������
				FS(2.2f),	// ����������� ������� ���������� 
				fSpeed(Vector0),
				fBrake(0.f),
				fHandBrake(0.f)
{
}

//  �������� ��������� ���������� ������ �� ������� ������
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

	// �������� �������� ������ � ���������
	_engineTorque = engine.engineOutputTorque();

	// �������� ������� ��� ������� ����� �������� � ����������
	// � �������� �������������� �������� ������ �� ��������� � �� ������
	_baseTorque = (1 + _engineTorque) * baseTorque();

	// # ToDo �����. 40 � 2 ����������, ��������� ��� ������������ ����������� ��������, �������� ������ ��� 1 ����������, � ��� ����� ������� �������� ������ ��-��
	// �������� �����. �� ������� ��������, ������ ���������� �������, ��� ������� ������ �������� ����� ����������� ������� �������������� ������� ��� ��� ��������, � ����� �����.
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


	// =============== ������������� ��������� ������� ����� �������� =================================

	// ���� ���������� ����������� 
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

// ��������� ������� ������� ����������
void TCar::setU(Vector3D const u) 
{
	fU = u;
}

// ��������� �������� ������� �������� ����������
const Vector TCar::getU() 
{
	return fU;
}

// ��������� �������� ������� ��������
void TCar::setSpeed(Vector3D const speed) 
{
	fSpeed = speed;
}

// ��������� �������� ������� �������� ����������
const Vector TCar::getSpeed() 
{
	return fSpeed;
}

// ������� ���������������� �� ������� �������� ������
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

// ������������ �������� ������ �� ���������, �� �����
float TCar::toMotorTorque(float baseTorque) 
{
	return (baseTorque * engine.inertia);
}

// �������������� �������� ������ �� ������
float TCar::toWheelsTorque(float baseTorque) 
{
	float znak = (gearbox.getGear() == GEAR_BACK ? -1.f : 1.f);
	znak = 1.f;
	float Result = - znak* baseTorque * wheels.inertia; //#todo
	Result = Result;
	//Result = pow (Result, 3);
	return Result;
}

// ��������� �������� ������ �������� �������� 
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

// ������� ��������� �������
float TCar::getThrottle() 
{
	return engine.throttle;
}

// ������ �� ���������
// val(0..1)
void TCar::setClutch(float clutch) 
{
	engine.clutch = clutch;
}

// �������� ������� ������� �� ������ ���������
float TCar::getClutch() 
{
	return engine.clutch;
}

// ������� �������� RPM ���������
float TCar::getRPM() 
{
	return engine.rpm();
}

// ���������� �������� RPM ���������
void TCar::setRPM(float rpm) 
{
	engine.setRpm(rpm);
}

// �������� RPM ����� ������ � �������� ���������
float TCar::wheelRPM() 
{
	float Result = wheels.rpm() * gearbox.transRpm();
	return Result;
}

// ���������� ����� �������� 
void TCar::setGear(int n) 
{
	gearbox.setGear((Gear)n);
}


// ���������� ������� ������� �� ������
// val(0..1)
void TCar::setBrake(float val) 
{
	fBrake = val;
}

// ������� �������� ������� �� ������
float TCar::getBrake()
{
	return fBrake;
}

// ���������� ��������� �������
// val(0..1)
void TCar::setHandBrake(float val)
{
	fHandBrake = val;
}

// ������ �������?
float TCar::getHandBrake()
{
	return fHandBrake;
}

// =========================== ������������ ====================================
// � ������� ������ ������������ �� ������������ � ������ ������
// =============================================================================

// ���������� ����������������� ������������� 
float TCar::Cdrag() 
{
	return (0.5f * FCd * FS * RHO);
}

// ���������� ������������ ������������� ������
float TCar::Crr() 
{
	return mass * 0.015f; //0.015f;
}

// ���������� ������������� ��������� �������
float TCar::Cbraking() 
{
	const float kCbraking = 100.0f;
	return getBrake() * kCbraking;
}

// �������������� ���� ����������� �� ���������� �� ����� �������� 
const Vector TCar::Flong() 
{
	Vector Result = Ftraction() + Fdrag() + Frr() + Fbraking();
	return Result;
}

// ���� ����������� �� ������ � ���������
const Vector TCar::Ftraction() 
{
	Vector Result = (engine.engineOutputTorque() + wheels.getClutchTorque()) * gearbox.transTorqK() * fU / wheels.R;
	return Result;
}

// ���������������� ������������� ������������ �������� �� ����������
const Vector TCar::Fdrag()
{
	Vector Result = - Cdrag() * getSpeed().length() * getSpeed();
	return Result;
}

// ���� ������������� ������� �����
const Vector TCar::Frr() 
{
	return Vector0;
	Vector Result = - Crr() * getSpeed();
	return Result;
}

// ���� ������������� ��������� �������
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
