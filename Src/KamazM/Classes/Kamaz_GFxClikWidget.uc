class Kamaz_GFxClikWidget extends GFxClikWidget;


//var array<EventListener>  EventListeners;
var delegate<EventListener> lstr;

function Press()
{
	local EventData ev;
	//если кнопка не задейсаблена и видна, вызываем ее обработчик 
	if(!getBool("disabled") && getBool("visible"))
	{
		if(GetBool("selected"))
			SetBool("selected",false);
		else
			SetBool("selected",true);

		lstr(ev);
	}
}

function AddEventListener(name type, delegate<EventListener> listener, bool useCapture=false, int listenerPriority=0, bool useWeakReference=false)
{
	super.AddEventListener( type, listener);
	lstr = listener;
}

DefaultProperties
{
}
