class Gorod_CrashMessages extends Gorod_BaseMessages;
`include(Gorod_Events.uci);

function fillMessages()
{
	local MessageInfo msgi;
	
	msgi.ID = GOROD_CRASH_PLAYER;
	msgi.Title = "������";
	msgi.Text = "�� ����������� � ������ �������";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_CRASH_VEHICLE;
	msgi.Title = "������";
	msgi.Text = "�� ����������� � ������ �������";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_CRASH_OTHER;
	msgi.Title = "������";
	msgi.Text = "�� ����������� � ����� ��������";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_CRASH_COMMON;
	msgi.Title = "������";
	msgi.Text = "�� ������ � ������";
	msgi.type = MESSAGE_INFORM;
	msgi.Points = 25;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_CRASH_TEMP_MISSION_COMPLITE;
	msgi.Title = "�������";
	msgi.Text = "�� ������� ��������� �������";
	msgi.type = MESSAGE_INFORM;
	msgi.Points = 0;
	Messages.AddItem(msgi);
}

DefaultProperties
{
	MinMsgID = 4100;
	MaxMsgID = 4199;
}
