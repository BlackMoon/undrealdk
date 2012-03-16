/** Класс отчета. Хранит все нарушения, произошедшие со старта игры до окончания */
class Kamaz_CReport extends Actor dependson (Gorod_EventDispatcher,Gorod_BaseMessages) implements(Gorod_EventListener);

`include(Gorod\Gorod_Events.uci);

/** Ссылка на плеерконтроллер */
var Kamaz_PlayerController gorodPC;

var array<MessageInfo> MsgInfos;
/** флаг, по которому мы понимаем, что надо начать собирать отчет */
var bool gameStarted;
var Gorod_ReportEvent ReportEvent;

/** Количество баллов за нарушения вцелом */
var int pointsCount;
/** Количество штрафов за нарушения вцелом */
var int moneyPenaltyCount;
/** количество упражнений */
var int exerciseCount;
/**Функция инициализации класса. Обязательно вызвать после создания объекта,  перед первым обращением к свойствам или функциям.*/
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
/** Деинициализатор. Отписываемся от сообщений и тд */
function UnInitialize()
{
	if(gorodPC!=none)
	{
		ClearStats();
		gorodPC.EventDispatcher.RemoveListener(self);
		//pointsCount=
	}
}
/** Очищает отчет */
function ClearStats()
{
	//очищаем массив 
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
	//проверяем, соообщение относятли к началу упражнения ?
	if(CheckExerciseStartedMessage(evt.messageID))
		return;

	if(CheckMsg(msgInfo))
	{
		//если игра началась
		if(gameStarted)
		{
			MsgInfos.AddItem(msgInfo);
			pointsCount+=msgInfo.Points;
			moneyPenaltyCount+=msgInfo.MoneyPenalty;
			
		}
	}
}

/** Проверки игровых входящих сообщений на старт игры. Меняет флаг gameStarted данного класса при соответсвующем сообщении*/
function CheckGameMsg(int messageID)
{
	//сообщение о начале игры
	if(messageID ==GOROD_GAME_STARTED)
	{		
		gameStarted=true;
					
	}

	//сообщение об окончании игры
	if(messageID == GOROD_MISSION_ENDED)
	{
		if(gameStarted)

			SendEvent();

		gameStarted=false;
	}
}

/**
 *  функция проверяет сообщение и выстанавливает необходимые флаги */
function bool CheckMsg(MessageInfo msgInfo)
{
	//нарушение ли?
  	if(msgInfo.Points!=0 || msgInfo.MoneyPenalty!=0 || msgInfo.type == MESSAGE_ERROR)
		return true;
	return false;
}

function bool CheckExerciseStartedMessage(int messageID)
{
	return false;
}
/** Решает, успешный ли отчет*/
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
 *  Отсылает сообщение */
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
