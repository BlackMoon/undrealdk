class Kamaz_Checker_Autodrom extends Actor implements (Gorod_ActorWithTriggers_Interface, Gorod_EventListener) placeable;
`include(Gorod\Gorod_Events.uci);

/** �������� ������ �� �������� */
var() array<Kamaz_Checker_AutodromTrigger> StartTriggerVolumes;

/** �������� ������ � ��������� */
var() array<Kamaz_Checker_AutodromTrigger> FinishTriggerVolumes;

/** �������� ��������� � ����������� �������� �� ��������� */
var() array<Kamaz_Checker_AutodromTrigger_Hint> PathHintsTriggerVolumes;

/** ������ ���������� �� ��������� */
var() array<Kamaz_Cheker_ExerciseBase> Exercises;

/** ������ ����������, ������� ��������� ����� � ������ ������ */
var int CurrentExerciseIndex;

/** ������ ������, ��������� ������� ������������� ��� ������� ���������  */
var() private PlayerCarBase VehicleForCheck;

/** ������� �������� �� ��������� (������ �����, ������� ����� ������ ��������������� ��������) */
var() array<Kamaz_ExercisePoint> Path;
/** ������ �����, � ������� ����� ������ ����� � ������ ������ */
var private int PathIndex;

/** ����, �������� ������������� �������� ������������ ����������� �������� (�� ����� ����������� ����������� ������� ������� �� ������������) */
var private bool bPathCheck;

/** ���������� ������ */
var private Kamaz_PlayerController CurrentPlayerController;

/** ������ �� ������ ��� �������� ������� */
var private Gorod_Event EventToSend;

/** ������ �� ���������� � ����������� �� ��������� */
var Kamaz_AutodromMessages AutodromMessages;

/** ����, ������������ ��� �������� ��������������� � ��������� ������������ */
var private bool bHasRegisteredInMessagesManager;

/** ����, ������������ ��� �������� ��������������� � ����������� ������� */
var private bool bHasRegisteredInEventDispatcher;

/** ����. ������������, ��� ����� ��������� �� ��������� */
var private bool bHasPlayer;
/** StaticMeshActor - ������� (����) ���������� ������� */
var private Kamaz_Checker_AutodromBorder bdrFront, bdrBack;

/** ����, ������������, ��� �������� �������� */
var bool bEnabled;

var() bool bVisualHintsEnabled;

simulated event PostBeginPlay()
{	
	local Kamaz_Checker_AutodromTrigger t;
	local Kamaz_Checker_AutodromTrigger_Hint t1;
	local Kamaz_Cheker_ExerciseBase Ex;

	super.PostBeginPlay();

	// �������� �������� ������
	SetHiddenFinishTriggers(true);

	// �������� ���������� ������
	CurrentPlayerController = Kamaz_PlayerController(GetALocalPlayerController());

	// ���� ��� ���� - �� Gorod_Game ��� PlayerController �� ������ ������ Gorod_PlayerController, �� �� �������� ��������
	if(Kamaz_Game(WorldInfo.Game) == none || CurrentPlayerController == none)
	{
		GotoState('Idle');
		return;
	}

	CurrentPlayerController.CheckerAutodrom = self;

	foreach StartTriggerVolumes(t)
		t.ActorWithTriggers = self;

	foreach FinishTriggerVolumes(t)
		t.ActorWithTriggers = self;

	foreach PathHintsTriggerVolumes(t1)
		t1.ActorWithTriggers = self;

	foreach Exercises(Ex)
		Ex.Autodrom = self;

	// �������� ������� ��� �������� �������
	EventToSend = new class'Gorod_Event';
	EventToSend.sender = self;
	EventToSend.eventType = GOROD_EVENT_HUD;

	// ������ � ������������ ������ ����������� ��������� �� ���������
	AutodromMessages = new class'Kamaz_AutodromMessages';
	AutoDromMessages.checkConfig();
	RegisterInMessagesManager();	

	CurrentExerciseIndex = 0;
}

// �����, � ������� �������� ������ �� ������
simulated state Idle
{
}

/** ���������� ������������� � ������ �� ��������� �� StartTriggerVolumes ��� FinishTriggerVolumes */
function OnTriggerTouch(Actor Sender, Actor Other)
{
	local PlayerCarBase v;
	local Kamaz_Checker_AutodromTrigger_Hint hint;

	if(!bEnabled) return;

	v = PlayerCarBase(Other);
	if(v == none) return;

	if(!bHasPlayer)
	{
		if(StartTriggerVolumes.Find(Sender) != INDEX_NONE)
		{
			StartAutodromCheck(v);
			SendAutodromEvent(self, 1000);
		}
	}
	else
	{
		if(FinishTriggerVolumes.Find(Sender) != INDEX_NONE)
		{
			StopAutodromCheck();
			SendAutodromEvent(self, 1001);
			SetEnadled(false);
		}
		else
		{
			hint = Kamaz_Checker_AutodromTrigger_Hint(Sender);
			if(hint != none && PathHintsTriggerVolumes.Find(hint) != INDEX_NONE)
			{
				switch(hint.HintMessage)
				{
					case HMT_DRIVE_LEFT:
						SendAutodromEvent(self, GOROD_EVENT_DRIVE_LEFT);
						break;
					case HMT_DRIVE_RIGHT:
						SendAutodromEvent(self, GOROD_EVENT_DRIVE_RIGHT);
						break;
					case HMT_DRIVE_FORWARD:
						SendAutodromEvent(self, GOROD_EVENT_DRIVE_FORWARD);
						break;
				}
			}
		}
	}
}

/** ���������� ��� ���������� ������ ������ �� ��������� StartTriggerVolumes ��� FinishTriggerVolumes (��������� ��� ���������� ���������� Gorod_ActorWithTriggers_Interface) */
function OnTriggerUnTouch(Actor Sender, Actor Other)
{
}

/** ������� ����������/�������� ������� ������� */
function showBrdMeshes(optional bool bshow = true)
{
	bdrFront.BorderMesh.SetHidden(!bshow);
	bdrBack.BorderMesh.SetHidden(!bshow);	
}
/** ������� ��������/��������� 2� StaticMesh - ������ ������� (����������� - �������� �����, ������ - �������� �����);
 *  ������� ���������:
 *  - locF, rotF - (location, rotator ����������� �������);
 *  - locB, rotB - (location, rotator ������ �������).
 */
function setBrdMeshes(vector locF, vector locB, rotator rotF, rotator rotB)
{
	local LinearColor clr;

	if(bVisualHintsEnabled)
	{
		// front
		if (bdrFront == none)
		{
			bdrFront = Spawn(class'Kamaz_Checker_AutodromBorder', self, 'front');				
			clr.R = 0;
			clr.g = 1.0f;
			clr.B = 0;		
			bdrFront.setColor(clr);
		}
		bdrFront.setLocation(locF);
		bdrFront.SetRotation(rotF);	
		// back
		if (bdrBack == none)
		{
			bdrBack = Spawn(class'Kamaz_Checker_AutodromBorder', self, 'back');		
			clr.R = 1.0f;
			clr.g = 0;
			clr.B = 0;		
			bdrBack.setColor(clr);		
		}
		bdrBack.setLocation(locB);
		bdrBack.SetRotation(rotB);
	
		showBrdMeshes();
	}
}

/** ������������ �������� � ��������� ��������� */
function RegisterInMessagesManager()
{
	// ���� �������� ��������� ��� ��������,
	if(CurrentPlayerController.MessagesManager != none)
	{
		// ��������������
		CurrentPlayerController.MessagesManager.Register(AutodromMessages);
		bHasRegisteredInMessagesManager = true;
	}
	else
	{
		// ����� ��� 1 ��� � ������� �����
		SetTimer(1, false, 'RegisterInMessagesManager');
	}
}

/** ������������ �������� � ����������� ������� */
function RegisterInEventDispatcher()
{
	// ���� ���������� ������� ��� ����
	if(CurrentPlayerController.EventDispatcher != none)
	{
		// ��������������
		CurrentPlayerController.EventDispatcher.RegisterListener(self, GOROD_EVENT_PDD);
		bHasRegisteredInEventDispatcher = true;
	}
	else
	{
		// ����� ��� 1 ��� � ������� �����
		SetTimer(1, false, 'RegisterInEventDispatcher');
	}
}

/** ������ ����������� � ����������� ������� */
function UnRegisterInEventDispatcher()
{
	CurrentPlayerController.EventDispatcher.RemoveListener(self);
}

simulated event Tick(float DeltaSeconds)
{
	super.Tick(DeltaSeconds);

	// ���� ��� �� ������������������ � ��������� ���������, �� ������
	if(!bHasRegisteredInMessagesManager) return;

	if(bPathCheck)
	{
		CheckPath();
	}
}

/** �������� �������� ����������� ��������� */
function StartAutodromCheck(PlayerCarBase v)
{
	local Kamaz_Checker_AutodromTrigger_Hint t1;

	// ����. ������ �� ������, ������� ����� �����������
	VehicleForCheck = v;

	// ���. ������ ����������
	CurrentExerciseIndex = 0;
	Exercises[0].StartWaitForPlayer();
	
	// �������� ������������ �������� �������� � ������ �����
	PathIndex = 0;
	bPathCheck = true;

	// ���. ���� ���������� ������ �� ���������
	bHasPlayer = true;

	foreach PathHintsTriggerVolumes(t1)
		t1.bEnabled = true;

	RegisterInEventDispatcher();
}

/** ��������� �������� ����������� ��������� */
function StopAutodromCheck()
{
	local Kamaz_Checker_AutodromTrigger_Hint t1;

	if(Exercises[CurrentExerciseIndex] != none)
	{
		Exercises[CurrentExerciseIndex].CancelCheck();
	}

	bPathCheck = false;
	bHasPlayer = false;

	SetHiddenFinishTriggers(true);

	UnRegisterInEventDispatcher();

	foreach PathHintsTriggerVolumes(t1)
		t1.bEnabled = false;

	SetEnadled(false);
}

simulated function SetEnadled(bool bNewEnabled)
{
	bEnabled = bNewEnabled;
}

/** ��������� ������������ �������� ������ �� �������� */
function CheckPath()
{
	local Vector VehicLoc, Point1, Point2, v;
	local float dist;

	if(VehicleForCheck == none)
		return;

	if(PathIndex < Path.Length - 1)
	{
		// ���������� ������ ������
		VehicLoc = VehicleForCheck.Location;

		// ���������� ��������� � ���������� ����� ��������
		Point1 = Path[PathIndex].Location;
		Point2 = Path[PathIndex+1].Location;

		// ��������� ���������� �� ������ �� ������� [Point1; Point2]
		dist = PointDistToSegment(VehicLoc, Point1, Point2, v);

		if(v == Point2)
		{
			// ������� �� ���������� ������� ����
			PathIndex++;
			return;
		}
		
		if(dist > 3000)
		{
			// ������� ������ ������ � ��������
			SendAutodromEvent(self, 1023);
			StopAutodromCheck();
		}
		else if(dist > 1000)
		{
			// ����������� �� ��������			
			SendAutodromEvent(self, 1009);
		}
	}
}

/** ���������� �������� � ������ ���������� ���������� */
function ExerciseStarted(Kamaz_Cheker_ExerciseBase Ex)
{
	// ���� �������� ���������� �� � ������������ � �������� ���������� � ������ ����������,
	// ������� warning - ������ �� ������ ����
	if(Exercises[CurrentExerciseIndex] != Ex)
	{
		`warn("Fialed to start exercise" @ Ex @ " - wrong order. Starting exercise" @ Exercises[CurrentExerciseIndex]);
		Ex.CancelCheck();
		Exercises[CurrentExerciseIndex].StartWaitForPlayer();
		return;
	}

	PathIndex++;
	bPathCheck = false;
}

/** ���������� �������� � ���������� ���������� ���������� */
function ExerciseStoped()
{
	bPathCheck = true;

	CurrentExerciseIndex++;

	if(Exercises[CurrentExerciseIndex] != none)
	{
		Exercises[CurrentExerciseIndex].StartWaitForPlayer();
	}
	else if(CurrentExerciseIndex == Exercises.Length)
	{
		if(bVisualHintsEnabled)
			SetHiddenFinishTriggers(false);
	}
}

/** �������� ������� �� ��������� */
function SendAutodromEvent(Object sender, int MsgId)
{
	if(CurrentPlayerController != none)
	{
		EventToSend.messageID = MsgId;

 		CurrentPlayerController.EventDispatcher.SendEvent(EventToSend);
	}
}

/** ������������ ������� ����� */
function HandleEvent(Gorod_Event evt)
{
	if(bHasPlayer)
	{
		if(evt.eventType == GOROD_EVENT_PDD && evt.messageID == GOROD_PDD_OUT_OF_SPEED_MAX_LIMIT)
		{
			// �� ������� ��������� � ���, ��� ��������� �������� ��� ���
			// ��� ����� ���������
			SendAutodromEvent(self, GOROD_EVENT_HIGH_SPEED);
		}
	
		if(evt.eventType == GOROD_EVENT_PDD && evt.messageID == GOROD_PDD_ROAD_ON_OFFROAD)
		{
			if(Exercises[CurrentExerciseIndex] != none && Exercises[CurrentExerciseIndex].IsExerciseRunning())
			{
				SendAutodromEvent(self, GOROD_EVENT_OFF_ROAD);
				Exercises[CurrentExerciseIndex].StopCheck();
			}
		}
	}
}

simulated function SetHiddenStartTriggers(bool bNewHidden)
{
	local Kamaz_Checker_AutodromTrigger t;

	foreach StartTriggerVolumes(t)
		t.SetHidden(bNewHidden);
}

simulated function SetHiddenFinishTriggers(bool bNewHidden)
{
	local Kamaz_Checker_AutodromTrigger t;

	foreach FinishTriggerVolumes(t)
		t.SetHidden(bNewHidden);
}

simulated function SetVisualHintsEnabled(bool NewEnabled)
{
	
	bVisualHintsEnabled = NewEnabled;
}

DefaultProperties
{
	bPathCheck = false;
	bHasRegisteredInMessagesManager = false;
	bHasRegisteredInEventDispatcher = false;
	bHasPlayer = false;

	bEnabled = false;
	bVisualHintsEnabled = false;
}