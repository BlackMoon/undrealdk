class Gorod_CrashMessages extends Gorod_BaseMessages;
`include(Gorod_Events.uci);

function fillMessages()
{
	local MessageInfo msgi;
	
	msgi.ID = GOROD_CRASH_PLAYER;
	msgi.Title = "Авария";
	msgi.Text = "Вы столкнулись с другим игроком";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_CRASH_VEHICLE;
	msgi.Title = "Авария";
	msgi.Text = "Вы столкнулись с другой машиной";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_CRASH_OTHER;
	msgi.Title = "Авария";
	msgi.Text = "Вы столкнулись с другм объектом";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_CRASH_COMMON;
	msgi.Title = "Авария";
	msgi.Text = "Вы попали в аварию";
	msgi.type = MESSAGE_INFORM;
	msgi.Points = 25;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_CRASH_TEMP_MISSION_COMPLITE;
	msgi.Title = "Задание";
	msgi.Text = "Вы успешно выполнили задание";
	msgi.type = MESSAGE_INFORM;
	msgi.Points = 0;
	Messages.AddItem(msgi);
}

DefaultProperties
{
	MinMsgID = 4100;
	MaxMsgID = 4199;
}
