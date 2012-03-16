class Gorod_CrossRoad extends Actor dependsOn(Gorod_CrossRoadsTrigger) placeable;

`include(Gorod_Events.uci);

/** ���� ����������� */
enum CrossRoadType
{
	CROADTYPE_SIMPLE,           // ����������� ��� ���������
	CROADTYPE_TRAFFICLIGHT      // ����������� �� ����������
};

enum CrossRoadEvents
{
	CREVT_MOVEONRED,                     // ������ �� ������� ���� ���������
	CREVT_MOVEONGREEN,                   // ������ �� ������� ���� ���������

	CREVT_ENTERFROMWRONGSIDE,            // ����� �� ����������� � ������������ �������
	CREVT_LEAVEFROMWRONGSIDE,            // ����� � ����������� � ������������ �������
};

/** ��� ����������� */
var(CrossRoad) CrossRoadType CrossRoad_Type;

/** ��� �������� */
var(CrossRoad) StaticMeshComponent MeshBox;

/** �������� ��� */
var(CrossRoad) SkeletalMeshComponent SkelBox;

/** ��������, ������������� ����������� (����������� � ���������) */
var(CrossRoad) array<Gorod_CrossRoadsTrigger> Triggers;

/** ������ ��� �������� �������, �������� �� ������ ����������� */
var array<Gorod_RegistryEntry> RegisteredControllers;

var int countTick;

var Gorod_Event EventToSend;

// ����������� �� ����������� �������������� ================================================
enum TrafficLightsState
{
	TLIGHTS_ON,             // ��������� ��������
	TLIGHTS_OFF,            // ��������� ��������� ���������
	TLIGHTS_DISABLED        // ��������� �������� � ������ ��������� �������
};

/** ������� ����� ������ ���������� */ 
var(CrossRoad) TrafficLightsState CurrentTLState;

/** ����� ������� �������� ����� ��������� */
var(CrossRoad) float RedLightTime;

/** ����� ������� �������� ����� ��������� */
var(CrossRoad) float GreenLightTime;

/** ���� ���������� �������� �� ����������� (��� ������������ �� ����������) */
var bool RedLightOn;

/** �����, ��������� � ������ ������� ������ ���� �� ������ ��������� */
var float LightTimeElapsed;

/** �����, ����� �������� �������� �������� ��������� */
var(CrossRoad) float LightWorkEnableTime;

/** ����� ������ ������ ���������� */
var float LightWorkStartTime;

/** ����� ������ ������ ����������� */
var float CrossRoadWorkStartTime;

/** ����, ��������������� ��������� ������������� ����������� ����������� (true - ��������� �������� )*/
var(CrossRoad) bool CrossRoadWorkingState;

/** ��������� ��� ���������� */
//var(CrossRoad) array<Gorod_TrafficLight> TrafficLights;

var(CrossRoad) Gorod_TrafficLight TopTrafficLight;
var(CrossRoad) Gorod_TrafficLight BottomTrafficLight;
var(CrossRoad) Gorod_TrafficLight LeftTrafficLight;
var(CrossRoad) Gorod_TrafficLight RightTrafficLight;

//==========================================================================================================

/** ������� ������ ������� ����� */
var private array<AIController> WaitingBots;

/** ������ ���� ����� ���������� */
var/*(CrossRoad)*/ array<Gorod_BasePath> Paths;

/** ��������� ����� � ��������� ���������� */
var private array<Gorod_BasePath> 
	OpenedPaths,            // ��������
	ClosedPaths,            // ��������
	NonePaths;              // ���� � ������������� ����������


struct CrossIndex
{
	var int A;
	var int B;
};

/** ������ ��� �������������� Path'��, ������� � ���� ��� �������� �� ������� Paths */
var array<CrossIndex> Crosses;

var private Gorod_Event EventToDisp;

simulated function PostBeginPlay()
{
	local Gorod_CrossRoadsTrigger T;
	local int i, j;

	// ������������� ��� ��������
	SetCollisionType(COLLIDE_TouchAll);

	// ��������� ���� ��������� ������ �� ������ ��������� ������
	foreach Triggers(T)
	{
		T.ParentCrossroad = self;
	}

	CrossRoadWorkStartTime = WorldInfo.TimeSeconds;
	
	// ���������� ���� ������ � ������ � ��������� ������ Crosses ������ ������� ������
	for(i = 0; i < Paths.Length; i++)
	{
		// ���������� ��������� ��� ���� �� ��������� ����� � ������������ ����������
		NonePaths.AddItem(Paths[i]);

		Paths[i].RegCrossRoad(self);

		for(j = i+1; j < Paths.Length; j++)
		{
			Paths[i].PathState = PS_None;

			if(PathCross(Paths[i], Paths[j]))
			{
				Crosses.Add(1);
				Crosses[Crosses.Length - 1].A = i;
				Crosses[Crosses.Length - 1].B = j;
			}
		}
	}

	EventToDisp = new class'Gorod_Event';
	EventToDisp.eventType = GOROD_EVENT_PDD;

	EventToSend = new class'Gorod_Event';
	EventToSend.eventType = GOROD_EVENT_HUD;
	EventToSend.sender=self;
}

function ReportPaths()
{
	local Gorod_BasePath p;

	`log("OPENED");
	foreach OpenedPaths(p)
	{
		`log(p @ p.DrivingPawns.Length @ p.WantToDrivePawns.Length @ p.CanGo());
	}
	`log("CLOSED");
	foreach ClosedPaths(p)
	{
		`log(p @ p.DrivingPawns.Length @ p.WantToDrivePawns.Length @ p.CanGo());
	}
	`log("NONE");
	foreach NonePaths(p)
	{
		`log(p @ p.DrivingPawns.Length @ p.WantToDrivePawns.Length @ p.CanGo());
	}
}

/** ������ �� ����������� ���� � ������� �� ������ ����������� */
function RegisterBotInQueue(AIController bot)
{
	WaitingBots.AddItem(bot);
}

/************************************************************************/
/*          ���������� ������� ��������� �������������� �����           */
/************************************************************************/

/**
 * �������� �� ����������� ���� �����
 */
function bool PathCross(Gorod_BasePath P1, Gorod_BasePath P2)
{
	local int i1, i2, i;
	
	if (P1 == none || P2 == none || P1.PathNodes.Length == 0 || P2.PathNodes.Length == 0)
		return false;
	
	if(P1.PathNodes[0] == P2.PathNodes[0])
		i = 1;
	else
		i = 0;

	// ���������� ������� ����� P1 � P2 ������ � ������
	for(i1 = i; i1 < P1.PathNodes.Length - 1; i1++)
	{
		for(i2 = i; i2 < P2.PathNodes.Length - 1; i2++)
		{
			if (P1.PathNodes[i1] != none && P2.PathNodes[i2] != none && P1.PathNodes[i1+1] != none && P2.PathNodes[i2+1] != none)
			if(PathSectionCross(P1.PathNodes[i1].Location, P1.PathNodes[i1+1].Location, P2.PathNodes[i2].Location, P2.PathNodes[i2+1].Location))
				return true;
		}
	}

	return false;
}

/**
 * ��������� �������� �� ������� [A1; A2] � [A3; A4] ���������������. CrossPoint - ����� ����������� ������, �� ������� ���������� ������� (���� �� ������������ - none)
 */
function bool PathSectionCross(Vector A1, Vector A2, Vector A3, Vector A4, optional out Vector CrossPoint)
{	
	local float Ua, Ub, Zn;
	local float eps;

	// ���������, ������������ �� �������, ��������� ���������� Z (�������� �����http://algolist.manual.ru/maths/geom/intersect/lineline2d.php)
	
	eps = 0.0001;

	Zn = (A4.Y-A3.Y)*(A2.X-A1.X) - (A4.X-A3.X)*(A2.Y-A1.Y);
	
	// ���� ��������� ������ ���������
	Ua = ((A4.X-A3.X)*(A1.Y-A3.Y) - (A4.Y-A3.Y)*(A1.X-A3.X));
	Ub = ((A2.X-A1.X)*(A1.Y-A3.Y) - (A2.Y-A1.Y)*(A1.X-A3.X));

	if(Abs(Zn) < eps)
	{
		if(Abs(Ua) < eps)
		{
			// ������ ���������, ������� ����� �� ����� ������ 
			if(PathSectionContainsPoint(A1, A2, A3))
				// ���� A3 ����� �� ������� [A1; A2]
				return true;
			else if(PathSectionContainsPoint(A1, A2, A4))
				// ���� A4 ����� �� ������� [A1; A2]
				return true;
			else
				return false;
		}
		else
		{
			// ������ �����������
			return false;
		}
	}

	Ua /= Zn;

	CrossPoint = A1 + Ua*(A2 - A1);

	if(Ua < -0.0001 || Ua > 1.0001)
		// ������� A ������������ �� ������ ���������
		return false;

	Ub /= Zn;
	if(Ub < -0.0001 || Ub > 1.0001)
		// ������� B ������������ �� ������ ���������
		return false;
	
	return true;
}

function bool PathSectionContainsPoint(Vector A1, Vector A2, Vector A)
{
	local float p;

	p = (A.X - A2.X)/(A1.X - A2.X);
	if(Abs((A.Y - p*A1.Y + (1 - p)*A2.Y)) < 0.0001)
		return true;
	else
		return false;
}

/**
 * ��������� �������� �� ���� path
 */
function SetClosedFor(Gorod_BasePath path)
{
	local CrossIndex CI;
	
	// ��������� �������������� ����
	foreach Crosses(CI)
	{
		if(Paths[CI.A] == path)
			MoveToClosed(Paths[CI.B]);
		else if(Paths[CI.B] == path)
			MoveToClosed(Paths[CI.A]);
	}
}

function UpdatePaths()
{
	local Gorod_BasePath P, CurrentPath;
	local AIController VC;
	local Pawn WantToDrivePawn;
	local Gorod_AIVehicle_Controller carCtrl;
	local Gorod_HumanBotAiController botCtrl;
	
	// ������� ClosedPaths
	while (ClosedPaths.Length > 0)
	{
		NonePaths.AddItem(ClosedPaths[0]);
		ClosedPaths.Remove(0, 1);
	}

	// ��������� ��� ������� ���� � ClosedPaths
	foreach Paths(P)
	{
		if(P.bIsClosed)
		{
			ClosedPaths.AddItem(P);
			OpenedPaths.RemoveItem(P);
			NonePaths.RemoveItem(P);
		}
	}

	// ��� ������� �������� ����, �� �������� ��� �������� ���� (����������� �����)
	// ��������� �������������� � ��� ���� � ClosedPaths
	foreach Paths(P)
	{
		if(P.bIsClosed && P.DrivingPawns.Length > 0)
		{
			SetClosedFor(P);
		}
	}

	// �� P1 � P3 ���������� ����, �� ������� �� ���� � �� ����� ����� ����
	foreach OpenedPaths(P)
	{
		if(P.DrivingPawns.Length == 0 && P.WantToDrivePawns.Length == 0)
		{
			OpenedPaths.RemoveItem(P);
			NonePaths.AddItem(P);
		}
	}

	// ����������� �������� ���� � ������������ � P1
	foreach OpenedPaths(P)
	{
		SetClosedFor(P);
	}

	// ������������ ���� �� ������� ���� ����� ����,
	// �������� ������� ����������� ����� �� ����������
	foreach WaitingBots(VC)
	{
		// ���� ��� ������ ���� ������� ��������� � NonePaths � ��� �� ���� �� ����, ��
		// ��������� ���� ����
		carCtrl = Gorod_AIVehicle_Controller(VC);
		if(carCtrl != none)
		{
			CurrentPath = carCtrl.CurPath;
			WantToDrivePawn = carCtrl.ControlledCar;
		}

		botCtrl = Gorod_HumanBotAiController(VC);
		if(botCtrl != none && botCtrl.Target != none)
		{
			if(botCtrl.Target.Paths.Length > 0 && botCtrl.selectedPath >= 0 && botCtrl.selectedPath < botCtrl.Target.Paths.Length)
			{
				CurrentPath = botCtrl.Target.Paths[botCtrl.selectedPath];
				WantToDrivePawn = botCtrl.MyPawn;
			}
		}
				
		if(CurrentPath != none && NonePaths.Find(CurrentPath) != INDEX_NONE && CurrentPath.WantToDrivePawns.Find(WantToDrivePawn) != INDEX_NONE)
		{
			OpenedPaths.AddItem(CurrentPath);
			NonePaths.RemoveItem(CurrentPath);
			SetClosedFor(CurrentPath);
		}
	}
	
	// ��������� ��������� �����
	foreach OpenedPaths(P)
	{
		//if(P.PathState != PS_Opened)
		//	P.DrawLines(0, 255);

		P.PathState = PS_Opened;
	}

	foreach ClosedPaths(P)
	{
		//if(P.PathState != PS_Closed)
		//	P.DrawLines(255, 0);

		P.PathState = PS_Closed;
		
	}

	foreach NonePaths(P)
	{
		//if(P.PathState != PS_None)
		//	P.DrawLines(0, 0);

		P.PathState = PS_None;
	}
}

/** 
 * ���������� ���� �� ��������� ����� � ������������� ���������� �� ��������� �������� �����
 */
function MoveToClosed(Gorod_BasePath path)
{
	if(ClosedPaths.Find(path) == -1)
	{
		NonePaths.RemoveItem(path);
		ClosedPaths.AddItem(path);
	}
}

/**
 * RegisterController - ������������ ��������� �� ����������� ������
 */
function RegisterController(Controller c)
{
	local Gorod_RegistryEntry re;

	re = new class'Gorod_RegistryEntry';

	re.pc = c;

	RegisteredControllers.AddItem(re);
}

/**
 * RemoveController - ������� ������ �� ���� ������������������ �������
 */
function RemoveController(name nm)
{
	local int i;
	local PlayerController pc;

	for(i=0; i<RegisteredControllers.Length; i++)
	{
		if(RegisteredControllers[i].pc.Name == nm)
		{
			foreach WorldInfo.AllControllers(class'PlayerController', pc)
			{
				//pc.ClientMessage("Controller removed: " $ nm);
			}
			RegisteredControllers.Remove(i, 1);
			break;
		}
	}
}

/**
 * GetRegEntryByName - ���� ����������� � ����, ���� ������� - ���������� ������ � ���
 */
function Gorod_RegistryEntry GetRegEntryByName(name nm)
{
	local Gorod_RegistryEntry rentry;
	local int i;

	for(i=0; i<RegisteredControllers.Length; i++)
	{
		if(RegisteredControllers[i].pc.Name == nm)
		{
			rentry = RegisteredControllers[i];
			break;
		}
	}

	return rentry;
}


event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	local Controller pc;
	local Gorod_RegistryEntry RG;
	local Common_PlayerController playc;

	// ���� �������� - ������ ������
	if(Zarnitza_VehicleTouchHelperActor(Other) != none)
	{
		playc = Common_PlayerController(Zarnitza_VehicleTouchHelperActor(Other).PC);

		if(playc != none)
		{

			// ������������ ������ � ����
			RG = GetRegEntryByName(playc.Name);
			if(RG == none)
			{
				RegisterController(playc);
			}
			else
			{
				// ���������� �������� �����������, ������ ��� ������������������. ������ �� ������ ����
				`warn("Controller touch crossroads when its already registered");
			}

			EventToDisp.messageID = 3011;//GOROD_PDD_CROSSROAD_ENTER
			EventToDisp.eventType = GOROD_EVENT_PDD;
			playc.EventDispatcher.SendEvent(EventToDisp);
		}

		return;
	}

	// ���������, �������� �� �������� ������������
	pc = Controller(Other.Owner);

	if(pc != none)
	{
		RG = GetRegEntryByName(pc.Name);
		if(RG == none)
		{
			RegisterController(pc);
		}
		else
		{
			// ���������� �������� �����������, ������ ��� ������������������. ������ �� ������ ����
			`warn("Controller touch crossroads when its already registered");
		}
	}
}

event UnTouch( Actor Other )
{
	local Controller c;
	local Gorod_RegistryEntry rentry;
	local int i;
	local Common_PlayerController playc;

	// ���������, �������� �� �������� ������� ������
	if(Zarnitza_VehicleTouchHelperActor(Other) != none)
	{
		playc = Common_PlayerController(Zarnitza_VehicleTouchHelperActor(Other).PC);

		if(playc != none)
		{
			rentry = GetRegEntryByName(playc.Name);
			if(rentry != none)
			{
				// ������� ����������
				RemoveController(playc.Name);

				// �������� ���������
				EventToDisp.messageID = 3012;//GOROD_PDD_CROSSROAD_EXIT
				EventToDisp.eventType = GOROD_EVENT_PDD;
				playc.EventDispatcher.SendEvent(EventToDisp);
			}
			else
			{
				// ����� �� ��������������� - ������ ���� �� ������
				`warn(playc @ "not registered when it leaving crossroad");
			}
		}

		return;
	}

	// ���������, �������� �� �������� ������������  ---------------------------------------------------------------
	if(Controller(Other.Owner) == none)
		return;
	else
		c = Controller(Other.Owner);

	rentry = GetRegEntryByName(c.Name);

	if(rentry != none)
	{
		if(Gorod_AIVehicle_Controller(rentry.pc) != none)
		{
			// ���� ��� ���, ������� ��� �� ������� �� ������ �����������
			for(i=0; i<WaitingBots.Length; i++)
			{
				if(WaitingBots[i].Name  == c.Name)
				{
					WaitingBots.Remove(i, 1);
					break;
				}
			}
		}
		
		// ������� ����������
		RemoveController(c.Name);
	}
	else
	{
		// �������� ����, ���� ���������� �� ���������������. ������ ���� �� ������
		//`warn("You have not registered yet " $ c.Name);
	}
}

simulated function Tick( FLOAT DeltaSeconds ) 
{
	// ����� ������� ��������� ��������� ����������
	super.Tick(DeltaSeconds);

	// �������� �������� �� ������, � ������������ � ���� - ������� ���������� �� ������ �����
	// ���������� ���, ���������������.
	/*
	if(RegisteredControllers.Length == 0 && WaitingBots.Length > 0)
	{
		//WaitingBots[0].ControlledCar.Target.Open();
	}
	else
	{
		//
	}
	*/

	if(CrossRoad_Type == CROADTYPE_TRAFFICLIGHT)
	{
		UpdateTrafficLights(DeltaSeconds);
	}

	countTick ++;
	if (countTick > 5)
	{
		UpdatePaths();
		countTick = 0;
	}
	
}

/// !!!!!!
function UpdateTrafficLights(float delta)
{
	local float CurTime;

	CurTime = WorldInfo.TimeSeconds;

	switch(CurrentTLState)
	{
	case TLIGHTS_ON:
		if(LightWorkEnableTime <= CurTime - CrossRoadWorkStartTime && CrossRoadWorkingState == false)
		{
			LightWorkStartTime = CrossRoadWorkStartTime + LightWorkEnableTime;
			CrossRoadWorkingState = true;
			RedLightOn = true;
		}

		// ��������� ��������
		if(CrossRoadWorkingState == true)
		{
			if(RedLightOn == true)
			{
				if(CurTime >= LightTimeElapsed + RedLightTime)
				{
					
				}
			}
		}
		break;

	case TLIGHTS_OFF:
		break;

	case TLIGHTS_DISABLED:
		break;

	default:
	}

	
}

/**
 * OnTriggerTouch - ������� ���������� ��� ������� ������ �� ���������, ������������� ������� ����������� 
 */ 
function OnTriggerTouch(Gorod_CrossRoadsTrigger trg, Actor toucher)
{
	local Gorod_RegistryEntry rentry;
	local Zarnitza_VehicleTouchHelperActor helper;

	// ���������, �������� �� �������� �������
	helper = Zarnitza_VehicleTouchHelperActor(toucher);

	if(helper == none)
		return;

	if(Common_PlayerController(helper.PC) != none)
	{
		// �������� - �����, ���� ��� � ���� ������������������ �������
		rentry = GetRegEntryByName(Common_PlayerController(helper.PC).Name);

		if(rentry.pc != none)
		{
			// ����� ��� ���������������, ���������
			CheckTrigger(trg, rentry);
			//Gorod_PlayerController(rentry.pc).ClientMessage(rentry.Message);

			// #ToDo SendEvent
			// Gorod_PlayerController(rentry.pc).ClientShowMsg(MESSAGE_INFORM, rentry.Message);
			//Gorod_PlayerController(rentry.pc).MessageManager.PushMessage(rentry.Message);
			//Gorod_PlayerController(rentry.pc).showMsg();
		}
		else
		{
			// ������ ��� � ����, �������
			//Gorod_PlayerController(rentry.pc).ClientMessage("You are not registered");

			// #ToDo SendEvent
			// Gorod_PlayerController(rentry.pc).ClientShowMsg(MESSAGE_INFORM, "You are not registered");

		}
		return;
	}
}

/** 
 *  OnTriggerUnTouch - ���������� ���������, �� ������� �������� ����� ����� 
 */
function OnTriggerUnTouch(Gorod_CrossRoadsTrigger trg, Actor toucher)
{
	//
}

/** 
 *  CheckTrigger - �������� ��������, �������� �������� �����
 */
function CheckTrigger(Gorod_CrossRoadsTrigger trg, out Gorod_RegistryEntry rentry)
{
	local TriggerReference local_trRef;
	//----------------------------------------------------------------------------------------------------------------------------------------------
	rentry.Message = "";

	switch(CrossRoad_Type)
	{
	case CROADTYPE_SIMPLE:
		switch(trg.trType)
		{
		case TRIGGERTYPE_ENTRY:
			// ���������, � ������ �� ��� ����� �������� ������ ���� ��������
			if(rentry.GetFirstTouchedTrigger() != none)
			{
				rentry.Message = "";

				// ��� ��������, ���� ���� ������� � ����������� ������ �������
				
				local_trRef = rentry.GetFirstTouchedTrigger().FindTriggerReference(trg);

				if(local_trRef.MessageID > 0)
				{
					EventToDisp.messageID = rentry.GetFirstTouchedTrigger().FindTriggerReference(trg).MessageID;
					EventToDisp.eventType = GOROD_EVENT_PDD;
					Common_PlayerController(rentry.pc).EventDispatcher.SendEvent(EventToDisp);

					if(local_trRef.bShowMessageInHUD)
					{
						EventToDisp.eventType = GOROD_EVENT_HUD;
						Common_PlayerController(rentry.pc).EventDispatcher.SendEvent(EventToDisp);
					}
				}
				EventToDisp.eventType = GOROD_EVENT_HUD;
				Common_PlayerController(rentry.pc).EventDispatcher.SendEvent(EventToDisp);			
			}
			else
			{
				// �������� �������, ����������� ������������������� ������ ��������� ����� ��������
				rentry.AddFirstTouchedTrigger(trg);
			}
			break;
	
		case TRIGGERTYPE_INVALIDENTRY:
			// ���������, � ������ �� ��� ����� �������� ������ ���� ��������
			if(rentry.GetFirstTouchedTrigger() != none)
			{
				// ��� ��������
				rentry.AddEvent(CREVT_LEAVEFROMWRONGSIDE);
			}
			else
			{
				// �������� �������, ����������� ������������������� ������ ��������� ����� ��������
				rentry.AddFirstTouchedTrigger(trg);
				rentry.AddEvent(CREVT_ENTERFROMWRONGSIDE);
			}
			break;

		default:
			break;
		}
		break;

	//--------------------------------------------------------------------------------------------------------------------------------------------------
	case CROADTYPE_TRAFFICLIGHT:
		switch(trg.trType)
		{
		case TRIGGERTYPE_ENTRY:
			if(rentry.GetFirstTouchedTrigger() != none)
			{
				// ��� ��������
				

				// ���������, ������� �� ����� �� ������� ���� �� ������� ����� ��������
				if(rentry.FindEvent(CREVT_MOVEONRED) == false)
				{
					// �� ��������, ������ �������� �������, ���������� � ��������.
					
					local_trRef = rentry.GetFirstTouchedTrigger().FindTriggerReference(trg);

					if(local_trRef.MessageID > 0)
					{
						EventToDisp.messageID = rentry.GetFirstTouchedTrigger().FindTriggerReference(trg).MessageID;
						EventToDisp.eventType = GOROD_EVENT_PDD;
						Common_PlayerController(rentry.pc).EventDispatcher.SendEvent(EventToDisp);

						if(local_trRef.bShowMessageInHUD)
						{
							EventToDisp.eventType = GOROD_EVENT_HUD;
							Common_PlayerController(rentry.pc).EventDispatcher.SendEvent(EventToDisp);
						}
					}					
				}
				else
				{
					// �������� �� ������� ���� �� ������� ����� ��������
					// � ���� ������ ������ �� ������
				}

			}
			else
			{
				// �������� �������
				rentry.AddFirstTouchedTrigger(trg);

				// ���� ������� ������������, ������ ��� ����������� ��������� (������ ����� �� ������������ ����������)
				if(trg.IsBlocked)
				{
					// ���������, ������� �� ����� �� ����������� ������ �����-���� �� ���. ������
					if(trg.bControlByLeftSection)
					{
						// ������� �� ����������� ������ ����� ������
						EventToDisp.messageID = 3042;
						EventToDisp.eventType = GOROD_EVENT_PDD;
						Common_PlayerController(rentry.pc).EventDispatcher.SendEvent(EventToDisp);
						EventToDisp.eventType = GOROD_EVENT_HUD;
						Common_PlayerController(rentry.pc).EventDispatcher.SendEvent(EventToDisp);
					}
					else if(trg.bControlByRightSection)
					{
						// ������� �� ����������� ������ ������ ������
						EventToDisp.messageID = 3043;
						EventToDisp.eventType = GOROD_EVENT_PDD;
						Common_PlayerController(rentry.pc).EventDispatcher.SendEvent(EventToDisp);
						EventToDisp.eventType = GOROD_EVENT_HUD;
						Common_PlayerController(rentry.pc).EventDispatcher.SendEvent(EventToDisp);
					}
					else
					{
						// ������� �� ������� ����
						EventToDisp.messageID = 3005;//GOROD_PDD_CROSSROAD_MOVE_ON_RED
						EventToDisp.eventType = GOROD_EVENT_PDD;
						Common_PlayerController(rentry.pc).EventDispatcher.SendEvent(EventToDisp);
						EventToDisp.eventType = GOROD_EVENT_HUD;
						Common_PlayerController(rentry.pc).EventDispatcher.SendEvent(EventToDisp);
					}

					// ���� �������, ��� ����� ������� �� �������, ���� ���� ������ �������� ���.������
					rentry.AddEvent(CREVT_MOVEONRED);

				}
				else
				{
					// �������� ��������� � ���, ��� ����� ������� �� ������� ����
					EventToDisp.messageID = 3006;//GOROD_PDD_CROSSROAD_MOVE_ON_GREEN
					EventToDisp.eventType = GOROD_EVENT_PDD;
					Common_PlayerController(GetALocalPlayerController()).EventDispatcher.SendEvent(EventToDisp);
				}
			}
			break;

		///////////////////////////////////////////
		case TRIGGERTYPE_INVALIDENTRY:
			// ���� ��� ��������
			if(rentry.GetFirstTouchedTrigger() != none)
			{
				rentry.AddEvent(CREVT_LEAVEFROMWRONGSIDE);
				EventToDisp.messageID = 3021;
				EventToDisp.eventType = GOROD_EVENT_PDD;
				Common_PlayerController(rentry.pc).EventDispatcher.SendEvent(EventToDisp);
				EventToDisp.eventType = GOROD_EVENT_HUD;
				Common_PlayerController(rentry.pc).EventDispatcher.SendEvent(EventToDisp);
			}
			// ��� �� ��������
			else
			{
				rentry.AddFirstTouchedTrigger(trg);
				rentry.AddEvent(CREVT_ENTERFROMWRONGSIDE);

				EventToDisp.messageID = 3020;
				EventToDisp.eventType = GOROD_EVENT_PDD;
				Common_PlayerController(rentry.pc).EventDispatcher.SendEvent(EventToDisp);
				EventToDisp.eventType = GOROD_EVENT_HUD;
				Common_PlayerController(rentry.pc).EventDispatcher.SendEvent(EventToDisp);
				//rentry.Message = "You entered to crossroad from wrong side";
			}
			break;
		

		/////////////////////////////////////////////////
		case TRIGGERTYPE_EXIT:
			// ���� ��� �������
			if(rentry.GetFirstTouchedTrigger() != none)
			{
				// ���������, ������� �� ����� �� ������� ���� �� ������� ����� ��������
				if(rentry.FindEvent(CREVT_MOVEONRED) == false)
				{
					// �� ��������
					rentry.Message = rentry.GetFirstTouchedTrigger().FindTriggerReference(trg).Message;
				}
				else
				{
					//
				}
			}
			// ��� �� �������
			else
			{
				rentry.AddFirstTouchedTrigger(trg);
			}
			break;

		default:
		}
		break;
	default:
	}

}

defaultproperties
{
	Begin Object Class=StaticMeshComponent Name=SBox 
		StaticMesh = StaticMesh'Tools_1.Meshes.S_Crossroad_1'
		CollideActors = true
		BlockActors = false
		RBChannel=RBCC_GameplayPhysics
		RBCollideWithChannels=(Default=TRUE,BlockingVolume=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE,Vehicle=TRUE)
		HiddenGame = true
	End Object
	Components.Add(SBox);
	MeshBox = SBox
	CollisionComponent = SBox

	CrossRoad_Type = CROADTYPE_SIMPLE

	GreenLightTime = 5.0;
	RedLightTime = 5.0;

	CurrentTLState = TLIGHTS_ON
	CrossRoadWorkingState = false
	RedLightOn = false
}
