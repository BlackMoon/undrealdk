class Gorod_AIVehicle_PathNode extends Gorod_BasePathNode;

var float BOT_COLLIDE_DIST;
/** ���������� �����, � ������� ����� ������� �� ������� (��������� ���������� �����) */
var() array<Gorod_AIVehicle_PathNode> NextPathNodes;

/** ������������ �������� � ������� ��������� ����� � ������ ����� */
var() float CarMaxSpeed;

/** ������ ������������ �����, ������� ���� � ������� ����� */
var array<Gorod_AIVehicle_Controller> IncomingAIVehicleControllers;

/** ��������� ������, ���������� ����� ��� ����� */
var Gorod_AIVehicle LastCar;

/** ���� ���� �������(true), � ������ ����� ����������� ��������� ������� (��������� ������ � ���������� ������ ������) */
var(AIVehicle_PathNode) bool bCanTurnRightFromInternalSide;

/** ���� ���� �������(true), � ������ ����� ����������� ��������� ������ (��������� ������ � ���������� ������ ������) */
var(AIVehicle_PathNode) bool bCanTurnLeftFromInternalSide;

/** ���� ���� �������(true), � ������ ����� ����������� ��������� ������ (��������� ������ � ������� ������ ������) */
var(AIVehicle_PathNode) bool bCanTurnLeft;

/** ���� ���� �������(true), � ������ ����� ����������� ��������� ������� (��������� ������ � ������� ������ ������) */
var(AIVehicle_PathNode) bool bCanTurnRight;

/** ���� ���� �������(true), � ������ ����� ����������� �������� ������ */
var(AIVehicle_PathNode) bool bCanDriveForward;

/** ���� ���� �������(true), � ������ ����� ����������� ������������ ������ (��������� ������ � ������� ������ ������) */
var(AIVehicle_PathNode) bool bCanTurnReverse;

/** ���� ���� �������(true), � ������ ����� ����������� ������������ ������ (��������� ������ � ���������� ������ ������) */
var(AIVehicle_PathNode) bool bCanTurnReverseFromInternalSide;

/** ���� ���� ���� �������, ��� ����� ����� ���������������� ������ �������������� ������� */
var(AIVehicle_PathNode) bool bControlByRightSection;

/** ���� ���� ���� �������, ��� ����� ����� ���������������� ����� �������������� ������� */
var(AIVehicle_PathNode) bool bControlByLeftSection;

/** �������� �����������, ��� ������� ����������� ����� */
var Material SurfaceMaterial;

/** ������ �� ����� ��� ������������ ������ */
var(AIVehicle_PathNode) Gorod_AIVehicle_PathNode leftChangelineNode;
/** ������ �� ����� ��� ������������ ������� */
var(AIVehicle_PathNode) Gorod_AIVehicle_PathNode rightChangelineNode;


var Gorod_AIVehicle_Controller ChangeLineAiVehicle_Controller;


function PostBeginPlay()
{
	super.PostBeginPlay();

	// ��������� � ����� � �������
	if(CrossRoad == none)
	{
		CarMaxSpeed = 50*CarMaxSpeed/3.6;
	}
}

/** ����� �������� ��� ������������ ���� ������ */
simulated function bool IsFreeForRelloc()
{	
	local bool result;		
	local Gorod_AIVehicle_Controller aivc;	
	local float d0, d1;
	
	result = true;	
	// ���� �� ���� ����� �� ����� ������ ����� � ������ ����� �� ��������� �� ����������
	if(CrossRoad != none || NextPathNodes.Length == 0) // || DangerousVehicleNum > 0)
	{
		result = false;
	}
	else
	{
		// �������� �� �������� ������ (�� ���������� �� �������-�����)
		result = super.IsFreeForRelloc();		
		if (result)
		{	
			d1 = BOT_COLLIDE_DIST;
			foreach IncomingAIVehicleControllers(aivc)
			{
				d0 = vSize(aivc.ControlledCar.Location - Location);				
				if (d0 < aivc.SafeDistance + 150 /*aivc.VEHICLE_LENGTH*/) return false;
				d1 = max(d1, aivc.SafeDistance + 150/*aivc.VEHICLE_LENGTH*/);
			}
			
			if (LastCar != none)
			{				
				d0 = vSize(LastCar.Location - Location);
				if (d0 < d1) return false;
			}			
		}
	}
	return result;
}

/** ����������, ���� ����������� ��� ������ ������ */
simulated function bool HasSurface()
{
	local Vector TraceStart, TraceEnd, HitNormal, HitLoc;
	local TraceHitInfo hi;

	// ���� ��� ������ �� �������� ����������� ��� ����� - ������� ����
	if(SurfaceMaterial == none)
	{
		TraceStart = self.Location;
		TraceEnd = self.Location - vect(0, 0, 100);

		Trace(HitLoc, HitNormal, TraceEnd, TraceStart, true, , hi, 1);
		SurfaceMaterial = hi.Material;
	}

	// ���� �������� ����������� �� ��� �� ������ ��� ��� �� �������� ������, ���������� false
	if(SurfaceMaterial == none || !OnRoad(SurfaceMaterial.Name))
		return false;
	else
		return true;
}

/************************************************************************************/
/*          ������ � ������� � ������                                               */
/************************************************************************************/

/** ���������� ��� ��������� ���������� ����� */
simulated function array<Gorod_BasePathNode> GetNextPathNodes()
{
	return NextPathNodes;
}

/** ���������� ��������� ����, ���������� ����� ������ ����� */
function Gorod_BasePath GetRandomPath()
{
	if(StartingPaths.Length == 0)
		return none;
	else
		return StartingPaths[Rand(StartingPaths.Length)];
}

/** ���������� �������� ��������� ��������� ���������� ����� */
function Gorod_AIVehicle_PathNode GetRandomNode()
{
	if(NextPathNodes.Length == 0)
		return none;
	else
		return NextPathNodes[Rand(NextPathNodes.Length)];
}

/** ���������, ��������� �� ������������ � ������ ����� */
function bool isSafeForChangeLine()
{
	local Gorod_AIVehicle_Controller IncomingAIVehicleController;
	foreach IncomingAIVehicleControllers(IncomingAIVehicleController)
	{
		IncomingAIVehicleController.CalcSafeDistance();
		if(Vsize(self.Location -IncomingAIVehicleController.ControlledCar.Location) <  IncomingAIVehicleController.SafeDistance)
			return false;
	}
	return true;
}


/** �������� �� �������� ������ */ 
function bool OnRoad(name matName)
{
	if(Left(string(matName), 9) == "M_4_strip" || Left(string(matName), 5) == "M_Per")
		return true;
	else
		return false;
}

DefaultProperties
{
	CarMaxSpeed = 20;

	bStatic = false;
	bNoDelete = false;

	bCanTurnRightFromInternalSide = false
	bCanTurnLeftFromInternalSide = false
	bCanTurnLeft = true
	bCanTurnRight = true
	bCanDriveForward = true
	bCanTurnReverse = true
	bCanTurnReverseFromInternalSide = false
	bControlByLeftSection = false
	bControlByRightSection = false
	
	// ��� �����
	Begin Object Class=StaticMeshComponent Name=MyStaticMeshComponent
		StaticMesh=StaticMesh'Pickups.Ammo_Shock.Mesh.S_Ammo_ShockRifle'
		HiddenGame = true
	End Object
	
	BOT_COLLIDE_DIST=500.0f

}