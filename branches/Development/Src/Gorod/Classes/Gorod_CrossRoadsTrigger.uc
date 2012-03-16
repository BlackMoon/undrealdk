class Gorod_CrossRoadsTrigger extends Gorod_Trigger placeable;

/** ��� �������� */
enum TriggerType
{
	TRIGGERTYPE_ENTRY,                  // ��� ��������, ��������������� ���������� ����� �� �����������
	TRIGGERTYPE_INVALIDENTRY,           // ��� ��������, ��������������� ������������ ����� �� ����������� (�������� � �������)
	TRIGGERTYPE_EXIT                    // ��� �������� "����� �� �����������"
};

struct TriggerReference
{
	var() Gorod_CrossRoadsTrigger triggerRef;                           // ������ �� �������
	var() string Message;                                               // ���������
	var() int MessageID;                                                // ����� ���������
	var() bool bShowMessageInHUD;                                          

	structdefaultproperties
	{
		MessageID = -1
		bShowMessageInHUD = false
	}
};

var(CrossroadsTrigger) TriggerType trType;                              // ��� ��������

var Gorod_CrossRoad ParentCrossroad;                                   // ������ �� ��������� ������ ��������� �����������
var(CrossroadsTrigger) array<TriggerReference> CorrectTriggers;        // ������ ���������, �� ������� �������� ������ �� ������� ��������
var(CrossroadsTrigger) array<TriggerReference> IncorrectTriggers;      // ������ ���������, �� ������� �������� ������ �� ������� ��������

/** ��������� �������� (true - ������������) */
var bool IsBlocked;

/** ���� ���� �������(true), � ������ ����� ����������� ��������� ������� (��������� ������ � ���������� ������ ������) */
var(CrossroadsTrigger) bool bCanTurnRightFromInternalSide;

/** ���� ���� �������(true), � ������ ����� ����������� ��������� ������ (��������� ������ � ���������� ������ ������) */
var(CrossroadsTrigger) bool bCanTurnLeftFromInternalSide;

/** ���� ���� �������(true), � ������ ����� ����������� ��������� ������ (��������� ������ � ������� ������ ������) */
var(CrossroadsTrigger) bool bCanTurnLeft;

/** ���� ���� �������(true), � ������ ����� ����������� ��������� ������� (��������� ������ � ������� ������ ������) */
var(CrossroadsTrigger) bool bCanTurnRight;

/** ���� ���� �������(true), � ������ ����� ����������� �������� ������ */
var(CrossroadsTrigger) bool bCanDriveForward;

/** ���� ���� �������(true), � ������ ����� ����������� ������������ ������ (��������� ������ � ������� ������ ������) */
var(CrossroadsTrigger) bool bCanTurnReverse;

/** ���� ���� �������(true), � ������ ����� ����������� ������������ ������ (��������� ������ � ���������� ������ ������) */
var(CrossroadsTrigger) bool bCanTurnReverseFromInternalSide;

/** ���� ���� ���� �������, ��� ����� ����� ���������������� ������ �������������� ������� */
var(CrossroadsTrigger) bool bControlByRightSection;

/** ���� ���� ���� �������, ��� ����� ����� ���������������� ����� �������������� ������� */
var(CrossroadsTrigger) bool bControlByLeftSection;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	// ��������� ���� ��������
	self.SetColor(RedColor);
}

event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	// ���� �������� �������� ��� �����������, ������ �� ������
	if(Other.Class == class'Gorod_CrossRoad')
		return;

	// �������� � ������� �����������-��������
	if (ParentCrossroad != none)	
		ParentCrossroad.OnTriggerTouch(self, Other);
}


event UnTouch( Actor Other )
{
	ParentCrossroad.OnTriggerUnTouch(self, Other);
}

function TriggerReference FindTriggerReference(Gorod_CrossRoadsTrigger trg)
{
	local TriggerReference tempTrgRef;

	foreach CorrectTriggers(tempTrgRef)
	{
		if(tempTrgRef.triggerRef.Name == trg.Name)
		{
			return tempTrgRef;
		}
	}

	foreach IncorrectTriggers(tempTrgRef)
	{
		if(tempTrgRef.triggerRef.Name == trg.Name)
		{
			return tempTrgRef;
		}
	}

	// ������ � �������� �� �������, �������� ��������������� ���������
	tempTrgRef.triggerRef = none;
	tempTrgRef.Message = "[WARNING] Trigger " $ trg.Name $ " not registered in entry trigger";
	return tempTrgRef;
}

defaultproperties
{
	bCanTurnRightFromInternalSide = false
	bCanTurnLeftFromInternalSide = false
	bCanTurnLeft = true
	bCanTurnRight = true
	bCanDriveForward = true
	bCanTurnReverse = true
	bCanTurnReverseFromInternalSide = false
	bControlByLeftSection = false
	bControlByRightSection = false

	trType = TRIGGERTYPE_ENTRY
}