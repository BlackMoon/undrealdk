class Kamaz_Cheker_ExerciseBase extends Kamaz_Checker_Base implements (Gorod_ActorWithTriggers_Interface);

var() array<Kamaz_Checker_AutodromTrigger> StartTriggers;
var() float ExerciseDistance;

/** Флаг ожидания игрока */
var private bool bWaitForPlayer;

/** Четыре точки, образующие прямоугольник, внутри которого надо остановиться при выполнении упражнения эстакада */
var() Kamaz_ExercisePoint ForwardLeftPoint, ForwardRightPoint, BackwardLeftPoint, BackwardRightPoint;

/** Координаты углов машины игрока */
var protected Vector FrontLeftCornerLoc;
var protected Vector FrontRightCornerLoc;
var protected Vector BackLeftCornerLoc;
var protected Vector BackRightCornerLoc;

/** Ссылка на объект - автодром */
var Kamaz_Checker_Autodrom Autodrom;

/** Счётчик для ограничения времени нахождения в каждом из состояний (если он дошёл до 0, значит игрок не совершал действий по упражнению в течение некоторого времени) */
var private float StateCountDown;

/** Декаль - набор стрелок, показывающая последовательность прохождения упражнения */
var() DecalActor ExerciseInfoDecal;

simulated event PostBeginPlay()
{
	local Kamaz_Checker_AutodromTrigger t;

	super.PostBeginPlay();

	foreach StartTriggers(t)
	{
		t.ActorWithTriggers = self;
		t.SetHidden(true);
	}

	ExerciseInfoDecal.SetHidden(true);
}

/** Начинает ождидание игрока */
function StartWaitForPlayer()
{
	bWaitForPlayer = true;

	if(Autodrom.bVisualHintsEnabled)
		SetHiddenStartTriggers(false);
}

/** Завершает ождидание игрока */
function StopWaitForPlayer()
{
	bWaitForPlayer = false;

	if(Autodrom.bVisualHintsEnabled)
		SetHiddenStartTriggers(true);
}

/** Начинает проверку прохождения упражнения */
simulated function StartCheck(CarX_Vehicle p)
{
	super.StartCheck(p);

	// проверяем корректность переданного параметра (у него должно быть четыре сокета, определяющих габариты)
	if(VehicleForCheck.Mesh.GetSocketByName('F_L_Corner') == none)
	{
		`warn("F_L_Corner not found");
	}
	if(VehicleForCheck.Mesh.GetSocketByName('F_R_Corner') == none)
	{
		`warn("F_R_Corner not found");
	}
	if(VehicleForCheck.Mesh.GetSocketByName('B_L_Corner') == none)
	{
		`warn("B_L_Corner not found");
	}
	if(VehicleForCheck.Mesh.GetSocketByName('B_R_Corner') == none)
	{
		`warn("B_R_Corner not found");
	}
	
	StopWaitForPlayer();
	
	if(Autodrom.bVisualHintsEnabled)
		ExerciseInfoDecal.SetHidden(false);

	ResetCountDown();

	Autodrom.ExerciseStarted(self);
}

/** Завершает проверку выполнения упражнения */
simulated function StopCheck()
{
	super.StopCheck();

	if(Autodrom.bVisualHintsEnabled)
		ExerciseInfoDecal.SetHidden(true);

	ResetCountDown();

	Autodrom.ExerciseStoped();
}

/** Отменяет проверку выполнения упражнения */
simulated function CancelCheck()
{
	if(bWaitForPlayer)
		StopWaitForPlayer();

	if(bCheckStarted)
		StopCheck();
}

/** Обновляет координаты углов машины */
simulated function UpdateCorners()
{
	VehicleForCheck.Mesh.GetSocketWorldLocationAndRotation('F_L_Corner', FrontLeftCornerLoc);
	VehicleForCheck.Mesh.GetSocketWorldLocationAndRotation('F_R_Corner', FrontRightCornerLoc);
	VehicleForCheck.Mesh.GetSocketWorldLocationAndRotation('B_L_Corner', BackLeftCornerLoc);
	VehicleForCheck.Mesh.GetSocketWorldLocationAndRotation('B_R_Corner', BackRightCornerLoc);
}

/** Отображает отладочную информацию об упражнении */
simulated function DrawDBG()
{
	DrawDebugLine(ForwardLeftPoint.Location, ForwardRightPoint.Location, 255, 0, 0);
	DrawDebugLine(ForwardRightPoint.Location, BackwardRightPoint.Location, 255, 0, 0);
	DrawDebugLine(BackwardRightPoint.Location, BackwardLeftPoint.Location, 255, 0, 0);
	DrawDebugLine(BackwardLeftPoint.Location, ForwardLeftPoint.Location, 255, 0, 0);
}

/** true - если КамАЗ располагается внутри четырёхугольника */
simulated function bool IsRectangleInside()
{
	local Vector cp;

	PointDistToSegment(FrontLeftCornerLoc, ForwardLeftPoint.Location, ForwardRightPoint.Location, cp);

	if(cp == ForwardLeftPoint.Location   ||   cp == ForwardRightPoint.Location)
		return false;

	PointDistToSegment(FrontRightCornerLoc, ForwardLeftPoint.Location, ForwardRightPoint.Location, cp);
	if(cp == ForwardLeftPoint.Location   ||   cp == ForwardRightPoint.Location)
		return false;


	PointDistToSegment(FrontLeftCornerLoc, BackwardLeftPoint.Location, ForwardLeftPoint.Location, cp);
	if(cp == BackwardLeftPoint.Location   ||   cp == ForwardLeftPoint.Location)
		return false;

	PointDistToSegment(BackLeftCornerLoc, BackwardLeftPoint.Location, ForwardLeftPoint.Location, cp);
	if(cp == BackwardLeftPoint.Location   ||   cp == ForwardLeftPoint.Location)
		return false;



	PointDistToSegment(FrontRightCornerLoc, ForwardRightPoint.Location, BackwardRightPoint.Location, cp);
	if(cp == ForwardRightPoint.Location   ||   cp == BackwardRightPoint.Location)
		return false;

	PointDistToSegment(BackRightCornerLoc, ForwardRightPoint.Location, BackwardRightPoint.Location, cp);
	if(cp == ForwardRightPoint.Location   ||   cp == BackwardRightPoint.Location)
		return false;

	PointDistToSegment(BackRightCornerLoc, BackwardRightPoint.Location, BackwardLeftPoint.Location, cp);
	if(cp == BackwardRightPoint.Location   ||   cp == BackwardLeftPoint.Location)
		return false;

	PointDistToSegment(BackLeftCornerLoc, BackwardRightPoint.Location, BackwardLeftPoint.Location, cp);
	if(cp == BackwardRightPoint.Location   ||   cp == BackwardLeftPoint.Location)
		return false;

	return true;
}

/** true - если КамАЗ располагается вне четырёхугольника */
simulated function bool IsRectangleOutside()
{
	local Vector cp1, cp2;

	// проверяем передний левый угол
	PointDistToSegment(FrontLeftCornerLoc, ForwardLeftPoint.Location, ForwardRightPoint.Location, cp1);
	PointDistToSegment(FrontLeftCornerLoc, BackwardLeftPoint.Location, ForwardLeftPoint.Location, cp2);

	if((cp1 != ForwardLeftPoint.Location && cp1 != ForwardRightPoint.Location) && (cp2 != BackwardLeftPoint.Location && cp2 != ForwardLeftPoint.Location))
		return false;

	// проверяем передний правый угол
	PointDistToSegment(FrontRightCornerLoc, ForwardLeftPoint.Location, ForwardRightPoint.Location, cp1);
	PointDistToSegment(FrontRightCornerLoc, ForwardRightPoint.Location, BackwardRightPoint.Location, cp2);
	
	if((cp1 != ForwardLeftPoint.Location && cp1 != ForwardRightPoint.Location) && (cp2 != ForwardRightPoint.Location && cp2 != BackwardRightPoint.Location))
		return false;

	// проверяем задний левый угол
	PointDistToSegment(BackLeftCornerLoc, BackwardLeftPoint.Location, ForwardLeftPoint.Location, cp1);
	PointDistToSegment(BackLeftCornerLoc, BackwardRightPoint.Location, BackwardLeftPoint.Location, cp2);
	
	if((cp1 != BackwardLeftPoint.Location && cp1 != ForwardLeftPoint.Location) && (cp2 != BackwardRightPoint.Location && cp2 != BackwardLeftPoint.Location))
		return false;

	// проверяем задний правый угол
	PointDistToSegment(BackRightCornerLoc, ForwardRightPoint.Location, BackwardRightPoint.Location, cp1);
	PointDistToSegment(BackRightCornerLoc, BackwardRightPoint.Location, BackwardLeftPoint.Location, cp2);
	
	if((cp1 != ForwardRightPoint.Location && cp1 != BackwardRightPoint.Location) && (cp2 != BackwardRightPoint.Location && cp2 != BackwardLeftPoint.Location))
		return false;

	return true;
}

/** true - если КамАЗ располагается над верхней гранью (определяемой отрезком [ForwardLeftPoint.Location; ForwardRightPoint]) четырёхугольника */
simulated function bool IsRectangleAboveForward()
{
	local Vector cp1, cp2;

	// передний левый угол
	PointDistToSegment(FrontLeftCornerLoc, ForwardLeftPoint.Location, BackwardLeftPoint.Location, cp1);
	PointDistToSegment(FrontLeftCornerLoc, ForwardRightPoint.Location, BackwardRightPoint.Location, cp2);

	if(cp1 != ForwardLeftPoint.Location || cp2 != ForwardRightPoint.Location)
		return false;

	// передний правый угол
	PointDistToSegment(FrontRightCornerLoc, ForwardLeftPoint.Location, BackwardLeftPoint.Location, cp1);
	PointDistToSegment(FrontRightCornerLoc, ForwardRightPoint.Location, BackwardRightPoint.Location, cp2);

	if(cp1 != ForwardLeftPoint.Location || cp2 != ForwardRightPoint.Location)
		return false;

	// задний левый угол
	PointDistToSegment(BackLeftCornerLoc, ForwardLeftPoint.Location, BackwardLeftPoint.Location, cp1);
	PointDistToSegment(BackLeftCornerLoc, ForwardRightPoint.Location, BackwardRightPoint.Location, cp2);

	if(cp1 != ForwardLeftPoint.Location || cp2 != ForwardRightPoint.Location)
		return false;

	// задний правый угол
	PointDistToSegment(BackRightCornerLoc, ForwardLeftPoint.Location, BackwardLeftPoint.Location, cp1);
	PointDistToSegment(BackRightCornerLoc, ForwardRightPoint.Location, BackwardRightPoint.Location, cp2);

	if(cp1 != ForwardLeftPoint.Location || cp2 != ForwardRightPoint.Location)
		return false;

	return true;
}

/** Проверка правильности выполнения упражнения */
simulated function Check(float DeltaSeconds)
{
	UpdateCorners();

	// если с момента последнего действия по упражнению прошло слишком много времени
	StateCountDown -= DeltaSeconds;
	if(StateCountDown <= 0)
	{
		StopCheck();
		Autodrom.SendAutodromEvent(self, 1022);
	}

	// если игрок уехал слишком далеко от прямоугольника
	if(IsTooFarFromRectangle())
	{
		StopCheck();
		Autodrom.SendAutodromEvent(self, 1025);
	}

}

/** Функция - обработчик касания одного из триггеров упражнения */
function OnTriggerTouch(Actor Sender, Actor Other)
{
	local CarX_Vehicle v;

	if(bWaitForPlayer && !bCheckStarted)
	{
		v = CarX_Vehicle(Other);
		if(v != none)
			StartCheck(v);
	}
}

function OnTriggerUnTouch(Actor Sender, Actor Other)
{
	
}

/** Сброс счётчика времени отведённого на выполнение текущего действия. seconds - кол-во секунд, отведённое на выполнение следующего действия */
function ResetCountDown(optional int seconds = 300)
{
	StateCountDown = seconds;
}

/** ТС остановлено. Ручной тормоз: вкл; Передача: нейтральная. */
function bool VehicleIsStoped()
{
	return (VehicleForCheck.GetHandBrake() && 
			VehicleForCheck.GetGear() == 0 /*&& 
			VehicleForCheck.FBrake == 0 &&
			VehicleForCheck.FThrottle <= 0.3 &&
			VehicleForCheck.FClutch == 1*/);
}

/** true - если машина движется задним ходом */
function bool DriveBackStarted()
{
	return (VehicleForCheck.CurrentGear == -1);
}

/** true - если машина расположена слишком далеко от зоны выполнения упражнения */
function bool IsTooFarFromRectangle()
{
	if(VSize(ForwardLeftPoint.Location - VehicleForCheck.Location) > ExerciseDistance)
		return true;
	else
		return false;
}

/** Отмена выполнения упражнения (в случае ошибки игрока) */
function CancelExercise()
{
	if(bCheckStarted)
		StopCheck();
}

simulated function SetHiddenStartTriggers(bool bNewHidden)
{
	local Kamaz_Checker_AutodromTrigger trg;
	
	foreach StartTriggers(trg)
	{
		trg.SetHidden(bNewHidden);
	}
}

DefaultProperties
{
	Begin Object Class=StaticMeshComponent Name=MyStaticMeshComponent
    StaticMesh=StaticMesh'NodeBuddies.NodeBuddy_PerchUp'
	bUsePrecomputedShadows = true
	End Object

	Components.Add(MyStaticMeshComponent);

	bCheckStarted = false;
	bWaitForPlayer = false;

	ExerciseDistance = 2000;
}
