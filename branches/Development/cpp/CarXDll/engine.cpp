// ---------------------------------------------------------------------------
#pragma hdrstop

#include "stdafx.h"
#include "engine.h"

// ---------------------------------------------------------------------------

//#pragma package(smart_init)

#define MAX_RPM 3000
#define MIN_RPM 600

TEngine::TEngine() 
{
	isRun = false;
	mass = 115.0f; // кг
	fClutchTorque = 0;

	braking_offset = 0.0f;
	braking_coeff = 0.3f;

	idle_rpm = 900.0f;
	idle_throttle = 0.3f;

	start_rpm = 700.0f;
	stall_rpm = MIN_RPM;
	max_rpm = MAX_RPM;

	inertia = 6.6f * pow(0.6f, 2)/2 + 24.0f * pow(0.1f, 2)/2;
	//inertia = 4;
//	inertia_engine = 20.0f * pow(0.1f, 2) / 2.0f; ;
}

void TEngine::progress(float dt) 
{
	float maxRpm;

	maxRpm = stall_rpm + ((max_rpm - stall_rpm) / (1.0 - 0.2f)) * (throttle - 0.2);
	
	
	if (fRPM < stall_rpm && isRun)
	{
		//rpm = 0;
		isRun = false;
	}

	if (fRPM < idle_rpm && throttle < 0.3f && isRun)
		throttle += 0.1f;

	// float torq = curve_torque() * throttle;
	if (maxRpm > fRPM)
		torque = curve_torque() * throttle;// - braking_torque();
	else
		torque = curve_torque() * throttle - braking_torque();
	//if (fClutchTorque < 0 && torque < -fClutchTorque)
	//	fClutchTorque = - torque + fabs (torque - fClutchTorque);
	additionRPM = (torque + getClutchTorque()) / inertia;


	/*if (fRPM > -additionRPM)
	//if (fRPM < -additionRPM)
		fRPM += additionRPM;
	else
		additionRPM = -fRPM;*/
	if (!(maxRpm <= fRPM && additionRPM > 0))
		fRPM += additionRPM;
	else
		fRPM -= additionRPM;
}

float TEngine::getThrottle() 
{
	return throttle;
}

float TEngine::braking_torque() 
{
	braking_coeff = (isRun ? 0.4f : 7.0f);
	if (fRPM < 0 || fRPM > max_rpm) 
    	braking_coeff = 200.0f;
	
	braking_offset = isRun ? 5.0f : 10.0f;
	return (braking_offset + braking_coeff * rps());
}

float TEngine::braking_torque_curve() 
{
	float torque = 0.0f;

	const int size = 15;

	/* ХЗ */
	/*
	float TorqueRpm[size][2] = {
		{0, 0}, {500, 25}, {1000, 35}, {1500, 55}, {2000, 85}, {2500, 95},
		{3000, 105}, {3500, 110}, {4000, 115}, {4500, 115}, {5000, 110},
		{5500, 105}, {6000, 100}, {6500, 95}, {7000, 90}, {7500, 80}, {8000, 70
		}, {8500, 50}, {9000, 40}, {9500, 10}, {10000, 0}};
	*/

	// Москвич 412
	static float TorqueRpm[size][2] = {
		{0, 0},
		{500, 2},
		{1000, 4},
		{1500, 6},
		{2000, 8},
		{2500, 15},
		{3000, 16},
		{3500, 26},
		{4000, 32},
		{4500, 36},
		{5000, 39},
		{5500, 43},
		{6000, 50},
		{6500, 5},
	    {7000, 0}};

	if ((rpm() < 0.f) || (rpm() > TorqueRpm[size - 1][0]) || !isRun) 
		torque = 0.0f;
	else
	{
		for (idx = 0; idx < size; idx++) 
		{
			if (rpm() > TorqueRpm[idx][0])
				continue;
			if (rpm() == TorqueRpm[idx][0]) 
			{
				torque = TorqueRpm[idx][1];
				break;
			}
			if ((idx > 0) && (TorqueRpm[idx - 1][0] < rpm()) && (rpm() <= TorqueRpm[idx][0]))
			{
				torque = (TorqueRpm[idx][1] - TorqueRpm[idx - 1][1]) / (TorqueRpm[idx][0] - TorqueRpm[idx - 1][0]) * (rpm() - TorqueRpm[idx - 1][0]) + TorqueRpm[idx - 1][1];
				break;
			}
		}
	}
	return torque;
}

float TEngine::curve_torque() 
{
	torque = 0.0f;
	_rpm = ((throttle != 0.f) ? int(rpm() / throttle) : 0);
	_rpm = rpm();

	/* ХЗ */
	/*
	float TorqueRpm[size][2] = {
		{0, 0}, {500, 25}, {1000, 35}, {1500, 55}, {2000, 85}, {2500, 95},
		{3000, 105}, {3500, 110}, {4000, 115}, {4500, 115}, {5000, 110},
		{5500, 105}, {6000, 100}, {6500, 95}, {7000, 90}, {7500, 80}, {8000, 70
		}, {8500, 50}, {9000, 40}, {9500, 10}, {10000, 0}};
	*/
	/*// Москвич 412
	const int size = 13;
	float TorqueRpm[size][2] = {
		{0, 0},
		{500, 5},
		{1000, 10},
		{1500, 18},
		{2000, 25},
		{2500, 33},
		{3000, 42},
		{3500, 48},
		{4000, 53},
		{4500, 55},
		{5000, 55},
		{5500, 43},
		{6000, 0}};*/

	// КАМАЗ
	const short size = 15;
	static float TorqueRpm[size][2] = 
	{
		{0, 0},
		{550, 0},
		{600, 30},
		{800, 42},
		{1000, 52},
		{1200, 59},
		{1400, 63},
		{1600, 65},
		{1800, 65},
		{2000, 63},
		{2200, 61},
		{2400, 58},
		{2600, 53},
		{2800, 40},
		{3000, 0}
	};


	if ((_rpm < 0) || (_rpm > TorqueRpm[size - 1][0]) || !isRun) 
		torque = 0.0f;
	else
	{
		for (idx = 0; idx < size; idx++) 
		{
			if (_rpm > TorqueRpm[idx][0])
				continue;
			if (_rpm == TorqueRpm[idx][0]) 
			{
				torque = TorqueRpm[idx][1];
				break;
			}
			if ((idx > 0) && (TorqueRpm[idx - 1][0] < _rpm) && (_rpm <= TorqueRpm[idx][0]))
			{
				torque = (TorqueRpm[idx][1] - TorqueRpm[idx - 1][1]) / (TorqueRpm[idx][0] - TorqueRpm[idx - 1][0]) * (_rpm - TorqueRpm[idx - 1][0]) + TorqueRpm[idx - 1][1];
				break;
			}
		}
	}

	return torque;
}

float TEngine::engineOutputTorque() 
{
	return (curve_torque() * throttle * clutch);
}


void TEngine::setClutchTorque (float torque) 
{
/*	if(curve_torque() + torque < 0)
	{
		isRun = false;
		fRPM = 0;
		fClutchTorque = 0;
	}
	else */
		fClutchTorque = torque;
}

float TEngine::getClutchTorque() 
{
	return fClutchTorque;
}

float TEngine::rpm() 
{
	return fRPM;
}
void TEngine::setRpm(float rpm) 
{
	if (rpm < MIN_RPM)
	{
		isRun = false;
		rpm = 0;
	}
	fRPM = rpm;
}

float TEngine::rps() 
{
	return fRPM / 60.f;
}

void TEngine::toRun() 
{
	isRun = true;
	//clutch = 0;
	setRpm(start_rpm);
}

void TEngine::toStop() 
{
	isRun = false;
}
