class Kamaz_HUD_TrainingMenu extends Kamaz_GFxMoviePlayer dependson (Quest_Custom);
/** Ссылка на главное меню */
var Kamaz_HUD GorodHUD;

/** Кнопка "Назад" */
var GFxClikWidget btnBack;
/** Список заданий */
var GFxClikWidget trainingList;
var int curentIndex;
/** Описание */
var GFxClikWidget trainingDescription;

/** Выбрать */
var GFxClikWidget traningSelectBtn;
var array <Quest_Custom> Quests;
var bool firstTime;
/** strings from ini-file */
var config string strTraningSelectBtn;
var config string strTraningMenuTitle;

function bool Start(optional bool StartPaused = false) 
{
	super.Start(StartPaused);
	Advance(0);
	return true;
}

event bool WidgetInitialized (name WidgetName, name WidgetPath, GFxObject Widget) 
{
	local ASValue val;
	val.n = 0;
	val.Type = AS_Number;

	// Добавляем обработчиики контролам 
	switch(WidgetName)
	{
		case('trainingBackBtn'):
			btnBack = GFxClikWidget(Widget);
			btnBack.AddEventListener('CLIK_click', OnBackButtonClick);
			btnBack.SetString("label", strBackBtn);
			break;
		case('trainingDescription'):
			trainingDescription = GFxClikWidget(Widget);			
			break;
		case('trainingList'):
			trainingList = GFxClikWidget(Widget);
			trainingList.AddEventListener('CLIK_itemClick', OnListItemClick);
			//выбираем первый элемент в списке
			trainingList.Set("selectedIndex", val);
			RefreshProfilesList();
			break;
		case('traningSelectBtn'):
			traningSelectBtn = GFxClikWidget(Widget);
			traningSelectBtn.AddEventListener('CLIK_click', OnTraningSelectButtonClick);
			traningSelectBtn.SetString("label", strTraningSelectBtn);	
			break;
		case('traningMenuTitle'):
			widget.SetText(strTraningMenuTitle);
			break;
		default:
			break;
	}
	return true;
}

event PostWidgetInit()
{
	local Quest_custom quest;
	local string descr;

	if (Quests.Length > 0)
	{
		quest = Quests[0];          // возможно отсутствие заголовка
		if (len(quest.QuestTitle) != 0) descr = quest.questTitle$"\n";
		descr @= quest.questDescription;

		trainingDescription.SetText (descr);
		trainingDescription.SetBool("focused", true);   // for scroll enabling	
		traningSelectBtn.SetBool("focused", true);
		trainingDescription.SetText (descr);		
	}
	firstTime = true;
}


function RefreshProfilesList()
{
	local int i, idx;
	local GFxObject DataProvider;
	local GFxObject TempObj;

	local array<string> strQuests;
	local string quest;

	`Entry();
	DataProvider = CreateArray();
	GetPerObjectConfigSections(class'Quest_Autodrom', strQuests);
    
	if(traningSelectBtn!=none)
	{
		foreach strQuests(quest, i)
		{
			idx = InStr(quest, " ");
			quest = Left (quest, idx);
			
			Quests.AddItem (new(none, quest) class'Quest_Autodrom');

			TempObj =  CreateObject("Object");
			TempObj.SetString("label", Quests[i].questName);
			DataProvider.SetElementObject(i,TempObj);
		}

		trainingList.SetObject("dataProvider", DataProvider);
	}
	else
	{
		`warn("InitializeProfilesList , listProf=none");
	}
	`exit();
}

function OnListItemClick(GFxClikWidget.EventData ev)
{
	local Quest_custom quest;
	local string descr;
	
	firstTime = false;
	curentIndex = ev.index;

	if (curentIndex > -1 && curentIndex < Quests.Length)
	{
		quest = Quests[curentIndex];        // возможно отсутствие заголовка
		if (len(quest.QuestTitle) != 0) descr = quest.questTitle@"\n";
		descr @= quest.questDescription;

		trainingDescription.SetText (descr);
		traningSelectBtn.SetBool("disabled",false);
	}
	else
	{
		trainingDescription.SetText ("Выберите упражнение");
		if(traningSelectBtn!=none)
			traningSelectBtn.SetBool("disabled",true);
	}
	Advance(0);	
}


/** Закрывает текущую флешку*/
function OnBackButtonClick(GFxClikWidget.EventData ev)
{
	goBack();
}

/** Выбрать */
function OnTraningSelectButtonClick(GFxClikWidget.EventData ev)
{
	local int index;
	local Kamaz_PlayerController PC;
	local Kamaz_HUD gHud;
	nextMovieClass = none;
	PC = Kamaz_PlayerController( GetPC());
	if(PC==none)
		return;
	gHUd = Kamaz_HUD(PC.myHUD);

	if(gHUd != none && PC != none)
	{
		if (firstTime) index = 0;
		else if (curentIndex > -1);

		PC.bIsMenu = false;

		PC.IgnoreLookInput(false);
		PC.IgnoreMoveInput(false);
		if(PC.WorldInfo.bPlayersOnly )
			PC.ConsoleCommand("Playersonly");

		PC.createQuestObj(string(Quests[index].Name),'Quest_Autodrom');
		gHud.GetAndShowMinimap();
		//GorodHUD.gfxTrainingMenu = none;
		//GorodHUD.CloseMainMenu();
		//закрываем совсем, чтобы не пришлось тыкать два раза

		gHud.bIsMenuOpened = false;
		Close(false);
	}	
}

/** Проверка на наличие UI текстов в ini-файле */
function checkConfig()
{	
	super.checkConfig();
	if (len(strTraningSelectBtn) == 0) {
		strTraningSelectBtn = "Выбрать";				
		bNeedToSave = true;		
	}	
	
	if (len(strTraningMenuTitle) == 0) {
		strTraningMenuTitle = "Обучение";				
		bNeedToSave = true;		
	}				
}

DefaultProperties
{
	curentIndex = -1;	
	bCaptureInput = true;
	MovieInfo=SwfMovie'menu.TrainingMenu.Training'
	WidgetBindings.Add((WidgetName="trainingBackBtn", WidgetClass=class'GFxClikWidget'));

	WidgetBindings.Add((WidgetName="trainingList", WidgetClass=class'GFxClikWidget'));
	WidgetBindings.Add((WidgetName="trainingDescription", WidgetClass=class'GFxClikWidget'));
	WidgetBindings.Add((WidgetName="traningSelectBtn", WidgetClass=class'GFxClikWidget'));

}
