class Gorod_HumanBotAiController extends AIController;
/** класс контроллера бота человека */

`include(Gorod_Events.uci);


//временный путь
var() Vector TempDest;
//точку к которой пойдет бот
var  Gorod_HumanBotPathNode Target;
//точка, в которой бот был последний раз
var  Gorod_HumanBotPathNode PrevTarget;
var  Gorod_HumanBotPathNode LastTarget;
//
var int selectedPath;
//
var int actual_node;
var int last_node;
/** Время, которое ждет бот прежде чем проверит свободен ли путь или нет */
var int WaitingTime;
//ссылка на нашего бота
var Gorod_HumanBot MyPawn;
var Vector CarLastLocation;
var Vector CarCurrLocation;
var Rotator CarRotation;
var Vector PerpVelocity;
var Gorod_HumanBotSpawner Spawner;
var Vector TempTarget;
var Actor a;
/** Переменная, которая определяет, пойдет ли бот по пути или по обычным точкам */
var int goOnPath;
/** Временный таргет для пересечения дороги */
var Gorod_HumanBotPathNode crossTarget;
/** Временный таргет для проверок*/
var Gorod_HumanBotPathNode trgt;
/** Сгенерированный фрагментированный путь */
var array<Vector> fragmentedPathPoint;
/** Идет ли бот по фрагментированному пути */
var bool bIsFollowingOnFragmentedPath;
/** Как часто разбиваем путь */
var int curPathFragmentation;
/** Максимальное отклонение вправо от начального пути */
var int curPathOffset;

var bool bIsCrossingTheRoad;

/** Погрешность с которой проверяется, дошел ли бот до точки */
var int imprecision;

// затрял
var bool bStuck;

var Gorod_Event EventToSend;

function SetPawn(Gorod_HumanBot NewPawn, optional Gorod_HumanBotSpawner Sp)
{
	//получаем ссылку на бота, которого контролируем
    MyPawn = NewPawn;
	Possess(MyPawn, false);
	NewPawn.SetMovementPhysics();
	Target = NewPawn.FirstPoint;//задаем первую точку
	LastTarget = Target;//первая точка является точка, в которой бот был последний раз
	//если бота заспавнил класс спавнер
	if(Sp!=none)
	{
		//сохраняем ссылку
		Spawner = Sp;
	}
	////включаем контролнимбы
	//NewPawn.EnableFootPlacement();
	//каждые пол секунды запускаем функцию, проверяющую стоит бот или нет
	SetTimer(5,true,'CheckObstacle');
}

/**
 *  Возвращает значение в промежутке от -pi до +pi поворота Actora в нашу сторону.
 *  Не важно, в какую сторону смотрим мы в данный момент.
 **/
function float GetAngleDifference(Actor Other)
{
	//переменные для вычисления разности
	local float OtherHeading;
	local float SelfHeading;
	local Rotator OtherRot;
	local Rotator SelfVectorRot;

	//смотрим только по Yaw, тоесть по повороту вдоль Z
	OtherRot.Yaw = Other.Rotation.Yaw;
	//высчитываем угол поворота, как если бы мы смотрели на Actor Other
	SelfVectorRot.Yaw = rotator(Pawn.Location - Other.Location).Yaw;

	//получаем углы
	OtherHeading = GetHeadingAngle(Vector(OtherRot));
	SelfHeading = GetHeadingAngle(Vector(SelfVectorRot));

	//возвращаем разность
	return FindDeltaAngle(OtherHeading, SelfHeading);
}

/**
 * Исчезаем, если находимся слишком далеко от всех игроков
 */
function TryToDisappear()
{
	// закомментировано для работы проекта форсаж
	/*
	local array<Vector> Locations;
	local float MinDistance, CurrentDistance;
	local int i;

	
	// исчезаем, если находимся слишком далеко от игрока
	Locations = Gorod_Game(WorldInfo.Game).GetPlayerControllersLocation();

	// вычмсляем расстояние до ближайшего игрока
	if(Locations.length > 0)
	{
		MinDistance = vsize(Locations[0] - myPawn.location);

		for(i = 1; i < Locations.length; i++)
		{
			currentdistance = vsize(locations[i] - myPawn.location);
			if(currentdistance < mindistance)
			{
				mindistance = currentdistance;
			}
		}

		// исчезаем, если находимся достаточно далеко от всех игроков
		if(mindistance > `MAX_BOT_DISTANCE)
		{
			disappear();
		}
	}
	*/

	local PlayerController LocalPlayerController;

	LocalPlayerController = GetALocalPlayerController();
	if(LocalPlayerController != none && LocalPlayerController.Pawn != none)
	{
		if(VSize(LocalPlayerController.Pawn.Location - MyPawn.Location) > `MAX_BOT_DISTANCE)
		{
			disappear();
		}
	}


}

/**
 * Исчезновение с карты
 */
function Disappear()
{
	GotoState('Teleportating');
}

//стейт по-умолчанию
auto simulated state Idle
{
	Begin:
		GotoState('FollowPath');
}

//В этом стейте  бот следует по своему пути
simulated state FollowPath
{
	///** Вызыается, когда бота толкают и ему некуда отлететь*/
	//event EncroachedBy(Actor Other)
	//{
	//}
	/** Вызыается, когда бота толкают */
	simulated event bool NotifyBump(Actor Other, Vector HitNormal)
	{
		BumpAction(Other);
		return true;
	}

	/*simulated function CheckDistantion()
	{
		local array<Vector> Locations;
		local float MinDistance;
		local int i;

		Locations = Gorod_Game(WorldInfo.Game).GetPlayerControllersLocation();

		// вычмсляем расстояние до ближайшего игрока	
		if(Locations.Length > 0)
		{
			MinDistance = VSize(Locations[0] - MyPawn.Location);

			for(i = 1; i < Locations.Length; i++)
			{
				MyPawn = VSize(Locations[i] - MyPawn.Location);
				if(MyPawn < MinDistance)
				{
					MinDistance = MyPawn;
				}
			}

			// исчезаем, если находимся достаточно далеко от всех игроков
			if(MinDistance > `MAX_DISTANCE)
				Disappear();
		}
	}*/

  Begin:
	//MoveTo(PerpVelocity,,10);
	if(Target==none)
	{
		GoToState('Teleportating');
	}

	if(Role ==ROLE_Authority && MyPawn != none)
	{
		TryToDisappear();
		
		//

		if(MyPawn.ReachedDestination(Target))
		{
			//запоминаем последнюю точку
			PrevTarget = LastTarget;
			LastTarget  = Target;//= curTarget;
			//curTarget =  Target;

			//если наткнулись на точку, принадлежащую пути
			if(Target.Paths.Length!=0)
			{
				//если путь не выбран
				if(selectedPath<0)
					goOnPath = rand(2); //выбираем путь или точку, не принадлежащую пути
				else
					goOnPath = 0;       //значит, путь уже был выбран.
				if(goOnPath == 0)
				{
					Target = SelectTargetOnPath();
					if(selectedPath>=0)
					{
						if(!Target.Paths[selectedPath].CanGo())
							GoToState('WaitingForTraffic');
						else
							Target.Paths[selectedPath].GoIn(MyPawn);
					}
					else
					{
						if(Target == none)
							Target = SelectNonPathTarget(PrevTarget);
					}
				}
				else
				{
					trgt = SelectNonPathTarget(PrevTarget);
					if(trgt != none)
						Target = trgt;
					else
					{
						Target = SelectTargetOnPath();
						if(!Target.Paths[selectedPath].CanGo())
							GoToState('WaitingForTraffic');
						else
							Target.Paths[selectedPath].GoIn(MyPawn);
					}
				}
			}

			//движение бота по точкам без пути
			else
			{

		//		if(Target.bIsBetweenLevels==true)
		//		{
		//			if(Target.LevelStreamingPathNode!=none)
		//				Target = Target.LevelStreamingPathNode;
		//			else
						if(Target.NextPathNodes.Length>0)
						{
							Target = Target.GetNextPathNode(PrevTarget);

						}
						else
						{
							GoToState('Teleportating');
						}

		//		}
		//		else
		//		{
		//			Target = Target.NextPathNodes[0];
		//		}
			}

			if(Target == none)
				GoToState('Teleportating');
			//пытаемся создать фрагментированный путь
			createNonLinearPath(LastTarget.Location,Target.Location, curPathFragmentation,curPathOffset, fragmentedPathPoint);
			bIsFollowingOnFragmentedPath = (fragmentedPathPoint.Length > 0);
		}
		else //если не достигли точки
		{
			if(bIsFollowingOnFragmentedPath)
			{
				//imprecision - погрешность
				if(VSize(fragmentedPathPoint[0] - myPawn.Location)>imprecision)
					MoveTo(fragmentedPathPoint[0]);
				else
				{
					fragmentedPathPoint.RemoveItem(fragmentedPathPoint[0]);
					//не сейчас
					////пытаемся исчезнуть
					TryToDisappear();

					if(fragmentedPathPoint.Length==0)
					{
						bIsFollowingOnFragmentedPath = false;
							if(Target!=none)
							MoveToward(Target, Target);
					}
				}
			}
			else
			{
				if(Target!=none)
					MoveToward(Target, Target);
			}
			Sleep(0.1);
			goto 'Begin';

		}
		if(bIsFollowingOnFragmentedPath)
		{
			//imprecision - погрешность
			if(VSize(fragmentedPathPoint[0] - Location)>imprecision)
				MoveTo(fragmentedPathPoint[0]);
			else
			{
				fragmentedPathPoint.RemoveItem(fragmentedPathPoint[0]);
				if(fragmentedPathPoint.Length==0)
				{
					bIsFollowingOnFragmentedPath = false;
					if(Target!=none)
						MoveToward(Target, Target);

				}
			}
		}
		else
		{
			if(Target!=none)
				MoveToward(Target, Target);
		}
		Sleep(0.1);
		goto 'Begin';
	}
}

/**
 *  Вычисляет нелинейный путь, смещенный вправо, возвращает массив точек пути.
 *  @param firstPoint - начальная точка разбиваемого пути
 *  @param lastPoint - конечная точка разбиваемого пути
 *  @param pathFragmentation - как часто разбивается путь
 *  @param offset - максимальное отклонение вправо от начального пути
 *  @param arrRes - результат работы функции
 *  */
function createNonLinearPath(Vector firstPoint,Vector lastPoint, int pathFragmentation, int offset, out array<Vector> fragmentVector)
{
	//////////////////// Разбиение пути
	/** Как часто путь будет разбиваться */
	//local int pathFragmentation;
	/** Длинна пути, который будет разбиваться */
	local int Pathlength;
	/** Новый элемент нелиненого пути  */
	local Vector nonlinearTarget;

	/**  Временный единичный вектор */
	local Vector NormalVector;
	/**  Временный перпендикулярный вектор */
	local Vector PerpVector;
	/**  Временный ротатор для поворота вектора на 90 градусов */
	local Rotator PerpRotator;

	/**  Временный единичный вектор */
	local float fragmentedPathLengh;
	local Vector LastNonlinearTarget;
	local Vector newNonLinearTarget;

	//  предварительная очистка массива
	fragmentVector.Remove(0, fragmentVector.Length);

	nonlinearTarget = firstPoint;
	LastNonlinearTarget = nonlinearTarget;

	Pathlength = VSize(lastPoint - firstPoint);
	NormalVector = Normal(lastPoint - firstPoint);
	PerpRotator = rotator(NormalVector);
	PerpRotator.Yaw+=90*DegToUnrRot;
	PerpVector = Vector(PerpRotator);
	//длинна вычисленного пути = 0
	fragmentedPathLengh = 0;

	//если путь не совсем короткий
	if(Pathlength >= (2*pathFragmentation))
	{
		//пока длинна вычисленного пути меньше всего пути плюс длинны разбиения (что-бы последняя точка не была за пределами пути)
		while((fragmentedPathLengh + 2 * pathFragmentation) <= (Pathlength + pathFragmentation))
		{
			nonlinearTarget = nonlinearTarget + NormalVector * pathFragmentation;
			//spawn(class'Gorod_AIVehicle_PathNode',,,nonlinearTarget);
			newNonLinearTarget = nonlinearTarget + PerpVector * rand(offset);
			//spawn(class'Gorod_AIVehicle_PathNode',,,newNonLinearTarget);
			fragmentedPathLengh+=VSize(nonlinearTarget - LastNonlinearTarget);
			LastNonlinearTarget = nonlinearTarget;
			fragmentVector.AddItem(newNonLinearTarget);
		}
	}
}


function Gorod_HumanBotPathNode SelectTargetOnPath()
{
	//TryToDisappear();

	//если длинна пути меньше 2 то не обращаем внимания на путь
	if(Target.Paths.Length<=0)
		`warn("Target.Paths.Length = 0 ");
	//если путь еще не выбран
	if(selectedPath<0)
	{
		//выбираем случайный путь
		selectedPath = Target.GetNextPathIndex();
		if(Target.Paths[selectedPath].PathNodes.Length < 2)
		{
			`warn("Path mast have length greather than 1, Path = "$Target.Paths[selectedPath]);
			return Target.GetNextPathNode(PrevTarget);
		}
		//Выбираем путь
		Target.Paths[selectedPath].Select(MyPawn);//(MyPawn);
		Target.Paths[selectedPath].CrossRoad.RegisterBotInQueue(self);//(MyPawn);
		//Выбираем вторую точку в пути, если идем сначала пути, иначе предпоследнюю точку в пути, если идем с конца пути
		if(Target == Target.Paths[selectedPath].PathNodes[0])
			return Gorod_HumanBotPathNode(Target.Paths[selectedPath].PathNodes[1]);
		else
			return Gorod_HumanBotPathNode(Target.Paths[selectedPath].PathNodes[Target.Paths[selectedPath].PathNodes.Length-2]);

	}
	else
	{
		//проверяем, последняя или первая точка в пути
		if(Target == Target.Paths[selectedPath].PathNodes[Target.Paths[selectedPath].PathNodes.Length-1] || Target == Target.Paths[selectedPath].PathNodes[0])
		{
			//сходим с пути
			Target.Paths[selectedPath].GoOut(MyPawn);
			//следующий путь не выбран, выбираем
			selectedPath = Target.GetNextPathIndex(Target.Paths[selectedPath]);
			//если мы пытались выбрать тот же самый путь, по которому уже прошли, то просто идем дальше
			if(selectedPath < 0 && Target.NextPathNodes.Length>0)
			{
				return Target.GetNextPathNode(PrevTarget);
			}
			//занимаем путь
			else
			{
				Target.Paths[selectedPath].Select(MyPawn);
				Target.Paths[selectedPath].CrossRoad.RegisterBotInQueue(self);
			}
		}
		//просто продолжаем движение
		if(Target.NextPathNodes.Length>0)
		{
			return Target.GetNextPathNode(PrevTarget);
		}
		else
		{
			GoToState('Teleportating');
		}

	}
}
/** Возвращает случайную, которая не принадлежит пути. Если задан LastPathNode, то возвращется любая точка, кроме этой */
function Gorod_HumanBotPathNode SelectNonPathTarget(optional Gorod_HumanBotPathNode LastPathNode)
{
	local int randNode;
	local array <Gorod_HumanBotPathNode> nonPath;
	nonPath = Target.GetNextNonPathPathNodes(LastPathNode);
	if(nonPath.Length==0)
		return none;
	randNode = rand(nonPath.Length);
	return nonPath[randNode];
}

//бота сбили, назначаем физику
simulated function Died()
{
	//если какой либо путь был выбран - сходим с пути
	if(selectedPath>=0)
	{
		Target.Paths[selectedPath].GoOut(MyPawn);
	}
	//myPawn.bIsDied = true;
	if(Role==ROLE_Authority)
	{
			MyPawn.BotSetDyingPhisics(myPawn.HitLoc);
	}

}
/** Функция обхождения другого бота или препятствия */
function CheckObstacle()
{

	if(MyPawn!=none && IsInState('FollowPath') && VSize(MyPawn.Velocity) < 0.01	)
		GoToState('GetRound');
}
simulated state GetRound
{
	simulated event bool NotifyBump(Actor Other, Vector HitNormal)
	{
		BumpAction(Other);
		return true;
	}
Begin:
	//if(VSize(MyPawn.Velocity) < 0.01)
	//{

		if(bStuck)
		{
			GotoState('Teleportating');
		}
		else 
		{
			bStuck = true;
		}
		if(MyPawn !=none)
		{
			setTimer(5,false,'dontStuck');
			TempTarget = EvalTempTarget();
			MoveTo(TempTarget);
			MyPawn.SetViewRotation(Rotator(TempTarget));

			if(MyPawn.ReachedPoint(TempTarget,a))
			{
				GoToState('FollowPath');
			}
			else

				GoTo 'Begin';
		}
}


/** Функция вычисления нового временного таргета */
function Vector EvalTempTarget()
{
		//временный таргет
	local Vector tempT;
	local int tempX;
	local int tempY;

	//если есть бот и он должен двигаться
	//если бот стоит или почти стоит
	tempT  = myPawn.Location;
	tempX = rand(60);
	tempX-=30;
	tempY = rand(60);
	tempY-=30;
	tempT.X += tempX;
	tempT.Y += tempY;
	return tempT;

}

//Похоже, что когда игрок присоединяется, Вызывается функция StartMatch(), описанная в GameInfo
//Она вызывает Функцию StartBot, в которой переход в стейт Dead. Переопределяем этот стейт:
simulated state Dead
{
MPStart:
	GoToState('FollowPath');
}

//Если у бота нет первой точки пути, то он просто стоит
simulated state Teleportating
{
	ignores NotifyBump, Bump, HitWall,  PhysicsVolumeChange, Falling,  FellOutOfWorld;
Begin:
	if(Spawner!=none)
	{
		if(Spawner.RelocManager != none)
			Spawner.RelocManager.AddPawnToReloc(MyPawn);
	}
	else
	{
		//Значит, бот заспавнил не HumanBotSpawner
	}
}



simulated state WaitingForTime
{

	function bool CheckIsPathFreeFromCar()
	{
		local Vehicle act;
		foreach VisibleCollidingActors(class'Vehicle', act, 100.0, MyPawn.Location)
		{
			return false;
		}
		return true;
	}

	simulated event bool NotifyBump(Actor Other, Vector HitNormal)
	{
		local Vehicle v;
		v = Vehicle(Other);
		if(v!=none)
		{
			if(VSize(v.Velocity) >100)
			{
				MyPawn.GroundSpeed = 50;
				BumpAction(Other);
			}
		}
		return true;
	}
Begin:
	MyPawn.GroundSpeed = 0;
	sleep(4);
	if(CheckIsPathFreeFromCar())
	{
		MyPawn.GroundSpeed = 50;
		GoToState('FollowPath');
	}
	else
		goto 'Begin';
}

simulated state WaitingForTraffic
{
	simulated event bool NotifyBump(Actor Other, Vector HitNormal)
	{
		BumpAction(Other);
		return true;
	}
Begin:
    if(selectedPath<0)
	{
		GoToState('FollowPath');
	}
 	if(LastTarget.Paths[selectedPath].CanGo())
	{
		LastTarget.Paths[selectedPath].GoIn(MyPawn);
		GoToState('FollowPath');
	}
	else
		sleep(WaitingTime);
	goto 'Begin';
}

/** 
 *  Функция, в которой бот решает, надо ли перебегать дорогу */
function bool cross(Gorod_HumanBotPathNode crossPathNode, optional int chanceToCrossTheRoad =100)
{
	local int i;
	local bool isCroassed;
	i = rand(100);
	i+=1;
	if(i<=chanceToCrossTheRoad)
	{
		isCroassed = true;
		crossTarget = crossPathNode;
		bIsCrossingTheRoad = true;
		GoToState('CrossingTheRoad');
	}
	else
		isCroassed = false;

	return isCroassed;
}

simulated function bool IsVehicleNear()
{
	local Vehicle Vehic;
	local Vector HitLoc;
	local vector HitNorm;
	foreach TraceActors(class'Vehicle',Vehic,HitLoc,HitNorm,MyPawn.Location, crossTarget.Location )
	{
		if(Vehic!=none)
			return true;
	}
	return false;
}

/** Стейт перебегания дороги */
simulated state CrossingTheRoad
{
	ignores CheckObstacle;

	//если сбили
	simulated event bool NotifyBump(Actor Other, Vector HitNormal)
	{
		BumpAction(Other);
		return true;
	}
	/** В этой функции переходим в стейт CrossingTheRoad , на метку Check  (проверка на препядствие) */
	function Check()
	{
		if(IsVehicleNear())
			GotoState('Late');
	}

Begin:
	//бежим
	MyPawn.GroundSpeed=150;
	//если достигли точки в которую бежим, начинаем двигаться как обычно
	if(MyPawn.ReachedDestination(crossTarget))
	{
		ClearTimer('Check');
		PrevTarget = crossTarget;
		LastTarget  = crossTarget;
		Target = crossTarget;
		MyPawn.GroundSpeed=50;
		bIsCrossingTheRoad = false;
		GotoState('FollowPath');
	}
	else
	{
		//если есть препядствие, переходим в стейт, в котором ждем, когда припядствие исчезнет
		if(IsVehicleNear())
		{
			//Препядствие есть, опоздали. Ждем
		}
		//каждые дельтатайм проверяем, исчезло ли препядствие 
		SetTimer(0.5,true,'Check');
		sleep(0.1);
	 	MoveToward(crossTarget, crossTarget);
		goto 'Begin';
	}


}
/** Бот опоздал перебежать */
simulated state Late
{
	ignores CheckObstacle;

	simulated event bool NotifyBump(Actor Other, Vector HitNormal)
	{
		BumpAction(Other);
		return true;
	}
Begin:

	if(!IsVehicleNear())
	{
		GotoState('CrossingTheRoad');		
	}	
	sleep(0.1);
	//останавливаемся
	MoveTo(MyPawn.Location);

	goto 'Begin';

}


/** Выполняется, когда человека-бота толкают */
simulated function BumpAction(Actor Other)
{
	local Vehicle VN;
	//`log(Other);
	VN = Vehicle(Other);

	if(	VN !=none )
	{
		if(VSize(VN.Velocity)>100)
		{
			myPawn.HitLoc = VN.Location;
			Died();
			MyPawn.GroundSpeed=50;
			SendMsg(VN.Controller);
			myPawn.GoToState('Dying');
		}
		else
		{
			GotoState('WaitingForTime');
		}
	}
}


function SendMsg(Controller PC)
{
	local Common_PlayerController gpc;

	gpc = Common_PlayerController(PC);
	if(gpc==none)
		return;

	EventToSend = new class'Gorod_Event';
	EventToSend.sender = self;
	EventToSend.eventType = GOROD_EVENT_HUD;
	EventToSend.messageID = GOROD_PDD_ROAD_BUMP_HUMAN_BOT;
	if(gpc.EventDispatcher!=none)
		gpc.EventDispatcher.SendEvent(EventToSend);

}
function dontStuck()
{
	bStuck = false;
}
//не сейчас



DefaultProperties
{
	bIsFollowingOnFragmentedPath = false;
	bIsCrossingTheRoad = false;

	//pathFragmentation = 100
	actual_node = 0
	last_node = 0
	bIsPlayer = true
	bSeeFriendly = true
	bGodMode = true
	WaitingTime = 0.01
	selectedPath = -1;
	imprecision = 55;
	curPathFragmentation = 200;
	curPathOffset = 50;
	bStuck = false;
}
