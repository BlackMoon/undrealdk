interface Gorod_EventListener;

/**  должен вернуть true, если это сообщение не следует обрабатывать другими listener- ми*/ 
function HandleEvent(Gorod_Event evt);