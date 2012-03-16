class Gorod_MDataManager extends Actor;

struct EventInfo
{
	var int Type;
	var int EventId;
};

var array<EventInfo> EventInfos;

var array<delegate<Gorod_EventReceived> > Gorod_EventDelegates;

delegate Gorod_EventReceived(int Type, int EventId);

function SendEventData(int Type, int EventId)
{
	local EventInfo EvInfo;

	EvInfo.Type = Type;
	EvInfo.EventId = EventId;

	EventInfos.AddItem(EvInfo);

	Gorod_EventReceived(Type, EventId);
}

function AddEventListener(delegate<Gorod_EventReceived> EventReceived)
{
	Gorod_EventDelegates.AddItem(EventReceived);
}

function ClearEventListener(delegate<Gorod_EventReceived> EventReceived)
{
	local int RemoveIndex;

	RemoveIndex = Gorod_EventDelegates.Find(EventReceived);
	if(RemoveIndex != INDEX_NONE)
	{
		Gorod_EventDelegates.Remove(RemoveIndex, 1);
	}
}

DefaultProperties
{
}
