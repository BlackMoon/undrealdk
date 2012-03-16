/** ����� ����������� ���. �������� ��������� �� ����������� ������, ����������� ���������� ������, ����� �� ��������� (�������� � ������)  */
class Gorod_PDDController extends Actor dependson (Gorod_EventDispatcher,Gorod_BaseMessages) implements(Gorod_EventListener);

										/**������ �� Gorod_PlayerController*/
var Common_PlayerController PC;
										/***/
var Gorod_PDDMessages PDDMessage;
										/***/
var bool bHasRegisteredInMessagesManager;
										/**���������� ���������� ���������*/
`include(Gorod_Events.uci);

/**������� ������������� ������� ������*/
function Initeliaze(Common_PlayerController myPC)
{
	PC = myPC;
	if(PC == none)
	{
		`warn("GetALocalPlayerController() = none", PC == none);
		return;
	}
	PC.EventDispatcher.RegisterListener(self,GOROD_EVENT_PDD); // ������������� �� ������� ���� GOROD_EVENT_PDD
	bHasRegisteredInMessagesManager=false;
	RegisterInMessagesManager();
}



/***/
function RegisterInMessagesManager()
{
	if(PC.MessagesManager != none)
	{
		PC.MessagesManager.Register(PDDMessage);
		bHasRegisteredInMessagesManager = true;
	}
	else
	{
		SetTimer(1, false, 'RegisterInMessagesManager');
	}
}

/**������� ���������� ������� �� ������� �������� ������ ������, ������ ������� ���������������� ����������� Gorod_EventListener, ������������ �� ������� ���������� � function Initeliaze(Gorod_PlayerController myPC) ������� ������.*/
function HandleEvent(Gorod_Event evnt)
{	
	switch (evnt.messageID)
	{
	case GOROD_PDD_OUT_OF_SPEED_MAX_LIMIT_RESULT:   //������������ ����� �������� ����� ������������� ���������� ����������� � ��� ���������
		if(Gorod_Event_PDD(evnt).ParametrInt2<20 )
			SendHUDMessages(GOROD_PDD_OUT_OF_SPEED_MAX_LIMIT_RESULT_10_20);
		else if(Gorod_Event_PDD(evnt).ParametrInt2>=20 && Gorod_Event_PDD(evnt).ParametrInt2<40)
			SendHUDMessages(GOROD_PDD_OUT_OF_SPEED_MAX_LIMIT_RESULT_20_40);
		else if(Gorod_Event_PDD(evnt).ParametrInt2>=40 && Gorod_Event_PDD(evnt).ParametrInt2<60)
			SendHUDMessages(GOROD_PDD_OUT_OF_SPEED_MAX_LIMIT_RESULT_40_60);
		else if(Gorod_Event_PDD(evnt).ParametrInt2>=60)
			SendHUDMessages(GOROD_PDD_OUT_OF_SPEED_MAX_LIMIT_RESULT_60);
		break;
	case GOROD_PDD_OUT_OF_SPEED_MIN_LIMIT_RESULT:    // ������������ ����� �������� ����� ������������ ���������� ����������� � ��� ���������
			SendHUDMessages(GOROD_PDD_OUT_OF_SPEED_MIN_LIMIT_RESULT);
		break;
	case GOROD_PDD_VIOLATION_BRICK:                 // ������������ ������ ��� ���� ������
		SendHUDMessages(GOROD_PDD_VIOLATION_BRICK);
		break;
	case GOROD_PDD_CROSSROAD_ENTER:                 // ������������� ����� � �����������, ������ ���� �����������
		SendZnakSpeedEvent(GOROD_ZNAK_END_ALL_LIMIT);
		break;
	case GOROD_PDD_VIOLATION_STOP:                  // ������������� ��������� ����� STOP
		SendHUDMessages(GOROD_PDD_VIOLATION_STOP);
		break;
	case GOROD_PDD_SIRENA_SIGNAL_ENABLED: // ������������� ��������� ������� ������
		SendZnakEvent(GOROD_PDD_SIRENA_SIGNAL_ENABLED);
		SendZnakSpeedEvent(GOROD_PDD_SIRENA_SIGNAL_ENABLED);
		break;
	case GOROD_PDD_SIRENA_SIGNAL_DISABLED:           // ������������� ���������� ������� ������
		SendZnakEvent(GOROD_PDD_SIRENA_SIGNAL_DISABLED);
		SendZnakSpeedEvent(GOROD_PDD_SIRENA_SIGNAL_DISABLED);
		break;
	}
}

/** ������� ��� ��������� ������ Gorod_Event ���� SendHUDMessages */
function SendHUDMessages(int MsgId)
{
	local Gorod_Event ev;
	if(PC != none)
	{
		ev = new class'Gorod_Event';
		ev.sender = self;
		ev.messageID = MsgId;
		ev.eventType=GOROD_EVENT_HUD;
		PC.EventDispatcher.SendEvent(ev);
	}
	return;
}

/** ������� ��� ��������� ������� Gorod_Event_Znak ���� GOROD_EVENT_ZNAK, ��� znakType=GOROD_ZNAK_OTHER */
function SendZnakEvent(int MsgId)
{
	local Gorod_Event_Znak ev;
	if(PC != none)
	{
		ev = new class'Gorod_Event_Znak';
		ev.sender = self;
		ev.messageID = MsgId;
		ev.eventType=GOROD_EVENT_ZNAK;
		PC.EventDispatcher.SendEvent(ev);
	}
	return;
}

/** ������� ��� ��������� ������� Gorod_Event_Znak ���� GOROD_EVENT_ZNAK, ��� znakType=GOROD_ZNAK_SPEEDTYPE */
function SendZnakSpeedEvent(int MsgId)
{
	local Gorod_Event_Znak ev;
	if(PC != none)
	{
		ev = new class'Gorod_Event_Znak';
		ev.sender = self;
		ev.messageID = MsgId;
		ev.eventType=GOROD_EVENT_ZNAK;
		ev.znakType=GOROD_ZNAK_SPEEDTYPE;
		PC.EventDispatcher.SendEvent(ev);
	}
	return;
}


DefaultProperties
{
}
