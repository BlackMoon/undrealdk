class Gorod_CrossRoad extends Actor dependsOn(Gorod_CrossRoadsTrigger) placeable;

`include(Gorod_Events.uci);

/** Типы перекрестка */
enum CrossRoadType
{
	CROADTYPE_SIMPLE,           // перекресток без светофора
	CROADTYPE_TRAFFICLIGHT      // перекресток со светофором
};

enum CrossRoadEvents
{
	CREVT_MOVEONRED,                     // проезд на красный свет светофора
	CREVT_MOVEONGREEN,                   // проезд на зеленый свет светофора

	CREVT_ENTERFROMWRONGSIDE,            // заезд на перекресток с неправильной стороны
	CREVT_LEAVEFROMWRONGSIDE,            // выезд с перекрестка с неправильной стороны
};

/** Тип перекрестка */
var(CrossRoad) CrossRoadType CrossRoad_Type;

/** Меш триггера */
var(CrossRoad) StaticMeshComponent MeshBox;

/** Скелетал меш */
var(CrossRoad) SkeletalMeshComponent SkelBox;

/** Триггеры, принадлежащие перекрестку (указываются в редакторе) */
var(CrossRoad) array<Gorod_CrossRoadsTrigger> Triggers;

/** Массив для хранения игроков, вошедших на данный перекресток */
var array<Gorod_RegistryEntry> RegisteredControllers;

var int countTick;

var Gorod_Event EventToSend;

// Перекресток со сфетофорным регулированием ================================================
enum TrafficLightsState
{
	TLIGHTS_ON,             // светофоры работают
	TLIGHTS_OFF,            // светофоры полностью отключены
	TLIGHTS_DISABLED        // светофоры работают в режиме мигающего желтого
};

/** Текущий режим работы светофоров */ 
var(CrossRoad) TrafficLightsState CurrentTLState;

/** Время горения красного света светофора */
var(CrossRoad) float RedLightTime;

/** Время горения зеленого света светофора */
var(CrossRoad) float GreenLightTime;

/** Флаг разрешения движения по перекрестку (для перекрестков со светофором) */
var bool RedLightOn;

/** Время, прошедшее с начала горения какого либо из светов светофора */
var float LightTimeElapsed;

/** Время, после которого начинают работать светофоры */
var(CrossRoad) float LightWorkEnableTime;

/** Время начала работы светофоров */
var float LightWorkStartTime;

/** Время начала работы перекрестка */
var float CrossRoadWorkStartTime;

/** Флаг, характеризующий состояние регулирования перекрестка светофорами (true - светофоры работают )*/
var(CrossRoad) bool CrossRoadWorkingState;

/** Светофоры для транспорта */
//var(CrossRoad) array<Gorod_TrafficLight> TrafficLights;

var(CrossRoad) Gorod_TrafficLight TopTrafficLight;
var(CrossRoad) Gorod_TrafficLight BottomTrafficLight;
var(CrossRoad) Gorod_TrafficLight LeftTrafficLight;
var(CrossRoad) Gorod_TrafficLight RightTrafficLight;

//==========================================================================================================

/** Очередь ждущих проезда ботов */
var private array<AIController> WaitingBots;

/** Список всех путей перекрёстка */
var/*(CrossRoad)*/ array<Gorod_BasePath> Paths;

/** Множества путей в различных состояниях */
var private array<Gorod_BasePath> 
	OpenedPaths,            // открытые
	ClosedPaths,            // закрытые
	NonePaths;              // пути с неопределённым состоянием


struct CrossIndex
{
	var int A;
	var int B;
};

/** список пар пересекающихся Path'ов, задаётся в виде пар индексов из массива Paths */
var array<CrossIndex> Crosses;

var private Gorod_Event EventToDisp;

simulated function PostBeginPlay()
{
	local Gorod_CrossRoadsTrigger T;
	local int i, j;

	// Устанавливаем тип коллизии
	SetCollisionType(COLLIDE_TouchAll);

	// Указываем всем триггерам ссылку на данный экземпляр класса
	foreach Triggers(T)
	{
		T.ParentCrossroad = self;
	}

	CrossRoadWorkStartTime = WorldInfo.TimeSeconds;
	
	// сравниваем пути каждый с каждым и заполняем массив Crosses парами смежных вершин
	for(i = 0; i < Paths.Length; i++)
	{
		// изначально добавляем все пути во множество путей с неопрделённым состоянием
		NonePaths.AddItem(Paths[i]);

		Paths[i].RegCrossRoad(self);

		for(j = i+1; j < Paths.Length; j++)
		{
			Paths[i].PathState = PS_None;

			if(PathCross(Paths[i], Paths[j]))
			{
				Crosses.Add(1);
				Crosses[Crosses.Length - 1].A = i;
				Crosses[Crosses.Length - 1].B = j;
			}
		}
	}

	EventToDisp = new class'Gorod_Event';
	EventToDisp.eventType = GOROD_EVENT_PDD;

	EventToSend = new class'Gorod_Event';
	EventToSend.eventType = GOROD_EVENT_HUD;
	EventToSend.sender=self;
}

function ReportPaths()
{
	local Gorod_BasePath p;

	`log("OPENED");
	foreach OpenedPaths(p)
	{
		`log(p @ p.DrivingPawns.Length @ p.WantToDrivePawns.Length @ p.CanGo());
	}
	`log("CLOSED");
	foreach ClosedPaths(p)
	{
		`log(p @ p.DrivingPawns.Length @ p.WantToDrivePawns.Length @ p.CanGo());
	}
	`log("NONE");
	foreach NonePaths(p)
	{
		`log(p @ p.DrivingPawns.Length @ p.WantToDrivePawns.Length @ p.CanGo());
	}
}

/** Запрос на регистрацию бота в очередь на проезд перекрестка */
function RegisterBotInQueue(AIController bot)
{
	WaitingBots.AddItem(bot);
}

/************************************************************************/
/*          Вычисление матрицы смежности пересекающихся путей           */
/************************************************************************/

/**
 * Проверка на пересечение двух путей
 */
function bool PathCross(Gorod_BasePath P1, Gorod_BasePath P2)
{
	local int i1, i2, i;
	
	if (P1 == none || P2 == none || P1.PathNodes.Length == 0 || P2.PathNodes.Length == 0)
		return false;
	
	if(P1.PathNodes[0] == P2.PathNodes[0])
		i = 1;
	else
		i = 0;

	// сравниваем отрезки путей P1 и P2 каждый с каждым
	for(i1 = i; i1 < P1.PathNodes.Length - 1; i1++)
	{
		for(i2 = i; i2 < P2.PathNodes.Length - 1; i2++)
		{
			if (P1.PathNodes[i1] != none && P2.PathNodes[i2] != none && P1.PathNodes[i1+1] != none && P2.PathNodes[i2+1] != none)
			if(PathSectionCross(P1.PathNodes[i1].Location, P1.PathNodes[i1+1].Location, P2.PathNodes[i2].Location, P2.PathNodes[i2+1].Location))
				return true;
		}
	}

	return false;
}

/**
 * Вычисляет являются ли отрезки [A1; A2] и [A3; A4] пересекающимися. CrossPoint - точка пересечения прямых, на которых упомянутые отрезки (если не пересекаются - none)
 */
function bool PathSectionCross(Vector A1, Vector A2, Vector A3, Vector A4, optional out Vector CrossPoint)
{	
	local float Ua, Ub, Zn;
	local float eps;

	// Вычисляем, пересекаются ли отрезки, игнорируя координату Z (описание здесьhttp://algolist.manual.ru/maths/geom/intersect/lineline2d.php)
	
	eps = 0.0001;

	Zn = (A4.Y-A3.Y)*(A2.X-A1.X) - (A4.X-A3.X)*(A2.Y-A1.Y);
	
	// пока вычисляем только числители
	Ua = ((A4.X-A3.X)*(A1.Y-A3.Y) - (A4.Y-A3.Y)*(A1.X-A3.X));
	Ub = ((A2.X-A1.X)*(A1.Y-A3.Y) - (A2.Y-A1.Y)*(A1.X-A3.X));

	if(Abs(Zn) < eps)
	{
		if(Abs(Ua) < eps)
		{
			// прямые совпадают, отрезки лежат на одной прямой 
			if(PathSectionContainsPoint(A1, A2, A3))
				// если A3 лежит на отрезке [A1; A2]
				return true;
			else if(PathSectionContainsPoint(A1, A2, A4))
				// если A4 лежит на отрезке [A1; A2]
				return true;
			else
				return false;
		}
		else
		{
			// прямые параллельны
			return false;
		}
	}

	Ua /= Zn;

	CrossPoint = A1 + Ua*(A2 - A1);

	if(Ua < -0.0001 || Ua > 1.0001)
		// Отрезок A пересекается за своими границами
		return false;

	Ub /= Zn;
	if(Ub < -0.0001 || Ub > 1.0001)
		// Отрезок B пересекается за своими границами
		return false;
	
	return true;
}

function bool PathSectionContainsPoint(Vector A1, Vector A2, Vector A)
{
	local float p;

	p = (A.X - A2.X)/(A1.X - A2.X);
	if(Abs((A.Y - p*A1.Y + (1 - p)*A2.Y)) < 0.0001)
		return true;
	else
		return false;
}

/**
 * Открывает движение по пути path
 */
function SetClosedFor(Gorod_BasePath path)
{
	local CrossIndex CI;
	
	// закрываем пересекающиеся пути
	foreach Crosses(CI)
	{
		if(Paths[CI.A] == path)
			MoveToClosed(Paths[CI.B]);
		else if(Paths[CI.B] == path)
			MoveToClosed(Paths[CI.A]);
	}
}

function UpdatePaths()
{
	local Gorod_BasePath P, CurrentPath;
	local AIController VC;
	local Pawn WantToDrivePawn;
	local Gorod_AIVehicle_Controller carCtrl;
	local Gorod_HumanBotAiController botCtrl;
	
	// очищаем ClosedPaths
	while (ClosedPaths.Length > 0)
	{
		NonePaths.AddItem(ClosedPaths[0]);
		ClosedPaths.Remove(0, 1);
	}

	// добавляем все красные пути в ClosedPaths
	foreach Paths(P)
	{
		if(P.bIsClosed)
		{
			ClosedPaths.AddItem(P);
			OpenedPaths.RemoveItem(P);
			NonePaths.RemoveItem(P);
		}
	}

	// Для каждого красного пути, по которому ещё движутся боты (завершающие манёвр)
	// добавляем пересекающиеся с ним пути в ClosedPaths
	foreach Paths(P)
	{
		if(P.bIsClosed && P.DrivingPawns.Length > 0)
		{
			SetClosedFor(P);
		}
	}

	// из P1 в P3 перемещаем пути, по которым не едут и не хотят ехать боты
	foreach OpenedPaths(P)
	{
		if(P.DrivingPawns.Length == 0 && P.WantToDrivePawns.Length == 0)
		{
			OpenedPaths.RemoveItem(P);
			NonePaths.AddItem(P);
		}
	}

	// Расчитываем закрытые пути в соответствии с P1
	foreach OpenedPaths(P)
	{
		SetClosedFor(P);
	}

	// обрабатываем пути по которым хотя ехать боты,
	// учитывая порядок регистрации ботов на перекрёстке
	foreach WaitingBots(VC)
	{
		// если бот выбрал путь который находится в NonePaths и ещё не едет по нему, то
		// открываем этот путь
		carCtrl = Gorod_AIVehicle_Controller(VC);
		if(carCtrl != none)
		{
			CurrentPath = carCtrl.CurPath;
			WantToDrivePawn = carCtrl.ControlledCar;
		}

		botCtrl = Gorod_HumanBotAiController(VC);
		if(botCtrl != none && botCtrl.Target != none)
		{
			if(botCtrl.Target.Paths.Length > 0 && botCtrl.selectedPath >= 0 && botCtrl.selectedPath < botCtrl.Target.Paths.Length)
			{
				CurrentPath = botCtrl.Target.Paths[botCtrl.selectedPath];
				WantToDrivePawn = botCtrl.MyPawn;
			}
		}
				
		if(CurrentPath != none && NonePaths.Find(CurrentPath) != INDEX_NONE && CurrentPath.WantToDrivePawns.Find(WantToDrivePawn) != INDEX_NONE)
		{
			OpenedPaths.AddItem(CurrentPath);
			NonePaths.RemoveItem(CurrentPath);
			SetClosedFor(CurrentPath);
		}
	}
	
	// обновляем состояния путей
	foreach OpenedPaths(P)
	{
		//if(P.PathState != PS_Opened)
		//	P.DrawLines(0, 255);

		P.PathState = PS_Opened;
	}

	foreach ClosedPaths(P)
	{
		//if(P.PathState != PS_Closed)
		//	P.DrawLines(255, 0);

		P.PathState = PS_Closed;
		
	}

	foreach NonePaths(P)
	{
		//if(P.PathState != PS_None)
		//	P.DrawLines(0, 0);

		P.PathState = PS_None;
	}
}

/** 
 * Перемещает путь из множества путей с неопределённым состоянием во множество закрытых путей
 */
function MoveToClosed(Gorod_BasePath path)
{
	if(ClosedPaths.Find(path) == -1)
	{
		NonePaths.RemoveItem(path);
		ClosedPaths.AddItem(path);
	}
}

/**
 * RegisterController - регистрирует вошедшего на перекресток игрока
 */
function RegisterController(Controller c)
{
	local Gorod_RegistryEntry re;

	re = new class'Gorod_RegistryEntry';

	re.pc = c;

	RegisteredControllers.AddItem(re);
}

/**
 * RemoveController - удаляет игрока из базы зарегистрированных игроков
 */
function RemoveController(name nm)
{
	local int i;
	local PlayerController pc;

	for(i=0; i<RegisteredControllers.Length; i++)
	{
		if(RegisteredControllers[i].pc.Name == nm)
		{
			foreach WorldInfo.AllControllers(class'PlayerController', pc)
			{
				//pc.ClientMessage("Controller removed: " $ nm);
			}
			RegisteredControllers.Remove(i, 1);
			break;
		}
	}
}

/**
 * GetRegEntryByName - ищет контроллера в базе, если находит - возвращает запись о нем
 */
function Gorod_RegistryEntry GetRegEntryByName(name nm)
{
	local Gorod_RegistryEntry rentry;
	local int i;

	for(i=0; i<RegisteredControllers.Length; i++)
	{
		if(RegisteredControllers[i].pc.Name == nm)
		{
			rentry = RegisteredControllers[i];
			break;
		}
	}

	return rentry;
}


event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	local Controller pc;
	local Gorod_RegistryEntry RG;
	local Common_PlayerController playc;

	// если касатель - машина игрока
	if(Zarnitza_VehicleTouchHelperActor(Other) != none)
	{
		playc = Common_PlayerController(Zarnitza_VehicleTouchHelperActor(Other).PC);

		if(playc != none)
		{

			// регистрируем игрока в базе
			RG = GetRegEntryByName(playc.Name);
			if(RG == none)
			{
				RegisterController(playc);
			}
			else
			{
				// контроллер коснулся перекрестка, будучи уже зарегистрированным. Такого не должно быть
				`warn("Controller touch crossroads when its already registered");
			}

			EventToDisp.messageID = 3011;//GOROD_PDD_CROSSROAD_ENTER
			EventToDisp.eventType = GOROD_EVENT_PDD;
			playc.EventDispatcher.SendEvent(EventToDisp);
		}

		return;
	}

	// проверяем, является ли касатель контроллером
	pc = Controller(Other.Owner);

	if(pc != none)
	{
		RG = GetRegEntryByName(pc.Name);
		if(RG == none)
		{
			RegisterController(pc);
		}
		else
		{
			// контроллер коснулся перекрестка, будучи уже зарегистрированным. Такого не должно быть
			`warn("Controller touch crossroads when its already registered");
		}
	}
}

event UnTouch( Actor Other )
{
	local Controller c;
	local Gorod_RegistryEntry rentry;
	local int i;
	local Common_PlayerController playc;

	// проверяем, является ли касатель машиной игрока
	if(Zarnitza_VehicleTouchHelperActor(Other) != none)
	{
		playc = Common_PlayerController(Zarnitza_VehicleTouchHelperActor(Other).PC);

		if(playc != none)
		{
			rentry = GetRegEntryByName(playc.Name);
			if(rentry != none)
			{
				// удаляем контроллер
				RemoveController(playc.Name);

				// посылаем сообщение
				EventToDisp.messageID = 3012;//GOROD_PDD_CROSSROAD_EXIT
				EventToDisp.eventType = GOROD_EVENT_PDD;
				playc.EventDispatcher.SendEvent(EventToDisp);
			}
			else
			{
				// игрок не зарегистрирован - такого быть не должно
				`warn(playc @ "not registered when it leaving crossroad");
			}
		}

		return;
	}

	// проверяем, является ли касатель контроллером  ---------------------------------------------------------------
	if(Controller(Other.Owner) == none)
		return;
	else
		c = Controller(Other.Owner);

	rentry = GetRegEntryByName(c.Name);

	if(rentry != none)
	{
		if(Gorod_AIVehicle_Controller(rentry.pc) != none)
		{
			// если это бот, удаляем его из очереди на проезд перекрестка
			for(i=0; i<WaitingBots.Length; i++)
			{
				if(WaitingBots[i].Name  == c.Name)
				{
					WaitingBots.Remove(i, 1);
					break;
				}
			}
		}
		
		// удаляем контроллер
		RemoveController(c.Name);
	}
	else
	{
		// попадаем сюда, если контроллер не зарегистрирован. Такого быть не должно
		//`warn("You have not registered yet " $ c.Name);
	}
}

simulated function Tick( FLOAT DeltaSeconds ) 
{
	// здесь следует обновлять показания светофоров
	super.Tick(DeltaSeconds);

	// проверка ситуации на дороге, в соответствии с этим - раздача разрешений на проезд ботам
	// непонятный код, закомментировал.
	/*
	if(RegisteredControllers.Length == 0 && WaitingBots.Length > 0)
	{
		//WaitingBots[0].ControlledCar.Target.Open();
	}
	else
	{
		//
	}
	*/

	if(CrossRoad_Type == CROADTYPE_TRAFFICLIGHT)
	{
		UpdateTrafficLights(DeltaSeconds);
	}

	countTick ++;
	if (countTick > 5)
	{
		UpdatePaths();
		countTick = 0;
	}
	
}

/// !!!!!!
function UpdateTrafficLights(float delta)
{
	local float CurTime;

	CurTime = WorldInfo.TimeSeconds;

	switch(CurrentTLState)
	{
	case TLIGHTS_ON:
		if(LightWorkEnableTime <= CurTime - CrossRoadWorkStartTime && CrossRoadWorkingState == false)
		{
			LightWorkStartTime = CrossRoadWorkStartTime + LightWorkEnableTime;
			CrossRoadWorkingState = true;
			RedLightOn = true;
		}

		// светофоры включены
		if(CrossRoadWorkingState == true)
		{
			if(RedLightOn == true)
			{
				if(CurTime >= LightTimeElapsed + RedLightTime)
				{
					
				}
			}
		}
		break;

	case TLIGHTS_OFF:
		break;

	case TLIGHTS_DISABLED:
		break;

	default:
	}

	
}

/**
 * OnTriggerTouch - функция вызывается при касании одного из триггеров, принадлежащих данному перекрестку 
 */ 
function OnTriggerTouch(Gorod_CrossRoadsTrigger trg, Actor toucher)
{
	local Gorod_RegistryEntry rentry;
	local Zarnitza_VehicleTouchHelperActor helper;

	// проверяем, является ли касатель игроком
	helper = Zarnitza_VehicleTouchHelperActor(toucher);

	if(helper == none)
		return;

	if(Common_PlayerController(helper.PC) != none)
	{
		// касатель - игрок, ищем его в базе зарегистрированных игроков
		rentry = GetRegEntryByName(Common_PlayerController(helper.PC).Name);

		if(rentry.pc != none)
		{
			// игрок уже зарегистрирован, проверяем
			CheckTrigger(trg, rentry);
			//Gorod_PlayerController(rentry.pc).ClientMessage(rentry.Message);

			// #ToDo SendEvent
			// Gorod_PlayerController(rentry.pc).ClientShowMsg(MESSAGE_INFORM, rentry.Message);
			//Gorod_PlayerController(rentry.pc).MessageManager.PushMessage(rentry.Message);
			//Gorod_PlayerController(rentry.pc).showMsg();
		}
		else
		{
			// игрока нет в базе, выходим
			//Gorod_PlayerController(rentry.pc).ClientMessage("You are not registered");

			// #ToDo SendEvent
			// Gorod_PlayerController(rentry.pc).ClientShowMsg(MESSAGE_INFORM, "You are not registered");

		}
		return;
	}
}

/** 
 *  OnTriggerUnTouch - вызывается триггером, из области которого вышел игрок 
 */
function OnTriggerUnTouch(Gorod_CrossRoadsTrigger trg, Actor toucher)
{
	//
}

/** 
 *  CheckTrigger - проверка триггера, которого коснулся игрок
 */
function CheckTrigger(Gorod_CrossRoadsTrigger trg, out Gorod_RegistryEntry rentry)
{
	local TriggerReference local_trRef;
	//----------------------------------------------------------------------------------------------------------------------------------------------
	rentry.Message = "";

	switch(CrossRoad_Type)
	{
	case CROADTYPE_SIMPLE:
		switch(trg.trType)
		{
		case TRIGGERTYPE_ENTRY:
			// проверяем, в первый ли раз игрок коснулся какого либо триггера
			if(rentry.GetFirstTouchedTrigger() != none)
			{
				rentry.Message = "";

				// уже коснулся, ищем этот триггер в присвоенных игроку списках
				
				local_trRef = rentry.GetFirstTouchedTrigger().FindTriggerReference(trg);

				if(local_trRef.MessageID > 0)
				{
					EventToDisp.messageID = rentry.GetFirstTouchedTrigger().FindTriggerReference(trg).MessageID;
					EventToDisp.eventType = GOROD_EVENT_PDD;
					Common_PlayerController(rentry.pc).EventDispatcher.SendEvent(EventToDisp);

					if(local_trRef.bShowMessageInHUD)
					{
						EventToDisp.eventType = GOROD_EVENT_HUD;
						Common_PlayerController(rentry.pc).EventDispatcher.SendEvent(EventToDisp);
					}
				}
				EventToDisp.eventType = GOROD_EVENT_HUD;
				Common_PlayerController(rentry.pc).EventDispatcher.SendEvent(EventToDisp);			
			}
			else
			{
				// коснулся впервые, присваиваем зарегистрированному игроку настройки этого триггера
				rentry.AddFirstTouchedTrigger(trg);
			}
			break;
	
		case TRIGGERTYPE_INVALIDENTRY:
			// проверяем, в первый ли раз игрок коснулся какого либо триггера
			if(rentry.GetFirstTouchedTrigger() != none)
			{
				// уже коснулся
				rentry.AddEvent(CREVT_LEAVEFROMWRONGSIDE);
			}
			else
			{
				// коснулся впервые, присваиваем зарегистрированному игроку настройки этого триггера
				rentry.AddFirstTouchedTrigger(trg);
				rentry.AddEvent(CREVT_ENTERFROMWRONGSIDE);
			}
			break;

		default:
			break;
		}
		break;

	//--------------------------------------------------------------------------------------------------------------------------------------------------
	case CROADTYPE_TRAFFICLIGHT:
		switch(trg.trType)
		{
		case TRIGGERTYPE_ENTRY:
			if(rentry.GetFirstTouchedTrigger() != none)
			{
				// уже коснулся
				

				// проверяем, проехал ли игрок на красный свет до касания этого триггера
				if(rentry.FindEvent(CREVT_MOVEONRED) == false)
				{
					// не проезжал, значит посылаем событие, записанное в триггере.
					
					local_trRef = rentry.GetFirstTouchedTrigger().FindTriggerReference(trg);

					if(local_trRef.MessageID > 0)
					{
						EventToDisp.messageID = rentry.GetFirstTouchedTrigger().FindTriggerReference(trg).MessageID;
						EventToDisp.eventType = GOROD_EVENT_PDD;
						Common_PlayerController(rentry.pc).EventDispatcher.SendEvent(EventToDisp);

						if(local_trRef.bShowMessageInHUD)
						{
							EventToDisp.eventType = GOROD_EVENT_HUD;
							Common_PlayerController(rentry.pc).EventDispatcher.SendEvent(EventToDisp);
						}
					}					
				}
				else
				{
					// проезжал на красный свет до касания этого триггера
					// в этом случае ничего не делаем
				}

			}
			else
			{
				// коснулся впервые
				rentry.AddFirstTouchedTrigger(trg);

				// если триггер заблокирован, значит его запрещается проезжать (скорее всего он заблокирован светофором)
				if(trg.IsBlocked)
				{
					// проверяем, проехал ли игрок на запрещающий сигнал какой-либо из доп. секций
					if(trg.bControlByLeftSection)
					{
						// проехал на запрещающий сигнал левой секции
						EventToDisp.messageID = 3042;
						EventToDisp.eventType = GOROD_EVENT_PDD;
						Common_PlayerController(rentry.pc).EventDispatcher.SendEvent(EventToDisp);
						EventToDisp.eventType = GOROD_EVENT_HUD;
						Common_PlayerController(rentry.pc).EventDispatcher.SendEvent(EventToDisp);
					}
					else if(trg.bControlByRightSection)
					{
						// проехал на запрещающий сигнал правой секции
						EventToDisp.messageID = 3043;
						EventToDisp.eventType = GOROD_EVENT_PDD;
						Common_PlayerController(rentry.pc).EventDispatcher.SendEvent(EventToDisp);
						EventToDisp.eventType = GOROD_EVENT_HUD;
						Common_PlayerController(rentry.pc).EventDispatcher.SendEvent(EventToDisp);
					}
					else
					{
						// проехал на красный свет
						EventToDisp.messageID = 3005;//GOROD_PDD_CROSSROAD_MOVE_ON_RED
						EventToDisp.eventType = GOROD_EVENT_PDD;
						Common_PlayerController(rentry.pc).EventDispatcher.SendEvent(EventToDisp);
						EventToDisp.eventType = GOROD_EVENT_HUD;
						Common_PlayerController(rentry.pc).EventDispatcher.SendEvent(EventToDisp);
					}

					// пока считаем, что игрок проехал на красный, даже если проезд запрещен доп.секцей
					rentry.AddEvent(CREVT_MOVEONRED);

				}
				else
				{
					// посылаем сообщение о том, что игрок проехал на зеленый свет
					EventToDisp.messageID = 3006;//GOROD_PDD_CROSSROAD_MOVE_ON_GREEN
					EventToDisp.eventType = GOROD_EVENT_PDD;
					Common_PlayerController(GetALocalPlayerController()).EventDispatcher.SendEvent(EventToDisp);
				}
			}
			break;

		///////////////////////////////////////////
		case TRIGGERTYPE_INVALIDENTRY:
			// если уже коснулся
			if(rentry.GetFirstTouchedTrigger() != none)
			{
				rentry.AddEvent(CREVT_LEAVEFROMWRONGSIDE);
				EventToDisp.messageID = 3021;
				EventToDisp.eventType = GOROD_EVENT_PDD;
				Common_PlayerController(rentry.pc).EventDispatcher.SendEvent(EventToDisp);
				EventToDisp.eventType = GOROD_EVENT_HUD;
				Common_PlayerController(rentry.pc).EventDispatcher.SendEvent(EventToDisp);
			}
			// еще не коснулся
			else
			{
				rentry.AddFirstTouchedTrigger(trg);
				rentry.AddEvent(CREVT_ENTERFROMWRONGSIDE);

				EventToDisp.messageID = 3020;
				EventToDisp.eventType = GOROD_EVENT_PDD;
				Common_PlayerController(rentry.pc).EventDispatcher.SendEvent(EventToDisp);
				EventToDisp.eventType = GOROD_EVENT_HUD;
				Common_PlayerController(rentry.pc).EventDispatcher.SendEvent(EventToDisp);
				//rentry.Message = "You entered to crossroad from wrong side";
			}
			break;
		

		/////////////////////////////////////////////////
		case TRIGGERTYPE_EXIT:
			// если уже касался
			if(rentry.GetFirstTouchedTrigger() != none)
			{
				// проверяем, проехал ли игрок на красный свет до касания этого триггера
				if(rentry.FindEvent(CREVT_MOVEONRED) == false)
				{
					// не проезжал
					rentry.Message = rentry.GetFirstTouchedTrigger().FindTriggerReference(trg).Message;
				}
				else
				{
					//
				}
			}
			// еще не касался
			else
			{
				rentry.AddFirstTouchedTrigger(trg);
			}
			break;

		default:
		}
		break;
	default:
	}

}

defaultproperties
{
	Begin Object Class=StaticMeshComponent Name=SBox 
		StaticMesh = StaticMesh'Tools_1.Meshes.S_Crossroad_1'
		CollideActors = true
		BlockActors = false
		RBChannel=RBCC_GameplayPhysics
		RBCollideWithChannels=(Default=TRUE,BlockingVolume=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE,Vehicle=TRUE)
		HiddenGame = true
	End Object
	Components.Add(SBox);
	MeshBox = SBox
	CollisionComponent = SBox

	CrossRoad_Type = CROADTYPE_SIMPLE

	GreenLightTime = 5.0;
	RedLightTime = 5.0;

	CurrentTLState = TLIGHTS_ON
	CrossRoadWorkingState = false
	RedLightOn = false
}
