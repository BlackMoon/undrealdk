/**
 * Класс контроллер знаков, в него приходят все события от знаков. Распределяет события между более узкоспециализированными контроллерами знаков или обрабатывает у себя.
 * */
class Gorod_Znak_Controller extends Object  dependson (Gorod_EventDispatcher,Gorod_BaseMessages) implements(Gorod_EventListener);
														/**ссылка на Gorod_PlayerController*/
var Common_PlayerController PC;
														/**контроллер знаков ограничения скорости*/
var Gorod_Znak_ControllerSpeed ZnakControllerSpeed;
														/**подключение справочника событий*/
`include(Gorod_Events.uci);
														/**флаг, сосотояние сигнала сирены*/
var bool SirenaSignalEnabled;

/**Функция инициализации объекта класса*/
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
	PC.EventDispatcher.RegisterListener(self,GOROD_EVENT_ZNAK); // подписываемчя на события типа GOROD_EVENT_ZNAK
}


/**Функция обработчик сообщения о новом входящем знаке*/
function ZnakCome(Gorod_Event_Znak evt)
{

	if(evt.messageID==GOROD_PDD_SIRENA_SIGNAL_ENABLED)// включение ли серена
	{
		SirenaSignalEnabled=true;
		return;
	}
	if(evt.messageID==GOROD_PDD_SIRENA_SIGNAL_DISABLED)// выключение ли серена
	{
		SirenaSignalEnabled=false;
		return;
	}

	if (!SirenaSignalEnabled) // если серена выключена
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

/** Функция обработчик событий на которые подписан данный объект, регламинтируется интерфейсом Gorod_EventListener, подписывание на события происходит в function Initeliaze(Gorod_PlayerController myPC) данного класса.*/
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


/**Функция генерации события типа GOROD_EVENT_PDD */
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
