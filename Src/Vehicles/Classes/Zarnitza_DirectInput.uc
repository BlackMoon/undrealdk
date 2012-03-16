class Zarnitza_DirectInput 
	extends Object 
	DLLBind(DirectInputDLL)
	implements (ICommonSignals);


var private int m_buttons[128];

/** ������� ��������: 
 *  -1  - ������;	
 *  0   - ���������;    
 *  1   - ������;   
 *  2   - ������;   
 *  3   - ������;   
 *  4   - ���������;     
 *  5   - �����;    
 */
var private int CurrentStep;

/** ����� ��������� ������ ������������ ������� */
var private bool DownStepPressed;
var private bool UpStepPressed;
var bool bIgnition;
var bool bMass;
/** ����, ������������, ��� DirectInput ��� ��������������� */
var private bool bInitialized;

function bool GetBackStep() { if(CurrentStep == -1) return true; else return false; }
function bool GetNeutral() { if(CurrentStep == 0) return true; else return false; }
function bool GetFirstStep() { if(CurrentStep == 1) return true; else return false; }
function bool GetSecondStep() { if(CurrentStep == 2) return true; else return false; }
function bool GetThirdStep() { if(CurrentStep == 3) return true; else return false; }
function bool GetFourthStep() { if(CurrentStep == 4) return true; else return false; }
function bool GetFifthStep() { if(CurrentStep == 5) return true; else return false; }

dllimport final function bool InitializeDirectInput();
dllimport final private function int UpdateJoyState();

dllimport final function int GetSteer();
dllimport final function int GetThrottle();
dllimport final function int GetClutch();
dllimport final function int GetBrake();

/** ���������� ������ ��������� ������ */
dllimport final private function GetButtonsArray(out int i[128]);
/**  ���������� ��������� ������������ */
dllimport final private function int GetPOV();

function bool Initialize()
{
	if(!bInitialized)
		bInitialized = InitializeDirectInput();

	return bInitialized;
}

function bool Update()
{
	local int result;
	result = UpdateJoyState();

	//`log("ResVAl" @ result);

	// ��������� ��������� ������
	GetButtonsArray(m_buttons);

	// ��������� ��������� ������ ������� �������
	if(m_buttons[8] == 1)  /* 0x80 */
	{
		if(DownStepPressed == false)
		{
			DownStepPressed = true;
			if(CurrentStep < 5)
				CurrentStep++;
		}
	}
	else
	{
		if(DownStepPressed == true)
		{
			DownStepPressed = false;
		}
	}

	if(m_buttons[9] == 1)  /* 0x80 */
	{
		if(UpStepPressed == false)
		{
			UpStepPressed = true;
			if(CurrentStep > -1)
				CurrentStep--;
		}
	}
	else
	{
		if(UpStepPressed == true)
		{
			UpStepPressed = false;
		}
	}

	return bool(result);
}

function bool GetDifferencial_1()
{
	return false;
}

function bool GetDifferencial_2()
{
	return false;
}

function bool GetHandBrake()
{
	return false;
}

function float GetBrakePedal(bool normalized = true)
{
	return ( (1000.0 - GetBrake()) / 2000.0);
}

function float GetClutchPedal(bool normalized = true)
{
	if(normalized)
		// 
		return 1 - ( (1000.0 - GetClutch()) / 2000.0);
	else
		// ������� ������� �� ������ ����
		return ((1000.0 - GetClutch()) / 2000.0);
}

function float GetGasPedal(bool normalized = true)
{
	return ( (1000.0 - GetThrottle())  / 2000.0);
}

function float GetSteering(bool normalized = true)
{
	return GetSteer() / -1000.0;
}

/**  ����� ���� */
function bool GetViewChange() 
{ 
	return false; 
}

/** ������ ����� */
function bool GetLookAtLeft() 
{
	if (GetHandRotation() == HR_LEFT) 
		return true;
	else
		return false;
}

/** ������ ������ */
function bool GetLookAtRight() 
{
	return (GetHandRotation() == HR_RIGHT);
}

function HandRotation GetHandRotation ()
{
	local int POV;
	local HandRotation HR;
	
	POV = GetPOV ();

	switch (POV)
	{
		case 27000:
			HR = HR_LEFT;
		break;
		case 9000:
			HR = HR_RIGHT;
		break;
		default:
			HR = HR_NONE;
		break;
	}
	return HR;
}

/** ��������� */
function bool GetIgnition() 
{
	return m_buttons[7] == 1;
	/*if (m_buttons[7] == 1)
		bIgnition = !bIgnition;
	return bIgnition;*/
}

/** ������� */
function bool GetStarter() 
{
	return m_buttons[6] == 1;
}

/** ���������� ����� */
function bool GetWeightSwitchingOff() 
{ 
	return m_buttons[2] == 1;
	/*if (m_buttons[2] == 1)
		bMass = !bMass;
	return bMass;*/
}


/** ����� ���������� */
function bool GetLeftTurn() 
{ 
	return m_buttons[0] == 1; 
}

/** ������ ���������� */
function bool GetRightTurn() 
{ 
	return m_buttons[1] == 1; 
}

/** ���������� ���� */
function bool GetDimensionalFires() 
{ 
	//#ToDo �������� m_buttons[n]
	return false; 
}

/** ������� ���� */
function bool GetPassingLight() 
{ 
	//#ToDo �������� m_buttons[n]
	return false; 
}

/** ������� ���� */
function bool GetHeadLight() 
{ 
	//#ToDo �������� m_buttons[n]
	return false; 
}

/** ���������������� */
function bool GetScreenWiper() 
{ 
	//#ToDo �������� m_buttons[n]
	return false; 
}


/** ��������� ������������ */
function bool GetAlarmSignal() 
{ 
	//#ToDo �������� m_buttons[n]
	return false; 
}

/** ������������� ����� */
function bool GetBeltOn()
{ 
	//#ToDo �������� m_buttons[n]
	return false; 
}

/** �������� ������� */
function bool GetTransfersDivider()
{ 
	//#ToDo �������� m_buttons[n]
	return false; 
}

/** ��������� ������������ */
function bool GetInteraxleDifferential()
{ 
	//#ToDo �������� m_buttons[n]
	return false; 
}

/** ���������������� ���������� (���) */
function bool GetElectrotouchDevice()
{ 
	//#ToDo �������� m_buttons[n]
	return false; 
}

DefaultProperties
{
	CurrentStep = 0;        // ��������� �� ���������  
	DownStepPressed = false
	UpStepPressed = false

	bInitialized = false
}
