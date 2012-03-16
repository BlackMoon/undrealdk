class Gorod_EventDispatcher extends Actor dependson(Gorod_Event);

struct ListenersData
{
	var Gorod_EventType eType;
	var array<Gorod_EventListener> Listeners;
};

var private array<ListenersData> ListenersMap;

function SendEvent(Gorod_Event evt)
{
	local Gorod_EventListener lstr;
	local ListenersData lstrData;

	evt.fireTime = WorldInfo.TimeSeconds;

	foreach ListenersMap(lstrData)
	{
		if(lstrData.eType == evt.eventType)
		{
			foreach lstrData.Listeners(lstr)
			{
				lstr.HandleEvent(evt);
			}
			break;
		}
	}
}

function RegisterListener(Gorod_EventListener lstr, Gorod_EventType etype)
{
	local ListenersData lData, newListData;
	local bool found;
	local int i;
	i = 0;
	foreach ListenersMap(lData,i)
	{
		if(lData.eType == etype)
		{
			found = true;
			ListenersMap[i].Listeners.AddItem(lstr);
			break;
		}
	}

	if(!found)
	{
		newListData.eType = etype;
		newListData.Listeners.AddItem(lstr);
		ListenersMap.AddItem(newListData);
	}
}

function RemoveListener(Gorod_EventListener lstr)
{
	local ListenersData lData;
	local int i;
	foreach ListenersMap(lData,i)
	{
		if(ListenersMap[i].Listeners.Find(lstr) != INDEX_NONE)
			ListenersMap[i].Listeners.RemoveItem(lstr);
	}
}

DefaultProperties
{
}
