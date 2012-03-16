/** ����� ���������� ��������� ������� �� ������ � �������� ��� ��������
 *  ��� ����������� ����������� ������ ����������� ��������� ����������:
 *    - � �������������� ����� ������ ������� ��� ������, ����� ������� ����� ������� � defaultproperties
 *    - ������ ������ ������������� ������������ �������, ����� ��� Trace ���� ���������� �����������
 *    - ����� ���������� ����������� ����� ������ ���������� � 4_polos
 *    - ����� ���������� ����������� ������ ���������� � Per_M
 *    
 *    (��������� ��������� ��������� � ������ "��� ������")
 *
 *  */
class Zarnitza_OnRoadSituationDetector extends Object;

/** ��������� ����� ������� */
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

/** �������� ��������� ��� ���� �� ������� �������� �� ���������� ������� �������� ����� */
enum RSD_TrafficLineMoveState
{
	RSD_TRAFFICLINESTATE_UNKNOWN,
	RSD_TRAFFICLINESTATE_ONSAMELINE,
	RSD_TRAFFICLINESTATE_MOVETO_LEFT,
	RSD_TRAFFICLINESTATE_MOVETO_RIGHT
};

enum RSD_Side { RSD_SIDE_EVEN, RSD_SIDE_ODD, RSD_SIDE_UNKNOWN };

/** ����� ������� */
var name F_L_Corner;
var name F_L_Corner_Trace;
var name F_R_Corner;
var name F_R_Corner_Trace;
var name B_L_Corner;
var name B_L_Corner_Trace;
var name B_R_Corner;
var name B_R_Corner_Trace;

/** ���������, ����������� ��������� ������ ���� ������� ������������ ������ */
struct OnRoadPositionInfo
{
	var RoadPositions MajorRoadPos;
	var RoadPositions MoreStrictRoadPos;
	var int ActualRoadLineNumber;                 // ������� ����� ������ (������ � ��������)
	var int ActualRoadLineSide;                   // ������� ��������� ����� ������ (��� ����������� ����������� �������� �� ������)
	var int PrevRoadLineNumber;
	var int PrevRoadLineSide;

	var int LineOutsideParameter;                 // ��������, ������������ ����� ������, ���� ��� �������

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


/** ����, ��������� �������� ������������� */
var Pawn DetectingPawn;

// ���� ��������� ��������. ��������� �������� �������� ������� �� ������
enum RSD_DriveStates
{
	RSD_DRIVESTATE_UNKNOWN,                     // ����������
	RSD_DRIVESTATE_DRIVING_TO_OFFROAD,          // ���������� �������� �� �������
	RSD_DRIVESTATE_DRIVING_TO_ROAD,             // ���������� �������� �� �������� �����
	RSD_DRIVESTATE_DRIVING_ON_ROAD,             // ���������� ���� �� ������
	RSD_DRIVESTATE_DRIVING_ON_OFFROAD,          // ���������� ���� ��� �������� �����
};

/** ������� ��������� �������� ���������� */
var RSD_DriveStates ActualDriveState;

/** ���� �������� ������������� �������� �������� ��������� �� ������. 
 *  (��������, ���� ���������� ������ ����� ������ �� �������, 
 *  ���������� ����������� ��� ����� ��������� �����, � �� ������ ��������� �����.
 *  ���� ���� �������, ����� ��������� � �������� �������������. ���� ���������� ������������ 
 *  �� ������ �� ��������� ������� ��������, �� ��������� �������� �������) */
var bool bPendingValidateDriveState;

/** �����, �� ��������� �������� ����������� ������� ������������� ��������� ��������� �� ����� */
var float LastPendingStartTime;

var float WaitTimeBeforeValidateDriveState;



var private InroadState ActualInroadState;
var bool bIsInroadPositionValidated;

/** ������� ������� ������, �� ������� ��������� ������ */
var private RSD_Side ActualInroadSide;

var private RSD_TrafficLineMoveState ActualTrafficLineState;

/** ������� ����� ������ �������� */
var private int CurrentTrafficLineNumber;

var float TraceStartZ;
var float TraceEndZ;



// ��������, ������������ ��� �������� ��������� ��������
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

// ���� ������� ����������, ����� ������, �������� �� ��������, ������������� �� ������
// � �������� �������� � ���������� ����������� (��������, ��������������� � ������������ �����, ��������� ��������)
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

			// ����� ����� �������� �� �������, ����������� ��������� ������ ������ ��� "����������"
			ChangeActualInroadState(RSD_INROADSTATE_UNKNOWN);

			ActualInroadSide = RSD_SIDE_UNKNOWN;

			break;
		//------------------------------------------------------------------------------
		case RSD_DRIVESTATE_DRIVING_TO_OFFROAD:
			dlgOnChangeDriveState_ToOffroad();

			// ����� ����� �������� �� �������, ����������� ��������� ������ ������ ��� "����������"
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
		// ����� �������� �������
		switch(ActualDriveState)
		{
		case RSD_DRIVESTATE_DRIVING_ON_ROAD:
			// ���������, ��������� �� ���� �� ����� ��� ������
			if(IsOneOfCornersOFFROAD())
			{
				// ���������, ��������� �� ������ ��������� ��� ������
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
				// �� ��������� �������� ������� �� ������
			}
			break;

		//------------------------------------------------------------------------------
		case RSD_DRIVESTATE_DRIVING_ON_OFFROAD:
			// ���������, ��������� �� ���� �� ����� �� ������
			if(IsOneOfCornersONROAD())
			{
				// ���������, ��������� �� ������ ��������� �� ������
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
				// �� ��������� �������� ������� ��� ������
			}
			break;
		//------------------------------------------------------------------------------
		case RSD_DRIVESTATE_DRIVING_TO_OFFROAD:
			// ���� �� �������� �� ������
			`log("RSD_DRIVESTATE_DRIVING_TO_OFFROAD not expecting here");
			break;

		//------------------------------------------------------------------------------
		case RSD_DRIVESTATE_DRIVING_TO_ROAD:
			// ���� �� �������� �� ������
			`log("RSD_DRIVESTATE_DRIVING_TO_ROAD not expecting here");
			break;

		//------------------------------------------------------------------------------
		case RSD_DRIVESTATE_UNKNOWN:
			// ���� �� �������� �� ������
			`log("RSD_DRIVESTATE_UNKNOWN not expecting here");
			break;

		}

		// ��������� ������� �������������
		bPendingValidateDriveState = false;
	}
	else
	{
		// ����� �������� �� �������
	}
}

function UpdateDriveState()
{
	switch(ActualDriveState)
	{
	case RSD_DRIVESTATE_DRIVING_ON_ROAD:
		// ���������, ��������� �� ���� �� ����� ��� ������
		if(IsOneOfCornersOFFROAD()   &&   bPendingValidateDriveState == false)
		{
			bPendingValidateDriveState = true;
			LastPendingStartTime = DetectingPawn.WorldInfo.TimeSeconds;
		}
		break;

	case RSD_DRIVESTATE_DRIVING_ON_OFFROAD:
		// ���������, ��������� �� ���� �� ����� �� ������
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
		// ���� �� �����, ��� ��������� ������, ����������:
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
			// ����������� ��������� ��������, ��������� ��� "����� �� �������� �����"
			ChangeDriveState(RSD_DRIVESTATE_DRIVING_TO_ROAD);
		}
		break;

	}

	if(bPendingValidateDriveState)
		ValidateDriveState();
}

/** ������� ��������� �������  ��������� ��������� ������� ����� ������� ������������ ������ */ 
function Update()
{
	local Vector TraceStart, TraceEnd, HitNormal, HitLoc;
	local TraceHitInfo hi;

	if(DetectingPawn.Mesh != none)
	{
		// �������� �����
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

		// �������� ������
		DetectingPawn.Mesh.GetSocketWorldLocationAndRotation(F_R_Corner, TraceStart);
		//DetectingPawn.Mesh.GetSocketWorldLocationAndRotation(F_R_Corner_Trace, TraceEnd);
		TraceEnd = TraceStart;
		TraceStart.Z = TraceStartZ;
		TraceEnd.Z = TraceEndZ;
		DetectingPawn.Trace(HitLoc, HitNormal, TraceEnd, TraceStart, true, , hi, /*TRACEFLAG_Bullet*/1);

		if(hi.Material != none) FrontRightInfo =  GetRoadPositionInfo(hi.Material, FrontRightInfo);
		else ResetRoadPositionInfo(FrontRightInfo);


		// ������ �����
		DetectingPawn.Mesh.GetSocketWorldLocationAndRotation(B_L_Corner, TraceStart);
		//DetectingPawn.Mesh.GetSocketWorldLocationAndRotation(B_L_Corner_Trace, TraceEnd);
		TraceEnd = TraceStart;
		TraceStart.Z = TraceStartZ;
		TraceEnd.Z = TraceEndZ;
		DetectingPawn.Trace(HitLoc, HitNormal, TraceEnd, TraceStart, true, , hi, /*TRACEFLAG_Bullet*/1);

		if(hi.Material != none) BackLeftInfo =  GetRoadPositionInfo(hi.Material, BackLeftInfo);
		else ResetRoadPositionInfo(BackLeftInfo);


		// ������ ������
		DetectingPawn.Mesh.GetSocketWorldLocationAndRotation(B_R_Corner, TraceStart);
		//DetectingPawn.Mesh.GetSocketWorldLocationAndRotation(B_R_Corner_Trace, TraceEnd);
		TraceEnd = TraceStart;
		TraceStart.Z = TraceStartZ;
		TraceEnd.Z = TraceEndZ;
		DetectingPawn.Trace(HitLoc, HitNormal, TraceEnd, TraceStart, true, , hi, /*TRACEFLAG_Bullet*/1);

		if(hi.Material != none) BackRightInfo =  GetRoadPositionInfo(hi.Material, BackRightInfo);
		else ResetRoadPositionInfo(BackRightInfo);

		// �����
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

/** ������� ��������� �������  ��������� ��������� ������� ����� ������� ������������ ������ */ 
function Old_Update()
{
	/*local Vector TraceStart, TraceEnd, HitNormal, HitLoc;
	local TraceHitInfo hi;

	if(DetectingPawn.Mesh != none)
	{
		// �������� �����
		DetectingPawn.Mesh.GetSocketWorldLocationAndRotation(F_L_Corner, TraceStart);
		DetectingPawn.Mesh.GetSocketWorldLocationAndRotation(F_L_Corner_Trace, TraceEnd);
		DetectingPawn.Trace(HitLoc, HitNormal, TraceEnd, TraceStart, true, , hi, /*TRACEFLAG_Bullet*/1);

		if(hi.Material != none) FrontLeftInfo =  GetRoadPositionInfo(hi.Material.Name, FrontLeftInfo);
		else ResetRoadPositionInfo(FrontLeftInfo);

		// �������� ������
		DetectingPawn.Mesh.GetSocketWorldLocationAndRotation(F_R_Corner, TraceStart);
		DetectingPawn.Mesh.GetSocketWorldLocationAndRotation(F_R_Corner_Trace, TraceEnd);
		DetectingPawn.Trace(HitLoc, HitNormal, TraceEnd, TraceStart, true, , hi, /*TRACEFLAG_Bullet*/1);

		if(hi.Material != none) FrontRightInfo =  GetRoadPositionInfo(hi.Material.Name, FrontRightInfo);
		else ResetRoadPositionInfo(FrontRightInfo);


		// ������ �����
		DetectingPawn.Mesh.GetSocketWorldLocationAndRotation(B_L_Corner, TraceStart);
		DetectingPawn.Mesh.GetSocketWorldLocationAndRotation(B_L_Corner_Trace, TraceEnd);
		DetectingPawn.Trace(HitLoc, HitNormal, TraceEnd, TraceStart, true, , hi, /*TRACEFLAG_Bullet*/1);

		if(hi.Material != none) BackLeftInfo =  GetRoadPositionInfo(hi.Material.Name, BackLeftInfo);
		else ResetRoadPositionInfo(BackLeftInfo);


		// ������ ������
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
	// ���������, ���������� �� ��� ��������� � "4_polos_"
	if( OnCrossRoad(mat)  ||  OnRoad(mat) ) return true;
	else return false;
}

function bool Old_CheckMaterialName(name matName)
{
	// ���������, ���������� �� ��� ��������� � "4_polos_"
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
		// ��������� ��� ������, �������
		rpi.MajorRoadPos = ROADPOS_OFFROAD;
		return rpi;
	}
	else
	{
		if(OnCrossRoad(mat) == true)
		{
			// ��������� �� ����������
			rpi.MajorRoadPos = ROADPOS_ONROAD;
			rpi.MoreStrictRoadPos = ROADPOS_ONCROSSROAD;
			return rpi;
		}
		else
		{
			// ��������� �� ������, �������� ���������� � ������	
			rpi.MajorRoadPos = ROADPOS_ONROAD;

			rpi.PrevRoadLineNumber = PrevRPI.ActualRoadLineNumber;
			rpi.PrevRoadLineSide = PrevRPI.ActualRoadLineSide;

			mat.GetScalarParameterValue('RoadPolosaName', val);

			rpi.ActualRoadLineNumber = int(val) / 2 + int(val) % 2;
			rpi.ActualRoadLineSide = val;

			// ����������, ������� �� ������ � ����� �������������
			if(mat.GetScalarParameterValue('lop', val))
			{
				rpi.LineOutsideParameter = int(val);
			}
			else
			{
				// �� ������� ������
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
		// ��������� ��� ������, �������
		rpi.MajorRoadPos = ROADPOS_OFFROAD;
		return rpi;
	}
	else
	{
		if(OnCrossRoad(matName) == true)
		{
			// ��������� �� ����������
			rpi.MajorRoadPos = ROADPOS_ONROAD;
			rpi.MoreStrictRoadPos = ROADPOS_ONCROSSROAD;
			return rpi;
		}
		else
		{
			// ��������� �� ������, �������� ���������� � ������
			str1 = Split(string(matName), "_M_", true);

			if(Locs(str1) == "p")
			{
				// ��������� �� ���������
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
/** ���� ����� ������, ���������� true */
function bool IsEven(int n)
{
	if(n % 2 == 0) return true;
	else return false;
}

/** ���������� true, ���� �� ������� ���� ���� �� ������� ����� ��������� � ��������������� ������� */
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

/** true, ���� ��� ������� ���� ������� ��������� �� ����� ������ �������� */
function bool IsInSameLineNumber()
{
	if( FrontRightInfo.ActualRoadLineNumber == FrontLeftInfo.ActualRoadLineNumber &&
		FrontRightInfo.ActualRoadLineNumber == BackLeftInfo.ActualRoadLineNumber &&
		FrontRightInfo.ActualRoadLineNumber == BackRightInfo.ActualRoadLineNumber)
		return true;
	else
		return false;
}

/** true, ���� ����� ���� ��������� �� ����� � ��� �� ������� ������ �������� */
function bool IsLeftSideInSameLineSide()
{
	if(FrontLeftInfo.ActualRoadLineSide == BackLeftInfo.ActualRoadLineSide) return true;
	else return false;
}

/** true, ���� ������ ���� ��������� �� ����� � ��� �� ������� ������ �������� */
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
	if( // ���� ����� � ������ ������� ������� ��������� �� ������ �������� ������
		IsLeftSideInSameLineSide()  &&  
		IsRightSideInSameLineSide()  && 
		FrontRightInfo.ActualRoadLineSide != FrontLeftInfo.ActualRoadLineSide &&
						
		// � ����� ���� ����� ������� ��������� �� ������� � ������� "2"
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

/** true, ���� ��� ���� ������� ��������� ��������� �� ������ ��� �������� ������� */
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

	// ����� ���������, ��������� � ���������� ��������� ��������
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

/** ���������� true, ���� ����� � ������ ���� ������� ��������� �� ���������� ���������� */
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
	// ��������� ��������� ������ ���� ������ ��������� ��������� �� ������
	if(ActualDriveState == RSD_DRIVESTATE_DRIVING_ON_ROAD)
	{
		// ���������, �� ��������� �� �� �� �����������
		if(IsCompletelyOnCrossroad())
		{
			// ���� ��, ������ ������� ������ ������ ��� "����������"
			ChangeActualInroadState(RSD_INROADSTATE_UNKNOWN);
			return;
		}

		switch(ActualInroadState)
		{
		case RSD_INROADSTATE_ON_CORRECT_SIDE:
			// ���� �� ���������� ������� ������

			// ���������, �� �������� �� ������ �� ��������� ������
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
				// ���� �� ��������
				ChangeActualInroadState(RSD_INROADSTATE_ON_WRONG_SIDE);
			}
			break;

		case RSD_INROADSTATE_ON_WRONG_SIDE:
			// ���� ������ �������� �� ��������, �������� �� ����� ������������ � ������������ �����
			// ���������� ��������. �������� �������� ���:
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
					// ���� ����� ������� ��������� �� �������� ����������, � ������ - �� ������
					// �� ��� ������ ��� �� �������� �� ��������
					ChangeActualInroadState(RSD_INROADSTATE_ON_WRONG_SIDE);
				}
				else
				{
					ChangeActualInroadState(RSD_INROADSTATE_ON_CORRECT_SIDE);
				}
			}
			else
			{
				// ���� ������� ��������� �� ����� ����������, ���� ������ �� ������
			}
			break;

		case RSD_INROADSTATE_GOING_TO_CORRECT_SIDE:
			break;

		case RSD_INROADSTATE_UNKNOWN:
			// �������� ��������� "����������" ��������� ������� �� ������ 
			// ���� ���������� �� ����� ������� ������� ����� ������� �����, ��� �� ������, 
			// �� ������ �������� �� ��������� ��������
			if(IsObjectSidesInDiffrentLineSides())  
			{
					if(FrontLeftInfo.ActualRoadLineSide > FrontRightInfo.ActualRoadLineSide)
					{
						// �������
						ChangeActualInroadState(RSD_INROADSTATE_ON_CORRECT_SIDE);
					}
					else if(FrontLeftInfo.ActualRoadLineSide < FrontRightInfo.ActualRoadLineSide)
					{
						// ���� �� ��������
						ChangeActualInroadState(RSD_INROADSTATE_ON_WRONG_SIDE);
					}
					else
					{
						// ����� �� ��������
						ChangeActualInroadState(RSD_INROADSTATE_GOING_TO_WRONG_SIDE);
					}
			}
			break;
		}

		// ���������� ������� ������ (������ ��� ��������)
		UpdateInroadSideState();

		// ���������� ��������� �������� ������� �� �������
		DetectStateBetweenRoadLines();
	}
}

function Old_UpdateInsideRoadSituation()
{
	// ��������� ��������� ������ ���� ������ ��������� ��������� �� ������
	if(ActualDriveState == RSD_DRIVESTATE_DRIVING_ON_ROAD)
	{
		switch(ActualInroadState)
		{
		case RSD_INROADSTATE_ON_CORRECT_SIDE:
			// ���� �� ���������� ������� ������

			// ���������, �� ��������� �� �� �� �����������
			if(IsCompletelyOnCrossroad())
			{
				// ���� ��, ������ ������� ������ ������ ��� "����������"
				ChangeActualInroadState(RSD_INROADSTATE_UNKNOWN);
			}

			// ���������, �� �������� �� ������ �� ��������� ������
			if(IsAnyOfCornersOnCrossroad() == false && IsAllCornersInSameRoadSide() == false  &&  IsCompletelyOnRoad())
			{
				// ���� ��������, �������, ��� ������ �������� �� ��������
				ChangeActualInroadState(RSD_INROADSTATE_GOING_TO_WRONG_SIDE);
			}
			break;

		case RSD_INROADSTATE_ON_WRONG_SIDE:
			// ���� ������ �������� �� ��������, �������� �� ����� ������������ � ������������ �����
			// ���������� ��������. �������� �������� ���:
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
			// ���� �������� �� �������� �� ������ �������
			if(ActualInroadSide == RSD_SIDE_EVEN)
			{
				// ���� ��������� ��������� �� �������� �������� (���������������)
				// - �������, ��� ��������� ������� �� ��������
				if(IsCompletelyOnOddSide())
				{
					ChangeActualInroadState(RSD_INROADSTATE_ON_WRONG_SIDE);
				}
				// ���� ��������� ��������� �� ������ ������� (�� ������� �������)
				// - �������, ��� ��������� �� ���������� ������
				else if(IsCompletelyOnEvenSide())
				{
					ChangeActualInroadState(RSD_INROADSTATE_ON_CORRECT_SIDE);
				}
			}
			// ���� �������� �� �������� �� �������� �������
			else if(ActualInroadSide == RSD_SIDE_ODD)
			{
				// ���� ��������� ��������� �� �������� �������� (�� ������� �������)
				if(IsCompletelyOnOddSide())
				{
					ChangeActualInroadState(RSD_INROADSTATE_ON_CORRECT_SIDE);
				}
				// ���� ��������� ��������� �� ������ ������� (���������������)
				else if(IsCompletelyOnEvenSide())
				{
					ChangeActualInroadState(RSD_INROADSTATE_ON_WRONG_SIDE);
				}
			}
			else
			{
				// ���� ������ ����, �� ������ ����� �� �������� �� ����������� 
				// ��� ���� �� ������� ����������� ������ � �������� ������
			}

			break;

		case RSD_INROADSTATE_GOING_TO_CORRECT_SIDE:
			break;

		case RSD_INROADSTATE_UNKNOWN:
			// ��������� ���� ������ ������ �� ��������, �������� ��� ����������
			if(IsCompletelyOnEvenSide())
			{
				// ���� ��������� �� ������ ������� ������
				// �� �������� ��������� �� "����������" ��������� ������� ������ ������
				// ���������� ��������� - ����� ��� ���� ������� ��������� �� ����� ������ ��������
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
				// ���� ������ ����, ������ �� ��������� �� ����������� ������ � �������� �����
				// ��� �� �����������
			}
			break;
		}

		// ���������� ������� ������ (������ ��� ��������)
		UpdateInroadSideState();

		// ���������� ��������� �������� ������� �� �������
		DetectStateBetweenRoadLines();
	}
}

function UpdateInroadSideState()
{
	// ���� ���� �� ���� �� ����� ��������� �� �����������, ������� ��������� ������� ��� "�����������"
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

/** ��� ������� ��������� ��������� ����� �������� 
 *  ��������� ���������� �� RSD_TRAFFICLINESTATE_ONSAMELINE ��� ������ ChangeInroadStrate() c ���-� RSD_INROADSTATE_ON_CORRECT_SIDE
 *  ��������� ���������� �� RSD_TRAFFICLINESTATE_UNKNOWN ��� ������ ChangeInroadStrate() c ���-� RSD_INROADSTATE_UNKNOWN
 *  */
function DetectStateBetweenRoadLines()
{
	// ��������� ��������� ������ ���� ���� �� ���������� ������� ������
	if(ActualInroadState == RSD_INROADSTATE_ON_CORRECT_SIDE)
	{
		switch (ActualTrafficLineState)
		{
		case RSD_TRAFFICLINESTATE_UNKNOWN:
			// �������� ����������, ��������� �� �� �� ����� ������
			if(IsInSameLineNumber())
			{
				ChangeTrafficLineState(RSD_TRAFFICLINESTATE_ONSAMELINE);
			}
			break;

		case RSD_TRAFFICLINESTATE_ONSAMELINE:
			// �������� �� ������������ �� ������ ������ �����
			if(((FrontLeftInfo.ActualRoadLineNumber > FrontLeftInfo.PrevRoadLineNumber)  &&  (FrontLeftInfo.PrevRoadLineNumber != 0))   ||
				(BackLeftInfo.ActualRoadLineNumber > BackLeftInfo.PrevRoadLineNumber)  &&  (BackLeftInfo.PrevRoadLineNumber != 0))
			{
				//if(IsEven(FrontLeftInfo.PrevRoadLineNumber) && IsEven(BackLeftInfo.PrevRoadLineNumber))
					ChangeTrafficLineState(RSD_TRAFFICLINESTATE_MOVETO_LEFT);	
			}

			// �������� �� ������������ �� ������ ������ ������
			if(((FrontRightInfo.ActualRoadLineNumber < FrontRightInfo.PrevRoadLineNumber)  &&  (FrontRightInfo.PrevRoadLineNumber != 0)  &&  (FrontRightInfo.LineOutsideParameter == 0))   ||
				(BackRightInfo.ActualRoadLineNumber < BackRightInfo.PrevRoadLineNumber)  &&  (BackRightInfo.PrevRoadLineNumber != 0)  &&  (BackRightInfo.LineOutsideParameter == 0))
			{
				ChangeTrafficLineState(RSD_TRAFFICLINESTATE_MOVETO_RIGHT);
			}
			break;

		case RSD_TRAFFICLINESTATE_MOVETO_RIGHT:
			// ��������� ��������� �� ������������ ������
			if(IsObjectSidesInDiffrentLineSides() == true   &&   !IsEven(FrontRightInfo.ActualRoadLineSide))
			{
				if(FrontRightInfo.ActualRoadLineNumber < CurrentTrafficLineNumber)
				{
					// ������������ ������
					ChangeTrafficLineState(RSD_TRAFFICLINESTATE_ONSAMELINE);
					dlgOnCompleteMovementFromRight();
					
				}
				else if(FrontRightInfo.ActualRoadLineNumber == CurrentTrafficLineNumber)
				{
					// �������� �� ������, �� ������� ����� ������������
					ChangeTrafficLineState(RSD_TRAFFICLINESTATE_ONSAMELINE);
				}
				else
				{
					// ����-�������� ��������, ���� �� �� ������ ��������
					`warn("RSD_TRAFFICLINESTATE_MOVETO_RIGHT unexpected situation");
				}
			}
			break;

		case RSD_TRAFFICLINESTATE_MOVETO_LEFT:
			// ��������� ��������� �� ������������ ������
			if(IsObjectSidesInDiffrentLineSides() == true   &&   IsEven(FrontLeftInfo.ActualRoadLineSide))
			{
				if(FrontLeftInfo.ActualRoadLineNumber > CurrentTrafficLineNumber)
				{
					// ������������ �����
					ChangeTrafficLineState(RSD_TRAFFICLINESTATE_ONSAMELINE);
					dlgOnCompleteMovementFromLeft();
				}
				else if(FrontLeftInfo.ActualRoadLineNumber == CurrentTrafficLineNumber)
				{
					// �������� �� ������, �� ������� ����� ������������
					ChangeTrafficLineState(RSD_TRAFFICLINESTATE_ONSAMELINE);
				}
				else
				{
					// ����-�������� ��������, ���� �� �� ������ ��������
					`warn("RSD_TRAFFICLINESTATE_MOVETO_LEFT unexpected situation");
				}
			}
			break;
		}
		
	}

}

function Old_DetectStateBetweenRoadLines()
{
	// ��������� ��������� ������ ���� ���� �� ���������� ������� ������
	if(ActualInroadState == RSD_INROADSTATE_ON_CORRECT_SIDE)
	{
		switch (ActualTrafficLineState)
		{
		case RSD_TRAFFICLINESTATE_UNKNOWN:
			break;

		case RSD_TRAFFICLINESTATE_ONSAMELINE:
			// �������� �� ������������ �� ������ ������ �����
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

			// �������� �� ������������ �� ������ ������ ������
			if(((FrontRightInfo.ActualRoadLineNumber < FrontRightInfo.PrevRoadLineNumber)  &&  (FrontRightInfo.PrevRoadLineNumber != 0))   ||
				(BackRightInfo.ActualRoadLineNumber < BackRightInfo.PrevRoadLineNumber)  &&  (BackRightInfo.PrevRoadLineNumber != 0))
			{
				ChangeTrafficLineState(RSD_TRAFFICLINESTATE_MOVETO_RIGHT);
			}
			break;

		case RSD_TRAFFICLINESTATE_MOVETO_RIGHT:
			// ��������� ��������� �� ������������ ������
			if(IsObjectSidesInDiffrentLineSides() == true   &&   FrontRightInfo.ActualRoadLineSide == 1)
			{
				if(FrontRightInfo.ActualRoadLineNumber < CurrentTrafficLineNumber)
				{
					// ������������ ������
					ChangeTrafficLineState(RSD_TRAFFICLINESTATE_ONSAMELINE);
					dlgOnCompleteMovementFromRight();
					
				}
				else if(FrontRightInfo.ActualRoadLineNumber == CurrentTrafficLineNumber)
				{
					// �������� �� ������, �� ������� ����� ������������
					ChangeTrafficLineState(RSD_TRAFFICLINESTATE_ONSAMELINE);
				}
				else
				{
					// ����-�������� ��������, ���� �� �� ������ ��������
					`warn("RSD_TRAFFICLINESTATE_MOVETO_RIGHT unexpected situation");
				}
			}
			break;

		case RSD_TRAFFICLINESTATE_MOVETO_LEFT:
			// ��������� ��������� �� ������������ ������
			if(IsObjectSidesInDiffrentLineSides() == true   &&   FrontLeftInfo.ActualRoadLineSide == 2)
			{
				if(FrontLeftInfo.ActualRoadLineNumber > CurrentTrafficLineNumber)
				{
					// ������������ �����
					ChangeTrafficLineState(RSD_TRAFFICLINESTATE_ONSAMELINE);
					dlgOnCompleteMovementFromLeft();
				}
				else if(FrontLeftInfo.ActualRoadLineNumber == CurrentTrafficLineNumber)
				{
					// �������� �� ������, �� ������� ����� ������������
					ChangeTrafficLineState(RSD_TRAFFICLINESTATE_ONSAMELINE);
				}
				else
				{
					// ����-�������� ��������, ���� �� �� ������ ��������
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