class Kamaz_HUD_VideoSettingsMenu extends Kamaz_GFxMoviePlayer
	config(Resolutions);
/** ������ �� ������� ���� */
var Kamaz_HUD GorodHUD;
/** ������ "�����" */
var GFxClikWidget btnBack;

var GFxClikWidget MonitorsCount;
var GFxClikWidget Resolution;
var GFxClikWidget ScreenCalibrationBtn;

var GFxClikWidget saveVideoSettingsBtn;
var Kamaz_HUD_ScreenCalibration scrCalibrationMovie;

/** �������������� ���������� */
var config array<string> supportedResolutions;
/** �������������� ���������� ��������� */
var config int MaxMonitorsCnt;

/** ������ ���������� ��������� - ������ ������� */
var config int curMonitorsCnt;
/** ������ ���������� - ������ ������� */
var config int curResolution;
/** strings from ini-file */
var config string strSaveVideoSettingsBtn;
var config string strScreenCalibrationBtn;
var config string strVideoSettingsMenuTitle;
var config string strMonitorsCountLabel;
var config string strResolutionLabel;
var private SMUtils sm_Utils;

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
		case('VideoSettingsCancelBtn'):
			btnBack = GFxClikWidget(Widget);
			btnBack.AddEventListener('CLIK_click', OnBackButtonClick);
			btnBack.SetString("label", strBackBtn);
			break;
		case('MonitorsCount'):
			MonitorsCount = GFxClikWidget(Widget);
			SetMonitorsCountData();
			MonitorsCount.AddEventListener('CLIK_change', OnMonitorsCountChange);
			break;
		case('Resolution'):
			Resolution = GFxClikWidget(Widget);
			SetResolutionData();
			break;
		case('saveVideoSettingsBtn'):
			saveVideoSettingsBtn = GFxClikWidget(Widget);
			saveVideoSettingsBtn.AddEventListener('CLIK_click', OnSaveVideoSettingsClick);
			saveVideoSettingsBtn.SetString("label", strSaveVideoSettingsBtn);
			break;
		case('btnScreenCalibration'):
			ScreenCalibrationBtn = GFxClikWidget(Widget);
			ScreenCalibrationBtn.AddEventListener('CLIK_click', OnScreenCalibrationClick);
			ScreenCalibrationBtn.SetString("label", strScreenCalibrationBtn);
			break;
		case('VideoSettingsMenuTitle'):
			widget.SetText(strVideoSettingsMenuTitle);
			break;
		case('MonitorsCountLabel'):
			widget.SetText(strMonitorsCountLabel);
			break;
		case('ResolutionLabel'):
			widget.SetText(strResolutionLabel);
			break;
		default:
			break;
	}

	return true;
}

event PostWidgetInit()
{
	super.PostWidgetInit();
	InitializeClickComponent();
}
/** ������ ��������� � ���������� ��������� �������� */
function InitializeClickComponent()
{
	local ASValue val;
	local float a;
	local string t;
	
	

	val.Type = AS_Number;
	//���������, �� �� ��������� � �������� ����������, ���� ��� - ��  ��������� � ���������
	if(supportedResolutions.Length==0)
	{
		supportedResolutions.AddItem("800x600");
		supportedResolutions.AddItem("1024x768");
		supportedResolutions.AddItem("1920x1080");

		SaveConfig();
	}

	val.n = curResolution;
	Resolution.Set("selectedIndex",val);
	sm_Utils = new class'SMUtils';
	a= sm_Utils.MonitorsNum();
	t=string(a);
	//val.n = sm_Utils.MonitorsNum();
	//val.n = curMonitorsCnt-1;
	//MonitorsCount.Set("selectedIndex",val);
	MonitorsCount.SetText(t);

}
/** ������������ OptionStepper'� Resolution ������� */
function SetResolutionData()
{
	local GFxObject DataProvider;
	local GFxObject TempObj;
	local int i;
	local string res;
    DataProvider = CreateArray();
	`warn("Resolution=none",Resolution==none);
	if(Resolution!=none)
	{
		foreach supportedResolutions(res,i)
		{
			TempObj =  CreateObject("Object");
			TempObj.SetString("label", res);
			DataProvider.SetElementObject(i,TempObj);
		}
	}
	Resolution.SetObject("dataProvider", DataProvider);
}

/** ������������ OptionStepper'� MonitorsCount ������� */
function SetMonitorsCountData()
{
	local GFxObject DataProvider;
	local GFxObject TempObj;
	local int i;
    DataProvider = CreateArray();
	`warn("MonitorsCount=none",MonitorsCount==none);
	if(MonitorsCount!=none)
	{
		for (i= 1; i<=MaxMonitorsCnt; i++)
		{
			TempObj =  CreateObject("Object");
			TempObj.SetString("label", ""$i);
			DataProvider.SetElementObject(i-1,TempObj);
		}
	}
	MonitorsCount.SetObject("dataProvider", DataProvider);
}

/** �������� �  ��������� ���������� ��������� � ���������� */
function OnSaveVideoSettingsClick(GFxClikWidget.EventData ev)
{
	local ASValue val;
	local string command;

	`warn("Resolution==none",Resolution==none);
	`warn("supportedResolutions==none",supportedResolutions.Length==0);
	`warn("MonitorsCount==none",MonitorsCount==none);

	if(Resolution!=none && supportedResolutions.Length >0 && MonitorsCount!= none)
	{
		val = Resolution.Get("selectedIndex");
		curResolution = val.n;

		val = MonitorsCount.Get("selectedIndex");
		curMonitorsCnt = val.n+1;
		command = "setres"@supportedResolutions[curResolution];
		//����������� ������������ objPC, ����� �� ��������
		GetPC().ConsoleCommand(command);
		//����������
		SaveConfig();
	}
	
}
/** ��������� ������� ������*/
function OnBackButtonClick(GFxClikWidget.EventData ev)
{
	goBack();
}
/**  �� ������ ���������� ���������, ������ ����������� �������� */
function OnMonitorsCountChange(GFxClikWidget.EventData ev)
{
	local ASValue val;
	`warn("Resolution==none",Resolution==none);
	`warn("ScreenCalibrationBtn==none",ScreenCalibrationBtn==none);
	if(Resolution==none ||ScreenCalibrationBtn == none)
		return;
	val = MonitorsCount.Get("selectedIndex");
	if(val.n >0)
	{
		Resolution.SetBool("disabled",true);
		ScreenCalibrationBtn.SetBool("disabled",false);
	}
	else
	{
		Resolution.SetBool("disabled",false);
		ScreenCalibrationBtn.SetBool("disabled",true);
	}

}
/** ��� �� ��� ������ */
function OnScreenCalibrationClick(GFxClikWidget.EventData ev)
{
	if(scrCalibrationMovie == none)
	{
		scrCalibrationMovie = new class'Kamaz_HUD_ScreenCalibration';
		scrCalibrationMovie.ownerMovie = self;
		scrCalibrationMovie.GorodHUD = GorodHUD;
		scrCalibrationMovie.checkConfig();
		//scrCalibrationMovie.RenderTexture = TextureRenderTarget2D'Gorod_Effects.PostProcess.FlashRenderTarget';
		scrCalibrationMovie.dlgOnBackButtonPress = OnScreenCalibrationClosed;
		if(scrCalibrationMovie.ScrCalibrationManager == none)
		{
			scrCalibrationMovie.ScrCalibrationManager = Kamaz_HUD(Kamaz_PlayerController(GetPC()).myHUD).DeformController;
		}
	}

	scrCalibrationMovie.Start();

	/** @fixme ���� ��� ���� ��� ���������������, �.�. �������� � ������ ������ ���������� */
	//����� �� ������ 2 ����
	//GorodHUD.gfxVideoSettingsMenu = none;
	self.Close(false);
}

function OnScreenCalibrationClosed()
{
	scrCalibrationMovie.Close(false);

	self.Start(false);
}

/** �������� �� ������� UI ������� � ini-����� */
function checkConfig()
{	
	super.checkConfig();
	if (len(strSaveVideoSettingsBtn) == 0) {
		strSaveVideoSettingsBtn = "���������";				
		bNeedToSave = true;		
	}	
	
	if (len(strScreenCalibrationBtn) == 0) {
		strScreenCalibrationBtn = "���������� ������";				
		bNeedToSave = true;		
	}		

	if (len(strVideoSettingsMenuTitle) == 0) {
		strVideoSettingsMenuTitle = "��������� �����";				
		bNeedToSave = true;		
	}		

	if (len(strMonitorsCountLabel) == 0) {
		strMonitorsCountLabel = "���������� ���������:";				
		bNeedToSave = true;		
	}		

	if (len(strResolutionLabel) == 0) {
		strResolutionLabel = "����������:";				
		bNeedToSave = true;		
	}			
}
function OnCleanup()
{
	super.OnCleanup();
	switch(nextMovieClass)
	{
	case class'Kamaz_HUD_ScreenCalibration':
		if(scrCalibrationMovie==none)
		{
			scrCalibrationMovie = new class'Kamaz_HUD_ScreenCalibration';
			scrCalibrationMovie.ownerMovie = self;
			scrCalibrationMovie.checkConfig();
			scrCalibrationMovie.Init();
		}
		else
		{
			scrCalibrationMovie.Start(false);
		}
		break;
	default:
		break;

	}
}
DefaultProperties
{	
	bCaptureInput = true;
	WidgetBindings.Add((WidgetName="VideoSettingsCancelBtn", WidgetClass=class'GFxClikWidget'));
	WidgetBindings.Add((WidgetName="MonitorsCount", WidgetClass=class'GFxClikWidget'));
	WidgetBindings.Add((WidgetName="Resolution", WidgetClass=class'GFxClikWidget'));
	WidgetBindings.Add((WidgetName="saveVideoSettingsBtn", WidgetClass=class'GFxClikWidget'));
	WidgetBindings.Add((WidgetName="btnScreenCalibration", WidgetClass=class'GFxClikWidget'));

	MovieInfo=SwfMovie'menu.VideoSettingsMenu.VideoSettings';
}
