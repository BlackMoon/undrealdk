class Kamaz_HUD_SettingsScreen extends Kamaz_GFxMoviePlayer;
var Kamaz_GFxClikWidget controllingOptBtn;
var Kamaz_GFxClikWidget	VideoOptBtn;
var Kamaz_GFxClikWidget SettingsMenuGoBackBtn;
var Kamaz_GFxClikWidget itemDescription;
var Kamaz_HUD KamazHUD;
/** strings from ini-file */
var config string strControllingOptBtn;
var config string strVideoOptBtn;
var config string strSettingsMenuTitle;

/******************************************************************/
/** �������� ������ */
var config string controllingOptDesription;
var config string VideoOptDesription;
var config string SettingsMenuGoBackDesription;
/******************************************************************/

event bool WidgetInitialized (name WidgetName, name WidgetPath, GFxObject Widget) 
{
	switch (WidgetName) 
	{

		case ('controllingOptBtn'):
			controllingOptBtn = Kamaz_GFxClikWidget(Widget);
			controllingOptBtn.AddEventListener('CLIK_click', OncontrollingOptBtn);

			controllingOptBtn.AddEventListener('CLIK_rollOver', OnControllingOptBtnRollOver);
			controllingOptBtn.AddEventListener('CLIK_rollOut', SetDefaultText);

			controllingOptBtn.SetString("label", strControllingOptBtn);
			break;
		case ('VideoOptBtn'):
			VideoOptBtn = Kamaz_GFxClikWidget(Widget);
			VideoOptBtn.AddEventListener('CLIK_click', OnVideoOptBtn);

			VideoOptBtn.AddEventListener('CLIK_rollOver', OnVideoOptBtnRollOver);
			VideoOptBtn.AddEventListener('CLIK_rollOut', SetDefaultText);

			VideoOptBtn.SetString("label", strVideoOptBtn);
			break;
		case('SettingsMenuGoBackBtn'):
			SettingsMenuGoBackBtn = Kamaz_GFxClikWidget(Widget);
			SettingsMenuGoBackBtn.AddEventListener('CLIK_click', OnSettingsMenuGoBackBtn);
			
			SettingsMenuGoBackBtn.AddEventListener('CLIK_rollOver', OnSettingsMenuGoBackBtnRollOver);
			SettingsMenuGoBackBtn.AddEventListener('CLIK_rollOut', SetDefaultText);

			SettingsMenuGoBackBtn.SetString("label", strBackBtn);
			break;
		case('SettingsMenuTitle'):
			widget.SetText(strSettingsMenuTitle);
			break;
		case('itemDescription'):
			itemDescription = Kamaz_GFxClikWidget(Widget);
			break;
		default:
			break;
	}
	return true;
}
///** ����������� ������ *///
function OncontrollingOptBtn(GFxClikWidget.EventData ev)
{
//	GorodHUD.ShowControlSettingsMenu();
}

function OnVideoOptBtn(GFxClikWidget.EventData ev)
{
//	GorodHUD.ShowVideoOptMenu();

}

function OnSettingsMenuGoBackBtn(GFxClikWidget.EventData ev)
{
//	GorodHUD.ShowMainMenu();
}

event PostWidgetInit()
{
	super.PostWidgetInit();	

	AddTabWidget(controllingOptBtn); 
	AddTabWidget(VideoOptBtn); 
	AddTabWidget(SettingsMenuGoBackBtn);
	itemDescription.SetBool("editable",false);
}

/** �������� �� ������� UI ������� � ini-����� */
function checkConfig()
{
	super.checkConfig();
	if (len(strControllingOptBtn) == 0) {
		strControllingOptBtn = "����������";				
		bNeedToSave = true;		
	}	

	if (len(strVideoOptBtn) == 0) {
		strVideoOptBtn = "�����";				
		bNeedToSave = true;		
	}		

	if (len(strSettingsMenuTitle) == 0) {
		strSettingsMenuTitle = "���������";				
		bNeedToSave = true;		
	}
	if (len(controllingOptDesription) == 0) {
		controllingOptDesription = "��������� ��������� ���������� �����";
		bNeedToSave = true;		
	}	
	if (len(VideoOptDesription) == 0) {
		VideoOptDesription = "��������� ��������� ���������� ������ (�������/��������) ";
		bNeedToSave = true;		
	}	
	if (len(SettingsMenuGoBackDesription) == 0) {
		SettingsMenuGoBackDesription = "������� � ������� ����";				
		bNeedToSave = true;		
	}	

}

//////////////////////��������� ����
function OnControllingOptBtnRollOver(GFxClikWidget.EventData ev)
{
	itemDescription.SetText(controllingOptDesription);
	
}function OnVideoOptBtnRollOver(GFxClikWidget.EventData ev)
{
	itemDescription.SetText(VideoOptDesription);
	
}function OnSettingsMenuGoBackBtnRollOver(GFxClikWidget.EventData ev)
{
	itemDescription.SetText(SettingsMenuGoBackDesription);
	
}

function SetDefaultText(GFxClikWidget.EventData ev)
{
	itemDescription.SetText("");
}

DefaultProperties
{
	WidgetBindings.Add((WidgetName="controllingOptBtn", WidgetClass=class'Kamaz_GFxClikWidget'))
	WidgetBindings.Add((WidgetName="VideoOptBtn", WidgetClass=class'Kamaz_GFxClikWidget'))
	WidgetBindings.Add((WidgetName="SettingsMenuGoBackBtn", WidgetClass=class'Kamaz_GFxClikWidget'))
	WidgetBindings.Add((WidgetName="itemDescription", WidgetClass=class'Kamaz_GFxClikWidget'))
}
