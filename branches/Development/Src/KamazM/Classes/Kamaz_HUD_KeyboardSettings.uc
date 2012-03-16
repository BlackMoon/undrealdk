class Kamaz_HUD_KeyboardSettings extends Kamaz_GFxMoviePlayer
	config(ControlSettingsMenu);

var Kamaz_GFxClikWidget ControlSettingsKeyBoardBackBtn;

////���� �� ������������
//var Kamaz_GFxClikWidget OkKeyboardSettingsBtn;
var Kamaz_GFxClikWidget keyBoardSettingsTextArea;
var Kamaz_HUD KamazHUD;
var config array<string> KeyboardTxt;
/** strings from ini-file */
var config string strKeyBoardSettingsMenuTitle;

event bool WidgetInitialized (name WidgetName, name WidgetPath, GFxObject Widget) 
{
	local string KeyboardString;
	local string Str;
	// ��������� ������������ ��������� 
	switch(WidgetName)
	{
		case('ControlSettingsKeyBoardBackBtn'):
			ControlSettingsKeyBoardBackBtn = Kamaz_GFxClikWidget(Widget);
			ControlSettingsKeyBoardBackBtn.AddEventListener('CLIK_click', OnControlSettingsKeyBoardBackBtn);
			ControlSettingsKeyBoardBackBtn.SetString("label", strBackBtn);
			break;
		////���� �� �����������
		//case('OkKeyboardSettingsBtn'):
		//	OkKeyboardSettingsBtn = Kamaz_GFxClikWidget(Widget);
		//	OkKeyboardSettingsBtn.AddEventListener('CLIK_click', OnOkKeyboardSettingsBtn);
		//	break;
		case('keyBoardSettingsTextArea'):
			foreach KeyboardTxt(KeyboardString)
			{
				Str @=KeyboardString;
				Str @="\n";
			}
			keyBoardSettingsTextArea = Kamaz_GFxClikWidget(Widget);
			keyBoardSettingsTextArea.SetText(Str);
			break;
		case('KeyBoardSettingsMenuTitle'):
			widget.SetText(strKeyBoardSettingsMenuTitle);
			break;
		default:
			break;
	}

	return true;
}


function OnControlSettingsKeyBoardBackBtn(GFxClikWidget.EventData ev)
{
	goBack();
	//Close(false);
	//if(KamazHUD!=none)
	//	KamazHUD.ShowControlSettingsMenu();
}
////���� �� �������������
//function OnOkKeyboardSettingsBtn(GFxClikWidget.EventData ev)
//{
	
//}
event PostWidgetInit()
{
	super.PostWidgetInit();
	AddTabWidget(ControlSettingsKeyBoardBackBtn); 
	////���� �� �����������
	//AddTabWidget(OkKeyboardSettingsBtn);
	if(ControlSettingsKeyBoardBackBtn!=none)
		ControlSettingsKeyBoardBackBtn.SetBool("focused",true);

	keyBoardSettingsTextArea.SetBool("editable",false);
}
/** �������� �� ������� UI ������� � ini-����� */
function checkConfig()
{	
	super.checkConfig();
	if (len(strKeyBoardSettingsMenuTitle) == 0) {
		strKeyBoardSettingsMenuTitle = "���������� �����������";				
		bNeedToSave = true;		
	}				
}
DefaultProperties
{
	MovieInfo = SwfMovie'menu.ControlSettingsKeyBoard'
	WidgetBindings.Add((WidgetName="ControlSettingsKeyBoardBackBtn", WidgetClass=class'Kamaz_GFxClikWidget'))
	//WidgetBindings.Add((WidgetName="OkKeyboardSettingsBtn", WidgetClass=class'Kamaz_GFxClikWidget'))
	WidgetBindings.Add((WidgetName="keyBoardSettingsTextArea", WidgetClass=class'Kamaz_GFxClikWidget'));
}
