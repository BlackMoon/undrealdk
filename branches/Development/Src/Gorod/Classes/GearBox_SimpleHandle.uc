/**
 * GearBox_SimpleHandle - ����� ������ ������� ������� �������� ����
 */

class GearBox_SimpleHandle extends GearBox;

var array<Gear> speedGears;                     // ������ ��� �������� ���������� �������
var float reverseSpeed;                         // ������������ �������� ��� �������� �����
var float reverseTorque;                        // �������� ������ ��� �������� �����


/** AddSpeedGear - ��������� ���������� �������� 
 *  maxSpeed -  ������������ ��������, ������� ����� ���� ���������� �� ���� ��������
 *  torque -    �������� ������
 *  maxRPM   -  ������� ��������� ��� ���������� ������������ �������� ������� ��������
 */
function AddSpeedGear(float maxSpeed, float torque, float maxRPM)
{
	local Gear gr;
	local InterpCurvePointFloat pt;

	pt.InterpMode = CIM_CurveAuto;

	gr.gearType = GEAR_Speed;
	gr.gearMaxSpeed = maxSpeed;
	gr.gearTorque = torque;

	/** ��������� ������ ��������\����.������� */
	// ��������� �������� ��� �������� �����
	pt.InVal = reverseSpeed - 1;
	pt.OutVal = 0;
	gr.gearTorqueVSpeedCurve.Points.AddItem(pt);

	pt.InVal = reverseSpeed;
	pt.OutVal = reverseTorque;
	gr.gearTorqueVSpeedCurve.Points.AddItem(pt);

	// �������� ��� ��������� �������
	pt.InVal = 0;
	pt.OutVal = torque;
	gr.gearTorqueVSpeedCurve.Points.AddItem(pt);

	// �������� ��������
	pt.InVal = maxSpeed - 1;
	pt.OutVal = torque;
	gr.gearTorqueVSpeedCurve.Points.AddItem(pt);

	// ����������� ��������
	pt.InVal = maxSpeed;
	pt.OutVal = 0;
	gr.gearTorqueVSpeedCurve.Points.AddItem(pt);

	// ������������� ���� ������ ��� ��������, ����� ������� ��� ������������
	pt.InVal = maxSpeed + 1;
	pt.OutVal = -10;
	gr.gearTorqueVSpeedCurve.Points.AddItem(pt);


	/** ��������� ������ ��������/�������� ��������� */
	// ��� �������� �����
	pt.InVal = reverseSpeed;
	pt.OutVal = reverseTorque;
	gr.gearEngineRPMCurve.Points.AddItem(pt);

	// ������� ��� ���������� ��������
	pt.InVal = 0.0;
	pt.OutVal = 200.0;
	gr.gearEngineRPMCurve.Points.AddItem(pt);

	// ��� ������ ��������
	pt.InVal = maxSpeed;
	pt.OutVal = maxRPM;
	gr.gearEngineRPMCurve.Points.AddItem(pt);
	
	speedGears.AddItem(gr);

	numOfGears = speedGears.Length;
}

/** ����������� ������� �������� �� ������� */
function NextGear()
{
	if(currentGear < numOfGears - 1)
		currentGear++;
}

/** ����������� ������� �������� �� ������ */
function PreviousGear()
{
	if(currentGear > 0)
		currentGear--;
}

/** ���������� ������� �������� */
function Gear GetCurrentGear()
{
	if(speedGears.Length > 0)
		return speedGears[currentGear];
}

DefaultProperties
{
	currentGear = 0;
	reverseSpeed = -300.0;
	reverseTorque = 70.0;
}
