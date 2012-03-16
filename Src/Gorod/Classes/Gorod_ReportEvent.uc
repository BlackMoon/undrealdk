class Gorod_ReportEvent extends Gorod_Event
	dependson(Gorod_BaseMessages);

var array<MessageInfo> MsgInfos;
var bool bSuccess;
	
/** Количество баллов за нарушение вцелом */
var int pointsCount;
/** Количество штрафов за нарушение вцелом */
var int moneyPenaltyCount;
/** Количество пройденных упражнений */
var int exerciseCount;
var bool bShowExcerisesCount; // show/hide excersise count line in report

DefaultProperties
{
}
