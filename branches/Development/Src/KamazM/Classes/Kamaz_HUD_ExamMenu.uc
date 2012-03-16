class Kamaz_HUD_ExamMenu extends Kamaz_GFxMoviePlayer;
/** Ссылка на главное меню */
var Kamaz_HUD KamazHUD;
/** Кнопка "Назад" */
var GFxClikWidget btnBack;
var GFxClikWidget examSelectBtn;
var GFxClikWidget examDescription;
// strings from ini-file
var config string strExamSelectBtn;
var config string strExamDescription;
var config string strexamMenuTitle;

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
		case('examBackBtn'):
			btnBack = GFxClikWidget(Widget);
			btnBack.AddEventListener('CLIK_click', OnBackButtonClick);
			btnBack.SetString("label", strBackBtn);
			break;
		case('examSelectBtn'):
			examSelectBtn = GFxClikWidget(Widget);
			examSelectBtn.AddEventListener('CLIK_click', OnexamSelectButtonClick);
			examSelectBtn.SetString("label", strExamSelectBtn);
			break;
		case('examDescription'):
			examDescription = GFxClikWidget(Widget);			
			examDescription.SetText(strExamDescription);
			break;
		case('examMenuTitle'):
			widget.setText(strExamMenuTitle);
			break;
		default:
			break;
	}

	return true;
}
/** Закрывает текущую флешку*/
function OnBackButtonClick(GFxClikWidget.EventData ev)
{
	goBack();
}

/** Зауск экзамена */
function OnexamSelectButtonClick(GFxClikWidget.EventData ev)
{

}
/** Проверка на наличие UI текстов в ini-файле */
function checkConfig()
{		
	super.checkConfig();
	if (len(strExamSelectBtn) == 0) {
		strExamSelectBtn = "Выбрать";				
		bNeedToSave = true;		
	}	

	if (len(strExamDescription) == 0) {
		strExamDescription = "Начало экзамена";				
		bNeedToSave = true;		
	}		

	if (len(strExamMenuTitle) == 0) {
		strExamMenuTitle = "Экзамен";				
		bNeedToSave = true;		
	}				
}

DefaultProperties
{
	bCaptureInput = true;
	WidgetBindings.Add((WidgetName="examBackBtn", WidgetClass=class'GFxClikWidget'));
	WidgetBindings.Add((WidgetName="examSelectBtn", WidgetClass=class'GFxClikWidget'));
	WidgetBindings.Add((WidgetName="examDescription", WidgetClass=class'GFxClikWidget'));
	MovieInfo=SwfMovie'menu.ExamMenu.Exam';
}
