class CarX extends Actor DLLBind(CarXDll);

/** �������� */
enum CarX_Gear 
{
	GEAR_BACK,      // ������
	GEAR_NEUTRAL,   // ��������
	GEAR_FIRST,
	GEAR_SECOND,
	GEAR_THIRD,
	GEAR_FOURTH,
	GEAR_FIFTH,
	GEAR_NUM        //  ��������� �� C++ ������� �� �������� � ���
};

/** ��� ������� type(fwd,rwd,4wd)*/
enum CarX_GearType 
{
	TYPE_FWD, // ��������
	TYPE_RWD, // ������
	TYPE_4WD, // ������
	// � ����� ����������
	TYPE_NUM
};

/** ��� �������� �����������, ���������� ��� ���������� */
enum CarX_TransferGear 
{
	TRANSFER_LOW, // ����������
	TRANSFER_HIGH, // ����������
	// � ����� ����������
	TRANSFER_NUM
};

/** ��� ������� type(auto,manual)*/
enum CarX_GearShiftType 
{
	SHIFT_AUTO, // �������-�������
	SHIFT_MANUAL, // ������ ��� �������
	// � ����� ����������
	SHIFT_NUM
};

/** ��������� ��� ����� */
struct TWheelX 
{
	var float rpm;              // ������� ������ � ������
	var float brakeTorque;      // ��������� �������� ������ 
	var float chassisTorque;    // �������� ������ �� ����� ������ �� ������ 
	var float torque;	        // �������� ������ ������������� �� ��������� � ������
};

/** ��������� ���������� ��������� ������ ��� ������ � Dll */
struct TCarX 
{
	var Vector u;	                    //  ������ ������� ������
	var float rpm;                      //  ���-�� �������� ��������� � ������

	// IN - ������� ���������
	var int ignition;                   //  ��������� ��������/���������� 1..0
	var int starter;                    //  �������� ������� 1..0
	var float brake;                    //  ������� �� ��� ������ �������� ��������� �������
	var float clutch;		            //  �������� ��� ��������� �� 1..0
	var float handBrake;                //  ������ ������, �������� ������ �� ������ ������
	var int gear;                       //  ������� ��������
	var float throttle;	                //  �������� ��� �������� ������� 0..1

	// OUT - �������� ���������	
	var vector Flong;                   //  �������������� ���� �������� �� ������
	var Vector speed;                   //  ��������� �������� ������
	var Vector a;                       //  ��������� ��������� ������

	// gearbox 
	var int gearType;                   //  ��� ������� ��������: ��������, ������ ��� ������ ������
	var int transfer;                   //  ��������: ���������� ��� ����������

	/** ��������� ������������ */
	var int diff_axle;
	/** ����������� ������������ 1 */
	var int diff_wheels1;
	/** ����������� ������������ 2 */
	var int diff_wheels2;
	// Wheel
	var int countWheel;                 //  ���-�� ����� 2,4,6
	var array <TWheelX> wheels;         //  ������ �����
};

/** ���-�� UU � ����� */
const UU2M=50;
/** ��������� - ���-�� ����� � ������ */
const COUNT_WHEEL = 4;
/** ������ */
var TCarX car; 
var int iTickIdx;

//C++ __declspec(dllexport) int progress(TCarX* fCar);							 
/** �������� ������� ��� ������ CarX.Dll 
 *  fCar - In|Out ��������� ����������  ������ 
 *  DeltaSeconds - ����� ������� ������ ����� �������� ���� */
dllimport final function int progressX(out TCarX fCar, float DeltaSeconds);


function STick (FLOAT DeltaSeconds) 
{
	// ������� ���������� ��������
	if (VSize (car.speed) < 10)
	{
		car.speed.X = 0.f;
		car.speed.Y = 0.f;
		car.speed.Z = 0.f;
	}
	else
	{
		/* ����������� UU � �����, ��� �������� �������� � ���� */
		car.speed /= UU2M;
		//car.Flong /= UU2M;
	}

	/* ��������� DLL, �� ������ �������� ����� �������� */
	progressX(car, DeltaSeconds);	

	/* ����������� �� ������ � UU */
	//car.speed *= UU2M;
	//car.Flong *= UU2M;
	//car.a *= UU2M;

	/* ��������� ��� �������� ������� �� ������, ������ �������� ���� ������ */
	for (iTickIdx = 0; iTickIdx < COUNT_WHEEL; iTickIdx++) 
	{
		if (car.rpm > 300.f)
		{
			car.wheels[iTickIdx].torque = car.wheels[iTickIdx].torque * 0.25f;
			car.wheels[iTickIdx].brakeTorque = 1.f;
		}
		else 
		{
			car.wheels[iTickIdx].brakeTorque = 3.f + Abs(car.wheels[iTickIdx].torque) * car.clutch;
			car.wheels[iTickIdx].torque = 0.f;
		}
	}
}

event PostBeginPlay()
{
	local TWheelX wheel;

	`Entry();
	super.PostBeginPlay();

	car.u.X = 1;
	car.u.Y = 0;
	car.u.Z = 0;
	
	car.speed.X = 0;
	car.speed.Y = 0;
	car.speed.Z = 0;

	car.Flong.X = 0;
	car.Flong.Y = 0;
	car.Flong.Z = 0;

	car.a.X = 0;
	car.a.Y = 0;
	car.a.Z = 0;

	car.ignition = 0;
	car.starter = 0;
	car.brake = 0;
	car.handBrake = 1;

	car.gear = GEAR_NEUTRAL;
	car.gearType = TYPE_FWD;
	car.transfer = TRANSFER_HIGH;
	car.diff_axle = 0;
	car.diff_wheels1 = 0;
	car.diff_wheels2 = 0;

	car.clutch = 0.0;
	car.rpm = 0.0;
	car.throttle = 0.3;
	
	car.countWheel = COUNT_WHEEL;
	car.wheels.Add(COUNT_WHEEL);
	foreach car.wheels (wheel) 
	{
		wheel.rpm = 0;
		wheel.torque = 0;
		wheel.brakeTorque = 0;
		wheel.chassisTorque = 0;
	}
	`Exit();
}

DefaultProperties
{

}