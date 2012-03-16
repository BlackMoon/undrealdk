class Kamaz_ExerciseList extends Kamaz_GFxMoviePlayer;	
/**
 * ������ �� HUD
 */
var Kamaz_HUD KamazHUD;
var GFxClikWidget btnBack;
var GFxClikWidget btnSelect;
/** strings from ini-file */
var config string strSelectBtn;
var config string strExercisesMenuTitle;
var config string strExercisesDescription;
/**
 * ���������� �� ����������
 */
struct ExerciseInfo
{
	/** �������� ���������� */
	var string ExerciseName;
	/** �������� ���������������� ����� �� ������ */
	var string ExerciseFrame;
	/** �������� ������ ��������� �� ���������� ����������� ������� ���������� */
	var class<Kamaz_Exercise_Base> ExerciseClass;
	/** �������� ���������� */
	var string ExerciseDescription;
	/** ���������� �������� */
	var int RepetitionCount;
};

/**
 * ������ ����������
 */
var config array<ExerciseInfo> ExerciseInfoList;

/**
 * ������ ����������, ���������� � ������
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
/*          �-��� ��� �������������� � ActionScript'��          */
/****************************************************************/

/**
 * ������� � �������� ���� 
 */
function OnBackButtonClick(GFxClikWidget.EventData ev)
{
	KamazHUD.ShowMainMenu();
}

/**
 * ������� � ���������� ���������� ����������
 */
function OnSelectButtonClick(GFxClikWidget.EventData ev)
{
	// ���� ����� ���������� SeletedIndex, ��������� ������ ����������
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
 * ���������� ������� ��������� ���������� ������� � ������ ����������
 */
function SelectedIndexChanged(int index)
{
	SelectedIndex = index;
}

/**
 * ���������� ���������� � ��� �������� � ������
 */
function InsertExerciseToList(string ExerciseName, string Exercisedescription)
{
	ActionScriptVoid("InsertExerciseToList");
}

/**
 * ������� �������� ���������� ������� � ������ ����������
 */
function SetSelectedIndex(int index)
{
	ActionScriptInt("SetSelectedIndex");
}

/**
 * ������������� ������ ����������
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

/** �������� �� ������� UI ������� � ini-����� */
function checkConfig()
{
	if (len(strSelectBtn) == 0) {
		strSelectBtn = "�������";				
		bNeedToSave = true;		
	}	

	if (len(strExercisesMenuTitle) == 0) {
		strExercisesMenuTitle = "������ ���������� �����������";				
		bNeedToSave = true;		
	}	

	if (len(strExercisesDescription) == 0) {
		strExercisesDescription = "�������� �����������";				
		bNeedToSave = true;		
	}

	if (len(strBackBtn) == 0) {
		strBackBtn = "�����";
		bNeedToSave = true;
	}
	// excersises
	if (ExerciseInfoList.Length == 0)
	{
		fillExercises();
		bNeedToSave = true;
	}
}

/** ��������� ������ ������� */
function fillExercises()
{
	local ExerciseInfo exi;	
	
	exi.ExerciseName = "���������� 1";
	exi.ExerciseClass = Class'KamazM.Kamaz_Exercise_Steer1';
	exi.ExerciseDescription = "�������� ���� ��� ������ ���. ���� ������ ������� ����������� �����, ����� ���������� ������������� �������� ����������� �������� ������, � ����������� �� ��������� � ��������� �������������� ��������.";
	exi.ExerciseFrame = "Exercise1";
	exi.RepetitionCount = 2;
	ExerciseInfoList.AddItem(exi);	

	exi.ExerciseName = "���������� 2";
	exi.ExerciseClass = Class'KamazM.Kamaz_Exercise_Steer234';
	exi.ExerciseDescription = "�������� ���� ����������. ������� �� ���, ����� ���� �������� ��� ���������, ��� ���� ���� ������ ������������ ���������� \'���������\' ���� �����. �� ������������� \'���������\' ���� ����, ������� ���������� �������� ����. ��� \'���������\' ���� ������ ��������� ����� ��� ������������ ���� ����� ������, ��� �� ������ ������-���� �������.";
	exi.ExerciseFrame = "Exercise2";
	exi.RepetitionCount = 2;
	ExerciseInfoList.AddItem(exi);	

	exi.ExerciseName = "���������� 3";
	exi.ExerciseClass = Class'KamazM.Kamaz_Exercise_Steer234';
	exi.ExerciseDescription = "�������� ���� ����� �����. ������� ����� �����, ������ ��� ����� � ����������� �� �������������, �������� ����� ����������� ������������ ���� � ������������ ��������� � ���������.";
	exi.ExerciseFrame = "Exercise4";
	exi.RepetitionCount = 2;
	ExerciseInfoList.AddItem(exi);	

	exi.ExerciseName = "���������� 4";
	exi.ExerciseClass = Class'KamazM.Kamaz_Exercise_Pedal1';
	exi.ExerciseDescription = "���������������� ������� �� ������. �������� �� ������ ��������� ������� ��� ��������� ����� ������. ��� ������ ������� ���� ����������� ����� ��������� ���� �������� ��������� ����� � ������. �������� �� ������ ��������� ������� ������, ����� ���������, �� ����� ���� ������.";
	exi.ExerciseFrame = "Exercise5";
	exi.RepetitionCount = 2;
	ExerciseInfoList.AddItem(exi);	

	exi.ExerciseName = "���������� 5";
	exi.ExerciseClass = Class'KamazM.Kamaz_Exercise_Pedal2';
	exi.ExerciseDescription = "���������� �� ������������� ������ �������� ���� � ���������. ������� ������ ���������. ������ ��������� ������ ��������� � ������������ ������ ������� ������ ����. ����� ������ ������� ������ ���� � ������������ ������ ��������� ������ ���������.";
	exi.ExerciseFrame = "Exercise6";
	exi.RepetitionCount = 2;
	ExerciseInfoList.AddItem(exi);	

	exi.ExerciseName = "���������� 6";
	exi.ExerciseClass = Class'KamazM.Kamaz_Exercise_Gear1';
	exi.ExerciseDescription = "���������������� ������������ ������� � ������� ����������. ��� ������������ ������� ���������� ������ ������ ���������, �������� ������ ��������, � ����� ��������� ������ ���������. �� ������� ��������� � ������ ������������ ������� �������� ������.";
	exi.ExerciseFrame = "Exercise7";
	exi.RepetitionCount = 2;
	ExerciseInfoList.AddItem(exi);	

	exi.ExerciseName = "���������� 7";
	exi.ExerciseClass = Class'KamazM.Kamaz_Exercise_Gear2';
	exi.ExerciseDescription = "���������������� ������������ ������� � ��������� ������� �������. ��� ������������ ������� ���������� ������ ������ ���������, �������� ������ ��������, � ����� ��������� ������ ���������. �� ������� ��������� � ������ ������������ ������� �������� ������.";
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