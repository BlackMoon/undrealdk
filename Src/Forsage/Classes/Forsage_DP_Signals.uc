class Forsage_DP_Signals extends Actor DllBind(DPAsync) config(DP_Signals);

struct Forsage_DP_Exchange
{
	var int iTime;	            //	����� � ������������� � ������ ������ ����������
	var int iRoll;	            //	���� ����� ����� ��������� �������� �� -32�768 �� 32�768, ��� ������������� ������� ��������� �����
	var int iPitch;	            //	���� ������� 

	structdefaultproperties
	{
		iTime       = 0
		iRoll       = 0
		iPitch      = 0
	}
};

var Forsage_DP_Exchange objDPExchange;      //  ��������� ��� �������� �� ��������� ������ �� ����� � �������
var config const float fTimerTime;          //  �������� ������� ����� �������� ������� �� ���������
var float fTime;                            //  ����� ����� ������ ����������
var Forsage_PlayerCar refLadaCar;           //  ������ �� ������, ������ � ������� ������������ �� ���������
var DP_WriteAngles objWA;                   //  ������ ��� ���������� � ����������� �������, ������� ������������ �� ���������

//  ������� ����������
var Forsage_PlayerCar refCar;               
var Forsage_PlayerCar refRet;

dllimport final function PushCurrentPack(out Forsage_DP_Exchange obj);

function Forsage_PlayerCar GetCar()
{
	if (refLadaCar == none)
	{
		foreach AllActors(class'Forsage_PlayerCar', refCar)
		{
			refRet = refCar;
			break;
		}
	}
	return refRet;
}

event PostBeginPlay()
{
	super.PostBeginPlay();
	objWA = Spawn(class'DP_WriteAngles');
	`warn("objWA == none", objWA == none);

	SetTimer(fTimerTime, true, 'TimerFunc');
}

simulated function Tick(float fDeltaTime)
{
	super.Tick(fDeltaTime);
	fTime += fDeltaTime;
}

function TimerFunc()
{
	if (refLadaCar == none)
		refLadaCar = GetCar();
	else
	{
		objDPExchange.iTime = fTime * 1000;
		objDPExchange.iRoll = refLadaCar.Rotation.Roll;
		objDPExchange.iPitch = refLadaCar.Rotation.Pitch;
		PushCurrentPack(objDPExchange);
		objWA.WriteDataForFiles(refLadaCar.Rotation.Roll, refLadaCar.Rotation.Pitch);
	}
}

DefaultProperties
{
	fTime=0.f
}
