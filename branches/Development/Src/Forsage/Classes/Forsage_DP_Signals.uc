class Forsage_DP_Signals extends Actor DllBind(DPAsync) config(DP_Signals);

struct Forsage_DP_Exchange
{
	var int iTime;	            //	врем€ в миллисекундах с начала работы приложени€
	var int iRoll;	            //	угол крена может принимать значени€ от -32†768 до 32†768, что соответствует крайним значени€м углов
	var int iPitch;	            //	угол тангажа 

	structdefaultproperties
	{
		iTime       = 0
		iRoll       = 0
		iPitch      = 0
	}
};

var Forsage_DP_Exchange objDPExchange;      //  структура дл€ отправки на платформу данных об углах и времени
var config const float fTimerTime;          //  интервал времени между посылкой пакетов на платформу
var float fTime;                            //  общее врем€ работы приложени€
var Forsage_PlayerCar refLadaCar;           //  ссылка на машину, данные о которой отправл€ютс€ на платформу
var DP_WriteAngles objWA;                   //  объект дл€ накоплени€ и логировани€ пакетов, которые отправл€ютс€ на платформу

//  рабочие переменные
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
