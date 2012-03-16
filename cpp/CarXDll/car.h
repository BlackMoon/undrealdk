#ifndef carH
#define carH
// ---------------------------------------------------------------------------
#include <gamemath.h>

#include "engine.h"
#include "wheels.h"
#include "gearbox.h"
// ---------------------------------------------------------------------------
// rho (греческая буква pо) = плотность воздуха кг/м3
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
		// Вектор скорости автомобиля
		Vector fSpeed;
		// Вектор нормали автомобиля
		Vector fU;
		// Тормоза (используеться для расчета сил на машину)
		float fBrake;
		// Ручной тормоз (используеться для расчета сил на машину)
		float fHandBrake;
		// Флаг что двигатель запущен
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

		// коэффициент трения об воздух
		float FCd;
		// Площадь передней части автомобиля м2
		float FS;
		// Масса автомобиля
		float mass;

		TCar();

		// Заводим двигатель
		void toRun();
		// Глушим двигатель
		void toStop();

		void progress(float dt = 0.1f);

		// Вектор нормали автомобиля
		void setU(Vector3D const u);
		const Vector getU();

		// Вектор скорости автомобиля
		void setSpeed(Vector3D const speed);
		const Vector getSpeed();

		// установить угол поворота передних колес
		// ang(-pi/4..+pi/4)
		void setSteerAngle(float ang);
		float getSteerAngle();

		// нажатие на наз
		// val(0..1)
		void setThrottle(float val);
		float getThrottle();

		// нажате на сцепление
		// val(0..1)
		void setClutch(float val);
		float getClutch();

		// включить скорость
		// n(-1..6)
		void setGear(int n);
		int getGear();

		// нажате на тормоз
		// val(0..1)
		void setBrake(float val);
		float getBrake();

		// нажате на ручник
		// val(0..1)
		void setHandBrake(float val);
		float getHandBrake();

		// установить обороты двигателя
		// val(0..1)
		void setRPM(float rpm);
		float getRPM();

		void setDeltaWheelRpm(float value);
		float getDeltaWheelRpm();

		// вращение колёс "в моторном расчёте"
		float wheelRPM();
		float wheelRPM(float rpm);
		// Обратный крутящий момент основан на разнице во вращении двигателя и колес
		float baseTorque();
		float toMotorTorque(float baseTorque);
		float toWheelsTorque(float baseTorque);

		// Аэродинамика
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
