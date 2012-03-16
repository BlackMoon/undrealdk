/** ����� GearBox ������������� ������ ������ ������� ������� */

class GearBox extends Object abstract;

enum GearTypes
{
	GEAR_Neutral,
	GEAR_Speed,
	GEAR_Reverse
};

struct Gear
{
	var GearTypes gearType;
	var float gearMaxSpeed;
	var float gearTorque;
	var InterpCurveFloat gearTorqueVSpeedCurve;        // ������ ��������� �������� � ��������� �������
	var InterpCurveFloat gearEngineRPMCurve;           // ������ ��������� �������� � �������� ���������
};
	
var int numOfGears;                // ���������� �������
var int currentGear;               // ������� ��������

DefaultProperties
{
	numOfGears = 0;
}
