class Kamaz_Exercise_Gear2 extends Kamaz_Exercise_Base;

enum GearStates
{
	GS_R,
	GS_N,
	GS_1,
	GS_2,
	GS_3,
	GS_4,
	GS_5
};

var GearStates CurrentState, PrevState;

var float PrevGear;

var bool bClutchWas0, bClutchWas1, bGearWasChanged;

function Start()
{
	super.Start();

	ResetCounter();

	bClutchWas0 = false;
	bClutchWas1 = false;
	bGearWasChanged = false;

	PrevGear = 0;

	CurrentState = GS_1;
	ParentGFx.StartAnim(0);
}

function UpdateSignals(ControlSignalsInfo ControlSignals)
{
	if(counter >= RepetitionCount)
	{
		Finish();
		return;
			
	}

	// фиксируем нажатие на сцепление	
	if(!bClutchWas1 && ControlSignals.Clutch >= 0.9)
	{
		bClutchWas1 = true;
	}

	if(bClutchWas1 && ControlSignals.Clutch >= 0.9 && PrevGear != ControlSignals.Gear)
	{
		bGearWasChanged = true;
	}

	if(bGearWasChanged && ControlSignals.Clutch <= 0.1)
	{
		bClutchWas1 = false;
		bGearWasChanged = false;

		if(ControlSignals.Gear == CurrentState - 1)
		{
			PrevState = CurrentState;
			CurrentState = GearStates(Rand(7));

			// простой способ избежать выбора одной и той же передачи несколько раз подряд
			if(PrevState == CurrentState)
			{
				if(CurrentState == GS_1)
					CurrentState = GS_2;
				else
					CurrentState = GS_1;
			}
			IncCounter();

			switch(CurrentState)
			{
				case GS_1:
					ParentGFx.StartAnim(0);
					break;
				case GS_2:
					ParentGFx.StartAnim(1);
					break;
				case GS_3:
					ParentGFx.StartAnim(2);
					break;
				case GS_4:
					ParentGFx.StartAnim(3);
					break;
				case GS_5:
					ParentGFx.StartAnim(4);
					break;
				case GS_R:
					ParentGFx.StartAnim(5);
					break;
				case GS_N:
					// в место того, чтобы переходить на нейтральную передачу, переходим на первую
					CurrentState = GS_1;
					ParentGFx.StartAnim(0);
					break;
			}
		}
	}	

	PrevGear = ControlSignals.Gear;
}

DefaultProperties
{
}