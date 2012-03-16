class Zarnitza_DirectInput 
	extends Object 
	DLLBind(DirectInputDLL)
	implements (ICommonSignals);


var private int m_buttons[128];

/** Текущая передача: 
 *  -1  - задняя;	
 *  0   - нейтралка;    
 *  1   - первая;   
 *  2   - вторая;   
 *  3   - третья;   
 *  4   - четвертая;     
 *  5   - пятая;    
 */
var private int CurrentStep;

/** Флаги состояния рычага переключения передач */
var private bool DownStepPressed;
var private bool UpStepPressed;
var bool bIgnition;
var bool bMass;
/** флаг, показывающий, что DirectInput был инициализирован */
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

/** Возвращает массив состояний кнопок */
dllimport final private function GetButtonsArray(out int i[128]);
/**  Возвращает положение миниджойтика */
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

	// Обновляем состояние кнопок
	GetButtonsArray(m_buttons);

	// обновляем состояние рычага коробки передач
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
		// степень нажатия на педаль газа
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

/**  Смена вида */
function bool GetViewChange() 
{ 
	return false; 
}

/** Взгляд влево */
function bool GetLookAtLeft() 
{
	if (GetHandRotation() == HR_LEFT) 
		return true;
	else
		return false;
}

/** Взгляд вправо */
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

/** Зажигание */
function bool GetIgnition() 
{
	return m_buttons[7] == 1;
	/*if (m_buttons[7] == 1)
		bIgnition = !bIgnition;
	return bIgnition;*/
}

/** Стартер */
function bool GetStarter() 
{
	return m_buttons[6] == 1;
}

/** Отключение массы */
function bool GetWeightSwitchingOff() 
{ 
	return m_buttons[2] == 1;
	/*if (m_buttons[2] == 1)
		bMass = !bMass;
	return bMass;*/
}


/** Левый повототник */
function bool GetLeftTurn() 
{ 
	return m_buttons[0] == 1; 
}

/** Правый повототник */
function bool GetRightTurn() 
{ 
	return m_buttons[1] == 1; 
}

/** Габаритные огни */
function bool GetDimensionalFires() 
{ 
	//#ToDo пользуем m_buttons[n]
	return false; 
}

/** Ближный свет */
function bool GetPassingLight() 
{ 
	//#ToDo пользуем m_buttons[n]
	return false; 
}

/** Дальний свет */
function bool GetHeadLight() 
{ 
	//#ToDo пользуем m_buttons[n]
	return false; 
}

/** Стеклоочиститель */
function bool GetScreenWiper() 
{ 
	//#ToDo пользуем m_buttons[n]
	return false; 
}


/** Аварийная сигнализация */
function bool GetAlarmSignal() 
{ 
	//#ToDo пользуем m_buttons[n]
	return false; 
}

/** Пристегивание ремня */
function bool GetBeltOn()
{ 
	//#ToDo пользуем m_buttons[n]
	return false; 
}

/** Делитель передач */
function bool GetTransfersDivider()
{ 
	//#ToDo пользуем m_buttons[n]
	return false; 
}

/** Межосевой дифференциал */
function bool GetInteraxleDifferential()
{ 
	//#ToDo пользуем m_buttons[n]
	return false; 
}

/** Электрофакельное устройство (ЭФУ) */
function bool GetElectrotouchDevice()
{ 
	//#ToDo пользуем m_buttons[n]
	return false; 
}

DefaultProperties
{
	CurrentStep = 0;        // нейтралка по умолчанию  
	DownStepPressed = false
	UpStepPressed = false

	bInitialized = false
}
