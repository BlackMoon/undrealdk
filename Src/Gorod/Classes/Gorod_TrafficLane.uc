class Gorod_TrafficLane extends Actor 
	placeable;

var (TrafficLane) Gorod_TrafficLane Left_TrafficLane;
var (TrafficLane) Gorod_TrafficLane Right_TrafficLane;

/**������ ����� �������� � ������ ������*/
var array <Gorod_AIVehicle> AIVehicleList;

/**������ �� ���� ������� ��������������� �� ������ ������ */
var private Gorod_AIVehicle AIVehicle_Relined ;

var CarX_Vehicle CarXVehicle;

var PlayerCarBase ZarnitzaVehicle;

struct SMCCoordainateStruct
{
	var vector A,B,C,D;
};

/** ���� ���������� ������� ����� �������� � ������. false - ��� �� �������, true- ������� */
var public bool bEnteredPathNodesFinded;

/** ���� ���� ��� ����� ���������� �� ������ ������. false - ����� �� ��������� �� ������ ������, true - ����� ��������� �� ������ ������ */
var public bool bDangerousPlayerIsHere;

/** ������ ������� ����� ����������� �� ������ ������*/
var public array <Gorod_AIVehicle_PathNode> EnteredPathNodeList;

/** ���������� ����� ���������� ������ �������(bottom) ������ ���� ������ */
var private Vector BottomMiddle;

/** ������ �� ������ ��� ���������, ������ ������ ��� ���������� ������� ������*/
var StaticMeshComponent SMC;

/** ��������� ���������� ���������� ����� ������ ���� ������ ������*/
var private SMCCoordainateStruct SMCCoordainate;
var private float SMCWidth;
var private float SMCLength;
var private float SMCWidthScaled;
var private float SMCLengthScaled;

function PostBeginPlay()
{
	SetCollisionType(COLLIDE_TouchAll);
	SMCWidthScaled = SMCwidth*DrawScale3D.Y;
	SMCLengthScaled = SMCLength*DrawScale3D.X;

	//����� ������ �����  �������
	
	SMCCoordainate.A.X=-SMCLengthScaled/2;
	SMCCoordainate.A.Y=-SMCWidthScaled/2;
	SMCCoordainate.A=(SMCCoordainate.A>>Rotation)+Location;
	SMCCoordainate.A.Z=Location.Z;

	//������ ������ ����� �����
	SMCCoordainate.B.X=-SMCLengthScaled/2;
	SMCCoordainate.B.Y=SMCWidthScaled/2;
	SMCCoordainate.B=(SMCCoordainate.B>>Rotation)+Location;
	SMCCoordainate.B.Z=Location.Z;
	// ������ ������� ����� �������
	SMCCoordainate.C.X=SMCLengthScaled/2;
	SMCCoordainate.C.Y=SMCWidthScaled/2;
	SMCCoordainate.C=(SMCCoordainate.C>>Rotation)+Location;
	SMCCoordainate.C.Z=Location.Z;
	//����� ������� ����� ������
	SMCCoordainate.D.X=SMCLengthScaled/2;
	SMCCoordainate.D.Y=-SMCWidthScaled/2;
	SMCCoordainate.D=(SMCCoordainate.D>>Rotation)+Location;
	SMCCoordainate.D.Z=Location.Z;
	
	
	// ����� ������ ����� (bottom)
	BottomMiddle.X= (SMCCoordainate.A.X+SMCCoordainate.B.X)/2;
	BottomMiddle.Y= (SMCCoordainate.A.Y+SMCCoordainate.B.Y)/2;
	BottomMiddle.Z= Location.Z;
	
	//DrawDebugSphere(BottomMiddle, 50,16, 0,0,0,true);
	//������ ��� ����� �������� � ������
	FindEnteredPathNodes();

	SetTimer(3,false,'GetNeighboringLane');
	SetTimer(3+5,false,'Wait');
}

/** ������� ������� ������� ��� ����� �������� � ������� ������ � ���������� �� � ������ EnteredPathNodeList  */
function private FindEnteredPathNodes()
{
	local Vector TempVector;
	local Gorod_AIVehicle_PathNode TempPathNode;
	foreach CollidingActors(class'Gorod_AIVehicle_PathNode', TempPathNode,VSize(Location-SMCCoordainate.A))
	{
		
			TempVector=(TempPathNode.Location-Location)<<Rotation;
			if(TempVector.X< SMCLengthScaled/2 && TempVector.X> -SMCLengthScaled/2 && TempVector.Y< SMCWidthScaled/2 && TempVector.Y> -SMCWidthScaled/2 )
				EnteredPathNodeList.AddItem(TempPathNode);
	}
	bEnteredPathNodesFinded=true;	
}

/** ������� ��������. ���� ���� �������� ������ �� �������� ���� EnteredPathNodeList � �������� SetRightLeftPathNodes */
function private Wait()
{
	if(Right_TrafficLane==none &&  Left_TrafficLane==none)
	{
		return;
	}
	if(Right_TrafficLane!=none && !Right_TrafficLane.bEnteredPathNodesFinded)
	{
		SetTimer(2,false,'Wait');
		return;
	}
	if(Left_TrafficLane!=none && !Left_TrafficLane.bEnteredPathNodesFinded)
	{
		SetTimer(2,false,'Wait');
		return;
	}
	SetRightLeftPathNodes();
}

/** �������� ������ �� �������� ������ */
function GetNeighboringLane()
{
	local float deltaAngle;
	local array <Gorod_TrafficLane> TrafficLaneSearchResult;
	local Gorod_TrafficLane TrafficLane;
	local Vector v;
	local int i;
	
	foreach CollidingActors( class'Gorod_TrafficLane',TrafficLane, 1.5*SMCWidthScaled ,Location)
	{
		if(TrafficLane==self)
			continue;
		if(TrafficLane!=none)
		{
			deltaAngle = FindDeltaAngle(Self.Rotation.Yaw * UnrRotToRad,TrafficLane.Rotation.Yaw * UnrRotToRad);	
			if(deltaAngle < PI/10 && deltaAngle > -PI/10 )
				TrafficLaneSearchResult.AddItem(TrafficLane);
		}
	}
	if(TrafficLaneSearchResult.Length>2)
	{   
		`log(self.Name @ "======================================== ������� ����� 2-� �������� �����");
		return;
	}
	
	for(i=0;i<TrafficLaneSearchResult.Length;i++)
	{
		v=TrafficLaneSearchResult[i].Location-Location;
		v=v<<Rotation;
		if(v.Y>0)
		{
			Right_TrafficLane=TrafficLaneSearchResult[i];
		}
		else
		{
			Left_TrafficLane=TrafficLaneSearchResult[i];
		}
	}



	if(Left_TrafficLane == none && Right_TrafficLane == none)
	{
		`log(self.Name @ ", for this traffic lane not find left and right traffic lane");
	}
}

/** ������� */
function private SetRightLeftPathNodes()
{
	local Gorod_AIVehicle_PathNode TempPathNode;
	local int i;

	for(i=0;i<EnteredPathNodeList.Length;i++)
	{
		if(Left_TrafficLane!=none)
		{
			 TempPathNode= Left_TrafficLane.GetPointForEvolution(VSize(EnteredPathNodeList[i].Location-BottomMiddle));
			 if(TempPathNode!=none)
			 {
				EnteredPathNodeList[i].leftChangelineNode=TempPathNode;
			 }
		}
		if(Right_TrafficLane!=none)
		{
			TempPathNode=Right_TrafficLane.GetPointForEvolution(VSize(EnteredPathNodeList[i].Location-BottomMiddle));
			if(TempPathNode!=none)
			{
				EnteredPathNodeList[i].rightChangelineNode=TempPathNode;
			}
		}
	}
}

/***/
function public Gorod_AIVehicle_PathNode GetPointForEvolution (float lenght)
{
	local int i;
	local Gorod_AIVehicle_PathNode MyPathNode;
	local  float l;

	local float a;
	
	lenght=lenght+150;

	l=999999999999;
	for(i=0; i<EnteredPathNodeList.Length;i++)
	{
		a=VSize(EnteredPathNodeList[i].Location-BottomMiddle);
		
		if(a>lenght && a<l )
		{
			l=VSize(EnteredPathNodeList[i].Location-BottomMiddle);
			MyPathNode=EnteredPathNodeList[i];
		}
	}
	return MyPathNode;
}


event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	
	if(Zarnitza_VehicleTouchHelperActor(Other) != none)
	{
		//`log(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
		ZarnitzaVehicle = PlayerCarBase(other.Owner);
		FindEnteredBots();
		AIVehicle_Relined=none;
		setTimer(1,true,'CheckCarXVehicleSirenaSignal');
		return;
		
	}

	CarXVehicle = CarX_Vehicle(Other);
	if(CarXVehicle!=none)
	{
		FindEnteredBots();
		AIVehicle_Relined=none;
		setTimer(1,true,'CheckCarXVehicleSirenaSignal');
		return;
		
	}
}
event UnTouch( Actor Other)
{
	super.UnTouch( Other);

	if(Zarnitza_VehicleTouchHelperActor(Other) != none)
	{
		//`log("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
		ClearTimer('CheckCarXVehicleSirenaSignal');
		bDangerousPlayerIsHere=false;
		AIVehicle_Relined=none;
		return;
	}

	//��� ��� ������ ������� �������� ������, �������� ���
	if(CarX_Vehicle(Other)!=none)
	{
		ClearTimer('CheckCarXVehicleSirenaSignal');
		bDangerousPlayerIsHere=false;
		AIVehicle_Relined=none;
		return;
		
	}
}

function CheckCarXVehicleSirenaSignal()
{
	if(ZarnitzaVehicle!=none)
	{
		//`log("===================================================================");	
		// todo �������� ������ � PlayerCarBase
		if(true/*ZarnitzaVehicle.bSirenaSignal*/)
		{
			bDangerousPlayerIsHere=true;
			ClearEnteredBotsList();
			FindEnteredBots();
			CheckBotsForRelaning();
		}
		else
		{
			bDangerousPlayerIsHere=false;
		}
	}
	if(CarXVehicle!=none)
	{
		if(CarXVehicle.bSirenaSignal)
		{
			bDangerousPlayerIsHere=true;
			ClearEnteredBotsList();
			FindEnteredBots();
			CheckBotsForRelaning();
		}
		else
		{
			bDangerousPlayerIsHere=false;
		}
	}
}

private function CheckBotsForRelaning()
{
	local int i;
	local Gorod_AIVehicle AIVehicle;
	local  float a,l,lenght;

	//`log("===================================================================");	
	
	if(CarXVehicle!=none)
	{
		lenght=VSize(BottomMiddle-CarXVehicle.Location);
	}
	if(ZarnitzaVehicle!=none)
	{
		lenght=VSize(BottomMiddle-ZarnitzaVehicle.Location);
	}
	l=999999999999;
	for(i=0; i<AIVehicleList.Length;i++)
	{
		a=VSize(AIVehicleList[i].Location-BottomMiddle);
		
		if(a>lenght && a<l )
		{
			l=a;
			AIVehicle=AIVehicleList[i];
		}
	}
	if(AIVehicle!=none)
	{
		//��������� ������������� �� �����
		//FlushPersistentDebugLines();
		if( Right_TrafficLane!=none &&  Right_TrafficLane.bDangerousPlayerIsHere == false )
		{
			if(AIVehicle.Target.rightChangelineNode!=none && AIVehicle_Relined!= AIVehicle)
			{
				//���� � ������� ����� ������ ����� �� ��������������� (����� �������� �������������� ������������) � �����, � ������� ��� ������ ������������ ��������� ��� ������������
				//if(Gorod_AIVehicle_Controller( AIVehicle.Controller).ControlledCar.Target.ChangeLineAiVehicle_Controller == none && AIVehicle.Target.rightChangelineNode.isSafeForChangeLine())
				//{
					//������ ������������ �������
					AIVehicle_Relined=AIVehicle;
					Gorod_AIVehicle_Controller( AIVehicle.Controller).SetTargetForRelining( AIVehicle.Target.rightChangelineNode);
				//}
			}
				
		}
		
		//��������� ������������� ������
		if(Left_TrafficLane!=none && Left_TrafficLane.bDangerousPlayerIsHere == false )
		{
			if(AIVehicle.Target.leftChangelineNode!=none && AIVehicle_Relined!= AIVehicle)
			{
				//���� � ������� ����� ������ ����� �� ��������������� (����� �������� �������������� ������������) � �����, � ������� ��� ������ ������������ ��������� ��� ������������
				//if(Gorod_AIVehicle_Controller( AIVehicle.Controller).ControlledCar.Target.ChangeLineAiVehicle_Controller == none && AIVehicle.Target.rightChangelineNode.isSafeForChangeLine())
				//{	
					//������ ������������ ������
					AIVehicle_Relined=AIVehicle;
					Gorod_AIVehicle_Controller( AIVehicle.Controller).SetTargetForRelining( AIVehicle.Target.leftChangelineNode);
				//}
			}
			else
			{
				//��������������
			}
		}
	}
}

function private FindEnteredBots()
{
	local Vector TempVector;
	local Gorod_AIVehicle AIVehicle;
	foreach CollidingActors(class'Gorod_AIVehicle', AIVehicle,VSize(Location-SMCCoordainate.A))
	{
			TempVector=(AIVehicle.Location-Location)<<Rotation;
			if(TempVector.X< SMCLengthScaled/2 && TempVector.X> -SMCLengthScaled/2 && TempVector.Y< SMCWidthScaled/2 && TempVector.Y> -SMCWidthScaled/2 )
				AIVehicleList.AddItem(AIVehicle);			
	}
}
function private ClearEnteredBotsList()
{
	AIVehicleList.Remove(0,AIVehicleList.Length);
}


DefaultProperties
{
	SMCWidth = 1225;
	SMCLength = 1225;
	bEnteredPathNodesFinded=false;
	bDangerousPlayerIsHere=false;
	
	Begin Object Class=StaticMeshComponent Name=MBox 
		StaticMesh = StaticMesh'Tools_1.Meshes.S_Road_lane_1'
		CollideActors = true
		BlockActors = false
		BlockRigidBody=false
		RBChannel=RBCC_GameplayPhysics
		RBCollideWithChannels=(Default=TRUE,BlockingVolume=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE,Vehicle=TRUE)
		HiddenGame = true  //<------
	End Object
	CollisionType = COLLIDE_TouchAll;
	Components.Add(MBox);
	CollisionComponent = MBox;
	SMC=MBox;

	bSkipActorPropertyReplication = true
	bAlwaysRelevant = false
}
