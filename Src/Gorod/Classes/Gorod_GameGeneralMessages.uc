class Gorod_GameGeneralMessages extends Gorod_BaseMessages;

function fillMessages()
{
	local MessageInfo msgi;
	
	msgi.ID = 2;
	msgi.Title = "�������";
	msgi.Text = "��� ���������� �������� �� ����� ������� ������. ������� ������� �� ������������ ����� ������������ ����������� ��������.";
	msgi.type = MESSAGE_WARNING;
	Messages.AddItem(msgi);
}

DefaultProperties
{
	MinMsgID = 0;
	MaxMsgID = 999;
}