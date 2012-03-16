class Kamaz_Exercise_Pedal2 extends Kamaz_Exercise_Base;

/**
 * ¬ начале упражнени€ ждЄм, пока не будет нажато сцепление,
 * а потом начинаем следить за выполнением качелей
 */
var bool bWaitForClutch;

/**
 * ѕогрешность, используема€ при контроле нажати€ на педали
 */
var float Delta;

/**
 * true - если ожидаетс€ нажатие на газ, false - если ожидаетс€ нажатие на сцепление
 */
var bool bWaitForThrottle;

function Start()
{
	super.Start();

	ResetCounter();
	bWaitForClutch = true;
	bWaitForThrottle = true;
	Delta = 0.2;
}

function UpdateSignals(ControlSignalsInfo ControlsInfo)
{
	if(counter >= RepetitionCount)
	{
		Finish();
		return;
	}
	
	if(bWaitForClutch)
	{
		if(ControlsInfo.Clutch >= 0.9)
			bWaitForClutch = false;
		return;
	}
	
	
	if(ControlsInfo.Throttle > (1 - ControlsInfo.Clutch + Delta) || ControlsInfo.Throttle < (1 - ControlsInfo.Clutch - Delta))
	{
		bWaitForClutch = true;
		return;
	}

	// если ожидаем нажати€ на газ и газ нажат
	if(bWaitForThrottle && ControlsInfo.Throttle >= 0.9)
	{
		// увеличиваем число повторов и  ждЄм нажати€ на сцепление
		IncCounter();
		bWaitForThrottle = false;
	}
	else
	{
		// если ждЄм нажати€ на сцепление и сцепление нажато
		if(ControlsInfo.Clutch >= 0.9)
		{
			// начинаем ждать нажати€ на газ
			bWaitForThrottle = true;
		}
	}
}

DefaultProperties
{
}
