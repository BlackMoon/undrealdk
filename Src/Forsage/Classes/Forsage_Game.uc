class Forsage_Game extends GameInfo;
`include(Forsage_OnlineConstants.uci)

/** Режим панорамного вида для подключающегося процесса (лобовое стекло, зеркало заднего вида, боковое левое зеркало, боковое правое зеркало), изначально - лобовое стекло */
enum eViewMode           
{
	VM_Screen,                      // лобовое стекло	
	VM_BackMirror,                  // зеркало заднего вида	
	VM_LeftMirror,                  // боковое левое зеркало
	VM_RightMirror                  // боковое правое зеркало
};

var enum eGameType
{
	GT_Autodrom,
	GT_City
} GameType;

var Forsage_DP_Signals objDPSignals;    //  для работы с динамической платформой
var private byte views[4];              // состояние каждого вида (свободен/занят)

var private Vehicle baseVehicle;        // ссылка на базовый vehicle (1й)
/** начальные точки для автодрома и свободной поездки*/
var const vector locAutodrom, locCity;    
var const rotator rotAutodrom, rotCity;

/** класс хранилища для поиска серверов */
var class<Forsage_DataStore_GameSearch> Forsage_GameSearch_DataStoreClass;
/** класс хранилища для создания сервера */
var class<Forsage_DataStore_GameSettings> Forsage_GameSettings_DataStoreClass;

/** клиент для хранилища */
var DataStoreClient DSClient;

/** ссылка на хранилище данных для поиска серверов */
var UDKDataStore_GameSearchBase ForsageSearch;
/** ссылка на хранилище для создания сервера */
var UIDataStore_OnlineGameSettings ForsageSettings;

/** флаг, показывающий, что в результате последнего поиска был найден сервер */
var bool bServerWasFound;

/** флаг, показывающий, что идёт поиск сервера */
var bool bServerFindingInProgress;

/** Таймаут для процесса поиска сервера (если сервер не будет найден за указанное время, то произойдёт создание сервера) */
var float ServerFindingTimeout;
var private string ServerName;

event InitGame(string Options, out string ErrorMessage)
{
	local class<UIDataStore> store;	

	super.InitGame(Options, ErrorMessage);
	//----------------------------------------------------------------
	// создаём и регистрируем хранилища данных 

	// получаем ссылку на клиента для хранилища данных
	DSClient = class'UIInteraction'.static.GetDataStoreClient();
	if ( DSClient != None )
	{
		store = DSClient.FindDataStoreClass(Forsage_GameSearch_DataStoreClass);
		if(store == none)
		{
			// создаём и регистрируем хранилище данных для поиска серверов
			ForsageSearch = DSClient.CreateDataStore(Forsage_GameSearch_DataStoreClass);
			DSClient.RegisterDataStore(ForsageSearch);
		}

		store = DSClient.FindDataStoreClass(Forsage_GameSettings_DataStoreClass);
		if(store == none)
		{
			// создаём и регистрируем хранилище данных с настройками создаваемого сервера
			ForsageSettings = DSClient.CreateDataStore(Forsage_GameSettings_DataStoreClass);
			DSClient.RegisterDataStore(ForsageSettings);
		}
	}

	//-----------------------------------------------------------------------------
	// ищем уже существующий сервер или создаём новый
	// если сервер ещё не создан или мы ещё не подключились к серверу
	if (WorldInfo.NetMode == NM_Standalone)
	{
		StartServerFinding(ServerFindingTimeout);
	}
}

event PostBeginPLay()
{
	super.PostBeginPlay();

	objDPSignals = spawn(class'Forsage_DP_Signals');
	`warn("objDPSignals == none", objDPSignals == none);
}

event PostLogin(PlayerController NewPlayer)
{	
	local Forsage_Controller C;			

	C = Forsage_Controller(NewPlayer);
 	if (baseVehicle == none)     // 1й старт на сервере - вид из машины			
		C.ServerInsertPPChain();		
	else	
		C.ClientInsertPPChain(PostProcessChain'Gorod_Effects.PostProcess.ppc_Mirror');				
	
	C.ViewMode = eViewMode(getFreeViewMode());
	super.PostLogin(NewPlayer);				
}
// получить свободный вид
function int getFreeViewMode()
{
	local byte i;
	local int idx;	
	
	idx = INDEX_NONE;
	for (i = 0; i < 3; i++)
	{
		if (views[i] == 0) {
			views[i] = 1;
			idx = i;
			break;
		}
	}
	return idx;
}

function Pawn SpawnDefaultPawnFor(Controller NewPlayer, NavigationPoint StartSpot)
{
	local Forsage_Pawn ResultPawn;	
	local vector loc;
	// Quick exit if NewPlayer is none
	if (NewPlayer == None)	
		return None;	

	loc = locCity;	
	if (baseVehicle != none)	
		loc = baseVehicle.Location;

	ResultPawn = Spawn(class'Forsage_Pawn',,, loc + vect(0, 0, 100), rotCity,, true);    // bNoCollisionFail = true		
	ResultPawn.SetBasePawn(baseVehicle);
	return ResultPawn;
}

function Vehicle SpawnDefaultVehicleFor(Controller NewPlayer, NavigationPoint StartSpot)
{	
	local Forsage_PlayerCarSounded SpawnedVehicle;
	// Quick exit if NewPlayer is none or if StartSpot is none
	if (NewPlayer == None || StartSpot == None)
	{
		return None;
	}
	// Spawn the default pawn archetype at the start spot's location and the start rotation defined above
	// Set SpawnedVehicle to the spawned vehicle	
	SpawnedVehicle = Spawn(class'Forsage_PlayerCarSounded',,, locCity, rotCity);
	SpawnedVehicle.startLoc = StartSpot.Location;
	SpawnedVehicle.startRot.Yaw = StartSpot.Rotation.Yaw;	
	// Return the value of SpawnedVehicle
	return SpawnedVehicle;
}
/**
 * Called when the controller wants to be given a pawn. Here we give the player a vehicle to drive as well.
 *
 * @param		NewPlayer		Controller requesting a new a pawn
 * @network						Server
 */
function RestartPlayer(Controller NewPlayer)
{
	local NavigationPoint StartSpot;		

	// If the level is restarting, not a dedicated server and not a listen server then abort
	if (bRestartLevel && WorldInfo.NetMode != NM_DedicatedServer && WorldInfo.NetMode != NM_ListenServer)
	{
		return;
	}

	// Find an appropriate starting point within the world for the player
	StartSpot = FindPlayerStart(NewPlayer, 255);

	// If the start spot cannot be found using FindPlayerStart, then try to use the previous stored start spot
	if (StartSpot == None)
	{
		// If the player had a start spot previously, attempt to use that
		if (NewPlayer.StartSpot != None)
		{
			StartSpot = NewPlayer.StartSpot;
		}
		else
		{
			// No start spot found at all, abort
			return;
		}
	}

	// Spawn a pawn for the player to possess
	if (NewPlayer.Pawn == None)
	{
		NewPlayer.Pawn = SpawnDefaultPawnFor(NewPLayer, StartSpot);
	}

	// Check if the pawn could not be spawned. If it couldn't then send the controller to the dead state
	if (NewPlayer.Pawn == None)
	{
		// Server side version of the controller
		NewPlayer.GotoState('Dead');
		// If the controller is a player controller, then tell the client version of the player controller to go to the dead state
		if (PlayerController(NewPlayer) != None)
		{
			PlayerController(NewPlayer).ClientGotoState('Dead', 'Begin');
		}
	}
	else
	{
		// The pawn was spawned, initialize the pawn
		NewPlayer.Pawn.SetAnchor(StartSpot);

		if (PlayerController(NewPlayer) != None)
		{
			PlayerController(NewPlayer).TimeMargin = -0.1f;
			StartSpot.AnchoredPawn = None;
		}

		// Set the last start spot
		NewPlayer.Pawn.LastStartSpot = PlayerStart(StartSpot);
		// Set the last start time
		NewPlayer.Pawn.LastStartTime = WorldInfo.TimeSeconds;
		// Tell the controller to take control over the new pawn
		NewPlayer.Possess(NewPlayer.Pawn, false);
		// Set the rotation of the client side controller to the spawned pawn
		NewPlayer.ClientSetRotation(NewPlayer.Pawn.Rotation, true);

		// Set the pawn defaults
		SetPlayerDefaults(NewPlayer.Pawn);
		// If we have a screen mirror
		if (Forsage_Controller(NewPlayer).ViewMode == VM_Screen)
		{
			// Remove the collision from the pawn so that we don't encroach the pawn when spawning the vehicle
			NewPlayer.Pawn.SetCollision(false, false, false);
			// Spawn the vehicle
			baseVehicle = SpawnDefaultVehicleFor(NewPlayer, StartSpot);
			if (baseVehicle != None)
			{
				// If we have successfully spawned the vehicle, get the pawn to drive the vehicle
				baseVehicle.TryToDrive(NewPlayer.Pawn);				
			}
		}
	}	
}

function Logout(Controller Exiting)
{	
	super.Logout(Exiting);
	views[Forsage_Controller(Exiting).ViewMode] = 0;	
}

//=============================================================
// Создание сервера

/** создание сервера */
function CreateServer(int InPlayerIndex)
{
	local string mapName;
	local Forsage_GameSettings GameSettings;
	
	//--------------------------------------------
	// выполняем необходимые проверки

	if(ServerName == "")
	{
		`warn("No server name!");
		return;
	}
	
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSub == none)
	{
		`warn("No online subsystem!");
		return;
	}

	GameInterface = OnlineSub.GameInterface;
	if (GameInterface == none)
	{
		`warn("No game interface!");
		return;
	}

	ForsageSettings = UIDataStore_OnlineGameSettings(DSClient.FindDataStore('ForsageGameSettings'));
	if(ForsageSettings == none)
	{
		`warn("Failed to find game settings data store");
		return;
	}

	//--------------------------------------------------------------------------------
	// Задаём настройки для сервера
	GameSettings = Forsage_GameSettings(ForsageSettings.GetCurrentGameSettings());
	GameSettings.bIsLanMatch=TRUE;
	GameSettings.bUsesArbitration=FALSE;
	
	MapName = WorldInfo.GetMapName();
	GameSettings.SetPropertyFromStringByName('Forsage_MapName', MapName);
	GameSettings.SetPropertyFromStringByName('Forsage_ServerName', ServerName);
	//-------------------------------------------------------------------------------
	// создаём сервер

	GameInterface.AddCreateOnlineGameCompleteDelegate(OnGameCreated);

	// todo# обратить внимание на параметр CreateGame
	if(ForsageSettings.CreateGame(InPlayerIndex)==FALSE )
	{
		GameInterface.ClearCreateOnlineGameCompleteDelegate(OnGameCreated);
		`warn("Failed to create online game!");
	}
}

/** обработчик создания сервера */
function OnGameCreated(name SessionName,bool bWasSuccessful)
{
	local string command, map;
	local Forsage_GameSettings GameSettings;

	//---------------------------------------------------------
	// выполняем необходимые проверки

	if(!bWasSuccessful)
	{
		`Log("Failed to create online game!");
		return;
	}

	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSub == None)
	{
		`warn("No online subsystem!");
		return;
	}
		
	GameInterface = OnlineSub.GameInterface;
	if (GameInterface == None)
	{
		`warn("No game interface!");
		return;
	}

	//----------------------------------------------------------------------
	// создаём сервер

	GameInterface.ClearCreateOnlineGameCompleteDelegate(OnGameCreated);

	GameSettings = Forsage_GameSettings(ForsageSettings.GetCurrentGameSettings());
	if(GameSettings == none)
	{
		`warn("No game settings!");
		return;
	}

	GameSettings.GetStringProperty(FORSAGE_PROPERTY_MAPNAME, map);

	// Задаём комманду для создания listener сервера
	command = "open" @ map $ "?listen";
	ConsoleCommand(command);
}
// Создание сервера ==============================================================


//===============================================================================
// Поиск сервера

/** поиск сервера */
function FindServer(int InPlayerIndex)
{
	local OnlineGameSearch GameSearch;

	//----------------------------------------------------
	// выполняем необходимые проверки

	if(DSClient == none)
	{
		`warn("No data store client!");
		return;
	}

	// Получаем ссылку на OnlineGameInterface
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSub == None)
	{
		`warn("No online subsystem!");
		return;
	}

	GameInterface = OnlineSub.GameInterface;
		
	// Получение сслыки на хранилище данных, используеого для получения списка серверов
	ForsageSearch = UDKDataStore_GameSearchBase(DSClient.FindDataStore('ForsageGameSearch'));
	if(ForsageSearch == none)
	{
		`warn("Search data store was not found!");
		return;
	}

	//--------------------------------------------------------------------------------------------
	// начинаем поиск сервера

	// сбрасываем флаг найденного сервера
	bServerWasFound = false;

	// Получение ссылки на объект класса OnlineGameSearch
	GameSearch = ForsageSearch.GetCurrentGameSearch();
	// Задание параметров поиска (здесь жёстко прописаны параметры для поиска LAN)
	GameSearch.bIsLanQuery=TRUE;
	GameSearch.bUsesArbitration=FALSE;	

	// Callback для обработки результатов поиска (добавляем делегат, который будет вызван при завершении поиска)
	GameInterface.AddFindOnlineGamesCompleteDelegate(OnFindOnlineGamesComplete);
	// Запуск поиска серверов
	ForsageSearch.SubmitGameSearch(class'UIInteraction'.static.GetPlayerControllerId(InPlayerIndex), false);
}

/** обработчик окончания поиска сервера */
function OnFindOnlineGamesComplete(bool bWasSuccessful)
{
	local OnlineGameSearch LatestGameSearch;	

	if(ForsageSearch.HasOutstandingQueries())
		return;

	GameInterface.ClearFindOnlineGamesCompleteDelegate(OnFindOnlineGamesComplete);
	
	LatestGameSearch = ForsageSearch.GetActiveGameSearch();

	// если в процессе поиска был найден сервер, устанавливаем флаг
	if (LatestGameSearch != none && LatestGameSearch.Results.Length > 0)
	{
		if (ServerName == LatestGameSearch.Results[0].GameSettings.GetPropertyAsStringByName('Forsage_ServerName'))
			bServerWasFound = true;
	}
	// после окончания поиска вызываем ф-цию, для повторного запуска поиска/подключения к серверу/создания сервера
	ServerFindingComplete();
}
// Поиск сервера ====================================================================================================


//===========================================================================================================
// Подключение к серверу

/** подключение к серверу */
function JoinToServer(int InPlayerIndex)
{
	local OnlineGameSearchResult GameToJoin;

	if(!bServerWasFound)
		return;

	// Получение ссылки на объект - результат поиска, содержащий информацию о сервере,
	// к которому мы подключаемся (нас интересует первый из найденных серверов)
	ForsageSearch.GetSearchResultFromIndex(0, GameToJoin);

	if (GameToJoin.GameSettings != None)
	{
		// Callback для обработки подключения к серверу
		GameInterface.AddJoinOnlineGameCompleteDelegate(OnJoinGameComplete);

		// Запуск процесса подключения к игре
		GameInterface.JoinOnlineGame(InPlayerIndex,'ForsageOnlineSession', GameToJoin);
	}
}

/** обработчик окончания подключения к серверу */
function OnJoinGameComplete(name SessionName, bool bSuccessful)
{
	local string command;

	if(GameInterface == none || !bSuccessful)
		return;
		
	// очищаем результаты поиска, отписываемся от делегатов
	Cleanup();
			
	// если удалось получить ip сервера к которму мы подключаемся
	if (GameInterface.GetResolvedConnectString(SessionName, command))
	{	
		// создаём и выполняем команду для подключения к серверу
		command = "open" @ command;
		ConsoleCommand(command);		
	}
}


/**
 * Очистка результатов поиска в хранилище данных, 
 * отписка от событий завершения поиска доступных серверов и завершения подключения к игре
 */
function Cleanup()
{
	if(GameInterface != none)
	{	
		GameInterface.ClearJoinOnlineGameCompleteDelegate(OnJoinGameComplete);
		GameInterface.ClearFindOnlineGamesCompleteDelegate(OnFindOnlineGamesComplete); // пока скопировал из проекта Gorod как есть
	}

	if(ForsageSearch != none)
	{
		ForsageSearch.ClearAllSearchResults();
	}
}
// Подключение к серверу ================================================================================================================


//=====================================================================================================================================
// Процесс поиска сервера

/** запуск процесса поиска сервера в течение Seconds секунд */
function StartServerFinding(float Seconds)
{
	FindServer(0);
	bServerFindingInProgress = true;
	SetTimer(Seconds, false, 'StopServerFinding');
}

/** 
 *  Запуск повторного поиска сервера или подключение к найденному серверу или создание сервера
 *  в зависимости от результата последнего поиска и флага bServerFindingInProgress
 */
function ServerFindingComplete()
{	
	// если процесс поиска ещё не завершён
	if(bServerFindingInProgress)
	{
		// если не нашли сервер
		if(!bServerWasFound)
		{
			// продолжаем искать
			FindServer(0);
		}
		else
		{
			// дополнительная проверка
			if(WorldInfo.NetMode != NM_Standalone)
			{
				`warn("Failed to join server: netmode is not standalone");
				return;
			}

			// поключаемся к найденному серверу
			JoinToServer(0);
			// завершаем процесс поиска
			bServerFindingInProgress = false;
		}
	}
	else
	{
		// дополнительная проверка
		if(WorldInfo.NetMode != NM_Standalone)
		{
			`warn("Failed to create a server: netmode is not standalone");
			return;
		}
		// создаём сервер
		CreateServer(0);
		// завершаем процесс поиска
		bServerFindingInProgress = false;
	}
}

/** завершение процесса поиска по таймауту (ф-ция для таймера) */
function StopServerFinding()
{
	if (bServerFindingInProgress)
		bServerFindingInProgress = false;
}

DefaultProperties
{	
	bDelayedStart=false
	DefaultPawnClass=class'Forsage.Forsage_Pawn'	
	PlayerControllerClass=class'Forsage.Forsage_Controller'	
	HUDType = class'Forsage_HUD'
	MaxPlayersAllowed = 4			

	LocAutodrom = (X=127473, Y=131274, Z=1834)	
	LocCity = (X=81273, Y=116912, Z=1790)
	RotAutodrom = (Pitch=0, Roll= 0, Yaw=20480)
	RotCity = (Pitch=0, Roll=0, Yaw=19456)	

	Forsage_GameSearch_DataStoreClass = class'Forsage.Forsage_DataStore_GameSearch'
	Forsage_GameSettings_DataStoreClass = class'Forsage.Forsage_DataStore_GameSettings'
	OnlineGameSettingsClass=class'Forsage_GameSettings'
	ServerName="ForsageServer"

	bServerWasFound = false
	bServerFindingInProgress = false
	ServerFindingTimeout = 5
}