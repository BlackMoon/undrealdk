/**
 * ����� ���������� ������, � ���� �������� ��� ������� �� ������. ������������ ������� ����� ����� ����������������������� ������������� ������ ��� ������������ � ����.
 * */
class Gorod_Znak_Controller extends Object  dependson (Gorod_EventDispatcher,Gorod_BaseMessages) implements(Gorod_EventListener);
														/**������ �� Gorod_PlayerController*/
var Common_PlayerController PC;
														/**���������� ������ ����������� ��������*/
var Gorod_Znak_ControllerSpeed ZnakControllerSpeed;
														/**����������� ����������� �������*/
`include(Gorod_Events.uci);
														/**����, ���������� ������� ������*/
var bool SirenaSignalEnabled;

/**������� ������������� ������� ������*/
function Initeliaze(Common_PlayerController myPC)
{
	
	PC = myPC;
	ZnakControllerSpeed=PC.Spawn(class'Gorod_Znak_ControllerSpeed');
	ZnakControllerSpeed.PC=PC;

	if(PC == none)
	{
		`warn("GetALocalPlayerController() = none", PC == none);
		return;
	}
	PC.EventDispatcher.RegisterListener(self,GOROD_EVENT_ZNAK); // ������������� �� ������� ���� GOROD_EVENT_ZNAK
}


/**������� ���������� ��������� � ����� �������� �����*/
function ZnakCome(Gorod_Event_Znak evt)
{

	if(evt.messageID==GOROD_PDD_SIRENA_SIGNAL_ENABLED)// ��������� �� ������
	{
		SirenaSignalEnabled=true;
		return;
	}
	if(evt.messageID==GOROD_PDD_SIRENA_SIGNAL_DISABLED)// ���������� �� ������
	{
		SirenaSignalEnabled=false;
		return;
	}

	if (!SirenaSignalEnabled) // ���� ������ ���������
	{
		switch(evt.messageID)
		{
		case GOROD_ZNAK_END_ALL_LIMIT:
			break;
		case GOROD_ZNAK_BRICK:
			SendPDDEvent(self,GOROD_PDD_VIOLATION_BRICK);
			break;
	
		}
	}
}

/** ������� ���������� ������� �� ������� �������� ������ ������, ���������������� ����������� Gorod_EventListener, ������������ �� ������� ���������� � function Initeliaze(Gorod_PlayerController myPC) ������� ������.*/
function HandleEvent(Gorod_Event evt)
{	switch(Gorod_Event_Znak(evt).ZnakType)
	{
		case GOROD_ZNAK_SPEEDTYPE:
			ZnakControllerSpeed.ZnakCome(Gorod_Event_Znak(evt));
		break;
		case GOROD_ZNAK_OTHERTYPE:
			ZnakCome(Gorod_Event_Znak(evt));
		break;
	}
}


/**������� ��������� ������� ���� GOROD_EVENT_PDD */
function SendPDDEvent(Object sender, int MsgId, optional int ParametrInt1, optional int ParametrInt2)
{
	local Gorod_Event_PDD ev;
	if(PC != none)
	{
		ev = new class'Gorod_Event_PDD';
		ev.sender = self;
		ev.messageID = MsgId;
		ev.eventType=GOROD_EVENT_PDD;
		ev.ParametrInt1=ParametrInt1;
		ev.ParametrInt2=ParametrInt2;
		PC.EventDispatcher.SendEvent(ev);
	}
	return;
}



DefaultProperties
{
	SirenaSignalEnabled=false;
}
