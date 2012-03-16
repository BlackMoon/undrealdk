/**Класс контроллера нарушения скорости , следит за выполнением скоростных ограничений. В случае нарушений генерит события типа GOROD_EVENT_PDD */
class Gorod_Znak_ControllerSpeed extends Actor;

								/**текущее максимальное ограничение скорости*/
var int MaxSpeedLimit;
								/**теукщее минимальное ограничение скорости*/
var int MinSpeedLimit;
								/**максимальное ограничение скорости по умолчанию для данной местности*/
var int MaxSpeedLimitDefailt;
								/**минимальное ограничение скорости по умолчанию для данной местности*/
var int MinSpeedLimitDefailt;
								/**максимально допустимое отклонение скорости*/
var int SpeedDeviation;
								/**максимальное зарегистрированное превышение скорости*/
var int MaxSpeedViolation;
								/**максимальное зарегестрированное пренижение скорости*/
var int MinSpeedViolation;
								/**флаг, проверять ли скоростной режим*/
var bool bCheckSpeedEnable;
								/**флаг, проверять ли минимальный скоростной режим*/
var bool bCheckMinSpeedEnable;
								/** флаг, въехали в зону действия знака стоп */
var bool bZnakStopEnable;
								/**минимальное значение скорости в области действия знака STOP */
var float StopAreaMinSpeed;
								/**флаг, проехал ли через стоп линию знака "STOP" */
var bool StopLineTouch;
								/**флаг, записываем в него состояние сирены*/
var bool bSirenaSigalEnabled;
								/**ссылка на Gorod_PlayerController*/
var Common_PlayerController PC;

`include(Gorod_Events.uci);

function PostBeginPlay()
{
	super.PostBeginPlay();
	SetTimer(2,true,'CheckSpeed');
}


/**Функция обработчик сообщения о новом входящем знаке, вызывается из Gorod_Znak_Controller.HandleEvent(Gorod_Event evt) */
function ZnakCome( Gorod_Event_Znak event)
{
	switch(event.messageID)
	{
	case GOROD_PDD_SIRENA_SIGNAL_ENABLED:
		FixViolation();
		bSirenaSigalEnabled=true;
		break;
	case GOROD_PDD_SIRENA_SIGNAL_DISABLED:
		bSirenaSigalEnabled=false;
		break;
	case GOROD_ZNAK_MAX_SPEED_LIMIT:
		FixViolation();
		MaxSpeedLimit=event.speed;
		MaxSpeedViolation=0;
		break;
	case GOROD_ZNAK_MIN_SPEED_LIMIT:
		FixViolation();
		MinSpeedLimit=event.speed;
		MinSpeedViolation=0;
		break;
	case GOROD_ZNAK_CANCEL_MAX_SPEED_LIMIT:
		FixViolation();
		MaxSpeedLimit=MaxSpeedLimitDefailt;
		MaxSpeedViolation=0;
		break;
	case GOROD_ZNAK_CANCEL_MIN_SPEED_LIMIT:
		FixViolation();
		MinSpeedLimit=MinSpeedLimitDefailt;
		MinSpeedViolation=0;
		break;
	case GOROD_ZNAK_END_ALL_LIMIT:
		FixViolation();
		MinSpeedLimit=MinSpeedLimitDefailt;
		MaxSpeedLimit=MaxSpeedLimitDefailt;
		MinSpeedViolation=0;
		MaxSpeedViolation=0;
		break;
	case GOROD_ZNAK_STOP_START:
		bZnakStopEnable=true;
		bCheckMinSpeedEnable=false;
		break;
	case GOROD_ZNAK_STOP_LINE:
		StopLineTouch=true;
		break;
	case GOROD_ZNAK_STOP_END:
		FixStopZnakViolation();
		StopAreaMinSpeed=2;
		bZnakStopEnable=false;
		bCheckMinSpeedEnable=true;
		StopLineTouch=false;
		break;
	}

}

/**Функция проверки скорости и сирены, вызывается таймером*/
function CheckSpeed()
{
	local float CurentSpeed;
	
	
	if(bCheckSpeedEnable && !bSirenaSigalEnabled) // проверка скорости включена ? + отключена ли сирена?
	{
		if(UDKVehicle(PC.Pawn) == none) // игрок в машине?
		{
			return;
		}
		CurentSpeed=PlayerCarBase(PC.Pawn).GetSpeedInKMpH();
		if(CurentSpeed>MaxSpeedLimit+SpeedDeviation) // выше ли текущая скорость  (максимально разрешенной+допустимое отклонение)?
		{
			if(MaxSpeedViolation<CurentSpeed-MaxSpeedLimit) //больше ли превышение скорости чем превышение зафиксированное до этого?
			{
				MaxSpeedViolation=CurentSpeed-MaxSpeedLimit;
			}
			SendPDDEvent(self, GOROD_PDD_OUT_OF_SPEED_MAX_LIMIT, MaxSpeedLimit);
		}

		if(CurentSpeed<MinSpeedLimit-SpeedDeviation && bCheckMinSpeedEnable) // Меньше ли текущая скорость чем  (минимально разрешенной-допустимое отклонение) ?  + учитывается флаг необходимости проверки.
		{
			if(MinSpeedViolation<MinSpeedLimit-CurentSpeed) //больше ли пренижение скорости чем пренижение зафиксированное до этого?
			{
				MinSpeedViolation=MinSpeedLimit-CurentSpeed;
			}
			SendPDDEvent(self, GOROD_PDD_OUT_OF_SPEED_MIN_LIMIT, MinSpeedLimit);
		}

		if(bZnakStopEnable) // если проверяем на знак STOP
		{
			if(CurentSpeed<StopAreaMinSpeed)
				StopAreaMinSpeed=CurentSpeed;
		}
	}
	return;
}

/**Функция фиксирования степени нарушения знаков ограничения скоростного режима. Вызывается после выезда из области действия знака.*/
function FixViolation()
{
	if(!bSirenaSigalEnabled)
	{
		if(MaxSpeedViolation>0)
		{
			SendPDDEvent(self,GOROD_PDD_OUT_OF_SPEED_MAX_LIMIT_RESULT,MaxSpeedLimit,MaxSpeedViolation);
		}
		if(MinSpeedViolation>0)
		{
			SendPDDEvent(self,GOROD_PDD_OUT_OF_SPEED_MIN_LIMIT_RESULT,MinSpeedLimit, MinSpeedViolation);
		}
	}
	return;
}

/**Функция фиксирования нарушения знака STOP. Вызывается по прикосновению стоп линии. */
function FixStopZnakViolation()
{
	if(!bSirenaSigalEnabled)
		if(bZnakStopEnable && StopAreaMinSpeed>1 && StopLineTouch)
		{
			//пошлем событие о нарушении знака стоп
			SendPDDEvent(self,GOROD_PDD_VIOLATION_STOP,0, 0);
		}
	return;
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
	MinSpeedLimitDefailt=0;
	MaxSpeedLimitDefailt=60;
	MinSpeedLimit=0;
	MaxSpeedLimit=60;
	MaxSpeedViolation=0;
	MinSpeedViolation=0;
	SpeedDeviation=9;
	bCheckSpeedEnable=true;
	bCheckMinSpeedEnable=true;
	bZnakStopEnable=false;
	StopAreaMinSpeed=2;
	StopLineTouch=false;
	bSirenaSigalEnabled=false;
}
