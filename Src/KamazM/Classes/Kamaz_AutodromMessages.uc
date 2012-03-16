class Kamaz_AutodromMessages extends Gorod_BaseMessages;
`include(Gorod/Gorod_Events.uci);

function fillMessages()
{
	local MessageInfo msgi; 

	msgi.ID = 1000;
	msgi.Title = "��������";
	msgi.Text = "�� ������� �� ��������. ����������� � ������� ����������";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = 1001;
	msgi.Title = "��������";
	msgi.Text = "�� ������� � ���������";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = 1002;
	msgi.Title = "��������";
	msgi.Text = "�� ������ ���������� ��������� � ������ �������� �� �������";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = 1003;
	msgi.Title = "��������";
	msgi.Text = "�� ��������� ���������� ��������� � ������ �������� �� �������. ����������� � ���������� ����������";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = 1004;
	msgi.Title = "��������";
	msgi.Text = "�� ������ ���������� �������� � ��������";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = 1005;
	msgi.Title = "��������";
	msgi.Text = "�� ��������� ���������� �������� � ��������. ����������� � ���������� ����������";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = 1006;
	msgi.Title = "��������";
	msgi.Text = "�� ������ ���������� ������������ �������� ������ �����";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = 1007;
	msgi.Title = "��������";
	msgi.Text = "�� ��������� ���������� ������������ �������� ������ �����. ����������� � ���������� ����������";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = 1008;
	msgi.Title = "��������";
	msgi.Text = "�� ������� �� ������� �������� �����";
	msgi.type = MESSAGE_ERROR;
	Messages.AddItem(msgi);

	msgi.ID = 1009;
	msgi.Title = "��������";
	msgi.Text = "�� �� ���������� ������� �������� �� ���������";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);	

	msgi.ID = 1011;
	msgi.Title = "��������";
	msgi.Text = "�� ��������� ����������� �������� �� ���������";
	msgi.type = MESSAGE_ERROR;
	Messages.AddItem(msgi);

	msgi.ID = 1012;
	msgi.Title = "����������";
	msgi.Text = "�� ��������� ����� �������� ���������� ���������� ��� ����� ����";
	msgi.type = MESSAGE_ERROR;
	Messages.AddItem(msgi);

	msgi.ID = 1013;
	msgi.Title = "����������";
	msgi.Text = "�� ������ �������� �����, ��� ����� 3 � ����� ���������";
	msgi.type = MESSAGE_ERROR;
	msgi.Points = 25;
	Messages.AddItem(msgi);

	msgi.ID = 1014;
	msgi.Title = "����������";
	msgi.Text = "�� �� ������ �������� � ������� 30 � ����� ���������";
	msgi.type = MESSAGE_ERROR;
	msgi.Points = 25;
	Messages.AddItem(msgi);

	msgi.ID = 1015;
	msgi.Title = "����������";
	msgi.Text = "�� ��������� ����� �� �� �������� ����� ��� 0,3 � ��� ��������� ��� ������ ��������";
	msgi.type = MESSAGE_ERROR;
	msgi.Points = 10;
	Messages.AddItem(msgi);

	msgi.ID = 1016;
	msgi.Title = "����������";
	msgi.Text = "�� �� ��������� ������� ������� �� ����� �������� ���������� ����������";
	msgi.type = MESSAGE_ERROR;
	msgi.Points = 5;
	Messages.AddItem(msgi);

	msgi.ID = 1017;
	msgi.Title = "����������";
	msgi.Text = "�� ��������� ����������� �����";
	msgi.type = MESSAGE_ERROR;
	msgi.Points = 5;
	Messages.AddItem(msgi);

	msgi.ID = 1018;
	msgi.Title = "����������";
	msgi.Text = "�� ��������� ����� 2 ����� �� ���������� ����������";
	msgi.type = MESSAGE_ERROR;
	msgi.Points = 5;
	Messages.AddItem(msgi);

	msgi.ID = 1019;
	msgi.Title = "����������";
	msgi.Text = "�� �� ��������� ������� ������� ����� �������� ���������� ����������";
	msgi.type = MESSAGE_ERROR;
	msgi.Points = 10;
	Messages.AddItem(msgi);

	msgi.ID = 1020;
	msgi.Title = "����������";
	msgi.Text = "�� ��������� ����������� �����";
	msgi.type = MESSAGE_ERROR;
	msgi.Points = 5;
	Messages.AddItem(msgi);

	msgi.ID = 1021;
	msgi.Title = "����������";
	msgi.Text = "�� ��������� ����� 2 ����� �� ���������� ����������";
	msgi.type = MESSAGE_ERROR;
	msgi.Points = 5;
	Messages.AddItem(msgi);

	msgi.ID = 1022;
	msgi.Title = "����������";
	msgi.Text = "�� �� ��������� �������� �� ���������� � ������� 5 �����. ���������� ����������. ����������� � ���������� ����������";
	msgi.type = MESSAGE_ERROR;
	msgi.Points = 0;
	Messages.AddItem(msgi);

	msgi.ID = 1023;
	msgi.Title = "��������";
	msgi.Text = "�� ������� ����������� �� ��������. ���������� ������� �� ��������� ����������.";
	msgi.type = MESSAGE_ERROR;
	Messages.AddItem(msgi);

	msgi.ID = 1024;
	msgi.Title = "����������";
	msgi.Text = "�� �������� ������� �������� ��� ���������� ����������. ���������� ����������. ����������� � ���������� ����������";
	msgi.type = MESSAGE_ERROR;
	Messages.AddItem(msgi);

	msgi.ID = 1025;
	msgi.Title = "����������";
	msgi.Text = "�� ������� ������ �������� �� ���� ���������� ����������";
	msgi.type = MESSAGE_ERROR;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_EVENT_OFF_ROAD;
	msgi.Title = "��������";
	msgi.Text = "�� ������� � �������� �����. ���������� ���������� ����� ����������.";
	msgi.type = MESSAGE_ERROR;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_EVENT_GO_TO_ASCENT;
	msgi.Title = "����������";
	msgi.Text = "���������� �� �� ������� ������� ����� ������ �������� ���������� ���������� � ������ ����";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_EVENT_STOP;
	msgi.Title = "����������";
	msgi.Text = "������������ �� � ����������� ��������� � ������� ������� �������, �������� ����������� ��������";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_EVENT_GO;
	msgi.Title = "����������";
	msgi.Text = "���������� �������� � ������ �����������, �� �������� ������ �� �����.(����� ��� ���������� 3 - 30���)";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_EVENT_MOVE_FORWARDS;
	msgi.Title = "����������";
	msgi.Text = "���������� �����. ������������ ����� ������";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_EVENT_PARK_BACK;
	msgi.Title = "����������";
	msgi.Text = "���������� �� �� ����� �������� ������ ����� ���, ����� ������ ����� ���������� �� ����� �������� ���������� ����������";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_EVENT_DRIVE_OUT_BACK;
	msgi.Title = "����������";
	msgi.Text = "��������� � �������� ����������.";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_EVENT_PARK_RIGHT;
	msgi.Title = "����������";
	msgi.Text = "���������� �� �� ����� �������� ������ ����� ���, ����� �������� � ������ ������ ����� ���������� �� ����� �������� ���������� ����������";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_EVENT_DRIVE_OUT_FROM_PARKING;
	msgi.Title = "����������";
	msgi.Text = "��������� � ����� ��������.";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_EVENT_DRIVE_LEFT;
	msgi.Title = "��������";
	msgi.Text = "��������� ������";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_EVENT_DRIVE_RIGHT;
	msgi.Title = "��������";
	msgi.Text = "��������� �������";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_EVENT_DRIVE_FORWARD;
	msgi.Title = "��������";
	msgi.Text = "���������� �����";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);
}

DefaultProperties
{
	MinMsgID = 1000;
	MaxMsgID = 1999;
}