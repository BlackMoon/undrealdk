class Kamaz_HUD_ControlSettingsMenu extends Kamaz_GFxMoviePlayer;
/** ������ �� ������� ���� */
var Kamaz_HUD KamazHUD;

/** ������ "�����" */
var Kamaz_GFxClikWidget btnBack;

/** ����������� */
var Kamaz_GFxClikWidget AutomaticChooseBtn;
var Kamaz_GFxClikWidget simulatorBtn;
var Kamaz_GFxClikWidget keyboardBtn;
var Kamaz_GFxClikWidget wheelBtn;

/** ������ ��������� ������������*/
var Kamaz_GFxClikWidget simulatorSettingsBtn;
var Kamaz_GFxClikWidget keyboardSettingsBtn;
var config bool bIsCalibrationDisabled;
/** strings from ini-file */
var config string strSimulatorBtn;
var config string strKeyboardBtn;
var config string strAutomaticChooseBtn;
var config string strWheelBtn;
var config string strSettingsBtn;
var config string strControlSettingsMenuTitle;
//////////������ �� �������� ������

/** ��������� ���������� */
var Kamaz_HUD_KeyboardSettings gfxKeyboardSettings;

var Kamaz_HUD_Calibration gfxTrainingStationCalibrationMenu;
////////////////////////////////////

function bool Start(optional bool StartPaused = false) 
{
	super.Start(StartPaused);
	/// ��-��������� ��������� 
	Advance(0);
	return true;
}

event bool WidgetInitialized (name WidgetName, name WidgetPath, GFxObject Widget) 
{
	// ��������� ������������ ��������� 
	switch(WidgetName)
	{
		case('ControlSettingsBackBtn'):
			btnBack = Kamaz_GFxClikWidget(Widget);
			btnBack.AddEventListener('CLIK_click', OnBackButtonClick);
			btnBack.SetString("label", strBackBtn);
			break;

		case('AutomaticChooseBtn'):
			AutomaticChooseBtn = Kamaz_GFxClikWidget(Widget);
			//���� ����� ��������� ������ �� ini
			AutomaticChooseBtn.SetBool("selected",true);			
			AutomaticChooseBtn.AddEventListener('CLIK_click', OnAutomaticChooseClick);
			AutomaticChooseBtn.SetString("label", strAutomaticChooseBtn);
			break;
		case('simulatorBtn'):
			simulatorBtn = Kamaz_GFxClikWidget(Widget);
			simulatorBtn.AddEventListener('CLIK_click', OnSimulatorButtonClick);
			simulatorBtn.SetString("label", strSimulatorBtn);
			break;
		case('keyboardBtn'):
			keyboardBtn = Kamaz_GFxClikWidget(Widget);
			keyboardBtn.AddEventListener('CLIK_click', OnKeyboardButtonClick);
			keyboardBtn.SetString("label", strKeyboardBtn);
			break;
		case('wheelBtn'):
			wheelBtn = Kamaz_GFxClikWidget(Widget);
			wheelBtn.AddEventListener('CLIK_click', OnWheelButtonClick);
			wheelBtn.SetString("label", strWheelBtn);
			break;
		case('simulatorSettingsBtn'):
			simulatorSettingsBtn = Kamaz_GFxClikWidget(Widget);
			simulatorSettingsBtn.AddEventListener('CLIK_click', OnSimulatorSettingsButtonClick);
			simulatorSettingsBtn.SetString("label", strSettingsBtn);
			break;
		case('keyboardSettingsBtn'):
			keyboardSettingsBtn = Kamaz_GFxClikWidget(Widget);
			keyboardSettingsBtn.AddEventListener('CLIK_click', OnKeyboardSettingsButtonClick);
			keyboardSettingsBtn.SetString("label", strSettingsBtn);
			break;
		case('ControlSettingsMenuTitle'):
			widget.SetText(strControlSettingsMenuTitle);
			break;
		default:
			break;
	}

	return true;
}

event PostWidgetInit()
{
	super.PostWidgetInit();

	AddTabWidget(AutomaticChooseBtn);

	AddTabWidget(simulatorBtn); 
	AddTabWidget(simulatorSettingsBtn); 
	AddTabWidget(keyboardBtn); 
	AddTabWidget(keyboardSettingsBtn);
	AddTabWidget(wheelBtn); 
	AddTabWidget(btnBack);
	if(bIsCalibrationDisabled)
		simulatorSettingsBtn.SetBool("disabled", true);
	if(AutomaticChooseBtn!=none)
		AutomaticChooseBtn.SetBool("focused",true);
}

/** �������������� ����������� */
function OnAutomaticChooseClick(GFxClikWidget.EventData ev)
{

}
/** ����� ��������� */
function OnSimulatorButtonClick(GFxClikWidget.EventData ev)
{
	
}
/** ����� ���������� */
function OnKeyboardButtonClick(GFxClikWidget.EventData ev)
{
	
}
/** ����� �������� ���� */
function OnWheelButtonClick(GFxClikWidget.EventData ev)
{
	
}


/** ���������� ������ "�������" */
function OnSelectButtonClick(GFxClikWidget.EventData ev)
{
	
}

/****************************/
//   ��������� ���������  //
/***************************/

/** ��������� ��������� */
function OnSimulatorSettingsButtonClick(GFxClikWidget.EventData ev)
{
	nextMovieClass = class'Kamaz_HUD_Calibration';
	self.Close(false);
}
/** ��������� ���������� */
function OnKeyboardSettingsButtonClick(GFxClikWidget.EventData ev)
{
	nextMovieClass = class'Kamaz_HUD_KeyboardSettings';
	Close(false);
}


/** ��������� ������� ������*/
function OnBackButtonClick(GFxClikWidget.EventData ev)
{
	goBack();
}
/** �������� �� ������� UI ������� � ini-����� */
function checkConfig()
{
	super.checkConfig();
	if (len(strSimulatorBtn) == 0) {
		strSimulatorBtn = "��������";				
		bNeedToSave = true;		
	}	

	if (len(strKeyboardBtn) == 0) {
		strKeyboardBtn = "����������";				
		bNeedToSave = true;		
	}	

	if (len(strAutomaticChooseBtn) == 0) {
		strAutomaticChooseBtn = "�������������� �����������";				
		bNeedToSave = true;		
	}

	if (len(strWheelBtn) == 0) {
		strWheelBtn = "������� ����";				
		bNeedToSave = true;		
	}

	if (len(strSettingsBtn) == 0) {
		strSettingsBtn = "���������";				
		bNeedToSave = true;		
	}	

	if (len(strControlSettingsMenuTitle) == 0) {
		strControlSettingsMenuTitle = "����������";
		bNeedToSave = true;
	}	
}


function OnCleanup()
{	
	super.OnCleanup();	
	
	switch(nextMovieClass)
	{
	case class'Kamaz_HUD_KeyboardSettings':
		if(gfxKeyboardSettings==none)
		{

			gfxKeyboardSettings = new class 'Kamaz_HUD_KeyboardSettings';
			gfxKeyboardSettings.ownerMovie = self;
			gfxKeyboardSettings.checkConfig();
			gfxKeyboardSettings.Init();
		}
		else
		{
			gfxKeyboardSettings.Start(false);
		}
		break;
	case class'Kamaz_HUD_Calibration':
		if(gfxTrainingStationCalibrationMenu==none)
		{
			gfxTrainingStationCalibrationMenu = new class'Kamaz_HUD_Calibration';			
			gfxTrainingStationCalibrationMenu.ownerMovie = self;
			gfxTrainingStationCalibrationMenu.checkConfig();
			gfxTrainingStationCalibrationMenu.Init();
		}
		else
		{
			gfxTrainingStationCalibrationMenu.Start(false);
		}

	default:
		break;

	}
}

DefaultProperties
{
	bCaptureInput = true;
	WidgetBindings.Add((WidgetName="ControlSettingsBackBtn", WidgetClass=class'Kamaz_GFxClikWidget'));
	WidgetBindings.Add((WidgetName="AutomaticChooseBtn", WidgetClass=class'Kamaz_GFxClikWidget'));
	WidgetBindings.Add((WidgetName="simulatorBtn", WidgetClass=class'Kamaz_GFxClikWidget'));
	WidgetBindings.Add((WidgetName="keyboardBtn", WidgetClass=class'Kamaz_GFxClikWidget'));
	WidgetBindings.Add((WidgetName="wheelBtn", WidgetClass=class'Kamaz_GFxClikWidget'));
	WidgetBindings.Add((WidgetName="simulatorSettingsBtn", WidgetClass=class'Kamaz_GFxClikWidget'));
	WidgetBindings.Add((WidgetName="keyboardSettingsBtn", WidgetClass=class'Kamaz_GFxClikWidget'));
		
	MovieInfo=SwfMovie'menu.ControlSettingsMenu.ControlSettings';
}
