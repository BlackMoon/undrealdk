#ifndef carH
#define carH
// ---------------------------------------------------------------------------
#include <gamemath.h>

#include "engine.h"
#include "wheels.h"
#include "gearbox.h"
// ---------------------------------------------------------------------------
// rho (��������� ����� p�) = ��������� ������� ��/�3
const float RHO = 1.29f;
const float kCrr = 30.0f;

// ---------------------------------------------------------------------------
typedef Vector3D Vector;

// ---------------------------------------------------------------------------
class TCar 
{
	private:
		volatile float _engineTorque;
		volatile float _baseTorque;
		volatile float _MotorTorque;
		volatile float _WheelsTorque;
		volatile unsigned short idx;

	protected:
		// ������ �������� ����������
		Vector fSpeed;
		// ������ ������� ����������
		Vector fU;
		// ������� (������������� ��� ������� ��� �� ������)
		float fBrake;
		// ������ ������ (������������� ��� ������� ��� �� ������)
		float fHandBrake;
		// ���� ��� ��������� �������
		bool run;

		float fDeltaWheelRpm;
	public:
		/**
		 * <link>aggregation</link>
		 */
		//TClutch *clutch;
		TGearbox gearbox;
		TEngine engine;
		TWheels<4> wheels;

		// ����������� ������ �� ������
		float FCd;
		// ������� �������� ����� ���������� �2
		float FS;
		// ����� ����������
		float mass;

		TCar();

		// ������� ���������
		void toRun();
		// ������ ���������
		void toStop();

		void progress(float dt = 0.1f);

		// ������ ������� ����������
		void setU(Vector3D const u);
		const Vector getU();

		// ������ �������� ����������
		void setSpeed(Vector3D const speed);
		const Vector getSpeed();

		// ���������� ���� �������� �������� �����
		// ang(-pi/4..+pi/4)
		void setSteerAngle(float ang);
		float getSteerAngle();

		// ������� �� ���
		// val(0..1)
		void setThrottle(float val);
		float getThrottle();

		// ������ �� ���������
		// val(0..1)
		void setClutch(float val);
		float getClutch();

		// �������� ��������
		// n(-1..6)
		void setGear(int n);
		int getGear();

		// ������ �� ������
		// val(0..1)
		void setBrake(float val);
		float getBrake();

		// ������ �� ������
		// val(0..1)
		void setHandBrake(float val);
		float getHandBrake();

		// ���������� ������� ���������
		// val(0..1)
		void setRPM(float rpm);
		float getRPM();

		void setDeltaWheelRpm(float value);
		float getDeltaWheelRpm();

		// �������� ���� "� �������� �������"
		float wheelRPM();
		float wheelRPM(float rpm);
		// �������� �������� ������ ������� �� ������� �� �������� ��������� � �����
		float baseTorque();
		float toMotorTorque(float baseTorque);
		float toWheelsTorque(float baseTorque);

		// ������������
		float Cdrag();
		float Crr();
		float Cbraking();

		const Vector Flong();
		const Vector Ftraction();
		const Vector Fdrag();
		const Vector Frr();
		const Vector Fbraking();
};

// ---------------------------------------------------------------------------
#endif /* #ifndef TCarH */
