class Kamaz_Exercise_Gear1 extends Kamaz_Exercise_Base;

enum GearStates
{
	GS_N,
	GS_1,
	GS_2,
	GS_3,
	GS_4,
	GS_5,
	GS_R
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

		switch(ControlSignals.Gear)
		{
			case 0:
				break;
			case 1:
					ParentGFx.StartAnim(1);
				break;
			case 2:
					ParentGFx.StartAnim(2);
				break;
			case 3:
					ParentGFx.StartAnim(3);
				break;
			case 4:
					ParentGFx.StartAnim(4);
				break;
			case 5:
					ParentGFx.StartAnim(5);
				break;
			case -1:
					ParentGFx.StartAnim(0);
					IncCounter();
				break;
		}
	}	

	PrevGear = ControlSignals.Gear;
}

DefaultProperties
{
}