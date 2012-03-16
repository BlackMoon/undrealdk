class Forsage_CarXDLL extends Actor
	DLLBind(ForsageCar);

struct CX_Matrix1
{
	var float m[16];
};

/** информация о состоянии машины */
struct CarParameters1
{
	var float Throttle;
	var float Clutch;
	var float Brake;
	// поворот руля [-1; 1]
	var float Steering;
	// угол поворота колёс
	var float SteerAngle;
	var int HandBrake;
	var int Gear;
	var int EngineStall;
	
	//var Vector GlobalAngularVelocity;
	var float GlobalAngularVelocity_X;
	var float GlobalAngularVelocity_Y;
	var float GlobalAngularVelocity_Z;
	//var Quat Quaternion;
	var float Quaternion_X;
	var float Quaternion_Y;
	var float Quaternion_Z;
	var float Quaternion_W;
	//var Vector Location;
	var float Location_X;
	var float Location_Y;
	var float Location_Z;
	//var Vector GlobalVelocity;	
	var float GlobalVelocity_X;
	var float GlobalVelocity_Y;
	var float GlobalVelocity_Z;

	var float COMOffset_X;
	var float COMOffset_Y;
	var float COMOffset_Z;
};

var bool bIgnition, bStarter, bEngineOn;

struct RayTraceInfo
{
	var Vector Target;
	var Vector N;
};
var RayTraceInfo rti;

struct TracePointsInfo
{
	var Vector Start, End;
};

struct CarXInfo
{
	 var float Accel;
	 var float Brake;
	 var float Clutch;
	 var float RPM;
	 var int Gear;
	 var float SpeedKmH;
	  
	 // координаты колёс
	var float F_L_WheelLoc_X;
	var float F_L_WheelLoc_Y;
	var float F_L_WheelLoc_Z;

	var float F_R_WheelLoc_X;
	var float F_R_WheelLoc_Y;
	var float F_R_WheelLoc_Z;

	var float R_L_WheelLoc_X;
	var float R_L_WheelLoc_Y;
	var float R_L_WheelLoc_Z;

	var float R_R_WheelLoc_X;
	var float R_R_WheelLoc_Y;
	var float R_R_WheelLoc_Z;

	// кватернионы колёс
	var float F_L_WheelQuat_X;
	var float F_L_WheelQuat_Y;
	var float F_L_WheelQuat_Z;
	var float F_L_WheelQuat_W;

	var float F_R_WheelQuat_X;
	var float F_R_WheelQuat_Y;
	var float F_R_WheelQuat_Z;
	var float F_R_WheelQuat_W;

	var float R_L_WheelQuat_X;
	var float R_L_WheelQuat_Y;
	var float R_L_WheelQuat_Z;
	var float R_L_WheelQuat_W;

	var float R_R_WheelQuat_X;
	var float R_R_WheelQuat_Y;
	var float R_R_WheelQuat_Z;
	var float R_R_WheelQuat_W;
};
var CarXInfo CarState;

struct InitInfo
{
	var float F_R_Wheel_X;
	var float F_R_Wheel_Y;
	var float F_R_Wheel_Z;

	var float F_L_Wheel_X;
	var float F_L_Wheel_Y;
	var float F_L_Wheel_Z;

	var float R_R_Wheel_X;
	var float R_R_Wheel_Y;
	var float R_R_Wheel_Z;

	var float R_L_Wheel_X;
	var float R_L_Wheel_Y;
	var float R_L_Wheel_Z;

	var float BoxMinLoc_X;
	var float BoxMinLoc_Y;
	var float BoxMinLoc_Z;

	var float BoxMaxLoc_X;
	var float BoxMaxLoc_Y;
	var float BoxMaxLoc_Z;
};
var InitInfo CarXInitInfo;

var CarParameters1 Car;
var Vector Fdt, MFdt;

//var Forsage_CarXVehicle OwnerVehicle;
var Forsage_PlayerCar OwnerVehicle;

dllimport final function Initialize(InitInfo Pos, out Vector COM);
dllimport final function Release();

/** Задание параметры машины */
dllimport final function SetCarParameters(CarParameters1 Params);

/** Получение точек для трейса */
dllimport final function GetTracePointsForWheel(int i, out Vector Start1, out Vector End1);

/** Задание результатов трейса */ 
dllimport final function SetTraceResults(int i, int res, RayTraceInfo rti1);

/** Обновление состояния машины */
dllimport final function Update(float dt);

/** Получение параметров машины */
dllimport final function GetTotals(out Vector Fdt1, out Vector MFdt1);

dllimport final function GetCarXInfo(out CarXInfo Info);

function InitCarX()
{
	local Vector COM;
	if (Role == ROLE_Authority)
	{
		Initialize(CarXInitInfo, COM);   //  инициализация CarX
		// задаём центр масс, рассчитанный в CarX
		OwnerVehicle.COMOffset = COM;
	}
}

simulated function OnDestroy(SeqAct_Destroy Action)
{
	if (Role == ROLE_Authority)
		Release();      //  финализация CarX
	super.OnDestroy(Action);
}

function CarUpdate(float dt)
{
	local int i;
	local Vector TraceStart, TraceEnd, HitLocation, HitNormal;
	local TraceHitInfo HitInfo;
	local int res;
	local Actor TraceActor;
	local bool TraceResult;

	SetCarParameters(Car);

	for(i = 0; i < 4; i++)
	{
		GetTracePointsForWheel(i, TraceStart, TraceEnd);

		TraceResult = true;
		foreach TraceActors(class'Actor', TraceActor, HitLocation, HitNormal, TraceEnd, TraceStart, vect(0, 0, 0), HitInfo, TRACEFLAG_Blocking)
		{
			if(TraceActor == OwnerVehicle)
				continue;

			//OwnerVehicle.WheelLocs[i] = HitLocation;
			TraceResult = false;
			break;
		}


		if(!TraceResult)
		{
			res = 0;
			rti.Target = HitLocation;
			rti.N = Normal(HitNormal);
		}
		else
		{
			res = 1;
		}

		SetTraceResults(i, res, rti);
	}

	Update(dt);

	Fdt = vect(0, 0, 0);
	MFdt = vect(0, 0, 0);
	GetTotals(Fdt, MFdt);

	GetCarXInfo(CarState);
}

DefaultProperties
{
	RemoteRole = Role_None
}
