/** мувер для окна */
class Forsage_Wnd extends Object config(ForsageWnd);

// положение окна-зеркала на экране 
var config struct RECT
{
	var int x, y, cx, cy;
} rcBackMirror, rcLeftMirror, rcRightMirror;

var private SMUtils sm_Utils;
/** требуется инициализация внешней библиотеки */
function init()
{
	sm_Utils = new class'SMUtils';
}

function moveWindow(eViewMode em)
{
	local RECT rc;
	switch (em)
	{
		case VM_LeftMirror:
			rc = rcLeftMirror;
			break;
		case VM_RightMirror:
			rc = rcRightMirror;
			break;
		default:
			rc = rcBackMirror;
			break;
	}
	sm_Utils.WindowPos(rc.x, rc.y, rc.cx, rc.cy);
}

DefaultProperties
{
}
