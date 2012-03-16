class Kamaz_HUD_ScreenCalibration extends Kamaz_GFxMoviePlayer;

var Gorod_PostProcessDeformationController ScrCalibrationManager;
/** strings from ini-file */
var config string strCheckDeformation;
var config string strHorzDispUp;
var config string strVertDispUp;

var config string strBottomPanelTitle;
var config string strBottomHeight;
var config string strBottomSidesHeightDisp;
var config string strBottomHeaderHeight;
var config string strBottomSidesFlatness;

var config string strTopPanelTitle;
var config string strTopHeight;
var config string strTopDispToUp;
var Kamaz_HUD GorodHUD;

delegate dlgOnBackButtonPress();

function bool Start(optional bool StartPaused = false) 
{
	/*if(ScrCalibrationManager == none)
	{
		ScrCalibrationManager = self.GetPC().Spawn(class'Gorod_PostProcessDeformationController');
	}*/
	super.Start(StartPaused);
	
	Advance(0);
	SetViewScaleMode(SM_NoScale);
	SetAlignment(Align_TopLeft);
	return true;
}

event OnClose()
{
	super.OnClose();
}

simulated function SliderChanged(int sliderNum, float value)
{
	//`log("SliderChanged" @ sliderNum @ value);

	if(!ScrCalibrationManager.IsDeformEnabled())
		return;

	switch(sliderNum)
	{
	case 1:
		ScrCalibrationManager.SetBottomHeight(value);
		break;

	case 2:
		ScrCalibrationManager.SetBottomSidesHeightDisp(value);
		break;

	case 3:
		ScrCalibrationManager.SetBottomHeaderHeightDisp(value);
		break;

	case 4:
		// temp!!!
		
		ScrCalibrationManager.SetBottomOuterSidesHeightDisp(value);
		break;

	case 5:
		ScrCalibrationManager.SetYdisp(value);
		break;

	case 6:
		ScrCalibrationManager.SetXdisp(value);
		break;

	case 7:
		ScrCalibrationManager.SetTopHeight(value);
		break;

	case 8:
		ScrCalibrationManager.SetTopDispToUp(value);
		break;
	}
}

event bool WidgetInitialized (name WidgetName, name WidgetPath, GFxObject Widget) 
{
	switch(WidgetName)
	{
		case('checkDeformationOn'):		
			widget.SetString("label", strCheckDeformation);
			widget.SetBool("selected", ScrCalibrationManager.IsDeformEnabled());
			break;		
		// bottomPanel
		case('BottomPanelTitle'):		
			widget.SetText(strBottomPanelTitle);
			break;		
		case('lblBottomHeight'):		
			widget.SetText(strBottomHeight);
			break;		
		case('lblBottomSidesHeightDisp'):		
			widget.SetText(strBottomSidesHeightDisp);
			break;		
		case('lblBottomHeaderHeight'):		
			widget.SetText(strBottomHeaderHeight);
			break;		
		case('lblBottomSidesFlatness'):		
			widget.SetText(strBottomSidesFlatness);
			break;		
		// topPanel
		case('TopPanelTitle'):		
			widget.SetText(strTopPanelTitle);
			break;		
		case('lblTopHeight'):		
			widget.SetText(strTopHeight);
			break;		
		case('lblTopDispToUp'):		
			widget.SetText(strTopDispToUp);
			break;		
		
		case('lblVertDisp'):		
			widget.SetText(strVertDispUp);
			break;
		case('lblHorzDisp'):		
			widget.SetText(strHorzDispUp);
			break;	

		case('btnBack'):		
			widget.SetString("label", strBackBtn);
			break;		
	}
	return true;
}

simulated function DeformationOn(bool on)
{
	//`log("DeformationOn");
	ScrCalibrationManager.EnableDeformation(on);
}

simulated function OnBackButtonClick()
{
	`log("Back");
	ScrCalibrationManager.SaveDeformations();
	//GorodHUD.gfxVideoSettingsMenu.OnScreenCalibrationClosed();
	//GorodHUD.scrCalibrationMovie = none;
	/*Close(true);
	if(GorodHUD!=none)
		GorodHUD.ShowVideoOptMenu();*/
	goBack();
	
}

/** Проверка на наличие UI текстов в ini-файле */
function checkConfig()
{	
	super.checkConfig();
	if (len(strCheckDeformation) == 0) {
		strCheckDeformation = "Режим деформации экрана";				
		bNeedToSave = true;		
	}	

	if (len(strHorzDispUp) == 0) {
		strHorzDispUp = "Смещение по горизонтали";				
		bNeedToSave = true;		
	}	

	if (len(strVertDispUp) == 0) {
		strVertDispUp = "Смещение по вертикали";				
		bNeedToSave = true;		
	}	
	// bottom panel
	if (len(strBottomPanelTitle) == 0) {
		strBottomPanelTitle = "Нижняя часть";				
		bNeedToSave = true;		
	}	
	if (len(strBottomHeight) == 0) {
		strBottomHeight = "Высота";				
		bNeedToSave = true;		
	}	
	if (len(strBottomSidesHeightDisp) == 0) {
		strBottomSidesHeightDisp = "Высота боковых сторон";				
		bNeedToSave = true;		
	}	
	if (len(strBottomHeaderHeight) == 0) {
		strBottomHeaderHeight = "Высота \'шапки\'";				
		bNeedToSave = true;		
	}	
	if (len(strBottomSidesFlatness) == 0) {
		strBottomSidesFlatness = "Спепень плоскости по бокам";				
		bNeedToSave = true;		
	}	
	// top panel
	if (len(strTopPanelTitle) == 0) {
		strTopPanelTitle = "Верхняя часть";				
		bNeedToSave = true;		
	}	
	if (len(strTopHeight) == 0) {
		strTopHeight = "Высота";				
		bNeedToSave = true;		
	}	
	if (len(strTopDispToUp) == 0) {
		strTopDispToUp = "Смещение вверх";				
		bNeedToSave = true;		
	}		
}

DefaultProperties
{
	MovieInfo=SwfMovie'menu.ScreenCalibration.ScreenCalibration'
}
