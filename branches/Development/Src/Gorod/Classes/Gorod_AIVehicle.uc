/** Машина, которая может ехать к заданной точке с заданной скоростью */
class Gorod_AIVehicle extends VehicleBase;

`include(Gorod_Events.uci);

/** Маршрутная точка, к которой бот движется в данный момент */
var RepNotify Gorod_AIVehicle_PathNode Target;

/** Последняя маршрутная точка, через которую проехал бот */
var Gorod_AIVehicle_PathNode OldTarget;

/** Требуемая скорость */
var RepNotify float NeededSpeed;

/** Направление на текущую маршрутную точку */
var Vector TargetViewDirection;

/** Текущий модуль вектора скорости */
var float CurrentVelocity;

/** Ссылка на менджер-телепортатор (сначала хотели получать его через Оwner) */
var() Gorod_RelocationBotManager RelocManager;

/** Счётчик тиков, чтобы можно было пересчитывать тягу каждые 0.1 секунд */
var float countTick;
     
/** Значение тяги, рассчитанное на текущем шаге */
var float newThrottle;

/** Значение угла поворота колёс, рассчитанное на текущем шаге */
var float newSteering;

/** Ссылка на объект для работы с материалом машины */
var Gorod_VehicleLightsController VehicleLightsController;

/** Константа для дополнительной проверки на правильность движения машины */
var const float DeltaForWrongDrivingDetection;

/** Структура для хранения информации о состоянии световых сигналов машины */
struct SignalLightsInfo
{
	// левый поворотник
	var bool bLeftSignalLightOn;
	// правый поворотник
	var bool bRightSignalLightOn;
	// фары
	var bool bHeadLightsOn;
	// габаритные огни
	var bool bParkingLightsOn;

	structdefaultproperties
	{
		bLeftSignalLightOn = false;
		bRightSignalLightOn = false;
		bHeadLightsOn = false;
		bParkingLightsOn = false;
	}
};

/** Информации о состоянии световых сигналов машины */
var RepNotify SignalLightsInfo LightsInfo;

/** Ускорение машины при разгоне/торможении */
var int VelocityStep;

/** Скорость, до которой машина будет разгоняться, если не задана другая, более низкая скорость */
var RepNotify float FavoriteSpeed;

/** Перерасчёт тяги отключен */
var private bool bStopped;

var SkeletalMeshComponent SMesh;

replication
{
	if(bNetDirty)
		Target, NeededSpeed, LightsInfo;
	if(bNetInitial)
		FavoriteSpeed;
}

simulated event ReplicatedEvent(Name VarName)
{
	switch(VarName)
	{
		case 'LightsInfo':
			// При изменении LightsInfo вызывается VehicleLightsController.UpdateSignalLights() на сервере, по событию
			// ReplicatedEvent та же функция вызывается на клиенте
			if (Role != ROLE_Authority)
				VehicleLightsController.UpdateSignalLights();
			break;
	}
}

simulated event PreBeginPlay()
{
	Super.PreBeginPlay();
	TargetViewDirection = vector(Rotation);
}

simulated event PostBeginPlay()
{
	super.PostBeginPlay();	

	// спауним Gorod_VehicleLightsController только на сервере и только для машин-ботов
	if(Role == ROLE_Authority)
		VehicleLightsController = Spawn(class'Gorod_VehicleLightsController', self);
	if(Target != none)
		Initialize();
}

function Initialize()
{
	local vector DriverSpawnLocation;
	local Pawn drvr;	
	// для работы проекта форсаж
	//local Gorod_Game GorodGame;
	local Gorod_AIVehicle_Controller refCtl;
	
	// для работы проекта форсаж
	//GorodGame = Gorod_Game(WorldInfo.Game);

	// Проводим инициализацию только при соответствующем типе игры и только для машин-ботов
	// проверка на Gorod_Game закомментирована для работы проекта форсаж
	if(Driver == none)
	{
		// Создание водителя и посадка его в машину (так сделано, чтобы отрабатывали epic'овские функции про присвоению котроллера, possess, unpossess и пр.)
		DriverSpawnLocation = Location;
		DriverSpawnLocation.Z += 200;
		drvr = Spawn(class'UDKPawn', , , DriverSpawnLocation, Rotation, , true);
		refCtl = Spawn(class'Gorod_AIVehicle_Controller');
		`warn("refCtl == none", refCtl == none);
		drvr.Controller = refCtl;
		DriverEnter(drvr);
	}
	
	// присваиваем начальные значения различным скоростям (только MaxSpeed не достаточно, чтобы ограничить скорость машины)
	MaxSpeed = 0;
	GroundSpeed = 0;
	AirSpeed = 0;
	WaterSpeed = 0;

	// если данная машина создана не с помощью Gorod_AIVehicleSpawner
	// запускаем контроллер 
	if((Gorod_AIVehicle_Spawner(self.Owner) == none) && (refCtl != none))
		refCtl.StartController();
}

function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation)
{
	// водитель никогда не умирает
	return false;
}

/** Выводит отладочную информацию о машине */
/*simulated function DrawHUD(HUD H)
{
	local Vector X, Y, Z, WorldLoc, ScreenLoc;
	local Kamaz_HUD gHud;
	
	super.DrawHUD(H);
	gHud = Gorod_HUD(H);
	if(gHud != none)
	{
		if(gHud.bShowBotNames)
		{
			// Рисуем подсказку для машины-бота для отладки
			GetAxes(Rotation, X, Y, Z);
			WorldLoc =  Location;
			ScreenLoc = H.Canvas.Project(WorldLoc);
    	
			if(ScreenLoc.X >= 0 &&	ScreenLoc.X < H.Canvas.ClipX && ScreenLoc.Y >= 0 && ScreenLoc.Y < H.Canvas.ClipY)
			{
				H.Canvas.DrawColor = MakeColor(0,0,255,255);
				H.Canvas.SetPos(ScreenLoc.X, ScreenLoc.Y);
				H.Canvas.DrawText("[" @ Name @ "] -" @ MaxSpeed @ NeededSpeed @ CurrentVelocity);
			}
		}
	}
}*/

simulated event Tick(float deltaSeconds)
{
	/** максимальный угол поворота колёс */
	local float MaxSteerAngle;
	// всякие дополнительные хрени
	local float VehicleHeading, SteerHeading, DeltaTargetHeading;
	local Rotator VehicleRot, TargetViewRot;
	local float DeltaVelocity;

	super.Tick(deltaSeconds);
  	
	// если нет Target'а, сбрасываем значения для тяги и угла поворота колёс и ничего не делаем
	if(Target == none)
	{
		newThrottle = 0;
		newSteering = 0;
		return;
	}

	CurrentVelocity = VSize(Velocity);

	if(!bStopped)
	{
		//------------------------------------------------------
		// расчёт угла поворота колёс

		VehicleRot.Yaw = Rotation.Yaw;
		TargetViewRot.Yaw = rotator(Target.Location - Location).Yaw;
	
		VehicleHeading = GetHeadingAngle(vector(VehicleRot));
	
		// вектор, направленный в сторону очередной маршрутной точки
		TargetViewDirection = vector(TargetViewRot);

		SteerHeading = GetHeadingAngle(TargetViewDirection);
	
		DeltaTargetHeading = FindDeltaAngle(SteerHeading, VehicleHeading);

		/*
		if(DeltaTargetHeading > 1 || DeltaTargetHeading < -1)
		{
			`warn("DeltaTargetHeading is too big!" @ self @ Target);
		}
		*/

		// переводим в градусы
		DeltaTargetHeading *= RadToDeg;

		// получение максимального угла поворота колёс
		//SimCar = SVehicleSimCar(SimObj);
		//EvalInterpCurveFloat(SimCar.MaxSteerAngleCurve, CurrentVelocity);

		// упрощенный вариант получения максимального угла поворота колёс
		MaxSteerAngle = 45;
	
		// нормализованное значение угла поворота колёс
		newSteering = DeltaTargetHeading/MaxSteerAngle;

		// окончательное вычисление угла повороа колёс
		if(newSteering > 1)
			newSteering = 1;
		else if(newSteering < -1)
			newSteering = -1;
	
		//--------------------------------------------
		// расчёт тяги

	
		countTick += deltaSeconds;
		if(countTick >= 0.1)
		{
			if(MaxSpeed == 0)
				newThrottle = 0;
			else
				newThrottle = 1;

			// отклонение по скорости
			DeltaVelocity = CurrentVelocity - NeededSpeed;

			// если отклонение по скорости больше чем возможное укороение, изменяем MaxSpeed на значение ускорения, иначе
			// устанавливаем нужное значение MaxSpeed
			if(DeltaVelocity > VelocityStep)
				MaxSpeed -= VelocityStep*countTick;
			else if(DeltaVelocity < -VelocityStep)
				MaxSpeed += VelocityStep*countTick;
			else
				MaxSpeed = NeededSpeed;

			// Нельзя задавать скорость больше чем FavoriteSpeed
			MaxSpeed = Min(FavoriteSpeed, MaxSpeed);

			// Изменяем значения других скоростей, так как изменения MaxSpeed не достаточно для ограничения скорости машины
			GroundSpeed = MaxSpeed;
			AirSpeed = MaxSpeed;
			WaterSpeed = MaxSpeed;

			countTick = 0;
		}
	}	

	// Применяем рассчитанные значения тяги и угла поворота колёс
	Throttle = newThrottle;
	Steering = newSteering;
	Rise = 0;
}

/** Вызывается при столкновении с другим объектом */
simulated event RigidBodyCollision(PrimitiveComponent HitComponent, PrimitiveComponent OtherComponent, const out CollisionImpactData RigidCollisionData, int ContactIndex)
{
	local Gorod_AIVehicle_Controller VC;
	VC = Gorod_AIVehicle_Controller(self.Controller);

	// уведомляем контроллер о столкновении с другой машиной
	if (VC != none) VC.NotifyRigidBobyCollision(HitComponent, OtherComponent, RigidCollisionData, ContactIndex);
}

/** Устанавливает значение требуемой скорости */
simulated function SetTargetSpeed(float s)
{
	// Задаём скорость не больше, чем скорость, указанная в данном Target'е
	if((Target == none) || (s < 0))
		NeededSpeed = 0.f;
	else
		NeededSpeed = Min(s, Target.CarMaxSpeed);
}

/** Устанавливаем маршрутную точку, к которой поедет машина после возвращения на карту */
function Appear(Gorod_AIVehicle_PathNode t)
{
	local Gorod_AIVehicle_Controller refCtl;

	if (t != none)
	{
		refCtl = Gorod_AIVehicle_Controller(Controller);
		`warn("refCtl == none", refCtl == none);
		if (refCtl != none)
			refCtl.Appear(t);
	}
}

/** Отключает рассчёт тяги */
simulated function SetNoThrottle(bool val)
{
	if(val)
		newThrottle = 0;
	bStopped = val;
}

/** Дополнительная проверка на правильность движения машины-боты */
function bool IsDrivingWrong()
{
	// вычисляем расстояние, которое машина проходит за секунду исходя из Velocity и исходя из скорость вращения передних колёс
	// сравниваем полученные результаты и делаем вывод о том, буксует ли машина. и. если буксует, то возвращаем true
	local vector lVelocity;
	local float lCurrentVelocity;
	local float MinSpinVel;

	lVelocity = Velocity;
	lVelocity.Z = 0;
	lCurrentVelocity = VSize(lVelocity);
	MinSpinVel = FMin(Wheels[2].SpinVel*Wheels[2].WheelRadius, Wheels[3].SpinVel*Wheels[3].WheelRadius);

	return (lCurrentVelocity < (MinSpinVel - DeltaForWrongDrivingDetection));
}

defaultproperties
{
	bNoDelete = false;
	bStatic = false;

	RemoteRole = ROLE_SimulatedProxy

	VelocityStep = 100;
	countTick = 0;
	bStopped = false;
	DeltaForWrongDrivingDetection = 200;
}