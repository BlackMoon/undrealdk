class Kamaz_Exercise_Pedal2 extends Kamaz_Exercise_Base;

/**
 * � ������ ���������� ���, ���� �� ����� ������ ���������,
 * � ����� �������� ������� �� ����������� �������
 */
var bool bWaitForClutch;

/**
 * �����������, ������������ ��� �������� ������� �� ������
 */
var float Delta;

/**
 * true - ���� ��������� ������� �� ���, false - ���� ��������� ������� �� ���������
 */
var bool bWaitForThrottle;

function Start()
{
	super.Start();

	ResetCounter();
	bWaitForClutch = true;
	bWaitForThrottle = true;
	Delta = 0.2;
}

function UpdateSignals(ControlSignalsInfo ControlsInfo)
{
	if(counter >= RepetitionCount)
	{
		Finish();
		return;
	}
	
	if(bWaitForClutch)
	{
		if(ControlsInfo.Clutch >= 0.9)
			bWaitForClutch = false;
		return;
	}
	
	
	if(ControlsInfo.Throttle > (1 - ControlsInfo.Clutch + Delta) || ControlsInfo.Throttle < (1 - ControlsInfo.Clutch - Delta))
	{
		bWaitForClutch = true;
		return;
	}

	// ���� ������� ������� �� ��� � ��� �����
	if(bWaitForThrottle && ControlsInfo.Throttle >= 0.9)
	{
		// ����������� ����� �������� �  ��� ������� �� ���������
		IncCounter();
		bWaitForThrottle = false;
	}
	else
	{
		// ���� ��� ������� �� ��������� � ��������� ������
		if(ControlsInfo.Clutch >= 0.9)
		{
			// �������� ����� ������� �� ���
			bWaitForThrottle = true;
		}
	}
}

DefaultProperties
{
}
