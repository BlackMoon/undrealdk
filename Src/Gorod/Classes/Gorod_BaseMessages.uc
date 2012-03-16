/** ������� ����� ���������� � ��������� */
class Gorod_BaseMessages extends Object config(Gorod_UIText);

/** ������������ �������� ID */
var int MinMsgID;
/** ����������� �������� ID */
var int MaxMsgID;
/** ��������� �� ���������� �� ������� ini-���� */
var bool bNeedToSave;
/** ��� ��������� */
enum messageType
{
	/** ������ */
	MESSAGE_NONE,
	/** ��������� */
	MESSAGE_TIP,
	/** �������������� */
	MESSAGE_WARNING,
	/** ������ */
	MESSAGE_ERROR,
	/** ���������� */
	MESSAGE_INFORM
};
/** ��������� ��������� */
struct MessageInfo
{
	/** ID ��������� */
	var int ID;
	/** ��� ��������� */
	var messageType type;
	/** ��������� ��������� */
	var string Title;
	/** ����� ��������� */
	var string Text;
	/** ���������� ������ �� ��������� */
	var int Points;
	/** �������� ����� */
	var int MoneyPenalty;
	/** ���� */
	var SoundCue Cue;
	/** ����� ������ ��������� � ������������� */
	var int ShowTime;
	structDefaultProperties
	{
		Points = 0
		MoneyPenalty = 0
		Cue = none
		ShowTime = 0
	}
};
var config array<MessageInfo> Messages;
/** ���������� ���������� � ��������� �� ��� ID */
function MessageInfo GetMsg(int i)
{
	local MessageInfo msgi;
	local bool found;
	found = false;
	foreach Messages(msgi)
	{
		if (msgi.ID == i) {
			found = true;
			break;
		}
	}
	return found ? msgi : CreateMessage(i, "������ ����������", "��������� �"@i@" �� ������� � �����������", 0, 0, MESSAGE_ERROR, none);	
}
/** �������� �� ������� ��������� � ini-����� */
function checkConfig()
{
	if (Messages.Length == 0) {		
		fillMessages();
		bNeedToSave = true;
	}
}
function save()
{
	if (bNeedToSave) saveConfig();
}
/** ��������� ������ ��������� (virtual) */
function fillMessages();

function MessageInfo CreateMessage(	int ID,	string Title, string Text, optional	int Points = 0,	optional int MoneyPenalty = 0, optional messageType type = MESSAGE_NONE, optional SoundCue Cue = none)
{
		local MessageInfo MsgInfo;
		MsgInfo.ID = ID;
		MsgInfo.Title = Title;
		MsgInfo.Text = Text;
		MsgInfo.Points = Points;
		MsgInfo.MoneyPenalty = MoneyPenalty;
		MsgInfo.type = type;
		MsgInfo.Cue = Cue;
		return MsgInfo;
}
DefaultProperties
{
	MinMsgID = 0;
	MaxMsgID = 0;
	bNeedToSave = false;
}
