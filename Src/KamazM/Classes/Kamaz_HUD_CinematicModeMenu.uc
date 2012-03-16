/** Меню ролика */
class Kamaz_HUD_CinematicModeMenu extends Kamaz_GFxMoviePlayer;

var Kamaz_GFxClikWidget skipBtn;
var Kamaz_GFxClikWidget	continueBtn;
var Kamaz_HUD GorodHUD;
// strings from ini-file
var config string strSkipBtn;
var config string strContinueBtn;


event bool WidgetInitialized (name WidgetName, name WidgetPath, GFxObject Widget) 
{
	switch (WidgetName) 
	{
		case ('skipBtn'):
			skipBtn = Kamaz_GFxClikWidget(Widget);
			skipBtn.AddEventListener('CLIK_click', OnSkipBtn);
			skipBtn.SetString("label", strSkipBtn);
			break;
		case ('continueBtn'):
			continueBtn = Kamaz_GFxClikWidget(Widget);
			continueBtn.AddEventListener('CLIK_click', OnContinueBtn);
			continueBtn.SetString("label", strContinueBtn);
			break;
		default:
			break;
	}

	return true;
}
///** обработчики кнопок *///
function OnSkipBtn(GFxClikWidget.EventData ev)
{
	local Kamaz_Game kg;
	kg = Kamaz_Game(GetPC().WorldInfo.Game);
	if(kg!=none)
		kg.MatineeStop();
	Close(false);
}

function OnContinueBtn(GFxClikWidget.EventData ev)
{
	local Kamaz_Game kg;
	kg = Kamaz_Game(GetPC().WorldInfo.Game);
	if(kg!=none)
		kg.MatineePause();
	Close(false);
}

event PostWidgetInit()
{
	super.PostWidgetInit();
	AddTabWidget(skipBtn); 
	AddTabWidget(continueBtn); 
}

/** Проверка на наличие UI текстов в ini-файле */
function checkConfig()
{
	super.checkConfig();
	if (len(strSkipBtn) == 0) {
		strSkipBtn = "Пропустить";				
		bNeedToSave = true;		
	}	

	if (len(strContinueBtn) == 0) {
		strContinueBtn = "Продолжить";				
		bNeedToSave = true;		
	}						
}

DefaultProperties
{
	bCaptureInput = true;
	MovieInfo = SwfMovie'menu.CinematicModeMenu';
	WidgetBindings.Add((WidgetName="skipBtn", WidgetClass=class'Kamaz_GFxClikWidget'))
	WidgetBindings.Add((WidgetName="continueBtn", WidgetClass=class'Kamaz_GFxClikWidget'))
}
