class Gorod_StartMovingMessages extends Gorod_BaseMessages;
`include(Gorod_Events.uci);

function fillMessages()
{
	local MessageInfo msgi;
	
	msgi.ID = GOROD_STARTMOVING_BELT;
	msgi.Title = "������ ��������";
	msgi.Text = "����������� ������";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_STARTMOVING_CLUTCH_DOWN;
	msgi.Title = "������ ��������";
	msgi.Text = "������� ������ ���������";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_STARTMOVING_IGNITION;
	msgi.Title = "������ ��������";
	msgi.Text = "��������� ���������";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_STARTMOVING_FIRST_GEAR;
	msgi.Title = "������ ��������";
	msgi.Text = "�������� ������ ��������";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_STARTMOVING_LEFT_TURN_SIGNAL;
	msgi.Title = "������ ��������";
	msgi.Text = "�������� ����� ��������� ��������";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);
	
	msgi.ID = GOROD_STARTMOVING_RIGHT_TURN_SIGNAL;
	msgi.Title = "������ ��������";
	msgi.Text = "�������� ������ ��������� ��������";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_STARTMOVING_HAND_BRAKE;
	msgi.Title = "������ ��������";
	msgi.Text = "������� ������ �� ����������� �������";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_STARTMOVING_THROTTLE;
	msgi.Title = "������ ��������";
	msgi.Text = "������� ������ ����";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_STARTMOVING_CLUTCH_UP;
	msgi.Title = "������ ��������";
	msgi.Text = "��������� ������ ���������";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_STARTMOVING_TURN_ON_MASS;
	msgi.Title = "������ ��������";
	msgi.Text = "�������������� ������� �� ������ ����������� �����, �������� �������������� �������";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);
}

DefaultProperties
{
	MinMsgID = 4000;
	MaxMsgID = 4099;
}