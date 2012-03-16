#pragma once

#pragma comment(lib, "lib/carx.lib")

#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include "interface/CarX.h"

// параметры пришедшие из UDK
CX_RB_DESC RigidBody;

CX_Vector g;
ICXMaterial *g_pmat = NULL;
CX_Plane *plane = NULL;

// менеджер машин
ICXManager *CarManager = NULL;
// машина
ICXCar *Car = NULL;
// трассировщик лучей
//ForsageRayTracer *RayTracer;
//ICX_RayTracer *RayTracer;

CX_Vector COM_Meters;

CX_Inertia Inertia;

struct Quat
{
	float X, Y, Z, W;
};

struct CarParameters
{
	float Throttle;
	float Clutch;
	float Brake;
	// поворот рул€ [-1; 1]
	float Steering;
	// угол поворота колЄс
	float SteerAngle;
	int HandBrake;
	int Gear;
	int EngineStall;
	
	//CX_Vector GlobalAngularVelocity;
	float GlobalAngularVelocity_X;
	float GlobalAngularVelocity_Y;
	float GlobalAngularVelocity_Z;
	//Quat Quaternion;
	float Quaternion_X;
	float Quaternion_Y;
	float Quaternion_Z;
	float Quaternion_W;
	//CX_Vector Location;
	float Location_X;
	float Location_Y;
	float Location_Z;
	//CX_Vector GlobalVelocity;
	float GlobalVelocity_X;
	float GlobalVelocity_Y;
	float GlobalVelocity_Z;

	float COMOffset_X;
	float COMOffset_Y;
	float COMOffset_Z;
};

struct RayTraceInfo
{
	CX_Vector Target;
	CX_Vector N;
};

bool Hasray;

struct CarXInfo
{
	float Accel;
	float Brake;
	float Clutch;
	float RPM;
	int Gear;
	float SpeedKmH;
	
	// координаты колЄс
	float F_L_WheelLoc_X;
	float F_L_WheelLoc_Y;
	float F_L_WheelLoc_Z;

	float F_R_WheelLoc_X;
	float F_R_WheelLoc_Y;
	float F_R_WheelLoc_Z;

	float R_L_WheelLoc_X;
	float R_L_WheelLoc_Y;
	float R_L_WheelLoc_Z;

	float R_R_WheelLoc_X;
	float R_R_WheelLoc_Y;
	float R_R_WheelLoc_Z;

	// кватернионы колЄс
	float F_L_WheelQuat_X;
	float F_L_WheelQuat_Y;
	float F_L_WheelQuat_Z;
	float F_L_WheelQuat_W;

	float F_R_WheelQuat_X;
	float F_R_WheelQuat_Y;
	float F_R_WheelQuat_Z;
	float F_R_WheelQuat_W;

	float R_L_WheelQuat_X;
	float R_L_WheelQuat_Y;
	float R_L_WheelQuat_Z;
	float R_L_WheelQuat_W;

	float R_R_WheelQuat_X;
	float R_R_WheelQuat_Y;
	float R_R_WheelQuat_Z;
	float R_R_WheelQuat_W;
};

struct InitInfo
{
	float F_R_Wheel_X;
	float F_R_Wheel_Y;
	float F_R_Wheel_Z;

	float F_L_Wheel_X;
	float F_L_Wheel_Y;
	float F_L_Wheel_Z;

	float R_R_Wheel_X;
	float R_R_Wheel_Y;
	float R_R_Wheel_Z;

	float R_L_Wheel_X;
	float R_L_Wheel_Y;
	float R_L_Wheel_Z;

	float BoxMinLoc_X;
	float BoxMinLoc_Y;
	float BoxMinLoc_Z;

	float BoxMaxLoc_X;
	float BoxMaxLoc_Y;
	float BoxMaxLoc_Z;
};

extern "C"
{
	CX_Vector MetersToUnits(CX_Vector Val)
	{
		CX_Vector NewVal;
		NewVal.x = Val.x*50;
		NewVal.y = Val.y*50;
		NewVal.z = Val.z*50;

		return NewVal;
	}

	CX_Vector UnitsToMeters(CX_Vector Val)
	{
		CX_Vector NewVal;
		NewVal.x = Val.x/50;
		NewVal.y = Val.y/50;
		NewVal.z = Val.z/50;

		return NewVal;
	}

	__declspec(dllexport) void Initialize(InitInfo *CarXInitInfo, CX_Vector *COM)
	{
		CX_Vector right, front, top;		
		CX_Vector WheelLoc;
		
		// получаем менеджер машин
		//CarManager = pCXGetManager();
		CarManager = CXGetManager();
		
		// инициализируем менеджер машин
 		g.x = 0.0f;	
		g.y = 0.0f;	
		g.z = -10.0f;
		//g.z = 0.0f;
		CarManager->SetGravity(g);

		right.x = 0.0f;
		right.y = 1.0f;
		right.z = 0.0f;
  
		top.x = 0.0f;
		top.y = 0.0f;
		top.z = 1.0f;

		front.x = 1.0f;
		front.y = 0.0f;
		front.z = 0.0f;

		CarManager->SetCoordSys(right, front, top);
				
		// создаЄм материал-асфальт
		g_pmat =  CarManager->CreateMaterial();
		g_pmat->SetType(ICXMaterial::SURF_ASPHALT);

		// задаЄм параметры RigidBody, которые не будут измен€тьс€ при пересчЄте
		RigidBody.m_mass = 1050.f;
		
		// создаЄм ашину
		Car = CarManager->CreateCar();

		Car->SetFront(0, 1);
		Car->SetRear(2, 3);
		
		// инициализируем колЄса
		ICXWheel *w;	
		w = Car->GetWheel(0);
		w->Enable(true);
		w->SetRadius(0.3f);
		w->SetMass(10.0f);
		//w->SetLeftHanded(true);
		w->SetLeftHanded(false);

		WheelLoc.x = CarXInitInfo->F_L_Wheel_X;
		WheelLoc.y = CarXInitInfo->F_L_Wheel_Y;
		WheelLoc.z = CarXInitInfo->F_L_Wheel_Z;
		w->SetTopPos(UnitsToMeters(WheelLoc));

		w->SetMaxSpringLen(0.2f);
		w->SetSpringCoef(40000.f);
		w->SetSteerLimits(0.f, 0.f);
		w->SetAbsorbCoef(5000.f);
		w->SetCaster(4.f);
		//w->SetCamber(-2);
		//w->SetToeIn(0.);

		w->SetFrictionMultiplier(1.f);

		w = Car->GetWheel(1);
		w->Enable(true);
		w->SetRadius(0.3f);
		w->SetMass(10.f);
		w->SetLeftHanded(false);

		WheelLoc.x = CarXInitInfo->F_R_Wheel_X;
		WheelLoc.y = CarXInitInfo->F_R_Wheel_Y;
		WheelLoc.z = CarXInitInfo->F_R_Wheel_Z;
		w->SetTopPos(UnitsToMeters(WheelLoc));

		w->SetMaxSpringLen(0.2f);
		w->SetSpringCoef(40000.f);
		w->SetSteerLimits(0.f, 0.f);
		w->SetAbsorbCoef(5000.f);
		w->SetCaster(4.f);
		//w->SetCamber(-2);
		//w->SetToeIn(0.);
		w->SetFrictionMultiplier(1);

		w = Car->GetWheel(2);
		w->Enable(true);
		w->SetRadius(0.3f);
		w->SetMass(10.f);
		//w->SetLeftHanded(true);
		w->SetLeftHanded(false);

		WheelLoc.x = CarXInitInfo->R_L_Wheel_X;
		WheelLoc.y = CarXInitInfo->R_L_Wheel_Y;
		WheelLoc.z = CarXInitInfo->R_L_Wheel_Z;
		w->SetTopPos(UnitsToMeters(WheelLoc));
		
		w->SetMaxSpringLen(0.2f);
		w->SetSpringCoef(35000.f);
		w->SetSteerLimits(0.f, 0.f);
		w->SetAbsorbCoef(3000.f);
		//w->SetCamber(0);

		w->SetFrictionMultiplier(1.f);

		w = Car->GetWheel(3);
		w->Enable(true);
		w->SetRadius(0.3f);
		w->SetMass(10.f);
		w->SetLeftHanded(false);

		WheelLoc.x = CarXInitInfo->R_R_Wheel_X;
		WheelLoc.y = CarXInitInfo->R_R_Wheel_Y;
		WheelLoc.z = CarXInitInfo->R_R_Wheel_Z;
		w->SetTopPos(UnitsToMeters(WheelLoc));
		
		w->SetMaxSpringLen(0.2f);
		w->SetSpringCoef(35000.f);
		w->SetSteerLimits(0.f, 0.f);
		w->SetAbsorbCoef(3000.f);
		//w->SetCamber(0);
		w->SetFrictionMultiplier(1.f);

		// инициализируем машину
		Car->SetGearType(ICXCar::GEAR_FWD);
		//Car->SetGearType(ICXCar::GEAR_RWD);
		Car->SetFrontTyreType(ICXCar::TYRE_SPORT, 200.f, 50.f);
		Car->SetRearTyreType(ICXCar::TYRE_SPORT, 200.f, 50.f);
  
		Car->SetViscoDiffCoef(20.f);
		//	cxcar->SetAckerman(0.5);
	
		Car->SetFrontStabSpringCoef(10000.f);
		Car->SetRearStabSpringCoef(10000.f);

		Car->SetBrakeFrontBalance(0.55f);
		Car->SetBrakeTorque(2000.f);

		Car->SetEngineMaxTorque(145.f, 4000.f);
		
		Car->SetEngineIdleRPM(900.f);
		Car->SetEngineRevLimiter(6100.f);

		//Car->SetEngineTorqueCurveNumSamples(4);
		//Car->SetEngineTorqueCurveSample(0, 800, 93);
		//Car->SetEngineTorqueCurveSample(1, 3000, 135);
		//Car->SetEngineTorqueCurveSample(2, 4000, 145);
		//Car->SetEngineTorqueCurveSample(3, 6000, 115);
		//Car->SetEngineTorqueCurveFinalize();


		Car->SetABS(false);
		Car->SetGearShifting(ICXCar::SHIFT_MANUAL);

		Car->SetFinaldrive(3.7f);

		Car->SetGearBoxUpLimitRPM(4500.f);
		Car->SetGearBoxDownLimitRPM(3000.f);

		//rear
		Car->SetGearRatio(0, 3.5f);

		//1-6
		Car->SetGearRatio(1, 3.636f);
		Car->SetGearRatio(2, 1.95f);
		Car->SetGearRatio(3, 1.357f);
		Car->SetGearRatio(4, 0.941f);
		Car->SetGearRatio(5, 0.784f);
		Car->SetGearRatio(6, 0.6f);

		Car->SetNumGears(5);
		// cxcar->SetAeroFrontDownforce(10);
		// cxcar->SetAeroRearDownforce(10);

		//car.cxcar->SetSimModeSimple(true);
		Car->SetIntegrationSteps(50);

		Car->SetActive(true);

		CX_Vector BoxMinLoc, BoxMaxLoc;

		BoxMinLoc.x = CarXInitInfo->BoxMinLoc_X;
		BoxMinLoc.y = CarXInitInfo->BoxMinLoc_Y;
		BoxMinLoc.z = CarXInitInfo->BoxMinLoc_Z;

		BoxMaxLoc.x = CarXInitInfo->BoxMaxLoc_X;
		BoxMaxLoc.y = CarXInitInfo->BoxMaxLoc_Y;
		BoxMaxLoc.z = CarXInitInfo->BoxMaxLoc_Z;

		BoxMinLoc = UnitsToMeters(BoxMinLoc);
		BoxMaxLoc = UnitsToMeters(BoxMaxLoc);

		Car->CalcInertia(1050.f, BoxMaxLoc.y - BoxMinLoc.y, BoxMaxLoc.z - BoxMinLoc.z, BoxMaxLoc.x - BoxMinLoc.x, Inertia);

		CX_Vector LocalCenterMass;
		Car->CalcCenterMassLocalSpace(60, 50, 25, BoxMinLoc, BoxMaxLoc, COM_Meters);

		LocalCenterMass = MetersToUnits(COM_Meters);
		COM->x = LocalCenterMass.x;
		COM->y = LocalCenterMass.y;
		COM->z = LocalCenterMass.z;
		
		CarManager->AddCar(Car);
	}

	__declspec(dllexport) void Release()
	{
		//	освобождаем ICXCar
		Car->Release();
		Car = NULL;

		//	освобождаем материал
		g_pmat->Release();
		g_pmat = NULL;
	}

   __declspec(dllexport) void SetCarParameters(CarParameters *params)
   {
	   CX_Matrix Matr;
	   CX_Vector Location_Meters, GlobalVelocity_Meters, GlobalAngularVelocity, LocalCenterMass_Meters;
	   float x, y, z, w;

	   // получаем локальные координаты ценра масс в метрах
	   
	   LocalCenterMass_Meters.x = params->COMOffset_X;
	   LocalCenterMass_Meters.y = params->COMOffset_Y;
	   LocalCenterMass_Meters.z = params->COMOffset_Z;
	   LocalCenterMass_Meters = UnitsToMeters(LocalCenterMass_Meters);
	   
	   //LocalCenterMass_Meters = COM_Meters;
	   

	   // получаем Location в метрах
	   Location_Meters.x = params->Location_X;
	   Location_Meters.y = params->Location_Y;
	   Location_Meters.z = params->Location_Z;

	   Location_Meters = UnitsToMeters(Location_Meters);
	   	   
	   // получаем GlobalVelocity в метрах
	   GlobalVelocity_Meters.x = params->GlobalVelocity_X;
	   GlobalVelocity_Meters.y = params->GlobalVelocity_Y;
	   GlobalVelocity_Meters.z = params->GlobalVelocity_Z;

	   GlobalVelocity_Meters = UnitsToMeters(GlobalVelocity_Meters);

	   // получаем GlobalAngularVelocity
	   GlobalAngularVelocity.x = params->GlobalAngularVelocity_X;
	   GlobalAngularVelocity.y = params->GlobalAngularVelocity_Y;
	   GlobalAngularVelocity.z = params->GlobalAngularVelocity_Z;

	   // получаем составл€ющие кватерниона
	   x = params->Quaternion_X;
	   y = params->Quaternion_Y;
	   z = params->Quaternion_Z;
	   w = params->Quaternion_W;

	   // задаЄм параметры RigidBody
	   RigidBody.m_local_inertia = Inertia;
	   RigidBody.m_local_center_mass = LocalCenterMass_Meters;
	   RigidBody.m_global_angular_velocity = GlobalAngularVelocity;
	   RigidBody.m_global_velocity = GlobalVelocity_Meters;
	   RigidBody.m_mass = 1050.f;
	   
	   Matr.m[0] = 1 - 2*y*y - 2*z*z;	Matr.m[4] = 2*x*y - 2*z*w;		Matr.m[8] = 2*x*z + 2*y*w;		Matr.m[12] = Location_Meters.x;
	   Matr.m[1] = 2*x*y + 2*z*w;		Matr.m[5] = 1 - 2*x*x - 2*z*z;	Matr.m[9] = 2*y*z - 2*x*w;		Matr.m[13] = Location_Meters.y;
	   Matr.m[2] = 2*x*z - 2*y*w;		Matr.m[6] = 2*y*z + 2*x*w;		Matr.m[10] = 1 - 2*x*x - 2*y*y;	Matr.m[14] = Location_Meters.z;
	   Matr.m[3] = 0;					Matr.m[7] = 0;					Matr.m[11] = 0;					Matr.m[15] = 1;

	   /*
	   Matr.m[0] = 1 - 2*y*y - 2*z*z;	Matr.m[4] = 2*x*y + 2*z*w;		Matr.m[8] = 2*x*z - 2*y*w;		Matr.m[12] = Location_Meters.x;
	   Matr.m[1] = 2*x*y - 2*z*w;		Matr.m[5] = 1 - 2*x*x - 2*z*z;	Matr.m[9] = 2*y*z + 2*x*w;		Matr.m[13] = Location_Meters.y;
	   Matr.m[2] = 2*x*z + 2*y*w;		Matr.m[6] = 2*y*z - 2*x*w;		Matr.m[10] = 1 - 2*x*x - 2*y*y;	Matr.m[14] = Location_Meters.z;
	   Matr.m[3] = 0;					Matr.m[7] = 0;					Matr.m[11] = 0;					Matr.m[15] = 1;
	   */
	   /*
	   Matr.m[0] = 1;	Matr.m[4] = 0;	Matr.m[8] = 0;		Matr.m[12] = Location_Meters.x;
	   Matr.m[1] = 0;	Matr.m[5] = 1;	Matr.m[9] = 0;		Matr.m[13] = Location_Meters.y;
	   Matr.m[2] = 0;	Matr.m[6] = 0;	Matr.m[10] = 1;		Matr.m[14] = Location_Meters.z;
	   Matr.m[3] = 0;	Matr.m[7] = 0;	Matr.m[11] = 0;		Matr.m[15] = 1;
	   */

	   // задаЄм матрицу, определ€ющую положение машины
	   RigidBody.m_global_position = Matr;


	   Car->SetAccel(params->Throttle < 0 ? 0 : params->Throttle);
	   //Car->SetClutch(params->Clutch);
	   Car->SetBrake(params->Brake);
	   Car->SetSteerAngle(params->SteerAngle);
	   Car->SetHandBrake(params->HandBrake == 1 ? 1.f : 0.f);
	   Car->SetGear(params->Gear);

	   Car->SetRigidBody(RigidBody);
   }

   CX_Vector pStartVectors[4];
   CX_Vector pEndVectors[4];

   __declspec(dllexport) void GetTracePointsForWheel(int i, CX_Vector *Start, CX_Vector *End)
   {
		ICXWheel *w = Car->GetWheel(i);
		Hasray = false;
		if(w != NULL)
		{
			Hasray = w->GetRayTracePoints(pStartVectors[i], pEndVectors[i]);
			*Start = MetersToUnits(pStartVectors[i]);
			*End = MetersToUnits(pEndVectors[i]);
		}
   }
   
   CX_RayTraceInfo Info[4];

   __declspec(dllexport) void SetTraceResults(int i, int res, RayTraceInfo *rti)
   {
	   if(Hasray)
	   {
		   ICXWheel *w = Car->GetWheel(i);
		   if(w != NULL)
		   {
			   Info[i].target = UnitsToMeters(rti->Target);
			   Info[i].mat = g_pmat;
			   Info[i].n = rti->N;
			   Info[i].prbh = 0;
			   Info[i].userdata = 0;
			   w->SetRayTraceRes(res == 0 ? false : true, Info[i]);
			   //w->SetRayTraceRes(true, Info[i]);
		   }
		   Hasray = false;
	   }
   }

   __declspec(dllexport) void Update(float dt)
   {
	   CarManager->Update(dt);
   }

   __declspec(dllexport) void GetTotals(CX_Vector *Fdt, CX_Vector *MFdt)
   {
	   CX_Vector Fdt1, MFdt1;
	   Car->GetVelocity(Fdt1);
	   Car->GetAngularVelocity(MFdt1);
	   //Car->GetTotals(Fdt1, MFdt1);
	   *Fdt = MetersToUnits(Fdt1);
	   *MFdt = MFdt1;
   }



   __declspec(dllexport) void GetCarXInfo(CarXInfo *CarInfo)
   {  
	   ICXWheel *w;
	   CX_Vector Loc;
	   CX_Quaternion Quat;
	   
	   CarInfo->Accel = Car->GetAccel();
	   CarInfo->Brake = Car->GetBrake();
	   CarInfo->Clutch = Car->GetClutch();
	   CarInfo->RPM = Car->GetRPM();
	   CarInfo->Gear = Car->GetGear();
	   CarInfo->SpeedKmH = Car->GetSpeedKMH();
	   
	   	   
	   w = Car->GetWheel(0);
	   if(w != NULL)
	   {
		   w->GetQuaternionAndPos(Quat, Loc);
		   Loc = MetersToUnits(Loc);
		   
		   CarInfo->F_L_WheelLoc_X = Loc.x;
		   CarInfo->F_L_WheelLoc_Y = Loc.y;
		   CarInfo->F_L_WheelLoc_Z = Loc.z;

		   CarInfo->F_L_WheelQuat_X = Quat.x;
		   CarInfo->F_L_WheelQuat_Y = Quat.y;
		   CarInfo->F_L_WheelQuat_Z = Quat.z;
		   CarInfo->F_L_WheelQuat_W = Quat.w;
	   }

	   w = Car->GetWheel(1);
	   if(w != NULL)
	   {
		   w->GetQuaternionAndPos(Quat, Loc);
		   Loc = MetersToUnits(Loc);
		   
		   CarInfo->F_R_WheelLoc_X = Loc.x;
		   CarInfo->F_R_WheelLoc_Y = Loc.y;
		   CarInfo->F_R_WheelLoc_Z = Loc.z;

		   CarInfo->F_R_WheelQuat_X = Quat.x;
		   CarInfo->F_R_WheelQuat_Y = Quat.y;
		   CarInfo->F_R_WheelQuat_Z = Quat.z;
		   CarInfo->F_R_WheelQuat_W = Quat.w;
	   }

	   w = Car->GetWheel(2);
	   if(w != NULL)
	   {
		   w->GetQuaternionAndPos(Quat, Loc);
		   Loc = MetersToUnits(Loc);
		   
		   CarInfo->R_L_WheelLoc_X = Loc.x;
		   CarInfo->R_L_WheelLoc_Y = Loc.y;
		   CarInfo->R_L_WheelLoc_Z = Loc.z;

		   CarInfo->R_L_WheelQuat_X = Quat.x;
		   CarInfo->R_L_WheelQuat_Y = Quat.y;
		   CarInfo->R_L_WheelQuat_Z = Quat.z;
		   CarInfo->R_L_WheelQuat_W = Quat.w;
	   }

	   w = Car->GetWheel(3);
	   if(w != NULL)
	   {
		   w->GetQuaternionAndPos(Quat, Loc);
		   Loc = MetersToUnits(Loc);
		   
		   CarInfo->R_R_WheelLoc_X = Loc.x;
		   CarInfo->R_R_WheelLoc_Y = Loc.y;
		   CarInfo->R_R_WheelLoc_Z = Loc.z;

		   CarInfo->R_R_WheelQuat_X = Quat.x;
		   CarInfo->R_R_WheelQuat_Y = Quat.y;
		   CarInfo->R_R_WheelQuat_Z = Quat.z;
		   CarInfo->R_R_WheelQuat_W = Quat.w;
	   }
   }
}