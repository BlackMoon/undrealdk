class Gorod_AIVehicle_Controller extends AIController;

/** ���������� ��������� ���������� �/� ������� - ����� � ��������� ������������ */
var const float MIN_DISTANCE;

/** ������������ ���������� �� ���������� �����, �� ������� ������ ���������� ����� ��������� ����������� */
var const float POINT_REACH_PRECISION;

/** ������, ����������� ������ Controller'�� */
var Gorod_AIVehicle ControlledCar;

/** ������� ��������� �������. ���� CurPath == none, ������ �������� ���� ��� */
var Gorod_BasePath CurPath;

/** ������ ����� � ������� �������� */
var int CurIndex;

/** ��������� ���������� (������� ������ ������/���������� �����, ����� ������� ���� �����������) */
var Actor Obstacle;

/** ���������� ���������� */
var float SafeDistance;

/** ������� ��� ��������� ������� 5-�� tick'� */
var int countTick;

/** �������������� ���������� ����� (������ ���������� �����, ���������� � ������� ������ �������, ������������� ����������� ������� �� �����
 *  ������� �� ������ SafeDistance)
 */
var array<Gorod_AIVehicle_PathNode> nodes;

/** �������������� ������ actor'�� ����� �������� �������� ������ */
var array<Actor> DangerousActors;

/** ���������� �� ���������� ������ */
var float DistanceToClosestPlayer;
// ��������� ��� ������ ������� ������
var PlayerController CurrentPlayerController;

/** ����, ������������, �������� �� �������� �� ������������ �������� ������ */
var bool bDrivingCheckStarted;

var Gorod_AIVehicle_PathNode TargetForRelining;

event Possess(Pawn inPawn, bool bVehicleTransition)
{
	super.Possess(inPawn, bVehicleTransition);
	ControlledCar = Gorod_AIVehicle(Pawn);
	Pawn.SetMovementPhysics();	
}

/** ��������� ������� ��� ������� ���������� � ������ ������ (� �� � PostBeginPlay) */
function StartController()
{
	// ��� ��� ������ ���������� ���� �� ������ � ������, �� � � �������� (����� �� ��� ��������� ����� � ������),
	// ������ �������� �� ��, ��� Pawn - ��� Gorod_AIVehicle (���� ��� �� ������� � auto state Idle � ������ �� ������)
	if((ControlledCar != none) && (ControlledCar.Target != none))
	{
		// ������������ � ������ �����, ������� ���� � ����� ControlledCar.Target
		ControlledCar.Target.IncomingAIVehicleControllers.AddItem(self);

		// ������� ��������� �������� ��������
		ControlledCar.SetTargetSpeed(ControlledCar.Target.CarMaxSpeed);
		if(CurPath == none)
		{
			// ������� ����
			SetCurrentPath(ControlledCar.Target.GetRandomPath());
		}

		UpdateNextNodes();

		GotoState('Work');
	}
}

/** ��������� ��������� */
auto simulated state Idle
{
}

/********************************************************/
/*          ���������� ��������� ������-����            */
/********************************************************/

/** �������� �� ����� */
simulated state Work
{
	simulated event Tick(float DeltaSeconds)
	{
		super.Tick(DeltaSeconds);

		if(ControlledCar != none)
		{
			SelectNewTarget();
			
			countTick++;

			if(countTick == 3)
			{
				// � ������ ������� base'�� ����������� ������ ������
				// ������ base �� none ����� ������ �� �������������� � ������ ������, ����� ������ ������������.
				ControlledCar.SetBase(none);
				
				// �������� � ������ ������
				CalcDistanceToClosestPlayer();

				if(DistanceToClosestPlayer < `MIN_DISTANCE && DistanceToClosestPlayer > `MIN_WRONG_DISTANCE )
					CheckWrongDriving();
			}
			else if(countTick == 4)
			{
				// ��������� ��� ������ ������� ������
				if(CurrentPlayerController == none)
					CurrentPlayerController = GetALocalPlayerController();

				CalcDistanceToClosestPlayer();

				// ��������, ���� ��������� ���������� ������ �� ���� �������
				if(DistanceToClosestPlayer > `MAX_DISTANCE)
					Disappear();
			}
			else if(countTick == 5)
			{
				CalcSafeDistance();
		
				Scan();

				countTick = 0;
			}

			SetNewTargetSpeed();
		}
	}

	/** �������������� �������� �� ������������ �������� ������. ��������� ��������������� ������� �� Gorod_AIVehicle �, ���� ��� �� ��������, ������������� ������ ��� ��������� �������� */
	function CheckWrongDriving()
	{
		if(!bDrivingCheckStarted)
		{
			if (ControlledCar.IsDrivingWrong())
			{
				bDrivingCheckStarted = true;
				SetTimer(1, false, 'CheckWrongDrivingAgain');
			}
		}
	}

	/** ��������� �������� �� ������������ �������� ������. ��������� ��������������� ������� �� Gorod_AIVehicle �, ���� ��� �� ��������, ������� ������ � ����� */
	function CheckWrongDrivingAgain()
	{
		if (ControlledCar.IsDrivingWrong())
			Disappear();
		bDrivingCheckStarted = false;
	}
}

/** �������� ��������� �� ����� */
simulated state Teleported
{
Begin:
	// ���� ��� RelocationManager'�, �� �������� ���-���� ������
	if(ControlledCar.RelocManager == none)
	{
		`log(self @ "No reloc manager");
		GotoState('Idle');
	}

	// ���� ���� ������� ����
	if(CurPath != none)
	{
		// ����������� ���
		CurPath.CancelPath(ControlledCar);
		CurIndex = 0;
		CurPath = none;
	}

	// ������������� ������
	ControlledCar.Target = none;
	ControlledCar.SetTargetSpeed(0);
	ControlledCar.SetNoThrottle(true);
	// ��������� �������� �������
	TurnOffControlledCarSignals();

	// ������� Obstacle
	Obstacle = none;

	// �������� RelocationBotManager'�, ��� ���������� ����������� ��� � ����� �����
	ControlledCar.RelocManager.AddPawnToReloc(ControlledCar);	
}

/** ������������� ��������� ��� ���������� ��������, ����������� ����� ��������� �� ����� */
simulated state AfterAppeared
{
	simulated event Tick(float DeltaSeconds)
	{
		// ��� ���� ������ ����� �� �����
		if(ControlledCar.IsOverlapping(ControlledCar.Target))
		{			
			ControlledCar.SetNoThrottle(false);
			ControlledCar.SetTargetSpeed(ControlledCar.Target.CarMaxSpeed);
			SetCurrentPath(ControlledCar.Target.GetRandomPath());
			GotoState('Work');
		}
	}
}

/** ���������� ������� �������������� ��������, ����� �� ��������� ������ ��� ������ CheckWrongDriving, ����� ������ ��������� �� � ��������� Work */
function CheckWrongDriving()
{
	`warn("wrong function call");
}

/** ������� ���������� �� ���������� ������ */
function CalcDistanceToClosestPlayer()
{
	// ���������� ���������� �� ���������� ������ ���������������� ��� ������ ������� ������
	/*
	local int i;		
	local float CurrentDistance;
	local array<Vector> Locations;

	Locations = Gorod_Game(WorldInfo.Game).GetPlayerControllersLocation();
			
	// ��������� ���������� �� ���������� ������	
	if(Locations.Length > 0)
	{
		DistanceToClosestPlayer = VSize(Locations[0] - ControlledCar.Location);

		for(i = 1; i < Locations.Length; i++)
		{
			CurrentDistance = VSize(Locations[i] - ControlledCar.Location);
			if(CurrentDistance < DistanceToClosestPlayer)
				DistanceToClosestPlayer = CurrentDistance;
		}
	}
	else
		DistanceToClosestPlayer = 0.f;
	*/

	if(CurrentPlayerController == none || CurrentPlayerController.Pawn == none)
		DistanceToClosestPlayer = 0.0f;
	else
		DistanceToClosestPlayer =  VSize(CurrentPlayerController.Pawn.Location - ControlledCar.Location);
}

function SetTargetForRelining(Gorod_AIVehicle_PathNode t)
{
	TargetForRelining = t;
	t.ChangeLineAiVehicle_Controller = self;
}

/** ����� ��������� ���������� ����� � ��� ������, ���� �� �������� ������� ���������� ����� */
function bool SelectNewTarget()
{
	local Gorod_AIVehicle_PathNode NewPathNode;
	local Gorod_BasePath NewPath;

	// ���� � ������ ��� Target'a (������ ���� �� ������)
	if(ControlledCar.Target == none)
	{
		// �������� �� ������ � �������� � �����
		`warn("Target is none.");
		Disappear();
		return false;
	}
	
	if(TargetForRelining != none) // ���� ���� ������� ����� ��� ������������
	{
		// ��������� �� ������� �����, ������� ���� � ����� ControlledCar.Target
		ControlledCar.Target.IncomingAIVehicleControllers.RemoveItem(self);

		// ���� ���� ���� �������� ���
		if(CurPath != none)
		{
			CurIndex = 0;
			CurPath.CancelPath(ControlledCar);
			CurPath = none;
		}

		// ������������� ����� ��� ������������ � �������� ������� ���������� �����
		ControlledCar.Target = TargetForRelining;
		
		// �������� ����� ����
		NewPath = TargetForRelining.GetRandomPath();
		if(NewPath != none)
			SetCurrentPath(NewPath);

		// ������������ � ������ �����, ������� ���� � ����� ControlledCar.Target
		ControlledCar.Target.IncomingAIVehicleControllers.AddItem(self);

		UpdateNextNodes();

		// ������� ����� ��� ������������, ����� �� ��������� ���� �� ������������ � �����
		TargetForRelining = none;

		return true;
	}
	else if(ControlledCar.IsOverlapping(ControlledCar.Target)) // ���� ������� �� ��������� �����
	{
		// �������������� ��������. ���� ������� �� �����, ������� �������� Obstacle, �� ��� ������, ��� ������-���
		// �� ������ ����������� - ������ ���� �� ������
		if(ControlledCar.Target == Obstacle)
			`warn("Failed to stop before PathNode" @ ControlledCar.Target $ ". CurrentVelocity=" $ ControlledCar.CurrentVelocity);
		//���� ������� �� ����� � ������� ���������������, ������� ���� �� �����
		if(ControlledCar.Target.ChangeLineAiVehicle_Controller==self)
			ControlledCar.Target.ChangeLineAiVehicle_Controller = none;

		// ��������� �� ������� �����, ������� ���� � ����� ControlledCar.Target
		ControlledCar.Target.IncomingAIVehicleControllers.RemoveItem(self);

		// ���������� ����� �� ������� �������
		ControlledCar.OldTarget = ControlledCar.Target;
		
		// ������� �������� ��������� ���������� ����� �� �������� ����
		if(CurPath != none)
		{
			// ���� ������� ������ ����� ��������� �� �������, �� ����� ��� ���� �� ������� ������� CurPath.PathNodes
			if(CurIndex < CurPath.PathNodes.Length - 1)
			{
				// ���� ������� �� ������ ����� �������� ����
				if(CurIndex == 0)
				{
					// �������� �� ����
					CurPath.GoIn(ControlledCar);
				}

				// ����� ��������� ���������� ����� � ������������ � ���������
				CurIndex++;
				NewPathNode = Gorod_AIVehicle_PathNode(CurPath.PathNodes[CurIndex]);
			}
			else
			{
				CurIndex = 0;
				// �������� ����
				CurPath.GoOut(ControlledCar);
				CurPath = none;

				// ��������� �������� ������� ������
				TurnOffControlledCarSignals();
			}
		}
		
		// ���� �� ������� ������� ����� �� �������� ����
		if(NewPathNode == none)
		{
			// �������� ����� ���������� ����� ��������� �������
			NewPathNode = ControlledCar.Target.GetRandomNode();

			// ���� � ����� �� ������
			if(NewPathNode == none)
			{
				Disappear();
				return false;
			}
			else
				NewPath = NewPathNode.GetRandomPath();
		}

		// ������������� ����� ���������� �����
		ControlledCar.Target = NewPathNode;
		SetCurrentPath(NewPath);

		// ������������ � ������ �����, ������� ���� � ����� ControlledCar.Target
		ControlledCar.Target.IncomingAIVehicleControllers.AddItem(self);

		ControlledCar.OldTarget.LastCar = ControlledCar;
		//ControlledCar.OldTarget.DecDangerousVehicleNum();

		UpdateNextNodes();

		//`log(ControlledCar.Target);
		return true;
	}

	return false;
}

/** ���������� ����������, ������������ ��� ����, ����� �������� �������� �� 0 */
simulated function CalcSafeDistance()
{
	 SafeDistance = ControlledCar.CurrentVelocity*(ControlledCar.CurrentVelocity/ControlledCar.VelocityStep)/2 + ControlledCar.VEHICLE_LENGTH/2 + MIN_DISTANCE;
}

/**
* � �������� ����������� �������� ��������� ������ �� ���, ������� ���� �� ���� �� ����, ��������������� ��� ����������� �������
* ��� ������ ����� ���������� CollidingActor � �������, ��������� � ������� ��������� ���������� �����
*/
simulated function Scan()
{	
	local UDKVehicle ClosestVehicle;
	local Actor ClosestDangerousActor;

	if(ControlledCar.Location.Z < -100)
	{
		Disappear();
		return;
	}

	Obstacle = none;

	if(ControlledCar.Target != none)
	{
		ClosestVehicle = FindClosestVehicle();
		ClosestDangerousActor = FindClosestDangerousActor();

		// ���������� ���������� �� ��������� ������-���� � ���������� �������� �������
		// ����� Obstacle
		if(ClosestVehicle != none && ClosestDangerousActor != none)
		{
			if(DistanceFromPoint(ClosestVehicle.Location) < DistanceFromPoint(ClosestDangerousActor.Location))
				Obstacle = ClosestVehicle;
			else
				Obstacle = ClosestDangerousActor;
		}
		else if(ClosestVehicle != none)
		{
			Obstacle = ClosestVehicle;
		}
		else if(ClosestDangerousActor != none)
		{
			Obstacle = ClosestDangerousActor;
		}
		
		// ���� ������ ����, �� �� ��� �� ������� �� ������ �����
		if((CurPath != none) && (CurIndex == 0))
		{
			// ���� �������� ������� ������ �� ��������
			if(DistanceFromPoint(ControlledCar.Target.Location) < 2000)
			{
				// ����� ����� �������� ������� ������ ���� �������� � ������
				SetControlledCarSignals();
			}

			// ���� ����� ��������� � �������� ������� ����� �������� ���������
			if(!CurPath.CanGo())
			{
				if(Obstacle == none || DistanceFromPoint(ControlledCar.Target.Location) < DistanceFromPoint(Obstacle.Location))
					Obstacle = ControlledCar.Target;
			}
		}
	}
}

/** ��������� ������� � ����������� ������� ������� ��������� �������� � ����������� �� ������� Obstacle � ���������� �� ����  */
simulated function SetNewTargetSpeed()
{
	local float VehicleObstacleLength2, StopDistance;
	local VehicleBase VehicleObstacle;

	// ���� ��� ������� ���������� �����, ���������������
	if(ControlledCar.Target == none)
	{
		ControlledCar.SetTargetSpeed(0);
		return;
	}

	// ���� ��� �����������, �������� �������� �� ������� ���������� �����
	if(Obstacle == none)
	{
		ControlledCar.SetTargetSpeed(ControlledCar.Target.CarMaxSpeed);
		return;
	}

	// ������������ �������� ����� ������� ������ ������
	VehicleObstacle = VehicleBase(Obstacle);
	VehicleObstacleLength2 = ((VehicleObstacle != none) ? (VehicleObstacle.VEHICLE_LENGTH/2) : 0.f);

	// ���������� �� �����������, �� �������� ����� ���������� ��������� �������� �������� �� ������ ������
	StopDistance = VSize(Obstacle.Location - ControlledCar.Location) - ControlledCar.VEHICLE_LENGTH/2 - VehicleObstacleLength2 - MIN_DISTANCE;

	// ���� ������� ������ ���������, �������� ���������
	if(StopDistance <= 0)
	{
		ControlledCar.SetTargetSpeed(0);
		return;
	}
	
	// ������������� �������� � ������� ���� ����� ����� ����������� �� ���������� StopDistance ��� ��������� ControlledCar.VelocityStep
	ControlledCar.SetTargetSpeed(Sqrt(2*ControlledCar.VelocityStep*StopDistance));
}

/** ����������� ��������� ������� ������ ������ */
function UDKVehicle FindClosestVehicle()
{
	// �����������, ������� ��������� ��������� �� ������ ������
	local UDKVehicle ClosestVehicle, CurrentVehicle;
	local UDKVehicle PlayerVehicle;
	local Gorod_AIVehicle CurrentAIVehicle;
	local Vector HitLoc, HitNorm;
	local bool bPlayerVehicleFound;

	ClosestVehicle = none;
	
	// ���� ������ ������ �� �������
	foreach CollidingActors(class'UDKVehicle', CurrentVehicle, SafeDistance, ControlledCar.Location + (SafeDistance)*ControlledCar.TargetViewDirection)
	{
		CurrentAIVehicle = Gorod_AIVehicle(CurrentVehicle);
		if(CurrentAIVehicle != none)        // ���� ��������� ������ - ���
		{
			// ���� ����� ���� ����, ��������� � ���������� �������, ���������� CollidingActors'��
			if(CurrentAIVehicle == ControlledCar) continue;

			// ���� Target � �������� ���� CurrentVehicle - �� � ������ nodes � �� �������� ������� ������, �� ��������� � ���������� �������
			if(nodes.Find(CurrentAIVehicle.Target) == INDEX_NONE) continue;
		}
		else if(CurrentVehicle != none && PlayerController(CurrentVehicle.Controller) != none)        // ���� ��������� ������ - ������ ������
		{
			bPlayerVehicleFound = false;
			
			// Trace ��� ����� ������
			foreach TraceActors(class'UDKVehicle', PlayerVehicle, HitLoc, HitNorm, ControlledCar.Location + (SafeDistance)*ControlledCar.TargetViewDirection, ControlledCar.Location, ControlledCar.GetCollisionExtent() + vect(20, 20, 0))
			{
				// ���� ������� ������ ������� � ������� Trace
				if(CurrentVehicle == PlayerVehicle)
				{
					bPlayerVehicleFound = true;
					break;
				}
			}

			// ���� ������ ������ �� ������� � ������� TraceActors, �� �������, ��� ��� �� ����������� ��� ����
			if(!bPlayerVehicleFound) continue;
		}

		// ��������� ��������� ������
		if(ClosestVehicle == none || (VSize(ClosestVehicle.Location - ControlledCar.Location) > VSize(CurrentVehicle.Location - ControlledCar.Location)))
			ClosestVehicle = CurrentVehicle;
	}

	return ClosestVehicle;
}

/** ������� ��������� ������� ������ */
function Actor FindClosestDangerousActor()
{
	local Actor a, ClosestActor;
	
	ClosestActor = none;

	foreach DangerousActors(a)
	{
		if(ClosestActor == none || (DistanceFromPoint(ClosestActor.Location) > (DistanceFromPoint(a.Location))))
			ClosestActor = a;
	}

	return ClosestActor;
}

/** ��������� ����������� �������� ��� ����������� ������ �� ����� */
function Appear(Gorod_AIVehicle_PathNode node)
{	
	ControlledCar.Target = node;
	ControlledCar.Target.LastCar = ControlledCar;   // LastCar = currentCar
	UpdateNextNodes();

	GotoState('AfterAppeared');
}

/** ��������� ��������� ���� � �������� �������� � ���������� ������������� �������� */
function SetCurrentPath(Gorod_BasePath path)
{
	if(path != none)
	{
		CurPath = path;
		CurIndex = 0;
		// �������� ����
		CurPath.Select(ControlledCar);
		
		if(ControlledCar.Target.CrossRoad != none)
		{
			// ���� � ������� ���������� ����� ����� CrossRoad, ������ ������ ����� �������� ������� �� ����������
			// � ���� ������������������ � ��
			ControlledCar.Target.CrossRoad.RegisterBotInQueue(self);
		}
	}
}

/** ��������� ������ �������������� ���������� ����� */
function UpdateNextNodes()
{
	local Gorod_AIVehicle_PathNode p;
	local int i, j;

	// ������� ���� ���������� ����� ������ ���� �� ������� tick'� ���� ������� ����� ���������� �����
	nodes.Remove(0, nodes.Length);
	
	if (ControlledCar.Target == none)
		return;

	nodes.AddItem(ControlledCar.Target);
	foreach ControlledCar.Target.NextPathNodes(p)
		nodes.AddItem(p);

	i = 0;
	while(i < nodes.Length)
	{
		for(j = 0; j < nodes[i].NextPathNodes.Length; ++j)
		{
			// �������������� �������� �� ������ ������ ��� �������� NextPathNodes
			if(nodes[i].NextPathNodes[j] == none)
			{
				`warn("NextPathNodes in" @ nodes[i] @ "contains none element" @ "(index=" $ j $")");
				continue;
			}
			// ������������� ���������� �����, ������� �� ������ 2000, SafeDistance �� ������������ � ���� ����, ��� �� �� ���������� ��� ��������� �������� ��������
			else if((nodes.Find(nodes[i].NextPathNodes[j]) == INDEX_NONE) && (VSize(nodes[i].NextPathNodes[j].Location - nodes[0].Location) < 2000.f /*SafeDistance*/))
				nodes.AddItem(nodes[i].NextPathNodes[j]); // �������� � nodes, ��������� �����, ������� ���� ����������
		}
		++i;
	}
}

/** ��������� ������-���� */
function Disappear()
{
	GotoState('Teleported');
}

/** ���������� �� ������-���� �� ��������� ����� */
function float DistanceFromPoint(Vector Loc)
{
	return VSize(ControlledCar.Location - Loc);
}

/** ������� - ����������� � ���, ��� � ������������ Pawn'� �������� ������� RigidBodyCollision */
function NotifyRigidBobyCollision(PrimitiveComponent HitComponent, PrimitiveComponent OtherComponent, const out CollisionImpactData RigidCollisionData, int ContactIndex)
{
	local UDKVehicle vehic;
	local PlayerController pl;

	// ���� ���������� �� � �������, ������ �� ������
	vehic = UDKVehicle(OtherComponent.Owner);
	if(vehic == none)
		return;

	// ���� ���������� � ������� ������, ������ �� ������
	pl = PlayerController(vehic.Controller);
	if(pl != none)
		return;

	// ����������� � "�����" ��������, ������ ���� �� ������ ��������
	Disappear();
	
	// ��� �� ������ ���� - ����� � ���
	// �������� ����������������, ��� ���������� �����
	//`log("CRASH-----------------------------------");
	//`log("Controller:" @ self);
	//`log("ControlledCar:" @ ControlledCar @ "Location:" @ ControlledCar.Location);
	//`log("Target:" @ ControlledCar.Target);
	//`log("Other:" @ OtherComponent.Owner);
}


/************************************************/
/*          ���������� � ������-����            */
/************************************************/

/** ���������� ������� ���� */
function Gorod_BasePath GetCurrentPath()
{
	return CurPath;
}

/** ���������� �������������� ������ */
function Gorod_AIVehicle GetControlledCar()
{
	return ControlledCar;
}

/************************************************/
/*          ���� ������                         */
/************************************************/

/** ��������� ��������� �������� �������� */
function SetControlledCarSignals()
{
	// ��������� ���������� � �������� ��������
	if(CurPath == none)
	{
		ControlledCar.LightsInfo.bLeftSignalLightOn = false;
		ControlledCar.LightsInfo.bRightSignalLightOn = false;
	}
	else if(CurPath.PathTurnType == PDR_Right)
	{
		ControlledCar.LightsInfo.bLeftSignalLightOn = false;
		ControlledCar.LightsInfo.bRightSignalLightOn = true;
	}
	else if(CurPath.PathTurnType == PDR_Left)
	{
		ControlledCar.LightsInfo.bLeftSignalLightOn = true;
		ControlledCar.LightsInfo.bRightSignalLightOn = false;
	}
	else 
	{
		ControlledCar.LightsInfo.bLeftSignalLightOn = false;
		ControlledCar.LightsInfo.bRightSignalLightOn = false;
	}

	// ���������� �������� �������� �� �������
	ControlledCar.VehicleLightsController.UpdateSignalLights();
}

/** ��������� ��� �������� ������� */
function TurnOffControlledCarSignals()
{
	ControlledCar.LightsInfo.bLeftSignalLightOn = false;
	ControlledCar.LightsInfo.bRightSignalLightOn = false;

	// ���������� �������� �������� �� �������
	ControlledCar.VehicleLightsController.UpdateSignalLights();
}

/****************************************************************************************************/
/*          ������� ��� ����������� ����������� ����������� �������� � ������������ �����           */
/****************************************************************************************************/

/** ���������� ���������� ����������, �� ������� ������-��� ����� ����������� */
function float GetSafeDistance()
{
	return SafeDistance;
}

/** ������������ ������� ������ */
function RegisterDangerousActor(Actor DangerousActor)
{
	if(DangerousActors.Find(DangerousActor) == INDEX_NONE)
		DangerousActors.AddItem(DangerousActor);
}

///** �������� ����������� �������� ������� */
//simulated function UnregisterDangerousActor(Actor DangerousActor)
//{
//	DangerousActors.RemoveItem(DangerousActor);
//}

///** ������� ������ ������� �������� */
//simulated function ClearDangerousActors()
//{
//	DangerousActors.Remove(0, DangerousActors.Length);
//}

DefaultProperties
{
	MIN_DISTANCE = 300;
	POINT_REACH_PRECISION = 50;

	countTick = 0;
	bDrivingCheckStarted = false;

	//RemoteRole = ROLE_SimulatedProxy;
}