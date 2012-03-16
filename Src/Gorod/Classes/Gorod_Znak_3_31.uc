/**
 * �������� ���� 3.31, ����� ���� �����������.
 * */
class Gorod_Znak_3_31 extends Gorod_Znak_Other placeable;


event Activate(vector HitLocation, vector HitNormal)
{
	local Gorod_Event_Znak ev;
	local Common_PlayerController GorodPC;

	super.Activate(HitLocation,HitNormal);
	//������ ��� �� �������������� �������(������ ������� ���� "���������" �����) ��� ���������� ���������� ������;
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
