class DP_Signals extends Actor DllBind(DPAsync) config(DP_Signals);

struct DP_Exchange
{
	var int iTime;	            //	время в миллисекундах с начала работы приложения
	var int iRoll;	            //	угол крена может принимать значения от -32 768 до 32 768, что соответствует крайним значениям углов
	var int iPitch;	            //	угол тангажа 

	structdefaultproperties
	{
		iTime       = 0
		iRoll       = 0
		iPitch      = 0
	}
};

var DP_Exchange objDPExchange;
var config const float fTimerTime;
var float fTime;
var Gorod_VehicleContent_Lada_12 refLadaCar;
var DP_WriteAngles objWA;

dllimport final function PushCurrentPack(out DP_Exchange obj);

event PostBeginPlay()
{
	local Gorod_VehicleContent_Lada_12 refCar;

	super.PostBeginPlay();
	foreach AllActors(class'Gorod_VehicleContent_Lada_12', refCar)
	{
		refLadaCar = refCar;
		break;
	}
	`warn("refLadaCar == none", refLadaCar == none);
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
	if (refLadaCar != none)
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