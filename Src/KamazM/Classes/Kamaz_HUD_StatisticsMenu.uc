class Kamaz_HUD_StatisticsMenu extends Kamaz_GFxMoviePlayer;
/** Ссылка на главное меню */
var Kamaz_HUD KamazHUD;
/** Кнопка "Назад" */
var GFxClikWidget btnBack;
var GFxClikWidget statSelect;
var GFxClikWidget currProfDescription;
/** strings from ini-file */
var config string strStatSelect;
var config string strStatMenuTitle;

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
		case('statBackBtn'):
			btnBack = GFxClikWidget(Widget);
			btnBack.AddEventListener('CLIK_click', OnBackButtonClick);
			btnBack.SetString("label", strBackBtn);
			break;
		case('statSelect'):
			statSelect = GFxClikWidget(Widget);
			statSelect.AddEventListener('CLIK_click', OnStatSelectButtonClick);
			statSelect.SetString("label", strStatSelect);
			break;
		case('currProfDescription'):
			currProfDescription = GFxClikWidget(Widget);			
			break;
		case('StatMenuTitle'):
			widget.SetText(strStatMenuTitle);
			break;
		default:
			break;
	}

	return true;
}
/** Выбрать */
function OnStatSelectButtonClick(GFxClikWidget.EventData ev)
{

}


/** Закрывает текущую флешку */
function OnBackButtonClick(GFxClikWidget.EventData ev)
{
	Close(false);
	if(KamazHUD!=none)
		KamazHUD.ShowAndPlayMainMenu();
}
/** Проверка на наличие UI текстов в ini-файле */
function checkConfig()
{
	super.checkConfig();
	if (len(strStatSelect) == 0) {
		strStatSelect = "Выбрать";				
		bNeedToSave = true;		
	}	
	
	if (len(strStatMenuTitle) == 0) {
		strStatMenuTitle = "Статистика";				
		bNeedToSave = true;		
	}				
}

DefaultProperties
{	
	bCaptureInput = true;
	WidgetBindings.Add((WidgetName="statBackBtn", WidgetClass=class'GFxClikWidget'));
	WidgetBindings.Add((WidgetName="statSelect", WidgetClass=class'GFxClikWidget'));
	WidgetBindings.Add((WidgetName="currProfDescription", WidgetClass=class'GFxClikWidget'));
	MovieInfo=SwfMovie'menu.StatisticsMenu.Statistics';
}
