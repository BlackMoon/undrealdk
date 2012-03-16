class Kamaz_GFxMoviePlayer extends GFxMoviePlayer abstract config(Gorod_UIText);

var array<GFxClikWidget> TabWidgets;
var  GFxClikWidget focusedWidget;
/** strings from ini-file */
var config protected string strBackBtn;
/** Требуется ли сохранение во внешний ini-файл */
var protected bool bNeedToSave;

var Kamaz_GFxMoviePlayer ownerMovie;
var class<Kamaz_GFxMoviePlayer> nextMovieClass;

function bool Start(optional bool StartPaused)
{
	if(!bMovieIsOpen)
	{
		return super.Start(StartPaused);
	}
	return false;
}

event PostWidgetInit()
{
	super.PostWidgetInit();
	SetAlignment(Align_Center);
	
}
/** Проверка на наличие UI текстов в ini-файле */
function checkConfig()
{
	if (len(strBackBtn) == 0)
	{
		strBackBtn = "Назад";
		bNeedToSave = true;
	}
}

event OnClose()
{
	super.OnClose();
	if (bNeedToSave) save();	
}

function save()
{
	if (bNeedToSave) saveConfig();
}

function ChangeFocus(optional bool reverse = false)
{
	local GFxClikWidget wid;
	local bool bFind;
	local int index;
	local int StepModificator;

	if(TabWidgets.Length < 1)
		return;

	StepModificator = reverse? -1:1;

	// ищем контрол с фокусом
	foreach TabWidgets(wid)
	{
		if(wid.GetBool("focused"))
		{
			bFind = true;
			break;
		}

		index++;
	}

	if(bFind)
	{
		if(TabWidgets[index + StepModificator] != none)
		{
			TabWidgets[index + StepModificator].SetBool("focused", true);
		}
		else
		{
			TabWidgets[reverse? TabWidgets.Length-1:0].SetBool("focused", true);
		}
	}
	else
	{
		TabWidgets[reverse? TabWidgets.Length-1:0].SetBool("focused", true);
	}
}

/** Задает фокус следующему элементу. Важно правильно последовательно добавлять элементы в массив.
 *  @param bRevers - следующий или предыдущий */
function focuseNext(optional bool bRevese = false )
{
	ChangeFocus(bRevese);
	/*
	local GFxClikWidget TabWidget;
	
	local int idx;
	local int nextIdx;

	idx = 0;

	foreach TabWidgets(TabWidget, idx)
	{
		if(TabWidget.GetBool("focused"))
		{
			if(!bRevese)
			{
				if( idx == TabWidgets.Length-1)
				{
					nextIdx=0;
				}
				else
				{
					nextIdx = ++idx;
				}
			}
			else
			{
				if(idx == 0)
				{
					nextIdx=TabWidgets.Length-1;
				}
				else
				{
					nextIdx = --idx;
				}
			}
			TabWidgets[nextIdx].SetBool("focused",true);
			break;

		}
	}*/

}
function pressButton()
{
	local GFxClikWidget TabWidget;
	
	local Kamaz_GFxClikWidget widg;
	local int idx;



	idx = 0;
	foreach TabWidgets(TabWidget, idx)
	{
		if(TabWidget.GetBool("focused"))
		{
			widg= Kamaz_GFxClikWidget(TabWidget);
			if( widg!=none)
				widg.Press();
		}
	}

}
function AddTabWidget(GFxClikWidget pl)
{
	if(pl !=none)
		TabWidgets.AddItem(pl);
}

function Gorod_CloseMenu() 
{
	local GFxClikWidget widget;
	bCaptureInput = false;
	foreach TabWidgets(widget)
	{
		widget.SetBool("visible",false);
	}

}

/** bool function SetText(string objName, coerce string message) - (string objName - имя объекта) поменять текст у выбранного объекта. Возможны 2 варианта GFXWidget (текстовое поле и button/label), поэтому внутри должна быть проверка. При отсутвии GFXWidget выдает false */
function bool SetText(string objName, coerce string message)
{

	local GFxObject obj;
	obj =  GetVariableObject(objName);
	if(obj !=none)
	{
		obj.SetString("label", message);
		
		if(obj.GetString("label") == message)
			return true;
		else
			obj.SetText(message);
		return true;
	}
	return false;
}

/** enable/disable GFXWidget, false при отсутсвии GFXWidget */
function bool SetEnable(string objName, bool bEnable)
{
	local GFxObject obj;
	obj =  GetVariableObject(objName);
	if(obj !=none)
	{
		obj.SetBool("disabled",!bEnable);
		return true;
	}
	return false;
}
function OnCleanup()
{
	`log("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"@self.Name);
	`Entry();
	`Exit();
	super.OnCleanup();

}
function goBack()
{
	nextMovieClass = none;

	if(ownerMovie!=none)
	{
		ownerMovie.ShowFormChild(self);
	}
}
function ShowFormChild(Kamaz_GFxMoviePlayer childPlayer)
{
	childPlayer.Close(false);
	self.Start(false);
}
event bool WidgetUnloaded(name WidgetName, name WidgetPath, GFxObject Widget)
{
	`Entry();

	//SetExternalTexture("",none);
	return super.WidgetUnloaded( WidgetName,  WidgetPath,  Widget);
	`Exit();

}
DefaultProperties
{
	//RenderTexture = TextureRenderTarget2D'Gorod_Effects.PostProcess.FlashRenderTarget';
	bNeedToSave = false;
	RenderTextureMode = RTM_Alpha
	bAutoPlay = true;
	//RTM_Opaque
	//RTM_Alpha
	//RTM_AlphaComposite
}
