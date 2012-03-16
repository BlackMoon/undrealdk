class Kamaz_Checker_Base extends Actor;

var protected float SecondsBetweenCheck;

/**
 * Машина игрока
 */
var CarX_Vehicle VehicleForCheck;

var protected bool bCheckStarted;

var protected float SecondsBetweenCheck_Counter;

simulated function StartCheck(CarX_Vehicle p)
{
	VehicleForCheck = p;
	bCheckStarted = true;
	SecondsBetweenCheck_Counter = 0;
}

simulated function StopCheck()
{
	bCheckStarted = false;
}

simulated function Tick(float DeltaSeconds)
{
	super.Tick(DeltaSeconds);

	// если начата проверка упражнения, то увеличиваем счётчик времени, иначе ничего не делаем
	if(bCheckStarted)
	{
		SecondsBetweenCheck_Counter += DeltaSeconds;

		if(SecondsBetweenCheck_Counter >= SecondsBetweenCheck)
		{
			if(VehicleForCheck != none)
				Check(SecondsBetweenCheck_Counter);

			SecondsBetweenCheck_Counter = 0;
		}
	}
}

simulated function Check(float DeltaSeconds)
{
}

simulated function bool IsExerciseRunning()
{
	return bCheckStarted;
}

DefaultProperties
{
	SecondsBetweenCheck = 0.5;
	SecondsBetweenCheck_Counter = 0;
}
