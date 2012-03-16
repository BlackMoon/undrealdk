class Gorod_GameGeneralMessages extends Gorod_BaseMessages;

function fillMessages()
{
	local MessageInfo msgi;
	
	msgi.ID = 2;
	msgi.Title = "Задание";
	msgi.Text = "Вам необходимо проехать на место тушения пожара. Зеленые стрелки на перекрестках будут подсказывать направление движения.";
	msgi.type = MESSAGE_WARNING;
	Messages.AddItem(msgi);
}

DefaultProperties
{
	MinMsgID = 0;
	MaxMsgID = 999;
}