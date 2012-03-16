class Kamaz_Exercise_Pedal1 extends Kamaz_Exercise_Base;

enum PedalStates
{
	PS_Throttle,
	PS_Brake,
	PS_Clutch
};

var PedalStates CurrentState;

var bool bWaiting;

function Start()
{
	super.Start();

	bWaiting = true;
	CurrentState = PS_Throttle;
	ResetCounter();
	ParentGFx.StartAnim(0);
}

function UpdateSignals(ControlSignalsInfo ControlsInfo)
{
	if(bWaiting)
	{
		if(ControlsInfo.Throttle > 0.5)
		{
			bWaiting = false;
			ParentGFx.StartAnim(1);
			CurrentState = PS_Throttle;
		}

		return;
	}
	if(counter >= RepetitionCount)
	{
		// упражнение пройдено
		bWaiting = true;
		Finish();
		return;
	}
	else
	{
		switch(CurrentState)
		{
			case PS_Throttle:
				if(ControlsInfo.Throttle >= 0.9)
				{
					CurrentState = PS_Brake;
					ParentGFx.StartAnim(2);
				}
				break;
			case PS_Brake:
				if(ControlsInfo.Brake >= 0.9)
				{
					CurrentState = PS_Clutch;
					ParentGFx.StartAnim(3);
				}
				break;
			case PS_Clutch:
				if(ControlsInfo.Clutch >= 0.9)
				{
					CurrentState = PS_Throttle;
					ParentGFx.StartAnim(1);
					IncCounter();
				}
				break;
		}
	}
}

DefaultProperties
{
}
