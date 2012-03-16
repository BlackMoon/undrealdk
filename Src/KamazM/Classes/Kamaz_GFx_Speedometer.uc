class Kamaz_GFx_Speedometer extends GFxMoviePlayer;

event bool Start(optional bool StartPaused = false)
{
	local bool Result;
	Result = super.Start(StartPaused);

	Advance(0.f);
    SetViewScaleMode(SM_NoScale);
    SetAlignment(Align_BottomRight);
	return Result;
}

function SetCurrentSpeed(int curSpd)
{
	ActionScriptVoid("setCurrentSpeed");
}

function SetMaxSpeed(float curSpd)
{
	ActionScriptVoid("setMaxSpeed");
}

DefaultProperties
{
	MovieInfo=SwfMovie'GorodHUD.speedometer.speedometer'
}
