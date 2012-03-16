/** Класс определяет положения объекта на дороге и характер его движения
 *  для корректного определения должны соблюдаться следующие требования:
 *    - у детектируемого пауна должны иметься все сокеты, имена которых можно увидеть в defaultproperties
 *    - сокеты должны располагаться определенным образом, чтобы луч Trace имел правильное направление
 *    - имена материалов асфальтовых дорог должны начинаться с 4_polos
 *    - имена материалов перекрестов должны начинаться с Per_M
 *    
 *    (остальные материалы относятся к классу "Вне дороги")
 *
 *  */
class Zarnitza_OnRoadSituationDetector extends Object;

/** Положение углов объекта */
enum RoadPositions
{
	ROADPOS_OFFROAD,
	ROADPOS_ONCROSSROAD,
	ROADPOS_ONROAD,
	ROADPOS_ONPAREBRIK
};

enum InroadState
{
	RSD_INROADSTATE_UNKNOWN,
	RSD_INROADSTATE_ON_CORRECT_SIDE,
	RSD_INROADSTATE_ON_WRONG_SIDE,
	RSD_INROADSTATE_GOING_TO_WRONG_SIDE,
	RSD_INROADSTATE_GOING_TO_CORRECT_SIDE
};

/** описания состояния при езде по полосам движения на правильной стороне проезжей части */
enum RSD_TrafficLineMoveState
{
	RSD_TRAFFICLINESTATE_UNKNOWN,
	RSD_TRAFFICLINESTATE_ONSAMELINE,
	RSD_TRAFFICLINESTATE_MOVETO_LEFT,
	RSD_TRAFFICLINESTATE_MOVETO_RIGHT
};

enum RSD_Side { RSD_SIDE_EVEN, RSD_SIDE_ODD, RSD_SIDE_UNKNOWN };

/** Имена сокетов */
var name F_L_Corner;
var name F_L_Corner_Trace;
var name F_R_Corner;
var name F_R_Corner_Trace;
var name B_L_Corner;
var name B_L_Corner_Trace;
var name B_R_Corner;
var name B_R_Corner_Trace;

/** структура, описывающая положение какого либо объекта относительно дороги */
struct OnRoadPositionInfo
{
	var RoadPositions MajorRoadPos;
	var RoadPositions MoreStrictRoadPos;
	var int ActualRoadLineNumber;                 // текущий номер полосы (четные и нечетные)
	var int ActualRoadLineSide;                   // текущий вторичный номер полосы (для определения направления движения по полосе)
	var int PrevRoadLineNumber;
	var int PrevRoadLineSide;

	var int LineOutsideParameter;                 // параметр, определяющий номер полосы, если она крайняя

	structdefaultproperties
	{
		MajorRoadPos = ROADPOS_OFFROAD
		MoreStrictRoadPos = ROADPOS_OFFROAD
	}
};

var OnRoadPositionInfo FrontLeftInfo;
var OnRoadPositionInfo FrontRightInfo;
var OnRoadPositionInfo BackLeftInfo;
var OnRoadPositionInfo BackRightInfo;
var OnRoadPositionInfo CenterInfo;


/** Паун, положение которого детектируется */
var Pawn DetectingPawn;

// типы состояний движения. описывают характер движения объекта на дороге
enum RSD_DriveStates
{
	RSD_DRIVESTATE_UNKNOWN,                     // неизвестно
	RSD_DRIVESTATE_DRIVING_TO_OFFROAD,          // автомобиль выезжает на обочину
	RSD_DRIVESTATE_DRIVING_TO_ROAD,             // автомобиль выезжает на проезжую часть
	RSD_DRIVESTATE_DRIVING_ON_ROAD,             // автомобиль едет по дороге
	RSD_DRIVESTATE_DRIVING_ON_OFFROAD,          // автомобиль едет вне проезжей части
};

/** Текущее состояние движения автомобиля */
var RSD_DriveStates ActualDriveState;

/** Флаг ожидания подтверждения текущего главного состояния на дороге. 
 *  (например, если автомобиль заехал краем колеса на обочину, 
 *  необходимо подтвердить это через некоторое время, а не менять состояние сразу.
 *  этот флаг активен, когда состояние в ожидании подтверждения. если автомобиль возвращается 
 *  на дорогу до истечения времени ожидания, то состояние остается прежним) */
var bool bPendingValidateDriveState;

/** Время, по истечении которого запускается функция подтверждения изменения положения на дорое */
var float LastPendingStartTime;

var float WaitTimeBeforeValidateDriveState;



var private InroadState ActualInroadState;
var bool bIsInroadPositionValidated;

/** текущая сторона дороги, на которой находится объект */
var private RSD_Side ActualInroadSide;

var private RSD_TrafficLineMoveState ActualTrafficLineState;

/** текущий номер полосы движения */
var private int CurrentTrafficLineNumber;

var float TraceStartZ;
var float TraceEndZ;



// делегаты, вызывающиеся при изменеии состояния движения
delegate dlgOnChangeDriveState_ToOffroad();
delegate dlgOnChangeDriveState_ToRoad();
delegate dlgOnChangeDriveState_OnRoad();
delegate dlgOnChangeDriveState_OnOffroad();

delegate dlgOnDriveInWrongSide();
delegate dlgOnDriveToWrongSide();

delegate dlgOnMoveToLeft();
delegate dlgOnMoveToRight();
delegate dlgOnCompleteMovementFromLeft();
delegate dlgOnCompleteMovementFromRight();

// этот делегат вызывается, когда объект, находясь на встречке, выравнивается по полосе
// и начинает движение в правильном направлении (например, разворачивается в неположенном месте, пересекая сплошную)
delegate dlgOnStartDriveInCorrentDirectionWhileInWrongSide();
///====================================================================================================

function RSD_Side GetActualInroadSide() { return ActualInroadSide; }

function ResetRoadPositionInfo(out OnRoadPositionInfo rpi)
{
	rpi.MajorRoadPos = ROADPOS_OFFROAD;
	rpi.MoreStrictRoadPos = ROADPOS_OFFROAD;
	rpi.ActualRoadLineSide = 0;
	rpi.ActualRoadLineNumber = 0;
	rpi.PrevRoadLineNumber = 0;
	rpi.PrevRoadLineSide = 0;
}

function Initialize(Pawn p)
{
	DetectingPawn = p;
}

function bool IsCompletelyOffRoad()
{
    if( FrontLeftInfo.MajorRoadPos == ROADPOS_OFFROAD   &&   
		FrontRightInfo.MajorRoadPos == ROADPOS_OFFROAD   &&
		BackLeftInfo.MajorRoadPos == ROADPOS_OFFROAD   &&
		BackRightInfo.MajorRoadPos == ROADPOS_OFFROAD)
		return true;
	else return false;
}

function bool IsCompletelyOnRoad() {
    if( FrontLeftInfo.MajorRoadPos == ROADPOS_ONROAD   &&   
		FrontRightInfo.MajorRoadPos == ROADPOS_ONROAD   &&
		BackLeftInfo.MajorRoadPos == ROADPOS_ONROAD   &&
		BackRightInfo.MajorRoadPos == ROADPOS_ONROAD)
		return true;
	else return false;
}

function bool IsOneOfCornersOFFROAD() {
	if( FrontLeftInfo.MajorRoadPos == ROADPOS_OFFROAD   ||   
		FrontRightInfo.MajorRoadPos == ROADPOS_OFFROAD   ||
		BackLeftInfo.MajorRoadPos == ROADPOS_OFFROAD   ||
		BackRightInfo.MajorRoadPos == ROADPOS_OFFROAD)
		return true;
	else return false;
}

function bool IsOneOfCornersONROAD() {
	if( FrontLeftInfo.MajorRoadPos == ROADPOS_ONROAD   ||   
		FrontRightInfo.MajorRoadPos == ROADPOS_ONROAD   ||
		BackLeftInfo.MajorRoadPos == ROADPOS_ONROAD   ||
		BackRightInfo.MajorRoadPos == ROADPOS_ONROAD)
		return true;
	else return false;
}

function private ChangeDriveState(RSD_DriveStates ds, optional bool callDlg = true)
{
	ActualDriveState = ds;

	if(callDlg)
	{
		switch(ActualDriveState)
		{
		case RSD_DRIVESTATE_DRIVING_ON_ROAD:
			dlgOnChangeDriveState_OnRoad();
			break;

		//------------------------------------------------------------------------------
		case RSD_DRIVESTATE_DRIVING_ON_OFFROAD:
			dlgOnChangeDriveState_OnOffroad();

			// когда игрок выезжает на обочину, переключаем состояние внутри дороги как "неизвестно"
			ChangeActualInroadState(RSD_INROADSTATE_UNKNOWN);

			ActualInroadSide = RSD_SIDE_UNKNOWN;

			break;
		//------------------------------------------------------------------------------
		case RSD_DRIVESTATE_DRIVING_TO_OFFROAD:
			dlgOnChangeDriveState_ToOffroad();

			// когда игрок выезжает на обочину, переключаем состояние внутри дороги как "неизвестно"
			ChangeActualInroadState(RSD_INROADSTATE_UNKNOWN);
			ChangeTrafficLineState(RSD_TRAFFICLINESTATE_UNKNOWN);
			break;

		//------------------------------------------------------------------------------
		case RSD_DRIVESTATE_DRIVING_TO_ROAD:
			dlgOnChangeDriveState_ToRoad();
			break;

		//------------------------------------------------------------------------------
		case RSD_DRIVESTATE_UNKNOWN:
			break;
		}
	}
}

function ValidateDriveState()
{
	if(DetectingPawn.WorldInfo.TimeSeconds - LastPendingStartTime >= WaitTimeBeforeValidateDriveState)
	{
		// время ожидания истекло
		switch(ActualDriveState)
		{
		case RSD_DRIVESTATE_DRIVING_ON_ROAD:
			// проверяем, находится ли один из углов вне дороги
			if(IsOneOfCornersOFFROAD())
			{
				// проверяем, полностью ли объект находится вне дороги
				if(IsCompletelyOffRoad())
				{
					ChangeDriveState(RSD_DRIVESTATE_DRIVING_ON_OFFROAD);
				}
				else
				{
					ChangeDriveState(RSD_DRIVESTATE_DRIVING_TO_OFFROAD);
				}
			}
			else
			{
				// по истечении ожидания остался на дороге
			}
			break;

		//------------------------------------------------------------------------------
		case RSD_DRIVESTATE_DRIVING_ON_OFFROAD:
			// проверяем, находится ли один из углов на дороге
			if(IsOneOfCornersONROAD())
			{
				// проверяем, полностью ли объект находится на дороге
				if(IsCompletelyOnRoad())
				{
					ChangeDriveState(RSD_DRIVESTATE_DRIVING_ON_ROAD);
				}
				else
				{
					ChangeDriveState(RSD_DRIVESTATE_DRIVING_TO_ROAD);
				}
			}
			else
			{
				// по истечении ожидания остался вне дороги
			}
			break;
		//------------------------------------------------------------------------------
		case RSD_DRIVESTATE_DRIVING_TO_OFFROAD:
			// сюда мы попадать не должны
			`log("RSD_DRIVESTATE_DRIVING_TO_OFFROAD not expecting here");
			break;

		//------------------------------------------------------------------------------
		case RSD_DRIVESTATE_DRIVING_TO_ROAD:
			// сюда мы попадать не должны
			`log("RSD_DRIVESTATE_DRIVING_TO_ROAD not expecting here");
			break;

		//------------------------------------------------------------------------------
		case RSD_DRIVESTATE_UNKNOWN:
			// сюда мы попадать не должны
			`log("RSD_DRIVESTATE_UNKNOWN not expecting here");
			break;

		}

		// перестаем ожидать подтверждения
		bPendingValidateDriveState = false;
	}
	else
	{
		// время ожидания не истекло
	}
}

function UpdateDriveState()
{
	switch(ActualDriveState)
	{
	case RSD_DRIVESTATE_DRIVING_ON_ROAD:
		// проверяем, находится ли один из углов вне дороги
		if(IsOneOfCornersOFFROAD()   &&   bPendingValidateDriveState == false)
		{
			bPendingValidateDriveState = true;
			LastPendingStartTime = DetectingPawn.WorldInfo.TimeSeconds;
		}
		break;

	case RSD_DRIVESTATE_DRIVING_ON_OFFROAD:
		// проверяем, находится ли один из углов на дороге
		if(IsOneOfCornersONROAD()   &&   bPendingValidateDriveState == false)
		{
			bPendingValidateDriveState = true;
			LastPendingStartTime = DetectingPawn.WorldInfo.TimeSeconds;
		}
		break;

	case RSD_DRIVESTATE_DRIVING_TO_OFFROAD:
		if(IsCompletelyOffRoad())
		{
			ChangeDriveState(RSD_DRIVESTATE_DRIVING_ON_OFFROAD);
		}
		else if(IsCompletelyOnRoad())
		{
			ChangeDriveState(RSD_DRIVESTATE_DRIVING_ON_ROAD);
		}
		break;

	case RSD_DRIVESTATE_DRIVING_TO_ROAD:
		if(IsCompletelyOffRoad())
		{
			ChangeDriveState(RSD_DRIVESTATE_DRIVING_ON_OFFROAD);
		}
		else if(IsCompletelyOnRoad())
		{
			ChangeDriveState(RSD_DRIVESTATE_DRIVING_ON_ROAD);
		}
		break;

	case RSD_DRIVESTATE_UNKNOWN:
		// пока не знаем, где находится объект, определяем:
		if(IsCompletelyOffRoad())
		{
			ChangeDriveState(RSD_DRIVESTATE_DRIVING_ON_OFFROAD);
		}
		else if(IsCompletelyOnRoad())
		{
			ChangeDriveState(RSD_DRIVESTATE_DRIVING_ON_ROAD);
		}
		else
		{
			// неизвестное состояние движения, принимаем как "выезд на проезжую часть"
			ChangeDriveState(RSD_DRIVESTATE_DRIVING_TO_ROAD);
		}
		break;

	}

	if(bPendingValidateDriveState)
		ValidateDriveState();
}

/** Функция обновляет текущее  состояние положения крайних углов объекта относительно дороги */ 
function Update()
{
	local Vector TraceStart, TraceEnd, HitNormal, HitLoc;
	local TraceHitInfo hi;

	if(DetectingPawn.Mesh != none)
	{
		// передний левый
		DetectingPawn.Mesh.GetSocketWorldLocationAndRotation(F_L_Corner, TraceStart);
		//DetectingPawn.Mesh.GetSocketWorldLocationAndRotation(F_L_Corner_Trace, TraceEnd);
		TraceEnd = TraceStart;
		TraceStart.Z = TraceStartZ;
		TraceEnd.Z = TraceEndZ;
		DetectingPawn.Trace(HitLoc, HitNormal, TraceEnd, TraceStart, true, , hi, /*TRACEFLAG_Bullet*/1);
		DetectingPawn.DrawDebugLine(TraceStart, TraceEnd, 255, 0, 0);
		//DetectingPawn.DrawDebugSphere( TraceStart, 10, 10, 0, 255, 0 );

		if(hi.Material != none) FrontLeftInfo =  GetRoadPositionInfo(hi.Material, FrontLeftInfo);
		else ResetRoadPositionInfo(FrontLeftInfo);

		// передний правый
		DetectingPawn.Mesh.GetSocketWorldLocationAndRotation(F_R_Corner, TraceStart);
		//DetectingPawn.Mesh.GetSocketWorldLocationAndRotation(F_R_Corner_Trace, TraceEnd);
		TraceEnd = TraceStart;
		TraceStart.Z = TraceStartZ;
		TraceEnd.Z = TraceEndZ;
		DetectingPawn.Trace(HitLoc, HitNormal, TraceEnd, TraceStart, true, , hi, /*TRACEFLAG_Bullet*/1);

		if(hi.Material != none) FrontRightInfo =  GetRoadPositionInfo(hi.Material, FrontRightInfo);
		else ResetRoadPositionInfo(FrontRightInfo);


		// задний левый
		DetectingPawn.Mesh.GetSocketWorldLocationAndRotation(B_L_Corner, TraceStart);
		//DetectingPawn.Mesh.GetSocketWorldLocationAndRotation(B_L_Corner_Trace, TraceEnd);
		TraceEnd = TraceStart;
		TraceStart.Z = TraceStartZ;
		TraceEnd.Z = TraceEndZ;
		DetectingPawn.Trace(HitLoc, HitNormal, TraceEnd, TraceStart, true, , hi, /*TRACEFLAG_Bullet*/1);

		if(hi.Material != none) BackLeftInfo =  GetRoadPositionInfo(hi.Material, BackLeftInfo);
		else ResetRoadPositionInfo(BackLeftInfo);


		// задний правый
		DetectingPawn.Mesh.GetSocketWorldLocationAndRotation(B_R_Corner, TraceStart);
		//DetectingPawn.Mesh.GetSocketWorldLocationAndRotation(B_R_Corner_Trace, TraceEnd);
		TraceEnd = TraceStart;
		TraceStart.Z = TraceStartZ;
		TraceEnd.Z = TraceEndZ;
		DetectingPawn.Trace(HitLoc, HitNormal, TraceEnd, TraceStart, true, , hi, /*TRACEFLAG_Bullet*/1);

		if(hi.Material != none) BackRightInfo =  GetRoadPositionInfo(hi.Material, BackRightInfo);
		else ResetRoadPositionInfo(BackRightInfo);

		// центр
		DetectingPawn.Mesh.GetSocketWorldLocationAndRotation('Center', TraceStart);
		//DetectingPawn.Mesh.GetSocketWorldLocationAndRotation(B_R_Corner_Trace, TraceEnd);
		TraceEnd = TraceStart;
		TraceStart.Z = TraceStartZ;
		TraceEnd.Z = TraceEndZ;
		DetectingPawn.Trace(HitLoc, HitNormal, TraceEnd, TraceStart, true, , hi, /*TRACEFLAG_Bullet*/1);

		if(hi.Material != none) CenterInfo =  GetRoadPositionInfo(hi.Material, CenterInfo);
		else ResetRoadPositionInfo(CenterInfo);
	}

	UpdateDriveState();

	UpdateInsideRoadSituation();
}

/** Функция обновляет текущее  состояние положения крайних углов объекта относительно дороги */ 
function Old_Update()
{
	/*local Vector TraceStart, TraceEnd, HitNormal, HitLoc;
	local TraceHitInfo hi;

	if(DetectingPawn.Mesh != none)
	{
		// передний левый
		DetectingPawn.Mesh.GetSocketWorldLocationAndRotation(F_L_Corner, TraceStart);
		DetectingPawn.Mesh.GetSocketWorldLocationAndRotation(F_L_Corner_Trace, TraceEnd);
		DetectingPawn.Trace(HitLoc, HitNormal, TraceEnd, TraceStart, true, , hi, /*TRACEFLAG_Bullet*/1);

		if(hi.Material != none) FrontLeftInfo =  GetRoadPositionInfo(hi.Material.Name, FrontLeftInfo);
		else ResetRoadPositionInfo(FrontLeftInfo);

		// передний правый
		DetectingPawn.Mesh.GetSocketWorldLocationAndRotation(F_R_Corner, TraceStart);
		DetectingPawn.Mesh.GetSocketWorldLocationAndRotation(F_R_Corner_Trace, TraceEnd);
		DetectingPawn.Trace(HitLoc, HitNormal, TraceEnd, TraceStart, true, , hi, /*TRACEFLAG_Bullet*/1);

		if(hi.Material != none) FrontRightInfo =  GetRoadPositionInfo(hi.Material.Name, FrontRightInfo);
		else ResetRoadPositionInfo(FrontRightInfo);


		// задний левый
		DetectingPawn.Mesh.GetSocketWorldLocationAndRotation(B_L_Corner, TraceStart);
		DetectingPawn.Mesh.GetSocketWorldLocationAndRotation(B_L_Corner_Trace, TraceEnd);
		DetectingPawn.Trace(HitLoc, HitNormal, TraceEnd, TraceStart, true, , hi, /*TRACEFLAG_Bullet*/1);

		if(hi.Material != none) BackLeftInfo =  GetRoadPositionInfo(hi.Material.Name, BackLeftInfo);
		else ResetRoadPositionInfo(BackLeftInfo);


		// задний правый
		DetectingPawn.Mesh.GetSocketWorldLocationAndRotation(B_R_Corner, TraceStart);
		DetectingPawn.Mesh.GetSocketWorldLocationAndRotation(B_R_Corner_Trace, TraceEnd);
		DetectingPawn.Trace(HitLoc, HitNormal, TraceEnd, TraceStart, true, , hi, /*TRACEFLAG_Bullet*/1);

		if(hi.Material != none) BackRightInfo =  GetRoadPositionInfo(hi.Material.Name, BackRightInfo);
		else ResetRoadPositionInfo(BackRightInfo);
	}

	UpdateDriveState();

	UpdateInsideRoadSituation();*/
}

//
function bool CheckMaterialName(Material mat)
{
	// проверяем, начинается ли имя материала с "4_polos_"
	if( OnCrossRoad(mat)  ||  OnRoad(mat) ) return true;
	else return false;
}

function bool Old_CheckMaterialName(name matName)
{
	// проверяем, начинается ли имя материала с "4_polos_"
	//if( OnCrossRoad(matName)  ||  OnRoad(matName) ) return true;
	//else return false;
}

function bool OnRoad(Material mat)
{
	local float val;
	if(mat.GetScalarParameterValue('RoadType', val))
		return true;
	else
		return false;
}

function bool Old_OnRoad(name matName)
{
	if(Left(string(matName), 8) == "4_polos_"   ||   Left(string(matName), 8) == "Asphalt_") return true;
	else return false;
}


function bool OnCrossRoad(Material mat)
{
	local float val;
	mat.GetScalarParameterValue('RoadType', val);
	if(val == 2)
		return true;
	else
		return false;
}

function bool Old_OnCrossRoad(name matName)
{
	if(Left(string(matName), 5) == "Per_M") return true;
	else return false;
}

function OnRoadPositionInfo GetRoadPositionInfo(Material mat, OnRoadPositionInfo prevRPI)
{
	local OnRoadPositionInfo rpi;
	local float val;

	if(CheckMaterialName(mat) == false)
	{
		// находимся вне дороги, выходим
		rpi.MajorRoadPos = ROADPOS_OFFROAD;
		return rpi;
	}
	else
	{
		if(OnCrossRoad(mat) == true)
		{
			// находимся на прекрестке
			rpi.MajorRoadPos = ROADPOS_ONROAD;
			rpi.MoreStrictRoadPos = ROADPOS_ONCROSSROAD;
			return rpi;
		}
		else
		{
			// находимся на дороге, получаем информацию о полосе	
			rpi.MajorRoadPos = ROADPOS_ONROAD;

			rpi.PrevRoadLineNumber = PrevRPI.ActualRoadLineNumber;
			rpi.PrevRoadLineSide = PrevRPI.ActualRoadLineSide;

			mat.GetScalarParameterValue('RoadPolosaName', val);

			rpi.ActualRoadLineNumber = int(val) / 2 + int(val) % 2;
			rpi.ActualRoadLineSide = val;

			// определяем, крайняя ли полоса в точке прикосновения
			if(mat.GetScalarParameterValue('lop', val))
			{
				rpi.LineOutsideParameter = int(val);
			}
			else
			{
				// не крайняя полоса
				rpi.LineOutsideParameter = 0;
			}

			return rpi;
		}
	}
}

function OnRoadPositionInfo Old_GetRoadPositionInfo(name matName, OnRoadPositionInfo prevRPI)
{
	/*local OnRoadPositionInfo rpi;
	local string str1;
	local array<string> strArr;

	if(CheckMaterialName(matName) == false)
	{
		// находимся вне дороги, выходим
		rpi.MajorRoadPos = ROADPOS_OFFROAD;
		return rpi;
	}
	else
	{
		if(OnCrossRoad(matName) == true)
		{
			// находимся на прекрестке
			rpi.MajorRoadPos = ROADPOS_ONROAD;
			rpi.MoreStrictRoadPos = ROADPOS_ONCROSSROAD;
			return rpi;
		}
		else
		{
			// находимся на дороге, получаем информацию о полосе
			str1 = Split(string(matName), "_M_", true);

			if(Locs(str1) == "p")
			{
				// находимся на паребрике
				rpi.MajorRoadPos = ROADPOS_OFFROAD;
				rpi.MoreStrictRoadPos = ROADPOS_ONPAREBRIK;
				return rpi;
			}
			
			rpi.MajorRoadPos = ROADPOS_ONROAD;
			strArr = SplitString(str1, "_");

			rpi.PrevRoadLineNumber = PrevRPI.ActualRoadLineNumber;
			rpi.PrevRoadLineSide = PrevRPI.ActualRoadLineSide;
			rpi.ActualRoadLineNumber = int(strArr[0]);
			rpi.ActualRoadLineSide = int(strArr[1]);

			return rpi;
		}
	}*/
}

//========================================================================================================
/** если число четное, возвращает true */
function bool IsEven(int n)
{
	if(n % 2 == 0) return true;
	else return false;
}

/** возвращает true, если по крайней мере один из крайних углов находится в противоположной стороне */
function bool IsOneOfCornersInCounterLineNumber()
{

}

function bool IsCompletelyOnEvenSide()
{
	if( IsEven(FrontLeftInfo.ActualRoadLineNumber) &&  
		IsEven(FrontRightInfo.ActualRoadLineNumber)  &&  
		IsEven(BackLeftInfo.ActualRoadLineNumber)  && 
		IsEven(BackRightInfo.ActualRoadLineNumber))
		return true;
	else
		return false;
}

function bool IsCompletelyOnOddSide()
{
	if( !IsEven(FrontLeftInfo.ActualRoadLineNumber) &&  
		!IsEven(FrontRightInfo.ActualRoadLineNumber)  &&  
		!IsEven(BackLeftInfo.ActualRoadLineNumber)  && 
		!IsEven(BackRightInfo.ActualRoadLineNumber))
		return true;
	else
		return false;
}

/** true, если все крайние углы объекта находятся на одной полосе движения */
function bool IsInSameLineNumber()
{
	if( FrontRightInfo.ActualRoadLineNumber == FrontLeftInfo.ActualRoadLineNumber &&
		FrontRightInfo.ActualRoadLineNumber == BackLeftInfo.ActualRoadLineNumber &&
		FrontRightInfo.ActualRoadLineNumber == BackRightInfo.ActualRoadLineNumber)
		return true;
	else
		return false;
}

/** true, если левые углы находятся на одной и той же стороне полосы движения */
function bool IsLeftSideInSameLineSide()
{
	if(FrontLeftInfo.ActualRoadLineSide == BackLeftInfo.ActualRoadLineSide) return true;
	else return false;
}

/** true, если правые углы находятся на одной и той же стороне полосы движения */
function bool IsRightSideInSameLineSide()
{
	if(FrontRightInfo.ActualRoadLineSide == BackRightInfo.ActualRoadLineSide) return true;
	else return false;
}

function bool IsObjectSidesInDiffrentLineSides()
{
	if( IsLeftSideInSameLineSide()  &&  
		IsRightSideInSameLineSide()  && 
		FrontRightInfo.ActualRoadLineSide != FrontLeftInfo.ActualRoadLineSide)
		return true;
	else return false;
}

function bool IsInCorrectDirection()
{
	if( // если левая и правая стороны объекта находятся на разных сторонах полосы
		IsLeftSideInSameLineSide()  &&  
		IsRightSideInSameLineSide()  && 
		FrontRightInfo.ActualRoadLineSide != FrontLeftInfo.ActualRoadLineSide &&
						
		// а также если левая сторона находится на стороне с номером "2"
		FrontLeftInfo.ActualRoadLineSide == 2
		)
		return true;
	else
		return false;
}

function bool IsCompletelyOnCrossroad()
{
	if(FrontLeftInfo.MoreStrictRoadPos == ROADPOS_ONCROSSROAD && 
		FrontRightInfo.MoreStrictRoadPos == ROADPOS_ONCROSSROAD &&
		BackLeftInfo.MoreStrictRoadPos == ROADPOS_ONCROSSROAD &&
		BackRightInfo.MoreStrictRoadPos == ROADPOS_ONCROSSROAD)
		return true;
	else return false;
}

/** true, если все углы объекта полностью находятся на четной или нечетной стороне */
function bool IsAllCornersInSameRoadSide()
{
	if(IsCompletelyOnEvenSide() || IsCompletelyOnOddSide()) return true;
	else return false;
}

function bool IsAnyOfCornersOnCrossroad()
{
	if( FrontLeftInfo.MoreStrictRoadPos == ROADPOS_ONCROSSROAD || 
		FrontRightInfo.MoreStrictRoadPos == ROADPOS_ONCROSSROAD ||
		BackLeftInfo.MoreStrictRoadPos == ROADPOS_ONCROSSROAD ||
		BackRightInfo.MoreStrictRoadPos == ROADPOS_ONCROSSROAD)
		return true;
	else return false;
}

function InroadState GetActualInroadState() { return ActualInroadState; }

function ChangeActualInroadState(InroadState is, optional bool callDlg = true)
{
	if(ActualInroadState == is)
		return;

	ActualInroadState = is;

	if(callDlg == false)
		return;

	// вызов делегатов, связанных с изменением состояния движения
	switch(is)
	{
	case RSD_INROADSTATE_ON_CORRECT_SIDE:
		break;

	case RSD_INROADSTATE_ON_WRONG_SIDE:
		ChangeTrafficLineState(RSD_TRAFFICLINESTATE_UNKNOWN);
		dlgOnDriveInWrongSide();
		break;

	case RSD_INROADSTATE_GOING_TO_WRONG_SIDE:
		ChangeTrafficLineState(RSD_TRAFFICLINESTATE_UNKNOWN);
		dlgOnDriveToWrongSide();
		break;

	case RSD_INROADSTATE_GOING_TO_CORRECT_SIDE:
		break;

	case RSD_INROADSTATE_UNKNOWN:
		ActualInroadSide = RSD_SIDE_UNKNOWN;
		ChangeTrafficLineState(RSD_TRAFFICLINESTATE_UNKNOWN);
		break;
	}
}

/** возвращает true, если левые и правые углы объекта находятся на одинаковой полуполосе */
function bool IsOnSameRoadLineSide()
{
	if( FrontLeftInfo.ActualRoadLineSide == FrontRightInfo.ActualRoadLineSide &&
		FrontLeftInfo.ActualRoadLineSide == BackLeftInfo.ActualRoadLineSide &&
		FrontLeftInfo.ActualRoadLineSide == BackRightInfo.ActualRoadLineSide)
	{
		return true;
	}
	else
		return false;
}


function bool AnyTwoTraceStayInDeffrentLOP()
{
	local int cnt1, cnt2;

	if(FrontLeftInfo.LineOutsideParameter == 1)
		cnt1++;
	else if(FrontLeftInfo.LineOutsideParameter == 2)
		cnt2++;


	if(FrontRightInfo.LineOutsideParameter == 1)
		cnt1++;
	else if(FrontLeftInfo.LineOutsideParameter == 2)
		cnt2++;


	if(BackLeftInfo.LineOutsideParameter == 1)
		cnt1++;
	else if(FrontLeftInfo.LineOutsideParameter == 2)
		cnt2++;


	if(BackRightInfo.LineOutsideParameter == 1)
		cnt1++;
	else if(FrontLeftInfo.LineOutsideParameter == 2)
		cnt2++;


	if(CenterInfo.LineOutsideParameter == 1)
		cnt1++;
	else if(FrontLeftInfo.LineOutsideParameter == 2)
		cnt2++;

	//
	if(cnt1 != 0  &&  cnt2 != 0)
		return true;
	else
		return false;
}

function UpdateInsideRoadSituation()
{
	// обновляем состояние только если объект находится полностью на дороге
	if(ActualDriveState == RSD_DRIVESTATE_DRIVING_ON_ROAD)
	{
		// проверяем, не находимся ли мы на перекрестке
		if(IsCompletelyOnCrossroad())
		{
			// если да, меняем позицию внутри дороги как "неизвестно"
			ChangeActualInroadState(RSD_INROADSTATE_UNKNOWN);
			return;
		}

		switch(ActualInroadState)
		{
		case RSD_INROADSTATE_ON_CORRECT_SIDE:
			// едем по правильной стороне дороги

			// проверяем, не выезжает ли объект на встречную полосу
			if(IsCompletelyOnRoad() 
				&& IsAnyOfCornersOnCrossroad() == false 
				&& AnyTwoTraceStayInDeffrentLOP() == true
				)
			{
				
				ChangeActualInroadState(RSD_INROADSTATE_GOING_TO_WRONG_SIDE);
			}
			else if(FrontLeftInfo.ActualRoadLineSide < FrontRightInfo.ActualRoadLineSide
					&& IsAnyOfCornersOnCrossroad() == false)
			{
				// езда по встречке
				ChangeActualInroadState(RSD_INROADSTATE_ON_WRONG_SIDE);
			}
			break;

		case RSD_INROADSTATE_ON_WRONG_SIDE:
			// если объект оказался на встречке, возможно он решил развернуться в неположенном месте
			// пересекнув сплошную. Пытаемся отловить это:
			if(IsInSameLineNumber())
			{
				if(IsObjectSidesInDiffrentLineSides() == true)
				{
					if(IsEven(FrontLeftInfo.ActualRoadLineSide))
					{
						ChangeActualInroadState(RSD_INROADSTATE_ON_CORRECT_SIDE);
						dlgOnStartDriveInCorrentDirectionWhileInWrongSide();
					}
				}
			}

			break;

		case RSD_INROADSTATE_GOING_TO_WRONG_SIDE:
			if(IsObjectSidesInDiffrentLineSides())
			{
				if(!IsEven(FrontLeftInfo.ActualRoadLineSide))
				{
					// если левая сторона находится на нечетной полуполосе, а правая - на четной
					// то это значит что мы движемся по встречке
					ChangeActualInroadState(RSD_INROADSTATE_ON_WRONG_SIDE);
				}
				else
				{
					ChangeActualInroadState(RSD_INROADSTATE_ON_CORRECT_SIDE);
				}
			}
			else
			{
				// углы объекта находятся на одной полуполосе, пока ничего не делаем
			}
			break;

		case RSD_INROADSTATE_GOING_TO_CORRECT_SIDE:
			break;

		case RSD_INROADSTATE_UNKNOWN:
			// начинаем проверять "устойчивое" положение объекта на дороге 
			// если полуполоса на левой стороне объекта нмеет больший номер, чем на правой, 
			// то объект движется по попутному движению
			if(IsObjectSidesInDiffrentLineSides())  
			{
					if(FrontLeftInfo.ActualRoadLineSide > FrontRightInfo.ActualRoadLineSide)
					{
						// попутка
						ChangeActualInroadState(RSD_INROADSTATE_ON_CORRECT_SIDE);
					}
					else if(FrontLeftInfo.ActualRoadLineSide < FrontRightInfo.ActualRoadLineSide)
					{
						// езда по встречке
						ChangeActualInroadState(RSD_INROADSTATE_ON_WRONG_SIDE);
					}
					else
					{
						// выезд на встречку
						ChangeActualInroadState(RSD_INROADSTATE_GOING_TO_WRONG_SIDE);
					}
			}
			break;
		}

		// определяем сторону дороги (четная или нечетная)
		UpdateInroadSideState();

		// определяем состояние движения объекта по полосам
		DetectStateBetweenRoadLines();
	}
}

function Old_UpdateInsideRoadSituation()
{
	// обновляем состояние только если объект находится полностью на дороге
	if(ActualDriveState == RSD_DRIVESTATE_DRIVING_ON_ROAD)
	{
		switch(ActualInroadState)
		{
		case RSD_INROADSTATE_ON_CORRECT_SIDE:
			// едем по правильной стороне дороги

			// проверяем, не находимся ли мы на перекрестке
			if(IsCompletelyOnCrossroad())
			{
				// если да, меняем позицию внутри дороги как "неизвестно"
				ChangeActualInroadState(RSD_INROADSTATE_UNKNOWN);
			}

			// проверяем, не выезжает ли объект на встречную полосу
			if(IsAnyOfCornersOnCrossroad() == false && IsAllCornersInSameRoadSide() == false  &&  IsCompletelyOnRoad())
			{
				// если выезжает, считаем, что объект выезжает на встречку
				ChangeActualInroadState(RSD_INROADSTATE_GOING_TO_WRONG_SIDE);
			}
			break;

		case RSD_INROADSTATE_ON_WRONG_SIDE:
			// если объект оказался на встречке, возможно он решил развернуться в неположенном месте
			// пересекнув сплошную. Пытаемся отловить это:
			if(IsInSameLineNumber())
			{
				if(IsObjectSidesInDiffrentLineSides() == true)
				{
					if(FrontLeftInfo.ActualRoadLineSide == 2)
					{
						ChangeActualInroadState(RSD_INROADSTATE_ON_CORRECT_SIDE);
						dlgOnStartDriveInCorrentDirectionWhileInWrongSide();
					}
					//else ChangeActualInroadState(RSD_INROADSTATE_ON_WRONG_SIDE);
				}
			}

			break;

		case RSD_INROADSTATE_GOING_TO_WRONG_SIDE:
			// если выезжаем на встречку из четной стороны
			if(ActualInroadSide == RSD_SIDE_EVEN)
			{
				// если оказались полностью на нечетной сотороне (противоположной)
				// - считаем, что полностью выехали на встречку
				if(IsCompletelyOnOddSide())
				{
					ChangeActualInroadState(RSD_INROADSTATE_ON_WRONG_SIDE);
				}
				// если оказались полностью на четной стороне (из которой выехали)
				// - считаем, что вернулись на правильную полосу
				else if(IsCompletelyOnEvenSide())
				{
					ChangeActualInroadState(RSD_INROADSTATE_ON_CORRECT_SIDE);
				}
			}
			// если выезжаем на встречку из нечетной стороны
			else if(ActualInroadSide == RSD_SIDE_ODD)
			{
				// если оказались полностью на нечетной сотороне (из которой выехали)
				if(IsCompletelyOnOddSide())
				{
					ChangeActualInroadState(RSD_INROADSTATE_ON_CORRECT_SIDE);
				}
				// если оказались полностью на четной стороне (противоположной)
				else if(IsCompletelyOnEvenSide())
				{
					ChangeActualInroadState(RSD_INROADSTATE_ON_WRONG_SIDE);
				}
			}
			else
			{
				// если попали сюда, то скорее всего мы выезжаем на перекресток 
				// или едем по границе пересечения четной и нечетной сторон
			}

			break;

		case RSD_INROADSTATE_GOING_TO_CORRECT_SIDE:
			break;

		case RSD_INROADSTATE_UNKNOWN:
			// состояние езды внутри дороги не известно, пытаемся его определить
			if(IsCompletelyOnEvenSide())
			{
				// если находимся на четной стороне дороги
				// то начинаем проверять на "устойчивое" положение объекта внутри дороги
				// устойчивое положение - когда все углы объекта находятся на одной полосе движения
				if(IsInSameLineNumber())
				{
					if(IsObjectSidesInDiffrentLineSides() == true)
					{
						if(FrontLeftInfo.ActualRoadLineSide == 2)
						{
							ChangeActualInroadState(RSD_INROADSTATE_ON_CORRECT_SIDE);
						}
						else ChangeActualInroadState(RSD_INROADSTATE_ON_WRONG_SIDE);
					}
				}
			}
			else if(IsCompletelyOnOddSide())
			{
				if(IsInSameLineNumber())
				{
					if(IsObjectSidesInDiffrentLineSides() == true)
					{
						if(FrontLeftInfo.ActualRoadLineSide == 2)
						{
							ChangeActualInroadState(RSD_INROADSTATE_ON_CORRECT_SIDE);
						}
						else ChangeActualInroadState(RSD_INROADSTATE_ON_WRONG_SIDE);
					}
				}
			}
			else
			{
				//ActualInroadSide = RSD_SIDE_UNKNOWN;
				// если попали сюда, значит мы находимся на пересечении четной и нечетной дорог
				// или на перекрестке
			}
			break;
		}

		// определяем сторону дороги (четная или нечетная)
		UpdateInroadSideState();

		// определяем состояние движения объекта по полосам
		DetectStateBetweenRoadLines();
	}
}

function UpdateInroadSideState()
{
	// если хотя бы один из углов находится на перекрестке, считаем положение объекта как "неизвестное"
	if(IsAnyOfCornersOnCrossroad())
		ActualInroadSide = RSD_SIDE_UNKNOWN;

	else if(IsCompletelyOnOddSide())
	{
		ActualInroadSide = RSD_SIDE_ODD;
	}
	else if(IsCompletelyOnEvenSide())
	{
		ActualInroadSide = RSD_SIDE_EVEN;
	}
}

function RSD_TrafficLineMoveState GetTrafficLineMoveState() { return ActualTrafficLineState; }
function int GetActualTrafficLineNumber() { return CurrentTrafficLineNumber; }

function ChangeTrafficLineState(RSD_TrafficLineMoveState st, optional bool callDlg = true)
{
	ActualTrafficLineState = st;

	if(!callDlg)
		return;

	switch (ActualTrafficLineState)
	{
	case RSD_TRAFFICLINESTATE_UNKNOWN:
		CurrentTrafficLineNumber = 0;
		break;

	case RSD_TRAFFICLINESTATE_ONSAMELINE:
		CurrentTrafficLineNumber = FrontLeftInfo.ActualRoadLineNumber;
		break;

	case RSD_TRAFFICLINESTATE_MOVETO_RIGHT:
		dlgOnMoveToRight();
		break;

	case RSD_TRAFFICLINESTATE_MOVETO_LEFT:
		dlgOnMoveToLeft();
		break;
	}
}

/** эта функция обновляет положение между полосами 
 *  состояние изменяется на RSD_TRAFFICLINESTATE_ONSAMELINE при вызове ChangeInroadStrate() c пар-м RSD_INROADSTATE_ON_CORRECT_SIDE
 *  состояние изменяется на RSD_TRAFFICLINESTATE_UNKNOWN при вызове ChangeInroadStrate() c пар-м RSD_INROADSTATE_UNKNOWN
 *  */
function DetectStateBetweenRoadLines()
{
	// обновляем состояние только если едем по правильной стороне дороги
	if(ActualInroadState == RSD_INROADSTATE_ON_CORRECT_SIDE)
	{
		switch (ActualTrafficLineState)
		{
		case RSD_TRAFFICLINESTATE_UNKNOWN:
			// пытаемся определить, находимся ли мы на одной полосе
			if(IsInSameLineNumber())
			{
				ChangeTrafficLineState(RSD_TRAFFICLINESTATE_ONSAMELINE);
			}
			break;

		case RSD_TRAFFICLINESTATE_ONSAMELINE:
			// проверка на перестроение на другую полосу ВЛЕВО
			if(((FrontLeftInfo.ActualRoadLineNumber > FrontLeftInfo.PrevRoadLineNumber)  &&  (FrontLeftInfo.PrevRoadLineNumber != 0))   ||
				(BackLeftInfo.ActualRoadLineNumber > BackLeftInfo.PrevRoadLineNumber)  &&  (BackLeftInfo.PrevRoadLineNumber != 0))
			{
				//if(IsEven(FrontLeftInfo.PrevRoadLineNumber) && IsEven(BackLeftInfo.PrevRoadLineNumber))
					ChangeTrafficLineState(RSD_TRAFFICLINESTATE_MOVETO_LEFT);	
			}

			// проверка на перестроение на другую полосу ВПРАВО
			if(((FrontRightInfo.ActualRoadLineNumber < FrontRightInfo.PrevRoadLineNumber)  &&  (FrontRightInfo.PrevRoadLineNumber != 0)  &&  (FrontRightInfo.LineOutsideParameter == 0))   ||
				(BackRightInfo.ActualRoadLineNumber < BackRightInfo.PrevRoadLineNumber)  &&  (BackRightInfo.PrevRoadLineNumber != 0)  &&  (BackRightInfo.LineOutsideParameter == 0))
			{
				ChangeTrafficLineState(RSD_TRAFFICLINESTATE_MOVETO_RIGHT);
			}
			break;

		case RSD_TRAFFICLINESTATE_MOVETO_RIGHT:
			// проверяем полностью ли перестроился объект
			if(IsObjectSidesInDiffrentLineSides() == true   &&   !IsEven(FrontRightInfo.ActualRoadLineSide))
			{
				if(FrontRightInfo.ActualRoadLineNumber < CurrentTrafficLineNumber)
				{
					// перестроился вправо
					ChangeTrafficLineState(RSD_TRAFFICLINESTATE_ONSAMELINE);
					dlgOnCompleteMovementFromRight();
					
				}
				else if(FrontRightInfo.ActualRoadLineNumber == CurrentTrafficLineNumber)
				{
					// вернулся на полосу, из которой начал перестроение
					ChangeTrafficLineState(RSD_TRAFFICLINESTATE_ONSAMELINE);
				}
				else
				{
					// форс-мажорная ситуация, сюда мы не должны попадать
					`warn("RSD_TRAFFICLINESTATE_MOVETO_RIGHT unexpected situation");
				}
			}
			break;

		case RSD_TRAFFICLINESTATE_MOVETO_LEFT:
			// проверяем полностью ли перестроился объект
			if(IsObjectSidesInDiffrentLineSides() == true   &&   IsEven(FrontLeftInfo.ActualRoadLineSide))
			{
				if(FrontLeftInfo.ActualRoadLineNumber > CurrentTrafficLineNumber)
				{
					// перестроился влево
					ChangeTrafficLineState(RSD_TRAFFICLINESTATE_ONSAMELINE);
					dlgOnCompleteMovementFromLeft();
				}
				else if(FrontLeftInfo.ActualRoadLineNumber == CurrentTrafficLineNumber)
				{
					// вернулся на полосу, из которой начал перестроение
					ChangeTrafficLineState(RSD_TRAFFICLINESTATE_ONSAMELINE);
				}
				else
				{
					// форс-мажорная ситуация, сюда мы не должны попадать
					`warn("RSD_TRAFFICLINESTATE_MOVETO_LEFT unexpected situation");
				}
			}
			break;
		}
		
	}

}

function Old_DetectStateBetweenRoadLines()
{
	// обновляем состояние только если едем по правильной стороне дороги
	if(ActualInroadState == RSD_INROADSTATE_ON_CORRECT_SIDE)
	{
		switch (ActualTrafficLineState)
		{
		case RSD_TRAFFICLINESTATE_UNKNOWN:
			break;

		case RSD_TRAFFICLINESTATE_ONSAMELINE:
			// проверка на перестроение на другую полосу ВЛЕВО
			if(((FrontLeftInfo.ActualRoadLineNumber > FrontLeftInfo.PrevRoadLineNumber)  &&  (FrontLeftInfo.PrevRoadLineNumber != 0))   ||
				(BackLeftInfo.ActualRoadLineNumber > BackLeftInfo.PrevRoadLineNumber)  &&  (BackLeftInfo.PrevRoadLineNumber != 0))
			{
				if(IsCompletelyOnEvenSide())
				{
					if(IsEven(FrontLeftInfo.PrevRoadLineNumber) && IsEven(BackLeftInfo.PrevRoadLineNumber))
						ChangeTrafficLineState(RSD_TRAFFICLINESTATE_MOVETO_LEFT);
				}
				else if(IsCompletelyOnOddSide())
				{
					if(!IsEven(FrontLeftInfo.PrevRoadLineNumber) && !IsEven(BackLeftInfo.PrevRoadLineNumber))
						ChangeTrafficLineState(RSD_TRAFFICLINESTATE_MOVETO_LEFT);
				}
					
			}

			// проверка на перестроение на другую полосу ВПРАВО
			if(((FrontRightInfo.ActualRoadLineNumber < FrontRightInfo.PrevRoadLineNumber)  &&  (FrontRightInfo.PrevRoadLineNumber != 0))   ||
				(BackRightInfo.ActualRoadLineNumber < BackRightInfo.PrevRoadLineNumber)  &&  (BackRightInfo.PrevRoadLineNumber != 0))
			{
				ChangeTrafficLineState(RSD_TRAFFICLINESTATE_MOVETO_RIGHT);
			}
			break;

		case RSD_TRAFFICLINESTATE_MOVETO_RIGHT:
			// проверяем полностью ли перестроился объект
			if(IsObjectSidesInDiffrentLineSides() == true   &&   FrontRightInfo.ActualRoadLineSide == 1)
			{
				if(FrontRightInfo.ActualRoadLineNumber < CurrentTrafficLineNumber)
				{
					// перестроился вправо
					ChangeTrafficLineState(RSD_TRAFFICLINESTATE_ONSAMELINE);
					dlgOnCompleteMovementFromRight();
					
				}
				else if(FrontRightInfo.ActualRoadLineNumber == CurrentTrafficLineNumber)
				{
					// вернулся на полосу, из которой начал перестроение
					ChangeTrafficLineState(RSD_TRAFFICLINESTATE_ONSAMELINE);
				}
				else
				{
					// форс-мажорная ситуация, сюда мы не должны попадать
					`warn("RSD_TRAFFICLINESTATE_MOVETO_RIGHT unexpected situation");
				}
			}
			break;

		case RSD_TRAFFICLINESTATE_MOVETO_LEFT:
			// проверяем полностью ли перестроился объект
			if(IsObjectSidesInDiffrentLineSides() == true   &&   FrontLeftInfo.ActualRoadLineSide == 2)
			{
				if(FrontLeftInfo.ActualRoadLineNumber > CurrentTrafficLineNumber)
				{
					// перестроился влево
					ChangeTrafficLineState(RSD_TRAFFICLINESTATE_ONSAMELINE);
					dlgOnCompleteMovementFromLeft();
				}
				else if(FrontLeftInfo.ActualRoadLineNumber == CurrentTrafficLineNumber)
				{
					// вернулся на полосу, из которой начал перестроение
					ChangeTrafficLineState(RSD_TRAFFICLINESTATE_ONSAMELINE);
				}
				else
				{
					// форс-мажорная ситуация, сюда мы не должны попадать
					`warn("RSD_TRAFFICLINESTATE_MOVETO_LEFT unexpected situation");
				}
			}
			break;
		}
		
	}

}

simulated function DrawDebug(HUD H)
{
	H.Canvas.SetDrawColor(255, 0, 0, 255);
	H.Canvas.SetPos(14, 12);
	H.Canvas.DrawText("Actual Drive State: " $ ActualDriveState);

	H.Canvas.SetPos(14, 24);
	H.Canvas.DrawText("Actual Inroad State: " $ ActualInroadState);

	H.Canvas.SetPos(14, 36);
	H.Canvas.DrawText("Actual Inroad Side: " $ ActualInroadSide);

	H.Canvas.SetPos(14, 48);
	H.Canvas.DrawText("ActualTrafficLineState: " $ ActualTrafficLineState);




	H.Canvas.SetPos(14, 60);
	H.Canvas.DrawText("FrontLeftLine: " $ FrontLeftInfo.ActualRoadLineNumber);

	H.Canvas.SetPos(14, 72);
	H.Canvas.DrawText("FrontLeftSide: " $ FrontLeftInfo.ActualRoadLineSide);

	H.Canvas.SetPos(14, 84);
	H.Canvas.DrawText("FrontRightLine: " $ FrontRightInfo.ActualRoadLineNumber);

	H.Canvas.SetPos(14, 96);
	H.Canvas.DrawText("FrontRightSide: " $ FrontRightInfo.ActualRoadLineSide);


	H.Canvas.SetPos(14, 108);
	H.Canvas.DrawText("BackLeftLine: " $ BackLeftInfo.ActualRoadLineNumber);

	H.Canvas.SetPos(14, 120);
	H.Canvas.DrawText("BackLeftSide: " $ BackLeftInfo.ActualRoadLineSide);

	H.Canvas.SetPos(14, 132);
	H.Canvas.DrawText("BackRightLine: " $ BackRightInfo.ActualRoadLineNumber);

	H.Canvas.SetPos(14, 144);
	H.Canvas.DrawText("BackRightSide: " $ BackRightInfo.ActualRoadLineSide);


	H.Canvas.SetPos(14, 156);
	H.Canvas.DrawText("Center: " $ CenterInfo.ActualRoadLineSide);
}



DefaultProperties
{
	ActualInroadState = RSD_INROADSTATE_UNKNOWN
	ActualDriveState = RSD_DRIVESTATE_UNKNOWN
	WaitTimeBeforeValidateDriveState = 2.0
	ActualInroadSide = RSD_SIDE_UNKNOWN
	ActualTrafficLineState = RSD_TRAFFICLINESTATE_UNKNOWN

	F_L_Corner = F_L_Corner
	F_L_Corner_Trace = F_L_Corner_Trace
	F_R_Corner = F_R_Corner
	F_R_Corner_Trace = F_R_Corner_Trace
	B_L_Corner = B_L_Corner
	B_L_Corner_Trace = B_L_Corner_Trace
	B_R_Corner = B_R_Corner
	B_R_Corner_Trace = B_R_Corner_Trace

	TraceEndZ = 500
	TraceStartZ = 1000
}

/*
	switch(ActualInroadState)
	{
	case RSD_INROADSTATE_ON_CORRECT_SIDE:
		break;

	case RSD_INROADSTATE_ON_WRONG_SIDE:
		break;

	case RSD_INROADSTATE_GOING_TO_WRONG_SIDE:
		break;

	case RSD_INROADSTATE_GOING_TO_CORRECT_SIDE:
		break;

	case RSD_INROADSTATE_UNKNOWN:
		break;
	}*/