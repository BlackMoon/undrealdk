class Gorod_ReportEvent extends Gorod_Event
	dependson(Gorod_BaseMessages);

var array<MessageInfo> MsgInfos;
var bool bSuccess;
	
/** ���������� ������ �� ��������� ������ */
var int pointsCount;
/** ���������� ������� �� ��������� ������ */
var int moneyPenaltyCount;
/** ���������� ���������� ���������� */
var int exerciseCount;
var bool bShowExcerisesCount; // show/hide excersise count line in report

DefaultProperties
{
}
