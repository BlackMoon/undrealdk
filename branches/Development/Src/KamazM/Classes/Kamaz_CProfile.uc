class Kamaz_CProfile extends Actor dependson (Gorod_EventDispatcher, Gorod_Event, Gorod_BaseMessages) implements(Gorod_EventListener);

`include(Gorod\Gorod_Events.uci);

var Kamaz_PlayerController kamazPC;

function Initialize(Kamaz_PlayerController objPC)
{
	kamazPC = objPC;
	`warn("kamazPC=none", kamazPC==none);
	if(kamazPC!=none)
	{
		kamazPC.EventDispatcher.RegisterListener(self,GOROD_EVENT_QUEST);
		kamazPC.EventDispatcher.RegisterListener(self,GOROD_EVENT_GAME);
	}
}

function HandleEvent(Gorod_Event evt)
{
	local Gorod_ReportEvent ReportEvent;
	//��������� � ������ ����
	if(evt.messageID == GOROD_GAME_STARTED && evt.eventType == GOROD_EVENT_GAME)
	{
		CreateReport();
	}
	if(evt.senderName=='Gorod_Report')
	{
		
		ReportEvent = Gorod_ReportEvent(evt);
		if(ReportEvent !=none)
		{
			/** ���� ����� �������*/
			//if(ReportEvent.bSuccess)
			SaveReport(ReportEvent);
			//ReportEvent.MsgInfos
		}
	}
}

/** 
 *  ��������� ��� ������� ����� */
function CreateReport()
{
	local array<string> questsId;
	local string questId;
	questsId = kamazPC.GetQuests("FreeDrv");

	if(questsId.Length==0)
		questId = kamazPC.CreateQuest("FreeDrv");
	else
		questId = questsId[0];

	kamazPC.StartQuest(questId);

}

function SaveReport(Gorod_ReportEvent ReportEvent)
{
	local MessageInfo msgInfo;
	foreach ReportEvent.MsgInfos(msgInfo)
	{
		kamazPC.AddQuestsPointsCount(msgInfo.Points);
	}
	kamazPC.endQuest(true);
}

DefaultProperties
{
}
