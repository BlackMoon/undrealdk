/** ����� ������. ������ ��� ���������, ������������ �� ������ ���� �� ��������� */
class Kamaz_CReport extends Actor dependson (Gorod_EventDispatcher,Gorod_BaseMessages) implements(Gorod_EventListener);

`include(Gorod\Gorod_Events.uci);

/** ������ �� ��������������� */
var Kamaz_PlayerController gorodPC;

var array<MessageInfo> MsgInfos;
/** ����, �� �������� �� ��������, ��� ���� ������ �������� ����� */
var bool gameStarted;
var Gorod_ReportEvent ReportEvent;

/** ���������� ������ �� ��������� ������ */
var int pointsCount;
/** ���������� ������� �� ��������� ������ */
var int moneyPenaltyCount;
/** ���������� ���������� */
var int exerciseCount;
/**������� ������������� ������. ����������� ������� ����� �������� �������,  ����� ������ ���������� � ��������� ��� ��������.*/
function Initialize(Kamaz_PlayerController objPC)
{
	gorodPC = objPC;
	`warn("gorodPC=none", gorodPC==none);
	if(gorodPC!=none)
	{
		gorodPC.EventDispatcher.RegisterListener(self,GOROD_EVENT_GAME);
		gorodPC.EventDispatcher.RegisterListener(self,GOROD_EVENT_HUD);

		ReportEvent = new class'Gorod_ReportEvent';
	}
}
/** ���������������. ������������ �� ��������� � �� */
function UnInitialize()
{
	if(gorodPC!=none)
	{
		ClearStats();
		gorodPC.EventDispatcher.RemoveListener(self);
		//pointsCount=
	}
}
/** ������� ����� */
function ClearStats()
{
	//������� ������ 
	MsgInfos.Remove(0,MsgInfos.Length);
	pointsCount = 0;
	moneyPenaltyCount = 0;
	exerciseCount=0;
	gameStarted = false;
}

/***/
function HandleEvent(Gorod_Event evt)
{
	local MessageInfo msgInfo;

	msgInfo = gorodPC.MessagesManager.getMessageContent(evt.messageID);

	CheckGameMsg(evt.messageID);
	//���������, ���������� ��������� � ������ ���������� ?
	if(CheckExerciseStartedMessage(evt.messageID))
		return;

	if(CheckMsg(msgInfo))
	{
		//���� ���� ��������
		if(gameStarted)
		{
			MsgInfos.AddItem(msgInfo);
			pointsCount+=msgInfo.Points;
			moneyPenaltyCount+=msgInfo.MoneyPenalty;
			
		}
	}
}

/** �������� ������� �������� ��������� �� ����� ����. ������ ���� gameStarted ������� ������ ��� �������������� ���������*/
function CheckGameMsg(int messageID)
{
	//��������� � ������ ����
	if(messageID ==GOROD_GAME_STARTED)
	{		
		gameStarted=true;
					
	}

	//��������� �� ��������� ����
	if(messageID == GOROD_MISSION_ENDED)
	{
		if(gameStarted)

			SendEvent();

		gameStarted=false;
	}
}

/**
 *  ������� ��������� ��������� � �������������� ����������� ����� */
function bool CheckMsg(MessageInfo msgInfo)
{
	//��������� ��?
  	if(msgInfo.Points!=0 || msgInfo.MoneyPenalty!=0 || msgInfo.type == MESSAGE_ERROR)
		return true;
	return false;
}

function bool CheckExerciseStartedMessage(int messageID)
{
	return false;
}
/** ������, �������� �� �����*/
function bool bIsEvalReportSuccess()
{
	if(pointsCount == 0 && moneyPenaltyCount ==0)
		return true;
	else 
		return false;
}

protected function prepareEvent()
{
	`log(pointsCount);
	ReportEvent.moneyPenaltyCount = moneyPenaltyCount;
	ReportEvent.pointsCount = pointsCount;
	ReportEvent.exerciseCount = exerciseCount;
	ReportEvent.MsgInfos = MsgInfos;
	ReportEvent.sender = self;
	ReportEvent.senderName = 'Gorod_Report';
	ReportEvent.eventType = GOROD_EVENT_QUEST;
	ReportEvent.bShowExcerisesCount = false;
	ReportEvent.bSuccess = bIsEvalReportSuccess();
}
/**
 *  �������� ��������� */
function SendEvent()
{
	prepareEvent();
	gorodPC.EventDispatcher.SendEvent(ReportEvent);
}
DefaultProperties
{
	exerciseCount = 0;
	pointsCount= 0;
	moneyPenaltyCount=0;
	gameStarted = false;
}
