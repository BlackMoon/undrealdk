/** Флешка с результатами */
class Kamaz_HUD_Results extends Kamaz_GFxMoviePlayer;

var Kamaz_GFxClikWidget btnOK;
var Kamaz_GFxClikWidget btnCancel;
var Kamaz_GFxClikWidget BtnBack;
var Kamaz_GFxClikWidget ResultsText;

var int CountPoints;
var int CountMoney;
var int CountErrors;
var int CountExercise;
var bool bIsSuccessReport;
var bool bShowExcersiseCount; // show/hide excersise count line in report
/** strings from ini-file */
var config string strBtnOK;
var config string strBtnCancel;

var config string strExcersises;
var config string strErrors;
var config string strPoints;

var config string strTrainingSuccess;
var	config string strTrainingUnsuccess;
var config string strTrainingQuestion;

var Kamaz_HUD KamazHUD;

function bool Start(optional bool StartPaused = false) 
{
	KamazHUD.MousePos_StopRenderToTexture();

	super.Start(StartPaused);
	if(KamazHUD.objPC!= none) KamazHUD.objPC.IgnoreLookInput(true);

	Advance(0);
	ConsoleCommand("Playersonly");
	return true;
}

event bool WidgetInitialized (name WidgetName, name WidgetPath, GFxObject Widget) 
{
	switch (WidgetName) 
	{
		case ('btnOK'):
			btnOK = Kamaz_GFxClikWidget(Widget);
			btnOK.AddEventListener('CLIK_click', OnOKClick);
			btnOK.SetString("label", strBtnOK);
			break;
		case ('btnCancel'):
			btnCancel = Kamaz_GFxClikWidget(Widget);
			btnCancel.AddEventListener('CLIK_click', OnCancelBtn);
			btnCancel.SetString("label", strBtnCancel);
			break;
		case('BtnBack'):
			BtnBack= Kamaz_GFxClikWidget(Widget);
			BtnBack.AddEventListener('CLIK_click', OnBackButtonClick);
			BtnBack.SetString("label", strBackBtn);			
			break;
		case ('ResultsText'):
			ResultsText = Kamaz_GFxClikWidget(Widget);
			break;
		default:
			break;
	}
	return true;
}

event PostWidgetInit()
{
	local string resultDescr;	
	super.PostWidgetInit();	
	
	resultDescr = bIsSuccessReport ? strTrainingSuccess : strTrainingUnsuccess;	
	resultDescr $= "\n";

	if (bShowExcersiseCount) 
		resultDescr $= "\n"$strExcersises@CountExercise@"/ 3";

	resultDescr $= "\n"$strErrors@CountErrors;
	resultDescr $= "\n"$strPoints@CountPoints;
	resultDescr $= "\n\n"$strTrainingQuestion;

	ResultsText.SetText(resultDescr);
	btnCancel.SetBool("focused", true);

	AddTabWidget(btnOK);
	AddTabWidget(btnCancel);
	AddTabWidget(BtnBack);	
}

function OnOKClick(GFxClikWidget.EventData ev)
{
	if (KamazHUD!=none)
    {
		KamazHUD.objPC.bIsMenu = false;
		KamazHUD.objPC.IgnoreLookInput(false);
		KamazHUD.objPC.IgnoreMoveInput(false);
		KamazHUD.objPC.CMapState.ReturnMapsObjectsToInitState();
		KamazHUD.objPC.createQuestObj(string(KamazHUD.objPC.Quest.Name ) , KamazHUD.objPC.Quest.Class.name);

		if(KamazHUD.objPC.WorldInfo.bPlayersOnly )
			KamazHUD.objPC.ConsoleCommand("Playersonly");

		KamazHUD.HUD_Results = none;
		Close(true);
		
	}
}

function OnCancelBtn(GFxClikWidget.EventData ev)
{
	if(KamazHUD.objPC.WorldInfo.bPlayersOnly )
		KamazHUD.objPC.ConsoleCommand("Playersonly");
	Close(true);
	KamazHUD.MousePos_StartRenderToTexture();
}
function OnBackButtonClick(GFxClikWidget.EventData ev)
{
	if (KamazHUD!=none)
    {

		if(KamazHUD.objPC!= none)
		{
			KamazHUD.objPC.IgnoreLookInput(true);
			KamazHUD.objPC.IgnoreMoveInput(true);
		}
		//возможно, тут должен быть дисконнект
		KamazHUD.objPC.CMapState.GoToMenu();
		KamazHUD.ShowAndPlayMainMenu();

		Close(true);
    }
}

/** Проверка на наличие UI текстов в ini-файле */
function checkConfig()
{		
	if (len(strBackBtn) == 0)
	{
		strBackBtn = "Выход";
		bNeedToSave = true;
	}

	if (len(strBtnCancel) == 0)
	{
		strBtnCancel = "Отмена";
		bNeedToSave = true;
	}

	if (len(strBtnOk) == 0)
	{
		strBtnOk = "OK";
		bNeedToSave = true;
	}

	if (len(strExcersises) == 0)
	{
		strExcersises = "Количество упражнений:";
		bNeedToSave = true;
	}	

	if (len(strErrors) == 0)
	{
		strErrors = "Ошибки:";
		bNeedToSave = true;
	}

	if (len(strPoints) == 0)
	{
		strPoints = "Баллы:";
		bNeedToSave = true;
	}

	if (len(strTrainingSuccess) == 0)
	{
		strTrainingSuccess = "Поздравляем!\\nВы успешно выполнили задание.";
		bNeedToSave = true;
	}
	if (len(strTrainingUnsuccess) == 0)
	{
		strTrainingUnsuccess = "Вы не выполнили задание";
		bNeedToSave = true;
	}
	if (len(strTrainingQuestion) == 0)
	{
		strTrainingQuestion = "Пройти задание еще раз?";
		bNeedToSave = true;
	}
}

DefaultProperties
{
	MovieInfo=SwfMovie'menu.Results.Results'
	WidgetBindings.Add((WidgetName="btnOK", WidgetClass=class'Kamaz_GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnCancel", WidgetClass=class'Kamaz_GFxClikWidget'))
	WidgetBindings.Add((WidgetName="BtnBack", WidgetClass=class'Kamaz_GFxClikWidget'))
	WidgetBindings.Add((WidgetName="ResultsText", WidgetClass=class'Kamaz_GFxClikWidget'))

	bShowExcersiseCount = false;
}
