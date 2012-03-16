class Kamaz_HUD_ChoiceSettings extends Kamaz_GFxMoviePlayer;

var Kamaz_GFxClikWidget VideoSettingsBtn;
var Kamaz_GFxClikWidget	ControlSettingsBtn;
var Kamaz_GFxClikWidget backFromChoiceBtn;
var Kamaz_GFxClikWidget ChoiceMenuTitle;
var Kamaz_GFxClikWidget itemDescription;

var Kamaz_HUD KamazHUD;
/** strings from ini-file */
var config string strChoiceMenuTitle;
var config string strControlSettingsBtn;
var config string strVideoSettingsBtn;

/******************************************************************/
/** �������� ������ */
var config string controllingOptDesription;
var config string VideoOptDesription;
var config string SettingsMenuGoBackDesription;

var config string currDesription;
/******************************************************************/

//////////������ �� �������� ������
/** ������ �� MoviePlayer � ��������� �������� */
var Kamaz_HUD_VideoSettingsMenu gfxVideoSettingsMenu;

/** ������ �� MoviePlayer �� ������� �������� */
var Kamaz_HUD_ControlSettingsMenu gfxControlSettingsMenu;
////////////////////////////////////



event bool WidgetInitialized (name WidgetName, name WidgetPath, GFxObject Widget) 
{	
	switch (WidgetName) 
	{
		case ('VideoSettingsBtn'):
			VideoSettingsBtn = Kamaz_GFxClikWidget(Widget);			
			VideoSettingsBtn.AddEventListener('CLIK_click', OnVideoSettingsBtn);

			VideoSettingsBtn.AddEventListener('CLIK_rollOver', OnVideoOptBtnRollOver);
			VideoSettingsBtn.AddEventListener('CLIK_rollOut', SetDefaultText);

			VideoSettingsBtn.SetString("label", strVideoSettingsBtn);

			break;
		case ('ControlSettingsBtn'):
			ControlSettingsBtn = Kamaz_GFxClikWidget(Widget);
			ControlSettingsBtn.AddEventListener('CLIK_click', OnControlSettingsBtn);

			ControlSettingsBtn.AddEventListener('CLIK_rollOver', OnControllingOptBtnRollOver);
			ControlSettingsBtn.AddEventListener('CLIK_rollOut', SetDefaultText);


			ControlSettingsBtn.SetString("label", strControlSettingsBtn);			
			break;
		case('backFromChoiceBtn'):
			backFromChoiceBtn = Kamaz_GFxClikWidget(Widget);
			backFromChoiceBtn.AddEventListener('CLIK_click', OnBackFromNetBtn);
			backFromChoiceBtn.AddEventListener('CLIK_rollOver', OnSettingsMenuGoBackBtnRollOver);
			backFromChoiceBtn.AddEventListener('CLIK_rollOut', SetDefaultText);

			backFromChoiceBtn.SetString("label", strBackBtn);
			break;
		case('ChoiceMenuTitle'):
			ChoiceMenuTitle = Kamaz_GFxClikWidget(Widget);
			ChoiceMenuTitle.SetText(strChoiceMenuTitle);
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

function OnVideoSettingsBtn(GFxClikWidget.EventData ev)
{
	nextMovieClass = class'Kamaz_HUD_VideoSettingsMenu';
	Close(false);
}

function OnControlSettingsBtn(GFxClikWidget.EventData ev)
{
	nextMovieClass = class'Kamaz_HUD_ControlSettingsMenu';
	Close(false);
}

function OnBackFromNetBtn(GFxClikWidget.EventData ev)
{
	goBack();
}


event PostWidgetInit()
{
	super.PostWidgetInit();
	

	AddTabWidget(VideoSettingsBtn); 
	AddTabWidget(ControlSettingsBtn); 
	AddTabWidget(backFromChoiceBtn);
	itemDescription.SetBool("editable",false);
	itemDescription.SetText(currDesription);


}
/** �������� �� ������� UI ������� � ini-����� */
function checkConfig()
{
	super.checkConfig();
	if (len(strChoiceMenuTitle) == 0) {
		strChoiceMenuTitle = "���������";				
		bNeedToSave = true;		
	}	

	if (len(strControlSettingsBtn) == 0) {
		strControlSettingsBtn = "��������� ����������";				
		bNeedToSave = true;		
	}	

	if (len(strVideoSettingsBtn) == 0) {
		strVideoSettingsBtn = "��������� �����";				
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
	if(len(currDesription)==0){
		currDesription="�� ���������� � ���� �������� ����� � ���������. �������� ���� �� ������� ���� ";
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
	itemDescription.SetText(currDesription);
}


function OnCleanup()
{
	super.OnCleanup();
	switch(nextMovieClass)
	{
	case class'Kamaz_HUD_VideoSettingsMenu':
		if(gfxVideoSettingsMenu==none)
		{
			gfxVideoSettingsMenu = new class'Kamaz_HUD_VideoSettingsMenu';
			gfxVideoSettingsMenu.ownerMovie = self;
			gfxVideoSettingsMenu.checkConfig();
			gfxVideoSettingsMenu.Init();
		}
		else
		{
			gfxVideoSettingsMenu.Start(false);
		}
		break;
	case class'Kamaz_HUD_ControlSettingsMenu':
		if(gfxControlSettingsMenu==none)
		{
			gfxControlSettingsMenu = new class'Kamaz_HUD_ControlSettingsMenu';
			gfxControlSettingsMenu.ownerMovie = self;
			gfxControlSettingsMenu.checkConfig();
			gfxControlSettingsMenu.Init();
		}
		else
		{
			gfxControlSettingsMenu.Start(false);
		}

		break;
	default:
		break;

	}
}
DefaultProperties
{
	MovieInfo = SwfMovie'menu.ChoiceSettingsScreen';
	WidgetBindings.Add((WidgetName="VideoSettingsBtn", WidgetClass=class'Kamaz_GFxClikWidget'))
	WidgetBindings.Add((WidgetName="ControlSettingsBtn", WidgetClass=class'Kamaz_GFxClikWidget'))
	WidgetBindings.Add((WidgetName="backFromChoiceBtn", WidgetClass=class'Kamaz_GFxClikWidget'))
	WidgetBindings.Add((WidgetName="ChoiceMenuTitle", WidgetClass=class'Kamaz_GFxClikWidget'))
	WidgetBindings.Add((WidgetName="itemDescription", WidgetClass=class'Kamaz_GFxClikWidget'))
}
