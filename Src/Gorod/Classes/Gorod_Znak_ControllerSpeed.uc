/**����� ����������� ��������� �������� , ������ �� ����������� ���������� �����������. � ������ ��������� ������� ������� ���� GOROD_EVENT_PDD */
class Gorod_Znak_ControllerSpeed extends Actor;

								/**������� ������������ ����������� ��������*/
var int MaxSpeedLimit;
								/**������� ����������� ����������� ��������*/
var int MinSpeedLimit;
								/**������������ ����������� �������� �� ��������� ��� ������ ���������*/
var int MaxSpeedLimitDefailt;
								/**����������� ����������� �������� �� ��������� ��� ������ ���������*/
var int MinSpeedLimitDefailt;
								/**����������� ���������� ���������� ��������*/
var int SpeedDeviation;
								/**������������ ������������������ ���������� ��������*/
var int MaxSpeedViolation;
								/**������������ ������������������ ���������� ��������*/
var int MinSpeedViolation;
								/**����, ��������� �� ���������� �����*/
var bool bCheckSpeedEnable;
								/**����, ��������� �� ����������� ���������� �����*/
var bool bCheckMinSpeedEnable;
								/** ����, ������� � ���� �������� ����� ���� */
var bool bZnakStopEnable;
								/**����������� �������� �������� � ������� �������� ����� STOP */
var float StopAreaMinSpeed;
								/**����, ������� �� ����� ���� ����� ����� "STOP" */
var bool StopLineTouch;
								/**����, ���������� � ���� ��������� ������*/
var bool bSirenaSigalEnabled;
								/**������ �� Gorod_PlayerController*/
var Common_PlayerController PC;

`include(Gorod_Events.uci);

function PostBeginPlay()
{
	super.PostBeginPlay();
	SetTimer(2,true,'CheckSpeed');
}


/**������� ���������� ��������� � ����� �������� �����, ���������� �� Gorod_Znak_Controller.HandleEvent(Gorod_Event evt) */
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

/**������� �������� �������� � ������, ���������� ��������*/
function CheckSpeed()
{
	local float CurentSpeed;
	
	
	if(bCheckSpeedEnable && !bSirenaSigalEnabled) // �������� �������� �������� ? + ��������� �� ������?
	{
		if(UDKVehicle(PC.Pawn) == none) // ����� � ������?
		{
			return;
		}
		CurentSpeed=PlayerCarBase(PC.Pawn).GetSpeedInKMpH();
		if(CurentSpeed>MaxSpeedLimit+SpeedDeviation) // ���� �� ������� ��������  (����������� �����������+���������� ����������)?
		{
			if(MaxSpeedViolation<CurentSpeed-MaxSpeedLimit) //������ �� ���������� �������� ��� ���������� ��������������� �� �����?
			{
				MaxSpeedViolation=CurentSpeed-MaxSpeedLimit;
			}
			SendPDDEvent(self, GOROD_PDD_OUT_OF_SPEED_MAX_LIMIT, MaxSpeedLimit);
		}

		if(CurentSpeed<MinSpeedLimit-SpeedDeviation && bCheckMinSpeedEnable) // ������ �� ������� �������� ���  (���������� �����������-���������� ����������) ?  + ����������� ���� ������������� ��������.
		{
			if(MinSpeedViolation<MinSpeedLimit-CurentSpeed) //������ �� ���������� �������� ��� ���������� ��������������� �� �����?
			{
				MinSpeedViolation=MinSpeedLimit-CurentSpeed;
			}
			SendPDDEvent(self, GOROD_PDD_OUT_OF_SPEED_MIN_LIMIT, MinSpeedLimit);
		}

		if(bZnakStopEnable) // ���� ��������� �� ���� STOP
		{
			if(CurentSpeed<StopAreaMinSpeed)
				StopAreaMinSpeed=CurentSpeed;
		}
	}
	return;
}

/**������� ������������ ������� ��������� ������ ����������� ����������� ������. ���������� ����� ������ �� ������� �������� �����.*/
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

/**������� ������������ ��������� ����� STOP. ���������� �� ������������� ���� �����. */
function FixStopZnakViolation()
{
	if(!bSirenaSigalEnabled)
		if(bZnakStopEnable && StopAreaMinSpeed>1 && StopLineTouch)
		{
			//������ ������� � ��������� ����� ����
			SendPDDEvent(self,GOROD_PDD_VIOLATION_STOP,0, 0);
		}
	return;
}

/**������� ��������� ������� ���� GOROD_EVENT_PDD */
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
