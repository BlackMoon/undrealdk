class Kamaz_ExerciseList extends Kamaz_GFxMoviePlayer;	
/**
 * Ссылка на HUD
 */
var Kamaz_HUD KamazHUD;
var GFxClikWidget btnBack;
var GFxClikWidget btnSelect;
/** strings from ini-file */
var config string strSelectBtn;
var config string strExercisesMenuTitle;
var config string strExercisesDescription;
/**
 * Информация об упражнении
 */
struct ExerciseInfo
{
	/** Название упражнения */
	var string ExerciseName;
	/** Название соответствующего кадра из флэшки */
	var string ExerciseFrame;
	/** Название класса следящего за правильным выполнением данного упражнения */
	var class<Kamaz_Exercise_Base> ExerciseClass;
	/** описание упражнения */
	var string ExerciseDescription;
	/** количество повторов */
	var int RepetitionCount;
};

/**
 * Список упражнений
 */
var config array<ExerciseInfo> ExerciseInfoList;

/**
 * Индекс упражнения, выбранного в списке
 */
var int SelectedIndex;

function bool Start(optional bool StartPaused = false) 
{
	super.Start(StartPaused);
	Advance(0);
	
	SelectedIndex = 0;
	SetSelectedIndex(0);

	return true;
}

event bool WidgetInitialized (name WidgetName, name WidgetPath, GFxObject Widget) 
{
	switch(WidgetName)
	{
		case('exercisesBack'):
			btnBack = GFxClikWidget(Widget);
			btnBack.AddEventListener('CLIK_click', OnBackButtonClick);
			btnBack.SetString("label", strBackBtn);
			break;
		case('exercisesSelect'):
			btnSelect = GFxClikWidget(Widget);
			btnSelect.AddEventListener('CLIK_click', OnSelectButtonClick);
			btnSelect.SetString("label", strSelectBtn);
			break;
		case('exercisesMenuTitle'):
			widget.SetString("label", strExercisesMenuTitle);
			break;
		case('exercisesDescription'):
			widget.SetText(strExercisesDescription);
			break;
		default:
			break;
	}
	return true;
}

/****************************************************************/
/*          Ф-ции для взаимодействия с ActionScript'ом          */
/****************************************************************/

/**
 * Возврат к главному меню 
 */
function OnBackButtonClick(GFxClikWidget.EventData ev)
{
	KamazHUD.ShowMainMenu();
}

/**
 * Переход к выполнению выбранного упражнения
 */
function OnSelectButtonClick(GFxClikWidget.EventData ev)
{
	// если задан подходящий SeletedIndex, открываем нужное упражнение
	if(SelectedIndex >= 0 && SelectedIndex < ExerciseInfoList.Length)
		KamazHUD.ShowCommonExercise();
}

function bool GetCurrentExercise(out string ExerciseFrame, out class<Kamaz_Exercise_Base> ExerciseClass, out string ExerciseDescription, out int RepetitionCount)
{
	if(SelectedIndex >= 0 && SelectedIndex < ExerciseInfoList.Length)
	{
		ExerciseFrame = ExerciseInfoList[SelectedIndex].ExerciseFrame;
		ExerciseClass = ExerciseInfoList[SelectedIndex].ExerciseClass;
		ExerciseDescription = ExerciseInfoList[SelectedIndex].ExerciseDescription;
		RepetitionCount = ExerciseInfoList[SelectedIndex].RepetitionCount;

		return true;
	}
	else
	{
		return false;
	}
}

function bool GetNextExercise(out string ExerciseFrame, out class<Kamaz_Exercise_Base> ExerciseClass, out string ExerciseDescription, out int RepetitionCount)
{
	if(SelectedIndex + 1 >= ExerciseInfoList.Length)
		return false;

	SelectedIndex++;
	if(GetCurrentExercise(ExerciseFrame, ExerciseClass, ExerciseDescription, RepetitionCount))
		return true;
	else
		return false;
}

function bool GetPrevExercise(out string ExerciseFrame, out class<Kamaz_Exercise_Base> ExerciseClass, out string ExerciseDescription, out int RepetitionCount)
{
	if(SelectedIndex - 1 < 0)
		return false;

	SelectedIndex--;
	if(GetCurrentExercise(ExerciseFrame, ExerciseClass, ExerciseDescription, RepetitionCount))
		return true;
	else
		return false;
}

/**
 * Обработчик события изменения выбранного индекса в списке упражнений
 */
function SelectedIndexChanged(int index)
{
	SelectedIndex = index;
}

/**
 * Добавление упражнения и его описания в список
 */
function InsertExerciseToList(string ExerciseName, string Exercisedescription)
{
	ActionScriptVoid("InsertExerciseToList");
}

/**
 * Задание текущего выбранного индекса в списке упражнений
 */
function SetSelectedIndex(int index)
{
	ActionScriptInt("SetSelectedIndex");
}

/**
 * Инициализация списка упражнений
 */
function CreateExerciseList()
{
	local ExerciseInfo EI;

	foreach ExerciseInfoList(EI)
	{
		InsertExerciseToList(EI.ExerciseName, EI.ExerciseDescription);
	}

	SelectedIndex = 0;
	SetSelectedIndex(0);
}

/** Проверка на наличие UI текстов в ini-файле */
function checkConfig()
{
	if (len(strSelectBtn) == 0) {
		strSelectBtn = "Выбрать";				
		bNeedToSave = true;		
	}	

	if (len(strExercisesMenuTitle) == 0) {
		strExercisesMenuTitle = "Навыки управления автомобилем";				
		bNeedToSave = true;		
	}	

	if (len(strExercisesDescription) == 0) {
		strExercisesDescription = "Описание отсутствует";				
		bNeedToSave = true;		
	}

	if (len(strBackBtn) == 0) {
		strBackBtn = "Назад";
		bNeedToSave = true;
	}
	// excersises
	if (ExerciseInfoList.Length == 0)
	{
		fillExercises();
		bNeedToSave = true;
	}
}

/** Заполняет массив заданий */
function fillExercises()
{
	local ExerciseInfo exi;	
	
	exi.ExerciseName = "Упражнение 1";
	exi.ExerciseClass = Class'KamazM.Kamaz_Exercise_Steer1';
	exi.ExerciseDescription = "Вращение руля без отрыва рук. Этот способ руления применяется тогда, когда необходимо незначительно изменить направление движения машины, с последующим ее возвратом в положение прямолинейного движения.";
	exi.ExerciseFrame = "Exercise1";
	exi.RepetitionCount = 2;
	ExerciseInfoList.AddItem(exi);	

	exi.ExerciseName = "Упражнение 2";
	exi.ExerciseClass = Class'KamazM.Kamaz_Exercise_Steer234';
	exi.ExerciseDescription = "Вращение руля перехватом. Следите за тем, чтобы руль вращался без остановок, для чего руки должны периодически передавать \'лидерство\' друг другу. Не выворачивайте \'наизнанку\' свои руки, пытаясь продолжить вращение руля. При \'перехвате\' руля нельзя разносить кисти рук относительно друг друга больше, чем на ширину одного-двух кулаков.";
	exi.ExerciseFrame = "Exercise2";
	exi.RepetitionCount = 2;
	ExerciseInfoList.AddItem(exi);	

	exi.ExerciseName = "Упражнение 3";
	exi.ExerciseClass = Class'KamazM.Kamaz_Exercise_Steer234';
	exi.ExerciseDescription = "Вращение руля одной рукой. Работая одной рукой, правой или левой в зависимости от необходимости, водитель имеет возможность поворачивать руль с максимальной скоростью и точностью.";
	exi.ExerciseFrame = "Exercise4";
	exi.RepetitionCount = 2;
	ExerciseInfoList.AddItem(exi);	

	exi.ExerciseName = "Упражнение 4";
	exi.ExerciseClass = Class'KamazM.Kamaz_Exercise_Pedal1';
	exi.ExerciseDescription = "Последовательное нажатие на педали. Нажимать на педаль кончиками пальцев или серединой стопы нельзя. При работе педалью газа оптимальной зоной считается зона перехода подушечек стопы в пальцы. Нажимать на педаль сцепления следует быстро, одним движением, до конца хода педали.";
	exi.ExerciseFrame = "Exercise5";
	exi.RepetitionCount = 2;
	ExerciseInfoList.AddItem(exi);	

	exi.ExerciseName = "Упражнение 5";
	exi.ExerciseClass = Class'KamazM.Kamaz_Exercise_Pedal2';
	exi.ExerciseDescription = "Упражнение на одновременную работу педалями газа и сцепления. Нажмите педаль сцепления. Плавно отпустите педаль сцепления и одновременно плавно нажмите педаль газа. Затем плавно нажмите педаль газа и одновременно плавно отпустите педаль сцепления.";
	exi.ExerciseFrame = "Exercise6";
	exi.RepetitionCount = 2;
	ExerciseInfoList.AddItem(exi);	

	exi.ExerciseName = "Упражнение 6";
	exi.ExerciseClass = Class'KamazM.Kamaz_Exercise_Gear1';
	exi.ExerciseDescription = "Последовательное переключение передач в порядке увеличения. Для переключения передач необходимо нажать педаль сцепления, включить нужную передачу, а затем отпустить педаль сцепления. Не следует прилагать к рычагу переключения передач излишних усилий.";
	exi.ExerciseFrame = "Exercise7";
	exi.RepetitionCount = 2;
	ExerciseInfoList.AddItem(exi);	

	exi.ExerciseName = "Упражнение 7";
	exi.ExerciseClass = Class'KamazM.Kamaz_Exercise_Gear2';
	exi.ExerciseDescription = "Последовательное переключение передач в случайном порядке порядке. Для переключения передач необходимо нажать педаль сцепления, включить нужную передачу, а затем отпустить педаль сцепления. Не следует прилагать к рычагу переключения передач излишних усилий.";
	exi.ExerciseFrame = "Exercise8";
	exi.RepetitionCount = 2;
	ExerciseInfoList.AddItem(exi);	
}

function save()
{
	if (bNeedToSave) saveConfig();
}

DefaultProperties
{
	MovieInfo = SwfMovie'GorodHUD.ExerciseList.SF_ExerciseList';
	bCaptureInput = true;

	WidgetBindings.Add((WidgetName="exercisesBack", WidgetClass=class'GFxClikWidget'));
	WidgetBindings.Add((WidgetName="exercisesSelect", WidgetClass=class'GFxClikWidget'));
}