class Kamaz_Checker_Exercise2 extends Kamaz_Cheker_ExerciseBase placeable;
`include(Gorod\Gorod_Events.uci);

var private float SecondsCounter;
var private Vector DriveOutInitialLoc;
var private Rotator DriveOutInitialRot;
var private bool bWasDriveBack;

enum ChekerStates_Exercise2
{
	CS_Start,
	CS_StartDrive,
	CS_Stop,
	CS_Wait,
	CS_BeforeDriveOut,
	CS_DriveOut
};

var ChekerStates_Exercise2 CurrentState;

simulated function StartCheck(CarX_Vehicle p)
{
	local rotator rot;	
	super.StartCheck(p);
	SecondsCounter = 0;
	CurrentState = CS_Start;
	
	rot.Pitch = 32;
	rot.Roll = -44;
	rot.Yaw = 19572;

	AutoDrom.setBrdMeshes(vect(120811, 126134, 1930), vect(120303, 125988, 1846), rot, rot);
}

simulated function StopCheck()
{
	super.StopCheck();
	CurrentState = CS_Start;
	AutoDrom.showBrdMeshes(false);
}

simulated function Check(float DeltaSeconds)
{
	local float CurrentDeltaAngle;
	local bool bVehicleIsStoped;

	super.Check(DeltaSeconds);

	// если проверка упражнения отключена
	if(!bCheckStarted) return;

	switch(CurrentState)
	{
		case CS_Start:
			// проверка, не попадаем ли мы уже внутрь прямоугольника
			if(!IsRectangleOutside())
			{
				// Не возможно начать упражнение
				StopCheck();
			}
			else
			{
				// прехеодим к следующему действию
				CurrentState = CS_StartDrive;
				// сообщение о начале упражнения
				Autodrom.SendAutodromEvent(self, GOROD_EVENT_EXERCISE2_STARTED);

				// сообщение "остановите ТС на подъёме"
				Autodrom.SendAutodromEvent(self, GOROD_EVENT_GO_TO_ASCENT);
				ResetCountDown();
			}
			break;
		case CS_StartDrive:
			// если свернули с пути
			if(!ISRectangleAtForwardLine())
			{
				StopCheck();
				Autodrom.SendAutodromEvent(self, 1024);
				return;
			}

			// ждём, пока машина въедет в прямоугольник
			if(IsRectangleInside())
			{
				CurrentState = CS_Stop;
				// сообщение "зафиксируйте ТС в неподвижном состоянии"
				Autodrom.SendAutodromEvent(self, GOROD_EVENT_STOP);
				ResetCountDown();
			}
			break;
		case CS_Stop:
			// если проехали эстакаду
			if(IsRectangleAboveForward())
			{
				StopCheck();
				Autodrom.SendAutodromEvent(self, 1024);
				return;
			}

			// ждём пока машина остановится, при этом проверяем, чтобы она не выехала за пределы прямоугольника
			if(VehicleIsStoped())
			{
 				if(!IsRectangleInside())
				{
					// Ошибка: при остановке ТС не пересёк линию фиксации выполнения упражнения по проекции заднего габарита ТС
					// или пересёк линию "СТОП"
					Autodrom.SendAutodromEvent(self, 1012);
				}

				// Пережодим к следующему действию
				CurrentState = CS_Wait;
				// сообщение "продолжите движение, не допуская отката"
				Autodrom.SendAutodromEvent(self, GOROD_EVENT_GO);
				ResetCountDown();
			}
			break;
		case CS_Wait:
			// ждём 3 секунды, при этом машина должна оставаться на месте
			SecondsCounter += DeltaSeconds;
			
			bVehicleIsStoped = VehicleIsStoped();
			if(!bVehicleIsStoped && SecondsCounter < 3)
			{
				// Ошибка: начал движение ранее, чем через 3с после остановки
				Autodrom.SendAutodromEvent(self, 1013);

				// Переходим к следующему шагу
				CurrentState = CS_BeforeDriveOut;
				ResetCountDown();
			}
			else if(!bVehicleIsStoped && SecondsCounter > 3)
			{
				// Переходим к следующему шагу
				CurrentState = CS_BeforeDriveOut;
				ResetCountDown();
			}
			else if(bVehicleIsStoped && SecondsCounter >= 30)
			{
				// Ошибка: не начал движение в течение 30с после остановки
				Autodrom.SendAutodromEvent(self, 1014);

				// Переходим к следующему шагу
				CurrentState = CS_BeforeDriveOut;
				ResetCountDown();
			}
			break;
		case CS_BeforeDriveOut:
			DriveOutInitialLoc = VehicleForCheck.Location;
			DriveOutInitialRot = VehicleForCheck.Rotation;
			bWasDriveBack = false;
			CurrentState = CS_DriveOut;
			ResetCountDown();
			break;
		case CS_DriveOut:
			// проверяем величину отката

			// если не было зафиксировано отката назад
			if(!bWasDriveBack)
			{
				// угол между изначальным Rotation'ом и направлением движения машины в данный момент
				CurrentDeltaAngle = RadToDeg*FindDeltaAngle(GetHeadingAngle(Vector(DriveOutInitialRot)), GetHeadingAngle(VehicleForCheck.Location - DriveOutInitialLoc));

				// если едем назад
				if(CurrentDeltaAngle > 90 || CurrentDeltaAngle < -90)
				{
					// если отъехали больше чем на 0.3 метра
					if(VSize(DriveOutInitialLoc - VehicleForCheck.Location) > 0.3*50)
					{
						Autodrom.SendAutodromEvent(self, 1015);
						bWasDriveBack = true;
					}
				}
			}

			// проверяем, выехала ли машина за пределы прямоугольника
			if(IsRectangleAboveForward())
			{
				// завершаем выполнение упражнения
				StopCheck();
				Autodrom.SendAutodromEvent(self, 1003);
			}
			break;
	}
}

/** Определяет, находится ли машина между боковыми сторонами прямоугольника */
function bool ISRectangleAtForwardLine()
{
	local Vector cp;

	PointDistToSegment(FrontLeftCornerLoc, ForwardLeftPoint.Location, ForwardRightPoint.Location, cp);
	if(cp == ForwardLeftPoint.Location)
		return false;

	PointDistToSegment(FrontRightCornerLoc, ForwardLeftPoint.Location, ForwardRightPoint.Location, cp);
	if(cp == ForwardRightPoint.Location)
		return false;

	PointDistToSegment(BackRightCornerLoc, BackwardRightPoint.Location, BackwardLeftPoint.Location, cp);
	if(cp == BackwardRightPoint.Location)
		return false;

	PointDistToSegment(BackLeftCornerLoc, BackwardRightPoint.Location, BackwardLeftPoint.Location, cp);
	if(cp == BackwardLeftPoint.Location)
		return false;

	return true;
}

DefaultProperties
{
}
