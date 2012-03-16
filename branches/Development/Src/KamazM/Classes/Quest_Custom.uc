class Quest_Custom 
	extends Object 
	config (Quest) perobjectconfig
	implements (Gorod_EventListener) ;

enum QUEST_STATE 
{
	QUEST_STATE_DISABLE, 
	QUEST_STATE_ENABLE, 
	QUEST_STATE_START,
	QUEST_STATE_CANCELED,
	QUEST_STATE_COMPLETE, 
	QUEST_STATE_FAIL
};

/** 
 *  Позиция на карте */
struct Point
{
	var() Name Level;
	var() Vector Location;
	var() Rotator Rotation;
	var() float Radius;
};

/** 
 *  Стартовые позиции */
struct QuestPoint
{
	/** Позиция машины */
	var() Point CarPosition;
	/** Позиция Игрока */
	var() Point PlayerStart;
	/** Игрок находиться внутри машины */
	var() bool StartInDrive;
};

var protected PlayerController PC;
var protected Gorod_EventDispatcher ED;

var protected QUEST_STATE QS;

/** ID - Квеста */
var(Quest) config int QuestId;
var(Quest) config string QuestName;
var(Quest) config string QuestType;

var(Quest) config string QuestTitle;
var(Quest) config string QuestDescription;

/**
 * Путевые точки по квесту */
var(QRoute) config QuestPoint StartPoint;
var(QRoute) config QuestPoint FinishPoint;
var(QRoute) config array<QuestPoint> Points;

var (Quest) config bool bTipsEnabled;



function Gorod_EventDispatcher getED()
{
	if(ED == none)
		ED = Kamaz_PlayerController (PC).EventDispatcher;
	return ED;
}



function Gorod_Event_Quest sendEvent(int messageID)
{
	local Gorod_Event_Quest EventToSend;
	if (EventToSend == none)
	{
		EventToSend = new class'Gorod_Event_Quest';
		EventToSend.eventType = GOROD_EVENT_QUEST;
		
		EventToSend.sender = self;
		EventToSend.QuestId = QuestId;
	}

	EventToSend.messageID = messageID;
	getED().SendEvent(EventToSend);
	return EventToSend;
}

function DoDisable(Gorod_Event evt)
{
	sendEvent(3001);
}

function DoEnable(Gorod_Event evt)
{
	sendEvent(3002);
}

function DoCanceled(Gorod_Event evt)
{
	SendEvent(3003);
}

function DoComplete()
{
	QS = QUEST_STATE_COMPLETE;
	SendEvent(3004);
}

function DoFail()
{
	QS = QUEST_STATE_FAIL;
	SendEvent(3005);
}

function DoStart(Gorod_Event evt)
{
	SendEvent(3010 /*Start*/);
}

function DoReStart(Gorod_Event evt)
{
	SendEvent(3011 /*ReStart*/);
}

/**  Прием сообщений */ 
function HandleEvent(Gorod_Event evt)
{
	if (evt.eventType == GOROD_EVENT_QUEST)
	{
		if (Gorod_Event_Quest (evt) != none && Gorod_Event_Quest(evt).QuestId == QuestId)
		switch (evt.messageID)
		{
			case 3001: // Disable
				QS = QUEST_STATE_DISABLE;
			break;
			case 3002: // Enable
				QS = QUEST_STATE_ENABLE;
			break;
			case 3003: // Canceled
				QS = QUEST_STATE_CANCELED;
			break;
			case 3004: // Complete
			break;
			case 3005: // Fail
			break;
			case 3006: // Start
				if (QS == QUEST_STATE_ENABLE)
					DoStart(evt);
			break;
			case 3007: // Restart
				if (QS == QUEST_STATE_ENABLE)
					DoReStart(evt);
			break;
			default:
			break;
		}
	}
}


DefaultProperties
{
	QS = QUEST_STATE_DISABLE;
}
