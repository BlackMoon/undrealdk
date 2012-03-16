class Kamaz_Cheker_ExerciseBase extends Kamaz_Checker_Base implements (Gorod_ActorWithTriggers_Interface);

var() array<Kamaz_Checker_AutodromTrigger> StartTriggers;
var() float ExerciseDistance;

/** ���� �������� ������ */
var private bool bWaitForPlayer;

/** ������ �����, ���������� �������������, ������ �������� ���� ������������ ��� ���������� ���������� �������� */
var() Kamaz_ExercisePoint ForwardLeftPoint, ForwardRightPoint, BackwardLeftPoint, BackwardRightPoint;

/** ���������� ����� ������ ������ */
var protected Vector FrontLeftCornerLoc;
var protected Vector FrontRightCornerLoc;
var protected Vector BackLeftCornerLoc;
var protected Vector BackRightCornerLoc;

/** ������ �� ������ - �������� */
var Kamaz_Checker_Autodrom Autodrom;

/** ������� ��� ����������� ������� ���������� � ������ �� ��������� (���� �� ����� �� 0, ������ ����� �� �������� �������� �� ���������� � ������� ���������� �������) */
var private float StateCountDown;

/** ������ - ����� �������, ������������ ������������������ ����������� ���������� */
var() DecalActor ExerciseInfoDecal;

simulated event PostBeginPlay()
{
	local Kamaz_Checker_AutodromTrigger t;

	super.PostBeginPlay();

	foreach StartTriggers(t)
	{
		t.ActorWithTriggers = self;
		t.SetHidden(true);
	}

	ExerciseInfoDecal.SetHidden(true);
}

/** �������� ��������� ������ */
function StartWaitForPlayer()
{
	bWaitForPlayer = true;

	if(Autodrom.bVisualHintsEnabled)
		SetHiddenStartTriggers(false);
}

/** ��������� ��������� ������ */
function StopWaitForPlayer()
{
	bWaitForPlayer = false;

	if(Autodrom.bVisualHintsEnabled)
		SetHiddenStartTriggers(true);
}

/** �������� �������� ����������� ���������� */
simulated function StartCheck(CarX_Vehicle p)
{
	super.StartCheck(p);

	// ��������� ������������ ����������� ��������� (� ���� ������ ���� ������ ������, ������������ ��������)
	if(VehicleForCheck.Mesh.GetSocketByName('F_L_Corner') == none)
	{
		`warn("F_L_Corner not found");
	}
	if(VehicleForCheck.Mesh.GetSocketByName('F_R_Corner') == none)
	{
		`warn("F_R_Corner not found");
	}
	if(VehicleForCheck.Mesh.GetSocketByName('B_L_Corner') == none)
	{
		`warn("B_L_Corner not found");
	}
	if(VehicleForCheck.Mesh.GetSocketByName('B_R_Corner') == none)
	{
		`warn("B_R_Corner not found");
	}
	
	StopWaitForPlayer();
	
	if(Autodrom.bVisualHintsEnabled)
		ExerciseInfoDecal.SetHidden(false);

	ResetCountDown();

	Autodrom.ExerciseStarted(self);
}

/** ��������� �������� ���������� ���������� */
simulated function StopCheck()
{
	super.StopCheck();

	if(Autodrom.bVisualHintsEnabled)
		ExerciseInfoDecal.SetHidden(true);

	ResetCountDown();

	Autodrom.ExerciseStoped();
}

/** �������� �������� ���������� ���������� */
simulated function CancelCheck()
{
	if(bWaitForPlayer)
		StopWaitForPlayer();

	if(bCheckStarted)
		StopCheck();
}

/** ��������� ���������� ����� ������ */
simulated function UpdateCorners()
{
	VehicleForCheck.Mesh.GetSocketWorldLocationAndRotation('F_L_Corner', FrontLeftCornerLoc);
	VehicleForCheck.Mesh.GetSocketWorldLocationAndRotation('F_R_Corner', FrontRightCornerLoc);
	VehicleForCheck.Mesh.GetSocketWorldLocationAndRotation('B_L_Corner', BackLeftCornerLoc);
	VehicleForCheck.Mesh.GetSocketWorldLocationAndRotation('B_R_Corner', BackRightCornerLoc);
}

/** ���������� ���������� ���������� �� ���������� */
simulated function DrawDBG()
{
	DrawDebugLine(ForwardLeftPoint.Location, ForwardRightPoint.Location, 255, 0, 0);
	DrawDebugLine(ForwardRightPoint.Location, BackwardRightPoint.Location, 255, 0, 0);
	DrawDebugLine(BackwardRightPoint.Location, BackwardLeftPoint.Location, 255, 0, 0);
	DrawDebugLine(BackwardLeftPoint.Location, ForwardLeftPoint.Location, 255, 0, 0);
}

/** true - ���� ����� ������������� ������ ��������������� */
simulated function bool IsRectangleInside()
{
	local Vector cp;

	PointDistToSegment(FrontLeftCornerLoc, ForwardLeftPoint.Location, ForwardRightPoint.Location, cp);

	if(cp == ForwardLeftPoint.Location   ||   cp == ForwardRightPoint.Location)
		return false;

	PointDistToSegment(FrontRightCornerLoc, ForwardLeftPoint.Location, ForwardRightPoint.Location, cp);
	if(cp == ForwardLeftPoint.Location   ||   cp == ForwardRightPoint.Location)
		return false;


	PointDistToSegment(FrontLeftCornerLoc, BackwardLeftPoint.Location, ForwardLeftPoint.Location, cp);
	if(cp == BackwardLeftPoint.Location   ||   cp == ForwardLeftPoint.Location)
		return false;

	PointDistToSegment(BackLeftCornerLoc, BackwardLeftPoint.Location, ForwardLeftPoint.Location, cp);
	if(cp == BackwardLeftPoint.Location   ||   cp == ForwardLeftPoint.Location)
		return false;



	PointDistToSegment(FrontRightCornerLoc, ForwardRightPoint.Location, BackwardRightPoint.Location, cp);
	if(cp == ForwardRightPoint.Location   ||   cp == BackwardRightPoint.Location)
		return false;

	PointDistToSegment(BackRightCornerLoc, ForwardRightPoint.Location, BackwardRightPoint.Location, cp);
	if(cp == ForwardRightPoint.Location   ||   cp == BackwardRightPoint.Location)
		return false;

	PointDistToSegment(BackRightCornerLoc, BackwardRightPoint.Location, BackwardLeftPoint.Location, cp);
	if(cp == BackwardRightPoint.Location   ||   cp == BackwardLeftPoint.Location)
		return false;

	PointDistToSegment(BackLeftCornerLoc, BackwardRightPoint.Location, BackwardLeftPoint.Location, cp);
	if(cp == BackwardRightPoint.Location   ||   cp == BackwardLeftPoint.Location)
		return false;

	return true;
}

/** true - ���� ����� ������������� ��� ��������������� */
simulated function bool IsRectangleOutside()
{
	local Vector cp1, cp2;

	// ��������� �������� ����� ����
	PointDistToSegment(FrontLeftCornerLoc, ForwardLeftPoint.Location, ForwardRightPoint.Location, cp1);
	PointDistToSegment(FrontLeftCornerLoc, BackwardLeftPoint.Location, ForwardLeftPoint.Location, cp2);

	if((cp1 != ForwardLeftPoint.Location && cp1 != ForwardRightPoint.Location) && (cp2 != BackwardLeftPoint.Location && cp2 != ForwardLeftPoint.Location))
		return false;

	// ��������� �������� ������ ����
	PointDistToSegment(FrontRightCornerLoc, ForwardLeftPoint.Location, ForwardRightPoint.Location, cp1);
	PointDistToSegment(FrontRightCornerLoc, ForwardRightPoint.Location, BackwardRightPoint.Location, cp2);
	
	if((cp1 != ForwardLeftPoint.Location && cp1 != ForwardRightPoint.Location) && (cp2 != ForwardRightPoint.Location && cp2 != BackwardRightPoint.Location))
		return false;

	// ��������� ������ ����� ����
	PointDistToSegment(BackLeftCornerLoc, BackwardLeftPoint.Location, ForwardLeftPoint.Location, cp1);
	PointDistToSegment(BackLeftCornerLoc, BackwardRightPoint.Location, BackwardLeftPoint.Location, cp2);
	
	if((cp1 != BackwardLeftPoint.Location && cp1 != ForwardLeftPoint.Location) && (cp2 != BackwardRightPoint.Location && cp2 != BackwardLeftPoint.Location))
		return false;

	// ��������� ������ ������ ����
	PointDistToSegment(BackRightCornerLoc, ForwardRightPoint.Location, BackwardRightPoint.Location, cp1);
	PointDistToSegment(BackRightCornerLoc, BackwardRightPoint.Location, BackwardLeftPoint.Location, cp2);
	
	if((cp1 != ForwardRightPoint.Location && cp1 != BackwardRightPoint.Location) && (cp2 != BackwardRightPoint.Location && cp2 != BackwardLeftPoint.Location))
		return false;

	return true;
}

/** true - ���� ����� ������������� ��� ������� ������ (������������ �������� [ForwardLeftPoint.Location; ForwardRightPoint]) ��������������� */
simulated function bool IsRectangleAboveForward()
{
	local Vector cp1, cp2;

	// �������� ����� ����
	PointDistToSegment(FrontLeftCornerLoc, ForwardLeftPoint.Location, BackwardLeftPoint.Location, cp1);
	PointDistToSegment(FrontLeftCornerLoc, ForwardRightPoint.Location, BackwardRightPoint.Location, cp2);

	if(cp1 != ForwardLeftPoint.Location || cp2 != ForwardRightPoint.Location)
		return false;

	// �������� ������ ����
	PointDistToSegment(FrontRightCornerLoc, ForwardLeftPoint.Location, BackwardLeftPoint.Location, cp1);
	PointDistToSegment(FrontRightCornerLoc, ForwardRightPoint.Location, BackwardRightPoint.Location, cp2);

	if(cp1 != ForwardLeftPoint.Location || cp2 != ForwardRightPoint.Location)
		return false;

	// ������ ����� ����
	PointDistToSegment(BackLeftCornerLoc, ForwardLeftPoint.Location, BackwardLeftPoint.Location, cp1);
	PointDistToSegment(BackLeftCornerLoc, ForwardRightPoint.Location, BackwardRightPoint.Location, cp2);

	if(cp1 != ForwardLeftPoint.Location || cp2 != ForwardRightPoint.Location)
		return false;

	// ������ ������ ����
	PointDistToSegment(BackRightCornerLoc, ForwardLeftPoint.Location, BackwardLeftPoint.Location, cp1);
	PointDistToSegment(BackRightCornerLoc, ForwardRightPoint.Location, BackwardRightPoint.Location, cp2);

	if(cp1 != ForwardLeftPoint.Location || cp2 != ForwardRightPoint.Location)
		return false;

	return true;
}

/** �������� ������������ ���������� ���������� */
simulated function Check(float DeltaSeconds)
{
	UpdateCorners();

	// ���� � ������� ���������� �������� �� ���������� ������ ������� ����� �������
	StateCountDown -= DeltaSeconds;
	if(StateCountDown <= 0)
	{
		StopCheck();
		Autodrom.SendAutodromEvent(self, 1022);
	}

	// ���� ����� ����� ������� ������ �� ��������������
	if(IsTooFarFromRectangle())
	{
		StopCheck();
		Autodrom.SendAutodromEvent(self, 1025);
	}

}

/** ������� - ���������� ������� ������ �� ��������� ���������� */
function OnTriggerTouch(Actor Sender, Actor Other)
{
	local CarX_Vehicle v;

	if(bWaitForPlayer && !bCheckStarted)
	{
		v = CarX_Vehicle(Other);
		if(v != none)
			StartCheck(v);
	}
}

function OnTriggerUnTouch(Actor Sender, Actor Other)
{
	
}

/** ����� �������� ������� ���������� �� ���������� �������� ��������. seconds - ���-�� ������, ��������� �� ���������� ���������� �������� */
function ResetCountDown(optional int seconds = 300)
{
	StateCountDown = seconds;
}

/** �� �����������. ������ ������: ���; ��������: �����������. */
function bool VehicleIsStoped()
{
	return (VehicleForCheck.GetHandBrake() && 
			VehicleForCheck.GetGear() == 0 /*&& 
			VehicleForCheck.FBrake == 0 &&
			VehicleForCheck.FThrottle <= 0.3 &&
			VehicleForCheck.FClutch == 1*/);
}

/** true - ���� ������ �������� ������ ����� */
function bool DriveBackStarted()
{
	return (VehicleForCheck.CurrentGear == -1);
}

/** true - ���� ������ ����������� ������� ������ �� ���� ���������� ���������� */
function bool IsTooFarFromRectangle()
{
	if(VSize(ForwardLeftPoint.Location - VehicleForCheck.Location) > ExerciseDistance)
		return true;
	else
		return false;
}

/** ������ ���������� ���������� (� ������ ������ ������) */
function CancelExercise()
{
	if(bCheckStarted)
		StopCheck();
}

simulated function SetHiddenStartTriggers(bool bNewHidden)
{
	local Kamaz_Checker_AutodromTrigger trg;
	
	foreach StartTriggers(trg)
	{
		trg.SetHidden(bNewHidden);
	}
}

DefaultProperties
{
	Begin Object Class=StaticMeshComponent Name=MyStaticMeshComponent
    StaticMesh=StaticMesh'NodeBuddies.NodeBuddy_PerchUp'
	bUsePrecomputedShadows = true
	End Object

	Components.Add(MyStaticMeshComponent);

	bCheckStarted = false;
	bWaitForPlayer = false;

	ExerciseDistance = 2000;
}
