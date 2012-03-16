class Kamaz_HUD_NetAndLocalScreen extends Kamaz_GFxMoviePlayer;

var Kamaz_GFxClikWidget SelectLocalDrvBtn;
var Kamaz_GFxClikWidget	selectNetworkDrvBtn;
var Kamaz_GFxClikWidget BackFromNetBtn;
var Kamaz_GFxClikWidget itemDescription;
var Kamaz_HUD KamazHUD;
// strings from ini-file
var config string strSelectLocalDrvBtn;
var config string strSelectNetworkDrvBtn;
var config string strLocalAndNetMenuTitle;

/******************************************************************/
/** Описания кнопок */
var config string SelectLocalDrvDesription;
var config string selectNetworkDrvDesription;
var config string BackFromNetBtnDesription;

var config string currDesription;
/******************************************************************/

//////////ссылки на дочерние флешки
/** Вождение локально*/
var Kamaz_HUD_drvScreen gfxdrvScreen;
/** Вождение по сети*/
var Kamaz_HUD_NetworkScreen gfxNetworkScreen;
///////////////////////////////////


event bool WidgetInitialized (name WidgetName, name WidgetPath, GFxObject Widget) 
{
	switch (WidgetName) 
	{
		case ('SelectLocalDrvBtn'):
			SelectLocalDrvBtn = Kamaz_GFxClikWidget(Widget);
			SelectLocalDrvBtn.AddEventListener('CLIK_click', OnSelectLocalDrvBtn);

			SelectLocalDrvBtn.AddEventListener('CLIK_rollOver', OnSelectLocalDrvRollOver);
			SelectLocalDrvBtn.AddEventListener('CLIK_rollOut', SetDefaultText);

			SelectLocalDrvBtn.SetString("label", strSelectLocalDrvBtn);
			break;
		case ('selectNetworkDrvBtn'):
			selectNetworkDrvBtn = Kamaz_GFxClikWidget(Widget);
			selectNetworkDrvBtn.AddEventListener('CLIK_click', OnselectNetworkDrvBtn);
			selectNetworkDrvBtn.AddEventListener('CLIK_rollOver', OnselectNetworkDrvBtnRollOver);
			selectNetworkDrvBtn.AddEventListener('CLIK_rollOut', SetDefaultText);
			//////////////////////////раскомментируй меня////////////////////////////////
			selectNetworkDrvBtn.SetBool("disabled",true);
			/////////////////////////////////////////////////////////////////////////////
			selectNetworkDrvBtn.SetString("label", strSelectNetworkDrvBtn);
			break;
		case('BackFromNetBtn'):
			BackFromNetBtn = Kamaz_GFxClikWidget(Widget);
			BackFromNetBtn.AddEventListener('CLIK_click', OnBackFromNetBtn);
			BackFromNetBtn.AddEventListener('CLIK_rollOver', OnBackFromNetBtnRollOver);
			BackFromNetBtn.AddEventListener('CLIK_rollOut', SetDefaultText);
			BackFromNetBtn.SetString("label", strBackBtn);
			break;
		case('LocalAndNetMenuTitle'):
			widget.SetText(strLocalAndNetMenuTitle);
			break;
		case('itemDescription'):
			itemDescription = Kamaz_GFxClikWidget(Widget);
			break;

		default:
			break;
	}

	return true;
}
///** обработчики кнопок *///

function OnSelectLocalDrvBtn(GFxClikWidget.EventData ev)
{
	nextMovieClass = class'Kamaz_HUD_drvScreen';
	Close(false);
}

function OnselectNetworkDrvBtn(GFxClikWidget.EventData ev)
{
	nextMovieClass = class'Kamaz_HUD_NetworkScreen';
	Close(false);
}

function OnBackFromNetBtn(GFxClikWidget.EventData ev)
{
	goBack();
}
//////////////////////наведение мыши
function OnSelectLocalDrvRollOver(GFxClikWidget.EventData ev)
{
	itemDescription.SetText(SelectLocalDrvDesription);

}
function OnselectNetworkDrvBtnRollOver(GFxClikWidget.EventData ev)
{
	itemDescription.SetText(selectNetworkDrvDesription);
	
}

function OnBackFromNetBtnRollOver(GFxClikWidget.EventData ev)
{
	itemDescription.SetText(BackFromNetBtnDesription);
	
}

function SetDefaultText(GFxClikWidget.EventData ev)
{
	itemDescription.SetText(currDesription);
}
event PostWidgetInit()
{
	super.PostWidgetInit();
	

	AddTabWidget(SelectLocalDrvBtn); 
	AddTabWidget(selectNetworkDrvBtn); 
	AddTabWidget(BackFromNetBtn);
	itemDescription.SetBool("editable",false);
	itemDescription.SetText(currDesription);

}

/** Проверка на наличие UI текстов в ini-файле */
function checkConfig()
{
	super.checkConfig();
	if (len(strSelectLocalDrvBtn) == 0) {
		strSelectLocalDrvBtn = "Одиночное вождение";				
		bNeedToSave = true;		
	}	

	if (len(strSelectNetworkDrvBtn) == 0) {
		strSelectNetworkDrvBtn = "Вождение по сети";				
		bNeedToSave = true;		
	}						

	if (len(strLocalAndNetMenuTitle) == 0) {
		strLocalAndNetMenuTitle = "Подключение";
		bNeedToSave = true;
	}
	if (len(SelectLocalDrvDesription) == 0) {
		SelectLocalDrvDesription = "Вождение в одиночном режиме";
		bNeedToSave = true;
	}	
	if (len(selectNetworkDrvDesription) == 0) {
		selectNetworkDrvDesription = "Вождение по сети";
		bNeedToSave = true;
	}	
	if (len(BackFromNetBtnDesription) == 0) {
		BackFromNetBtnDesription = "Возврат в главное меню";
		bNeedToSave = true;
	}
	if(len(currDesription)==0){
		currDesription="Вождение автомобилем. Обучение и проверка навыка вождения ТС. Выберите режим вождения.";
		bNeedToSave = true;	
	}

}
function OnCleanup()
{
	super.OnCleanup();
	switch(nextMovieClass)
	{
	case class'Kamaz_HUD_drvScreen':
		if(gfxdrvScreen==none)
		{
			gfxdrvScreen = new class'Kamaz_HUD_drvScreen';
			gfxdrvScreen.ownerMovie = self;
			gfxdrvScreen.checkConfig();
			gfxdrvScreen.Init();
		}
		else
		{
			gfxdrvScreen.Start(false);
		}
		break;
	case class'Kamaz_HUD_NetworkScreen':
		if(gfxNetworkScreen==none)
		{
			gfxNetworkScreen = new class'Kamaz_HUD_NetworkScreen';
			gfxNetworkScreen.ownerMovie = self;
			gfxNetworkScreen.checkConfig();
			gfxNetworkScreen.Init();
		}
		else
		{
			gfxNetworkScreen.Start(false);
		}

		break;
	default:
		break;
	}
}
DefaultProperties
{
	MovieInfo = SwfMovie'menu.NetAndLocalScreen';
	WidgetBindings.Add((WidgetName="SelectLocalDrvBtn", WidgetClass=class'Kamaz_GFxClikWidget'))
	WidgetBindings.Add((WidgetName="selectNetworkDrvBtn", WidgetClass=class'Kamaz_GFxClikWidget'))
	WidgetBindings.Add((WidgetName="BackFromNetBtn", WidgetClass=class'Kamaz_GFxClikWidget'))
	WidgetBindings.Add((WidgetName="itemDescription", WidgetClass=class'Kamaz_GFxClikWidget'))
}
