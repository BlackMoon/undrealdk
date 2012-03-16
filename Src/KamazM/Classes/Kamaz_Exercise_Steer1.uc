/**
 * ”пражнение по вращению рул€ без отрыва рук. Ќеобходимо повернуть руль 5 раз вправо и влево между заданными крайними положени€ми рул€
 */
class Kamaz_Exercise_Steer1 extends Kamaz_Exercise_Base;

/**
 * «начение сигнала, соответствующего крайнему правому/крайнему левому положению рул€
 */
var float SteerValueRight, SteerValueLeft, SteerDelta;

/**
 * Ќаправление, в котором следует вращать руль в данный момент
 */
var bool isRightTurn;
/**
 * флаг дл€ временной задержки
 */
var bool bWaiting;

function Start()
{
	super.Start();

	ResetCounter();
	SteerValueRight = -90;
	SteerValueLeft = 90;
	isRightTurn = false;
	SteerDelta = 10;
	bWaiting = true;

	ParentGFx.StartAnim(0);
}

function UpdateSignals(ControlSignalsInfo ControlsInfo)
{
	if(bWaiting)
	{
		// ждЄм нажати€ на элемент управлени€ (пока это педаль газа), чтобы перейти к вращению рулЄм
		if(ControlsInfo.Throttle > 0.5)
		{
			bWaiting = false;
			ParentGFx.StartAnim(1);
		}
		
		return;
	}

	if(counter >= RepetitionCount)
	{
		// упражнение пройдено
		Finish();
		return;
	}

	if(isRightTurn)
	{
		if(GetDegreesBySteering(ControlsInfo.Steering) <= SteerValueRight)
		{
			// начинаем рулить влево
			ParentGFx.StartAnim(1);
			isRightTurn = false;
			IncCounter();
		}
	}
	else
	{	
		if(GetDegreesBySteering(ControlsInfo.Steering) >= SteerValueLeft)
		{
			// начинаем рулить вправо
			ParentGFx.StartAnim(2);
			isRightTurn = true;
			IncCounter();
		}
	}
}

DefaultProperties
{
}
