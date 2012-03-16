class Kamaz_PlayerController extends Common_PlayerController dependson (Gorod_EventDispatcher,Gorod_Event,Gorod_BaseMessages, Kamaz_SeqEvent_MissionStart);

`include(Gorod\Gorod_Events.uci);

/**
 * */
var CarX_Vehicle_Kamaz_4x4 Kamaz;
/** 
 *  ���������� ������� ����������*/
var Kamaz_ControllerSaveSystem SaveSystem;
/** 
 *  ������ �� ����� ��������� */
var private Kamaz_ClientMessageBroadcaster MessageBroadcaster;
/**
 * ����� */
var Kamaz_CReport CReport;
/** 
 *  ������ �� Gorod_EventDispatcher */
/*var Gorod_EventDispatcher EventDispatcher;*/ // ���� ��� �� ���������

var Kamaz_CProfile CProfile;

/**
 * */
var Pawn PossessedPawn;
/**
 * */
var bool PossessedBVehicleTransition;
/** 
 *  ������, �������� �� ������������� �������� ������ ��� ������ �������� */
var Kamaz_Checker_StartMoving StartMovingChecker;
/**
 * */
var Quest_Custom Quest;
/** 
 *  ���������� � ����������� � ������� ��� �������������*/
var Gorod_CrashMessages CrashMessages;
/** 
 *  ���������� � ����������� ���*/
var Gorod_PDDMessages PDDMessages;

/** ��������� �����. ��������� �������������� �������� ��� ������ , ������� � �. �. */
var Kamaz_CMapState CMapState;

/** ��������� ���������. ��������� ��������� �� ��������� */
var Kamaz_Checker_Autodrom CheckerAutodrom;

/** ������� ���� */
var bool bIsMenu;
var bool bIsMission;

exec function SwitchControl()
{
	/*
	local Kamaz_PlayerCar refCar;

	//  ������ ����� ���������� �� ������, ����������� �������
	foreach AllActors(class'Kamaz_PlayerCar', refCar)
	{
		refCar.SetupCCM(refCar.CCM == none ? CarControlManager : none);
	}
	*/
}

exec function Mirrors()
{
	local Kamaz_PlayerCar refCar;

	foreach AllActors(class'Kamaz_PlayerCar', refCar)
	{
		refCar.leftMirror.SceneCapture.bEnabled = !refCar.leftMirror.SceneCapture.bEnabled;
		refCar.rightMirror.SceneCapture.bEnabled = !refCar.rightMirror.SceneCapture.bEnabled;
	}
}

/** 
 *  �����������, ���� ���� �������� ������� ������������. ���� ���, ��������� ����� */
simulated event PostBeginPlay()
{
	local Kamaz_Game game;	

	super.PostBeginPlay();
	//�������� ������ ��������
	game = Kamaz_Game(WorldInfo.Game);
	if(game!=none)
		game.showLoadingFlash();
	
	/** */
	SaveSystem = Spawn(class'Kamaz_ControllerSaveSystem');
	`warn("Gorod_ControllerSaveSystem = none", SaveSystem == none);
	SaveSystem.gpc = self;

	PDDMessages = new class'Gorod_PDDMessages';	
	PDDMessages.checkConfig();
	MessagesManager.Register(PDDMessages);

	/** ������� ��������� ������� ��������� */
	MessageBroadcaster = Spawn(class'Kamaz_ClientMessageBroadcaster');
	`warn("Gorod_ClientMessageBroadcaster = none", MessageBroadcaster == none);
	MessageBroadcaster.Initialize(self);	

	CProfile = Spawn(class'Kamaz_CProfile');
	`warn("Gorod_CProfile = none", CProfile == none);
	CProfile.Initialize(self);

	StartMovingChecker = Spawn(class'Kamaz_Checker_StartMoving');
	`warn("Kamaz_Checker_StartMoving = none", StartMovingChecker == none);

	CrashMessages = new class'Gorod_CrashMessages';
	CrashMessages.checkConfig();
	MessagesManager.Register(CrashMessages);
	
	CMapState = Spawn(class'Kamaz_CMapState');
	CMapState.PC = self;	
}

/** 
 *  */
function ShowStartMisionMessages()
{
	local Gorod_Event evnt;
	local bool flag;
	flag=Kamaz_Game( WorldInfo.Game).bMissionEnabled;

	if( flag )
	{
		evnt = new class'Gorod_Event';
		evnt.sender = self;
		evnt.messageID = 2;
		evnt.eventType=GOROD_EVENT_HUD;
		EventDispatcher.SendEvent(evnt);
	}
}





///////////���������� �������
/**
 * ������� �����, questType - ��� ������, ���� string, ��������������, ��� ��� 
 * ����� ����� ��������� ��������� ��������, ��������, �������. ��������, 
 * ��������� ���� ��� ������� ��� ��������� ������ 
 */
exec client reliable function string CreateQuest(string questType)
{
	local string s;
	`entry();
	if(SaveSystem != none)
	{
		`log("SaveSystem inside if");
		s = SaveSystem.CreateQuest(questType);
	}
	else
		`warn("SaveSystem hasnt been created");
	return s;
	`exit();
}

/** ��������� ��������� ���� (���������� ����� ������ ������) */
exec client reliable function StartQuest(optional string questName)
{
	if(SaveSystem != none)
		SaveSystem.StartQuest(questName);
	else
		`warn("SaveSystem hasnt been created");
}

//����� ������ �����
/** �������� ����� ������ ������, ����� ������� questName, ����� �������� ����� ���������� */
exec client reliable function GetQuestStartTime(optional string questName)
{
	if(SaveSystem != none)
		WorldInfo.Game.Broadcast(self, SaveSystem.GetQuestStartTime(questName));
	else
		`warn("SaveSystem hasnt been created");

}

/** ��������� �������, ���� ������� Successfull = true �� ����� ����������, ������ �� ���� ������� */
exec client reliable function endQuest(bool Successfull, optional string questID)
{
	if(SaveSystem != none)
		SaveSystem.EndQuest(Successfull, questID);
	else
		`warn("SaveSystem hasnt been created");

}
/** �������� ����� ����������� ������. ����� ������� questName, ����� �������� ����� ���������� ������������ */
exec client reliable function string GetQuestPassTime(optional string questID)
{
	if(SaveSystem != none)
	{
	
		WorldInfo.Game.Broadcast(self, SaveSystem.GetQuestPassTime(questID));
		return SaveSystem.GetQuestPassTime(questID);
	}
	else
	{
		`warn("SaveSystem hasnt been created");
		return "";
	}
	return "";

}


/** �������� ���������� ������, ���������� �� ����� */
exec client reliable function byte GetQuestsPointsCount(byte points,optional string questID)
{
	local byte questPoints;
	if(SaveSystem != none)
		questPoints = SaveSystem.GetQuestPoints(questId);
	else
		`warn("SaveSystem hasnt been created");
	return questPoints;

}
/** ��������� ����� �� ����� */
exec client reliable function AddQuestsPointsCount(byte points,optional string questID)
{
	if(SaveSystem != none)
		SaveSystem.AddQuestPoints(points,questID);
	else
		`warn("SaveSystem hasnt been created");

}

/** �������� ������ ������� �� ��������� ���� */
exec client reliable function array<string> GetQuests(optional string type, optional string profileName)
{
	local array<string> quests;
	
	if(SaveSystem != none)
	{
		quests = SaveSystem.GetQuestsID();
		return quests;
	}
	else
	{
		`warn("SaveSystem hasnt been created");
		return quests;
	}
} 

/** ������� � ��� ���������� ���������������, ������� ������� ��� ������������� */
exec function ShowMyLocation()
{
	`log( "x-"@Location.X @" y-"@ Location.Y @" z-"@ Location.Z); 
}

exec function RestartMission()
{
	Kamaz_Game(WorldInfo.Game).StartMissionKismet();
}
///////////===============================================================================================
client reliable function ClientQuit()
{
	if(CleanupOnlineSubsystemSession()==false)
	{
		FinishQuitToMainMenu();
	}
}

function QuitGame()
{
	if(CleanupOnlineSubsystemSession()==false)
	{
		FinishQuitToMainMenu();
	}
}

simulated function FinishQuitToMainMenu()
{
	ConsoleCommand("Disconnect");
}

simulated function bool CleanupOnlineSubsystemSession()
{
	if (WorldInfo.NetMode != NM_Standalone &&
		OnlineSub != None &&
		OnlineSub.GameInterface != None &&
		OnlineSub.GameInterface.GetGameSettings('Game') != None)
	{
		OnlineSub.GameInterface.AddEndOnlineGameCompleteDelegate(OnEndOnlineGameComplete);
		OnlineSub.GameInterface.EndOnlineGame('Game');

		return true;
	}

	return false;
}

/**
 * Called when the online game has finished ending.
 */
function OnEndOnlineGameComplete(name SessionName,bool bWasSuccessful)
{
	OnlineSub.GameInterface.ClearEndOnlineGameCompleteDelegate(OnEndOnlineGameComplete);
	OnlineSub.GameInterface.AddDestroyOnlineGameCompleteDelegate(OnDestroyOnlineGameComplete);

	if(!OnlineSub.GameInterface.DestroyOnlineGame('Game'))
	{
		OnDestroyOnlineGameComplete('Game',true);
	}
}

/**
 * Called when the destroy online game has completed. At this point it is safe
 * to travel back to the menus
 *
 * @param SessionName the name of the session the event is for
 * @param bWasSuccessful whether it worked ok or not
 */
function OnDestroyOnlineGameComplete(name SessionName,bool bWasSuccessful)
{
	OnlineSub.GameInterface.ClearDestroyOnlineGameCompleteDelegate(OnDestroyOnlineGameComplete);

	FinishQuitToMainMenu();
}

/** ����� �� ������ */
function LeaveCar(Vehicle v)
{
	local CarX_Vehicle_Kamaz_4x4 VehicKamaz;

	if(v!=none)
	{
		VehicKamaz = CarX_Vehicle_Kamaz_4x4(v);
		if(VehicKamaz!=none)
		{
			//�������������
			if(VehicKamaz.BeltOn)
				VehicKamaz.SwitchBelt();
		}
		v.DriverLeave(true);
	}
}
/** ������� �� ������� */
function PawnDied(Pawn P)
{
}

function Gorod_Event sendEvent(int messageID)
{
	local Gorod_Event ev;
	ev = new class'Gorod_Event';
	ev.eventType = GOROD_EVENT_GAME;
	ev.messageID = messageID;
	EventDispatcher.SendEvent(ev);
	return ev;
}

event Possess(Pawn aPawn, bool bVehicleTransition)
{
	super.Possess(aPawn, bVehicleTransition);

	//���� ���� � ������
	if(Vehicle(aPawn)!=none)
	{
		sendEvent(GOROD_GAME_STARTED);
		if(Quest.bTipsEnabled)
			StartCheckCarControlElements();		
	}
}

event UnPossess()
{
	StopCheckCarControlElements();
	super.UnPossess();

	sendEvent(GOROD_UNPOSSESSED);
}

simulated function StartCheckCarControlElements()
{
	local CarX_Vehicle vehic;

		vehic = CarX_Vehicle(Pawn);
	if(StartMovingChecker != none && vehic != none)
	{
		// �������� ������� �� ���������� ������ ��� ������ ��������
		StartMovingChecker.StartCheck(vehic);
	}
}

simulated function StopCheckCarControlElements()
{
	if(CarX_Vehicle(Pawn) == none)
	{
		// ���������� ������� �� ���������� ������ ��� ������ ��������
		StartMovingChecker.StopCheck();
	}
}
exec function CloseLoadingFlash()
{
	Kamaz_Game(WorldInfo.Game).CloseLoadingFlash();
}
function client reliable createQuestObj(string QuestId, name QuestType)
{	
	local Kamaz_HUD kHud;
	`warn("func createQuestObj ",CMapState==none);
	if(CMapState==none)
		return;
	// destroy old report (if exists)
	if (CReport !=none)
	{
		CReport.UnInitialize();
		CReport.Destroy();
	}

	if (QuestType == 'Quest_Custom')
	{
		Quest = new(none, QuestId) class 'Quest_Custom';
		CMapState.GoToFreeDrv(Quest);
		Kamaz = CMapState.PlayerCar;
	}
	
	if (QuestType == 'Quest_Autodrom' )
	{
		Quest = new(none, QuestId) class 'Quest_Autodrom';		
		CReport = Spawn(class'Kamaz_AutodromReport');
		CReport.Initialize(self);		

		CMapState.GoToFreeDrv(Quest);
		Kamaz = CMapState.PlayerCar;
	}

	if (QuestType == 'Quest_Mission' )
	{
		Quest = new(none, QuestId) class 'Quest_Mission';
		CReport = Spawn(class'Kamaz_CReport');
		CReport.Initialize(self);		

		CMapState.GoToMission(Quest);
		Kamaz = CMapState.PlayerCar;
	}
	sendEvent(GOROD_POSSESSED);		
	Kamaz_Game(WorldInfo.Game).CloseLoadingFlash();

	//��� ������������� �� ��������� �� �������
	kHud = Kamaz_HUD(self.myHUD);

	if(kHud!=none && kHud.bRegistred ==false)
	{
		kHud.RegisterInListeners(self);
		kHud.bRegistred = true;
	}
}

function saveUITexts()
{
	local Kamaz_Checker_Autodrom gca;	
	local Kamaz_Game gg;
	local Kamaz_HUD ghud;
	// flash text	
	ghud = Kamaz_HUD(myHUD);
	if (ghud != none) ghud.saveMenuTexts();

	// message texts	
	CrashMessages.save();
	PDDMessages.save();
	StartMovingChecker.getMessages().save();

	gg = Kamaz_Game(WorldInfo.Game);
	if (gg != none && gg.GameGeneralMessages != none) gg.GameGeneralMessages.save(); 	
	// find first Gorod_Checker_Autodrom
	if (CheckerAutodrom == none)
	{
		foreach AllActors(class 'Kamaz_Checker_Autodrom', gca)
		{
			CheckerAutodrom = gca;
			break;			
		}		
	}	
	if (CheckerAutodrom != none) CheckerAutodrom.AutodromMessages.save();
}

function string ConsoleCommand(string Command, optional bool bWriteToLog = true)
{		
	if (Command ~= "exit" || Command ~= "quit")	
		saveUITexts();		
	return super.ConsoleCommand(Command);
}


DefaultProperties
{

//	InputClass = class 'KamazM.Kamaz_PlayerInput'
	SupportedEvents(5)=Class'KamazM.Kamaz_SeqEvent_MissionStart'
	SupportedEvents(6)=Class'KamazM.Kamaz_SeqEvent_MatineeContinue'
	SupportedEvents(7)=Class'KamazM.Kamaz_SeqEvent_MatineePause'
	SupportedEvents(8)=Class'KamazM.Kamaz_SeqEvent_MatineeStop'

	bIsMission = false;
	bIsMenu = true;

}