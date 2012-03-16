/** Класс, который регистрирует другие классы, которые могут выдавать сообщения */
class Gorod_MessagesManager extends Object implements (Gorod_EventListener);

/** все классы*/
var array <Gorod_BaseMessages> BaseMessages;

/** фнкция регистрирования */
function Register(Gorod_BaseMessages bMsgs)
{
	if(BaseMessages.Find(bMsgs)==INDEX_NONE)
		BaseMessages.AddItem(bMsgs);
}

/** функция разрегистрирования  */
function UnRegister(Gorod_BaseMessages bMsgs)
{
	if(BaseMessages.Find(bMsgs)!=INDEX_NONE)
		BaseMessages.AddItem(bMsgs);
}

/** Найти сообщение с заданном ID и вернуть контент */
function MessageInfo getMessageContent(int msgID)
{
	local Gorod_BaseMessages BaseMgs;
	local MessageInfo msgInf;
	foreach BaseMessages(BaseMgs)
	{
		if(BaseMgs.MaxMsgID>=msgID && BaseMgs.MinMsgID <= msgID)
		{
			msgInf =  BaseMgs.GetMsg(msgID);

		}
	}
	return msgInf;
}

/** */ 
function HandleEvent(Gorod_Event evt)
{
	if (evt.eventType == GOROD_EVENT_REGISTER_MESSAGES)
	{
		if (Gorod_BaseMessages(evt.sender) != none)
			Register (Gorod_BaseMessages (evt.sender));
	}

}

DefaultProperties
{
}
