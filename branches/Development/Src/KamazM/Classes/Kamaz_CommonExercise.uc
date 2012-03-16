class Kamaz_CommonExercise extends Kamaz_GFxMoviePlayer;
/**
 * Ссылка на HUD
 */
var Kamaz_HUD KamazHUD;
var GFxClikWidget btnBack;
var GFxClikWidget btnBackEx;

// авто для настройки
var private Kamaz_PlayerCar car;
var Kamaz_Exercise_Base ExerciseController;

/** Вспомогательный actor, служащий для вызова функции обновления приборов в каждом тике */
var TimerHelper mTickHelper;   

/** strings from ini-file */
var config string strAccLabel;
var config string strBrakeLabel;
var config string strDoneLabel;
var config string strTranceLabel;

var config string strBtnPrev;
var config string strBtnNext;
var config string strBtnStartEx;
var config string strBtnBackEx;
var config string strNoExersiseLabel;

var config string strEx1Title;
var config string strEx1Descr_1;    // frame #1
var config string strEx1Descr_2;
var config string strEx1Descr_3;

var config string strEx2Title;
var config string strEx2Descr_1;    // frame #1
var config string strEx2Descr_2;

var config string strEx3Title;
var config string strEx3Descr_1;    // frame #1
var config string strEx3Descr_2;
var config string strEx3Descr_3;
var config string strEx3Descr_4;

var config string strEx4Title;
var config string strEx4Descr_1;    // frame #1
var config string strEx4Descr_2;
var config string strEx4Descr_3;
var config string strEx4Descr_4;

var config string strEx5Title;
var config string strEx5Descr_1;    // frame #1

var config string strEx6Title;
var config string strEx6Descr_1;    // frame #1
var config string strEx6Descr_2;
var config string strEx6Descr_3;
var config string strEx6Descr_4;
var config string strEx6Descr_5;
var config string strEx6Descr_6;

var config string strEx7Title;
var config string strEx7Descr_1;    // frame #1
var config string strEx7Descr_2;
var config string strEx7Descr_3;
var config string strEx7Descr_4;
var config string strEx7Descr_5;
var config string strEx7Descr_6;

struct ControlSignalsInfo
{
	var float Throttle; 
	var float Brake;
	var float Clutch;
	var float Steering;
	var int Gear;
}; 

var ControlSignalsInfo ControlsInfo;

function bool Start(optional bool StartPaused = false) 
{
	local Kamaz_PlayerCar refCar;
	
	super.Start(StartPaused);
	Advance(0);
	foreach GetPC().AllActors(class'Kamaz_PlayerCar', refCar)
	{
		car = refCar;
		break;
	}	
	return true;
}

event bool WidgetInitialized (name WidgetName, name WidgetPath, GFxObject Widget) 
{	
	switch(WidgetName)
	{
		case('AccLabel'):
			widget.SetText(strAccLabel);
			break;
		case('BrakeLabel'):
			widget.SetText(strBrakeLabel);
			break;
		case('Done'):
			widget.SetText(strDoneLabel);
			break;
		case('TranceLabel'):
			widget.SetText(strTranceLabel);
			break;
		case('Back'):
			btnBack = GFxClikWidget(Widget);
			btnBack.AddEventListener('CLIK_click', OnBackButtonClick);
			btnBack.SetString("label", strBackBtn);
			break;		
		case('btnPrev'):
			widget.SetString("label", strBtnPrev);
			break;
		case('btnNext'):
			widget.SetString("label", strBtnNext);
			break;
		case('btnStartEx'):
			widget.SetString("label", strBtnStartEx);
			break;
		case('BackEx'):
			btnBackEx =  GFxClikWidget(Widget);			
			btnBackEx.AddEventListener('CLIK_click', OnBackButtonClick);
			btnBackEx.SetString("label", strBtnBackEx);
			break;
		case('NoExersiseLabel'):
			widget.SetText(strNoExersiseLabel);
			break;
		// ex1
		case('Ex1Title'):			
			widget.SetText(strEx1Title);			
			break;
		case('Ex1Descr_1'):			
			widget.SetText(strEx1Descr_1);			
			break;
		case('Ex1Descr_2'):			
			widget.SetText(strEx1Descr_2);			
			break;
		case('Ex1Descr_3'):			
			widget.SetText(strEx1Descr_3);			
			break;
		// ex2
		case('Ex2Title'):			
			widget.SetText(strEx2Title);			
			break;
		case('Ex2Descr_1'):			
			widget.SetText(strEx2Descr_1);			
			break;
		case('Ex2Descr_2'):			
			widget.SetText(strEx2Descr_2);			
			break;
		// ex3
		case('Ex3Title'):			
			widget.SetText(strEx3Title);			
			break;
		case('Ex3Descr_1'):			
			widget.SetText(strEx3Descr_1);			
			break;
		case('Ex3Descr_2'):			
			widget.SetText(strEx3Descr_2);			
			break;
		case('Ex3Descr_3'):			
			widget.SetText(strEx3Descr_3);			
			break;
		case('Ex3Descr_4'):			
			widget.SetText(strEx3Descr_4);			
			break;
		// ex4
		case('Ex4Title'):			
			widget.SetText(strEx4Title);			
			break;
		case('Ex4Descr_1'):			
			widget.SetText(strEx4Descr_1);			
			break;
		case('Ex4Descr_2'):			
			widget.SetText(strEx4Descr_2);			
			break;
		case('Ex4Descr_3'):			
			widget.SetText(strEx4Descr_3);			
			break;
		case('Ex4Descr_4'):			
			widget.SetText(strEx4Descr_4);			
			break;
		// ex5
		case('Ex5Title'):			
			widget.SetText(strEx5Title);			
			break;
		case('Ex5Descr_1'):			
			widget.SetText(strEx5Descr_1);			
			break;
		// ex6
		case('Ex6Title'):			
			widget.SetText(strEx6Title);			
			break;
		case('Ex6Descr_1'):			
			widget.SetText(strEx6Descr_1);			
			break;
		case('Ex6Descr_2'):			
			widget.SetText(strEx6Descr_2);			
			break;
		case('Ex6Descr_3'):			
			widget.SetText(strEx6Descr_3);			
			break;
		case('Ex6Descr_4'):			
			widget.SetText(strEx6Descr_4);			
			break;
		case('Ex6Descr_5'):			
			widget.SetText(strEx6Descr_5);			
			break;
		case('Ex6Descr_6'):			
			widget.SetText(strEx6Descr_6);			
			break;
		// ex7
		case('Ex7Title'):			
			widget.SetText(strEx7Title);			
			break;
		case('Ex7Descr_1'):			
			widget.SetText(strEx7Descr_1);			
			break;
		case('Ex7Descr_2'):			
			widget.SetText(strEx7Descr_2);			
			break;
		case('Ex7Descr_3'):			
			widget.SetText(strEx7Descr_3);			
			break;
		case('Ex7Descr_4'):			
			widget.SetText(strEx7Descr_4);			
			break;
		case('Ex7Descr_5'):			
			widget.SetText(strEx7Descr_5);			
			break;
		case('Ex7Descr_6'):			
			widget.SetText(strEx7Descr_6);			
			break;
		default:
			break;
	}

	return true;
}

function OnBackButtonClick(GFxClikWidget.EventData ev)
{
	KamazHUD.ShowExerciseList();
}

function StartExercise(string ExerciseFrame, class<Kamaz_Exercise_Base> ExerciseClass, string ExerciseDescription, int RepetitionCount)
{
	ExerciseController = new ExerciseClass;

	if(ExerciseController != none)
	{
		ExerciseController.SetParentGFx(self);
		ExerciseController.SetRepetitionCount(RepetitionCount);
		OpenExercise(ExerciseFrame, ExerciseDescription);		
		
		if (mTickHelper == none)
		{
			mTickHelper = GetPC().Spawn(class'TimerHelper',, 'Kamaz_CalibrationHelper');
			mTickHelper.dlgTimerFunc = ListenControls;
		}		
		mTickHelper.DoFunc(true);
		`log("start listen signals");
	}
	else
	{
		`warn("Failed to start exercise!");
	}
}

function OpenExercise(string ExerciseFrame, string ExerciseDescription)
{
	ActionScriptVoid("OpenExercise");
}

event OnClose()
{
	mTickHelper.DoFunc(false);

	if(ExerciseController != none)
		ExerciseController.Finish();
}

/**
 * Опрос управляющих устройств и обновление значений для флэшки
 */
function ListenControls()
{	
	GetControlValues();
	SetControlValues();
	
	if(ExerciseController != none)
		ExerciseController.Update(ControlsInfo);
}

function int GetGear()
{
	local int nval;
	if (car.KamazSignals != none)
	{
		if (car.KamazSignals.GetBackStep())
			nval =-1;		
		else if(car.KamazSignals.GetFirstStep())
			nval = 1;
		else if(car.KamazSignals.GetSecondStep())
			nval = 2;
		else if(car.KamazSignals.GetThirdStep())
			nval = 3;
		else if(car.KamazSignals.GetFourthStep())
			nval = 4;
		else if(car.KamazSignals.GetFifthStep())
			nval = 5;		
	}
	return nval;
}

function GetControlValues()
{
	if (car.KamazSignals != none)
	{
		ControlsInfo.Steering = car.KamazSignals.GetSteering();
		ControlsInfo.Throttle = car.KamazSignals.GetGasPedal();
		ControlsInfo.Brake = car.KamazSignals.GetBrakePedal();
		ControlsInfo.Clutch = car.KamazSignals.GetClutchPedal(false);
		ControlsInfo.Gear = GetGear();
	}
}

function SetControlValues()
{
	SetSteering(ControlsInfo.Steering);
	SetThrottle(ControlsInfo.Throttle);
	SetBrake(ControlsInfo.Brake);
	SetClutch(ControlsInfo.Clutch);
	SetGear(ControlsInfo.Gear);
}

/************************************************************/
/*          Функции вызываемые из UDK во flash'е            */
/************************************************************/

/**
 * Установка значения угла поворота руля
 */
function SetSteering(float val)
{
	ActionScriptVoid("SetSteeringAngle");
}

/**
 * Установка значения степени нажатия на педаль газа
 */
function SetThrottle(float val)
{
	ActionScriptVoid("SetThrottle");
}

/**
 * Установка значения степени нажатия на педаль тормоза
 */
function SetBrake(float val)
{
	ActionScriptVoid("SetBrake");
}

/**
 * Установка значения степени нажатия на педаль сцепления
 */
function SetClutch(float val)
{
	ActionScriptVoid("SetClutch");
}

/**
 * Установка значения передачи
 */
function SetGear(int val)
{
	ActionScriptVoid("SetGear");
}

/**
 * Установка значения счётчика повторов
 */
function SetCount(string str)
{
	ActionScriptVoid("SetCount");
}

/**
 * Устанавливает максимальный угол поворота руля
 */
function SetMaxSteerAngle(float angle_pos, float angle_neg)
{
	ActionScriptVoid("SetMaxSteerAngle");
}

/**
 * Начинаем проигрывать анимацию, определяемую параметром val
 */
function StartAnim(int val, optional bool bFinished = false)
{
	ActionScriptVoid("StartAnim");
}

/**
 * Завершить упражнение
 */
function FinishExercise()
{
	ActionScriptVoid("FinishExercise");
}

/****************************************************/
/*          Функции, вызываемые из flash            */
/****************************************************/
/**
 * Начало упражнения повторно
 */
function StartExerciseAgain()
{
	ExerciseController.Start();
}

/**
 * Переход к следующему упражнению
 */
function GotoNextExercise()
{
	KamazHUD.ShowCommonExercise(EST_Next);
}

/**
 * Переход к предыдущему упражнению
 */
function GotoPrevExercise()
{
	KamazHUD.ShowCommonExercise(EST_Prev);
}

/** Проверка на наличие UI текстов в ini-файле */
function checkConfig()
{
	if (len(strAccLabel) == 0) {
		strAccLabel = "Газ";
		bNeedToSave = true;
	}

	if (len(strBrakeLabel) == 0) {
		strBrakeLabel = "Тормоз";
		bNeedToSave = true;
	}

	if (len(strTranceLabel) == 0) {
		strTranceLabel = "Сцепление";
		bNeedToSave = true;
	}

	if (len(strDoneLabel) == 0) {
		strDoneLabel = "Выполнено!";
		bNeedToSave = true;
	}
	
	if (len(strBtnPrev) == 0) {
		strBtnPrev = "Назад";
		bNeedToSave = true;
	}

	if (len(strBtnNext) == 0) {
		strBtnNext = "Далее";
		bNeedToSave = true;
	}

	if (len(strBtnStartEx) == 0) {
		strBtnStartEx = "СТАРТ";
		bNeedToSave = true;
	}

	if (len(strBtnBackEx) == 0)
	{
		strBtnBackEx = "К списку";
		bNeedToSave = true;
	}
	
	if (len(strNoExersiseLabel) == 0)
	{
		strNoExersiseLabel = "Упражнение недоступно";
		bNeedToSave = true;
	}
	// ex1
	if (len(strEx1Title) == 0)
	{
		strEx1Title = "Упражнение №1";
		bNeedToSave = true;
	}

	if (len(strEx1Descr_1) == 0)
	{
		strEx1Descr_1 = "Положите руки на руль. Кисти рук должны лежать на рулевом колесе чуть выше горизонтальной оси руля, в локтях приблизительно 120°. При этом неправильным является положение кистей на нижней части руля. Для  продолжения нажмите педаль газа наполовину.";
		bNeedToSave = true;
	}
	
	if (len(strEx1Descr_2) == 0)
	{
		strEx1Descr_2 = "Поверните руль НАЛЕВО, не отрывая рук от рулевого колеса.";
		bNeedToSave = true;
	}

	if (len(strEx1Descr_3) == 0)
	{
		strEx1Descr_3 = "Поверните руль НАПРАВО, не отрывая рук от рулевого колеса.";
		bNeedToSave = true;
	}
	// ex2
	if (len(strEx2Title) == 0)
	{
		strEx2Title = "Упражнение №2";
		bNeedToSave = true;
	}

	if (len(strEx2Descr_1) == 0)
	{
		strEx2Descr_1 = "Поверните руль ВПРАВО. При повороте рулевого колеса перехватом ПРАВАЯ рука выполняет основную работу, а ЛЕВАЯ выполняет вспомогательную работу, обеспечивая вращение руля без остановок.";
		bNeedToSave = true;
	}
	
	if (len(strEx2Descr_2) == 0)
	{
		strEx2Descr_2 = "Поверните руль ВЛЕВО. При повороте рулевого колеса перехватом ЛЕВАЯ рука выполняет основную работу, а ПРАВАЯ выполняет вспомогательную работу, обеспечивая вращение руля без остановок";
		bNeedToSave = true;
	}
	// ex3
	if (len(strEx3Title) == 0)
	{
		strEx3Title = "Упражнение №3";
		bNeedToSave = true;
	}

	if (len(strEx3Descr_1) == 0)
	{
		strEx3Descr_1 = "Поверните руль ВПРАВО. При повороте рулевого колеса перебором следует попеременно выполнять движения правой и левой рукой по очереди в равной степени.";
		bNeedToSave = true;
	}
	
	if (len(strEx3Descr_2) == 0)
	{
		strEx3Descr_2 = "Поверните руль ВЛЕВО. При повороте рулевого колеса перебором следует попеременно выполнять движения правой и левой рукой по очереди в равной степени.";
		bNeedToSave = true;
	}

	if (len(strEx3Descr_3) == 0)
	{
		strEx3Descr_3 = "Поверните руль ВПРАВО одной рукой. Вращение рулевого колеса следует производить ЛЕВОЙ рукой. При этом кисть руки должна постоянно находиться в одной и той же позиции на ободе руля.";
		bNeedToSave = true;
	}

	if (len(strEx3Descr_4) == 0)
	{
		strEx3Descr_4 = "Поверните руль ВЛЕВО одной рукой. Вращение рулевого колеса следует производить ПРАВОЙ рукой. При этом кисть руки должна постоянно находиться в одной и той же позиции на ободе руля.";
		bNeedToSave = true;
	}	
	// ex4
	if (len(strEx4Title) == 0)
	{
		strEx4Title = "Упражнение №4";
		bNeedToSave = true;
	}

	if (len(strEx4Descr_1) == 0)
	{
		strEx4Descr_1 = "При нажатии на педали ноги должны занимать опеределённое положение. ПРАВОЙ ногой необходимо нажимать на педали ГАЗА и ТОРМОЗА, а ЛЕВОЙ - на педаль СЦЕПЛЕНИЯ. Для продолжения нажмите педаль газа наполовину.";
		bNeedToSave = true;
	}
	
	if (len(strEx4Descr_2) == 0)
	{
		strEx4Descr_2 = "Нажмите на педаль газа.";
		bNeedToSave = true;
	}

	if (len(strEx4Descr_3) == 0)
	{
		strEx4Descr_3 = "Нажмите на педаль тормоза.";
		bNeedToSave = true;
	}

	if (len(strEx4Descr_4) == 0)
	{
		strEx4Descr_4 = "Нажмите на педаль сцепления.";
		bNeedToSave = true;
	}	
	// ex5
	if (len(strEx5Title) == 0)
	{
		strEx5Title = "Упражнение №5";
		bNeedToSave = true;
	}

	if (len(strEx5Descr_1) == 0)
	{
		strEx5Descr_1 = "\'Качели\' Поочерёдно нажимайте на педали газа и сцепления так, чтобы степень нажатия на педаль газа была тем сильнее, чем слабее степень нажатия на педаль сцепления, и наоборот.";
		bNeedToSave = true;
	}
	// ex6
	if (len(strEx6Title) == 0)
	{
		strEx6Title = "Упражнение №6";
		bNeedToSave = true;
	}

	if (len(strEx6Descr_1) == 0)
	{
		strEx6Descr_1 = "Включите 1 передачу, после чего верните рычаг переключения скоростей обратно в нейтральное положение. При этом переключение стоит производить с нажатой педалью сцепления.";
		bNeedToSave = true;
	}
	
	if (len(strEx6Descr_2) == 0)
	{
		strEx6Descr_2 = "Включите 2 передачу, после чего верните рычаг переключения скоростей обратно в нейтральное положение. При этом переключение стоит производить с нажатой педалью сцепления.";
		bNeedToSave = true;
	}

	if (len(strEx6Descr_3) == 0)
	{
		strEx6Descr_3 = "Включите 3 передачу, после чего верните рычаг переключения скоростей обратно в нейтральное положение. При этом переключение стоит производить с нажатой педалью сцепления.";
		bNeedToSave = true;
	}

	if (len(strEx6Descr_4) == 0)
	{
		strEx6Descr_4 = "Включите 4 передачу, после чего верните рычаг переключения скоростей обратно в нейтральное положение. При этом переключение стоит производить с нажатой педалью сцепления.";
		bNeedToSave = true;
	}
	if (len(strEx6Descr_5) == 0)
	{
		strEx6Descr_5 = "Включите 5 передачу, после чего верните рычаг переключения скоростей обратно в нейтральное положение. При этом переключение стоит производить с нажатой педалью сцепления.";
		bNeedToSave = true;
	}

	if (len(strEx6Descr_6) == 0)
	{
		strEx6Descr_6 = "Включите передачу заднего хода, после чего верните рычаг переключения скоростей обратно в нейтральное положение. При этом переключение стоит производить с нажатой педалью сцепления.";
		bNeedToSave = true;
	}
	// ex7
	if (len(strEx7Title) == 0)
	{
		strEx7Title = "Упражнение №7";
		bNeedToSave = true;
	}

	if (len(strEx7Descr_1) == 0)
	{
		strEx7Descr_1 = "Включите 1 передачу, после чего верните рычаг переключения скоростей обратно в нейтральное положение. При этом переключение стоит производить с нажатой педалью сцепления";
		bNeedToSave = true;
	}
	
	if (len(strEx7Descr_2) == 0)
	{
		strEx7Descr_2 = "Включите 2 передачу, после чего верните рычаг переключения скоростей обратно в нейтральное положение. При этом переключение стоит производить с нажатой педалью сцепления.";
		bNeedToSave = true;
	}

	if (len(strEx7Descr_3) == 0)
	{
		strEx7Descr_3 = "Включите 3 передачу, после чего верните рычаг переключения скоростей обратно в нейтральное положение. При этом переключение стоит производить с нажатой педалью сцепления.";
		bNeedToSave = true;
	}

	if (len(strEx7Descr_4) == 0)
	{
		strEx7Descr_4 = "Включите 4 передачу, после чего верните рычаг переключения скоростей обратно в нейтральное положение. При этом переключение стоит производить с нажатой педалью сцепления.";
		bNeedToSave = true;
	}

	if (len(strEx7Descr_5) == 0)
	{
		strEx7Descr_5 = "Включите 5 передачу, после чего верните рычаг переключения скоростей обратно в нейтральное положение. При этом переключение стоит производить с нажатой педалью сцепления.";
		bNeedToSave = true;
	}
	if (len(strEx7Descr_6) == 0)
	{
		strEx7Descr_6 = "Включите передачу заднего хода, после чего верните рычаг переключения скоростей обратно в нейтральное положение. При этом переключение стоит производить с нажатой педалью сцепления.";
		bNeedToSave = true;
	}
	
	
	
	if (len(strBackBtn) == 0) {
		strBackBtn = "Назад";
		bNeedToSave = true;
	}
}

function save()
{
	if (bNeedToSave) saveConfig();
}

DefaultProperties
{
	MovieInfo = SwfMovie'GorodHUD.CommonExercise.SF_CommonExercise';
	bCaptureInput = true;

	WidgetBindings.Add((WidgetName="Back", WidgetClass=class'GFxClikWidget'));
	WidgetBindings.Add((WidgetName="BackEx", WidgetClass=class'GFxClikWidget'));
}
