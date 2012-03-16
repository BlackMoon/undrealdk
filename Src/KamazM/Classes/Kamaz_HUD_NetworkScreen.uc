class Kamaz_HUD_NetworkScreen extends Kamaz_GFxMoviePlayer;

var Kamaz_GFxClikWidget btnCreateServer;
var Kamaz_GFxClikWidget	btnConnectToServer;
var Kamaz_GFxClikWidget servBackBtn;
var Kamaz_HUD KamazHUD;
// strings from ini-file
var config string strBtnCreateServer;
var config string strBtnConnectToServer;
var config string strDrvMenuTitle;

//////////������ �� �������� ������

/** ������ �� MoviePlayer � ��������� ������� */
var Kamaz_HUD_CreateServMenu gfxCreateServMenu;
/** ������ �� MoviePlayer � ������� �������� */
var Kamaz_HUD_ConnectToServMenu gfxConnectToServMenu;
////////////////////////////////////


event bool WidgetInitialized (name WidgetName, name WidgetPath, GFxObject Widget) 
{	
	switch (WidgetName) 
	{
		case ('btnCreateServer'):
			btnCreateServer = Kamaz_GFxClikWidget(Widget);
			btnCreateServer.AddEventListener('CLIK_click', OnbtnCreateServer);
			btnCreateServer.SetString("label", strBtnCreateServer);
			break;
		case ('btnConnectToServer'):
			btnConnectToServer = Kamaz_GFxClikWidget(Widget);
			btnConnectToServer.AddEventListener('CLIK_click', OnbtnConnectToServer);
			btnConnectToServer.SetString("local", strBtnConnectToServer);
			break;
		case('servBackBtn'):
			servBackBtn = Kamaz_GFxClikWidget(Widget);
			servBackBtn.AddEventListener('CLIK_click', OnservBackBtn);
			servBackBtn.SetString("label", strBackBtn);
			break;
		case('DrvMenuTitle'):
			widget.SetText(strDrvMenuTitle);
			break;
		default:
			break;
	}

	return true;
}
///** ����������� ������ *///

function OnbtnCreateServer(GFxClikWidget.EventData ev)
{
	nextMovieClass = class'Kamaz_HUD_CreateServMenu';
	Close(false);
}

function OnbtnConnectToServer(GFxClikWidget.EventData ev)
{
	nextMovieClass = class'Kamaz_HUD_ConnectToServMenu';
	Close(false);

}

function OnservBackBtn(GFxClikWidget.EventData ev)
{
	goBack();
}


event PostWidgetInit()
{
	super.PostWidgetInit();
	

	AddTabWidget(btnCreateServer); 
	AddTabWidget(btnConnectToServer); 
	AddTabWidget(servBackBtn);
	if(btnCreateServer!=none)
		btnCreateServer.SetBool("focused",true);
}

/** �������� �� ������� UI ������� � ini-����� */
function checkConfig()
{
	super.checkConfig();
	if (len(strBtnCreateServer) == 0) {
		strBtnCreateServer = "��������";				
		bNeedToSave = true;		
	}	

	if (len(strDrvMenuTitle) == 0) {
		strDrvMenuTitle = "��������";				
		bNeedToSave = true;		
	}		

	if (len(strBtnConnectToServer) == 0) {
		strBtnConnectToServer = "��������� ���� �� ������";				
		bNeedToSave = true;		
	}				
}
function OnCleanup()
{
	super.OnCleanup();
	switch(nextMovieClass)
	{
	case class'Kamaz_HUD_CreateServMenu':
		if(gfxCreateServMenu==none)
		{
			gfxCreateServMenu = new class'Kamaz_HUD_CreateServMenu';
			gfxCreateServMenu.ownerMovie = self;
			gfxCreateServMenu.checkConfig();
			gfxCreateServMenu.Init();
		}
		else
		{
			gfxCreateServMenu.Start(false);
		}
		break;
	case class'Kamaz_HUD_ConnectToServMenu':
		if(gfxConnectToServMenu==none)
		{
			gfxConnectToServMenu = new class'Kamaz_HUD_ConnectToServMenu';
			gfxConnectToServMenu.ownerMovie = self;
			gfxConnectToServMenu.checkConfig();
			gfxConnectToServMenu.Init();
		}
		else
		{
			gfxConnectToServMenu.Start(false);
		}

		break;
	default:
		break;
	}
}
DefaultProperties
{
	MovieInfo = SwfMovie'menu.NetworkScreen'
	WidgetBindings.Add((WidgetName="btnCreateServer", WidgetClass=class'Kamaz_GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnConnectToServer", WidgetClass=class'Kamaz_GFxClikWidget'))
	WidgetBindings.Add((WidgetName="servBackBtn", WidgetClass=class'Kamaz_GFxClikWidget'))
}
