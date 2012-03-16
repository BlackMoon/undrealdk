class Kamaz_Checker_Exercise6 extends Kamaz_Cheker_ExerciseBase placeable;

`include(Gorod\Gorod_Events.uci);

var() Kamaz_ExercisePoint ForwardLeftPoint1, ForwardRightPoint1, BackwardLeftPoint1, BackwardRightPoint1;

var() Kamaz_ExercisePoint FrontLinePoint, BackLinePoint;

enum CheckerStates_Exercise6
{
	CS_Start,
	CS_StartDrive1,
	CS_StopDrive1,
	CS_StartDrive2,
	CS_StopDrive2,
	CS_WaitForStopConditions,
	CS_DriveOut,
	CS_Finished
};

var private CheckerStates_Exercise6 CurrentState;
var private float SecondsCounter;

simulated function StartCheck(CarX_Vehicle p)
{
	local rotator rotF, rotB;

	super.StartCheck(p);
	SecondsCounter = 0;
	CurrentState = CS_Start;

	rotF.Pitch = 32;
	rotF.Roll = -44;
	rotF.Yaw = 19572;

	rotB.Pitch = -211;
	rotB.Roll = -244;
	rotB.Yaw = 3124;

	AutoDrom.setBrdMeshes(vect(122667, 119359, 1832), vect(122163, 118426, 1832), rotF, rotB);
	Autodrom.SendAutodromEvent(self, 1004);
}

simulated function StopCheck()
{
	super.StopCheck();
	AutoDrom.showBrdMeshes(false);
}

simulated function Check(float DeltaSeconds)
{
	local Vector B_L_TireLoc, B_R_TireLoc, cp1, cp2;

	super.Check(DeltaSeconds);

	// если проверка упражнения отключена
	if(!bCheckStarted) return;

	SecondsCounter += DeltaSeconds;

	switch(CurrentState)
	{
		case CS_Start:
			SecondsCounter = 0;

			// не начинаем пока водителя нет в машине
			if(VehicleForCheck.Driver == none)
				return;

			if( !IsRectangleOutside())
			{
				// Не возможно начать упражнение
				StopCheck();
			}
			else
			{
				// прехеодим к следующему действию
				CurrentState = CS_StartDrive1;
				// сообщение "проедьте вперёд"
				Autodrom.SendAutodromEvent(self, GOROD_EVENT_MOVE_FORWARDS);
				ResetCountDown();
			}
		break;
		case CS_StartDrive1:
			if(VehicleForCheck.CurrentGear > 0)
			{
				CurrentState = CS_StopDrive1;
				ResetCountDown();
			}
			break;
		case CS_StopDrive1:
			// ждём переключения на нейтральную передачу
			if(VehicleForCheck.CurrentGear == 0)
			{
				CurrentState = CS_StartDrive2;
				// сообщение "установите ТС на место парковки задним ходом"
				Autodrom.SendAutodromEvent(self, GOROD_EVENT_PARK_BACK);
				ResetCountDown();
			}
			break;
		case CS_StartDrive2:
				// ждём, пока начнётся движение назад
				if(!DriveBackStarted())
					return;

				if(!IsRectangleInside())
				{
					Autodrom.SendAutodromEvent(self, 1017);
				}

				CurrentState = CS_StopDrive2;
				ResetCountDown();

				// Так как ф-ция IsRectangleInside работает со свойствами ForwardLeftPoint, ForwardRightPoint, BackwardLeftPoint, BackwardRightPoint,
				// переписываем их значениями для второго прямоугольника
				ForwardLeftPoint = ForwardLeftPoint1;
				ForwardRightPoint = ForwardRightPoint1;
				BackwardLeftPoint = BackwardLeftPoint1;
				BackwardRightPoint = BackwardRightPoint1;
			break;
		case CS_StopDrive2:
			// Если выключена задняя передача, то это свидетельствует о завершении выполнеиня упражнения
			if(VehicleForCheck.CurrentGear != -1)
			{
				B_L_TireLoc =  VehicleForCheck.Mesh.GetBoneLocation('B_L_Tire');
				B_R_TireLoc =  VehicleForCheck.Mesh.GetBoneLocation('B_R_Tire');

				PointDistToSegment(B_L_TireLoc, FrontLinePoint.Location, BackLinePoint.Location, cp1);
				PointDistToSegment(B_R_TireLoc, FrontLinePoint.Location, BackLinePoint.Location, cp2);

				// Проверяем касание задними колёсами ТС линии фиксации выполнения упражнения
				if(cp1 != BackLinePoint.Location || cp2 != BackLinePoint.Location)
				{
					Autodrom.SendAutodromEvent(self, 1016);
				}

				// Проверяем пересечение контрольной линии
				if(!IsRectangleInside())
				{
					Autodrom.SendAutodromEvent(self, 1017);
				}

				CurrentState = CS_DriveOut;
				// сообщение "выезжайте в обратном направлении"
				Autodrom.SendAutodromEvent(self, GOROD_EVENT_DRIVE_OUT_BACK);
				ResetCountDown();
			}
			break;
	}
}

function OnTriggerTouch(Actor Sender, Actor Other)
{
	super.OnTriggerTouch(Sender, Other);

	// показываем сообщение о завершении при Touch'е триггера
	if(CurrentState == CS_DriveOut)
	{
		// Проверяем количество времени, затраченное на упражнение
		if(SecondsCounter > 120)
		{
			Autodrom.SendAutodromEvent(self, 1018);
		}

		StopCheck();

		// Сообщаем о завершении упражнения
		Autodrom.SendAutodromEvent(self, 1005);
		CurrentState = CS_Finished;
	}
}

DefaultProperties
{
}