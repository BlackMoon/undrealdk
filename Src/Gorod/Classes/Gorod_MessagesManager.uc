/** �����, ������� ������������ ������ ������, ������� ����� �������� ��������� */
class Gorod_MessagesManager extends Object implements (Gorod_EventListener);

/** ��� ������*/
var array <Gorod_BaseMessages> BaseMessages;

/** ������ ��������������� */
function Register(Gorod_BaseMessages bMsgs)
{
	if(BaseMessages.Find(bMsgs)==INDEX_NONE)
		BaseMessages.AddItem(bMsgs);
}

/** ������� ������������������  */
function UnRegister(Gorod_BaseMessages bMsgs)
{
	if(BaseMessages.Find(bMsgs)!=INDEX_NONE)
		BaseMessages.AddItem(bMsgs);
}

/** ����� ��������� � �������� ID � ������� ������� */
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
