class Kamaz_HUD_ConnectToServMenu extends Kamaz_GFxMoviePlayer;
// здесь определены необходимые константы
`include(Kamaz_OnlineConstants.uci)
var Kamaz_HUD KamazHUD;
/** кнопки */
var GFxClikWidget btnBack;

var GFxClikWidget btnRefresh;
var GFxClikWidget btnSelect;
/** Лист для всех серверов */
var GFxClikWidget listServers;
/** strings from ini-file */
var config string strBtnRefresh;
var config string strBtnSelect;
var config string strConnectToServMenuTitle;
/** Выбранный индекс*/
var int selectedIndex;
struct Option
{
	var string OptionName;
	var string OptionLabel;
	var string OptionDesc;
};

var array<Option> ListOptions;

/**
 * Ссылка на хранилище результатов поиска
 */
var UDKDataStore_GameSearchBase	SearchDataStore;

/**
 * Название хранилища данных
 */
var name SearchDSName;
/**
 * Ссылка на интерфейс игры
 */
var OnlineGameInterface GameInterface;

var DataStoreClient DSClient;

function bool Start(optional bool StartPaused = false) 
{
	DSClient = class'UIInteraction'.static.GetDataStoreClient();
	super.Start(StartPaused);
	//обновляем данные о серверах
	
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
/** Проверка на наличие UI текстов в ini-файле */
function checkConfig()
{	
	super.checkConfig();
	if (len(strConnectToServMenuTitle) == 0) {	
		strConnectToServMenuTitle = "Подключиться к серверу";
		bNeedToSave = true;
	}

	if (len(strBtnRefresh) == 0) {
		strBtnRefresh = "Обновить";				
		bNeedToSave = true;		
	}		

	if (len(strBtnSelect) == 0) {
		strBtnSelect = "Выбрать";				
		bNeedToSave = true;		
	}	
}
//обновить
function OnRefreshButtonClick(GFxClikWidget.EventData ev)
{
	RefreshServerList(0);
}
function OnBackButtonClick(GFxClikWidget.EventData ev)
{
	goBack();
}

/********************************************************/
/*          Получение списка доступных серверов         */
/********************************************************/


/**
 * Запуск поиска доступных серверов
 */
function RefreshServerList(int InPlayerIndex)
{
	local OnlineSubsystem OnlineSub;
	local OnlineGameSearch GameSearch;
	`log(">>>>>>>>>>>>>>>>>>>>RefreshServerList");
	// Название хранилища, используеого для получения списка серверов
	SearchDSName = 'Kamaz_GameSearch';

	if(DSClient != None)
	{
		// Получаем ссылку на OnlineGameInterface
		OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
		if (OnlineSub != None)
		{
			GameInterface = OnlineSub.GameInterface;
		}
		
		// Получение сслыки на хранилище данных, используеого для получения списка серверов
		SearchDataStore = UDKDataStore_GameSearchBase(DSClient.FindDataStore(SearchDSName));
		if(SearchDataStore != none)
		{
			// Получение ссылки на объект класса OnlineGameSearch
			GameSearch = SearchDataStore.GetCurrentGameSearch();
			// Задание параметров поиска (здесь жёстко прописаны параметры для поиска LAN)
			GameSearch.MaxSearchResults = 1000;
			GameSearch.bIsLanQuery=TRUE;
			GameSearch.bUsesArbitration=FALSE;

			// Callback для обработки результатов поиска (добавляем делегат, который будет вызван при завершении поиска)
			GameInterface.AddFindOnlineGamesCompleteDelegate(OnFindOnlineGamesCompleteDelegate);
			// Запуск поиска серверов
			SearchDataStore.SubmitGameSearch(class'UIInteraction'.static.GetPlayerControllerId(InPlayerIndex), false);
		}
		else
		{
			`warn("Gorod data store not found!");
		}
	}
}


/**
 * Делегат, который вызывается при завершении поиска
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
 * Функция обработчик результатов поиска
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
			// количество игроков на сервере
			NumPlayers = GameSettings.NumPublicConnections-GameSettings.NumOpenPublicConnections;
			// Добавляем информацию об очередном найденном сервере в список
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

/** Подключиться к серверу */

function OnSelectButtonClick(GFxClikWidget.EventData ev)
{
	local OnlineGameSearchResult GameToJoin;
	local int ControllerId;


	// Получение ссылки на объект - результат поиска, содержащий информацию о сервере,
	// к которому мы подключаемся
	SearchDataStore.GetSearchResultFromIndex(selectedIndex, GameToJoin);

	if (GameToJoin.GameSettings != None)
	{
		// Callback для обработки подключения к серверу
		GameInterface.AddJoinOnlineGameCompleteDelegate(OnJoinGameComplete);
		ControllerId = 0;
		// Запуск процесса подключения к игре
		GameInterface.JoinOnlineGame(ControllerId,'Game',GameToJoin);
	}
}


/** Подключение к выбранному серверу */
function OnJoinGameComplete(name SessionName,bool bSuccessful)
{
	local string command;	

	if (GameInterface != None)
	{
		if (bSuccessful)
		{
			Cleanup();
			
			// если удалось получить ip сервера к которму мы подключаемся
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
 * Очистка результатов поиска в хранилище данных, 
 * отписка от событий завершения поиска доступных серверов и завершения подключения к игре
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
