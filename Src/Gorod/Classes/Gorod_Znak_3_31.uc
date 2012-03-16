/**
 * Дорожный знак 3.31, конец всех ограничений.
 * */
class Gorod_Znak_3_31 extends Gorod_Znak_Other placeable;


event Activate(vector HitLocation, vector HitNormal)
{
	local Gorod_Event_Znak ev;
	local Common_PlayerController GorodPC;

	super.Activate(HitLocation,HitNormal);
	//пошлем так же дополнительное событие(помимо события типа "остальные" знаки) для контролера скоростных знаков;
	if(PC != none)
	{
		ev = new class'Gorod_Event_Znak';
		ev.sender = self;
		ev.messageID = 2005;
		ev.eventType=GOROD_EVENT_ZNAK;
		ev.speed=0;
		ev.znakType=GOROD_ZNAK_SPEEDTYPE;

		GorodPC = Common_PlayerController(PC);
		if(GorodPC != none)
			GorodPC.EventDispatcher.SendEvent(ev);
	}
}


DefaultProperties
{
	Begin Object Name=MeshCompSign
		Materials[0] = MaterialInstanceConstant'Znaky.Material_Instances.3_31_mINST'
	End Object
	msgId=2005
}
