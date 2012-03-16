class Kamaz_HUD_ExamMenu extends Kamaz_GFxMoviePlayer;
/** ������ �� ������� ���� */
var Kamaz_HUD KamazHUD;
/** ������ "�����" */
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
	// ��������� ������������ ��������� 
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
/** ��������� ������� ������*/
function OnBackButtonClick(GFxClikWidget.EventData ev)
{
	goBack();
}

/** ����� �������� */
function OnexamSelectButtonClick(GFxClikWidget.EventData ev)
{

}
/** �������� �� ������� UI ������� � ini-����� */
function checkConfig()
{		
	super.checkConfig();
	if (len(strExamSelectBtn) == 0) {
		strExamSelectBtn = "�������";				
		bNeedToSave = true;		
	}	

	if (len(strExamDescription) == 0) {
		strExamDescription = "������ ��������";				
		bNeedToSave = true;		
	}		

	if (len(strExamMenuTitle) == 0) {
		strExamMenuTitle = "�������";				
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
