class Kamaz_HUD_MainMenu extends Kamaz_GFxMoviePlayer;
// здесь определены необходимые константы
`include(Kamaz_OnlineConstants.uci)

var Kamaz_GFxClikWidget ProfilesButton;
var Kamaz_GFxClikWidget ExercisesButton;
var Kamaz_GFxClikWidget driveBtn;
var Kamaz_GFxClikWidget ListPddTestButton;
var Kamaz_GFxClikWidget settingsBtn;
var Kamaz_GFxClikWidget ExitButton;
var Kamaz_GFxClikWidget itemDescription;

var GFxObject MainMenuTitle;

var bool bPauseMenu;

var Kamaz_HUD KamazHUD;
/** strings from ini-file */
var config string strProfilesButton;
var config string strListPddTestButton;
var config string strExitButton;
var config string strExercisesButton;
var config string strdriveBtn;
var config string strsettingsBtn;
/******************************************************************/

/** Описания кнопок */
var config string ProfilesItemDesription;
var config string ExercisesButtonDesription;
var config string driveBtnDesription;
var config string ListPddTestButtonDesription;
var config string settingsBtnDesription;
var config string ExitButtonDesription;

var config string currDesription;
/******************************************************************/

//////////ссылки на дочерние флешки

/** Ссылка на MoviePlayer со списком профилей */
var Kamaz_HUD_ProfilesMenu gfxProfilesMenu;

/** Ссылка на MoviePlayer со списком упражнений */
var Kamaz_ExerciseList gfxExerciseList;

/** Одиночное вождение и вождение по сети */
var Kamaz_HUD_NetAndLocalScreen gfxNetAndLocalScreen;

/** Ссылка на MoviePlayer с текстовым экзаменом ПДД */
var Kamaz_HUD_ListPDDTestMenu gfxListPDDTestMenu;

/** Меню настроек */
var Kamaz_HUD_ChoiceSettings gfxChoiceSettingsScreen;

////////////////////////////////////


function bool Start(optional bool StartPaused = false) 
{
	if(super.Start(StartPaused))
	{
		Advance(0);
		MainMenuTitle = GetVariableObject("profilesBtn.textField");
		if(KamazHUD.objPC!=none)
		{
			KamazHUD.objPC.IgnoreLookInput(true);
			KamazHUD.objPC.IgnoreMoveInput(true);
		}
	}
	return true;

}

event bool WidgetInitialized (name WidgetName, name WidgetPath, GFxObject Widget) 
{
	switch (WidgetName) 
	{
		///// профили
		case ('profilesBtn'):
			ProfilesButton = Kamaz_GFxClikWidget(Widget);
			ProfilesButton.AddEventListener('CLIK_click', OnProfilesButtonClick);

			ProfilesButton.AddEventListener('CLIK_rollOver', OnProfilesButtonRollOver);
			ProfilesButton.AddEventListener('CLIK_rollOut', SetDefaultText);

			ProfilesButton.SetString("label", strProfilesButton);
			break;						
		case ('textTestBtn'):
			ListPddTestButton = Kamaz_GFxClikWidget(Widget);
			ListPddTestButton.AddEventListener('CLIK_click', OnListPddTestButtonButtonClick);

			ListPddTestButton.AddEventListener('CLIK_rollOver',OntextTestBtnRollOver);
			ListPddTestButton.AddEventListener('CLIK_rollOut',SetDefaultText);

			//////////////////////////закомментируй меня////////////////////////////////   
			ListPddTestButton.SetBool("disabled",true);
			/////////////////////////////////////////////////////////////////////////////
			ListPddTestButton.SetString("label", strListPddTestButton);	
			break;			
		case ('exitMainBtn'):
			ExitButton = Kamaz_GFxClikWidget(Widget);
			ExitButton.AddEventListener('CLIK_click', OnExitButtonClick);

			ExitButton.AddEventListener('CLIK_rollOver', OnExitButtonRollOver);
			ExitButton.AddEventListener('CLIK_rollOut', SetDefaultText);

			ExitButton.SetString("label", strExitButton);
			break;		
		case ('exercisesBtn'):
			ExercisesButton = Kamaz_GFxClikWidget(Widget);
			ExercisesButton.AddEventListener('CLIK_click', OnExercisesButtonClick);

			ExercisesButton.AddEventListener('CLIK_rollOver', OnExercisesButtonRollOver);
			ExercisesButton.AddEventListener('CLIK_rollOut', SetDefaultText);

			ExercisesButton.SetString("label", strExercisesButton);
			break;
		case('driveBtn'):
			driveBtn = Kamaz_GFxClikWidget(Widget);
			driveBtn.AddEventListener('CLIK_click', OndriveBtn);

			driveBtn.AddEventListener('CLIK_rollOver', OndriveBtnRollOver);
			driveBtn.AddEventListener('CLIK_rollOut', SetDefaultText);

			driveBtn.SetString("label", strdriveBtn);
			break;
		case('settingsBtn'):
			settingsBtn = Kamaz_GFxClikWidget(Widget);
			settingsBtn.AddEventListener('CLIK_click', OnsettingsBtn);

			settingsBtn.AddEventListener('CLIK_rollOver', OnSettingsBtnRollOver);
			settingsBtn.AddEventListener('CLIK_rollOut', SetDefaultText);

			settingsBtn.SetString("label", strsettingsBtn);
			break;		
		case('itemDescription'):
			itemDescription = Kamaz_GFxClikWidget(Widget);
			break;
		default:
			break;
	}
	return true;
}

/** Проверка на наличие UI текстов в ini-файле */
function checkConfig()
{	
	if (len(strProfilesButton) == 0) {
		strProfilesButton = "Профиль";				
		bNeedToSave = true;		
	}	

	if (len(strListPddTestButton) == 0) {
		strListPddTestButton = "ПДД";				
		bNeedToSave = true;		
	}

	if (len(strExitButton) == 0) {
		strExitButton = "Выход";				
		bNeedToSave = true;		
	}

	if (len(strExercisesButton) == 0) {
		strExercisesButton = "Навыки управления автомобилем";				
		bNeedToSave = true;		
	}	

	if (len(strdriveBtn) == 0) {
		strdriveBtn = "Вождение";				
		bNeedToSave = true;		
	}

	if (len(strsettingsBtn) == 0) {
		strsettingsBtn = "Настройки";				
		bNeedToSave = true;		
	}
	if(len(ProfilesItemDesription)==0){
		ProfilesItemDesription ="Меню профилей.    Создание, добавление, удаление, статистика ";
		bNeedToSave = true;		
	}
	if(len(ExercisesButtonDesription)==0){
		ExercisesButtonDesription="Список упражнений. Отработка навыков связанных с различными органами управления автомобиля";
		bNeedToSave = true;		
	}
	if(len(driveBtnDesription)==0){
		driveBtnDesription="Вождение автомобилем. Обучение и проверка навыка вождения ТС";
		bNeedToSave = true;		
	}
	if(len(ListPddTestButtonDesription)==0){
		ListPddTestButtonDesription="Текстовые тесты по ПДД. Входят экзаменционные билеты";
		bNeedToSave = true;		
	}
	if(len(settingsBtnDesription)==0){
		settingsBtnDesription="Настройки видео и тренажера";
		bNeedToSave = true;		
	}
	if(len(ExitButtonDesription)==0){
		ExitButtonDesription="Выход из приложения";
		bNeedToSave = true;		
	}
	if(len(currDesription)==0){
		currDesription="Вы находитесь на главном меню приложения. Чтобы продолжить работу выберите один из пунктов меню. Чтобы выйти из приложения нажмите кнопку Выход";
		bNeedToSave = true;	
	}

}

event PostWidgetInit()
{
	super.PostWidgetInit();
	AddTabWidget(ProfilesButton); 
	AddTabWidget(ExercisesButton); 
	AddTabWidget(driveBtn);
	AddTabWidget(ListPddTestButton);
	AddTabWidget(settingsBtn);
	AddTabWidget(ExitButton);
	//нельзя редактировать
	itemDescription.SetBool("editable",false);
	itemDescription.SetText(currDesription);

}
/************************************************/
/*          Обработчики нажатия кнопок          */
/************************************************/

//профили
function OnProfilesButtonClick(GFxClikWidget.EventData ev)
{
	nextMovieClass = class'Kamaz_HUD_ProfilesMenu';
	Close(false);
}
//упражнения
function OnExercisesButtonClick(GFxClikWidget.EventData ev)
{
	nextMovieClass = none;
	KamazHUD.ShowExerciseList();
}

//вождение
function OndriveBtn(GFxClikWidget.EventData ev)
{
	nextMovieClass = class'Kamaz_HUD_NetAndLocalScreen';
	Close(false);
}
//текстовые упражнения
function OnListPddTestButtonButtonClick(GFxClikWidget.EventData ev)
{
	nextMovieClass = class'Kamaz_HUD_ListPDDTestMenu';
	Close(false);
}
//настройки
function OnsettingsBtn(GFxClikWidget.EventData ev)
{
	nextMovieClass = class'Kamaz_HUD_ChoiceSettings';
	Close(false);
}

// Выход 
function OnExitButtonClick(GFxClikWidget.EventData ev)  
{
	local Kamaz_PlayerController gpc;
	gpc = Kamaz_PlayerController(GetPC());
	if(gpc  != None )
	{
		gpc.ConsoleCommand("quit");
	}
}
//////////////////////наведение мыши
function OnProfilesButtonRollOver(GFxClikWidget.EventData ev)
{
	itemDescription.SetText(ProfilesItemDesription);
}
function OntextTestBtnRollOver(GFxClikWidget.EventData ev)
{
	itemDescription.SetText(ListPddTestButtonDesription);
}

function OnExitButtonRollOver(GFxClikWidget.EventData ev)
{
	itemDescription.SetText(ExitButtonDesription);
}
function OnExercisesButtonRollOver(GFxClikWidget.EventData ev)
{
	itemDescription.SetText(ExercisesButtonDesription);

}
function OndriveBtnRollOver(GFxClikWidget.EventData ev)
{
	itemDescription.SetText(driveBtnDesription);
}

function OnSettingsBtnRollOver(GFxClikWidget.EventData ev)
{
	itemDescription.SetText(settingsBtnDesription);
}

////////////////////////наведение мыши
//function OnProfilesButtonRollOut(GFxClikWidget.EventData ev)
//{

//}

//function OntextTestBtnRollOut(GFxClikWidget.EventData ev)
//{
//}

//function OnExitButtonRollOut(GFxClikWidget.EventData ev)
//{
//}
//function OnExercisesButtonRollOut(GFxClikWidget.EventData ev)
//{
//}

//function OndriveBtnRollOut(GFxClikWidget.EventData ev)
//{
//}
//function OnSettingsBtnRollOut(GFxClikWidget.EventData ev)
//{

//}

function ShowChoiseSettingsMenu()
{
	// закрываем главное меню
	//0if(gfxMainMenu != none && gfxMainMenu.bMovieIsOpen)
	// если обьект ещё не создан, создаём
	if(gfxChoiceSettingsScreen == none)
	{
		gfxChoiceSettingsScreen = new class'Kamaz_HUD_ChoiceSettings';
//		gfxChoiceSettingsScreen.GorodHUD = self;
	}
	Close(true);


	gfxChoiceSettingsScreen.Start();
}


function SetDefaultText(GFxClikWidget.EventData ev)
{
	itemDescription.SetText(currDesription);
}
function OnCleanup()
{
	super.OnCleanup();
	switch(nextMovieClass)
	{
	case class'Kamaz_HUD_ProfilesMenu':
		if(gfxProfilesMenu==none)
		{
			gfxProfilesMenu = new class'Kamaz_HUD_ProfilesMenu';
			gfxProfilesMenu.ownerMovie = self;
			gfxProfilesMenu.checkConfig();
			gfxProfilesMenu.Init();			
		}
		else
		{
			gfxProfilesMenu.Start(false);
		}
		break;
	case class'Kamaz_ExerciseList':
		if(gfxExerciseList==none)
		{
			gfxExerciseList = new class'Kamaz_ExerciseList';
			gfxExerciseList.ownerMovie = self;
			gfxExerciseList.checkConfig();
			gfxExerciseList.Init();			
		}
		else
		{
			gfxExerciseList.Start(false);
		}

		break;
	case class'Kamaz_HUD_NetAndLocalScreen':
		if(gfxNetAndLocalScreen==none)
		{
			gfxNetAndLocalScreen = new class'Kamaz_HUD_NetAndLocalScreen';
			gfxNetAndLocalScreen.ownerMovie = self;
			gfxNetAndLocalScreen.checkConfig();
			gfxNetAndLocalScreen.Init();			
		}
		else
		{
			gfxNetAndLocalScreen.Start(false);
		}
		break;
	case class'Kamaz_HUD_ListPDDTestMenu':
		if(gfxListPDDTestMenu==none)
		{
			gfxListPDDTestMenu = new class'Kamaz_HUD_ListPDDTestMenu';
			gfxListPDDTestMenu.ownerMovie = self;
			gfxListPDDTestMenu.checkConfig();
			gfxListPDDTestMenu.Init();			
		}
		else
		{
			gfxNetAndLocalScreen.Start(false);
		}
		break;
	case class'Kamaz_HUD_ChoiceSettings':
		if(gfxListPDDTestMenu==none)
		{
			gfxChoiceSettingsScreen = new class'Kamaz_HUD_ChoiceSettings';
			gfxChoiceSettingsScreen.ownerMovie = self;
			gfxChoiceSettingsScreen.checkConfig();
			gfxChoiceSettingsScreen.Init();			
		}
		else
		{
			gfxChoiceSettingsScreen.Start(false);
		}

		break;
	default:
		break;

	}
}

DefaultProperties
{
	MovieInfo=SwfMovie'menu.MainMenu.MainMenu1'
	bCaptureInput = true;
	bPauseMenu = false;

	WidgetBindings.Add((WidgetName="profilesBtn", WidgetClass=class'Kamaz_GFxClikWidget'))
	WidgetBindings.Add((WidgetName="exercisesBtn", WidgetClass=class'Kamaz_GFxClikWidget'))
	WidgetBindings.Add((WidgetName="driveBtn", WidgetClass=class'Kamaz_GFxClikWidget'))
	WidgetBindings.Add((WidgetName="textTestBtn", WidgetClass=class'Kamaz_GFxClikWidget'))
	WidgetBindings.Add((WidgetName="settingsBtn", WidgetClass=class'Kamaz_GFxClikWidget'))
	WidgetBindings.Add((WidgetName="exitMainBtn", WidgetClass=class'Kamaz_GFxClikWidget'))	
	WidgetBindings.Add((WidgetName="itemDescription", WidgetClass=class'Kamaz_GFxClikWidget'))	

}
