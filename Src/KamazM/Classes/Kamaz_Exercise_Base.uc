class Kamaz_Exercise_Base extends Object dependson(Kamaz_CommonExercise);

var protected Kamaz_CommonExercise ParentGFx;

/**
 * Флаг, показывающий, что упражнение работает
 */
var bool bIsWorking;

/**
 * Количество повторов
 */
var int RepetitionCount;

/**
 * счётчик повторов
 */
var int counter;

/**
 * Максимальный угол поворота руля (как влево, так и вправо)
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
 * Обновление значений сигналов, пришедших от устройств
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
