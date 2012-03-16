/** ����� ��� �������� ������ �������, ���������� � ����������� */

class Gorod_RegistryEntry extends Object;

var Controller pc;
var private Gorod_CrossRoadsTrigger FirstTouchedTrigger;
var private float FirstTouchedTime;
var string Message;
enum CrossRoadEvents
{
	CREVT_MOVEONRED,                     // ������ �� ������� ���� ���������
	CREVT_MOVEONGREEN,                   // ������ �� ������� ���� ���������

	CREVT_ENTERFROMWRONGSIDE,            // ����� �� ����������� � ������������ �������
	CREVT_LEAVEFROMWRONGSIDE,            // ����� � ����������� � ������������ �������
};
var private array<CrossRoadEvents> Events;



function AddEvent(CrossRoadEvents evt)
{
	if(FindEvent(evt) == false)
	{
		Events.AddItem(evt);
	}
}

function bool FindEvent(CrossRoadEvents toFind)
{
	local CrossRoadEvents e;

	foreach Events(e)
	{
		if(e == toFind)
		{
			return true;
		}
	}

	return false;
}

function AddFirstTouchedTrigger(Gorod_CrossRoadsTrigger trg)
{
	FirstTouchedTrigger = trg;
	FirstTouchedTime = trg.WorldInfo.TimeSeconds;
}

function Gorod_CrossRoadsTrigger GetFirstTouchedTrigger()
{
	return FirstTouchedTrigger;
}

function float GetFirstTouchedTime()
{
	return FirstTouchedTime;
}

function GetEvents(out array<CrossRoadEvents> arr)
{
	local CrossRoadEvents evt;

	foreach Events(evt)
	{
		arr.AddItem(evt);
	}
}

DefaultProperties
{
}
