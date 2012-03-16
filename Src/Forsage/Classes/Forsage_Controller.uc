class Forsage_Controller extends Common_PlayerController dependson(Forsage_Game)
	implements(Gorod_EventListener);
`include(Library_Msg.uci);

/** indicates controller ViewMode */
var repnotify eViewMode ViewMode;
/** материал тонировки зеркал*/
var MaterialInstanceConstant matInst;   
/** мувер для окна UDK */
var private Forsage_Wnd forsageWnd;	
var bool bMenuIsFirstTime;              // при первом показе нельзя закрыть меню по esc

var array<int> RegisteredMessages; 

replication
{
	if (bNetInitial) ViewMode;	
}

function bool CheckEvent(int id)
{
	return (RegisteredMessages.Find(id) == INDEX_NONE);
}

function ClearMessage()
{
	if(RegisteredMessages.Length > 0)
		RegisteredMessages.Remove(0,1);
}

function HandleEvent(Gorod_Event evt)
{
	local MessageInfo msgInfo;

	if(evt.eventType == GOROD_EVENT_HUD  
		&&  CheckEvent(evt.messageID)  
		&&  WorldInfo.NetMode == NM_ListenServer
		&&  !Forsage_HUD(myHUD).menu.bMovieIsOpen
		&&  Forsage_HUD(myHUD).loadingPlayer == none)
	{
		RegisteredMessages.AddItem(evt.messageID);
		msgInfo = MessagesManager.getMessageContent(evt.messageID);
		PlayerMessageManager.PushMessage(msgInfo.Text, msgInfo.Title);
	}	
}

simulated event ReplicatedEvent(name VarName)
{	
	if (VarName == 'ViewMode')	{
		Forsage_Pawn(Pawn).ViewMode = ViewMode;
		forsageWnd.moveWindow(ViewMode);		
	}
	else super.ReplicatedEvent(VarName); 	
}

simulated event PostBeginPlay()
{
	local Gorod_PDDMessages PDDMessages;
	
	super.PostBeginPlay();	
	
	forsageWnd = new class'Forsage_Wnd';
	forsageWnd.init();

	// регистация на сообщения типа HUD
	EventDispatcher.RegisterListener(self, GOROD_EVENT_HUD);

	PlayerMessageManager.MessageBoxX = 700;
	PlayerMessageManager.MsgBoxMovie.RenderTexture = none;

	// регистация справочников сообщений ----------------------------------------------------------
	PDDMessages = new class'Gorod_PDDMessages';
	PDDMessages.checkConfig();
	MessagesManager.Register(PDDMessages);
	//---------------------------------------------------------------------------------------------

	SetTimer(5, true, 'ClearMessage');
}

reliable client function ClientInsertPPChain(PostProcessChain InChain)
{
	local LocalPlayer LP;	
	LP = LocalPlayer(Player);
	LP.RemoveAllPostProcessingChains();
	LP.InsertPostProcessingChain(InChain, INDEX_NONE, true);	
	matInst = MaterialInstanceConstant(MaterialEffect(InChain.FindPostProcessEffect('MatMirror')).Material);
}

reliable server function ServerInsertPPChain()
{
	local LocalPlayer LP;	
	LP = LocalPlayer(Player);
	LP.RemoveAllPostProcessingChains();
	LP.InsertPostProcessingChain(LP.Outer.GetWorldPostProcessChain(), INDEX_NONE, true);	
}

reliable client function setToneColor(bool bToning)
{
	local LinearColor clr;
	
	clr.A = 1.f;
	clr.B = 1.f;
	clr.G = 1.f;

	if (matInst != none)
	{
		clr.R = btoning ? 0.f : 1.f;
		matInst.SetVectorParameterValue('Hue', clr);
	}
}

exec function showMode()
{		
	`ScreenMessage("VM -"@ViewMode);	
}

/************************************************/
/*          Завершение он-лайн сессии           */
/************************************************/

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
	if(WorldInfo.NetMode == NM_ListenServer)
		ConsoleCommand("Disconnect");
	else
		ConsoleCommand("Exit");
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

exec function ShowGameMenu()
{
	if (WorldInfo.NetMode == NM_ListenServer)
	{
		if (!bMenuIsFirstTime) showMenu();
	}
}

reliable server function showMenu()
{
	local Forsage_HUD FH;
	FH = Forsage_HUD(myHUD);

	if (FH != none && FH.menu != none)
	{		
		FH.menu.Show(!FH.menu.bMovieIsOpen);			
	}
}

function string ConsoleCommand(string Command, optional bool bWriteToLog = true)
{	
	local Forsage_HUD fh;		
	if (Command ~= "exit" || Command ~= "quit")	{	
		fh = Forsage_HUD(myHUD);
		if (fh != none && fh.menu != none)
			fh.menu.Save();
		
		if (Role == Role_Authority)
		{
			// finalize forsage signals
			Forsage_PlayerCar(Pawn).cleanSignals();							
		}
	}
	return super.ConsoleCommand(Command);
}

DefaultProperties
{	
	bMenuIsFirstTime = true	
}