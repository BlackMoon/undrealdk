/**
 * ���������� �� �������� ���� � ����������. ���������� ��������� ���� 5 ��� ������ � 5 ��� ����� ����� ��������� �������� ����������� ����
 */
class Kamaz_Exercise_Steer234 extends Kamaz_Exercise_Base;

/**
 * �������� �������, ���������������� �������� �������/�������� ������ ��������� ����
 */
var float SteerValueRight, SteerValueLeft;

/**
 * �����������, � ������� ������� ������� ���� � ������ ������
 */
var bool isRightTurn;

/**
 * ���� ������� �������
 */
var bool bIsFirstTime;

function Start()
{
	super.Start();

	ResetCounter();
	SteerValueRight = -1;
	SteerValueLeft = 1;
	isRightTurn = true;
	bIsFirstTime = true;
}

function UpdateSignals(ControlSignalsInfo ControlsInfo)
{
	if(bIsFirstTime)
	{
		ParentGFx.StartAnim(0);
		bIsFirstTime = false;
	}

	if(counter >= RepetitionCount)
	{
		// ���������� ��������
		Finish();
		return;
	}

	if(isRightTurn)
	{
		if(ControlsInfo.Steering == SteerValueRight)
		{
			// �������� ������ �����
			ParentGFx.StartAnim(1);
			isRightTurn = false;
			IncCounter();
		}
	}
	else
	{	
		if(ControlsInfo.Steering == SteerValueLeft)
		{
			// �������� ������ ������
			ParentGFx.StartAnim(0);
			isRightTurn = true;
			IncCounter();
		}
	}
}

DefaultProperties
{
}
