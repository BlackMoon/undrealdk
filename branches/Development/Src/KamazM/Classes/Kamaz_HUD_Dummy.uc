/** Этот класс флешки представляет собой прозрачный мувик, который рендерится в текстуру, 
 *  чтобы обеспечить видимость сцены при совместной работе с материалом деформации экрана */

class Kamaz_HUD_Dummy extends Kamaz_GFxMoviePlayer;

function bool Start(optional bool StartPaused = false)
{
	//Start and load the SWF Movie
	if(super.Start(StartPaused))
	{
		Advance(0.f);
		SetViewScaleMode(SM_NoScale);
		SetAlignment(Align_TopLeft);
		return true;
	}
	else
		return false;
}

DefaultProperties
{
	// пока используется флешка MousePosReceiver`а с разрешением 1920х1080
	MovieInfo=SwfMovie'GorodHUD.MouseReceiver.MouseReceiver'
}