class Kamaz_HUD_GameMenu extends Kamaz_GFxMoviePlayer;
/** Ссылка на главное меню */
var Kamaz_HUD KamazHUD;
/** Кнопка "Назад" */
var GFxClikWidget btnBack;
var GFxClikWidget exitGameButton;
var GFxClikWidget restartGameBtn;
var GFxClikWidget cursor;
var bool bIsClosed;
/** strings from ini-file */
var config string strExitGameButton;
var config string strRestartGameBtn;

function bool Start(optional bool StartPaused = false) 
{
	super.Start(StartPaused);
	if(KamazHUD.objPC!= none)
		KamazHUD.objPC.IgnoreLookInput(true);

	bIsClosed = false;
	Advance(0);

	if(!KamazHUD.objPC.WorldInfo.bPlayersOnly )
			KamazHUD.objPC.ConsoleCommand("Playersonly");

	return true;
}

event bool WidgetInitialized (name WidgetName, name WidgetPath, GFxObject Widget) 
{
	// Добавляем обработчиики контролам 
	switch(WidgetName)
	{
		case('continueGameBtn'):
			btnBack = GFxClikWidget(Widget);			
			btnBack.AddEventListener('CLIK_click', OnBackButtonClick);
			btnBack.SetString("label", strBackBtn);
			btnBack.SetBool("focused", true);
			break;
		case('exitGameBtn'):
			exitGameButton = GFxClikWidget(Widget);
			exitGameButton.AddEventListener('CLIK_click', OnExitGameButtonClick);
			exitGameButton.SetString("label", strExitGameButton);
			break;
		case('RestartGameBtn'):
			restartGameBtn = GFxClikWidget(Widget);
			restartGameBtn.AddEventListener('CLIK_click', OnRestartGameButtonClick);
			restartGameBtn.SetString("label", strRestartGameBtn);
		case('cursor'):
			cursor = GFxClikWidget(Widget);
		default:
			break;
	}

	return true;
}
/** Проверка на наличие UI текстов в ini-файле */
function checkConfig()
{
	// отличие названия кнопки 'Back' от стандартного названия
	if (len(strBackBtn) == 0) {
		strBackBtn = "Продолжить";				
		bNeedToSave = true;		
	}	

	if (len(strExitGameButton) == 0) {
		strExitGameButton = "Выход";				
		bNeedToSave = true;		
	}	

	if (len(strRestartGameBtn) == 0) {
		strRestartGameBtn = "Начать сначала";				
		bNeedToSave = true;		
	}
}

function CloseFlash()
{
	if(KamazHUD.objPC.bCinematicMode)
		return;

	if(!bIsClosed)
	{
		bIsClosed= true;
		close(false);
		//HideElements();
		bCaptureInput = false;
	}
	else
	{
		bIsClosed= false;
		start(false);
		//ShowElements();
		bCaptureInput = true;
	}
}
/** Закрывает текущую флешку*/
function OnBackButtonClick(GFxClikWidget.EventData ev)
{
	if(KamazHUD.objPC!= none)
	{
		KamazHUD.objPC.IgnoreLookInput(false);
		KamazHUD.objPC.IgnoreMoveInput(false);
		if(KamazHUD.objPC.WorldInfo.bPlayersOnly )
			KamazHUD.objPC.ConsoleCommand("Playersonly");

	}
	CloseFlash();

	KamazHUD.MousePos_StartRenderToTexture();
}
function OnExitGameButtonClick(GFxClikWidget.EventData ev)
{
`log("OnExitGameButtonClick");

	if (KamazHUD!=none)
    {
		if(KamazHUD.objPC!= none)
		{
			KamazHUD.objPC.IgnoreLookInput(true);
			KamazHUD.objPC.IgnoreMoveInput(true);
		}
		//возмаожно, тут должен быть дисконнект
		KamazHUD.objPC.CMapState.GoToMenu();
		KamazHUD.MousePos_StopRenderToTexture();
		KamazHUD.bIsMenuOpened = true;

		CloseFlash();	
		
		KamazHUD.ShowAndPlayMainMenu();
    }
}
function OnRestartGameButtonClick(GFxClikWidget.EventData ev)
{
    if (KamazHUD!=none)
    {
		KamazHUD.objPC.bIsMenu = false;
		KamazHUD.objPC.IgnoreLookInput(false);
		KamazHUD.objPC.IgnoreMoveInput(false);
		KamazHUD.objPC.CMapState.ReturnMapsObjectsToInitState();
		KamazHUD.objPC.createQuestObj(string(KamazHUD.objPC.Quest.Name ) , KamazHUD.objPC.Quest.Class.name);
		KamazHUD.bIsMenuOpened = false;
		
		if(KamazHUD.objPC.WorldInfo.bPlayersOnly )
			KamazHUD.objPC.ConsoleCommand("Playersonly");
		CloseFlash();
	}
}
function HideElements()
{
	 btnBack.SetBool("visible",false);
	 exitGameButton.SetBool("visible",false);
	 restartGameBtn.SetBool("visible",false);
	 cursorHide();
}
function showElements()
{
	bIsClosed = false;
	btnBack.SetBool("visible",true);
	exitGameButton.SetBool("visible",true);
	restartGameBtn.SetBool("visible",true);
	ActionScriptVoid("ShowCursor");
}
function cursorHide()
{
	ActionScriptVoid("HideCursor");
}
DefaultProperties
{

	bCaptureInput = true;
	WidgetBindings.Add((WidgetName="continueGameBtn", WidgetClass=class'GFxClikWidget'));
	WidgetBindings.Add((WidgetName="exitGameBtn", WidgetClass=class'GFxClikWidget'));
	WidgetBindings.Add((WidgetName="RestartGameBtn", WidgetClass=class'GFxClikWidget'));
	WidgetBindings.Add((WidgetName="cursor", WidgetClass=class'GFxClikWidget'));
	MovieInfo=SwfMovie'menu.GameMenu.GameMenu'
}
