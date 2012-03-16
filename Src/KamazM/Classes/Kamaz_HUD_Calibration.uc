class Kamaz_HUD_Calibration extends Kamaz_GFxMoviePlayer;

/** ��� ������������ ���������� */
enum CalibrationType
{
	CLBRTYPE_NONE,
	CLBRTYPE_WHELL,
	CLBRTYPE_GAS,
	CLBRTYPE_CLUTCH,
	CLBRTYPE_BRAKEPEDAL
};

// ���� ��� ���������
var private Kamaz_PlayerCar car;
/** ��������������� �����, �������� ��� ������ ������� ���������� �������� � ������ ���� */
var TimerHelper mTickHelper;

/** ������� ����������� ���������� */
var CalibrationType CurrentCalibrationState;

var Kamaz_HUD KamazHUD;

/** ����, ������������, ������ �� ������ "����� ����" (��������� �������� ������������ ����������) */
var private bool bViewChangePressed;
/** ������ ��� �������� �������� ���������� */
var private Zarnitza_ICalibrate CalibrationDataHolder;
/** strings from ini-file */
var config string strAddBtn;
var config string strCalibrateBtn;
var config string strResetBtn;
var config string strAddValueDesc;
var config string strSetValueDesc;
var config string strCalibrateDesc;
var config string strSliderDesc;

var config string strFix;
var config string strSave;
var config string strArrowDeviceCalibration;
var config string strStartCalibration;
var config string strDevDescSpeedometer;
var config string strDevDescTahometer;
var config string strDevDescOil;
var config string strDevDescTemp;
var config string strDevDescAccum;
var config string strDevDescFuel;
var config string strDevDescPneum;

var config string strGasPedalCalibration;
var config string strGasTip;        // main
var config string strGasTip1;       // 1st
var config string strGasTip2;       // 2nd
var config string strGasTip3;       // 3d
var config string strGasCalibrationTitle;
var config string strFinishGasPedalCalibration;

var config string strBrakePedalCalibration;
var config string strBrakeTip;      // main
var config string strBrakeTip1;     // 1st
var config string strBrakeTip2;     // 2nd
var config string strBrakeTip3;     // 3d
var config string strBrakeCalibrationTitle;
var config string strFinishBrakePedalCalibration;

var config string strWheelCalibration;
var config string strWheelTip;      // main
var config string strWheelTip1;     // 1st
var config string strWheelTip2;     // 2nd
var config string strWheelTip3;     // 3d
var config string strWheelTip4;     // 4th
var config string strWheelCalibrationTitle;
var config string strFinishWheelCalibration;

var config string strClutchPedalCalibration;
var config string strClutchTip;     // main
var config string strClutchTip1;    // 1st
var config string strClutchTip2;    // 2nd
var config string strClutchTip3;    // 3d
var config string strClutchCalibrationTitle;
var config string strFinishClutchPedalCalibration;

function bool Start(optional bool startPaused = false)
{
	local bool result;
	local Kamaz_PlayerCar refCar;
	result = super.Start(startPaused);

	if(CalibrationDataHolder == none)
	{
		CalibrationDataHolder = new class'Zarnitza_KamazSignals';
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
	AddCaptureKey('BackSpace');
	
	Advance(0.f);
	foreach GetPC().AllActors(class'Kamaz_PlayerCar', refCar)
	{
		car = refCar;
		break;
	}	

	return result;
}

function OnExit()
{
	goBack();
	Close(false);
}

/** ������� ��������� ������������� �������� �� ���������
 *  calibrationState - ������������� ������� ������������ CalibrationType */
function StartListenSignals(int calibrationState)
{
	CurrentCalibrationState = CalibrationType(calibrationState);		

	if (mTickHelper == none)
	{
		mTickHelper = GetPC().Spawn(class'TimerHelper',, 'Forsage_CalibrationHelper');
		mTickHelper.dlgTimerFunc = CalibrationTimerFunc;
	}				
	mTickHelper.DoFunc(true);
	`log("start listen signals: " $ CurrentCalibrationState);	
}

/** ��������������� �������, ������� ������ ��� ��������� �������� � ��������� */
function CalibrationTimerFunc()
{
	local float fval;

	if (car.KamazSignals != none)
	{
		if(car.KamazSignals.Update())
		{
			switch(CurrentCalibrationState)
			{
			case CLBRTYPE_WHELL:
				fval = car.KamazSignals.GetSteering(false);
				break;

			case CLBRTYPE_GAS:
				fval = car.KamazSignals.GetGasPedal(false);
				break;

			case CLBRTYPE_CLUTCH:
				fval = car.KamazSignals.GetClutchPedal(false);
				break;

			case CLBRTYPE_BRAKEPEDAL:
				fval = car.KamazSignals.GetBrakePedal(false);
				break;			
			}			
			SetVariableNumber("lblCurrentValue.text", fval); 
		}
	}			
}

/** ������������� ������������� �������� � ��������� */
function StopListenSignals()
{
	`log("stop listen signals");
	mTickHelper.ClearTimer('CalibrationTimerFunc');
	bViewChangePressed = false;
	CurrentCalibrationState = CLBRTYPE_NONE;
}

/** ���������� �� ����, ��� ������ ���������� */
function FinishCalibration()
{
	if(CurrentCalibrationState != CLBRTYPE_NONE)
	{
		StopListenSignals();
	}
}

/** ��������� � ����.����� ��������������� �������� ���� */
function SaveWheelCalibration()
{
	car.KamazSignals.WheelCentral = GetVariableNumber("gWheelAverage");
	car.KamazSignals.WheelMax = GetVariableNumber("gWheelMaxRight");
	car.KamazSignals.WheelMin = GetVariableNumber("gWheelMaxLeft");
	car.KamazSignals.SaveConfig();

	`log("Save wheel calibration");
}

/** ��������� � ����.����� ��������������� �������� ������ ���� */
function SaveGasPedalCalibration()
{
	car.KamazSignals.GasPedalMin = GetVariableNumber("gGasPedalMin");
	car.KamazSignals.GasPedalMax = GetVariableNumber("gGasPedalMax");

	car.KamazSignals.SaveConfig();

	`log("Save gas calibration");
}

/** ��������� � ����.����� ��������������� �������� ������ ��������� */
function SaveClutchPedalCalibration()
{
	car.KamazSignals.ClutchPedalMin = GetVariableNumber("gClutchPedalMin");
	car.KamazSignals.ClutchPedalMax = GetVariableNumber("gClutchPedalMax");

	car.KamazSignals.SaveConfig();

	`log("Save clu calibration");
}

/** ��������� � ����.����� ��������������� �������� ������ ������� */
function SaveBrakePedalCalibration()
{
	car.KamazSignals.BrakePedalMax = GetVariableNumber("gBrakePedalMax");
	car.KamazSignals.BrakePedalMin = GetVariableNumber("gBrakePedalMin");

	car.KamazSignals.SaveConfig();

	`log("Save brake calibration");
}

/** ��������� ���������� ���������� �������� */
function SaveArrowDeviceCalibration()
{
	local ArrowDeviceData ArrDevData;
	local GFxObject gfxObj;

	gfxObj = GetVariableObject("gSpeedometerData");
	CalculateArrowDeviceData(gfxObj, ArrDevData);
	//CarControlManager.GetKamazSimulatorObject().SpeedometerData = ArrDevData;

	gfxObj = GetVariableObject("gTahometerData");
	CalculateArrowDeviceData(gfxObj, ArrDevData);
	//CarControlManager.GetKamazSimulatorObject().TahometerData = ArrDevData;

	gfxObj = GetVariableObject("gOilData");
	CalculateArrowDeviceData(gfxObj, ArrDevData);
	//CarControlManager.GetKamazSimulatorObject().OilPressureData = ArrDevData;

	gfxObj = GetVariableObject("gWaterData");
	CalculateArrowDeviceData(gfxObj, ArrDevData);
	//CarControlManager.GetKamazSimulatorObject().EngineTemperatureData = ArrDevData;
	
	gfxObj = GetVariableObject("gAccumData");
	CalculateArrowDeviceData(gfxObj, ArrDevData);
	//CarControlManager.GetKamazSimulatorObject().AccumulatorChargeData = ArrDevData;
	
	gfxObj = GetVariableObject("gBensinData");
	CalculateArrowDeviceData(gfxObj, ArrDevData);
	//CarControlManager.GetKamazSimulatorObject().FuelData = ArrDevData;

	gfxObj = GetVariableObject("gPressureData");
	CalculateArrowDeviceData(gfxObj, ArrDevData);
	//CarControlManager.GetKamazSimulatorObject().PneumaticPressureData = ArrDevData;

	car.KamazSignals.SaveConfig();
}

/** ��������� �� ������� ������ ��������������� �������� � ������������ ������������ */
function private CalculateArrowDeviceData(out GFxObject dataObj, out ArrowDeviceData arrowData)
{
//	local float fullScale, oneOfThird, tmpVal;
//	local float kfc;
	
	// ������ ������������: ����.�������� ��������� / ���� ����� ��������
	/*kfc = CarControlManager.GetKamazSimulatorObject().MaxResistorValue / CarControlManager.GetKamazSimulatorObject().MaxSliderValue;

	arrowData.min = dataObj.GetFloat("min") * kfc;
	arrowData.val_1 = dataObj.GetFloat("val_1") * kfc;
	arrowData.val_2 = dataObj.GetFloat("val_2") * kfc;
	arrowData.max = dataObj.GetFloat("max") * kfc;

	// value between max and min
	fullScale = arrowData.max - arrowData.min;

	// 33% of full scale
	oneOfThird = fullScale * 0.333333;

	// ����������� ���������� ��� ���������� ����������� �� ��������� 0 - 1\3 ���� �����
	tmpVal = arrowData.val_1 - arrowData.min;
	arrowData.koeff_1 = tmpVal / oneOfThird;
	/*if(tmpVal == 0.0)
		arrowData.koeff_1 = 0.0;
	else
		arrowData.koeff_1 = oneOfThird / tmpVal;*/

	// k2 -  val_1 -> val_2


	// ����������� ���������� ��� ���������� ����������� �� ��������� 1\3 - 2\3 ���� �����
	tmpVal = arrowData.val_2 - arrowData.val_1;
	arrowData.koeff_2 = tmpVal / oneOfThird;
	/*if(tmpVal == 0.0)
		arrowData.koeff_2 = 1.0;
	else
		arrowData.koeff_2 = oneOfThird / tmpVal;*/



	// ����������� ���������� ��� ���������� ����������� �� ��������� 2\3 - 3\3 ���� �����
	tmpVal = arrowData.max - arrowData.val_2;
	arrowData.koeff_3 = tmpVal / oneOfThird;
	/*if(tmpVal == 0.0)
		arrowData.koeff_3 = 1.0;
	else
		arrowData.koeff_3 = oneOfThird / tmpVal;*/

	// ������ ���������
	arrowData.Diff_Between_Min_13 = arrowData.val_1 - arrowData.min;
	arrowData.Diff_Between_13_23 = arrowData.val_2 - arrowData.val_1;
	arrowData.Diff_Between_23_Max = arrowData.max - arrowData.val_2;*/
}

/** ���������� �� ���� ��� �������������� ������ ���� �� ��������� */
function SliderChanged(int sliderNum, float value)
{
	local float kfc;
	local Zarnitza_KamazSignals KS;
	KS = car.KamazSignals;
	
	// ��� �������� ��������� ��������� �������:
	// ����������� �������� - 0.0
	// ������������ �������� - 10.0
	// ��� ���������� ������� - ��� - 0,  ���� - 255

	// ������ ������������: ����.�������� ��������� / ���� ����� ��������
	kfc = KS.MaxResistorValue / KS.MaxSliderValue;

	switch(sliderNum)
	{
		case 0: // speedometer
			KS.SetSpeedometer(value * kfc, false);
			break;

		case 1: // tahometer
			KS.SetTahometer(value * kfc, false);
			break;

		case 2: // oil pressure (oil)
			KS.SetOilPressure(value * kfc, false);
			break;

		case 3: // engine temperature (water)
			KS.SetEngineTemperature(value * kfc, false);
			break;

		case 4: // accumulator charge (accum)
			KS.SetAccumulatorCharge(value * kfc, false);
			break;

		case 5: // fuel (bensin)
			KS.SetFuel(value * kfc, false);
			break;

		case 6: // engine pressure (pressure)
			KS.SetPneumaticsPressure(value * kfc, false);
			break;
	}
}

function Arrow_Reset(int DeviceID)
{
	if(CalibrationDataHolder != none)
	{
		if(CalibrationDataHolder.ResetCalibrationData(DeviceID) != 0)
		{
			`warn("Some error occured when try to reset calibration Data on device: " @ DeviceID);
		}
	}
	else
		`warn("CalibrationDataHolder is empty");
}

function Arrow_AddCalibrationPoint(int DeviceID, float ResVal, float FrontVal)
{
	if(CalibrationDataHolder != none)
	{
		if(CalibrationDataHolder.AddCalibrationInfo(DeviceID, ResVal, FrontVal) != 0)
			`warn("Some error occured when try to add calibration Data on device: " @ DeviceID);;
	}
	else
		`warn("CalibrationDataHolder is empty");
}

function Arrow_OnSave()
{
	if(CalibrationDataHolder != none)
		CalibrationDataHolder.SaveCalibration();
	else
		`warn("CalibrationDataHolder is empty");
}

function Arrow_SliderChanged(int DeviceID, float value)
{
	local float kfc;
	local int result;

	`log("Arrow_SliderChanged " @ DeviceID @ value);
	
	// ��� �������� ��������� ��������� �������:
	// ����������� �������� - 0.0
	// ������������ �������� - 10.0
	// ��� ���������� ������� - ��� - 0,  ���� - 255

	// ������ ������������: ����.�������� ��������� / ���� ����� ��������
	//kfc = CarControlManager.GetKamazSimulatorObject().MaxResistorValue / CarControlManager.GetKamazSimulatorObject().MaxSliderValue;
	
	kfc = 25.5;

	if(CalibrationDataHolder != none)
	{
		result = CalibrationDataHolder.ShowCalibratedValue(DeviceID, value * kfc);
		if(result != 0)
			`warn("Some error("@result@") occured when try to show calibrated value on device: " @ DeviceID);
	}
	else
		`warn("CalibrationDataHolder is empty");
}

function Arrow_Calibrate(int DeviceID)
{
	local int result;
	result = CalibrationDataHolder.Calibrate(DeviceID);
	//result = CalibrDaraStorage.KamazSignalsObj.CalibrateDevice(DeviceID);

	`log("ArrowCalibrate"@DeviceID);

	if(result == 0)// CALIBSAMPLE_NOERROR
	{
		SetCalibState(DeviceID, true);
	}
	else
	{
		// ��������� ������
		if(result == 3)//CALIBSAMPLE_ERRSTATE - ���������� ��� �� ������ � ����������
		{
			SetCalibState(DeviceID, false);
			`warn("Error(CALIBSAMPLE_ERRSTATE) when try to calibrate device: " @ DeviceID);
		}
	}
}

function SetCalibState(int DeviceId, bool calState)
{
	ActionScriptVoid("SetCalibState");
}

function Arrow_TextChanged(int DevID, float val)
{
	`log("TextChanged :" @ DevID @ val);

	if(CalibrationDataHolder != none)
	{
		if(CalibrationDataHolder.ShowValue(DevID, int(val)) != 0)
			`warn("Some error occured when try to show res value on device: " @ DevID);
	}
	else
		`warn("CalibrationDataHolder is empty");

	//CalibrDaraStorage.KamazSignalsObj.ShowDeviceResistor(DevID, val);
}

event bool WidgetInitialized (name WidgetName, name WidgetPath, GFxObject Widget) 
{
	switch(WidgetName)
	{
		case('btnArrowDeviceCalibration'):
			widget.SetString("label", strArrowDeviceCalibration);
			break;
		case('btnWheelCalibration'):
			widget.SetString("label", strWheelCalibration);
			break;
		case('btnGasPedalCalibration'):
			widget.SetString("label", strGasPedalCalibration);
			break;
		case('btnClutchPedalCalibration'):
			widget.SetString("label", strClutchPedalCalibration);
			break;
		case('btnBrakePedalCalibration'):
			widget.SetString("label", strBrakePedalCalibration);
			break;
		case('btnStartCalibration'):
			widget.SetString("label", strStartCalibration);
			break;
		case('btnSetResSpeedometer'):
		case('btnSetResTahometer'):
		case('btnSetResOil'):
		case('btnSetResTemp'):
		case('btnSetResAccum'):
		case('btnSetResFuel'):
		case('btnSetResPneum'):
		case('btnSetValueSpeedometer'):
		case('btnSetValueTahometer'):
		case('btnSetValueOil'):
		case('btnSetValueTemp'):
		case('btnSetValueAccum'):
		case('btnSetValueFuel'):
		case('btnSetValuePneum'):
			widget.SetString("label", strAddBtn);
			break;
		case('btnResetSpeedometer'):
		case('btnResetSpeedometer'):
		case('btnResetTahometer'):
		case('btnResetOil'):
		case('btnResetTemp'):
		case('btnResetAccum'):
		case('btnResetFuel'):
		case('btnResetPneum'):
			widget.SetString("label", strResetBtn);
			break;
		case('btnCalibrateSpeedometer'):
		case('btnCalibrateSpeedometer'):
		case('btnCalibrateTahometer'):
		case('btnCalibrateOil'):
		case('btnCalibrateTemp'):
		case('btnCalibrateAccum'):
		case('btnCalibrateFuel'):
		case('btnCalibratePneum'):
			widget.SetString("label", strCalibrateBtn);
			break;
		case('btnFix'):
			widget.SetString("label", strFix);
			break;
		case('btnSave'):
			widget.SetString("label", strSave);
			break;
		case('btnBack'):
		case('btnExit'):
			widget.SetString("label", strBackBtn);
			break;	
		case('lblSetValueDesc'):
			widget.SetText(strSetValueDesc);
			break;
		case('lblAddValueDesc'):
			widget.SetText(strAddValueDesc);
			break;
		case('lblCalibrateDesc'):
			widget.SetText(strCalibrateDesc);
			break;
		case('lblSliderDescr'):
			widget.SetText(strSliderDesc);
			break;
		case('lblDevDescSpeedometer'):
			widget.SetText(strDevDescSpeedometer);
			break;
		case('lblDevDescTahometer'):
			widget.SetText(strDevDescTahometer);
			break;
		case('lblDevDescOil'):
			widget.SetText(strDevDescOil);
			break;
		case('lblDevDescTemp'):
			widget.SetText(strDevDescTemp);
			break;
		case('lblDevDescAccum'):
			widget.SetText(strDevDescAccum);
			break;
		case('lblDevDescFuel'):
			widget.SetText(strDevDescFuel);
			break;
		case('lblDevDescPneum'):
			widget.SetText(strDevDescPneum);
			break;
		// brake
		case('lblBrakeCalibrationTitle'):
			widget.SetText(strBrakeCalibrationTitle);
			break;
		case('lblBrakeTip'):
			widget.SetText(strBrakeTip);
			break;
		case('btnFinishBrakePedalCalibration'):
			widget.SetString("label", strFinishBrakePedalCalibration);
			break;
		// clutch
		case('lblClutchCalibrationTitle'):
			widget.SetText(strClutchCalibrationTitle);
			break;
		case('lblClutchTip'):
			widget.SetText(strClutchTip);
			break;
		case('btnFinishClutchPedalCalibration'):
			widget.SetString("label", strFinishClutchPedalCalibration);
			break;
		// gas
		case('lblGasCalibrationTitle'):
			widget.SetText(strGasCalibrationTitle);
			break;
		case('lblGasTip'):
			widget.SetText(strGasTip);
			break;
		case('btnFinishGasPedalCalibration'):
			widget.SetString("label", strFinishGasPedalCalibration);
			break;
		// wheel
		case('lblWheelCalibrationTitle'):
			widget.SetText(strWheelCalibrationTitle);
			break;
		case('lblWheelTip'):
			widget.SetText(strWheelTip);
			break;
		case('btnFinishWheelCalibration'):
			widget.SetString("label", strFinishWheelCalibration);
			break;		
	}
	return true;
}

function checkConfig()
{
	super.checkConfig();	
	if (len(strArrowDeviceCalibration) == 0) {
		strArrowDeviceCalibration = "���������� �������";
		bNeedToSave = true;
	}
	
	if (len(strStartCalibration) == 0) {
		strStartCalibration = "������ ����������";
		bNeedToSave = true;
	}

	if (len(strFix) == 0) {
		strFix = "�������������";
		bNeedToSave = true;
	}

	if (len(strSave) == 0) {
		strSave = "���������";
		bNeedToSave = true;
	}

	if (len(strAddBtn) == 0) {
		strAddBtn = "��������";
		bNeedToSave = true;
	}

	if (len(strCalibrateBtn) == 0) {
		strCalibrateBtn = "�����������";
		bNeedToSave = true;
	}

	if (len(strResetBtn) == 0) {
		strResetBtn = "��������";
		bNeedToSave = true;
	}

	if (len(strAddValueDesc) == 0) {
		strAddValueDesc = "������������ ��������";
		bNeedToSave = true;
	}

	if (len(strSetValueDesc) == 0) {
		strSetValueDesc = "������� ��������";
		bNeedToSave = true;
	}

	if (len(strCalibrateDesc) == 0) {
		strCalibrateDesc = "�����";
		bNeedToSave = true;
	}

	if (len(strSliderDesc) == 0) {
		strSliderDesc = "������������";
		bNeedToSave = true;
	}

	if (len(strDevDescSpeedometer) == 0) {
		strDevDescSpeedometer = "���������";
		bNeedToSave = true;
	}
	if (len(strDevDescTahometer) == 0) {
		strDevDescTahometer = "��������";
		bNeedToSave = true;
	}
	if (len(strDevDescOil) == 0) {
		strDevDescOil = "�����";
		bNeedToSave = true;
	}
	if (len(strDevDescTemp) == 0) {
		strDevDescTemp = "�����������";
		bNeedToSave = true;
	}
	if (len(strDevDescAccum) == 0) {
		strDevDescAccum = "�����������";
		bNeedToSave = true;
	}
	if (len(strDevDescFuel) == 0) {
		strDevDescFuel = "�������";
		bNeedToSave = true;
	}
	if (len(strDevDescPneum) == 0) {
		strDevDescPneum = "��������";
		bNeedToSave = true;
	}	
	// brake
	if (len(strBrakePedalCalibration) == 0) {
		strBrakePedalCalibration = "��������� ������ �������";
		bNeedToSave = true;
	}

	if (len(strBrakeCalibrationTitle) == 0) {
		strBrakeCalibrationTitle = "���������� ������ �������";
		bNeedToSave = true;
	}
	if (len(strFinishBrakePedalCalibration) == 0)
	{
		strFinishBrakePedalCalibration = "��������� ����������";
		bNeedToSave = true;
	}
	if (len(strBrakeTip) == 0) {
		strBrakeTip = "��� ������ ���������� ������ ������� ������� �� ������ \'������ ����������\'";
		bNeedToSave = true;
	}
	if (len(strBrakeTip1) == 0) {
		strBrakeTip1 = "���������� ������ ������� � ������� ��������� � ������� ������ \'�������������\'";
		bNeedToSave = true;
	}
	if (len(strBrakeTip2) == 0) {
		strBrakeTip2 = "������� �� ������ ������� �� ����� � ������� ������ \'�������������\'";
		bNeedToSave = true;
	}
	if (len(strBrakeTip3) == 0) {
		strBrakeTip3 = "���������� ���������. ��������� ���������, ����� ������ \'���������\'";
		bNeedToSave = true;
	}
	// gas
	if (len(strGasPedalCalibration) == 0) {
		strGasPedalCalibration = "���������� ������ ����";
		bNeedToSave = true;
	}

	if (len(strGasCalibrationTitle) == 0) {
		strGasCalibrationTitle = "���������� ������ ����";
		bNeedToSave = true;
	}
	if (len(strFinishGasPedalCalibration) == 0)
	{
		strFinishGasPedalCalibration = "��������� ����������";
		bNeedToSave = true;
	}
	if (len(strGasTip) == 0) {
		strGasTip = "��� ������ ���������� ������ ���� ������� �� ������ \'������ ����������\'";
		bNeedToSave = true;
	}
	if (len(strGasTip1) == 0) {
		strGasTip1 = "���������� ������ ���� � ������� ��������� � ������� ������ \'�������������\'";
		bNeedToSave = true;
	}
	if (len(strGasTip2) == 0) {
		strGasTip2 = "������� �� ������ ���� �� ����� � ������� ������ \'�������������\'";
		bNeedToSave = true;
	}
	if (len(strGasTip3) == 0) {
		strGasTip3 = "���������� ���������. ��������� ���������, ����� ������ \'���������\'";
		bNeedToSave = true;
	}
	// clutch
	if (len(strClutchPedalCalibration) == 0) {
		strClutchPedalCalibration = "���������� ������ ���������";
		bNeedToSave = true;
	}	

	if (len(strClutchCalibrationTitle) == 0) {
		strClutchCalibrationTitle = "���������� ������ ���������";
		bNeedToSave = true;
	}
	if (len(strFinishClutchPedalCalibration) == 0)
	{
		strFinishClutchPedalCalibration = "��������� ����������";
		bNeedToSave = true;
	}
	if (len(strClutchTip) == 0) {
		strClutchTip = "��� ������ ���������� ������ ��������� ������� �� ������ \'������ ����������\'";
		bNeedToSave = true;
	}
	if (len(strClutchTip1) == 0) {
		strClutchTip1 = "���������� ������ ��������� � ������� ��������� � ������� ������ \'�������������\'";
		bNeedToSave = true;
	}
	if (len(strClutchTip2) == 0) {
		strClutchTip2 = "������� �� ������ ��������� �� ����� � ������� ������ \'�������������\'";
		bNeedToSave = true;
	}
	if (len(strClutchTip3) == 0) {
		strClutchTip3 = "���������� ���������. ��������� ���������, ����� ������ \'���������\'";
		bNeedToSave = true;
	}
	// wheel
	if (len(strWheelCalibration) == 0) {
		strWheelCalibration = "���������� ����";
		bNeedToSave = true;
	}		

	if (len(strWheelCalibrationTitle) == 0) {
		strWheelCalibrationTitle = "���������� ����";
		bNeedToSave = true;
	}
	if (len(strFinishWheelCalibration) == 0) {
		strFinishWheelCalibration = "��������� ����������";
		bNeedToSave = true;
	}
	if (len(strWheelTip) == 0) {
		strWheelTip = "��� ������ ���������� ���� ������� �� ������ \'������ ����������\'";
		bNeedToSave = true;
	}
	if (len(strWheelTip1) == 0) {
		strWheelTip1 = "��������� ���� � ��������� �� ��������� � ������� ������ \'�������������\'";
		bNeedToSave = true;
	}
	if (len(strWheelTip2) == 0) {
		strWheelTip2 = "��������� ���� ������� �� ����� � ������� ������ \'�������������\'";
		bNeedToSave = true;
	}
	if (len(strWheelTip3) == 0) {
		strWheelTip3 = "��������� ���� ������ �� ����� � ������� ������ \'�������������\'";
		bNeedToSave = true;
	}
	if (len(strWheelTip4) == 0) {
		strWheelTip4 = "���������� ���������. ��������� ���������, ����� ������ \'���������\'";
		bNeedToSave = true;
	}
}

DefaultProperties
{
	MovieInfo=SwfMovie'GorodHUD.Calibration.Calibration'
	CurrentCalibrationState = CLBRTYPE_NONE
}
