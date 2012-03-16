/** ���� ����� ������ ������������ ����� ���������� �����, ������� ���������� � ��������, 
 *  ����� ���������� ��������� ����� ��� ���������� ������ � ���������� ���������� ������ */

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
	// ���� ������������ ������ MousePosReceiver`� � ����������� 1920�1080
	MovieInfo=SwfMovie'GorodHUD.MouseReceiver.MouseReceiver'
}