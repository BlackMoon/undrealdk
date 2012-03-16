/**
 * Упражнение по вращению руля с перехватом. Необходимо повернуть руль 5 раз вправо и 5 раз влево между заданными крайними положениями руля
 */
class Kamaz_Exercise_Steer234 extends Kamaz_Exercise_Base;

/**
 * Значение сигнала, соответствующего крайнему правому/крайнему левому положению руля
 */
var float SteerValueRight, SteerValueLeft;

/**
 * Направление, в котором следует вращать руль в данный момент
 */
var bool isRightTurn;

/**
 * Флаг первого запуска
 */
var bool bIsFirstTime;

function Start()
{
	super.Start();

	ResetCounter();
	SteerValueRight = -1;
	SteerValueLeft = 1;
	isRightTurn = true;
	bIsFirstTime = true;
}

function UpdateSignals(ControlSignalsInfo ControlsInfo)
{
	if(bIsFirstTime)
	{
		ParentGFx.StartAnim(0);
		bIsFirstTime = false;
	}

	if(counter >= RepetitionCount)
	{
		// упражнение пройдено
		Finish();
		return;
	}

	if(isRightTurn)
	{
		if(ControlsInfo.Steering == SteerValueRight)
		{
			// начинаем рулить влево
			ParentGFx.StartAnim(1);
			isRightTurn = false;
			IncCounter();
		}
	}
	else
	{	
		if(ControlsInfo.Steering == SteerValueLeft)
		{
			// начинаем рулить вправо
			ParentGFx.StartAnim(0);
			isRightTurn = true;
			IncCounter();
		}
	}
}

DefaultProperties
{
}
