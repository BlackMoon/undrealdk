/** �������� ����
 *  
 *  ������� �-�� */

class Gorod_Znak_Touch extends Gorod_Znak_Content;

/** ���� ����������� ������ ����� ������ */
var PlayerController PC;

var UDKVehicle PlayerVehicle;

event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	if (Pawn(Other) == none)
		return;

	/** ��� �����? */
	if(PlayerController(Pawn(Other).Controller) == none)
		return;
	
	/** ����� ���� � ������? */
	if(UDKVehicle(Other) == none)
		return;

	PlayerVehicle = UDKVehicle(Other);
	/** �������� ���������� ������, �������� ����������� ���� */
	PC = GetALocalPlayerController();
	if(PC == none)
		return;

	/** ��� �����, �������� ����������� ����? */
	if(PlayerController(Pawn(Other).Controller) != PC)
		return;	
	Activate(HitLocation, HitNormal);
}

event UnTouch(Actor Other)
{
	if (Other == none)
		return;

	/** ��� �����? */
	if(PlayerController(Pawn(Other).Controller) == none)
		return;
	
	/** ����� ���� � ������? */
	if(UDKVehicle(Other) == none)
		return;

	PlayerVehicle = UDKVehicle(Other);
	/** �������� ���������� ������, �������� ����������� ���� */
	PC = GetALocalPlayerController();
	if(PC == none)
		return;

	/** ��� �����, �������� ����������� ����? */
	if(PlayerController(Pawn(Other).Controller) != PC)
		return;	
	UnActivate();
}


function Activate(vector HitLocation, vector HitNormal)
{
	return;
}
function UnActivate()
{
	return;
}

function bool CheckDirection(vector HitLocation, vector HitNormal)
{
	local Rotator rotRes;

	rotRes= Rotator(HitNormal)-Rotation;
	`log(rotRes.Yaw*UnrRotToDeg);

	/**��������� � ������� ������� �����?*/
	if (rotRes.Yaw*UnrRotToDeg>0 || rotRes.Yaw*UnrRotToDeg<-180 )
	{
		`log(rotRes.Yaw*UnrRotToDeg @ ">0 ||" @ rotRes.Yaw*UnrRotToDeg @ " <-180"); 
		return false;
	}
	return true;
}


function SendZnakEvent(Object sender, int MsgId)
{
	local Gorod_Event_Znak ev;
	local Common_PlayerController CommonPC;

	if(PC != none)
	{
		ev = new class'Gorod_Event_Znak';
		ev.sender = self;
		ev.messageID = MsgId;
		ev.eventType=GOROD_EVENT_ZNAK;
		ev.speed=0;
		ev.znakType=GOROD_ZNAK_OTHERTYPE;

		CommonPC = Common_PlayerController(PC);
		if(CommonPC != none)
			CommonPC.EventDispatcher.SendEvent(ev);
	}
}


DefaultProperties
{
}
