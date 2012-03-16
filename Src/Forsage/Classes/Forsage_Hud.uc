class Forsage_HUD extends HUD
	dependson(Gorod_EventDispatcher)
	implements(Gorod_EventListener);

/** ������ �� ������ �������� */
var GFxMoviePlayer loadingPlayer;
/** ������ �� ���� */
var Forsage_Menu menu;

function HandleEvent(Gorod_Event evt)
{
	switch(evt.eventType)
	{

	}
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	switch (WorldInfo.NetMode)
	{
		case NM_Standalone:                 // ���� ������ ��� �� ������ ��� �� ��� �� ������������ � �������			
			showLoadingFlash();
			break;
		case NM_ListenServer:               //���������� ���� ������ �� �������
			menu = new class'Forsage_Menu';						
			menu.FG = Forsage_Game(WorldInfo.Game);			
			menu.checkConfig();
			menu.Show();
			break;
	}	
}

/** ���������� ������ �������� */
function showLoadingFlash()
{
	if (loadingPlayer==none)
	{
		loadingPlayer = new class'GFxMoviePlayer';
		loadingPlayer.bAutoPlay = true;
		loadingPlayer.MovieInfo = SwfMovie'menu.LoadingScreen.Loading';
		loadingPlayer.Init();
		loadingPlayer.SetViewScaleMode(SM_ExactFit);
		loadingPlayer.Advance(0);
	}
	else	
		loadingPlayer.Start(false);
}

DefaultProperties
{
}
