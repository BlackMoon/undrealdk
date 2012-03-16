class Gorod_AIVehicle_Controller extends AIController;

/** минимально допустиое расстояние м/у машиной - ботом и ближайшим препятствием */
var const float MIN_DISTANCE;

/** максимальное расстояние до маршрутной точки, на котором данная маршрутная точка считается достигнутой */
var const float POINT_REACH_PRECISION;

/** Машина, управляемая данным Controller'ом */
var Gorod_AIVehicle ControlledCar;

/** Текущий выбранный маршрут. Если CurPath == none, значит текущего пути нет */
var Gorod_BasePath CurPath;

/** Индекс точки в текущем маршруте */
var int CurIndex;

/** ближайшее препятсвие (впереди идущая машина/маршрутная точка, перед которой надо затормозить) */
var Actor Obstacle;

/** Безопасное расстояние */
var float SafeDistance;

/** счётчик для выявления каждого 5-го tick'а */
var int countTick;

/** Впередилежащие маршрутные точки (список маршрутных точек, полученных с помощью обхода орграфа, образованного маршрутными точками на карте
 *  лежащих не дальше SafeDistance)
 */
var array<Gorod_AIVehicle_PathNode> nodes;

/** Дополнительный список actor'ов перед которыми тормозит машина */
var array<Actor> DangerousActors;

/** Расстояние до ближайшего игрока */
var float DistanceToClosestPlayer;
// добавлено для работы проекта форсаж
var PlayerController CurrentPlayerController;

/** Флаг, показывающий, запущена ли проверка на правильность движения машины */
var bool bDrivingCheckStarted;

var Gorod_AIVehicle_PathNode TargetForRelining;

event Possess(Pawn inPawn, bool bVehicleTransition)
{
	super.Possess(inPawn, bVehicleTransition);
	ControlledCar = Gorod_AIVehicle(Pawn);
	Pawn.SetMovementPhysics();	
}

/** Отдельная функция для запуска котроллера в нужный момент (а не в PostBeginPlay) */
function StartController()
{
	// так как данный контроллер есть не только у машины, но и у водителя (чтобы он мог нормально сесть в машину),
	// делаем проверку на то, что Pawn - это Gorod_AIVehicle (если нет то остаёмся в auto state Idle и ничего не делаем)
	if((ControlledCar != none) && (ControlledCar.Target != none))
	{
		// записываемся в массив машин, которые едут к точке ControlledCar.Target
		ControlledCar.Target.IncomingAIVehicleControllers.AddItem(self);

		// задание требуемой скорости движения
		ControlledCar.SetTargetSpeed(ControlledCar.Target.CarMaxSpeed);
		if(CurPath == none)
		{
			// задание пути
			SetCurrentPath(ControlledCar.Target.GetRandomPath());
		}

		UpdateNextNodes();

		GotoState('Work');
	}
}

/** Начальное состояние */
auto simulated state Idle
{
}

/********************************************************/
/*          Управление движением машины-бота            */
/********************************************************/

/** Движение по карте */
simulated state Work
{
	simulated event Tick(float DeltaSeconds)
	{
		super.Tick(DeltaSeconds);

		if(ControlledCar != none)
		{
			SelectNewTarget();
			
			countTick++;

			if(countTick == 3)
			{
				// в редких случаях base'ом становилась другая машина
				// меняем base на none чтобы машина не приатачивалась к другой машине, иначе машина подпрыгивает.
				ControlledCar.SetBase(none);
				
				// исчезаем в случае косяка
				CalcDistanceToClosestPlayer();

				if(DistanceToClosestPlayer < `MIN_DISTANCE && DistanceToClosestPlayer > `MIN_WRONG_DISTANCE )
					CheckWrongDriving();
			}
			else if(countTick == 4)
			{
				// добавлено для работы проекта форсаж
				if(CurrentPlayerController == none)
					CurrentPlayerController = GetALocalPlayerController();

				CalcDistanceToClosestPlayer();

				// исчезаем, если находимся достаточно далеко от всех игроков
				if(DistanceToClosestPlayer > `MAX_DISTANCE)
					Disappear();
			}
			else if(countTick == 5)
			{
				CalcSafeDistance();
		
				Scan();

				countTick = 0;
			}

			SetNewTargetSpeed();
		}
	}

	/** Дополнительная проверка на правильность движения машины. Запускаем соответствующую провеку из Gorod_AIVehicle и, если она не проходит, устанавливаем таймер для повторной проверки */
	function CheckWrongDriving()
	{
		if(!bDrivingCheckStarted)
		{
			if (ControlledCar.IsDrivingWrong())
			{
				bDrivingCheckStarted = true;
				SetTimer(1, false, 'CheckWrongDrivingAgain');
			}
		}
	}

	/** Повторная проверка на правильность движения машины. Запускаем соответствующую провеку из Gorod_AIVehicle и, если она не проходит, убираем машину с карты */
	function CheckWrongDrivingAgain()
	{
		if (ControlledCar.IsDrivingWrong())
			Disappear();
		bDrivingCheckStarted = false;
	}
}

/** Ожидание появления на карте */
simulated state Teleported
{
Begin:
	// если нет RelocationManager'а, то перестаём что-либо делать
	if(ControlledCar.RelocManager == none)
	{
		`log(self @ "No reloc manager");
		GotoState('Idle');
	}

	// если есть текущий путь
	if(CurPath != none)
	{
		// освобождаем его
		CurPath.CancelPath(ControlledCar);
		CurIndex = 0;
		CurPath = none;
	}

	// останавливаем машину
	ControlledCar.Target = none;
	ControlledCar.SetTargetSpeed(0);
	ControlledCar.SetNoThrottle(true);
	// отключаем световые сигналы
	TurnOffControlledCarSignals();

	// убираем Obstacle
	Obstacle = none;

	// сообщаем RelocationBotManager'у, что необходимо переместить нас в новую точку
	ControlledCar.RelocManager.AddPawnToReloc(ControlledCar);	
}

/** Промежуточное состояние для выполнения действий, необходимых после появления на карте */
simulated state AfterAppeared
{
	simulated event Tick(float DeltaSeconds)
	{
		// ждём пока машина упадёт на точку
		if(ControlledCar.IsOverlapping(ControlledCar.Target))
		{			
			ControlledCar.SetNoThrottle(false);
			ControlledCar.SetTargetSpeed(ControlledCar.Target.CarMaxSpeed);
			SetCurrentPath(ControlledCar.Target.GetRandomPath());
			GotoState('Work');
		}
	}
}

/** Объявление функции дополнительной проверки, чтобы не возникало ошибки при вызове CheckWrongDriving, когда машина находится не в состоянии Work */
function CheckWrongDriving()
{
	`warn("wrong function call");
}

/** Рассчёт расстояния до ближайшего игрока */
function CalcDistanceToClosestPlayer()
{
	// вычисление расстояния до ближайшего игрока закомментировано для работы проекта форсаж
	/*
	local int i;		
	local float CurrentDistance;
	local array<Vector> Locations;

	Locations = Gorod_Game(WorldInfo.Game).GetPlayerControllersLocation();
			
	// вычмсляем расстояние до ближайшего игрока	
	if(Locations.Length > 0)
	{
		DistanceToClosestPlayer = VSize(Locations[0] - ControlledCar.Location);

		for(i = 1; i < Locations.Length; i++)
		{
			CurrentDistance = VSize(Locations[i] - ControlledCar.Location);
			if(CurrentDistance < DistanceToClosestPlayer)
				DistanceToClosestPlayer = CurrentDistance;
		}
	}
	else
		DistanceToClosestPlayer = 0.f;
	*/

	if(CurrentPlayerController == none || CurrentPlayerController.Pawn == none)
		DistanceToClosestPlayer = 0.0f;
	else
		DistanceToClosestPlayer =  VSize(CurrentPlayerController.Pawn.Location - ControlledCar.Location);
}

function SetTargetForRelining(Gorod_AIVehicle_PathNode t)
{
	TargetForRelining = t;
	t.ChangeLineAiVehicle_Controller = self;
}

/** Выбор очередной маршрутной точки в том случае, если мы достигли текущей маршрутной точки */
function bool SelectNewTarget()
{
	local Gorod_AIVehicle_PathNode NewPathNode;
	local Gorod_BasePath NewPath;

	// если у машины нет Target'a (такого быть не должно)
	if(ControlledCar.Target == none)
	{
		// сообщаем об ошибке и исчезаем с карты
		`warn("Target is none.");
		Disappear();
		return false;
	}
	
	if(TargetForRelining != none) // если была выбрана точка для перестроения
	{
		// удаляемся из массива машин, которые едут к точке ControlledCar.Target
		ControlledCar.Target.IncomingAIVehicleControllers.RemoveItem(self);

		// если есть путь покидаем его
		if(CurPath != none)
		{
			CurIndex = 0;
			CurPath.CancelPath(ControlledCar);
			CurPath = none;
		}

		// устанавливаем точку для перестроения в качестве текущей маршрутной точки
		ControlledCar.Target = TargetForRelining;
		
		// выбираем новый путь
		NewPath = TargetForRelining.GetRandomPath();
		if(NewPath != none)
			SetCurrentPath(NewPath);

		// записываемся в массив машин, которые едут к точке ControlledCar.Target
		ControlledCar.Target.IncomingAIVehicleControllers.AddItem(self);

		UpdateNextNodes();

		// удаляем точку для перестроения, чтобы на следующем шаге не обрабатывать её снова
		TargetForRelining = none;

		return true;
	}
	else if(ControlledCar.IsOverlapping(ControlledCar.Target)) // если доехали до очередной точки
	{
		// Дополнительная проверка. Если доехали до точки, которая является Obstacle, то это значит, что машина-юот
		// не успела затормозить - такого быть не должно
		if(ControlledCar.Target == Obstacle)
			`warn("Failed to stop before PathNode" @ ControlledCar.Target $ ". CurrentVelocity=" $ ControlledCar.CurrentVelocity);
		//если доехали до точки в которую перестраивались, удаляем себя из точки
		if(ControlledCar.Target.ChangeLineAiVehicle_Controller==self)
			ControlledCar.Target.ChangeLineAiVehicle_Controller = none;

		// удаляемся из массива машин, которые едут к точке ControlledCar.Target
		ControlledCar.Target.IncomingAIVehicleControllers.RemoveItem(self);

		// запоминаем точку до которой доехали
		ControlledCar.OldTarget = ControlledCar.Target;
		
		// пробуем получить очередную маршрутную точку из текущего пути
		if(CurPath != none)
		{
			// если текущий индекс можно увеличить на единицу, не выйдя при этом за границу массива CurPath.PathNodes
			if(CurIndex < CurPath.PathNodes.Length - 1)
			{
				// если доехали до первой точки текущего пути
				if(CurIndex == 0)
				{
					// заезжаем на путь
					CurPath.GoIn(ControlledCar);
				}

				// задаём следующую маршрутную точку в соответствии с маршрутом
				CurIndex++;
				NewPathNode = Gorod_AIVehicle_PathNode(CurPath.PathNodes[CurIndex]);
			}
			else
			{
				CurIndex = 0;
				// покидаем путь
				CurPath.GoOut(ControlledCar);
				CurPath = none;

				// отключаем световые сигналы машины
				TurnOffControlledCarSignals();
			}
		}
		
		// если не удалось выбрать точку из текущего пути
		if(NewPathNode == none)
		{
			// выбираем новую маршрутную точку случайным образом
			NewPathNode = ControlledCar.Target.GetRandomNode();

			// если и этого не удаётся
			if(NewPathNode == none)
			{
				Disappear();
				return false;
			}
			else
				NewPath = NewPathNode.GetRandomPath();
		}

		// устанавливаем новую маршрутную точку
		ControlledCar.Target = NewPathNode;
		SetCurrentPath(NewPath);

		// записываемся в массив машин, которые едут к точке ControlledCar.Target
		ControlledCar.Target.IncomingAIVehicleControllers.AddItem(self);

		ControlledCar.OldTarget.LastCar = ControlledCar;
		//ControlledCar.OldTarget.DecDangerousVehicleNum();

		UpdateNextNodes();

		//`log(ControlledCar.Target);
		return true;
	}

	return false;
}

/** Вычисление расстояния, достаточного для того, чтобы сбросить скорость до 0 */
simulated function CalcSafeDistance()
{
	 SafeDistance = ControlledCar.CurrentVelocity*(ControlledCar.CurrentVelocity/ControlledCar.VelocityStep)/2 + ControlledCar.VEHICLE_LENGTH/2 + MIN_DISTANCE;
}

/**
* В качестве препятствия выбирает ближайшую машину из тех, которые едут по тому же пути, перестраиваются или управляются игроком
* Для поиска машин использует CollidingActor с центром, смещенным в сторону очередной маршрутной точки
*/
simulated function Scan()
{	
	local UDKVehicle ClosestVehicle;
	local Actor ClosestDangerousActor;

	if(ControlledCar.Location.Z < -100)
	{
		Disappear();
		return;
	}

	Obstacle = none;

	if(ControlledCar.Target != none)
	{
		ClosestVehicle = FindClosestVehicle();
		ClosestDangerousActor = FindClosestDangerousActor();

		// сравниваем расстояния до ближайшей машины-бота и ближайшего опасного объекта
		// задаём Obstacle
		if(ClosestVehicle != none && ClosestDangerousActor != none)
		{
			if(DistanceFromPoint(ClosestVehicle.Location) < DistanceFromPoint(ClosestDangerousActor.Location))
				Obstacle = ClosestVehicle;
			else
				Obstacle = ClosestDangerousActor;
		}
		else if(ClosestVehicle != none)
		{
			Obstacle = ClosestVehicle;
		}
		else if(ClosestDangerousActor != none)
		{
			Obstacle = ClosestDangerousActor;
		}
		
		// если выбран путь, но мы ещё не доехали до первой точки
		if((CurPath != none) && (CurIndex == 0))
		{
			// если световые сигналы машины не включены
			if(DistanceFromPoint(ControlledCar.Target.Location) < 2000)
			{
				// задаём какие световые сигналы должны быть включены у машины
				SetControlledCarSignals();
			}

			// если через выбранную в качестве таргета точку движение запрещено
			if(!CurPath.CanGo())
			{
				if(Obstacle == none || DistanceFromPoint(ControlledCar.Target.Location) < DistanceFromPoint(Obstacle.Location))
					Obstacle = ControlledCar.Target;
			}
		}
	}
}

/** Отдельная функция с реализацией формулы расчёта требуемой скорости в зависимости от наличия Obstacle и расстояния до него  */
simulated function SetNewTargetSpeed()
{
	local float VehicleObstacleLength2, StopDistance;
	local VehicleBase VehicleObstacle;

	// Если нет текущей маршрутной точки, останавливаемся
	if(ControlledCar.Target == none)
	{
		ControlledCar.SetTargetSpeed(0);
		return;
	}

	// Если нет препятствия, выбираем скорость из текущей маршрутной точки
	if(Obstacle == none)
	{
		ControlledCar.SetTargetSpeed(ControlledCar.Target.CarMaxSpeed);
		return;
	}

	// Рассчитываем половину длины впереди идущей машины
	VehicleObstacle = VehicleBase(Obstacle);
	VehicleObstacleLength2 = ((VehicleObstacle != none) ? (VehicleObstacle.VEHICLE_LENGTH/2) : 0.f);

	// Расстояние до препятствия, по которому будет рассчитана требуемая скорость движения на данный момент
	StopDistance = VSize(Obstacle.Location - ControlledCar.Location) - ControlledCar.VEHICLE_LENGTH/2 - VehicleObstacleLength2 - MIN_DISTANCE;

	// если слишком близко подъехали, тормозим мгновенно
	if(StopDistance <= 0)
	{
		ControlledCar.SetTargetSpeed(0);
		return;
	}
	
	// Устанавливаем скорость с которой надо ехать чтобы затормозить на расстоянии StopDistance при ускорении ControlledCar.VelocityStep
	ControlledCar.SetTargetSpeed(Sqrt(2*ControlledCar.VelocityStep*StopDistance));
}

/** Определение ближайшей впереди идущей машины */
function UDKVehicle FindClosestVehicle()
{
	// препятствие, которое считается ближайшим на данный момент
	local UDKVehicle ClosestVehicle, CurrentVehicle;
	local UDKVehicle PlayerVehicle;
	local Gorod_AIVehicle CurrentAIVehicle;
	local Vector HitLoc, HitNorm;
	local bool bPlayerVehicleFound;

	ClosestVehicle = none;
	
	// Ищем другие машины по радиусу
	foreach CollidingActors(class'UDKVehicle', CurrentVehicle, SafeDistance, ControlledCar.Location + (SafeDistance)*ControlledCar.TargetViewDirection)
	{
		CurrentAIVehicle = Gorod_AIVehicle(CurrentVehicle);
		if(CurrentAIVehicle != none)        // Если очередная машина - бот
		{
			// если нашли сами себя, переходим к следующему объекту, найденному CollidingActors'ом
			if(CurrentAIVehicle == ControlledCar) continue;

			// если Target к которому едет CurrentVehicle - не в списке nodes и не является машиной игрока, то переходим к следующему объекту
			if(nodes.Find(CurrentAIVehicle.Target) == INDEX_NONE) continue;
		}
		else if(CurrentVehicle != none && PlayerController(CurrentVehicle.Controller) != none)        // Если очередная машина - машина игрока
		{
			bPlayerVehicleFound = false;
			
			// Trace для машин игрока
			foreach TraceActors(class'UDKVehicle', PlayerVehicle, HitLoc, HitNorm, ControlledCar.Location + (SafeDistance)*ControlledCar.TargetViewDirection, ControlledCar.Location, ControlledCar.GetCollisionExtent() + vect(20, 20, 0))
			{
				// Если текущая машина найдена с помощью Trace
				if(CurrentVehicle == PlayerVehicle)
				{
					bPlayerVehicleFound = true;
					break;
				}
			}

			// если машина игрока не нашлась с помощью TraceActors, то считаем, что она не преграждает нам путь
			if(!bPlayerVehicleFound) continue;
		}

		// вычисляем ближайшую машину
		if(ClosestVehicle == none || (VSize(ClosestVehicle.Location - ControlledCar.Location) > VSize(CurrentVehicle.Location - ControlledCar.Location)))
			ClosestVehicle = CurrentVehicle;
	}

	return ClosestVehicle;
}

/** Находим ближайший опасный объект */
function Actor FindClosestDangerousActor()
{
	local Actor a, ClosestActor;
	
	ClosestActor = none;

	foreach DangerousActors(a)
	{
		if(ClosestActor == none || (DistanceFromPoint(ClosestActor.Location) > (DistanceFromPoint(a.Location))))
			ClosestActor = a;
	}

	return ClosestActor;
}

/** Выполняет необходимые действия при возвращении машины на карту */
function Appear(Gorod_AIVehicle_PathNode node)
{	
	ControlledCar.Target = node;
	ControlledCar.Target.LastCar = ControlledCar;   // LastCar = currentCar
	UpdateNextNodes();

	GotoState('AfterAppeared');
}

/** Установка заданного пути в качестве текущего и выполнение сопутствующих действий */
function SetCurrentPath(Gorod_BasePath path)
{
	if(path != none)
	{
		CurPath = path;
		CurIndex = 0;
		// выбираем путь
		CurPath.Select(ControlledCar);
		
		if(ControlledCar.Target.CrossRoad != none)
		{
			// если у текущей маршрутной точки задан CrossRoad, значит данная точка является въездом на перекрёсток
			// и надо зарегистрироваться в нём
			ControlledCar.Target.CrossRoad.RegisterBotInQueue(self);
		}
	}
}

/** Обновляем список впередилежащих маршрутных точек */
function UpdateNextNodes()
{
	local Gorod_AIVehicle_PathNode p;
	local int i, j;

	// обходим граф маршрутных точек только если на текущем tick'е была выбрана новая маршрутная точка
	nodes.Remove(0, nodes.Length);
	
	if (ControlledCar.Target == none)
		return;

	nodes.AddItem(ControlledCar.Target);
	foreach ControlledCar.Target.NextPathNodes(p)
		nodes.AddItem(p);

	i = 0;
	while(i < nodes.Length)
	{
		for(j = 0; j < nodes[i].NextPathNodes.Length; ++j)
		{
			// дополнительная проверка на случай ошибки при указании NextPathNodes
			if(nodes[i].NextPathNodes[j] == none)
			{
				`warn("NextPathNodes in" @ nodes[i] @ "contains none element" @ "(index=" $ j $")");
				continue;
			}
			// Просматриваем маршрутные точки, лежащие не дальше 2000, SafeDistance не используется в виду того, что он не достаточен при небольшой скорости движения
			else if((nodes.Find(nodes[i].NextPathNodes[j]) == INDEX_NONE) && (VSize(nodes[i].NextPathNodes[j].Location - nodes[0].Location) < 2000.f /*SafeDistance*/))
				nodes.AddItem(nodes[i].NextPathNodes[j]); // добавляю в nodes, очередную точку, которую надо обработать
		}
		++i;
	}
}

/** Исчезание машины-бота */
function Disappear()
{
	GotoState('Teleported');
}

/** Расстояние от машины-бота до указанной точки */
function float DistanceFromPoint(Vector Loc)
{
	return VSize(ControlledCar.Location - Loc);
}

/** Функция - уведомление о том, что у управляемого Pawn'а возникло событие RigidBodyCollision */
function NotifyRigidBobyCollision(PrimitiveComponent HitComponent, PrimitiveComponent OtherComponent, const out CollisionImpactData RigidCollisionData, int ContactIndex)
{
	local UDKVehicle vehic;
	local PlayerController pl;

	// если столкнулся не с машиной, ничего не делаем
	vehic = UDKVehicle(OtherComponent.Owner);
	if(vehic == none)
		return;

	// если столкнулся с машиной игрока, ничего не делаем
	pl = PlayerController(vehic.Controller);
	if(pl != none)
		return;

	// столкнулись с "левым" объектом, такого быть не должно исчезаем
	Disappear();
	
	// так не должно быть - пишем в лог
	// временно закоментированно, для финального билда
	//`log("CRASH-----------------------------------");
	//`log("Controller:" @ self);
	//`log("ControlledCar:" @ ControlledCar @ "Location:" @ ControlledCar.Location);
	//`log("Target:" @ ControlledCar.Target);
	//`log("Other:" @ OtherComponent.Owner);
}


/************************************************/
/*          Информация о машине-боте            */
/************************************************/

/** Возвращает текущий путь */
function Gorod_BasePath GetCurrentPath()
{
	return CurPath;
}

/** Возвращает подконтрольную машину */
function Gorod_AIVehicle GetControlledCar()
{
	return ControlledCar;
}

/************************************************/
/*          Свет машины                         */
/************************************************/

/** Обновляет состояние световых сигналов */
function SetControlledCarSignals()
{
	// Обновляем информацию о световых сигналах
	if(CurPath == none)
	{
		ControlledCar.LightsInfo.bLeftSignalLightOn = false;
		ControlledCar.LightsInfo.bRightSignalLightOn = false;
	}
	else if(CurPath.PathTurnType == PDR_Right)
	{
		ControlledCar.LightsInfo.bLeftSignalLightOn = false;
		ControlledCar.LightsInfo.bRightSignalLightOn = true;
	}
	else if(CurPath.PathTurnType == PDR_Left)
	{
		ControlledCar.LightsInfo.bLeftSignalLightOn = true;
		ControlledCar.LightsInfo.bRightSignalLightOn = false;
	}
	else 
	{
		ControlledCar.LightsInfo.bLeftSignalLightOn = false;
		ControlledCar.LightsInfo.bRightSignalLightOn = false;
	}

	// обновление световых сигналов на сервере
	ControlledCar.VehicleLightsController.UpdateSignalLights();
}

/** Выключает все световые сигналы */
function TurnOffControlledCarSignals()
{
	ControlledCar.LightsInfo.bLeftSignalLightOn = false;
	ControlledCar.LightsInfo.bRightSignalLightOn = false;

	// обновление световыч сигналов на сервере
	ControlledCar.VehicleLightsController.UpdateSignalLights();
}

/****************************************************************************************************/
/*          Функции для обеспечения возможности перебегания пешехода в неположенном месте           */
/****************************************************************************************************/

/** Возвращает безопасное расстояние, на котором машина-бот может затормозить */
function float GetSafeDistance()
{
	return SafeDistance;
}

/** Регистрирует опасный объект */
function RegisterDangerousActor(Actor DangerousActor)
{
	if(DangerousActors.Find(DangerousActor) == INDEX_NONE)
		DangerousActors.AddItem(DangerousActor);
}

///** Отменяет регистрацию опасного объекта */
//simulated function UnregisterDangerousActor(Actor DangerousActor)
//{
//	DangerousActors.RemoveItem(DangerousActor);
//}

///** Очищает список опасных объектов */
//simulated function ClearDangerousActors()
//{
//	DangerousActors.Remove(0, DangerousActors.Length);
//}

DefaultProperties
{
	MIN_DISTANCE = 300;
	POINT_REACH_PRECISION = 50;

	countTick = 0;
	bDrivingCheckStarted = false;

	//RemoteRole = ROLE_SimulatedProxy;
}