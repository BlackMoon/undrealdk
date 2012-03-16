class Forsage_Game extends GameInfo;
`include(Forsage_OnlineConstants.uci)

/** ����� ����������� ���� ��� ��������������� �������� (������� ������, ������� ������� ����, ������� ����� �������, ������� ������ �������), ���������� - ������� ������ */
enum eViewMode           
{
	VM_Screen,                      // ������� ������	
	VM_BackMirror,                  // ������� ������� ����	
	VM_LeftMirror,                  // ������� ����� �������
	VM_RightMirror                  // ������� ������ �������
};

var enum eGameType
{
	GT_Autodrom,
	GT_City
} GameType;

var Forsage_DP_Signals objDPSignals;    //  ��� ������ � ������������ ����������
var private byte views[4];              // ��������� ������� ���� (��������/�����)

var private Vehicle baseVehicle;        // ������ �� ������� vehicle (1�)
/** ��������� ����� ��� ��������� � ��������� �������*/
var const vector locAutodrom, locCity;    
var const rotator rotAutodrom, rotCity;

/** ����� ��������� ��� ������ �������� */
var class<Forsage_DataStore_GameSearch> Forsage_GameSearch_DataStoreClass;
/** ����� ��������� ��� �������� ������� */
var class<Forsage_DataStore_GameSettings> Forsage_GameSettings_DataStoreClass;

/** ������ ��� ��������� */
var DataStoreClient DSClient;

/** ������ �� ��������� ������ ��� ������ �������� */
var UDKDataStore_GameSearchBase ForsageSearch;
/** ������ �� ��������� ��� �������� ������� */
var UIDataStore_OnlineGameSettings ForsageSettings;

/** ����, ������������, ��� � ���������� ���������� ������ ��� ������ ������ */
var bool bServerWasFound;

/** ����, ������������, ��� ��� ����� ������� */
var bool bServerFindingInProgress;

/** ������� ��� �������� ������ ������� (���� ������ �� ����� ������ �� ��������� �����, �� ��������� �������� �������) */
var float ServerFindingTimeout;
var private string ServerName;

event InitGame(string Options, out string ErrorMessage)
{
	local class<UIDataStore> store;	

	super.InitGame(Options, ErrorMessage);
	//----------------------------------------------------------------
	// ������ � ������������ ��������� ������ 

	// �������� ������ �� ������� ��� ��������� ������
	DSClient = class'UIInteraction'.static.GetDataStoreClient();
	if ( DSClient != None )
	{
		store = DSClient.FindDataStoreClass(Forsage_GameSearch_DataStoreClass);
		if(store == none)
		{
			// ������ � ������������ ��������� ������ ��� ������ ��������
			ForsageSearch = DSClient.CreateDataStore(Forsage_GameSearch_DataStoreClass);
			DSClient.RegisterDataStore(ForsageSearch);
		}

		store = DSClient.FindDataStoreClass(Forsage_GameSettings_DataStoreClass);
		if(store == none)
		{
			// ������ � ������������ ��������� ������ � ����������� ������������ �������
			ForsageSettings = DSClient.CreateDataStore(Forsage_GameSettings_DataStoreClass);
			DSClient.RegisterDataStore(ForsageSettings);
		}
	}

	//-----------------------------------------------------------------------------
	// ���� ��� ������������ ������ ��� ������ �����
	// ���� ������ ��� �� ������ ��� �� ��� �� ������������ � �������
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
 	if (baseVehicle == none)     // 1� ����� �� ������� - ��� �� ������			
		C.ServerInsertPPChain();		
	else	
		C.ClientInsertPPChain(PostProcessChain'Gorod_Effects.PostProcess.ppc_Mirror');				
	
	C.ViewMode = eViewMode(getFreeViewMode());
	super.PostLogin(NewPlayer);				
}
// �������� ��������� ���
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
// �������� �������

/** �������� ������� */
function CreateServer(int InPlayerIndex)
{
	local string mapName;
	local Forsage_GameSettings GameSettings;
	
	//--------------------------------------------
	// ��������� ����������� ��������

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
	// ����� ��������� ��� �������
	GameSettings = Forsage_GameSettings(ForsageSettings.GetCurrentGameSettings());
	GameSettings.bIsLanMatch=TRUE;
	GameSettings.bUsesArbitration=FALSE;
	
	MapName = WorldInfo.GetMapName();
	GameSettings.SetPropertyFromStringByName('Forsage_MapName', MapName);
	GameSettings.SetPropertyFromStringByName('Forsage_ServerName', ServerName);
	//-------------------------------------------------------------------------------
	// ������ ������

	GameInterface.AddCreateOnlineGameCompleteDelegate(OnGameCreated);

	// todo# �������� �������� �� �������� CreateGame
	if(ForsageSettings.CreateGame(InPlayerIndex)==FALSE )
	{
		GameInterface.ClearCreateOnlineGameCompleteDelegate(OnGameCreated);
		`warn("Failed to create online game!");
	}
}

/** ���������� �������� ������� */
function OnGameCreated(name SessionName,bool bWasSuccessful)
{
	local string command, map;
	local Forsage_GameSettings GameSettings;

	//---------------------------------------------------------
	// ��������� ����������� ��������

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
	// ������ ������

	GameInterface.ClearCreateOnlineGameCompleteDelegate(OnGameCreated);

	GameSettings = Forsage_GameSettings(ForsageSettings.GetCurrentGameSettings());
	if(GameSettings == none)
	{
		`warn("No game settings!");
		return;
	}

	GameSettings.GetStringProperty(FORSAGE_PROPERTY_MAPNAME, map);

	// ����� �������� ��� �������� listener �������
	command = "open" @ map $ "?listen";
	ConsoleCommand(command);
}
// �������� ������� ==============================================================


//===============================================================================
// ����� �������

/** ����� ������� */
function FindServer(int InPlayerIndex)
{
	local OnlineGameSearch GameSearch;

	//----------------------------------------------------
	// ��������� ����������� ��������

	if(DSClient == none)
	{
		`warn("No data store client!");
		return;
	}

	// �������� ������ �� OnlineGameInterface
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSub == None)
	{
		`warn("No online subsystem!");
		return;
	}

	GameInterface = OnlineSub.GameInterface;
		
	// ��������� ������ �� ��������� ������, ������������ ��� ��������� ������ ��������
	ForsageSearch = UDKDataStore_GameSearchBase(DSClient.FindDataStore('ForsageGameSearch'));
	if(ForsageSearch == none)
	{
		`warn("Search data store was not found!");
		return;
	}

	//--------------------------------------------------------------------------------------------
	// �������� ����� �������

	// ���������� ���� ���������� �������
	bServerWasFound = false;

	// ��������� ������ �� ������ ������ OnlineGameSearch
	GameSearch = ForsageSearch.GetCurrentGameSearch();
	// ������� ���������� ������ (����� ����� ��������� ��������� ��� ������ LAN)
	GameSearch.bIsLanQuery=TRUE;
	GameSearch.bUsesArbitration=FALSE;	

	// Callback ��� ��������� ����������� ������ (��������� �������, ������� ����� ������ ��� ���������� ������)
	GameInterface.AddFindOnlineGamesCompleteDelegate(OnFindOnlineGamesComplete);
	// ������ ������ ��������
	ForsageSearch.SubmitGameSearch(class'UIInteraction'.static.GetPlayerControllerId(InPlayerIndex), false);
}

/** ���������� ��������� ������ ������� */
function OnFindOnlineGamesComplete(bool bWasSuccessful)
{
	local OnlineGameSearch LatestGameSearch;	

	if(ForsageSearch.HasOutstandingQueries())
		return;

	GameInterface.ClearFindOnlineGamesCompleteDelegate(OnFindOnlineGamesComplete);
	
	LatestGameSearch = ForsageSearch.GetActiveGameSearch();

	// ���� � �������� ������ ��� ������ ������, ������������� ����
	if (LatestGameSearch != none && LatestGameSearch.Results.Length > 0)
	{
		if (ServerName == LatestGameSearch.Results[0].GameSettings.GetPropertyAsStringByName('Forsage_ServerName'))
			bServerWasFound = true;
	}
	// ����� ��������� ������ �������� �-���, ��� ���������� ������� ������/����������� � �������/�������� �������
	ServerFindingComplete();
}
// ����� ������� ====================================================================================================


//===========================================================================================================
// ����������� � �������

/** ����������� � ������� */
function JoinToServer(int InPlayerIndex)
{
	local OnlineGameSearchResult GameToJoin;

	if(!bServerWasFound)
		return;

	// ��������� ������ �� ������ - ��������� ������, ���������� ���������� � �������,
	// � �������� �� ������������ (��� ���������� ������ �� ��������� ��������)
	ForsageSearch.GetSearchResultFromIndex(0, GameToJoin);

	if (GameToJoin.GameSettings != None)
	{
		// Callback ��� ��������� ����������� � �������
		GameInterface.AddJoinOnlineGameCompleteDelegate(OnJoinGameComplete);

		// ������ �������� ����������� � ����
		GameInterface.JoinOnlineGame(InPlayerIndex,'ForsageOnlineSession', GameToJoin);
	}
}

/** ���������� ��������� ����������� � ������� */
function OnJoinGameComplete(name SessionName, bool bSuccessful)
{
	local string command;

	if(GameInterface == none || !bSuccessful)
		return;
		
	// ������� ���������� ������, ������������ �� ���������
	Cleanup();
			
	// ���� ������� �������� ip ������� � ������� �� ������������
	if (GameInterface.GetResolvedConnectString(SessionName, command))
	{	
		// ������ � ��������� ������� ��� ����������� � �������
		command = "open" @ command;
		ConsoleCommand(command);		
	}
}


/**
 * ������� ����������� ������ � ��������� ������, 
 * ������� �� ������� ���������� ������ ��������� �������� � ���������� ����������� � ����
 */
function Cleanup()
{
	if(GameInterface != none)
	{	
		GameInterface.ClearJoinOnlineGameCompleteDelegate(OnJoinGameComplete);
		GameInterface.ClearFindOnlineGamesCompleteDelegate(OnFindOnlineGamesComplete); // ���� ���������� �� ������� Gorod ��� ����
	}

	if(ForsageSearch != none)
	{
		ForsageSearch.ClearAllSearchResults();
	}
}
// ����������� � ������� ================================================================================================================


//=====================================================================================================================================
// ������� ������ �������

/** ������ �������� ������ ������� � ������� Seconds ������ */
function StartServerFinding(float Seconds)
{
	FindServer(0);
	bServerFindingInProgress = true;
	SetTimer(Seconds, false, 'StopServerFinding');
}

/** 
 *  ������ ���������� ������ ������� ��� ����������� � ���������� ������� ��� �������� �������
 *  � ����������� �� ���������� ���������� ������ � ����� bServerFindingInProgress
 */
function ServerFindingComplete()
{	
	// ���� ������� ������ ��� �� ��������
	if(bServerFindingInProgress)
	{
		// ���� �� ����� ������
		if(!bServerWasFound)
		{
			// ���������� ������
			FindServer(0);
		}
		else
		{
			// �������������� ��������
			if(WorldInfo.NetMode != NM_Standalone)
			{
				`warn("Failed to join server: netmode is not standalone");
				return;
			}

			// ����������� � ���������� �������
			JoinToServer(0);
			// ��������� ������� ������
			bServerFindingInProgress = false;
		}
	}
	else
	{
		// �������������� ��������
		if(WorldInfo.NetMode != NM_Standalone)
		{
			`warn("Failed to create a server: netmode is not standalone");
			return;
		}
		// ������ ������
		CreateServer(0);
		// ��������� ������� ������
		bServerFindingInProgress = false;
	}
}

/** ���������� �������� ������ �� �������� (�-��� ��� �������) */
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