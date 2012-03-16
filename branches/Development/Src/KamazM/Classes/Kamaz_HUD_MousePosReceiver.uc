class Kamaz_HUD_MousePosReceiver extends GFxMoviePlayer;

/**
 * Called from PostBeginPlay() to init movie
 */
function bool Start(optional bool StartPaused = false)
{
	//Start and load the SWF Movie
	if(super.Start(StartPaused))
	{
		Advance(0.f);

		SetViewScaleMode(SM_NoScale);
		//SetViewScaleMode(SM_ExactFit);
		//SetViewScaleMode(SM_ShowAll);
		//SetViewScaleMode(SM_NoBorder);
		SetAlignment(Align_TopLeft);
		return true;
	}
	else
		return false;
}

event OnClose()
{
	`log("MousePos: OnClose: close ending");
	super.OnClose();
}

function OnMouseButtonUp()
{
	`log("MouseGetter.OnMouseButtonUp: X = " @ getMouseX() @ " Y = " @ getMouseY());
}

function int getMouseX()
{
	return ActionScriptInt("getMouseX");
}

function int getMouseY()
{
	return ActionScriptInt("getMouseY");
}

function int getWidth()
{
	return ActionScriptInt("getWidth");
}

function int getHeight()
{
	return ActionScriptInt("getHeight");
}

function int getPosX()
{
	return ActionScriptInt("getPosX");
}

function int getPosY()
{
	return ActionScriptInt("getPosY");
}

function ShowMouseCursor(bool showCur)
{
	ActionScriptVoid("showMouseCursor");
}

DefaultProperties
{
	// Load flash
	MovieInfo=SwfMovie'GorodHUD.MouseReceiver.MouseReceiver'
}