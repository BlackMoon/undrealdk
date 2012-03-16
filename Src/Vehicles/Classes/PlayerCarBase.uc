class PlayerCarBase extends VehicleBase abstract;

enum EInputMode
{
	IM_Joystick,
	IM_Simulator,
	IM_Keyboard
};

var protected ICommonSignals CS;
var protected EInputMode InputMode;

//==============================================================
// ��������� ������
var float Steer;
var float GasPedal;
var float ClutchPedal;
var float BrakePedal;
var bool HandBrake;
var bool LeftTurn;
var bool RightTurn;
var bool ViewChange;
var bool DimensionalFires;
var bool PassingLight;
var bool HeadLight;
var bool ScreenWiper;
var bool LookAtLeft;
var bool LookAtRight;
var bool Ignition;
var bool Starter;
var bool AlarmSignal;
var int CurrentGear;
var bool BeltOn;
var bool bSirenaSignal;
// ��������� ������ ===============================================
var bool bEngineOn;

var array<name> CameraSocketNames;
var int CameraSocketIndex;
// ������������� ��������� ���������� ���� [0, 1]
var byte iAlarm;    
// ��������� PenetrationDestroy
event RBPenetrationDestroy();

//====================================================================================
// ��������� ���������� ������
function SetSteering(float val)
{
	Steer = val;
}

function SetGasPedal(float val)
{
	GasPedal = val;
}

function SetClutchPedal(float val)
{
	ClutchPedal = val;
}

function SetBrakePedal(float val)
{
	BrakePedal = val;
}

function SetHandBrake(bool val)
{
	HandBrake = val;
}

function SetLeftTurn(bool val)
{
	LeftTurn = val;
}

function SetRightTurn(bool val)
{	
	RightTurn = val;
}

function SetViewChange(bool val)
{	
	if(ViewChange != val)
	{
		ViewChange = !ViewChange;
		if (ViewChange)
		{			
			CameraSocketIndex++;
			if (CameraSocketIndex == CameraSocketNames.Length) 
				CameraSocketIndex = 0;
		}
	}
}

function SetDimensionalFires(bool val)
{
	DimensionalFires = val;
}

function SetPassingLight(bool val)
{	
	PassingLight = val;
}

function SetHeadLight(bool val)
{	
	HeadLight = val;
}

function SetScreenWiper(bool val)
{	
	ScreenWiper = val;
}

function SetLookAtLeft(bool val)
{
	LookAtLeft = val;
}

function SetLookAtRight(bool val)
{
	LookAtRight = val;
}

function SetIgnition(bool val)
{
	Ignition = val;
}

function SetStarter(bool val)
{	
	Starter = val;
}

function SetAlarmSignal(bool val)
{
	AlarmSignal = val;
}

function SetCurrentGear(int val)
{
	CurrentGear = val;
}

function SetBelt(bool val)
{
	BeltOn = val;
}
function SwitchBelt()
{
	SetBelt(!BeltOn);
}

function SetSirenaSignal(bool val)
{
	bSirenaSignal = val;
}
//====================================================================================
// ���������� � ����������
exec function Car_SetSteering(float val)
{
	SetSteering(val);
}

exec function Car_SetGasPedal(float val)
{
	SetGasPedal(val);
}

exec function Car_SetClutchPedal(float val)
{
	SetClutchPedal(val);
}

exec function Car_SetBrakePedal(float val)
{
	SetBrakePedal(val);
}

exec function Car_SetHandBrake(bool val)
{
	SetHandBrake(val);
}
exec function Car_SwitchHandBrake()
{
	SetHandBrake(!HandBrake);
}

exec function Car_SetLeftTurn(bool val)
{
	SetLeftTurn(val);
}
exec function Car_SwitchLeftTurn()
{
	SetLeftTurn(!LeftTurn);
}

exec function Car_SetRightTurn(bool val)
{
	SetRightTurn(val);
}
exec function Car_SwitchRightTurn()
{
	SetRightTurn(!RightTurn);
}

exec function Car_SetViewChange(bool val)
{
	SetViewChange(val);
}

exec function Car_SetDimensionalFires(bool val)
{
	SetDimensionalFires(val);
}

exec function Car_SetPassingLight(bool val)
{
	SetPassingLight(val);
}

exec function Car_SetHeadLight(bool val)
{
	SetHeadLight(val);
}

exec function Car_SetScreenWiper(bool val)
{
	SetScreenWiper(val);
}

exec function Car_SetLookAtLeft(bool val)
{
	SetLookAtLeft(val);
}

exec function Car_SetLookAtRight(bool val)
{
	SetLookAtRight(val);
}

exec function Car_SetIgnition(bool val)
{
	SetIgnition(val);
}
exec function Car_SwitchIgnition()
{
	SetIgnition(!Ignition);
}

exec function Car_SetStarter(bool val)
{
	SetStarter(val);
}

exec function Car_SetAlarmSignal(bool val)
{
	SetAlarmSignal(val);
}
exec function Car_SwitchAlarmSignal()
{
	SetAlarmSignal(!AlarmSignal);
}

exec function Car_SetCurrentGear(int val)
{
	SetCurrentGear(val);
}
exec function Car_SetNextGear()
{
	SetCurrentGear(Clamp(CurrentGear + 1, -1, 5));
}
exec function Car_SetPrevGear()
{
	SetCurrentGear(Clamp(CurrentGear - 1, -1, 5));
}

exec function Car_SetBelt(bool val)
{
	SetBelt(val);
}
exec function Car_SwitchBelt()
{
	SetBelt(!BeltOn);
}

exec function Car_SetSirenaSignal(bool val)
{
	SetSirenaSignal(val);
}
exec function Car_SwitchSirenaSignal()
{
	SetSirenaSignal(!bSirenaSignal);
}
//====================================================================================
// ���������� �� �������� ���� ��� ��������
protected function Update()
{
	CS.Update();
	SetSteering(CS.GetSteering());
	SetGasPedal(CS.GetGasPedal());
	SetClutchPedal(CS.GetClutchPedal());
	SetBrakePedal(CS.GetBrakePedal());
	SetCurrentGear(GetCurrentGear());

	// �������, ������� �� ����� ������� ������� ����
	if(InputMode != IM_Joystick)
	{
		SetIgnition(CS.GetIgnition());
		SetStarter(CS.GetStarter());

		SetHandBrake(CS.GetHandBrake());
		SetLeftTurn(CS.GetLeftTurn());
		SetRightTurn(CS.GetRightTurn());
		SetViewChange(CS.GetViewChange());
		SetDimensionalFires(CS.GetDimensionalFires());
		SetPassingLight(CS.GetPassingLight());
		SetHeadLight(CS.GetHeadLight());
		SetScreenWiper(CS.GetScreenWiper());
		SetLookAtLeft(CS.GetLookAtLeft());
		SetLookAtRight(CS.GetLookAtRight());
		SetAlarmSignal(CS.GetAlarmSignal());
		SetBelt(CS.GetBeltOn());
	}
}

// ��������� ���������� �������� �� ������� 
function ToggleAlarmLamp()
{
	iAlarm = 1 - iAlarm;
}

simulated event Tick(float DeltaSeconds)
{
	super.Tick(DeltaSeconds);

	Steering = Steer;
}

protected function int GetCurrentGear()
{
	if(CS.GetFirstStep())
		return 1;
	else if(CS.GetSecondStep())
		return 2;
	else if(CS.GetThirdStep())
		return 3;
	else if(CS.GetFourthStep())
		return 4;
	else if(CS.GetFifthStep())
		return 5;
	else if(CS.GetBackStep())
		return -1;
	else 
		return 0;
}

function bool DriverEnter(Pawn P)
{
	SetInputMode();
	return super.DriverEnter(P);
}

/** ������� ��� �������� */
exec function ChangeInputMode(EInputMode mode)
{
	if(InputMode != mode)
	{
		InputMode = mode;
		SetInputMode();
	}
}

/** ��������� ������ �����. ���������� ������� ����� ��������� �������� InputMode ���� ���. */
function SetInputMode()
{
	GetSignalsObj(CS);

	if(InputMode == IM_Keyboard)
	{
		// ���� ������������� �� ����������, �������� ������� ������� �� �������� ���������� �� �������
		ClearTimer('Update');
	}
	else
	{
		// ���� ������� ������� � ���������������� ������ ��� ��������� ��������, �������� �������� ������� �� �������
		// ����� ������������� ����� ����� - � ����������
		if(CS != none && CS.Initialize())
			SetTimer(0.1, true, 'Update');
		else
			InputMode = IM_Keyboard;
	}
}


/** ***************************************************
 *  ��������� ������� � UU � ����� 
 *  ****************************************************/
function float FromUnrealUnitsToMeters(float uu)
{
	return (uu / 50.0f);
}

/** ���������� ������� �������� � ��/� */
function int GetSpeedInKMpH()
{
	return FromUnrealUnitsToMeters(VSize(Velocity)) * 3.6;
}


protected function GetSignalsObj(out ICommonSignals sig)
{
	switch(InputMode)
	{
		case IM_Keyboard:
			sig = none;
			break;
		case IM_Joystick:
			sig = new class'Zarnitza_DirectInput';
			break;
	}
}

DefaultProperties
{
	InputMode = IM_Keyboard
	CameraSocketIndex = 0;
}
