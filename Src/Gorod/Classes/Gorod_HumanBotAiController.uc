class Gorod_HumanBotAiController extends AIController;
/** ����� ����������� ���� �������� */

`include(Gorod_Events.uci);


//��������� ����
var() Vector TempDest;
//����� � ������� ������ ���
var  Gorod_HumanBotPathNode Target;
//�����, � ������� ��� ��� ��������� ���
var  Gorod_HumanBotPathNode PrevTarget;
var  Gorod_HumanBotPathNode LastTarget;
//
var int selectedPath;
//
var int actual_node;
var int last_node;
/** �����, ������� ���� ��� ������ ��� �������� �������� �� ���� ��� ��� */
var int WaitingTime;
//������ �� ������ ����
var Gorod_HumanBot MyPawn;
var Vector CarLastLocation;
var Vector CarCurrLocation;
var Rotator CarRotation;
var Vector PerpVelocity;
var Gorod_HumanBotSpawner Spawner;
var Vector TempTarget;
var Actor a;
/** ����������, ������� ����������, ������ �� ��� �� ���� ��� �� ������� ������ */
var int goOnPath;
/** ��������� ������ ��� ����������� ������ */
var Gorod_HumanBotPathNode crossTarget;
/** ��������� ������ ��� ��������*/
var Gorod_HumanBotPathNode trgt;
/** ��������������� ����������������� ���� */
var array<Vector> fragmentedPathPoint;
/** ���� �� ��� �� ������������������ ���� */
var bool bIsFollowingOnFragmentedPath;
/** ��� ����� ��������� ���� */
var int curPathFragmentation;
/** ������������ ���������� ������ �� ���������� ���� */
var int curPathOffset;

var bool bIsCrossingTheRoad;

/** ����������� � ������� �����������, ����� �� ��� �� ����� */
var int imprecision;

// ������
var bool bStuck;

var Gorod_Event EventToSend;

function SetPawn(Gorod_HumanBot NewPawn, optional Gorod_HumanBotSpawner Sp)
{
	//�������� ������ �� ����, �������� ������������
    MyPawn = NewPawn;
	Possess(MyPawn, false);
	NewPawn.SetMovementPhysics();
	Target = NewPawn.FirstPoint;//������ ������ �����
	LastTarget = Target;//������ ����� �������� �����, � ������� ��� ��� ��������� ���
	//���� ���� ��������� ����� �������
	if(Sp!=none)
	{
		//��������� ������
		Spawner = Sp;
	}
	////�������� ������������
	//NewPawn.EnableFootPlacement();
	//������ ��� ������� ��������� �������, ����������� ����� ��� ��� ���
	SetTimer(5,true,'CheckObstacle');
}

/**
 *  ���������� �������� � ���������� �� -pi �� +pi �������� Actora � ���� �������.
 *  �� �����, � ����� ������� ������� �� � ������ ������.
 **/
function float GetAngleDifference(Actor Other)
{
	//���������� ��� ���������� ��������
	local float OtherHeading;
	local float SelfHeading;
	local Rotator OtherRot;
	local Rotator SelfVectorRot;

	//������� ������ �� Yaw, ������ �� �������� ����� Z
	OtherRot.Yaw = Other.Rotation.Yaw;
	//����������� ���� ��������, ��� ���� �� �� �������� �� Actor Other
	SelfVectorRot.Yaw = rotator(Pawn.Location - Other.Location).Yaw;

	//�������� ����
	OtherHeading = GetHeadingAngle(Vector(OtherRot));
	SelfHeading = GetHeadingAngle(Vector(SelfVectorRot));

	//���������� ��������
	return FindDeltaAngle(OtherHeading, SelfHeading);
}

/**
 * ��������, ���� ��������� ������� ������ �� ���� �������
 */
function TryToDisappear()
{
	// ���������������� ��� ������ ������� ������
	/*
	local array<Vector> Locations;
	local float MinDistance, CurrentDistance;
	local int i;

	
	// ��������, ���� ��������� ������� ������ �� ������
	Locations = Gorod_Game(WorldInfo.Game).GetPlayerControllersLocation();

	// ��������� ���������� �� ���������� ������
	if(Locations.length > 0)
	{
		MinDistance = vsize(Locations[0] - myPawn.location);

		for(i = 1; i < Locations.length; i++)
		{
			currentdistance = vsize(locations[i] - myPawn.location);
			if(currentdistance < mindistance)
			{
				mindistance = currentdistance;
			}
		}

		// ��������, ���� ��������� ���������� ������ �� ���� �������
		if(mindistance > `MAX_BOT_DISTANCE)
		{
			disappear();
		}
	}
	*/

	local PlayerController LocalPlayerController;

	LocalPlayerController = GetALocalPlayerController();
	if(LocalPlayerController != none && LocalPlayerController.Pawn != none)
	{
		if(VSize(LocalPlayerController.Pawn.Location - MyPawn.Location) > `MAX_BOT_DISTANCE)
		{
			disappear();
		}
	}


}

/**
 * ������������ � �����
 */
function Disappear()
{
	GotoState('Teleportating');
}

//����� ��-���������
auto simulated state Idle
{
	Begin:
		GotoState('FollowPath');
}

//� ���� ������  ��� ������� �� ������ ����
simulated state FollowPath
{
	///** ���������, ����� ���� ������� � ��� ������ ��������*/
	//event EncroachedBy(Actor Other)
	//{
	//}
	/** ���������, ����� ���� ������� */
	simulated event bool NotifyBump(Actor Other, Vector HitNormal)
	{
		BumpAction(Other);
		return true;
	}

	/*simulated function CheckDistantion()
	{
		local array<Vector> Locations;
		local float MinDistance;
		local int i;

		Locations = Gorod_Game(WorldInfo.Game).GetPlayerControllersLocation();

		// ��������� ���������� �� ���������� ������	
		if(Locations.Length > 0)
		{
			MinDistance = VSize(Locations[0] - MyPawn.Location);

			for(i = 1; i < Locations.Length; i++)
			{
				MyPawn = VSize(Locations[i] - MyPawn.Location);
				if(MyPawn < MinDistance)
				{
					MinDistance = MyPawn;
				}
			}

			// ��������, ���� ��������� ���������� ������ �� ���� �������
			if(MinDistance > `MAX_DISTANCE)
				Disappear();
		}
	}*/

  Begin:
	//MoveTo(PerpVelocity,,10);
	if(Target==none)
	{
		GoToState('Teleportating');
	}

	if(Role ==ROLE_Authority && MyPawn != none)
	{
		TryToDisappear();
		
		//

		if(MyPawn.ReachedDestination(Target))
		{
			//���������� ��������� �����
			PrevTarget = LastTarget;
			LastTarget  = Target;//= curTarget;
			//curTarget =  Target;

			//���� ���������� �� �����, ������������� ����
			if(Target.Paths.Length!=0)
			{
				//���� ���� �� ������
				if(selectedPath<0)
					goOnPath = rand(2); //�������� ���� ��� �����, �� ������������� ����
				else
					goOnPath = 0;       //������, ���� ��� ��� ������.
				if(goOnPath == 0)
				{
					Target = SelectTargetOnPath();
					if(selectedPath>=0)
					{
						if(!Target.Paths[selectedPath].CanGo())
							GoToState('WaitingForTraffic');
						else
							Target.Paths[selectedPath].GoIn(MyPawn);
					}
					else
					{
						if(Target == none)
							Target = SelectNonPathTarget(PrevTarget);
					}
				}
				else
				{
					trgt = SelectNonPathTarget(PrevTarget);
					if(trgt != none)
						Target = trgt;
					else
					{
						Target = SelectTargetOnPath();
						if(!Target.Paths[selectedPath].CanGo())
							GoToState('WaitingForTraffic');
						else
							Target.Paths[selectedPath].GoIn(MyPawn);
					}
				}
			}

			//�������� ���� �� ������ ��� ����
			else
			{

		//		if(Target.bIsBetweenLevels==true)
		//		{
		//			if(Target.LevelStreamingPathNode!=none)
		//				Target = Target.LevelStreamingPathNode;
		//			else
						if(Target.NextPathNodes.Length>0)
						{
							Target = Target.GetNextPathNode(PrevTarget);

						}
						else
						{
							GoToState('Teleportating');
						}

		//		}
		//		else
		//		{
		//			Target = Target.NextPathNodes[0];
		//		}
			}

			if(Target == none)
				GoToState('Teleportating');
			//�������� ������� ����������������� ����
			createNonLinearPath(LastTarget.Location,Target.Location, curPathFragmentation,curPathOffset, fragmentedPathPoint);
			bIsFollowingOnFragmentedPath = (fragmentedPathPoint.Length > 0);
		}
		else //���� �� �������� �����
		{
			if(bIsFollowingOnFragmentedPath)
			{
				//imprecision - �����������
				if(VSize(fragmentedPathPoint[0] - myPawn.Location)>imprecision)
					MoveTo(fragmentedPathPoint[0]);
				else
				{
					fragmentedPathPoint.RemoveItem(fragmentedPathPoint[0]);
					//�� ������
					////�������� ���������
					TryToDisappear();

					if(fragmentedPathPoint.Length==0)
					{
						bIsFollowingOnFragmentedPath = false;
							if(Target!=none)
							MoveToward(Target, Target);
					}
				}
			}
			else
			{
				if(Target!=none)
					MoveToward(Target, Target);
			}
			Sleep(0.1);
			goto 'Begin';

		}
		if(bIsFollowingOnFragmentedPath)
		{
			//imprecision - �����������
			if(VSize(fragmentedPathPoint[0] - Location)>imprecision)
				MoveTo(fragmentedPathPoint[0]);
			else
			{
				fragmentedPathPoint.RemoveItem(fragmentedPathPoint[0]);
				if(fragmentedPathPoint.Length==0)
				{
					bIsFollowingOnFragmentedPath = false;
					if(Target!=none)
						MoveToward(Target, Target);

				}
			}
		}
		else
		{
			if(Target!=none)
				MoveToward(Target, Target);
		}
		Sleep(0.1);
		goto 'Begin';
	}
}

/**
 *  ��������� ���������� ����, ��������� ������, ���������� ������ ����� ����.
 *  @param firstPoint - ��������� ����� ������������ ����
 *  @param lastPoint - �������� ����� ������������ ����
 *  @param pathFragmentation - ��� ����� ����������� ����
 *  @param offset - ������������ ���������� ������ �� ���������� ����
 *  @param arrRes - ��������� ������ �������
 *  */
function createNonLinearPath(Vector firstPoint,Vector lastPoint, int pathFragmentation, int offset, out array<Vector> fragmentVector)
{
	//////////////////// ��������� ����
	/** ��� ����� ���� ����� ����������� */
	//local int pathFragmentation;
	/** ������ ����, ������� ����� ����������� */
	local int Pathlength;
	/** ����� ������� ���������� ����  */
	local Vector nonlinearTarget;

	/**  ��������� ��������� ������ */
	local Vector NormalVector;
	/**  ��������� ���������������� ������ */
	local Vector PerpVector;
	/**  ��������� ������� ��� �������� ������� �� 90 �������� */
	local Rotator PerpRotator;

	/**  ��������� ��������� ������ */
	local float fragmentedPathLengh;
	local Vector LastNonlinearTarget;
	local Vector newNonLinearTarget;

	//  ��������������� ������� �������
	fragmentVector.Remove(0, fragmentVector.Length);

	nonlinearTarget = firstPoint;
	LastNonlinearTarget = nonlinearTarget;

	Pathlength = VSize(lastPoint - firstPoint);
	NormalVector = Normal(lastPoint - firstPoint);
	PerpRotator = rotator(NormalVector);
	PerpRotator.Yaw+=90*DegToUnrRot;
	PerpVector = Vector(PerpRotator);
	//������ ������������ ���� = 0
	fragmentedPathLengh = 0;

	//���� ���� �� ������ ��������
	if(Pathlength >= (2*pathFragmentation))
	{
		//���� ������ ������������ ���� ������ ����� ���� ���� ������ ��������� (���-�� ��������� ����� �� ���� �� ��������� ����)
		while((fragmentedPathLengh + 2 * pathFragmentation) <= (Pathlength + pathFragmentation))
		{
			nonlinearTarget = nonlinearTarget + NormalVector * pathFragmentation;
			//spawn(class'Gorod_AIVehicle_PathNode',,,nonlinearTarget);
			newNonLinearTarget = nonlinearTarget + PerpVector * rand(offset);
			//spawn(class'Gorod_AIVehicle_PathNode',,,newNonLinearTarget);
			fragmentedPathLengh+=VSize(nonlinearTarget - LastNonlinearTarget);
			LastNonlinearTarget = nonlinearTarget;
			fragmentVector.AddItem(newNonLinearTarget);
		}
	}
}


function Gorod_HumanBotPathNode SelectTargetOnPath()
{
	//TryToDisappear();

	//���� ������ ���� ������ 2 �� �� �������� �������� �� ����
	if(Target.Paths.Length<=0)
		`warn("Target.Paths.Length = 0 ");
	//���� ���� ��� �� ������
	if(selectedPath<0)
	{
		//�������� ��������� ����
		selectedPath = Target.GetNextPathIndex();
		if(Target.Paths[selectedPath].PathNodes.Length < 2)
		{
			`warn("Path mast have length greather than 1, Path = "$Target.Paths[selectedPath]);
			return Target.GetNextPathNode(PrevTarget);
		}
		//�������� ����
		Target.Paths[selectedPath].Select(MyPawn);//(MyPawn);
		Target.Paths[selectedPath].CrossRoad.RegisterBotInQueue(self);//(MyPawn);
		//�������� ������ ����� � ����, ���� ���� ������� ����, ����� ������������� ����� � ����, ���� ���� � ����� ����
		if(Target == Target.Paths[selectedPath].PathNodes[0])
			return Gorod_HumanBotPathNode(Target.Paths[selectedPath].PathNodes[1]);
		else
			return Gorod_HumanBotPathNode(Target.Paths[selectedPath].PathNodes[Target.Paths[selectedPath].PathNodes.Length-2]);

	}
	else
	{
		//���������, ��������� ��� ������ ����� � ����
		if(Target == Target.Paths[selectedPath].PathNodes[Target.Paths[selectedPath].PathNodes.Length-1] || Target == Target.Paths[selectedPath].PathNodes[0])
		{
			//������ � ����
			Target.Paths[selectedPath].GoOut(MyPawn);
			//��������� ���� �� ������, ��������
			selectedPath = Target.GetNextPathIndex(Target.Paths[selectedPath]);
			//���� �� �������� ������� ��� �� ����� ����, �� �������� ��� ������, �� ������ ���� ������
			if(selectedPath < 0 && Target.NextPathNodes.Length>0)
			{
				return Target.GetNextPathNode(PrevTarget);
			}
			//�������� ����
			else
			{
				Target.Paths[selectedPath].Select(MyPawn);
				Target.Paths[selectedPath].CrossRoad.RegisterBotInQueue(self);
			}
		}
		//������ ���������� ��������
		if(Target.NextPathNodes.Length>0)
		{
			return Target.GetNextPathNode(PrevTarget);
		}
		else
		{
			GoToState('Teleportating');
		}

	}
}
/** ���������� ���������, ������� �� ����������� ����. ���� ����� LastPathNode, �� ����������� ����� �����, ����� ���� */
function Gorod_HumanBotPathNode SelectNonPathTarget(optional Gorod_HumanBotPathNode LastPathNode)
{
	local int randNode;
	local array <Gorod_HumanBotPathNode> nonPath;
	nonPath = Target.GetNextNonPathPathNodes(LastPathNode);
	if(nonPath.Length==0)
		return none;
	randNode = rand(nonPath.Length);
	return nonPath[randNode];
}

//���� �����, ��������� ������
simulated function Died()
{
	//���� ����� ���� ���� ��� ������ - ������ � ����
	if(selectedPath>=0)
	{
		Target.Paths[selectedPath].GoOut(MyPawn);
	}
	//myPawn.bIsDied = true;
	if(Role==ROLE_Authority)
	{
			MyPawn.BotSetDyingPhisics(myPawn.HitLoc);
	}

}
/** ������� ���������� ������� ���� ��� ����������� */
function CheckObstacle()
{

	if(MyPawn!=none && IsInState('FollowPath') && VSize(MyPawn.Velocity) < 0.01	)
		GoToState('GetRound');
}
simulated state GetRound
{
	simulated event bool NotifyBump(Actor Other, Vector HitNormal)
	{
		BumpAction(Other);
		return true;
	}
Begin:
	//if(VSize(MyPawn.Velocity) < 0.01)
	//{

		if(bStuck)
		{
			GotoState('Teleportating');
		}
		else 
		{
			bStuck = true;
		}
		if(MyPawn !=none)
		{
			setTimer(5,false,'dontStuck');
			TempTarget = EvalTempTarget();
			MoveTo(TempTarget);
			MyPawn.SetViewRotation(Rotator(TempTarget));

			if(MyPawn.ReachedPoint(TempTarget,a))
			{
				GoToState('FollowPath');
			}
			else

				GoTo 'Begin';
		}
}


/** ������� ���������� ������ ���������� ������� */
function Vector EvalTempTarget()
{
		//��������� ������
	local Vector tempT;
	local int tempX;
	local int tempY;

	//���� ���� ��� � �� ������ ���������
	//���� ��� ����� ��� ����� �����
	tempT  = myPawn.Location;
	tempX = rand(60);
	tempX-=30;
	tempY = rand(60);
	tempY-=30;
	tempT.X += tempX;
	tempT.Y += tempY;
	return tempT;

}

//������, ��� ����� ����� ��������������, ���������� ������� StartMatch(), ��������� � GameInfo
//��� �������� ������� StartBot, � ������� ������� � ����� Dead. �������������� ���� �����:
simulated state Dead
{
MPStart:
	GoToState('FollowPath');
}

//���� � ���� ��� ������ ����� ����, �� �� ������ �����
simulated state Teleportating
{
	ignores NotifyBump, Bump, HitWall,  PhysicsVolumeChange, Falling,  FellOutOfWorld;
Begin:
	if(Spawner!=none)
	{
		if(Spawner.RelocManager != none)
			Spawner.RelocManager.AddPawnToReloc(MyPawn);
	}
	else
	{
		//������, ��� ��������� �� HumanBotSpawner
	}
}



simulated state WaitingForTime
{

	function bool CheckIsPathFreeFromCar()
	{
		local Vehicle act;
		foreach VisibleCollidingActors(class'Vehicle', act, 100.0, MyPawn.Location)
		{
			return false;
		}
		return true;
	}

	simulated event bool NotifyBump(Actor Other, Vector HitNormal)
	{
		local Vehicle v;
		v = Vehicle(Other);
		if(v!=none)
		{
			if(VSize(v.Velocity) >100)
			{
				MyPawn.GroundSpeed = 50;
				BumpAction(Other);
			}
		}
		return true;
	}
Begin:
	MyPawn.GroundSpeed = 0;
	sleep(4);
	if(CheckIsPathFreeFromCar())
	{
		MyPawn.GroundSpeed = 50;
		GoToState('FollowPath');
	}
	else
		goto 'Begin';
}

simulated state WaitingForTraffic
{
	simulated event bool NotifyBump(Actor Other, Vector HitNormal)
	{
		BumpAction(Other);
		return true;
	}
Begin:
    if(selectedPath<0)
	{
		GoToState('FollowPath');
	}
 	if(LastTarget.Paths[selectedPath].CanGo())
	{
		LastTarget.Paths[selectedPath].GoIn(MyPawn);
		GoToState('FollowPath');
	}
	else
		sleep(WaitingTime);
	goto 'Begin';
}

/** 
 *  �������, � ������� ��� ������, ���� �� ���������� ������ */
function bool cross(Gorod_HumanBotPathNode crossPathNode, optional int chanceToCrossTheRoad =100)
{
	local int i;
	local bool isCroassed;
	i = rand(100);
	i+=1;
	if(i<=chanceToCrossTheRoad)
	{
		isCroassed = true;
		crossTarget = crossPathNode;
		bIsCrossingTheRoad = true;
		GoToState('CrossingTheRoad');
	}
	else
		isCroassed = false;

	return isCroassed;
}

simulated function bool IsVehicleNear()
{
	local Vehicle Vehic;
	local Vector HitLoc;
	local vector HitNorm;
	foreach TraceActors(class'Vehicle',Vehic,HitLoc,HitNorm,MyPawn.Location, crossTarget.Location )
	{
		if(Vehic!=none)
			return true;
	}
	return false;
}

/** ����� ����������� ������ */
simulated state CrossingTheRoad
{
	ignores CheckObstacle;

	//���� �����
	simulated event bool NotifyBump(Actor Other, Vector HitNormal)
	{
		BumpAction(Other);
		return true;
	}
	/** � ���� ������� ��������� � ����� CrossingTheRoad , �� ����� Check  (�������� �� �����������) */
	function Check()
	{
		if(IsVehicleNear())
			GotoState('Late');
	}

Begin:
	//�����
	MyPawn.GroundSpeed=150;
	//���� �������� ����� � ������� �����, �������� ��������� ��� ������
	if(MyPawn.ReachedDestination(crossTarget))
	{
		ClearTimer('Check');
		PrevTarget = crossTarget;
		LastTarget  = crossTarget;
		Target = crossTarget;
		MyPawn.GroundSpeed=50;
		bIsCrossingTheRoad = false;
		GotoState('FollowPath');
	}
	else
	{
		//���� ���� �����������, ��������� � �����, � ������� ����, ����� ����������� ��������
		if(IsVehicleNear())
		{
			//����������� ����, ��������. ����
		}
		//������ ���������� ���������, ������� �� ����������� 
		SetTimer(0.5,true,'Check');
		sleep(0.1);
	 	MoveToward(crossTarget, crossTarget);
		goto 'Begin';
	}


}
/** ��� ������� ���������� */
simulated state Late
{
	ignores CheckObstacle;

	simulated event bool NotifyBump(Actor Other, Vector HitNormal)
	{
		BumpAction(Other);
		return true;
	}
Begin:

	if(!IsVehicleNear())
	{
		GotoState('CrossingTheRoad');		
	}	
	sleep(0.1);
	//���������������
	MoveTo(MyPawn.Location);

	goto 'Begin';

}


/** �����������, ����� ��������-���� ������� */
simulated function BumpAction(Actor Other)
{
	local Vehicle VN;
	//`log(Other);
	VN = Vehicle(Other);

	if(	VN !=none )
	{
		if(VSize(VN.Velocity)>100)
		{
			myPawn.HitLoc = VN.Location;
			Died();
			MyPawn.GroundSpeed=50;
			SendMsg(VN.Controller);
			myPawn.GoToState('Dying');
		}
		else
		{
			GotoState('WaitingForTime');
		}
	}
}


function SendMsg(Controller PC)
{
	local Common_PlayerController gpc;

	gpc = Common_PlayerController(PC);
	if(gpc==none)
		return;

	EventToSend = new class'Gorod_Event';
	EventToSend.sender = self;
	EventToSend.eventType = GOROD_EVENT_HUD;
	EventToSend.messageID = GOROD_PDD_ROAD_BUMP_HUMAN_BOT;
	if(gpc.EventDispatcher!=none)
		gpc.EventDispatcher.SendEvent(EventToSend);

}
function dontStuck()
{
	bStuck = false;
}
//�� ������



DefaultProperties
{
	bIsFollowingOnFragmentedPath = false;
	bIsCrossingTheRoad = false;

	//pathFragmentation = 100
	actual_node = 0
	last_node = 0
	bIsPlayer = true
	bSeeFriendly = true
	bGodMode = true
	WaitingTime = 0.01
	selectedPath = -1;
	imprecision = 55;
	curPathFragmentation = 200;
	curPathOffset = 50;
	bStuck = false;
}
