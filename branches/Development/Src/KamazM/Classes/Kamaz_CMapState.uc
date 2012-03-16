
/** Контролер карты. Управляет инициализацией объектов для миссий , заданий и т. д. */
class Kamaz_CMapState extends Actor;

/** Машина игрока */
var Kamaz_PlayerCar PlayerCar;

/** Контроллер игрока */
var Kamaz_PlayerController PC;

/** Контроллер игрока */
var PlayerStart PStart;


/** Возвращет объекты на карте в исходное состояние */
client reliable function ReturnMapsObjectsToInitState()
{
	local Kamaz_Game KG;	
	
	CheckPlayerCar();
	KG=Kamaz_Game(WorldInfo.Game);
	
	if(PlayerCar!=none && PC!= none && KG!=none )
	{
		PC.LeaveCar(Vehicle(PC.Pawn) );
		PlayerCar.SetLocation(Vect(200472.0,218139.0,2004.0));
		PlayerCar.CollisionComponent.SetRBPosition(Vect(200472.0,218139.0,2004.0));

		PlayerCar.Ignition = false;
		PlayerCar.bMass = false;
		PlayerCar.ClutchPedal = 1.0;
		PlayerCar.GasPedal = 0.3;  
		PlayerCar.HandBrake = true;
		PlayerCar.BrakePedal = 0;
		PlayerCar.SetCurrentGear(0);
		PlayerCar.SetLeftTurn(false);
		PlayerCar.SetRightTurn(false);
		PlayerCar.SetAlarmSignal(false);
		PlayerCar.SetSirenaSignal(false);
		
		// Вызовем событие для кизмета, кизмет выполнит все необходымие действия по завершению миссии.
		// сделаем все стрелки миссий невидимые
		KG.MissionObjectsHide();
	}
	else
	{
		`warn ("Execepted error in: Gorod_CMapState.ReturnMapsObjectsToInitState()");
	}
	

	// Надо будет переделать. Вообще-то нельзя отключать автодром, пока хотя бы один игрок на карте
	// проходит автодром
	PC.CheckerAutodrom.StopAutodromCheck();
	PC.CheckerAutodrom.SetEnadled(false);
}

/** устанавливает всё для мисcии*/
client reliable function GoToMission(Quest_Custom quest)
{
	local Kamaz_Game KG;
	CheckPlayerCar();

	KG=Kamaz_Game(WorldInfo.Game);
	if(KG!=none)
	{	
		KG.StartMissionKismet(); // запускаем ролик
		PC.bIsMission=true;
		PC.bIsMenu=false;
	}	
}

/** устанавливает всё для свободной поездки и автодрома  */
client reliable function GoToFreeDrv(Quest_Custom quest)
{
	local Vector loc;
	local Rotator rot;
	local Quest_Autodrom questA;
	
	CheckPlayerCar();
		
	if(PlayerCar!=none && PC!= none)
	{
		loc = quest.StartPoint.CarPosition.Location;
		rot = quest.StartPoint.CarPosition.Rotation;

		PlayerCar.SetLocation(loc);
		PlayerCar.CollisionComponent.SetRBPosition(loc);
		PlayerCar.SetRotation(rot);
		PlayerCar.CollisionComponent.SetRBRotation(rot);
		PlayerCar.TryToDrive(PC.Pawn);
		
		
		PC.bIsMission=false;
		PC.bIsMenu=false;

		questA = Quest_Autodrom(quest);
		// если quest - автодром, то вкл. автодром
		if(questA != none)
		{
			PC.CheckerAutodrom.SetEnadled(true);
			PC.CheckerAutodrom.SetVisualHintsEnabled(questA.bVisualHintsEnabled);
		}
	}
	else
	{
		`log ("Execepted error in: Gorod_CMapState.GoToFreeDrv()");
	}
	
}

/**устанавливает всё для перехода в главное меню*/
client reliable function GoToMenu()
{
	local Vector loc;
	local Rotator rot;
	
	
	ReturnMapsObjectsToInitState();
	
	if( PC!= none )
	{
		CheckPlayerStart();
		loc = PStart.Location;
		rot = PStart.Rotation;
		if(PC.Pawn!=none)
		{
			PC.Pawn.SetLocation(loc);
			PC.Pawn.SetRotation(rot);
		}
		PC.SetLocation(loc);
		PC.SetRotation(rot);
		PC.IgnoreMoveInput(true);
		PC.IgnoreLookInput(true);
		//PC.StopCheckCarControlElements();   закоментированно так как данный код так же вызывается в UnPossess() Gorod_PlayerController в связи с тем что на данный момент возможно выходить их камаза
		PC.bIsMission=false;
		PC.bIsMenu=true;
	}

}

/** функция проверки ссылки на камаз, в случае если ссылка пустая, пытается заполнить */
function CheckPlayerCar()
{
	local Kamaz_PlayerCar PlayerC;
	if(PlayerCar==none)	
	{
		foreach AllActors(class'Kamaz_PlayerCar',PlayerC)
		{
			PlayerCar = PlayerC;
			break;
		}
	}
}
/** Проверяет, есть ли ссылка на плеерстарт. Если нет - находит и сохраняет */
function CheckPlayerStart()
{
	local PlayerStart PS;
	if(PStart ==none)
	{
		foreach WorldInfo.AllNavigationPoints(class'PlayerStart', PS)
		{
			PStart = PS;
			break;
		}
	}
}
DefaultProperties
{
}
