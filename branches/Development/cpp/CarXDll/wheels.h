#ifndef WheelsH
#define WheelsH

//-----------------------------------------------------------------------------
#ifndef M_PI
#define M_PI       3.14159265358979323846
#endif

//-----------------------------------------------------------------------------
struct TWheel 
{
	float rpm;
	float torque;
};

//-----------------------------------------------------------------------------
template <unsigned short iWheelsNum> class TWheels 
{
	protected:
		float FClutchTorque; 
		float FTorque; 
		float FBrakeTorque; 
	public:
		float rpm()
		{
			return (wheels[0].rpm + wheels[1].rpm ) * 0.5f;
		}

		float R;
		float CR;

		float inertia;

		TWheels()
		{
			// R = 0.575f;
			// R = 0,8571428571428571
			R = 0.63f;

			CR = float(M_PI*R);
			inertia = 20.0f * (pow(R, 2)+ pow(13*0.0254f, 2));
			//inertia = 6;
			FClutchTorque = 0;
		}

		void progress(float speed, float dt)
		{
			//	При чем тут может быть версия компилятора? Этот участок кода вообще кроссплатформенный.
			#ifndef _MSC_VER
			float rpm = speed * 60 / CR;
			for (int i = 0;  i < 4 ; i++) 
				wheels[i].rpm = rpm;
			#endif
		}

		void setClutchTorque(float torque)
		{
			if (fabs (FTorque) > fabs (torque))
				FClutchTorque = torque;
			else 
				FClutchTorque = 0.f;
		}

		float getClutchTorque()
		{
			return FClutchTorque;
		}

		void setTorque (float torque)
		{
			if (fabs(torque) > 6000.f )
				torque = torque/fabs(torque) * 5600.f;
			FTorque = torque;
		}

		float getTorque()
		{
			return FTorque;
		}

		TWheel wheels[iWheelsNum];
		const static unsigned short WheelsNum = iWheelsNum;
};


//-----------------------------------------------------------------------------
#endif /* #ifndef WheelsH */
