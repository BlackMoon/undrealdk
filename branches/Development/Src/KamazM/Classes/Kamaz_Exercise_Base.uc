class Kamaz_Exercise_Base extends Object dependson(Kamaz_CommonExercise);

var protected Kamaz_CommonExercise ParentGFx;

/**
 * ����, ������������, ��� ���������� ��������
 */
var bool bIsWorking;

/**
 * ���������� ��������
 */
var int RepetitionCount;

/**
 * ������� ��������
 */
var int counter;

/**
 * ������������ ���� �������� ���� (��� �����, ��� � ������)
 */
var float MaxSteerAngle_Pos;
var float MaxSteerAngle_Neg;


function SetParentGFx(Kamaz_CommonExercise parent)
{
	ParentGFx = parent;
}

function SetRepetitionCount(int RepCount)
{
	RepetitionCount = RepCount;
}

function Start()
{
	bIsWorking = true;
	ParentGFx.SetMaxSteerAngle(MaxSteerAngle_Pos, MaxSteerAngle_Neg);
}

function Finish()
{
	bIsWorking = false;
	ParentGFx.FinishExercise();
}

function Update(ControlSignalsInfo ControlsInfo)
{
	if(bIsWorking)
	{
		UpdateSignals(ControlsInfo);
	}
}

/**
 * ���������� �������� ��������, ��������� �� ���������
 */
function UpdateSignals(ControlSignalsInfo ControlsInfo)
{
}

function IncCounter()
{
	counter++;
	ParentGFx.SetCount(counter @ "/" @ RepetitionCount);
}

function ResetCounter()
{
	counter = 0;
	ParentGFx.SetCount(counter @ "/" @ RepetitionCount);
}

function float GetDegreesBySteering(float steering)
{
	if(steering >= 0)
		return steering*MaxSteerAngle_Pos;
	else
		return steering*MaxSteerAngle_Neg;
}

DefaultProperties
{
	bIsWorking = false;
	MaxSteerAngle_Pos = 675;
	MaxSteerAngle_Neg = 765;
}
