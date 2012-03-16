class Kamaz_Checker_Autodrom extends Actor implements (Gorod_ActorWithTriggers_Interface, Gorod_EventListener) placeable;
`include(Gorod\Gorod_Events.uci);

/** Триггеры въезда на автодром */
var() array<Kamaz_Checker_AutodromTrigger> StartTriggerVolumes;

/** Триггеры выезда с автодрома */
var() array<Kamaz_Checker_AutodromTrigger> FinishTriggerVolumes;

/** Триггеры подсказок о направлении движения на автодроме */
var() array<Kamaz_Checker_AutodromTrigger_Hint> PathHintsTriggerVolumes;

/** Список упражнений на автодроме */
var() array<Kamaz_Cheker_ExerciseBase> Exercises;

/** Индекс упражнения, которое выполняет игрок в данный момент */
var int CurrentExerciseIndex;

/** Машина игрока, параметры которой отслеживаются при проезде автодрома  */
var() private PlayerCarBase VehicleForCheck;

/** Маршрут движения по автодрому (список точек, которые игрок должен последовательно проехать) */
var() array<Kamaz_ExercisePoint> Path;
/** Индекс точки, к которой игрок должен ехать в данный момент */
var private int PathIndex;

/** Флаг, задающий необходимость проверки правильности прохождения маршрута (во время прохождения конкретного задания маршрут не отслежиается) */
var private bool bPathCheck;

/** Контроллер игрока */
var private Kamaz_PlayerController CurrentPlayerController;

/** Ссылка на объект для рассылки событий */
var private Gorod_Event EventToSend;

/** Ссылка на справочник с сообщениями от автодрома */
var Kamaz_AutodromMessages AutodromMessages;

/** Флаг, показывающий что автодром зарегистрирован в менеджере справочников */
var private bool bHasRegisteredInMessagesManager;

/** Флаг, показывающий что автодром зарегистрирован в рассыльщике событий */
var private bool bHasRegisteredInEventDispatcher;

/** Флаг. показывающий, что игрок находится на автодроме */
var private bool bHasPlayer;
/** StaticMeshActor - границы (зоны) выполнения заданий */
var private Kamaz_Checker_AutodromBorder bdrFront, bdrBack;

/** Флаг, показывающий, что автодром работает */
var bool bEnabled;

var() bool bVisualHintsEnabled;

simulated event PostBeginPlay()
{	
	local Kamaz_Checker_AutodromTrigger t;
	local Kamaz_Checker_AutodromTrigger_Hint t1;
	local Kamaz_Cheker_ExerciseBase Ex;

	super.PostBeginPlay();

	// скрываем триггеры выезда
	SetHiddenFinishTriggers(true);

	// получаем контроллер игрока
	CurrentPlayerController = Kamaz_PlayerController(GetALocalPlayerController());

	// если тип игры - не Gorod_Game или PlayerController не объект класса Gorod_PlayerController, то не включаем автодром
	if(Kamaz_Game(WorldInfo.Game) == none || CurrentPlayerController == none)
	{
		GotoState('Idle');
		return;
	}

	CurrentPlayerController.CheckerAutodrom = self;

	foreach StartTriggerVolumes(t)
		t.ActorWithTriggers = self;

	foreach FinishTriggerVolumes(t)
		t.ActorWithTriggers = self;

	foreach PathHintsTriggerVolumes(t1)
		t1.ActorWithTriggers = self;

	foreach Exercises(Ex)
		Ex.Autodrom = self;

	// Создание объекта для рассылки событий
	EventToSend = new class'Gorod_Event';
	EventToSend.sender = self;
	EventToSend.eventType = GOROD_EVENT_HUD;

	// Создаём и регистрируем объект справочника сообщений от автодрома
	AutodromMessages = new class'Kamaz_AutodromMessages';
	AutoDromMessages.checkConfig();
	RegisterInMessagesManager();	

	CurrentExerciseIndex = 0;
}

// стейт, в котором автодром ничего не делает
simulated state Idle
{
}

/** Обработчик прикосновения к одному из триггеров из StartTriggerVolumes или FinishTriggerVolumes */
function OnTriggerTouch(Actor Sender, Actor Other)
{
	local PlayerCarBase v;
	local Kamaz_Checker_AutodromTrigger_Hint hint;

	if(!bEnabled) return;

	v = PlayerCarBase(Other);
	if(v == none) return;

	if(!bHasPlayer)
	{
		if(StartTriggerVolumes.Find(Sender) != INDEX_NONE)
		{
			StartAutodromCheck(v);
			SendAutodromEvent(self, 1000);
		}
	}
	else
	{
		if(FinishTriggerVolumes.Find(Sender) != INDEX_NONE)
		{
			StopAutodromCheck();
			SendAutodromEvent(self, 1001);
			SetEnadled(false);
		}
		else
		{
			hint = Kamaz_Checker_AutodromTrigger_Hint(Sender);
			if(hint != none && PathHintsTriggerVolumes.Find(hint) != INDEX_NONE)
			{
				switch(hint.HintMessage)
				{
					case HMT_DRIVE_LEFT:
						SendAutodromEvent(self, GOROD_EVENT_DRIVE_LEFT);
						break;
					case HMT_DRIVE_RIGHT:
						SendAutodromEvent(self, GOROD_EVENT_DRIVE_RIGHT);
						break;
					case HMT_DRIVE_FORWARD:
						SendAutodromEvent(self, GOROD_EVENT_DRIVE_FORWARD);
						break;
				}
			}
		}
	}
}

/** Обработчик при завершении каания одного из триггеров StartTriggerVolumes или FinishTriggerVolumes (объявлена для реализации интерфейса Gorod_ActorWithTriggers_Interface) */
function OnTriggerUnTouch(Actor Sender, Actor Other)
{
}

/** Функция показывает/скрывает границы заданий */
function showBrdMeshes(optional bool bshow = true)
{
	bdrFront.BorderMesh.SetHidden(!bshow);
	bdrBack.BorderMesh.SetHidden(!bshow);	
}
/** Функция создания/установки 2х StaticMesh - границ заданий (фронтальная - зеленого цвета, задняя - красного цвета);
 *  входные параметры:
 *  - locF, rotF - (location, rotator фронтальной границы);
 *  - locB, rotB - (location, rotator задней границы).
 */
function setBrdMeshes(vector locF, vector locB, rotator rotF, rotator rotB)
{
	local LinearColor clr;

	if(bVisualHintsEnabled)
	{
		// front
		if (bdrFront == none)
		{
			bdrFront = Spawn(class'Kamaz_Checker_AutodromBorder', self, 'front');				
			clr.R = 0;
			clr.g = 1.0f;
			clr.B = 0;		
			bdrFront.setColor(clr);
		}
		bdrFront.setLocation(locF);
		bdrFront.SetRotation(rotF);	
		// back
		if (bdrBack == none)
		{
			bdrBack = Spawn(class'Kamaz_Checker_AutodromBorder', self, 'back');		
			clr.R = 1.0f;
			clr.g = 0;
			clr.B = 0;		
			bdrBack.setColor(clr);		
		}
		bdrBack.setLocation(locB);
		bdrBack.SetRotation(rotB);
	
		showBrdMeshes();
	}
}

/** Регистрирует автодром в менеджере сообщений */
function RegisterInMessagesManager()
{
	// Если менеджер сообщений уже появился,
	if(CurrentPlayerController.MessagesManager != none)
	{
		// регистрируемся
		CurrentPlayerController.MessagesManager.Register(AutodromMessages);
		bHasRegisteredInMessagesManager = true;
	}
	else
	{
		// иначе ждём 1 сек и пробуем снова
		SetTimer(1, false, 'RegisterInMessagesManager');
	}
}

/** Регистрирует автодром в рассыльщике событий */
function RegisterInEventDispatcher()
{
	// Если рассыльщик событий уже есть
	if(CurrentPlayerController.EventDispatcher != none)
	{
		// регистрируемся
		CurrentPlayerController.EventDispatcher.RegisterListener(self, GOROD_EVENT_PDD);
		bHasRegisteredInEventDispatcher = true;
	}
	else
	{
		// иначе ждём 1 сек и пробуем снова
		SetTimer(1, false, 'RegisterInEventDispatcher');
	}
}

/** Отмена регистрации в рассыльщике событий */
function UnRegisterInEventDispatcher()
{
	CurrentPlayerController.EventDispatcher.RemoveListener(self);
}

simulated event Tick(float DeltaSeconds)
{
	super.Tick(DeltaSeconds);

	// если ещё не зарегистрировались в менеджере сообщений, не тикаем
	if(!bHasRegisteredInMessagesManager) return;

	if(bPathCheck)
	{
		CheckPath();
	}
}

/** Начинает проверку прохождения автодрома */
function StartAutodromCheck(PlayerCarBase v)
{
	local Kamaz_Checker_AutodromTrigger_Hint t1;

	// сохр. ссылку на машину, которую будем отслеживать
	VehicleForCheck = v;

	// вкл. первое упражнение
	CurrentExerciseIndex = 0;
	Exercises[0].StartWaitForPlayer();
	
	// начинаем отслеживание маршрута движения с первой точки
	PathIndex = 0;
	bPathCheck = true;

	// вкл. флаг нахождения игрока на автодроме
	bHasPlayer = true;

	foreach PathHintsTriggerVolumes(t1)
		t1.bEnabled = true;

	RegisterInEventDispatcher();
}

/** Завершает проверку прохождения автодрома */
function StopAutodromCheck()
{
	local Kamaz_Checker_AutodromTrigger_Hint t1;

	if(Exercises[CurrentExerciseIndex] != none)
	{
		Exercises[CurrentExerciseIndex].CancelCheck();
	}

	bPathCheck = false;
	bHasPlayer = false;

	SetHiddenFinishTriggers(true);

	UnRegisterInEventDispatcher();

	foreach PathHintsTriggerVolumes(t1)
		t1.bEnabled = false;

	SetEnadled(false);
}

simulated function SetEnadled(bool bNewEnabled)
{
	bEnabled = bNewEnabled;
}

/** Проверяет правильность движения игрока по маршруту */
function CheckPath()
{
	local Vector VehicLoc, Point1, Point2, v;
	local float dist;

	if(VehicleForCheck == none)
		return;

	if(PathIndex < Path.Length - 1)
	{
		// координаты машины игрока
		VehicLoc = VehicleForCheck.Location;

		// координаты очередной и предыдущей точек маршрута
		Point1 = Path[PathIndex].Location;
		Point2 = Path[PathIndex+1].Location;

		// вычисляем расстояние от машины до отрезка [Point1; Point2]
		dist = PointDistToSegment(VehicLoc, Point1, Point2, v);

		if(v == Point2)
		{
			// доехали до следующего участка пути
			PathIndex++;
			return;
		}
		
		if(dist > 3000)
		{
			// слишком далеко уехали с маршрута
			SendAutodromEvent(self, 1023);
			StopAutodromCheck();
		}
		else if(dist > 1000)
		{
			// отклонились от маршрута			
			SendAutodromEvent(self, 1009);
		}
	}
}

/** Уведомляет автодром о начале выполнения упражнения */
function ExerciseStarted(Kamaz_Cheker_ExerciseBase Ex)
{
	// если начинаем упражнение не в соответствии с порядком упражнений в списке упражнений,
	// выводим warning - такого не должно быть
	if(Exercises[CurrentExerciseIndex] != Ex)
	{
		`warn("Fialed to start exercise" @ Ex @ " - wrong order. Starting exercise" @ Exercises[CurrentExerciseIndex]);
		Ex.CancelCheck();
		Exercises[CurrentExerciseIndex].StartWaitForPlayer();
		return;
	}

	PathIndex++;
	bPathCheck = false;
}

/** Уведомляет автодром о завершении выполнения упражнения */
function ExerciseStoped()
{
	bPathCheck = true;

	CurrentExerciseIndex++;

	if(Exercises[CurrentExerciseIndex] != none)
	{
		Exercises[CurrentExerciseIndex].StartWaitForPlayer();
	}
	else if(CurrentExerciseIndex == Exercises.Length)
	{
		if(bVisualHintsEnabled)
			SetHiddenFinishTriggers(false);
	}
}

/** Посылает событие от автодрома */
function SendAutodromEvent(Object sender, int MsgId)
{
	if(CurrentPlayerController != none)
	{
		EventToSend.messageID = MsgId;

 		CurrentPlayerController.EventDispatcher.SendEvent(EventToSend);
	}
}

/** Обрабатывает событие извне */
function HandleEvent(Gorod_Event evt)
{
	if(bHasPlayer)
	{
		if(evt.eventType == GOROD_EVENT_PDD && evt.messageID == GOROD_PDD_OUT_OF_SPEED_MAX_LIMIT)
		{
			// Не выводим сообщение о том, что превышена скорость так как
			// это общее сообщение
			SendAutodromEvent(self, GOROD_EVENT_HIGH_SPEED);
		}
	
		if(evt.eventType == GOROD_EVENT_PDD && evt.messageID == GOROD_PDD_ROAD_ON_OFFROAD)
		{
			if(Exercises[CurrentExerciseIndex] != none && Exercises[CurrentExerciseIndex].IsExerciseRunning())
			{
				SendAutodromEvent(self, GOROD_EVENT_OFF_ROAD);
				Exercises[CurrentExerciseIndex].StopCheck();
			}
		}
	}
}

simulated function SetHiddenStartTriggers(bool bNewHidden)
{
	local Kamaz_Checker_AutodromTrigger t;

	foreach StartTriggerVolumes(t)
		t.SetHidden(bNewHidden);
}

simulated function SetHiddenFinishTriggers(bool bNewHidden)
{
	local Kamaz_Checker_AutodromTrigger t;

	foreach FinishTriggerVolumes(t)
		t.SetHidden(bNewHidden);
}

simulated function SetVisualHintsEnabled(bool NewEnabled)
{
	
	bVisualHintsEnabled = NewEnabled;
}

DefaultProperties
{
	bPathCheck = false;
	bHasRegisteredInMessagesManager = false;
	bHasRegisteredInEventDispatcher = false;
	bHasPlayer = false;

	bEnabled = false;
	bVisualHintsEnabled = false;
}