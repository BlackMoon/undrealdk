/** ��������������� actor, �������� ��� ������ ������� ���������� �������� � ������ ���� */
class TimerHelper extends Actor;

var bool bRunning;
delegate dlgTimerFunc();

function DoFunc(bool value)
{
	bRunning = value;		
}

simulated event Tick(float DeltaTime)
{
	if (bRunning)  
		dlgTimerFunc();	
}

DefaultProperties
{	
}
