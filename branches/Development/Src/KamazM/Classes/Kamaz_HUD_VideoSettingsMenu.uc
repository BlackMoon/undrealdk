class Kamaz_HUD_VideoSettingsMenu extends Kamaz_GFxMoviePlayer
	config(Resolutions);
/** Ссылка на главное меню */
var Kamaz_HUD GorodHUD;
/** Кнопка "Назад" */
var GFxClikWidget btnBack;

var GFxClikWidget MonitorsCount;
var GFxClikWidget Resolution;
var GFxClikWidget ScreenCalibrationBtn;

var GFxClikWidget saveVideoSettingsBtn;
var Kamaz_HUD_ScreenCalibration scrCalibrationMovie;

/** Поддерживаемые разрешения */
var config array<string> supportedResolutions;
/** Поддерживаемое количество мониторов */
var config int MaxMonitorsCnt;

/** текщее количество мониторов - индекс массива */
var config int curMonitorsCnt;
/** текщее разрешение - индекс массива */
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
	// Добавляем обработчиики контролам 
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
/** задает контролам и переменным начальные значения */
function InitializeClickComponent()
{
	local ASValue val;
	local float a;
	local string t;
	
	

	val.Type = AS_Number;
	//Проверяем, всё ли нормально с массивом разрешений, если нет - то  заполняем и сохраняем
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
/** устанвливает OptionStepper'у Resolution контент */
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

/** устанвливает OptionStepper'у MonitorsCount контент */
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

/** Изменить и  сохранить количество мониторов и разрешение */
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
		//обязательно использовать objPC, иначе не задается
		GetPC().ConsoleCommand(command);
		//сохранимся
		SaveConfig();
	}
	
}
/** Закрывает текущую флешку*/
function OnBackButtonClick(GFxClikWidget.EventData ev)
{
	goBack();
}
/**  не меняет количество мониторов, просто переключает контролы */
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
/** что то там Динара */
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

	/** @fixme этот код пока что закомментирован, т.к. приводит к вылету флешки деформации */
	//чтобы не тыкать 2 раза
	//GorodHUD.gfxVideoSettingsMenu = none;
	self.Close(false);
}

function OnScreenCalibrationClosed()
{
	scrCalibrationMovie.Close(false);

	self.Start(false);
}

/** Проверка на наличие UI текстов в ini-файле */
function checkConfig()
{	
	super.checkConfig();
	if (len(strSaveVideoSettingsBtn) == 0) {
		strSaveVideoSettingsBtn = "Сохранить";				
		bNeedToSave = true;		
	}	
	
	if (len(strScreenCalibrationBtn) == 0) {
		strScreenCalibrationBtn = "Калибровка экрана";				
		bNeedToSave = true;		
	}		

	if (len(strVideoSettingsMenuTitle) == 0) {
		strVideoSettingsMenuTitle = "Настройки видео";				
		bNeedToSave = true;		
	}		

	if (len(strMonitorsCountLabel) == 0) {
		strMonitorsCountLabel = "Количество мониторов:";				
		bNeedToSave = true;		
	}		

	if (len(strResolutionLabel) == 0) {
		strResolutionLabel = "Разрешение:";				
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
