class Kamaz_HUD_CreateServMenu extends Kamaz_GFxMoviePlayer;
// ����� ���������� ����������� ���������
`include(Kamaz_OnlineConstants.uci)

/** ������ �� ������� ���� */
var Kamaz_HUD GorodHUD;

/////���� ����������
/** ������ "�����" */
var GFxClikWidget btnBack;
var GFxClikWidget btnCreateServ;
var GFxClikWidget txtNewServName;
/** strings from ini-file */
var config string strBtnCreateServ;
var config string strServerName;
var config string strCreateServMenuTitle;

var UIDataStore_OnlineGameSettings SettingsDataStore;
var DataStoreClient DSClient;

function bool Start(optional bool StartPaused = false) 
{
	DSClient = class'UIInteraction'.static.GetDataStoreClient();
	super.Start(StartPaused);
	Advance(0);
	return true;
}

event bool WidgetInitialized (name WidgetName, name WidgetPath, GFxObject Widget) 
{
	// ��������� ������������ ��������� 
	switch(WidgetName)
	{
		case('createServBackBtn'):
			btnBack = GFxClikWidget(Widget);
			btnBack.AddEventListener('CLIK_click', OnBackButtonClick);
			btnBack.SetString("label", strBackBtn);
			break;
		case('CreateServBtn'):
			btnCreateServ = GFxClikWidget(Widget);
			btnCreateServ.AddEventListener('CLIK_click', OnCreateServButtonClick);
			btnCreateServ.SetString("label", strBtnCreateServ);
			break;
		case('newServName'):
			txtNewServName = GFxClikWidget(Widget);			
			break;
		case('ServerNameTextField'):
			widget.SetString("label", strServerName);
			break;
		case('CreateServMenuTitle'):
			widget.SetText(strCreateServMenuTitle);
			break;
		default:
			break;
	}

	return true;
}
/** ��������� ������� ������*/
function OnBackButtonClick(GFxClikWidget.EventData ev)
{
	goBack();
}

function OnCreateServButtonClick(GFxClikWidget.EventData ev)
{

	local OnlineSubsystem OnlineSub;
	local OnlineGameInterface GameInterface1;
	local string servername;
	if(txtNewServName!=none)
	{
		servername = txtNewServName.GetText();
		if(servername != "" )
		{
			`log("Server name: " $ serverName);
		}
		else
		{
			servername = "GORODDEFAULTSERVER";
		}
		OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
		if (OnlineSub != None)
		{
			GameInterface1 = OnlineSub.GameInterface;
			if (GameInterface1 != None)
			{
				SettingsDataStore = UIDataStore_OnlineGameSettings(DSClient.FindDataStore('Gorod_GameSettings'));

				if(SettingsDataStore != none)
				{
					/// !!!! �������� dedicated ������� �� serverName
					SetupGameSettings(serverName);

					GameInterface1.AddCreateOnlineGameCompleteDelegate(OnGameCreated);

					if(SettingsDataStore.CreateGame(GetPlayerControllerId(0))==FALSE )
					{
						GameInterface1.ClearCreateOnlineGameCompleteDelegate(OnGameCreated);
						`warn("Failed to create online game!");
					}
				}
				else
				{
					`warn("No settings data store!");
				}
			}
			else
			{
				`warn("No game interface!");
			}
		}
		else
		{
			`warn("No online subsystem!");
		}
	}
	else
	{
		`warn("Trouble with flash!");
	}

}


function OnGameCreated(name SessionName,bool bWasSuccessful)
{
	local string command;
	local OnlineSubsystem OnlineSub;
	local OnlineGameInterface GameInterface1;

	// Figure out if we have an online subsystem registered
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSub != None)
	{
		// Grab the game interface to verify the subsystem supports it
		GameInterface1 = OnlineSub.GameInterface;
		if (GameInterface1 != None)
		{

			// Clear the delegate we set.
			GameInterface1.ClearCreateOnlineGameCompleteDelegate(OnGameCreated);
			
			// If we were successful, then travel.
			if(bWasSuccessful)
			{
				// ����� �������� ��� �������� listener �������
				command = "open City?listen";

				`Log("Game Created, Traveling: " $ command);

				// Do the server travel.
				ConsoleCommand(command);
			}
			else
			{
				`Log("Failed to create online game!");
			}
		}
		else
		{
			`Log("No game interface found!");
		}
	}
	else
	{
		`Log("No online subsystem found!");
	}
}


function SetupGameSettings(string serverName)
{
	local Gorod_GameSettingsSC GameSettings;

	// ����� ��������� ��� �������
	GameSettings = Gorod_GameSettingsSC(SettingsDataStore.GetCurrentGameSettings());
	// ����� ����������� ��������� ��� LAN ����
	GameSettings.bIsLanMatch=TRUE;
	GameSettings.bUsesArbitration=FALSE;


	GameSettings.SetPropertyFromStringByName('Gorod_ServerNameTestDinar', serverName);
}

function int GetPlayerControllerId(int PlayerIndex)
{
	return class'UIInteraction'.static.GetPlayerControllerId(PlayerIndex);
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

	if (GorodHUD.WorldInfo.NetMode != NM_Standalone &&
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
/** �������� �� ������� UI ������� � ini-����� */
function checkConfig()
{
	super.checkConfig();
	if (len(strBtnCreateServ) == 0) {
		strBtnCreateServ = "�������";				
		bNeedToSave = true;		
	}	

	if (len(strServerName) == 0) {
		strServerName = "�������� �������:";				
		bNeedToSave = true;		
	}		

	if (len(strCreateServMenuTitle) == 0) {
		strCreateServMenuTitle = "������� ������";				
		bNeedToSave = true;		
	}				
}

DefaultProperties
{
	bCaptureInput = true;
	WidgetBindings.Add((WidgetName="createServBackBtn", WidgetClass=class'GFxClikWidget'));
	WidgetBindings.Add((WidgetName="CreateServBtn", WidgetClass=class'GFxClikWidget'));
	WidgetBindings.Add((WidgetName="newServName", WidgetClass=class'GFxClikWidget'));
	MovieInfo=SwfMovie'menu.CreateServMenu.CreateServ'
}
