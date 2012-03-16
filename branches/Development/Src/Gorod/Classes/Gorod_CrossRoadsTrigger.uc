class Gorod_CrossRoadsTrigger extends Gorod_Trigger placeable;

/** Тип триггера */
enum TriggerType
{
	TRIGGERTYPE_ENTRY,                  // тип триггера, характеризующий правильный вьезд на перекресток
	TRIGGERTYPE_INVALIDENTRY,           // тип триггера, характеризующий неправильный вьезд на перекресток (например с обочины)
	TRIGGERTYPE_EXIT                    // тип триггера "Выезд из перекрестка"
};

struct TriggerReference
{
	var() Gorod_CrossRoadsTrigger triggerRef;                           // ссылка на триггер
	var() string Message;                                               // сообщение
	var() int MessageID;                                                // номер сообщения
	var() bool bShowMessageInHUD;                                          

	structdefaultproperties
	{
		MessageID = -1
		bShowMessageInHUD = false
	}
};

var(CrossroadsTrigger) TriggerType trType;                              // тип триггера

var Gorod_CrossRoad ParentCrossroad;                                   // ссылка на владеющий данным триггером перекресток
var(CrossroadsTrigger) array<TriggerReference> CorrectTriggers;        // массив триггеров, по которым разрешен проезд из данного триггера
var(CrossroadsTrigger) array<TriggerReference> IncorrectTriggers;      // массив триггеров, по которым запрещен проезд из данного триггера

/** состояние триггера (true - заблокирован) */
var bool IsBlocked;

/** Если флаг активен(true), с данной точки разрешается повернуть направо (относится только к внутренним точкам вьезда) */
var(CrossroadsTrigger) bool bCanTurnRightFromInternalSide;

/** Если флаг активен(true), с данной точки разрешается повернуть налево (относится только к внутренним точкам вьезда) */
var(CrossroadsTrigger) bool bCanTurnLeftFromInternalSide;

/** Если флаг активен(true), с данной точки разрешается повернуть налево (относится только к крайним точкам вьезда) */
var(CrossroadsTrigger) bool bCanTurnLeft;

/** Если флаг активен(true), с данной точки разрешается повернуть направо (относится только к крайним точкам вьезда) */
var(CrossroadsTrigger) bool bCanTurnRight;

/** Если флаг активен(true), с данной точки разрешается проехать вперед */
var(CrossroadsTrigger) bool bCanDriveForward;

/** Если флаг активен(true), с данной точки разрешается развернуться налево (относится только к крайним точкам вьезда) */
var(CrossroadsTrigger) bool bCanTurnReverse;

/** Если флаг активен(true), с данной точки разрешается развернуться налево (относится только к внутренним точкам вьезда) */
var(CrossroadsTrigger) bool bCanTurnReverseFromInternalSide;

/** Если этот флаг активен, эта точка будет контролироваться правой дополнительной секцией */
var(CrossroadsTrigger) bool bControlByRightSection;

/** Если этот флаг активен, эта точка будет контролироваться левой дополнительной секцией */
var(CrossroadsTrigger) bool bControlByLeftSection;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	// начальный цвет триггера
	self.SetColor(RedColor);
}

event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	// если триггера касается сам перекресток, ничего не делаем
	if(Other.Class == class'Gorod_CrossRoad')
		return;

	// сообщаем о касании перекрестку-родителю
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

	// запись о триггере не найдена, посылаем соответствующее сообщение
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