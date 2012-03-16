class Kamaz_AutodromReport extends Kamaz_CReport;

/** �������� ������� �������� ��������� �� ����� ����. ������ ���� gameStarted ������� ������ ��� �������������� ���������*/
function CheckGameMsg(int messageID)
{
	//��������� � ������ ����
	if(messageID == GOROD_EVENT_DRIVE_IN)
	{
		gameStarted=true;		
	}

	//��������� � ������ � ���������
	if(messageID ==GOROD_EVENT_DRIVE_OUT|| messageID == GOROD_EVENT_TOO_FAR_FROM_PATH)
	{
		if(gameStarted)
			SendEvent();
		gameStarted=false;
	}
}
function bool CheckExerciseStartedMessage(int messageID)
{
	switch(messageID)
	{
		case GOROD_EVENT_EXERCISE2_FINISHED:		
		case GOROD_EVENT_EXERCISE6_FINISHED:		
		case GOROD_EVENT_EXERCISE7_FINISHED:
			exerciseCount++;
			break;
		default:
			return false;
	}
	return true;

}

protected function prepareEvent()
{
	super.prepareEvent();
	ReportEvent.bShowExcerisesCount = true;
}

function bool bIsEvalReportSuccess()
{
	if( pointsCount < 25 &&  exerciseCount == 3)
		return true;
	else 
		return false;
}

DefaultProperties
{
}
