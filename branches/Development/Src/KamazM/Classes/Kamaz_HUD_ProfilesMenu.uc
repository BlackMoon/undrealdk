class Kamaz_HUD_ProfilesMenu extends Kamaz_GFxMoviePlayer dependsOn(Kamaz_ProfileSettings);

var Kamaz_HUD KamazHUD;
var GFxClikWidget btnBack;
var GFxClikWidget listProf;

var GFxClikWidget NetDescription;
var GFxClikWidget profStatBtn;
var GFxClikWidget txtProfileName;
var GFxClikWidget profCreateBtn;
var GFxClikWidget profDeleteBtn;
var GFxClikWidget profSelectBtn;
var GFxClikWidget ProfilesMenuTitle;

var Kamaz_ProfileSettings Profile;
var Kamaz_ControllerSaveSystem SaveSystem;
/** strings from ini-file */
var config string strNetDescription;

var config string strProfStatBtn;
var config string strProfCreateBtn;
var config string strProfDeleteBtn;
var config string strProfSelectBtn;
var config string strProfilesMenuTitle;
var config string strNewProftextField;

function bool Start(optional bool StartPaused = false) 
{
	super.Start(StartPaused);
	Advance(0);
	return true;
}
event bool WidgetInitialized (name WidgetName, name WidgetPath, GFxObject Widget) 
{
	switch(WidgetName)
	{
		case('profBackBtn'):
			btnBack = GFxClikWidget(Widget);
			btnBack.AddEventListener('CLIK_click', OnBackButtonClick);
			btnBack.SetString("label", strBackBtn);
			break;
		case('NetDescription'):
			NetDescription = GFxClikWidget(Widget);
			NetDescription.SetText(strNetDescription);			
			break;
		case('profStatBtn'):
			profStatBtn = GFxClikWidget(Widget);
			profStatBtn.AddEventListener('CLIK_click', OnProfStatButtonClick);
			profStatBtn.SetString("label", strProfStatBtn);
			profStatBtn.SetBool("disabled",true);
			break;
		case('txtProfileName'):
			txtProfileName = GFxClikWidget(Widget);
			txtProfileName.AddEventListener('CLIK_textChange', OnProfileNameTextChange);
			break;
		case('profCreateBtn'):
			profCreateBtn = GFxClikWidget(Widget);
			profCreateBtn.AddEventListener('CLIK_click', OnCreateButtonClick);
			profCreateBtn.SetString("label", strProfCreateBtn);
			break;
		case('profDeleteBtn'):
			profDeleteBtn = GFxClikWidget(Widget);
			profDeleteBtn.AddEventListener('CLIK_click', OnProfDeleteButtonClick);
			profDeleteBtn.SetString("label", strProfDeleteBtn);
			break;
		case('profSelectBtn'):
			profSelectBtn = GFxClikWidget(Widget);
			profSelectBtn.AddEventListener('CLIK_click', OnProfSelectButtonClick);
			profSelectBtn.SetString("label", strProfSelectBtn);
			break;
		case('listProfile'):
			listProf = GFxClikWidget(Widget);
			listProf.AddEventListener('CLIK_itemClick', OnListItemClick);
			break;
		case('ProfilesMenuTitle'):
			ProfilesMenuTitle = GFxClikWidget(Widget);
			ProfilesMenuTitle.SetText(strProfilesMenuTitle);
			break;	
		case('newProftextField'):
			widget.SetText(strNewProftextField);
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
/** Инициализровать компоненты */
function InitializeClickComponent()
{
	local ASValue val;
	local ASValue MaxChars;
	local Kamaz_PlayerController PC;
	PC = Kamaz_PlayerController( GetPC());
	if(PC==none)
		return;

	SaveSystem = PC.SaveSystem;
	Profile = SaveSystem.Profile;
	val.n = 0;
	val.Type = AS_Number;
	listProf.Set("selectedIndex",val);
	RefreshProfilesList();
	profCreateBtn.SetText("");
	//profCreateBtn.
	profCreateBtn.SetBool("disabled",true);

	MaxChars.n=20;
	MaxChars.Type = AS_Number;
	txtProfileName.Set("maxChars",MaxChars);
	//убрать позже

	ProfilesMenuTitle.SetText(SaveSystem.GetActiveProfileName());

	NetDescription.SetBool("editable",false);


	ClickControlToggle(0);
}

/** Показать статистику */
function OnProfStatButtonClick(GFxClikWidget.EventData ev)
{
	`log("нажата");
}
/** Создать профиль */
function OnCreateButtonClick(GFxClikWidget.EventData ev)
{
	local string profileName;
	profileName = txtProfileName.GetText();
	if(profileName!="")
	{
		SaveSystem.createProfile(profileName);
		SaveSystem.saveProfile();
		txtProfileName.SetText("");
		profCreateBtn.SetBool("disabled", true);
		RefreshProfilesList();
		ProfilesMenuTitle.SetText(SaveSystem.GetActiveProfileName());
	}
}
/** Удалить профиль*/
function OnProfDeleteButtonClick(GFxClikWidget.EventData ev)
{
	local ASValue val;
	if(listProf!=none)
	{
		val = listProf.Get("selectedIndex");

		if(val.n >=0 && val.n <= Profile.sProf.Length-1)
		{
			if(SaveSystem.DeleteProfile(Profile.sProf[val.n].ProfileName))
			{
				RefreshProfilesList();  
				SaveSystem.saveProfile();
				val.n-=1;
				listProf.Set("selectedIndex",val);
				ClickControlToggle(val.n);
			}
		}

	}

}
/** Выбрать профиль*/
function OnProfSelectButtonClick(GFxClikWidget.EventData ev)
{
	local ASValue val;
	if(listProf!=none)
	{
		val = listProf.Get("selectedIndex");

		if(val.n >=0 && val.n <= Profile.sProf.Length-1)
		{
			if(	SaveSystem.ChangeActiveProfile(Profile.sProf[val.n].ProfileName ) )
			{
				RefreshProfilesList();  
				//поменять имя активного профиля
				ClickControlToggle(val.n);
			}
		}
	}
	ProfilesMenuTitle.SetText(SaveSystem.GetActiveProfileName());
}
function RefreshProfilesList()
{
	local GFxObject DataProvider;
	local GFxObject TempObj;
	local structProf prof;

	local int i;
    DataProvider = CreateArray();
	if(listProf!=none)
	{
		foreach Profile.sProf(prof,i)
		{
			TempObj =  CreateObject("Object");
			TempObj.SetString("label", prof.ProfileName);
			DataProvider.SetElementObject(i,TempObj);
		}

		listProf.SetObject("dataProvider", DataProvider);
	}
	else
	{
		`warn("InitializeProfilesList , listProf=none");
	}

}

function OnListItemClick(GFxClikWidget.EventData ev)
{
	ClickControlToggle(ev.index);
}
/** Ппереключает активные контролы */
function ClickControlToggle(int selectedIndex)
{
	if(selectedIndex <0 || selectedIndex >= Profile.sProf.Length)
	{
		profStatBtn.SetBool("disabled",true);
		profDeleteBtn.SetBool("disabled",true);
		profSelectBtn.SetBool("disabled",true);
	}
	else
	{
		//profStatBtn.SetBool("disabled",false);
		//нельзя удалять и активировать активный профиль
		if(selectedIndex == SaveSystem.GetActiveProfile())
		{
			profDeleteBtn.SetBool("disabled",true);
			profSelectBtn.SetBool("disabled",true);
		}
		else
		{
			profDeleteBtn.SetBool("disabled",false);
			profSelectBtn.SetBool("disabled",false);
		}
	}
}

function OnProfileNameTextChange(GFxClikWidget.EventData ev)
{
	local string profileName;
	profileName = txtProfileName.GetText();
	profileName -= " ";
	profileName -= ":";
	profileName -= "/";
	profileName -= "-";

	txtProfileName.SetText(profileName);
	if(profileName=="" || SaveSystem.bIsProfileExist(profileName))
	{
		profCreateBtn.SetBool("disabled",true);
	}
	else
	{
		profCreateBtn.SetBool("disabled",false);
	}
}

function OnBackButtonClick(GFxClikWidget.EventData ev)
{
	//Close(false);
	//if(GorodHud!=none)
	//	GorodHud.ShowAndPlayMainMenu();
	goBack();
}

/** Проверка на наличие UI текстов в ini-файле */
function checkConfig()
{	
	super.checkConfig();
	if (len(strNetDescription) == 0) {
		strNetDescription = "Баллы:\\n Штрафы: ";				
		bNeedToSave = true;		
	}	

	if (len(strProfStatBtn) == 0) {
		strProfStatBtn = "Статистика";				
		bNeedToSave = true;		
	}	

	if (len(strProfCreateBtn) == 0) {
		strProfCreateBtn = "Добавить";				
		bNeedToSave = true;		
	}

	if (len(strProfDeleteBtn) == 0) {
		strProfDeleteBtn = "Удалить";				
		bNeedToSave = true;		
	}

	if (len(strProfilesMenuTitle) == 0) {
		strProfilesMenuTitle = "Профили";				
		bNeedToSave = true;		
	}

	if (len(strNewProftextField) == 0) {
		strNewProftextField = "Новый профиль:";				
		bNeedToSave = true;		
	}

	if  (len(strProfSelectBtn) == 0) {
		strProfSelectBtn = "Выбрать";
		bNeedToSave = true;
	}

	if (len(strProfStatBtn) == 0) {
		strProfStatBtn = "Статистика";				
		bNeedToSave = true;		
	}	
}

DefaultProperties
{
	bCaptureInput = true;
	WidgetBindings.Add((WidgetName="profBackBtn", WidgetClass=class'GFxClikWidget'));
	WidgetBindings.Add((WidgetName="listProfile", WidgetClass=class'GFxClikWidget'));

	WidgetBindings.Add((WidgetName="NetDescription", WidgetClass=class'GFxClikWidget'));
	WidgetBindings.Add((WidgetName="profStatBtn", WidgetClass=class'GFxClikWidget'));
	WidgetBindings.Add((WidgetName="txtProfileName", WidgetClass=class'GFxClikWidget'));
	WidgetBindings.Add((WidgetName="profCreateBtn", WidgetClass=class'GFxClikWidget'));
	WidgetBindings.Add((WidgetName="profDeleteBtn", WidgetClass=class'GFxClikWidget'));
	WidgetBindings.Add((WidgetName="profSelectBtn", WidgetClass=class'GFxClikWidget'));
	WidgetBindings.Add((WidgetName="ProfilesMenuTitle", WidgetClass=class'GFxClikWidget'));


	MovieInfo=SwfMovie'menu.ProfilesMenu.Profiles';
}
