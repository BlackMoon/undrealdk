// ---------------------------------------------------------------------------

#ifndef engineH
#define engineH
// ---------------------------------------------------------------------------
#include <math.h>
// ---------------------------------------------------------------------------
// const float cInertion = 20.0f * pow(0.1f, 2) / 2.0f;
// const float cBackTorque = 0.303f * 0.3f;
// const float cIdleRPM = 1000.0f;
const float cRpmToThrottle = (7000.0f - 1000.0f) / (1.0f - 0.3f);

class TEngine {

private:
	float fClutchTorque;
	/**
	 * Частота вращения двигате<stereotype>property</stereotype>
	 */
	float fRPM;

	volatile float torque;
	volatile float additionRPM;
	volatile int _rpm;
	volatile short idx;
public:
	/**
	 * Уровень поднятия дроселя 0..1
	 * <stereotype>property</stereotype>
	 */
	float throttle;

	void setClutchTorque (float torque);
	float getClutchTorque();

	float getThrottle();
	float braking_torque();
	float braking_torque_curve();
	// График Крутящего момента от RPM
	float curve_torque();
	float engineOutputTorque();
	float rpm();
	void setRpm(float rpm);
	float rps();

	bool isRun;
	float starter_torque;
	bool start_stalled;
	float start_rpm;
	float stall_rpm;
	bool enable_stall;

	float mass;
	float inertia;

	float idle_rpm;
	float idle_throttle;
	float autoclutch_rpm;
	float max_rpm;
	int rev_limiter_time;
	float braking_offset;
	float braking_coeff;
	float clutch;

	TEngine();
	void progress(float dt);
	void toRun();
	void toStop();
};

// ---------------------------------------------------------------------------
#endif
