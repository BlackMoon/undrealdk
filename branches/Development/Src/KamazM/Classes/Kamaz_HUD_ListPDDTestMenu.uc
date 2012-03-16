class Kamaz_HUD_ListPDDTestMenu extends Kamaz_GFxMoviePlayer;
/** ������ �� ������� ���� */
var Kamaz_HUD GorodHUD;
/** ������ "�����" */
var GFxClikWidget btnBack;

var GFxClikWidget StartPDDBtn;
var GFxClikWidget CCategoryDescription;

var GFxClikWidget StartCategoryBackBtn;
var GFxClikWidget StartTestBtn;
var GFxClikWidget TestsText;

/** �����  */
var GFxClikWidget CorrectAnswPDD;
var GFxClikWidget mistakesPDD;
var GFxClikWidget TimePassagePDD;
var GFxClikWidget ResultPDD;

var GFxClikWidget exitResultPDDBtn;
var GFxClikWidget RestartPDDBtn;
/** strings from ini-file */
var config string strStartPDDBtn;
var config string strCCategoryDescription;
var config string strStartCategoryBackBtn;
var config string strStartTestBtn;
var config string strTestsText;
var config string strMistakesPDD;
var config string strTimePassagePDD;
var config string strResultPDD;
var config string strPDDMainMenuTitle;

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
		case('CategoryBackBtn'):
			btnBack = GFxClikWidget(Widget);
			btnBack.AddEventListener('CLIK_click', OnBackButtonClick);
			btnBack.SetString("label", strBackBtn);
			break;
		case('StartPDDBtn'):
			StartPDDBtn = GFxClikWidget(Widget);
			StartPDDBtn.AddEventListener('CLIK_click', OnStartPDDButtonClick);
			StartPDDBtn.SetString("label", strStartPDDBtn);
			break;
		case('CCategoryDescription'):
			CCategoryDescription = GFxClikWidget(Widget);
			CCategoryDescription.SetText(strCCategoryDescription);			
			break;
		///////////////////////////////////////////////////////////////////////////////
		case('StartCategoryBackBtn'):
			StartCategoryBackBtn = GFxClikWidget(Widget);
			StartCategoryBackBtn.AddEventListener('CLIK_click', OnTestBackButtonClick);
			StartCategoryBackBtn.SetString("label", strStartCategoryBackBtn);
			break;
		case('StartTestBtn'):
			StartTestBtn = GFxClikWidget(Widget);
			StartTestBtn.AddEventListener('CLIK_click', OnStartTestButtonClick);
			StartTestBtn.SetString("label", strStartTestBtn);
			break;
		case('TestsText'):
			TestsText = GFxClikWidget(Widget);			
			TestsText.SetText(strTestsText);
			break;
		///////////////////////////////////////////////////////////////////////////////
		case('CorrectAnswPDD'):
			StartCategoryBackBtn = GFxClikWidget(Widget);			
			StartCategoryBackBtn.SetText(strStartCategoryBackBtn);
			break;
		case('mistakesPDD'):
			mistakesPDD = GFxClikWidget(Widget);			
			mistakesPDD.SetText(strMistakesPDD);
			break;
		case('TimePassagePDD'):
			TimePassagePDD = GFxClikWidget(Widget);			
			TimePassagePDD.SetText(strTimePassagePDD);
			break;
		case('ResultPDD'):
			ResultPDD = GFxClikWidget(Widget);			
			ResultPDD.SetText(strResultPDD);
			break;
		case('exitResultPDDBtn'):
			StartCategoryBackBtn = GFxClikWidget(Widget);
			StartCategoryBackBtn.AddEventListener('CLIK_click', OnExitResultPDButtonClick);
			StartCategoryBackBtn.SetString("label", strStartCategoryBackBtn);
			break;
		case('RestartPDDBtn'):
			StartTestBtn = GFxClikWidget(Widget);
			StartTestBtn.AddEventListener('CLIK_click', OnRestartPDDButtonClick);
			StartTestBtn.SetString("label", strStartTestBtn);
			break;
		case('PDDMainMenuTitle'):
			widget.SetText(strPDDMainMenuTitle);
			break;
		default:
			break;
	}

	return true;
}
/** ������ ���� */
function OnStartPDDButtonClick(GFxClikWidget.EventData ev)
{

}

function OnTestBackButtonClick(GFxClikWidget.EventData ev)
{

}

function OnStartTestButtonClick(GFxClikWidget.EventData ev)
{

}




function OnExitResultPDButtonClick(GFxClikWidget.EventData ev)
{

}

function OnRestartPDDButtonClick(GFxClikWidget.EventData ev)
{

}






/** ��������� ������� ������*/
function OnBackButtonClick(GFxClikWidget.EventData ev)
{
	Close(false);
	if(GorodHud!=none)
		GorodHud.ShowAndPlayMainMenu();
}
/** �������� �� ������� UI ������� � ini-����� */
function checkConfig()
{	
	super.checkConfig();
	if (len(strStartPDDBtn) == 0) {
		strStartPDDBtn = "������";				
		bNeedToSave = true;		
	}	

	if (len(strCCategoryDescription) == 0) {
		strCCategoryDescription = "��� ������ ����� ������� ������ =) (������� ��� )";				
		bNeedToSave = true;		
	}		

	if (len(strStartCategoryBackBtn) == 0) {
		strStartCategoryBackBtn = "�����";				
		bNeedToSave = true;		
	}	

	if (len(strStartTestBtn) == 0) {
		strStartTestBtn = "������";				
		bNeedToSave = true;		
	}	

	if (len(strTestsText) == 0) {
		strTestsText = "����� �����";				
		bNeedToSave = true;		
	}	

	if (len(strMistakesPDD) == 0) {
		strMistakesPDD = "������: 0";				
		bNeedToSave = true;		
	}

	if (len(strTimePassagePDD) == 0) {
		strTimePassagePDD = "����� ����������� ������������: 0";				
		bNeedToSave = true;		
	}

	if (len(strResultPDD) == 0) {
		strResultPDD = "���������:";				
		bNeedToSave = true;		
	}

	if (len(strStartCategoryBackBtn) == 0) {
		strStartCategoryBackBtn = "���������� �������: 0";				
		bNeedToSave = true;		
	}

	if (len(strPDDMainMenuTitle) == 0) {
		strPDDMainMenuTitle = "������� ��������� ��������";				
		bNeedToSave = true;		
	}	
}

DefaultProperties
{
	bCaptureInput = true;
	WidgetBindings.Add((WidgetName="CategoryBackBtn", WidgetClass=class'GFxClikWidget'));
	WidgetBindings.Add((WidgetName="StartPDDBtn", WidgetClass=class'GFxClikWidget'));
	WidgetBindings.Add((WidgetName="CCategoryDescription", WidgetClass=class'GFxClikWidget'));

	WidgetBindings.Add((WidgetName="StartCategoryBackBtn", WidgetClass=class'GFxClikWidget'));
	WidgetBindings.Add((WidgetName="StartTestBtn", WidgetClass=class'GFxClikWidget'));
	WidgetBindings.Add((WidgetName="TestsText", WidgetClass=class'GFxClikWidget'));
	WidgetBindings.Add((WidgetName="CorrectAnswPDD", WidgetClass=class'GFxClikWidget'));
	WidgetBindings.Add((WidgetName="mistakesPDD", WidgetClass=class'GFxClikWidget'));
	WidgetBindings.Add((WidgetName="TimePassagePDD", WidgetClass=class'GFxClikWidget'));
	WidgetBindings.Add((WidgetName="ResultPDD", WidgetClass=class'GFxClikWidget'));

	WidgetBindings.Add((WidgetName="exitResultPDDBtn", WidgetClass=class'GFxClikWidget'));
	WidgetBindings.Add((WidgetName="RestartPDDBtn", WidgetClass=class'GFxClikWidget'));

	MovieInfo=SwfMovie'menu.ListPDDTestMenu.ListPDDTest';
}
