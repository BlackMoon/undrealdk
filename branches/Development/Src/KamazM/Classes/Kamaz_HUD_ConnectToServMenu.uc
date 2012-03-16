class Kamaz_HUD_ConnectToServMenu extends Kamaz_GFxMoviePlayer;
// ����� ���������� ����������� ���������
`include(Kamaz_OnlineConstants.uci)
var Kamaz_HUD KamazHUD;
/** ������ */
var GFxClikWidget btnBack;

var GFxClikWidget btnRefresh;
var GFxClikWidget btnSelect;
/** ���� ��� ���� �������� */
var GFxClikWidget listServers;
/** strings from ini-file */
var config string strBtnRefresh;
var config string strBtnSelect;
var config string strConnectToServMenuTitle;
/** ��������� ������*/
var int selectedIndex;
struct Option
{
	var string OptionName;
	var string OptionLabel;
	var string OptionDesc;
};

var array<Option> ListOptions;

/**
 * ������ �� ��������� ����������� ������
 */
var UDKDataStore_GameSearchBase	SearchDataStore;

/**
 * �������� ��������� ������
 */
var name SearchDSName;
/**
 * ������ �� ��������� ����
 */
var OnlineGameInterface GameInterface;

var DataStoreClient DSClient;

function bool Start(optional bool StartPaused = false) 
{
	DSClient = class'UIInteraction'.static.GetDataStoreClient();
	super.Start(StartPaused);
	//��������� ������ � ��������
	
	RefreshServerList(0);	
	Advance(0);
	return true;
}

event bool WidgetInitialized (name WidgetName, name WidgetPath, GFxObject Widget) 
{	
	switch(WidgetName)
	{
		case('serversBackBtn'):
			btnBack = GFxClikWidget(Widget);
			btnBack.AddEventListener('CLIK_click', OnBackButtonClick);
			btnBack.SetString("label", strBackBtn);
			break;
		case('refreshServBtn'):
			btnRefresh = GFxClikWidget(Widget);
			btnRefresh.AddEventListener('CLIK_click', OnRefreshButtonClick);
			btnRefresh.SetString("label", strBtnRefresh);
		case('serversList'):
			listServers = GFxClikWidget(Widget);
			listServers.AddEventListener('CLIK_itemClick', OnListItemClick);			
			break;
		case('SelectServBtn'):
			btnSelect = GFxClikWidget(Widget);
			btnSelect.AddEventListener('CLIK_click', OnSelectButtonClick);
			btnSelect.SetString("label", strBtnSelect);
			break;
		case ('ConnectToServMenuTitle'):			
			widget.SetText(strConnectToServMenuTitle);
		default:
			break;
	}

	return true;
}
/** �������� �� ������� UI ������� � ini-����� */
function checkConfig()
{	
	super.checkConfig();
	if (len(strConnectToServMenuTitle) == 0) {	
		strConnectToServMenuTitle = "������������ � �������";
		bNeedToSave = true;
	}

	if (len(strBtnRefresh) == 0) {
		strBtnRefresh = "��������";				
		bNeedToSave = true;		
	}		

	if (len(strBtnSelect) == 0) {
		strBtnSelect = "�������";				
		bNeedToSave = true;		
	}	
}
//��������
function OnRefreshButtonClick(GFxClikWidget.EventData ev)
{
	RefreshServerList(0);
}
function OnBackButtonClick(GFxClikWidget.EventData ev)
{
	goBack();
}

/********************************************************/
/*          ��������� ������ ��������� ��������         */
/********************************************************/


/**
 * ������ ������ ��������� ��������
 */
function RefreshServerList(int InPlayerIndex)
{
	local OnlineSubsystem OnlineSub;
	local OnlineGameSearch GameSearch;
	`log(">>>>>>>>>>>>>>>>>>>>RefreshServerList");
	// �������� ���������, ������������ ��� ��������� ������ ��������
	SearchDSName = 'Kamaz_GameSearch';

	if(DSClient != None)
	{
		// �������� ������ �� OnlineGameInterface
		OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
		if (OnlineSub != None)
		{
			GameInterface = OnlineSub.GameInterface;
		}
		
		// ��������� ������ �� ��������� ������, ������������ ��� ��������� ������ ��������
		SearchDataStore = UDKDataStore_GameSearchBase(DSClient.FindDataStore(SearchDSName));
		if(SearchDataStore != none)
		{
			// ��������� ������ �� ������ ������ OnlineGameSearch
			GameSearch = SearchDataStore.GetCurrentGameSearch();
			// ������� ���������� ������ (����� ����� ��������� ��������� ��� ������ LAN)
			GameSearch.MaxSearchResults = 1000;
			GameSearch.bIsLanQuery=TRUE;
			GameSearch.bUsesArbitration=FALSE;

			// Callback ��� ��������� ����������� ������ (��������� �������, ������� ����� ������ ��� ���������� ������)
			GameInterface.AddFindOnlineGamesCompleteDelegate(OnFindOnlineGamesCompleteDelegate);
			// ������ ������ ��������
			SearchDataStore.SubmitGameSearch(class'UIInteraction'.static.GetPlayerControllerId(InPlayerIndex), false);
		}
		else
		{
			`warn("Gorod data store not found!");
		}
	}
}


/**
 * �������, ������� ���������� ��� ���������� ������
 */
function OnFindOnlineGamesCompleteDelegate(bool bWasSuccessful)
{
	local bool bSearchCompleted;
	`log("<<OnFindOnlineGamesCompleteDelegate");
	bSearchCompleted = !SearchDataStore.HasOutstandingQueries();
	
	if(bSearchCompleted)
	{
		GameInterface.ClearFindOnlineGamesCompleteDelegate(OnFindOnlineGamesCompleteDelegate);
		OnFindOnlineGamesComplete(bWasSuccessful);
	}
}
/**
 * ������� ���������� ����������� ������
 */
function OnFindOnlineGamesComplete(bool bWasSuccessful)
{
	local OnlineGameSearch LatestGameSearch;
	local byte i;
	local int NumPlayers;
	local Gorod_GameSettingsSC GameSettings;
	local GFxObject DataProvider;
	local GFxObject TempObj;
	
	local string lServerName;
	LatestGameSearch = SearchDataStore.GetActiveGameSearch();

	DataProvider = CreateArray();
	if (LatestGameSearch != none)
	{	
		for (i = 0; i < LatestGameSearch.Results.Length; i++)
		{
			GameSettings = Gorod_GameSettingsSC(LatestGameSearch.Results[i].GameSettings);
			// ���������� ������� �� �������
			NumPlayers = GameSettings.NumPublicConnections-GameSettings.NumOpenPublicConnections;
			// ��������� ���������� �� ��������� ��������� ������� � ������
			GameSettings.GetStringProperty(KAMAZ_PROPERTY_SERVERNAME, lServerName);

			TempObj = CreateObject("Object");
			TempObj.SetString("name", lServerName);
			TempObj.SetString("ip", NumPlayers$"/"$GameSettings.NumPublicConnections);
			DataProvider.SetElementObject(i,TempObj);
		}
	}
	SetListData(DataProvider);
}

function SetListData(GFxObject DataProvider)
{
	ActionScriptVoid("SetListData");
}

function OnListItemClick(GFxClikWidget.EventData ev)
{
	selectedIndex = ev.index;
}

/** ������������ � ������� */

function OnSelectButtonClick(GFxClikWidget.EventData ev)
{
	local OnlineGameSearchResult GameToJoin;
	local int ControllerId;


	// ��������� ������ �� ������ - ��������� ������, ���������� ���������� � �������,
	// � �������� �� ������������
	SearchDataStore.GetSearchResultFromIndex(selectedIndex, GameToJoin);

	if (GameToJoin.GameSettings != None)
	{
		// Callback ��� ��������� ����������� � �������
		GameInterface.AddJoinOnlineGameCompleteDelegate(OnJoinGameComplete);
		ControllerId = 0;
		// ������ �������� ����������� � ����
		GameInterface.JoinOnlineGame(ControllerId,'Game',GameToJoin);
	}
}


/** ����������� � ���������� ������� */
function OnJoinGameComplete(name SessionName,bool bSuccessful)
{
	local string command;	

	if (GameInterface != None)
	{
		if (bSuccessful)
		{
			Cleanup();
			
			// ���� ������� �������� ip ������� � ������� �� ������������
			if(GameInterface.GetResolvedConnectString('Game',command))
			{	
				command = "open" @ command;

				`log(">>" @ command);
				ConsoleCommand(command);
			}
		}
	}
}

/**
 * ������� ����������� ������ � ��������� ������, 
 * ������� �� ������� ���������� ������ ��������� �������� � ���������� ����������� � ����
 */
function Cleanup()
{
	if ( GameInterface != None )
	{	
		GameInterface.ClearJoinOnlineGameCompleteDelegate(OnJoinGameComplete);
		GameInterface.ClearFindOnlineGamesCompleteDelegate(OnFindOnlineGamesCompleteDelegate);
	}

	if ( SearchDataStore != None )
	{
		SearchDataStore.ClearAllSearchResults();
	}
}


/*          */
function QuitGame()
{
	if(CleanupOnlineSubsystemSession()==false)
	{
		FinishQuitToMainMenu();
	}
}

function FinishQuitToMainMenu()
{
	ConsoleCommand("Disconnect");
}

function bool CleanupOnlineSubsystemSession()
{
	local OnlineSubsystem OnlineSub;

	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();

	if (KamazHUD.WorldInfo.NetMode != NM_Standalone &&
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
	local OnlineSubsystem OnlineSub;

	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();

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
	local OnlineSubsystem OnlineSub;

	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();

	OnlineSub.GameInterface.ClearDestroyOnlineGameCompleteDelegate(OnDestroyOnlineGameComplete);

	FinishQuitToMainMenu();
}

DefaultProperties
{
	bCaptureInput = true;
	WidgetBindings.Add((WidgetName="serversBackBtn", WidgetClass=class'GFxClikWidget'));
	WidgetBindings.Add((WidgetName="serversList", WidgetClass=class'GFxClikWidget'));
	WidgetBindings.Add((WidgetName="refreshServBtn", WidgetClass=class'GFxClikWidget'));
	WidgetBindings.Add((WidgetName="SelectServBtn", WidgetClass=class'GFxClikWidget'));

	
	MovieInfo=SwfMovie'menu.ConnectToServMenu.ConnectToServ';
}
