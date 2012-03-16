/**
 * ���������� �� �������� ���� ��� ������ ���. ���������� ��������� ���� 5 ��� ������ � ����� ����� ��������� �������� ����������� ����
 */
class Kamaz_Exercise_Steer1 extends Kamaz_Exercise_Base;

/**
 * �������� �������, ���������������� �������� �������/�������� ������ ��������� ����
 */
var float SteerValueRight, SteerValueLeft, SteerDelta;

/**
 * �����������, � ������� ������� ������� ���� � ������ ������
 */
var bool isRightTurn;
/**
 * ���� ��� ��������� ��������
 */
var bool bWaiting;

function Start()
{
	super.Start();

	ResetCounter();
	SteerValueRight = -90;
	SteerValueLeft = 90;
	isRightTurn = false;
	SteerDelta = 10;
	bWaiting = true;

	ParentGFx.StartAnim(0);
}

function UpdateSignals(ControlSignalsInfo ControlsInfo)
{
	if(bWaiting)
	{
		// ��� ������� �� ������� ���������� (���� ��� ������ ����), ����� ������� � �������� ����
		if(ControlsInfo.Throttle > 0.5)
		{
			bWaiting = false;
			ParentGFx.StartAnim(1);
		}
		
		return;
	}

	if(counter >= RepetitionCount)
	{
		// ���������� ��������
		Finish();
		return;
	}

	if(isRightTurn)
	{
		if(GetDegreesBySteering(ControlsInfo.Steering) <= SteerValueRight)
		{
			// �������� ������ �����
			ParentGFx.StartAnim(1);
			isRightTurn = false;
			IncCounter();
		}
	}
	else
	{	
		if(GetDegreesBySteering(ControlsInfo.Steering) >= SteerValueLeft)
		{
			// �������� ������ ������
			ParentGFx.StartAnim(2);
			isRightTurn = true;
			IncCounter();
		}
	}
}

DefaultProperties
{
}
