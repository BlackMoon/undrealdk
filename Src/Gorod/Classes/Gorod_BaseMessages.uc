/** Базовый класс информации о сообщении */
class Gorod_BaseMessages extends Object config(Gorod_UIText);

/** Максимальный выданный ID */
var int MinMsgID;
/** Минимальный выданный ID */
var int MaxMsgID;
/** Требуется ли сохранение во внешний ini-файл */
var bool bNeedToSave;
/** тип сообщения */
enum messageType
{
	/** незнай */
	MESSAGE_NONE,
	/** Подсказка */
	MESSAGE_TIP,
	/** Предупреждение */
	MESSAGE_WARNING,
	/** Ошибка */
	MESSAGE_ERROR,
	/** Информация */
	MESSAGE_INFORM
};
/** Структура сообщения */
struct MessageInfo
{
	/** ID сообщения */
	var int ID;
	/** тип сообщения */
	var messageType type;
	/** заголовок сообщения */
	var string Title;
	/** текст сообщения */
	var string Text;
	/** количество баллов за нарушение */
	var int Points;
	/** денежный штраф */
	var int MoneyPenalty;
	/** звук */
	var SoundCue Cue;
	/** Время показа сообщения в миллисекундах */
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
/** Возвращает информацию о сообщении по его ID */
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
	return found ? msgi : CreateMessage(i, "Ошибка приложения", "Сообщение №"@i@" не найдено в справочнике", 0, 0, MESSAGE_ERROR, none);	
}
/** Проверка на наличие сообщений в ini-файле */
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
/** Заполняет массив сообщений (virtual) */
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
