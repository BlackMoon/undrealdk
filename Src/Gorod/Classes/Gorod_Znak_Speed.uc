/**Базовый класс для дорожных знаков ограничения скорости */
class Gorod_Znak_Speed extends Gorod_Znak_Circle;

var int speed_limit;

function SendZnakEvent(Object sender, int MsgId)
{
	local Gorod_Event_Znak ev;
	if(PC != none)
	{
		ev = new class'Gorod_Event_Znak';
		ev.sender = self;
		ev.messageID = MsgId;
		ev.eventType=GOROD_EVENT_ZNAK;
		ev.speed=speed_limit;
		ev.znakType=GOROD_ZNAK_SPEEDTYPE;
		Common_PlayerController(PC).EventDispatcher.SendEvent(ev);
	}
}


DefaultProperties
{

}

