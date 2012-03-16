class Kamaz_HUD_FreeDrivingMenu extends Kamaz_GFxMoviePlayer;
/** Ссылка на главное меню */
var Kamaz_HUD KamazHUD;
/** Кнопка "Назад" */
var GFxClikWidget btnBack;
var GFxClikWidget freeDriveSelectBtn;
var GFxClikWidget freeDriveDescription;
var Quest_Custom Quest;
// strings from ini-file
var config string strFreeDriveSelectBtn;
var config string strFreeDriveDescription;
var config string strFreeDriveMenuTitle;

function bool Start(optional bool StartPaused = false) 
{
	super.Start(StartPaused);
	Advance(0);
	return true;
}

event bool WidgetInitialized (name WidgetName, name WidgetPath, GFxObject Widget) 
{
	// Добавляем обработчиики контролам 
	switch(WidgetName)
	{
		case('freeDriveBackBtn'):
			btnBack = GFxClikWidget(Widget);
			btnBack.AddEventListener('CLIK_click', OnBackButtonClick);
			btnBack.SetString("label", strBackBtn);
			break;
		case('freeDriveSelectBtn'):
			freeDriveSelectBtn = GFxClikWidget(Widget);
			freeDriveSelectBtn.AddEventListener('CLIK_click', OnFreeDriveSelectButtonClick);
			freeDriveSelectBtn.SetString("label", strFreeDriveSelectBtn);
			freeDriveSelectBtn.SetBool("focused",true);
			break;
		case('freeDriveDescription'):
			freeDriveDescription = GFxClikWidget(Widget);
			freeDriveDescription.SetText(strFreeDriveDescription);			
			break;
		case('freeDriveMenuTitle'):
			widget.SetText(strFreeDriveMenuTitle);
		default:
			break;
	}

	return true;
}

/** Закрывает текущую флешку */
function OnBackButtonClick(GFxClikWidget.EventData ev)
{
	goBack();
}

/** Свободное вождение */
function OnFreeDriveSelectButtonClick(GFxClikWidget.EventData ev)
{
	local Kamaz_PlayerController PC;
	local Kamaz_HUD gHud;
	nextMovieClass = none;
	PC = Kamaz_PlayerController( GetPC());
	if(PC==none)
		return;
	gHUd = Kamaz_HUD(PC.myHUD);
	if (PC.SaveSystem.Profile != none)
	{
		PC.bIsMenu = false;
		PC.IgnoreLookInput(false);
		PC.IgnoreMoveInput(false);
		if(PC.WorldInfo.bPlayersOnly )
			PC.ConsoleCommand("Playersonly");

		PC.createQuestObj("Quest_Custom_0",'Quest_Custom');
		gHud.GetAndShowMinimap();
		//KamazHUD.CloseMainMenu();
		//KamazHUD.gfxFreeDrivingMenu = none;
		gHud.bIsMenuOpened = false;
		Close(false);
	}
	
	//KamazHUD.CloseAllMenus();
	//ConsoleCommand("open City");
}

/** Проверка на наличие UI текстов в ini-файле */
function checkConfig()
{
	super.checkConfig();
	if (len(strFreeDriveSelectBtn) == 0) {
		strFreeDriveSelectBtn = "Выбрать";				
		bNeedToSave = true;		
	}	

	if (len(strFreeDriveDescription) == 0) {
		strFreeDriveDescription = "Свободная поездка по городу в автомобильном потоке без пункта назначения. Отличное место для проверки навыков вождения автомобилем вне тренировочной площадки. Будьте аккуратны, соблюдайте правила дорожного движения.";
		bNeedToSave = true;		
	}		

	if (len(strFreeDriveMenuTitle) == 0) {
		strFreeDriveMenuTitle = "Свободная поездка";				
		bNeedToSave = true;		
	}				
}

DefaultProperties
{
	bCaptureInput = true;
	WidgetBindings.Add((WidgetName="freeDriveBackBtn", WidgetClass=class'GFxClikWidget'));
	WidgetBindings.Add((WidgetName="freeDriveSelectBtn", WidgetClass=class'GFxClikWidget'));
	WidgetBindings.Add((WidgetName="freeDriveDescription", WidgetClass=class'GFxClikWidget'));

	MovieInfo=SwfMovie'menu.FreeDrivingMenu.FreeDriving'
}
