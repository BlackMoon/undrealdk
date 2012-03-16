class Kamaz_HUD_drvScreen extends Kamaz_GFxMoviePlayer;

var Kamaz_GFxClikWidget trainingBtn;
var Kamaz_GFxClikWidget	freeDriveBtn;
var Kamaz_GFxClikWidget examBtn;
var Kamaz_GFxClikWidget drvBackBtn;
var Kamaz_GFxClikWidget questBtn;
var Kamaz_GFxClikWidget itemDescription;

var Kamaz_HUD GorodHUD;
/** strings from ini-file */
var config string strTrainingBtn;
var config string strExamBtn;
var config string strQuestBtn;
var config string strDrvMenuTitle;
var config string strDrvDescription;
var config string strFreeDriveBtn;

/******************************************************************/
/** Описания кнопок */
var config string trainingDesription;
var config string freeDriveDesription;
var config string examDesription;
var config string questDesription;
var config string drvBackDesription;

var config string currDesription;

/******************************************************************/

//////////ссылки на дочерние флешки
/** Ссылка на MoviePlayer с обучением вождения */
var Kamaz_HUD_TrainingMenu gfxTrainingMenu;

/** Ссылка на MoviePlayer с экзаменом вождения */
var Kamaz_HUD_ExamMenu gfxExamMenu;

/** Ссылка на MoviePlayer со свободным вождением */
var Kamaz_HUD_FreeDrivingMenu gfxFreeDrivingMenu;

///////////////////////////////////
var Quest_Custom Quest;

event bool WidgetInitialized (name WidgetName, name WidgetPath, GFxObject Widget) 
{
	switch (WidgetName) 
	{
		case ('trainingBtn'):
			trainingBtn = Kamaz_GFxClikWidget(Widget);
			trainingBtn.AddEventListener('CLIK_click', OntrainingBtn);


			trainingBtn.AddEventListener('CLIK_rollOver', OntrainingBtnRollOver);
			trainingBtn.AddEventListener('CLIK_rollOut', SetDefaultText);

			trainingBtn.SetString("label", strTrainingBtn);
			break;
		case ('freeDriveBtn'):
			freeDriveBtn = Kamaz_GFxClikWidget(Widget);
			freeDriveBtn.AddEventListener('CLIK_click', OnfreeDriveBtn);

			freeDriveBtn.AddEventListener('CLIK_rollOver', OnfreeDriveBtnRollOver);
			freeDriveBtn.AddEventListener('CLIK_rollOut', SetDefaultText);

			freeDriveBtn.SetString("label", strFreeDriveBtn);
			break;
		case('examBtn'):
			examBtn = Kamaz_GFxClikWidget(Widget);
			examBtn.AddEventListener('CLIK_click', OnexamBtn);

			examBtn.AddEventListener('CLIK_rollOver', OnexamBtnRollOver);
			examBtn.AddEventListener('CLIK_rollOut', SetDefaultText);

			//////////////////////////раскомментируй меня////////////////////////////////
			examBtn.SetBool("disabled",true);
			/////////////////////////////////////////////////////////////////////////////
			examBtn.SetString("label", strExamBtn);
			break;		
		case('questBtn'):
			questBtn = Kamaz_GFxClikWidget(Widget);
			questBtn.AddEventListener('CLIK_click', OnQuestBtn);

			questBtn.AddEventListener('CLIK_rollOver', OnquestBtnRollOver);
			questBtn.AddEventListener('CLIK_rollOut', SetDefaultText);

			questBtn.SetString("label", strQuestBtn);
			break;
		case ('drvBackBtn'):
			drvBackBtn = Kamaz_GFxClikWidget(Widget);
			drvBackBtn.AddEventListener('CLIK_click', OndrvBackBtn);


			drvBackBtn.AddEventListener('CLIK_rollOver', OndrvBackBtnRollOver);
			drvBackBtn.AddEventListener('CLIK_rollOut', SetDefaultText);

			drvBackBtn.SetString("label", strBackBtn);
			break;
		case ('itemDescription'):
			itemDescription = Kamaz_GFxClikWidget(Widget);
			break;
		case ('DrvMenuTitle'):
			widget.SetText(strDrvMenuTitle);
			break;
		default:
			break;
	}

	return true;
}
///** обработчики кнопок *///

///////////////начать квест
function OnQuestBtn(GFxClikWidget.EventData ev)
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

		PC.createQuestObj("Quest_Mission_0",'Quest_Mission');
		gHUd.GetAndShowMinimap();
		//GorodHUD.CloseMainMenu();
//		GorodHUD.gfxdrvScreen = none;
		gHUd.bIsMenuOpened = false;
		Close(false);
	}
	else
	{
		`Warn("Profile not loaded");
	}
}

function OntrainingBtn(GFxClikWidget.EventData ev)
{
	nextMovieClass = class'Kamaz_HUD_TrainingMenu';
	Close(false);
}

function OnfreeDriveBtn(GFxClikWidget.EventData ev)
{
	nextMovieClass = class'Kamaz_HUD_FreeDrivingMenu';
	Close(false);

}

function OnexamBtn(GFxClikWidget.EventData ev)
{
	nextMovieClass = class'Kamaz_HUD_ExamMenu';
	Close(false);

	
}
function OndrvBackBtn(GFxClikWidget.EventData ev)
{
	goBack();
}

event PostWidgetInit()
{
	super.PostWidgetInit();
	AddTabWidget(trainingBtn); 
	AddTabWidget(freeDriveBtn); 
	AddTabWidget(examBtn);
	AddTabWidget(drvBackBtn);
	AddTabWidget(questBtn);

	//if(trainingBtn!=none)
	//	trainingBtn.SetBool("focused",true);

	itemDescription.SetBool("editable",false);
	itemDescription.SetText(currDesription);

}

/** Проверка на наличие UI текстов в ini-файле */
function checkConfig()
{
	super.checkConfig();
	if (len(strTrainingBtn) == 0) {
		strTrainingBtn = "Обучение";				
		bNeedToSave = true;		
	}	

	if (len(strExamBtn) == 0) {
		strExamBtn = "Экзамен";				
		bNeedToSave = true;		
	}		

	if (len(strQuestBtn) == 0) {
		strQuestBtn = "Задание";				
		bNeedToSave = true;		
	}			

	if (len(strFreeDriveBtn) == 0) {
		strfreeDriveBtn = "Свободная езда по городу";
		bNeedToSave = true;
	}
	
	if (len(strDrvMenuTitle) == 0) {
		strDrvMenuTitle = "Вождение";
		bNeedToSave = true;
	}
	
	if (len(strDrvDescription) == 0) {
		strDrvDescription = "Выберите тип вождения";
		bNeedToSave = true;
	}

	if (len(trainingDesription) == 0) {
		trainingDesription = "Обучение выполнению упражнений на автодроме. Будьте аккуратны и внимательны. Следуйте подсказкам, появляющимся на экране";
		bNeedToSave = true;
	}	
	if (len(freeDriveDesription) == 0) {
		freeDriveDesription = "Свободная поездка по городу в автомобильном потоке без пункта назначения ";
		bNeedToSave = true;
	}	
	if (len(examDesription) == 0) {
		examDesription = "Сдача экзамена";
		bNeedToSave = true;
	}
	if (len(questDesription) == 0) {
		questDesription = "Выезд на задание по тушению пожара. Необходимо добраться до горящего здания следуя подсказкам, появляющимся по мере прохождения";
		bNeedToSave = true;
	}
	if (len(drvBackDesription) == 0) {
		drvBackDesription = "Вернуться в предыдущее меню";
		bNeedToSave = true;
	}
	if(len(currDesription)==0){
		currDesription="Вы находитесь в меню вождения в одиночном режиме. Выберите тип вождения.";
		bNeedToSave = true;	
	}
	 
}
////////////////////////наведение мыши
function OntrainingBtnRollOver(GFxClikWidget.EventData ev)
{
	itemDescription.SetText(trainingDesription);
}
function OnfreeDriveBtnRollOver(GFxClikWidget.EventData ev)
{
	itemDescription.SetText(freeDriveDesription);
}
function OnexamBtnRollOver(GFxClikWidget.EventData ev)
{
	itemDescription.SetText(examDesription);
}
function OnquestBtnRollOver(GFxClikWidget.EventData ev)
{
	itemDescription.SetText(questDesription);
}
function OndrvBackBtnRollOver(GFxClikWidget.EventData ev)
{
	itemDescription.SetText(drvBackDesription);
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
	case class'Kamaz_HUD_TrainingMenu':
		if(gfxTrainingMenu==none)
		{
			gfxTrainingMenu = new class'Kamaz_HUD_TrainingMenu';
			gfxTrainingMenu.ownerMovie = self;
			gfxTrainingMenu.checkConfig();
			gfxTrainingMenu.Init();			
		}
		else
		{
			gfxTrainingMenu.Start(false);
		}
		break;
	case class'Kamaz_HUD_ExamMenu':
		if(gfxExamMenu==none)
		{
			gfxExamMenu = new class'Kamaz_HUD_ExamMenu';
			gfxExamMenu.ownerMovie = self;
			gfxExamMenu.checkConfig();
			gfxExamMenu.Init();			
		}
		else
		{
			gfxExamMenu.Start(false);
		}

		break;
	case class'Kamaz_HUD_FreeDrivingMenu':
		if(gfxFreeDrivingMenu==none)
		{
			gfxFreeDrivingMenu = new class'Kamaz_HUD_FreeDrivingMenu';
			gfxFreeDrivingMenu.ownerMovie = self;
			gfxFreeDrivingMenu.checkConfig();
			gfxFreeDrivingMenu.Init();			
		}
		else
		{
			gfxFreeDrivingMenu.Start(false);
		}
		break;
	default:
		break;

	}
}

DefaultProperties
{
	MovieInfo =SwfMovie'menu.drvScreen'
	WidgetBindings.Add((WidgetName="trainingBtn", WidgetClass=class'Kamaz_GFxClikWidget'))
	WidgetBindings.Add((WidgetName="freeDriveBtn", WidgetClass=class'Kamaz_GFxClikWidget'))
	WidgetBindings.Add((WidgetName="examBtn", WidgetClass=class'Kamaz_GFxClikWidget'))
	WidgetBindings.Add((WidgetName="drvBackBtn", WidgetClass=class'Kamaz_GFxClikWidget'))
	WidgetBindings.Add((WidgetName="questBtn", WidgetClass=class'Kamaz_GFxClikWidget'))
	WidgetBindings.Add((WidgetName="drvDescription", WidgetClass=class'Kamaz_GFxClikWidget'))
	WidgetBindings.Add((WidgetName="itemDescription", WidgetClass=class'Kamaz_GFxClikWidget'))


}
