class Kamaz_HUD extends UDKHUD dependson (Gorod_EventDispatcher,Gorod_BaseMessages) implements(Gorod_EventListener);

var bool bShowMainMenu;
var Kamaz_PlayerController objPC;

/**
 * Ссылка на MoviePlayer с главным меню
 */
var Kamaz_HUD_MainMenu  gfxMainMenu;

/** Ссылка на MoviePlayer со списком упражнений */
var Kamaz_ExerciseList gfxExerciseList;

///** Ссылка на MoviePlayer с списком серверов */
//var Gorod_HUD_ConnectToServMenu gfxConnectToServMenu;

///** Ссылка на MoviePlayer с созданием сервера */
//var Gorod_HUD_CreateServMenu gfxCreateServMenu;




/** Ссылка на MoviePlayer с игровым меню */
var Kamaz_HUD_GameMenu gfxGameMenu;

/** Ссылка на MoviePlayer со статистикой */
var Kamaz_HUD_StatisticsMenu gfxStatisticsMenu;



/** Ссылка на MoviePlayer с калибровкой тренажера */
var Kamaz_HUD_Calibration gfxTrainingStationCalibrationMenu;

var Kamaz_HUD_SettingsScreen gfxSettingsScreen;

var Kamaz_HUD_Results HUD_Results;

var Kamaz_HUD_Dummy gfxDummyFlash;

var Kamaz_HUD_ScreenCalibration scrCalibrationMovie;

var Kamaz_HUD_CinematicModeMenu gfxCinematicModeMenu;

var array<GFxMoviePlayer> MoviePlayers;

var bool bIsMenuOpened;

/**
 * Ссылка на MoviePlayer с упражнением (одна флэшка, которая работает по-разному в зависимости от выбранного конкретного упражнения)
 */
var Kamaz_CommonExercise gfxCommonExercise;
/** Переменная для отладки */
var bool bShowBotNames;

var array<Actor> Objects;

var MU_Minimap GameMinimap;
var Float TileSize;
var Int MapDim;
var Int BoxSize;
var Color PlayerColors[3];
var vector2d MapPosition;

/** Holds the full width and height of the viewport */
var float FullWidth, FullHeight;
/** Holds the scaling factor given the current resolution.  This is calculated in PostRender() */
var float ResolutionScale, ResolutionScaleX;

/** подгруженная карта*/
var string URLMap;

/** Деформация экрана */
var Gorod_PostProcessDeformationController DeformController;

var bool bwithEditor;

enum ExerciseShowTypes
{
	EST_Current,
	EST_Next,
	EST_Prev
};

var ExerciseShowTypes ExerciseShowType;

/**
 * true - если запускаем список упражнений в первый раз
 */
var bool bFirstTime;
/** подписались ли на события */
var bool bRegistred;

function GetAndShowMinimap()
{
	local MU_Minimap ThisMinimap;

	if(GameMinimap==none)
	{
		foreach AllActors(class'MU_Minimap',ThisMinimap)
		{
			GameMinimap = ThisMinimap;
			break;
		}
	}
}
function RegisterInListeners(Kamaz_PlayerController kamazPC)
{
	`warn("objPC=none", kamazPC==none);
	if(kamazPC==none)
		return;

	`warn("gorodPC.EventDispatcher=none", kamazPC.EventDispatcher==none);

	if(kamazPC.EventDispatcher==none)
		return;
	kamazPC.EventDispatcher.RegisterListener(self, GOROD_EVENT_QUEST);
}
function HandleEvent(Gorod_Event evt)
{
	local Gorod_ReportEvent ReportEvent;
	ReportEvent=Gorod_ReportEvent(evt);
	if(ReportEvent!=none)
	{
		ShowAndPlayResultsMenu(ReportEvent);
	}
}
function ShowAndPlayResultsMenu(Gorod_ReportEvent ReportEvent)
{
	if(HUD_Results==none) HUD_Results = new class'Kamaz_HUD_Results';
	HUD_Results.checkConfig();
	HUD_Results.CountErrors =  ReportEvent.MsgInfos.Length;
	HUD_Results.CountPoints =  ReportEvent.pointsCount;
	HUD_Results.CountMoney=  ReportEvent.moneyPenaltyCount;
	HUD_Results.CountExercise = ReportEvent.exerciseCount;
	HUD_Results.bIsSuccessReport =  ReportEvent.bSuccess;
	HUD_Results.bShowExcersiseCount = ReportEvent.bShowExcerisesCount;
	HUD_Results.KamazHUD = self;
	HUD_Results.Start();
}
event PostRender()
{
	//для отладки
	local Gorod_AIVehicle vehic;
	local Gorod_HumanBot bot;

	super.PostRender();

	FullWidth = Canvas.ClipX;
	FullHeight = Canvas.ClipY;

	ResolutionScaleX = Canvas.ClipX/1024;
	ResolutionScale = Canvas.ClipY/768;

	//для отладки
	if(bShowBotNames)
	{
		foreach AllActors(class'Gorod_AIVehicle', vehic)
		{
			if(objPC.CanSee(vehic)) 
				vehic.DrawHUD(self);					
		}
		foreach AllActors(class'Gorod_HumanBot', bot)
		{
			if(objPC.CanSee(bot))
				bot.DrawHUD(self);
		}
	}

}

function DrawString(float PosX, float PosY, color DrawColor, string DrawText) 
{
	Canvas.SetPos(PosX, PosY);
	Canvas.DrawColor = DrawColor;
	Canvas.DrawText (DrawText);
}

simulated function PostBeginPlay()
{
	`Entry();
	Super.PostBeginPlay();
	

	//  сохраняем ссылку на PlayerController
	objPC = Kamaz_PlayerController(PlayerOwner);
	
	if (objPC == none)
	{
		`warn("objPC == none");
		return;
	}
	
	URLMap = objPC.GetURLMap();
	`Log("URLMap:"$URLMap);
	
	if(objPC.bIsMenu )	
	{
		Kamaz_Game(WorldInfo.Game).CloseLoadingFlash();
		CreateMenus();
		InitMenus();

		if(URLMap~="City")
		{
			bIsMenuOpened = true;
			gfxMainMenu.Init();
			gfxMainMenu.Start();
			objPC.IgnoreLookInput(true);
			objPC.IgnoreMoveInput(true);
		}

	}

	// инифиализация класса для управления деформацией экрана
	DeformController = Spawn(class'Gorod_PostProcessDeformationController');
	if(DeformController == none)
	{
		`warn("ScreenDeformationController initialization failed");
	}

	`Exit();
}

function CreateMenus()
{
	gfxMainMenu = new class'Kamaz_HUD_MainMenu';
	gfxMainMenu.KamazHUD = self;
	gfxMainMenu.checkConfig();

	MoviePlayers.AddItem(gfxMainMenu);

	gfxExerciseList = new class'Kamaz_ExerciseList';	
	gfxExerciseList.KamazHUD = self;	
	gfxExerciseList.checkConfig();
	bFirstTime = true;
	MoviePlayers.AddItem(gfxExerciseList);

	
	gfxStatisticsMenu = new class'Kamaz_HUD_StatisticsMenu';
	gfxStatisticsMenu.KamazHUD = self;
	gfxStatisticsMenu.checkConfig();
	MoviePlayers.AddItem(gfxStatisticsMenu);

	gfxCommonExercise = new class'Kamaz_CommonExercise';	
	gfxCommonExercise.KamazHUD = self;
	gfxCommonExercise.checkConfig();
	MoviePlayers.AddItem(gfxCommonExercise);

	
	gfxDummyFlash = new class'Kamaz_HUD_Dummy';
	MoviePlayers.AddItem(gfxDummyFlash);
	gfxDummyFlash.Start(false);
}
/** Сохранение текста меню в ini-file */
function saveMenuTexts()
{
//	gfxChoiceSettingsScreen.save();
	gfxCommonExercise.save();
//	gfxConnectToServMenu.save();
//	gfxControlSettingsMenu.save();
//	gfxCreateServMenu.save();				
//	if (gfxdrvScreen != none) gfxdrvScreen.save();

//	gfxExamMenu.save();
	gfxExerciseList.save();	
//	if (gfxFreeDrivingMenu != none) gfxFreeDrivingMenu.save();					

//	gfxKeyboardSettings.save();
	//gfxListPDDTestMenu.save();
	//if (gfxMainMenu != none) gfxMainMenu.save();

	//gfxNetAndLocalScreen.save();
//	gfxNetworkScreen.save();
//	gfxProfilesMenu.save();				

	if (gfxSettingsScreen != none) gfxSettingsScreen.save();
	gfxStatisticsMenu.save();
	
//	if (gfxTrainingMenu != none) gfxTrainingMenu.save();

	if (gfxTrainingStationCalibrationMenu != none) gfxTrainingStationCalibrationMenu.save();
//	gfxVideoSettingsMenu.save();

	if (scrCalibrationMovie != none) scrCalibrationMovie.save();	
}

function InitMenus()
{
	local GFxMoviePlayer mp;
	local array<name> keys;
	keys.AddItem('UP');
	keys.AddItem('DOWN');
	keys.AddItem('LEFT');
	keys.AddItem('RIGHT');

	keys.AddItem('SPACEBAR');
	keys.AddItem('TAB');
	foreach MoviePlayers(mp)
	{
		if(mp!=none)
		{
			mp.bCaptureInput = TRUE;
			mp.CaptureKeys = keys;
			mp.bIgnoreMouseInput = false;
		}
	}
}
exec function ToggleNext()
{
	local GFxMoviePlayer mp;
	local Kamaz_GFxMoviePlayer gmp;

	foreach MoviePlayers(mp)
	{
		gmp = Kamaz_GFxMoviePlayer(mp);
		if(gmp!=none)
		{
			if(gmp.bMovieIsOpen)
				gmp.focuseNext();
		}
	}
}
exec function PressThis()
{
	local GFxMoviePlayer mp;
	local Kamaz_GFxMoviePlayer gmp;
	foreach MoviePlayers(mp)
	{
		gmp = Kamaz_GFxMoviePlayer(mp);
		if(gmp!=none)
		{
			if(gmp.bMovieIsOpen)
				gmp.pressButton();
		}
	}
}
exec function Gorod_ShowMenu() 
{
	`Entry();
	if(gfxMainMenu!=none)
	{
		gfxMainMenu = new class'Kamaz_HUD_MainMenu';
	}
	gfxMainMenu.RenderTexture = none;
	gfxMainMenu.KamazHUD = self;
	gfxMainMenu.bPauseMenu = true;
	gfxMainMenu.Start(true);
	`Exit();
}


/**
 * Проверка, подключён ли игрок к серверу
 */
function bool IsConnected()
{
	return (WorldInfo.NetMode != NM_Standalone);
}

function DrawHUD()
 {
	super.DrawHUD();
	if (GameMinimap != none && !ObjPC.bIsMenu)
		DrawMap();
 }

/**  Показать главное меню */
function ShowAndPlayMainMenu()
{
	if(gfxMainMenu==none)
	{
		gfxMainMenu = new class 'Kamaz_HUD_MainMenu';
		gfxMainMenu.KamazHUD = self;
	}
	gfxMainMenu.Start();
}

 /**
  * Показать главной меню
  */
exec function HUDCloseMenu()
{
	gfxMainMenu.Gorod_CloseMenu();
}
exec function CloseM()
{
	gfxMainMenu.Close(true);
}
function ShowMainMenu()
{
	// закрываем список упражнений или конкретное упражнение (если они были открыты)
	if(gfxExerciseList != none && gfxExerciseList.bMovieIsOpen)
		gfxExerciseList.Close(false);

	if(gfxCommonExercise != none && gfxCommonExercise.bMovieIsOpen)
	{
		// перед тем, как закрывать конкретное упражнение переходим на пустой фрейм,
		// это делается на случай несоответствия списка упражнений в gfxExerciseList и набора упражнений в gfxCommonExercise
		gfxCommonExercise.OpenExercise("NoExercise", "");
		gfxCommonExercise.Close(false);
	}

	// стартуем ролик без проверки на none, потому что gfxMainMenu создаётся и сразу запускается в PostBeginPlay
	gfxMainMenu.Start();
}

/**
 * Показать список упражнений
 */
function ShowExerciseList()
{
	// закрываем главное меню или конкретное упражнение (если они были открыты)
	if(gfxMainMenu != none && gfxMainMenu.bMovieIsOpen)
		gfxMainMenu.Close(false);

	if(gfxCommonExercise != none && gfxCommonExercise.bMovieIsOpen)
	{
		// перед тем, как закрывать конкретное упражнение переходим на пустой фрейм,
		// это делается на случай несоответствия списка упражнений в gfxExerciseList и набора упражнений в gfxCommonExercise
		gfxCommonExercise.OpenExercise("NoExercise", "");
		gfxCommonExercise.Close(false);
	}

	// если gfxExerciseList ещё не создан, то создаём
	if(gfxExerciseList == none)
	{
		gfxExerciseList = new class'Kamaz_ExerciseList';
		gfxExerciseList.KamazHUD = self;
		bFirstTime = true;
	}

	gfxExerciseList.Start();
	
	// инициализируем список упражнений один раз за время жизни gfxExerciseList
	if(bFirstTime)
	{
		bFirstTime = false;
		gfxExerciseList.CreateExerciseList();
	}
}

function MousePos_StartRenderToTexture()
{
	/*gfxDummyFlash.Close(false);
	gfxDummyFlash.RenderTexture = TextureRenderTarget2D'Gorod_Effects.PostProcess.FlashRenderTarget';
	gfxDummyFlash.Start();*/
}

function MousePos_StopRenderToTexture()
{
	/*gfxDummyFlash.Close(false);
	gfxDummyFlash.RenderTexture = none;
	gfxDummyFlash.Start();*/
}

exec function ShowGameMenu()
{
	local Kamaz_Game gg;
	if(bIsMenuOpened)
		return;
	//если в кинематик мод
	if(objPC.bCinematicMode)
	{
		gg = Kamaz_Game(WorldInfo.Game);
		//если еще не создали меню- создаем
		if(gfxCinematicModeMenu==none)
		{
			gfxCinematicModeMenu= new class'Kamaz_HUD_CinematicModeMenu';
			gfxCinematicModeMenu.checkConfig();
		}
		//меню уже было создано
		else
		{   
			//если меню открыто и запущено - снимаем с паузы и закрываем
			if(gfxCinematicModeMenu.bMovieIsOpen)
			{
				if(gg!=none)
					gg.MatineePause();
				gfxCinematicModeMenu.Close(false);
				return;
			}
		}

		//стартуем
		gfxCinematicModeMenu.Start();
		if(gg!=none)
			gg.MatineePause();
		else
			`warn("Gorod_Hud.uc, function ShowGameMenu: game type != Gorod_Game ");
	}
	//если в игре
	else
	{
		if(gfxGameMenu == none)
		{
			gfxGameMenu = new class'Kamaz_HUD_GameMenu';
			gfxGameMenu.checkConfig();
			gfxGameMenu.KamazHUD = self;
			gfxGameMenu.Start();
		}
		else
		{
			if(gfxGameMenu.bMovieIsOpen)
			{
				//gfxGameMenu.
			}
			gfxGameMenu.Start();
			gfxGameMenu.ShowElements();
		}
	}

	//mpr.RenderTexture = none;
	//mpr.Close(false);
	//mpr = none;
	//mpr = new class'Gorod_HUD_MousePosReceiver';
	//mpr.RenderTexture = none;
	//mpr.Start();
		
}

function ShowStatisticsMenu()
{

	// закрываем главное меню
	if(gfxMainMenu != none && gfxMainMenu.bMovieIsOpen)
		gfxMainMenu.Close(false);

	// если обьект ещё не создан, создаём
	if(gfxStatisticsMenu == none)
	{
		gfxStatisticsMenu = new class'Kamaz_HUD_StatisticsMenu';
		gfxStatisticsMenu.checkConfig();
		gfxStatisticsMenu.KamazHUD = self;
	}
	gfxStatisticsMenu.Start();
	
}

function CloseMainMenu()
{
	if(gfxMainMenu != none)
	{
		gfxMainMenu.Close(false);
		gfxMainMenu = none;
	}
}


function ShowSettingsScreen()
{
		// закрываем главное меню
	if(gfxMainMenu != none && gfxMainMenu.bMovieIsOpen)
		gfxMainMenu.Close(false);

	// если обьект ещё не создан, создаём
	if(gfxSettingsScreen == none)
	{
		gfxSettingsScreen = new class'Kamaz_HUD_SettingsScreen';
		gfxSettingsScreen.checkConfig();
		gfxSettingsScreen.KamazHUD = self;
	}
	gfxSettingsScreen.Start();

}



// Закрываем менюшки /
exec function Gorod_CloseMenu() 
{
	`Entry();
	if(gfxMainMenu!=none)
	{
		gfxMainMenu = new class'Kamaz_HUD_MainMenu';
	}
	gfxMainMenu.RenderTexture = none;
	gfxMainMenu.bPauseMenu = true;
	gfxMainMenu.KamazHUD = none;
	gfxMainMenu.Start(true);    
	`Exit();
}

function CloseExerciseList()
{
	if(gfxExerciseList != none)
	{
		gfxExerciseList = new class'Kamaz_ExerciseList';
		gfxExerciseList.RenderTexture= none;
		gfxExerciseList.Start();
	}
}

function CloseStatisticsMenu()
{
	if(gfxStatisticsMenu != none)
	{
		gfxStatisticsMenu = new class'Kamaz_HUD_StatisticsMenu';
		gfxStatisticsMenu.RenderTexture= none;
		gfxStatisticsMenu.Start();
	}

	
}


function CloseSettingsScreen()
{
	// если обьект ещё не создан, создаём
	if(gfxSettingsScreen != none)
	{
		gfxSettingsScreen = new class'Kamaz_HUD_SettingsScreen';
		gfxSettingsScreen.RenderTexture= none;
		gfxSettingsScreen.Start();
	}


}


//////////////////////////////////////////////////////////////////////////////////////////////

/**

 */
function ShowCommonExercise(optional ExerciseShowTypes ExShowType = EST_Current)
{
	local string ExerciseFrame, ExerciseDescription;
	local class<Kamaz_Exercise_Base> ExerciseClass;
	local int RepetitionCount;	

	// закрываем главное меню или список упражнений (если они были открыты)
	if(gfxMainMenu != none && gfxMainMenu.bMovieIsOpen)
		gfxMainMenu.Close(false);

	if(gfxExerciseList != none && gfxExerciseList.bMovieIsOpen)
		gfxExerciseList.Close(false);

	// если gfxCommonExercise ещё не создан, то создаём
	if(gfxCommonExercise == none)
	{		
		gfxCommonExercise = new class'Kamaz_CommonExercise';			
		gfxCommonExercise.KamazHUD = self;
	}

	gfxCommonExercise.Start();
	// Открываем нужное упражнение
	switch(ExShowType)
	{
		case EST_Current:
			if(!gfxExerciseList.GetCurrentExercise(ExerciseFrame, ExerciseClass, ExerciseDescription, RepetitionCount))
				return;
			break;
		case EST_Next:
			if(!gfxExerciseList.GetNextExercise(ExerciseFrame, ExerciseClass, ExerciseDescription, RepetitionCount))
				return;
			break;
		case EST_Prev:
			if(!gfxExerciseList.GetPrevExercise(ExerciseFrame, ExerciseClass, ExerciseDescription, RepetitionCount))
				return;
			break;
	}
	
	gfxCommonExercise.StartExercise(ExerciseFrame, ExerciseClass, ExerciseDescription, RepetitionCount);
}

exec function MapSizeUp()
{
	MapDim *= 2;
	BoxSize *= 2;
}

exec function MapSizeDown()
{
	MapDim /= 2;
	BoxSize /= 2;
}

exec function MapZoomIn()
{
	TileSize = 1.0 / FClamp(Int((1.0 / TileSize) + 1.0) + 0.5,1.5,10.5);
}

exec function MapZoomOut()
{
	TileSize = 1.0 / FClamp(Int((1.0 / TileSize) - 1.0) + 0.5,1.5,10.5);
}

function float GetPlayerHeading()
{
	local Float PlayerHeading;
	local Rotator PlayerRotation;
	local Vector v;

	if (PlayerOwner.Pawn == none)
		return 0;
	PlayerRotation.Yaw = PlayerOwner.Pawn.Rotation.Yaw;
	v = vector(PlayerRotation);
	PlayerHeading = GetHeadingAngle(v);
	PlayerHeading = UnwindHeading(PlayerHeading);

	while (PlayerHeading < 0)
		PlayerHeading += PI * 2.0f;
	
	return PlayerHeading;
}

function DrawMap()
{
	local Float TrueNorth,PlayerHeading;
	local Float MapRotation,CompassRotation;
	local Vector PlayerPos, ClampedPlayerPos, RotPlayerPos, DisplayPlayerPos, StartPos;
	local LinearColor MapOffset;
	local Float ActualMapRange;
	local Controller C;

	if (ResolutionScale == 0)
		return;
	if (PlayerOwner.Pawn == none)
		return;
	//Set MapDim & BoxSize accounting for the current resolution 		
	MapPosition.X = default.MapPosition.X * FullWidth;
	MapPosition.Y = default.MapPosition.Y * FullHeight;
	MapDim = default.MapDim * ResolutionScale;
	BoxSize = default.BoxSize * ResolutionScale;

	//Calculate map range values
	ActualMapRange = FMax(	GameMinimap.MapRangeMax.X - GameMinimap.MapRangeMin.X,
						GameMinimap.MapRangeMax.Y - GameMinimap.MapRangeMin.Y);

	//Calculate normalized player position
	PlayerPos.X = (PlayerOwner.Pawn.Location.Y - GameMinimap.MapCenter.Y) / ActualMapRange;
	PlayerPos.Y = (GameMinimap.MapCenter.X - PlayerOwner.Pawn.Location.X) / ActualMapRange;

	//Calculate clamped player position
	ClampedPlayerPos.X = FClamp(PlayerPos.X,-0.5 + (TileSize / 2.0),0.5 - (TileSize / 2.0));
	ClampedPlayerPos.Y = FClamp(PlayerPos.Y,-0.5 + (TileSize / 2.0),0.5 - (TileSize / 2.0));

	//Get north direction and player's heading
	TrueNorth = GameMinimap.GetRadianHeading();
	Playerheading = GetPlayerHeading();

	//Calculate rotation values
	if(GameMinimap.bForwardAlwaysUp)
	{
		MapRotation = PlayerHeading;
		CompassRotation = PlayerHeading - TrueNorth;
	}
	else
	{
		MapRotation = PlayerHeading - TrueNorth;
		CompassRotation = MapRotation;
	}

	//Calculate position for displaying the player in the map
	DisplayPlayerPos.X = VSize(PlayerPos) * Cos( Atan2(PlayerPos.Y, PlayerPos.X) - MapRotation);
	DisplayPlayerPos.Y = VSize(PlayerPos) * Sin( Atan2(PlayerPos.Y, PlayerPos.X) - MapRotation);

	//Calculate player location after rotation
	RotPlayerPos.X = VSize(ClampedPlayerPos) * Cos( Atan2(ClampedPlayerPos.Y, ClampedPlayerPos.X) - MapRotation);
	RotPlayerPos.Y = VSize(ClampedPlayerPos) * Sin( Atan2(ClampedPlayerPos.Y, ClampedPlayerPos.X) - MapRotation);

	//Calculate upper left UV coordinate
	StartPos.X = FClamp(RotPlayerPos.X + (0.5 - (TileSize / 2.0)),0.0,1.0 - TileSize);
	StartPos.Y = FClamp(RotPlayerPos.Y + (0.5 - (TileSize / 2.0)),0.0,1.0 - TileSize);

	//Calculate texture panning for alpha
	MapOffset.R =  FClamp(-1.0 * RotPlayerPos.X,-0.5 + (TileSize / 2.0),0.5 - (TileSize / 2.0));
	MapOffset.G =  FClamp(-1.0 * RotPlayerPos.Y,-0.5 + (TileSize / 2.0),0.5 - (TileSize / 2.0));

	//Set the material parameter values
	GameMinimap.Minimap.SetScalarParameterValue('MapRotation',MapRotation);
	GameMinimap.Minimap.SetScalarParameterValue('TileSize',TileSize);
	GameMinimap.Minimap.SetVectorParameterValue('MapOffset',MapOffset);
	GameMinimap.CompassOverlay.SetScalarParameterValue('CompassRotation',CompassRotation);

	//Draw the map
	Canvas.SetPos(MapPosition.X,MapPosition.Y);
	Canvas.DrawMaterialTile(GameMinimap.Minimap,MapDim,MapDim,StartPos.X,StartPos.Y,TileSize,TileSize);

	//Draw the player's location
	Canvas.SetPos(	MapPosition.X + MapDim * (((DisplayPlayerPos.X + 0.5) - StartPos.X) / TileSize) - (BoxSize / 2),
				MapPosition.Y + MapDim * (((DisplayPlayerPos.Y + 0.5) - StartPos.Y) / TileSize) - (BoxSize / 2));
	Canvas.SetDrawColor(PlayerColors[0].R,
					PlayerColors[0].G,
					PlayerColors[0].B,
					PlayerColors[0].A);
	Canvas.DrawBox(BoxSize,BoxSize);
	
	/*****************************
	*  Draw Other Players
	*****************************/

	foreach WorldInfo.AllControllers(class'Controller', C)
	{
		//Добавлена проверка на существование Pawn
		if(PlayerController(C) != PlayerOwner && C.Pawn!=none /*&& Vehicle (C.Pawn) != none*/)
		{
			//Calculate normalized player position
			PlayerPos.Y = (GameMinimap.MapCenter.X - C.Pawn.Location.X) / ActualMapRange;
			PlayerPos.X = (C.Pawn.Location.Y - GameMinimap.MapCenter.Y) / ActualMapRange;

			//Calculate position for displaying the player in the map
			DisplayPlayerPos.X = VSize(PlayerPos) * Cos( Atan2(PlayerPos.Y, PlayerPos.X) - MapRotation);
			DisplayPlayerPos.Y = VSize(PlayerPos) * Sin( Atan2(PlayerPos.Y, PlayerPos.X) - MapRotation);

			if(VSize(DisplayPlayerPos - RotPlayerPos) <= ((TileSize / 2.0) - (TileSize * Sqrt(2 * Square(BoxSize / 2)) / MapDim)))
			{
				//Draw the player's location
				Canvas.SetPos(	MapPosition.X + MapDim * (((DisplayPlayerPos.X + 0.5) - StartPos.X) / TileSize) - (BoxSize / 2),
							MapPosition.Y + MapDim * (((DisplayPlayerPos.Y + 0.5) - StartPos.Y) / TileSize) - (BoxSize / 2));
				
				if (Vehicle (C.Pawn) != none)
				{
					Canvas.SetDrawColor(PlayerColors[1].R,
								    PlayerColors[1].G,
									PlayerColors[1].B,
									PlayerColors[1].A);
					Canvas.DrawBox(BoxSize,BoxSize);
				}
				else
				{
					Canvas.SetDrawColor(PlayerColors[2].R,
								    PlayerColors[2].G,
									PlayerColors[2].B,
									PlayerColors[2].A);
					Canvas.DrawBox(BoxSize/2, BoxSize/2);
				}
				
			}
		}
	}

	//Draw the compass overlay
	Canvas.SetPos(MapPosition.X,MapPosition.Y);
	Canvas.DrawMaterialTile(GameMinimap.CompassOverlay,MapDim,MapDim,0.0,0.0,1.0,1.0);
}

exec function CloseAllMenus()
{

	Gorod_CloseMenu();
	// список флэшек ещё пригодится
	//CloseKeyBoardSettingsScreen();
	//CloseExerciseList();
	//CloseProfilesMenu();
	//CloseConnectToServMenu();
	//CloseControlSettingsMenu();
	//CloseCreateServMenu();
	//CloseExamMenu();
	//CloseFreeDrivingMenu();
	//CloseGameMenu();
	//CloseListPDDTestMenu();
	//CloseStatisticsMenu();
	//CloseTrainingMenu();
	//CloseVideoOptMenu()	;
	//CloseNetAndLocalScreen();
	//CloseSettingsScreen();
	//ClosedrvScreen();
	//CloseNetworkScreen();
}

`if(`notdefined(FINAL_RELEASE))
exec function ShowBotNames()
{
	bShowBotNames=!bShowBotNames;
}
`endif

defaultproperties
{

	MapDim=256
	BoxSize=5
	PlayerColors(0)=(R=255,G=0,B=0,A=255)
	PlayerColors(1)=(R=96,G=255,B=96,A=255)
	PlayerColors(2)=(R=0,G=255,B=255,A=255)
	TileSize=0.4
	MapPosition=(X=0.000000,Y=0.000000)
	bShowBotNames = false;
	bRegistred = false;
}