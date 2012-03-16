/** Класс контроллера ПДД. Получает сообщения от контроллера знаков, контроллера скоростных знаков, также от разметрки (уточнять у Динара)  */
class Gorod_PDDController extends Actor dependson (Gorod_EventDispatcher,Gorod_BaseMessages) implements(Gorod_EventListener);

										/**ссылка на Gorod_PlayerController*/
var Common_PlayerController PC;
										/***/
var Gorod_PDDMessages PDDMessage;
										/***/
var bool bHasRegisteredInMessagesManager;
										/**подключаем справочник сообщений*/
`include(Gorod_Events.uci);

/**Функция инициализации объекта класса*/
function Initeliaze(Common_PlayerController myPC)
{
	PC = myPC;
	if(PC == none)
	{
		`warn("GetALocalPlayerController() = none", PC == none);
		return;
	}
	PC.EventDispatcher.RegisterListener(self,GOROD_EVENT_PDD); // подписываемчя на события типа GOROD_EVENT_PDD
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

/**Функция обработчик событий на которые подписан данный объект, данная функция регламинтируется интерфейсом Gorod_EventListener, подписывание на события происходит в function Initeliaze(Gorod_PlayerController myPC) данного класса.*/
function HandleEvent(Gorod_Event evnt)
{	
	switch (evnt.messageID)
	{
	case GOROD_PDD_OUT_OF_SPEED_MAX_LIMIT_RESULT:   //зафиксирован конец дейсивия знака максимального скростного ограничения и его нарушение
		if(Gorod_Event_PDD(evnt).ParametrInt2<20 )
			SendHUDMessages(GOROD_PDD_OUT_OF_SPEED_MAX_LIMIT_RESULT_10_20);
		else if(Gorod_Event_PDD(evnt).ParametrInt2>=20 && Gorod_Event_PDD(evnt).ParametrInt2<40)
			SendHUDMessages(GOROD_PDD_OUT_OF_SPEED_MAX_LIMIT_RESULT_20_40);
		else if(Gorod_Event_PDD(evnt).ParametrInt2>=40 && Gorod_Event_PDD(evnt).ParametrInt2<60)
			SendHUDMessages(GOROD_PDD_OUT_OF_SPEED_MAX_LIMIT_RESULT_40_60);
		else if(Gorod_Event_PDD(evnt).ParametrInt2>=60)
			SendHUDMessages(GOROD_PDD_OUT_OF_SPEED_MAX_LIMIT_RESULT_60);
		break;
	case GOROD_PDD_OUT_OF_SPEED_MIN_LIMIT_RESULT:    // зафиксирован конец дейсивия знака минимального скростного ограничения и его нарушение
			SendHUDMessages(GOROD_PDD_OUT_OF_SPEED_MIN_LIMIT_RESULT);
		break;
	case GOROD_PDD_VIOLATION_BRICK:                 // зафиксирован проезд под знак кирпич
		SendHUDMessages(GOROD_PDD_VIOLATION_BRICK);
		break;
	case GOROD_PDD_CROSSROAD_ENTER:                 // зафиксировали въезд в перекресток, отмена всех ограничений
		SendZnakSpeedEvent(GOROD_ZNAK_END_ALL_LIMIT);
		break;
	case GOROD_PDD_VIOLATION_STOP:                  // зафиксировано нарушение знака STOP
		SendHUDMessages(GOROD_PDD_VIOLATION_STOP);
		break;
	case GOROD_PDD_SIRENA_SIGNAL_ENABLED: // зафиксировано включение сигнала сирены
		SendZnakEvent(GOROD_PDD_SIRENA_SIGNAL_ENABLED);
		SendZnakSpeedEvent(GOROD_PDD_SIRENA_SIGNAL_ENABLED);
		break;
	case GOROD_PDD_SIRENA_SIGNAL_DISABLED:           // зафиксировано выключение сигнала сирены
		SendZnakEvent(GOROD_PDD_SIRENA_SIGNAL_DISABLED);
		SendZnakSpeedEvent(GOROD_PDD_SIRENA_SIGNAL_DISABLED);
		break;
	}
}

/** Функция для генерации событи Gorod_Event типа SendHUDMessages */
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

/** Функция для генерации событий Gorod_Event_Znak типа GOROD_EVENT_ZNAK, где znakType=GOROD_ZNAK_OTHER */
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

/** Функция для генерации событий Gorod_Event_Znak типа GOROD_EVENT_ZNAK, где znakType=GOROD_ZNAK_SPEEDTYPE */
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
