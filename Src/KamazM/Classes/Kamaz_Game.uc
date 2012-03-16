class Kamaz_Game extends UDKGame;

var class<Gorod_DataStore_SearchSC> GorodDataStoreClass;
var class<Gorod_DataStore_GameSettingsSC> GorodSettingsDataStoreClass;
var Gorod_Event ev;

var float TickCounter;

var array<Vector> PlayerControllersLocation;
														/**флаг использования задания*/
var bool bMissionEnabled;
var GFxMoviePlayer loadingPlayer;
var Gorod_GameGeneralMessages GameGeneralMessages;
var bool bHasRegisteredInMessagesManager;

var Gorod_MapUtils MapUtils;

event PostBeginPlay()
{
	local DataStoreClient DSClient;
	local Gorod_DataStore_SearchSC GorodDataStore;
	local Gorod_DataStore_GameSettingsSC GorodSettingsDataStore;
	local class<UIDataStore> store;	

	super.PostBeginPlay();
	initloadingPlayer();

	// получаем ссылку на клиента для хранилища данных
	DSClient = class'UIInteraction'.static.GetDataStoreClient();
	if ( DSClient != None )
	{
		store = DSClient.FindDataStoreClass(GorodDataStoreClass);
		if(store == none)
		{
			// создаём и регистрируем хранилище данных для поиска серверов
			GorodDataStore = DSClient.CreateDataStore(GorodDataStoreClass);
			DSClient.RegisterDataStore(GorodDataStore);
		}

		store = DSClient.FindDataStoreClass(GorodSettingsDataStoreClass);
		if(store == none)
		{
			// создаём и регистрируем хранилище данных с настройками создаваемого сервера
			GorodSettingsDataStore = DSClient.CreateDataStore(GorodSettingsDataStoreClass);
			DSClient.RegisterDataStore(GorodSettingsDataStore);
		}
	}

	ev = new class'Gorod_Event';

	MapUtils = Spawn (class'Gorod_MapUtils');	
}

/** функция предназначена для вызыва события StartMission в кизмете*/
simulated function StartMissionKismet()
{
	
	local int i;
	local Sequence Seq;
	local array<SequenceObject> AllSeqEvents;
	

	Seq = WorldInfo.GetGameSequence();

	if(Seq != none)
	{
		Seq.Reset();
		Seq.FindSeqObjectsByClass(class'Kamaz_SeqEvent_MissionStart', true, AllSeqEvents);

		
		for(i = 0; i < AllSeqEvents.Length; i++)
		{
			
				Kamaz_SeqEvent_MissionStart(AllSeqEvents[i]).CheckActivate(WorldInfo, none);
				bMissionEnabled=true;
				ShowStartMisionMessages();				
		}
	}
}

/** функция предназначена для завершения миссии*/
simulated function EndMission()
{
	local Gorod_Event evnt;

	local Kamaz_PlayerController PC;
	PC=Kamaz_PlayerController(GetALocalPlayerController());
	if (bMissionEnabled)
	{		
		evnt = new class'Gorod_Event';
		evnt.sender = self;
		evnt.messageID = 3; //GOROD_MISSION_ENDED;  
		evnt.eventType=GOROD_EVENT_GAME;
		evnt.ShowTime=23000;
		PC.EventDispatcher.SendEvent(evnt);
	}	
}


/** функция предназначена для вызыва события MissionObjectsHide в кизмете*/
simulated function MissionObjectsHide()
{
	
	local int i;
	local Sequence Seq;
	local array<SequenceObject> AllSeqEvents;
	

	Seq = WorldInfo.GetGameSequence();

	if(Seq != none)
	{
		Seq.FindSeqObjectsByClass(class'SeqEvent_MissionObjectsHide', true, AllSeqEvents);
		
		for(i = 0; i < AllSeqEvents.Length; i++)
		{	
				SeqEvent_MissionObjectsHide(AllSeqEvents[i]).CheckActivate(WorldInfo, none);
				bMissionEnabled=true;
		}
	}
}

simulated function ShowStartMisionMessages()
{
	local Gorod_Event evnt;

	local Kamaz_PlayerController PC;
	PC=Kamaz_PlayerController(GetALocalPlayerController());
	if( bMissionEnabled  )
	{
		
		GameGeneralMessages= new class 'Gorod_GameGeneralMessages';
		GameGeneralMessages.checkConfig();		
		PC.MessagesManager.Register(GameGeneralMessages);
		
		evnt = new class'Gorod_Event';
		evnt.sender = self;
		evnt.messageID = 2;
		evnt.eventType=GOROD_EVENT_HUD;
		evnt.ShowTime=23000;
		PC.EventDispatcher.SendEvent(evnt);
	}
	else
	{
		SetTimer(1, false, 'ShowStartMisionMessages');
	}	
}

/** Функция предназначена для вызова события в Кизмете, ставит Матини на паузу*/
simulated function MatineePause()
{
	local int i;
	local Sequence Seq;
	local array<SequenceObject> AllSeqEvents;
	

	Seq = WorldInfo.GetGameSequence();

	if(Seq != none)
	{
		Seq.FindSeqObjectsByClass(class'Kamaz_SeqEvent_MatineePause', true, AllSeqEvents);

		for(i = 0; i < AllSeqEvents.Length; i++)
		{
				Kamaz_SeqEvent_MatineePause(AllSeqEvents[i]).CheckActivate(WorldInfo, none);
		}
	}
}

/** Функция предназначена для вызова события в Кизмете, продолжает проигрывание Матинее*/
simulated function MatineeContinue()
{
	local int i;
	local Sequence Seq;
	local array<SequenceObject> AllSeqEvents;
	

	Seq = WorldInfo.GetGameSequence();

	if(Seq != none)
	{
		Seq.FindSeqObjectsByClass(class'Kamaz_SeqEvent_MatineeContinue', true, AllSeqEvents);

		
		for(i = 0; i < AllSeqEvents.Length; i++)
		{
				Kamaz_SeqEvent_MatineeContinue(AllSeqEvents[i]).CheckActivate(WorldInfo, none);
		}
	}
}

/** Функция предназначена для вызова события в Кизмете, останавливает Матинее*/
simulated function MatineeStop()
{
	local int i;
	local Sequence Seq;
	local array<SequenceObject> AllSeqEvents;
	local Kamaz_PlayerController objPC;

	objPC=Kamaz_PlayerController(GetALocalPlayerController());	
	objPC.ConsoleCommand("cancelmatinee");

	Seq = WorldInfo.GetGameSequence();
	if(Seq != none)
	{
		Seq.FindSeqObjectsByClass(class'Kamaz_SeqEvent_MatineeStop', true, AllSeqEvents);
		
		for(i = 0; i < AllSeqEvents.Length; i++)
		{
				Kamaz_SeqEvent_MatineeStop(AllSeqEvents[i]).CheckActivate(WorldInfo, none);
		}
	}
	
	

}


function RegisterInMessagesManager_GameGeneralMessages()
{
	local Kamaz_PlayerController PC;
	PC=Kamaz_PlayerController(GetALocalPlayerController());

	if(PC.MessagesManager != none)
	{
		PC.MessagesManager.Register(GameGeneralMessages);
		bHasRegisteredInMessagesManager = true;
	}
	else
	{
		SetTimer(1, false, 'RegisterInMessagesManager_GameGeneralMessages');
	}
}


function ServerDisconnect()
{
	local Kamaz_PlayerController gpc;

	foreach WorldInfo.AllControllers(class'Kamaz_PlayerController', gpc)
	{
		gpc.ClientQuit();
	}
}

function Tick(float DeltaSeconds)
{
	local Kamaz_PlayerController gpc;

	super.Tick(DeltaSeconds);

	TickCounter += DeltaSeconds;

	/** Обновление списка координат всех игроков */
	if(TickCounter > 1)
	{
		PlayerControllersLocation.Remove(0, PlayerControllersLocation.Length);

		foreach WorldInfo.AllControllers(class'Kamaz_PlayerController', gpc)
		{
			if(gpc.Pawn != none)
			{
				PlayerControllersLocation.AddItem(gpc.Pawn.Location);
			}
		}
	}
}

/** Возвращает список координат всех игроков */
function array<Vector> GetPlayerControllersLocation()
{
	return PlayerControllersLocation;
}

event GameEnding()
{
	local Kamaz_PlayerController gpc;
	gpc = Kamaz_PlayerController(GetALocalPlayerController());

	`warn("Class Gorod_Game, function GameEnding Gorod_PlayerController = none",gpc==none);

	if(gpc!=none)
	{
		showLoadingFlash();
		ev.eventType = GOROD_EVENT_GAME;
		ev.messageID = 1;
		gpc.EventDispatcher.SendEvent(ev);
	}
	super.GameEnding();

}

function initloadingPlayer()
{
	loadingPlayer = new class'GFxMoviePlayer';
	loadingPlayer.MovieInfo =SwfMovie'menu.LoadingScreen.Loading';
	loadingPlayer.bDisplayWithHudOff = true;
	loadingPlayer.bForceFullViewport = false;

}

/** Показывает флешку загрузки */
function showLoadingFlash()
{
	//создается 
	if(loadingPlayer==none)
		initloadingPlayer();

	loadingPlayer.Start();
	loadingPlayer.SetViewScaleMode(SM_ExactFit);
	loadingPlayer.Advance(0);
	
}

function TimerCloseLoadingFlash()
{
	SetTimer(1, false, 'CloseLoadingFlash');
}

exec function CloseLoadingFlash()
{
	
	if(loadingPlayer!=none)
		loadingPlayer.Close(true);
}

event PreExit()
{
	local Kamaz_PlayerController gpc;

	local Kamaz_HUD gHUD;
	gpc = Kamaz_PlayerController(GetALocalPlayerController());
	if(gpc!=none)
	{
		gHUD = Kamaz_HUD(gpc.myHUD);
		if(gHUD!=none)
		{
			//gHUD.DestroyHud();
		}
		super.PreExit();
	}
	`log('preexit');
}

DefaultProperties
{
	PlayerControllerClass=class'KamazM.Kamaz_PlayerController'
	HUDType = class'Kamaz_HUD'

	GorodDataStoreClass = class'gorod.Gorod_DataStore_SearchSC'
	GorodSettingsDataStoreClass = class'gorod.Gorod_DataStore_GameSettingsSC'

	OnlineGameSettingsClass=class'Gorod_GameSettingsSC'
	//спауним пауна нашего класса
	DefaultPawnClass=class'Gorod_SimplePawn'
	
	
	
	TickCounter = 0;

	bMissionEnabled=false;
}