/** Класс флешки меню проекта форсаж */
class Forsage_Menu extends GFxMoviePlayer config(Forsage_UIText) dependson(Forsage_Signals);
`include(Library_Msg.uci);
//=========================================================================
// Кнопки табов
var GFxClikWidget btnGame;
var GFxClikWidget btnCar;
var GFxClikWidget btnControlSettings;
//=========================================================================
// Кнопки управления игрой
var GFxClikWidget btnAutodromGame;
var GFxClikWidget btnCityGame;
var GFxClikWidget btnExit;
// Описание
var GFxClikWidget lbDescription;
//=========================================================================
// Авто, зеркало заднего вида
var GFxClikWidget btnBackMirror_PitchInc;
var GFxClikWidget btnBackMirror_PitchDec;
var GFxClikWidget btnBackMirror_YawInc;
var GFxClikWidget btnBackMirror_YawDec;

var GFxClikWidget lbBackMirrorCalibration;
//=========================================================================
// Авто, левое зеркало
var GFxClikWidget btnLeftMirror_PitchInc;
var GFxClikWidget btnLeftMirror_PitchDec;
var GFxClikWidget btnLeftMirror_YawInc;
var GFxClikWidget btnLeftMirror_YawDec;

var GFxClikWidget lbLeftMirrorCalibration;
//=========================================================================
// Авто, правое зеркало
var GFxClikWidget btnRightMirror_PitchInc;
var GFxClikWidget btnRightMirror_PitchDec;
var GFxClikWidget btnRightMirror_YawInc;
var GFxClikWidget btnRightMirror_YawDec;

var GFxClikWidget lbRightMirrorCalibration;
//=========================================================================
// Авто, зеркало заднего вида
var GFxClikWidget btnBackMirror_PitchIncrease;
var GFxClikWidget btnBackMirror_PitchDecrease;
var GFxClikWidget btnBackMirror_YawIncrease;
var GFxClikWidget btnBackMirror_YawDecrease;
// Авто, тонировка
var GFxClikWidget chkToning;
//=========================================================================
// Управление
var GFxClikWidget btnArrowDeviceCalibration;
var GFxClikWidget btnWheelCalibration;
var GFxClikWidget btnGasPedalCalibration;
var GFxClikWidget btnClutchPedalCalibration;
var GFxClikWidget btnBrakePedalCalibration;
//=========================================================================
// Стрелочные приборы
var GFxClikWidget lblSetValueDesc;
var GFxClikWidget lblAddValueDesc;
var GFxClikWidget lblCalibrateDesc;
var GFxClikWidget lblSliderDesc;

var GFxClikWidget lblDevDescSpeedometer;
var GFxClikWidget lblDevDescTachometer;
var GFxClikWidget lblDevDescTemp;
var GFxClikWidget lblDevDescFuel;

var GFxClikWidget txtSetResSpeedometer;
var GFxClikWidget txtSetResTachometer;
var GFxClikWidget txtSetResTemp;
var GFxClikWidget txtSetResFuel;

var GFxClikWidget btnSetResSpeedometer;
var GFxClikWidget btnSetResTachometer;
var GFxClikWidget btnSetResTemp;
var GFxClikWidget btnSetResFuel;

var GFxClikWidget txtSetValueSpeedometer;
var GFxClikWidget txtSetValueTachometer;
var GFxClikWidget txtSetValueTemp;
var GFxClikWidget txtSetValueFuel;

var GFxClikWidget btnSetValueSpeedometer;
var GFxClikWidget btnSetValueTachometer;
var GFxClikWidget btnSetValueTemp;
var GFxClikWidget btnSetValueFuel;

var GFxClikWidget btnResetSpeedometer;
var GFxClikWidget btnResetTachometer;
var GFxClikWidget btnResetTemp;
var GFxClikWidget btnResetFuel;

var GFxClikWidget btnCalibrateSpeedometer;
var GFxClikWidget btnCalibrateTachometer;
var GFxClikWidget btnCalibrateTemp;
var GFxClikWidget btnCalibrateFuel;

var GFxClikWidget lblSliderValSpeedometer;
var GFxClikWidget lblSliderValTachometer;
var GFxClikWidget lblSliderValTemp;
var GFxClikWidget lblSliderValFuel;
//=========================================================================
var GFxClikWidget lblCurrentValue;
var GFxClikWidget btnFix;
var GFxClikWidget btnStartCalibration;
// Калибровка руля
var GFxClikWidget lblWheelTip;
var GFxClikWidget btnFinishWheelCalibration;
//=========================================================================
// Калибровка педали газа
var GFxClikWidget lblGasTip;
var GFxClikWidget btnFinishGasPedalCalibration;
//=========================================================================
// Калибровка педали сцепления
var GFxClikWidget lblClutchTip;
var GFxClikWidget btnFinishClutchPedalCalibration;
//=========================================================================
// Калибровка педали тормоза
var GFxClikWidget lblBrakeTip;
var GFxClikWidget btnFinishBrakePedalCalibration;
//сохранить
var GFxClikWidget btnSave;
// авто для настройки
var Forsage_PlayerCar car;
var Forsage_Controller FC;
var Forsage_Game FG;

/** Требуется ли сохранение во внешний ini-файл */
var private bool bNeedToSave;
//=========================================================================
// Кнопки табов (Сохраняемые строки)
var config string strbtnGame;
var config string strbtnGameTip;
var config string strbtnCar;
var config string strbtnCarTip;
var config string strbtnControlSettings;
var config string strbtnControlSettingsTip;
//=========================================================================
// Кнопки управления игрой (Сохраняемые строки)
var config string strbtnAutodromGame;
var config string strbtnCityGame;
var config string strbtnExit;

var config string strRestartGame;
// Описание (Сохраняемые строки)
var config string strlbBackMirrorCalibration;
var config string strlbLeftMirrorCalibration;
var config string strlbRightMirrorCalibration;
// Авто, тонировка (Сохраняемые строки)
var config string strchkToning;
//=========================================================================
// Управление (Сохраняемые строки)
var config string strbtnArrowDeviceCalibration;
var config string strbtnWheelCalibration;
var config string strbtnGasPedalCalibration;
var config string strbtnClutchPedalCalibration;
var config string strbtnBrakePedalCalibration;
//=========================================================================
// Стрелочные приборы (Сохраняемые строки)
var config string strlblSetValueDesc;
var config string strlblAddValueDesc;
var config string strlblCalibrateDesc;
var config string strlblSliderDesc;

var config string strlblDevDescSpeedometer;
var config string strlblDevDescTachometer;
var config string strlblDevDescTemp;
var config string strlblDevDescFuel;

var config string strtxtSetResSpeedometer;
var config string strtxtSetResTachometer;
var config string strtxtSetResTemp;
var config string strtxtSetResFuel;

var config string strbtnSetResSpeedometer;
var config string strbtnSetResTachometer;
var config string strbtnSetResTemp;
var config string strbtnSetResFuel;

var config string strtxtSetValueSpeedometer;
var config string strtxtSetValueTachometer;
var config string strtxtSetValueTemp;
var config string strtxtSetValueFuel;

var config string strbtnSetValueSpeedometer;
var config string strbtnSetValueTachometer;
var config string strbtnSetValueTemp;
var config string strbtnSetValueFuel;

var config string strbtnResetSpeedometer;
var config string strbtnResetTachometer;
var config string strbtnResetTemp;
var config string strbtnResetFuel;

var config string strbtnCalibrateSpeedometer;
var config string strbtnCalibrateTachometer;
var config string strbtnCalibrateTemp;
var config string strbtnCalibrateFuel;

var config string strlblSliderValSpeedometer;
var config string strlblSliderValTachometer;
var config string strlblSliderValTemp;
var config string strlblSliderValFuel;
//=========================================================================
var config string strlblCurrentValue;
var config string strbtnFix;
var config string strbtnStartCalibration;
// Калибровка руля (Сохраняемые строки)
var config string strlblWheelTip;
var config string strbtnFinishWheelCalibration;
//=========================================================================
// Калибровка педали газа (Сохраняемые строки)
var config string strlblGasTip;
var config string strbtnFinishGasPedalCalibration;
//=========================================================================
// Калибровка педали сцепления (Сохраняемые строки)
var config string strlblClutchTip;
var config string strbtnFinishClutchPedalCalibration;
//=========================================================================
// Калибровка педали тормоза (Сохраняемые строки)
var config string strlblBrakeTip;
var config string strbtnFinishBrakePedalCalibration;
//сохранить (Сохраняемые строки)
var config string strbtnSave;

var private bool bIsAlredyInit;
/** Тип калибруемого устройства */
var enum CalibrationType
{
	CLBRTYPE_NONE,
	CLBRTYPE_WHEEL,
	CLBRTYPE_GAS,
	CLBRTYPE_CLUTCH,
	CLBRTYPE_BRAKEPEDAL
} CurrentCalibrationState;

/** Объект для хранения значений калибровки */
var private Zarnitza_ICalibrate CalibrationDataHolder;
/** Вспомогательный actor, служащий для вызова функции обновления приборов в каждом тике */
var TimerHelper mTickHelper;   

var Forsage_ScreenCalibration ScrCalibrationObj;

function Init(optional LocalPlayer LocPlay)
{	
	FC = Forsage_Controller(GetPC());
	car = Forsage_PlayerCar(FC.Pawn);	
	super.Init(LocPLay);
}

function bool Start(optional bool startPaused = false)
{	
	if (CalibrationDataHolder == none)
	{
		CalibrationDataHolder = new class'Forsage_Signals';
	}		
	
	AddCaptureKey('0');
	AddCaptureKey('1');
	AddCaptureKey('2');
	AddCaptureKey('3');
	AddCaptureKey('4');
	AddCaptureKey('5');
	AddCaptureKey('6');
	AddCaptureKey('7');
	AddCaptureKey('8');
	AddCaptureKey('9');	
	AddCaptureKey('Backspace');		
	AddFocusIgnoreKey('Escape');

	Advance(0.f);

	ScrCalibrationObj = FC.Spawn(class'Forsage_ScreenCalibration', FC);
	ScrCalibrationObj.InitDeform();
	
	return super.Start(startPaused); 
}

/** Функция запускает прослушивание сигналов из тренажера
 *  calibrationState - соответствует порядку перечисления CalibrationType */
function StartListenSignals(int calibrationState)
{
	if (FC != none)
	{
		CurrentCalibrationState = CalibrationType(calibrationState);		

		if (mTickHelper == none)
		{
			mTickHelper = FC.Spawn(class'TimerHelper',, 'Forsage_CalibrationHelper');
			mTickHelper.dlgTimerFunc = CalibrationTimerFunc;
		}		
		mTickHelper.DoFunc(true);
		`log("start listen signals: " $ CurrentCalibrationState);
	}
	else 
		`warn("Controller is null");
}

function CalibrationTimerFunc()
{
	local float fval;	

	if (car.ForsageSignals != none)
	{
		if (car.ForsageSignals.update())
		{
			switch (CurrentCalibrationState)
			{
				case CLBRTYPE_WHEEL:
					fval = car.ForsageSignals.getSteering(false);										
					lblCurrentValue.SetText(fval);                              // отображается дробное значение, т.к. руль уже откалиброван 
					break;
				case CLBRTYPE_GAS:
					fval = car.ForsageSignals.GetGasPedal(false);										
					SetVariableNumber("lblCurrentValue.text", fval); 	        // отображается целое значение
					break;
				case CLBRTYPE_CLUTCH:
					fval = car.ForsageSignals.GetClutchPedal(false);					
					SetVariableNumber("lblCurrentValue.text", fval);           // отображается целое значение
					break;
				case CLBRTYPE_BRAKEPEDAL:
					fval = car.ForsageSignals.GetBrakePedal(false);
					SetVariableNumber("lblCurrentValue.text", fval);           // отображается целое значение
					break;				
			}			
		}			
	}	
}
/** Останавливает прослушивание сигналов с тренажера */
function StopListenSignals()
{
	`log("stop listen signals");	
	mTickHelper.DoFunc(false);	
	CurrentCalibrationState = CLBRTYPE_NONE;
}

/** Вызывается из флеш при перетаскивании какого либо из слайдеров */
function SliderChanged(int sliderNum, float value)
{
	local float kfc;
	local Forsage_Signals FS;
	FS = car.ForsageSignals;
	// все слайдеры настроены следующим образом:
	// минимальное значение - 0.0
	// максимальное значение - 10.0
	// все стрелочные приборы - мин - 0,  макс - 255

	// расчет коэффициента: макс.диапазон резистора / макс шкала слайдера
	kfc = FS.MaxResistorValue / FS.MaxSliderValue;

	switch (sliderNum)
	{
		case 0: // speedometer
			FS.SetSpeedometer(value * kfc, false);
			break;
		case 1: // tachometer
			FS.SetTachometer(value * kfc, false);
			break;	
		case 2: // temperature (water)
			FS.SetTemperature(value * kfc, false);
			break;	
		case 3: // fuel
			FS.SetFuel(value * kfc, false);
			break;	
	}
}
/** Сохраняет калибровку стрелочных приборов */
function SaveArrowDeviceCalibration()
{
	car.ForsageSignals.SaveConfig();
}

function SetCalibState(int DeviceId, bool calState)
{
	ActionScriptVoid("SetCalibState");
}

function Arrow_Calibrate(int DeviceID)
{
	local int result;
	result = CalibrationDataHolder.Calibrate(DeviceID);
	`log("ArrowCalibrate"@DeviceID);

	if (result == 0)// CALIBSAMPLE_NOERROR
	{
		SetCalibState(DeviceID, true);
	}
	else
	{	// произошла ошибка
		if (result == 3)    //CALIBSAMPLE_ERRSTATE - устройство еще не готово к калибровке
		{
			SetCalibState(DeviceID, false);
			`warn("Error(CALIBSAMPLE_ERRSTATE) when try to calibrate device: " @ DeviceID);
		}
	}
}

function Arrow_Reset(int DeviceID)
{
	if (CalibrationDataHolder != none)
	{
		if (CalibrationDataHolder.ResetCalibrationData(DeviceID) != 0)
		{
			`warn("Some error occured when try to reset calibration Data on device: " @ DeviceID);
		}
	}
	else
		`warn("CalibrationDataHolder is empty");
}

function Arrow_AddCalibrationPoint(int DeviceID, float ResVal, float FrontVal)
{
	if (CalibrationDataHolder != none)
	{
		if (CalibrationDataHolder.AddCalibrationInfo(DeviceID, ResVal, FrontVal) != 0)
			`warn("Some error occured when try to add calibration Data on device: " @ DeviceID);
	}
	else
		`warn("CalibrationDataHolder is empty");
}

function Arrow_OnSave()
{
	car.bCalibrating = false;
	if (CalibrationDataHolder != none)
		CalibrationDataHolder.SaveCalibration();
	else
		`warn("CalibrationDataHolder is empty");
}

function Arrow_SliderChanged(int DeviceID, float value)
{
	local float kfc;
	local int result;

	`log("Arrow_SliderChanged " @ DeviceID @ value);
	
	// все слайдеры настроены следующим образом:
	// минимальное значение - 0.0
	// максимальное значение - 10.0
	// все стрелочные приборы - мин - 0,  макс - 255

	// расчет коэффициента: макс.диапазон резистора / макс шкала слайдера
	kfc = 25.5;
	if (CalibrationDataHolder != none)
	{
		result = CalibrationDataHolder.ShowCalibratedValue(DeviceID, value * kfc);
		if (result != 0)
			`warn("Some error("@result@") occured when try to show calibrated value on device: " @ DeviceID);
	}
	else
		`warn("CalibrationDataHolder is empty");
}


function Arrow_TextChanged(int DevID, float val)
{
	`log("TextChanged :" @ DevID @ val);

	if (CalibrationDataHolder != none)
	{
		if (CalibrationDataHolder.ShowValue(DevID, int(val)) != 0)
			`warn("Some error occured when try to show res value on device: " @ DevID);
	}
	else
		`warn("CalibrationDataHolder is empty");	
}


/** Сохраняет в ini-файле откалиброванные значения педали тормоза */
function SaveBrakePedalCalibration()
{	
	car.ForsageSignals.BrakePedalMax = GetVariableNumber("gBrakePedalMax");
	car.ForsageSignals.BrakePedalMin = GetVariableNumber("gBrakePedalMin");
	car.ForsageSignals.SaveConfig();
	`log("Save brake calibration");
}
/** Сохраняет в ini-файле откалиброванные значения педали сцепления */
function SaveClutchPedalCalibration()
{	
	car.ForsageSignals.ClutchPedalMin = GetVariableNumber("gClutchPedalMin");
	car.ForsageSignals.ClutchPedalMax = GetVariableNumber("gClutchPedalMax");
	car.ForsageSignals.SaveConfig();
	`log("Save clutch calibration");
}
/** Сохраняет в ini-файле откалиброванные значения педали газа */
function SaveGasPedalCalibration()
{	
	car.ForsageSignals.GasPedalMin = GetVariableNumber("gGasPedalMin");
	car.ForsageSignals.GasPedalMax = GetVariableNumber("gGasPedalMax");
	car.ForsageSignals.SaveConfig();
	`log("Save gas calibration");
}
/** Сохраняет в ini-файле откалиброванные углы зеркал */
function SaveMirrorCalibration()
{
	car.SaveConfig();
}
/** Сохраняет в ini-файле откалиброванные значения руля */
function SaveWheelCalibration()
{	
	car.ForsageSignals.WheelCentral = GetVariableNumber("gWheelAverage");
	car.ForsageSignals.WheelMax = GetVariableNumber("gWheelMaxRight");
	car.ForsageSignals.WheelMin = GetVariableNumber("gWheelMaxLeft");
	car.ForsageSignals.SaveConfig();
	`log("Save wheel calibration");
}

event bool WidgetInitialized (name WidgetName, name WidgetPath, GFxObject Widget) 
{		
	local string strLabel;
	switch (WidgetName) 
	{
		/////////////////////// Кнопки табов
		case ('btnGame'):
			btnGame = GFxClikWidget(Widget);						
			btnGame.AddEventListener('CLIK_rollOver', OnbtnGameRollOver);
			btnGame.AddEventListener('CLIK_rollOut', OnRollOut);
			btnGame.SetString("label",strbtnGame);
			break;
		case ('btnCar'):
			btnCar = GFxClikWidget(Widget);						
			btnCar.AddEventListener('CLIK_rollOver', OnbtnCarRollOver);
			btnCar.AddEventListener('CLIK_rollOut', OnRollOut);
			btnCar.SetString("label", strbtnCar);
			break;		
		case ('btnControlSettings'):
			btnControlSettings = GFxClikWidget(Widget);						
			btnControlSettings.AddEventListener('CLIK_rollOver', OnbtnControlSettingsRollOver);
			btnControlSettings.AddEventListener('CLIK_rollOut', OnRollOut);
			btnControlSettings.SetString("label", strbtnControlSettings);
			break;
		/////////////////////// Кнопки управления игрой
		case ('btnAutodromGame'):
			btnAutodromGame = GFxClikWidget(Widget);			
			btnAutodromGame.AddEventListener('CLIK_click', OnbtnAutodromGameClick);
			btnAutodromGame.AddEventListener('CLIK_rollOver', OnbtnAutodromGameRollOver);
			btnAutodromGame.AddEventListener('CLIK_rollOut', OnRollOut);				

			strLabel = strbtnAutodromGame;
			if (!FC.bMenuIsFirstTime && FG.GameType == GT_Autodrom)
				strLabel = strRestartGame;
			btnAutodromGame.SetString("label", strLabel);
			break;
		case ('btnCityGame'):
			btnCityGame = GFxClikWidget(Widget);			
			btnCityGame.AddEventListener('CLIK_click', OnbtnCityGameClick);
			btnCityGame.AddEventListener('CLIK_rollOver', OnbtnCityGameRollOver);
			btnCityGame.AddEventListener('CLIK_rollOut', OnRollOut);	
			
			strLabel = strbtnCityGame;
			if (!FC.bMenuIsFirstTime && FG.GameType == GT_City)
				strLabel = strRestartGame;
			btnCityGame.SetString("label", strLabel);
			break;
		case ('btnExit'):
			btnExit = GFxClikWidget(Widget);			
			btnExit.AddEventListener('CLIK_click', OnbtnExitClick);
			btnExit.AddEventListener('CLIK_rollOver', OnbtnExitRollOver);
			btnExit.AddEventListener('CLIK_rollOut', OnRollOut);
			btnExit.SetString("label", strbtnExit);
			break;
		/////////////////////// Описание
		case 'lbDescription':
			lbDescription = GFxClikWidget(Widget);			
			break;
		case 'btnBackMirror_PitchInc':
			btnBackMirror_PitchInc = GFxClikWidget(Widget);
			btnBackMirror_PitchInc.AddEventListener('CLIK_press', OnbtnBackMirror_PitchIncPress);
			btnBackMirror_PitchInc.AddEventListener('CLIK_click', stopMirrorTuning);
			break;
		case 'btnBackMirror_PitchDec':
			btnBackMirror_PitchDec = GFxClikWidget(Widget);
			btnBackMirror_PitchDec.AddEventListener('CLIK_press', OnbtnBackMirror_PitchDecPress);			
			btnBackMirror_PitchDec.AddEventListener('CLIK_click', stopMirrorTuning);
			break;
		case 'btnBackMirror_YawInc':
			btnBackMirror_YawInc = GFxClikWidget(Widget);
			btnBackMirror_YawInc.AddEventListener('CLIK_press', OnbtnBackMirror_YawIncPress);
			btnBackMirror_YawInc.AddEventListener('CLIK_click', stopMirrorTuning);
			break;
		case 'btnBackMirror_YawDec':
			btnBackMirror_YawDec = GFxClikWidget(Widget);
			btnBackMirror_YawDec.AddEventListener('CLIK_press', OnbtnBackMirror_YawDecPress);
			btnBackMirror_YawDec.AddEventListener('CLIK_click', stopMirrorTuning);
			break;
		case 'lbBackMirrorCalibration':
			lbBackMirrorCalibration = GFxClikWidget(Widget);
			lbBackMirrorCalibration.SetString("label",strlbBackMirrorCalibration);
			break;
		case 'btnLeftMirror_PitchInc':
			btnLeftMirror_PitchInc = GFxClikWidget(Widget);
			btnLeftMirror_PitchInc.AddEventListener('CLIK_press', OnbtnLeftMirror_PitchIncPress);
			btnLeftMirror_PitchInc.AddEventListener('CLIK_click', stopMirrorTuning);
			break;
		case 'btnLeftMirror_PitchDec':
			btnLeftMirror_PitchDec = GFxClikWidget(Widget);
			btnLeftMirror_PitchDec.AddEventListener('CLIK_press', OnbtnLeftMirror_PitchDecPress);
			btnLeftMirror_PitchDec.AddEventListener('CLIK_click', stopMirrorTuning);
			break;
		case 'btnLeftMirror_YawInc':
			btnLeftMirror_YawInc = GFxClikWidget(Widget);
			btnLeftMirror_YawInc.AddEventListener('CLIK_press', OnbtnLeftMirror_YawIncPress);
			btnLeftMirror_YawInc.AddEventListener('CLIK_click', stopMirrorTuning);
			break;
		case 'btnLeftMirror_YawDec':
			btnLeftMirror_YawDec = GFxClikWidget(Widget);
			btnLeftMirror_YawDec.AddEventListener('CLIK_press', OnbtnLeftMirror_YawDecPress);
			btnLeftMirror_YawDec.AddEventListener('CLIK_click', stopMirrorTuning);
			break;
		case 'lbLeftMirrorCalibration':
			lbLeftMirrorCalibration = GFxClikWidget(Widget);
			lbLeftMirrorCalibration.SetString("label",strlbLeftMirrorCalibration);
			break;
		case 'btnRightMirror_PitchInc':
			btnRightMirror_PitchInc = GFxClikWidget(Widget);
			btnRightMirror_PitchInc.AddEventListener('CLIK_press', OnbtnRightMirror_PitchIncPress);
			btnRightMirror_PitchInc.AddEventListener('CLIK_click', stopMirrorTuning);
			break;			
		case 'btnRightMirror_PitchDec':
			btnRightMirror_PitchDec = GFxClikWidget(Widget);
			btnRightMirror_PitchDec.AddEventListener('CLIK_press', OnbtnRightMirror_PitchDecPress);
			btnRightMirror_PitchDec.AddEventListener('CLIK_click', stopMirrorTuning);
			break;
		case 'btnRightMirror_YawInc':
			btnRightMirror_YawInc = GFxClikWidget(Widget);
			btnRightMirror_YawInc.AddEventListener('CLIK_press', OnbtnRightMirror_YawIncPress);
			btnRightMirror_YawInc.AddEventListener('CLIK_click', stopMirrorTuning);
			break;
		case 'btnRightMirror_YawDec':		
			btnRightMirror_YawDec = GFxClikWidget(Widget);
			btnRightMirror_YawDec.AddEventListener('CLIK_press', OnbtnRightMirror_YawDecPress);
			btnRightMirror_YawDec.AddEventListener('CLIK_click', stopMirrorTuning);
			break;
		case 'lbRightMirrorCalibration':		
			lbRightMirrorCalibration = GFxClikWidget(Widget);
			lbRightMirrorCalibration.SetString("label", strlbRightMirrorCalibration);
			break;
		case 'chkToning':
			chkToning = GFxClikWidget(Widget);
			chkToning.AddEventListener('CLIK_Press', OnchkToningChange);
			chkToning.SetBool("selected", car.msLeftMirror.Toning);
			chkToning.SetString("label", strchkToning);
			break;
		//=========================================================================
		// Управление	
		case 'btnArrowDeviceCalibration':
			btnArrowDeviceCalibration = GFxClikWidget(Widget);
			btnArrowDeviceCalibration.AddEventListener('CLIK_rollOver', onbtnArrowDeviceCalibrationRollOver);
			btnArrowDeviceCalibration.AddEventListener('CLIK_rollOut', onRollOut);
			btnArrowDeviceCalibration.SetString("label", strbtnArrowDeviceCalibration);
			break;	
		case 'btnWheelCalibration':
			btnWheelCalibration = GFxClikWidget(Widget);
			btnWheelCalibration.AddEventListener('CLIK_rollOver', onbtnWheelCalibrationRollOver);
			btnWheelCalibration.AddEventListener('CLIK_rollOut', onRollOut);
			btnWheelCalibration.SetString("label", strbtnWheelCalibration);
			break;	
		case 'btnGasPedalCalibration':
			btnGasPedalCalibration = GFxClikWidget(Widget);
			btnGasPedalCalibration.AddEventListener('CLIK_rollOver', onbtnGasPedalCalibrationRollOver);
			btnGasPedalCalibration.AddEventListener('CLIK_rollOut', onRollOut);
			btnGasPedalCalibration.SetString("label", strbtnGasPedalCalibration);
			break;	
		case 'btnClutchPedalCalibration':
			btnClutchPedalCalibration = GFxClikWidget(Widget);
			btnClutchPedalCalibration.AddEventListener('CLIK_rollOver', onbtnClutchPedalCalibrationRollOver);
			btnClutchPedalCalibration.AddEventListener('CLIK_rollOut', onRollOut);
			btnClutchPedalCalibration.SetString("label", strbtnClutchPedalCalibration);
			break;	
		case 'btnBrakePedalCalibration':
			btnBrakePedalCalibration = GFxClikWidget(Widget);
			btnBrakePedalCalibration.AddEventListener('CLIK_rollOver', onbtnBrakePedalCalibrationRollOver);
			btnBrakePedalCalibration.AddEventListener('CLIK_rollOut', onRollOut);
			btnBrakePedalCalibration.SetString("label", strbtnBrakePedalCalibration);
			break;	
		//=========================================================================
		// Калибровка стрелочных приборов
		case 'lblSetValueDesc':
			lblSetValueDesc = GFxClikWidget(Widget);
			break;	
		case 'lblAddValueDesc':
			lblAddValueDesc = GFxClikWidget(Widget);
			break;	
		case 'lblCalibrateDesc':
			lblCalibrateDesc = GFxClikWidget(Widget);
			break;	
		case 'lblSliderDesc':
			lblSliderDesc = GFxClikWidget(Widget);
			break;	
		case 'lblDevDescSpeedometer':
			lblDevDescSpeedometer = GFxClikWidget(Widget);
			break;	
		case 'lblDevDescTachometer':
			lblDevDescTachometer = GFxClikWidget(Widget);
			break;	
		case 'btnSetResSpeedometer':
			btnSetResSpeedometer = GFxClikWidget(Widget);
			break;	
		//=========================================================================
		// Калибровка руля
		case 'lblWheelTip':
			lblWheelTip = GFxClikWidget(Widget);
			lblWheelTip.SetString("label", strlblWheelTip);
			break;
		case 'lblCurrentValue':
			lblCurrentValue = GFxClikWidget(Widget);
			break;	
		case 'btnFix':
			btnFix = GFxClikWidget(Widget);
			break;
		case 'btnStartCalibration':
			btnStartCalibration = GFxClikWidget(Widget);
			break;	
		case 'btnFinishWheelCalibration':
			btnFinishWheelCalibration = GFxClikWidget(Widget);
			break;	
		//=========================================================================
		// Калибровка педали газа
		case 'lblGasTip':
			lblGasTip = GFxClikWidget(Widget);
			lblGasTip.SetString("label", strlblGasTip);
			break;		
		case 'btnFinishGasPedalCalibration':
			btnFinishGasPedalCalibration = GFxClikWidget(Widget);
			break;
		//=========================================================================
		// Калибровка педали сцепления
		case 'lblClutchTip':
			lblClutchTip = GFxClikWidget(Widget);
			lblClutchTip.SetString("label", strlblClutchTip);
			break;
		case 'btnFinishClutchPedalCalibration':
			btnFinishClutchPedalCalibration = GFxClikWidget(Widget);
			break;	
		//=========================================================================
		// Калибровка педали тормоза
		case 'lblBrakeTip':
			lblBrakeTip = GFxClikWidget(Widget);
			lblBrakeTip.SetString("label", strlblBrakeTip);
			break;
		case 'btnFinishBrakePedalCalibration':
			btnFinishBrakePedalCalibration = GFxClikWidget(Widget);
			break;	
		case 'btnSave':
			btnSave = GFxClikWidget(Widget);			
			btnSave.SetString("label", strbtnSave);
			break;	
	}
	return true;
}

event PostWidgetInit()
{	
	super.PostWidgetInit();		
	SetAlignment(Align_Center);	
	SetViewScaleMode(SM_NoScale);
}

function OnRollOut(GFxClikWidget.EventData ev)
{
	lbDescription.SetText("");
}
//игра
function OnbtnGameRollOver(GFxClikWidget.EventData ev)
{
	lbDescription.SetText(strbtnGameTip);
}
//авто
function OnbtnCarRollOver(GFxClikWidget.EventData ev)
{
	lbDescription.SetText(strbtnCarTip);
}
//управление
function OnbtnControlSettingsRollOver(GFxClikWidget.EventData ev)
{
	lbDescription.SetText(strbtnControlSettingsTip);
}
//начать заново
function OnbtnAutodromGameClick(GFxClikWidget.EventData ev)
{
	FC.bMenuIsFirstTime = false;
	FG.GameType = GT_Autodrom;	
	show(false);
	car.relocate(FG.locAutodrom, FG.rotAutodrom);
}

function OnbtnCityGameClick(GFxClikWidget.EventData ev)
{
	FC.bMenuIsFirstTime = false;
	FG.GameType = GT_City;
	show(false);
	car.relocate(FG.locCity, FG.rotCity);
}
function OnbtnAutodromGameRollOver(GFxClikWidget.EventData ev)
{
	lbDescription.SetText(strbtnAutodromGame);
}
function OnbtnCityGameRollOver(GFxClikWidget.EventData ev)
{
	lbDescription.SetText(strbtnCityGame);
}
//выход
function OnbtnExitClick(GFxClikWidget.EventData ev)
{		
	ConsoleCommand("exit");
}
function OnbtnExitRollOver(GFxClikWidget.EventData ev)
{
	lbDescription.SetText(strbtnExit);
}
// поворот зеркал
function OnbtnBackMirror_PitchIncPress(GFxClikWidget.EventData ev)
{
	car.TuningType = TT_BackMirrorPitchInc;	
}
function OnbtnBackMirror_PitchDecPress(GFxClikWidget.EventData ev)
{	
	car.TuningType = TT_BackMirrorPitchDec;
}
function OnbtnBackMirror_YawIncPress(GFxClikWidget.EventData ev)
{
	car.TuningType = TT_BackMirrorYawInc;	
}
function OnbtnBackMirror_YawDecPress(GFxClikWidget.EventData ev)
{	
	car.TuningType = TT_BackMirrorYawDec;
}
function OnbtnLeftMirror_PitchIncPress(GFxClikWidget.EventData ev)
{
	car.TuningType = TT_LeftMirrorPitchInc;	
}
function OnbtnLeftMirror_PitchDecPress(GFxClikWidget.EventData ev)
{	
	car.TuningType = TT_LeftMirrorPitchDec;
}
function OnbtnLeftMirror_YawIncPress(GFxClikWidget.EventData ev)
{
	car.TuningType = TT_LeftMirrorYawInc;	
}
function OnbtnLeftMirror_YawDecPress(GFxClikWidget.EventData ev)
{	
	car.TuningType = TT_LeftMirrorYawDec;
}
function OnbtnRightMirror_PitchIncPress(GFxClikWidget.EventData ev)
{
	car.TuningType = TT_RightMirrorPitchInc;	
}
function OnbtnRightMirror_PitchDecPress(GFxClikWidget.EventData ev)
{	
	car.TuningType = TT_RightMirrorPitchDec;
}
function OnbtnRightMirror_YawIncPress(GFxClikWidget.EventData ev)
{
	car.TuningType = TT_RightMirrorYawInc;	
}
function OnbtnRightMirror_YawDecPress(GFxClikWidget.EventData ev)
{	
	car.TuningType = TT_RightMirrorYawDec;
}
function stopMirrorTuning(GFxClikWidget.EventData ev)
{
	car.TuningType = TT_None;
}
function OnchkToningChange(GFxClikWidget.EventData ev)
{
	car.setMirrorToning();
}
//=========================================================================
// Управление	
function OnbtnArrowDeviceCalibrationRollOver(GFxClikWidget.EventData ev)
{
	lbDescription.SetText(strbtnArrowDeviceCalibration);
}
function OnbtnWheelCalibrationRollOver(GFxClikWidget.EventData ev)
{
	lbDescription.SetText(strbtnWheelCalibration);
}
function OnbtnBrakePedalCalibrationRollOver(GFxClikWidget.EventData ev)
{
	lbDescription.SetText(strbtnBrakePedalCalibration);
}
function OnbtnGasPedalCalibrationRollOver(GFxClikWidget.EventData ev)
{
	lbDescription.SetText(strbtnGasPedalCalibration);
}
function OnbtnClutchPedalCalibrationRollOver(GFxClikWidget.EventData ev)
{
	lbDescription.SetText(strbtnClutchPedalCalibration);
}
//=========================================================================
// устанавливает названия 2х кнопок игры (Автодром и Город)
private function setGameBtnLabels()
{
	local string strLabel;	
	switch (FG.GameType)
	{
		case GT_Autodrom:
			strLabel = FC.bMenuIsFirstTime ? strbtnAutodromGame : strRestartGame;
			btnAutodromGame.SetString("label", strLabel);
			btnCityGame.SetString("label", strbtnCityGame);
			break;
		case GT_City:
			strLabel = FC.bMenuIsFirstTime ? strbtnCityGame : strRestartGame;
			btnAutodromGame.SetString("label", strbtnAutodromGame);
			btnCityGame.SetString("label", strLabel);
			break;
	}
}
function Show(optional bool bShow = true) 
{		
	if (bShow)
	{		
		if (!bIsAlredyInit)
		{			
			Init();
			bIsAlredyInit = true;
		}
		else					
		{
			Start();			
			ActionScriptVoid("gotoStart");																		
			btnGame.SetBool("focused", true);       // игровое меню всегда активно	
			setGameBtnLabels();						
		}
	}
	else { 
		car.bCalibrating = false;
		Close(false);	
	}
}
/** Проверка на наличие UI текстов в ini-файле */
function checkConfig()
{	
	//=========================================================================
	// Кнопки табов
	if (len(strbtnGame) == 0) {
		strbtnGame = "Игра";				
		bNeedToSave = true;		
	}	

	if (len(strbtnCar) == 0) {
		strbtnCar = "Зеркала";				
		bNeedToSave = true;		
	}	
	if (len(strbtnControlSettings) == 0) {
		strbtnControlSettings = "Управление";				
		bNeedToSave = true;		
	}
	//
	if (len(strbtnAutodromGame) == 0) {
		strbtnAutodromGame = "Автодром";
		bNeedToSave = true;		
	}	
	if (len(strbtnCityGame) == 0) {
		strbtnCityGame = "Город";
		bNeedToSave = true;		
	}	
	if (len(strRestartGame) == 0) {
		strRestartGame = "Начать заново";
		bNeedToSave = true;		
	}	
	if (len(strbtnExit) == 0) {
		strbtnExit = "Выход из игры";
		bNeedToSave = true;		
	}	
		
	if (len(lbBackMirrorCalibration) == 0) {
		strlbBackMirrorCalibration = "Зеркало заднего вида";				
		bNeedToSave = true;		
	}	
	if (len(strlbLeftMirrorCalibration) == 0) {
		strlbLeftMirrorCalibration = "Боковое левое зеркало";				
		bNeedToSave = true;		
	}	
	if (len(strlbRightMirrorCalibration) == 0) {
		strlbRightMirrorCalibration = "Боковое правое зеркало";				
		bNeedToSave = true;		
	}	
	if (len(strchkToning) == 0) {
		strchkToning = "Тонировка зеркал";				
		bNeedToSave = true;		
	}	
	if (len(strbtnArrowDeviceCalibration) == 0) {
		strbtnArrowDeviceCalibration = "Стрелочные приборы";				
		bNeedToSave = true;		
	}	
	if (len(strbtnWheelCalibration) == 0) {
		strbtnWheelCalibration = "Калибровка руля";				
		bNeedToSave = true;		
	}	
	if (len(strbtnGasPedalCalibration) == 0) {
		strbtnGasPedalCalibration = "Калибровка педали газа";				
		bNeedToSave = true;		
	}	
	if (len(strbtnClutchPedalCalibration) == 0) {
		strbtnClutchPedalCalibration = "Калибровка педали сцепления";				
		bNeedToSave = true;		
	}	
	if (len(strbtnBrakePedalCalibration) == 0) {
		strbtnBrakePedalCalibration = "Калибровка педали тормоза";				
		bNeedToSave = true;		
	}
	
	if (len(strbtnGameTip) ==0){
		strbtnGameTip = "Игровое меню";				
		bNeedToSave = true;		
	}
	if (len(strbtnCarTip)==0){
		strbtnCarTip = "Настройка зеркал машины";				
		bNeedToSave = true;		
	}
	if (len(strbtnControlSettingsTip)==0){
		strbtnControlSettingsTip = "Настройка тренажера";				
		bNeedToSave = true;		
	}
	if(len(strlblWheelTip)==0){
		strlblWheelTip = "Для начала калибровки руля нажмите на кнопку Начать калибровку";				
		bNeedToSave = true;		
	}
	if(len(strlblGasTip)==0){
		strlblGasTip = "Для начала калибровки педали газа нажмите на кнопку Начать калибровку";				
		bNeedToSave = true;		
	}

	if(len(strlblClutchTip)==0){
		strlblClutchTip = "Для начала калибровки педали сцепления нажмите на кнопку Начать калибровку";				
		bNeedToSave = true;		
	}
	if(len(strlblBrakeTip)==0){
		strlblBrakeTip = "Для начала калибровки педали тормоза нажмите на кнопку Начать калибровку";				
		bNeedToSave = true;		
	}
	if(len(strbtnSave)==0){
		strbtnSave = "сохранить";				
		bNeedToSave = true;		
	}
}

function scrcal_SliderChanged(int id, float val)
{

	`log("slider: " @ id @ val);
	if(ScrCalibrationObj == none)
	{
		`warn("scrcalibrationObj is none");
		return;
	}

	switch(id)
	{
	case 11:
		ScrCalibrationObj.Set_P1_X(val);
		break;
	case 12:
		ScrCalibrationObj.Set_P1_Y(val);
		break;
	case 21:
		ScrCalibrationObj.Set_P2_X(val);
		break;
	case 22:
		ScrCalibrationObj.Set_P2_Y(val);
		break;
	case 31:
		ScrCalibrationObj.Set_P3_X(val);
		break;
	case 32:
		ScrCalibrationObj.Set_P3_Y(val);
		break;
	case 41:
		ScrCalibrationObj.Set_P4_X(val);
		break;
	case 42:
		ScrCalibrationObj.Set_P4_Y(val);
		break;
	case 51:
		ScrCalibrationObj.Set_P5_X(val);
		break;
	case 52:
		ScrCalibrationObj.Set_P5_Y(val);
		break;
	case 61:
		ScrCalibrationObj.Set_P6_X(val);
		break;
	case 62:
		ScrCalibrationObj.Set_P6_Y(val);
		break;
	case 71:
		ScrCalibrationObj.Set_P7_X(val);
		break;
	case 72:
		ScrCalibrationObj.Set_P7_Y(val);
		break;
	case 81:
		ScrCalibrationObj.Set_P8_X(val);
		break;
	case 82:
		ScrCalibrationObj.Set_P8_Y(val);
		break;
	}
}

function CalibSave()
{
	`log("CalibSave");
	if(ScrCalibrationObj != none)
		ScrCalibrationObj.SaveCalibration();
}

function save()
{
	if (bNeedToSave) 
		saveConfig();
}

function ScreenCalib_Reset()
{
	`log("ScreenCalib_reset");
	ScrCalibrationObj.SetupDeform(true);
}

function ArrowCalibStart(bool bStart)
{
	car.bCalibrating = bStart;
}

function ScreenCalib_SetupSliders()
{
	local float val;

	`log("ScreenCalib_SetupSliders");

	ScrCalibrationObj.matInst.GetScalarParameterValue('p1_x', val);
	SetVariableNumber("sldr_P1_x.value", val);
	ScrCalibrationObj.matInst.GetScalarParameterValue('p1_y', val);
	SetVariableNumber("sldr_P1_y.value", val);
	ScrCalibrationObj.matInst.GetScalarParameterValue('p2_x', val);
	SetVariableNumber("sldr_P2_x.value", val);
	ScrCalibrationObj.matInst.GetScalarParameterValue('p2_y', val);
	SetVariableNumber("sldr_P2_y.value", val);
	ScrCalibrationObj.matInst.GetScalarParameterValue('p3_x', val);
	SetVariableNumber("sldr_P3_x.value", val);
	ScrCalibrationObj.matInst.GetScalarParameterValue('p3_y', val);
	SetVariableNumber("sldr_P3_y.value", val);
	ScrCalibrationObj.matInst.GetScalarParameterValue('p4_x', val);
	SetVariableNumber("sldr_P4_x.value", val);
	ScrCalibrationObj.matInst.GetScalarParameterValue('p4_y', val);
	SetVariableNumber("sldr_P4_y.value", val);
	ScrCalibrationObj.matInst.GetScalarParameterValue('p5_x', val);
	SetVariableNumber("sldr_P5_x.value", val);
	ScrCalibrationObj.matInst.GetScalarParameterValue('p5_y', val);
	SetVariableNumber("sldr_P5_y.value", val);
	ScrCalibrationObj.matInst.GetScalarParameterValue('p6_x', val);
	SetVariableNumber("sldr_P6_x.value", val);
	ScrCalibrationObj.matInst.GetScalarParameterValue('p6_y', val);
	SetVariableNumber("sldr_P6_y.value", val);
	ScrCalibrationObj.matInst.GetScalarParameterValue('p7_x', val);
	SetVariableNumber("sldr_P7_x.value", val);
	ScrCalibrationObj.matInst.GetScalarParameterValue('p7_y', val);
	SetVariableNumber("sldr_P7_y.value", val);
	ScrCalibrationObj.matInst.GetScalarParameterValue('p8_x', val);
	SetVariableNumber("sldr_P8_x.value", val);
	ScrCalibrationObj.matInst.GetScalarParameterValue('p8_y', val);
	SetVariableNumber("sldr_P8_y.value", val);
}

DefaultProperties
{	
	bAutoPlay = true;	
	bCaptureInput = true;
	bIsAlredyInit = false;
	
	MovieInfo = SwfMovie'Forsage_Menu.Forsage_Menu';
	RenderTextureMode = RTM_Alpha;
	
	/////////////////////// Кнопки табов
	WidgetBindings.Add((WidgetName="btnGame", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnCar", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnScreenCalibration", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnControlSettings", WidgetClass=class'GFxClikWidget'))
	/////////////////////// Кнопки управления игрой
	WidgetBindings.Add((WidgetName="btnAutodromGame", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnCityGame", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnExit", WidgetClass=class'GFxClikWidget'))
	/////////////////////// описание
	WidgetBindings.Add((WidgetName="lbDescription", WidgetClass=class'GFxClikWidget'))
	/////////////////////// Кнопки управления зеркалами
	WidgetBindings.Add((WidgetName="btnBackMirror_PitchInc", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnBackMirror_PitchDec", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnBackMirror_YawInc", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnBackMirror_YawDec", WidgetClass=class'GFxClikWidget'))	
	WidgetBindings.Add((WidgetName="btnLeftMirror_PitchInc", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnLeftMirror_PitchDec", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnLeftMirror_YawInc", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnLeftMirror_YawDec", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnRightMirror_PitchInc", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnRightMirror_PitchDec", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnRightMirror_YawInc", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnRightMirror_YawDec", WidgetClass=class'GFxClikWidget'))		

	WidgetBindings.Add((WidgetName="lbBackMirrorCalibration", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="lbLeftMirrorCalibration", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="lbRightMirrorCalibration", WidgetClass=class'GFxClikWidget'))	
	WidgetBindings.Add((WidgetName="chkToning", WidgetClass=class'GFxClikWidget'))	
	//=========================================================================
	// Управление
	WidgetBindings.Add((WidgetName="btnArrowDeviceCalibration", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnWheelCalibration", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnGasPedalCalibration", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnClutchPedalCalibration", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnBrakePedalCalibration", WidgetClass=class'GFxClikWidget'))
	//=========================================================================
	// Калибровка стрелочных приборов
	WidgetBindings.Add((WidgetName="lblSetValueDesc", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="lblAddValueDesc", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="lblCalibrateDesc", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="lblSliderDesc", WidgetClass=class'GFxClikWidget'))

	WidgetBindings.Add((WidgetName="lblDevDescSpeedometer", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="lblDevDescTahometer", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="lblDevDescOil", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="lblDevDescTemp", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="lblDevDescAccum", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="lblDevDescFuel", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="lblDevDescPneum", WidgetClass=class'GFxClikWidget'))

	WidgetBindings.Add((WidgetName="txtSetResSpeedometer", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="txtSetResTahometer", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="txtSetResOil", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="txtSetResTemp", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="txtSetResAccum", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="txtSetResFuel", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="txtSetResPneum", WidgetClass=class'GFxClikWidget'))

	WidgetBindings.Add((WidgetName="btnSetResSpeedometer", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnSetResTahometer", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnSetResOil", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnSetResTemp", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnSetResAccum", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnSetResFuel", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnSetResPneum", WidgetClass=class'GFxClikWidget'))

	WidgetBindings.Add((WidgetName="txtSetValueSpeedometer", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="txtSetValueTahometer", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="txtSetValueOil", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="txtSetValueTemp", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="txtSetValueAccum", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="txtSetValueFuel", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="txtSetValuePneum", WidgetClass=class'GFxClikWidget'))

	WidgetBindings.Add((WidgetName="btnSetValueSpeedometer", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnSetValueTahometer", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnSetValueOil", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnSetValueTemp", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnSetValueAccum", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnSetValueFuel", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnSetValuePneum", WidgetClass=class'GFxClikWidget'))

	WidgetBindings.Add((WidgetName="btnResetSpeedometer", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnResetTahometer", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnResetOil", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnResetTemp", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnResetAccum", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnResetFuel", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnResetPneum", WidgetClass=class'GFxClikWidget'))

	WidgetBindings.Add((WidgetName="btnCalibrateSpeedometer", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnCalibrateTahometer", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnCalibrateOil", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnCalibrateTemp", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnCalibrateAccum", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnCalibrateFuel", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnCalibratePneum", WidgetClass=class'GFxClikWidget'))

	WidgetBindings.Add((WidgetName="lblSliderValSpeedometer", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="lblSliderValTahometer", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="lblSliderValOil", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="lblSliderValTemp", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="lblSliderValAccum", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="lblSliderValFuel", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="lblSliderValPneum", WidgetClass=class'GFxClikWidget'))
	//=========================================================================
	// Калибровка руля
	WidgetBindings.Add((WidgetName="lblWheelTip", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="lblCurrentValue", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnFix", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnStartCalibration", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnFinishWheelCalibration", WidgetClass=class'GFxClikWidget'))
	//=========================================================================
	// Калибровка педали газа
	WidgetBindings.Add((WidgetName="lblGasTip", WidgetClass=class'GFxClikWidget'))
	//WidgetBindings.Add((WidgetName="", WidgetClass=class'GFxClikWidget'))
	//WidgetBindings.Add((WidgetName="", WidgetClass=class'GFxClikWidget'))
	//WidgetBindings.Add((WidgetName="", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnFinishGasPedalCalibration", WidgetClass=class'GFxClikWidget'))
	//=========================================================================
	// Калибровка педали сцепления
	WidgetBindings.Add((WidgetName="lblClutchTip", WidgetClass=class'GFxClikWidget'))
	//WidgetBindings.Add((WidgetName="", WidgetClass=class'GFxClikWidget'))
	//WidgetBindings.Add((WidgetName="", WidgetClass=class'GFxClikWidget'))
	//WidgetBindings.Add((WidgetName="", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnFinishClutchPedalCalibration", WidgetClass=class'GFxClikWidget'))
	//=========================================================================
	// Калибровка педали тормоза
	WidgetBindings.Add((WidgetName="lblBrakeTip", WidgetClass=class'GFxClikWidget'))
	//WidgetBindings.Add((WidgetName="", WidgetClass=class'GFxClikWidget'))
	//WidgetBindings.Add((WidgetName="", WidgetClass=class'GFxClikWidget'))
	//WidgetBindings.Add((WidgetName="", WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="btnFinishBrakePedalCalibration", WidgetClass=class'GFxClikWidget'))

	WidgetBindings.Add((WidgetName="btnSave", WidgetClass=class'GFxClikWidget'))

	
}
