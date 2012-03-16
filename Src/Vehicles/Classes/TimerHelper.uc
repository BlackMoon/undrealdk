/** Вспомогательный actor, служащий для вызова функции обновления приборов в каждом тике */
class TimerHelper extends Actor;

var bool bRunning;
delegate dlgTimerFunc();

function DoFunc(bool value)
{
	bRunning = value;		
}

simulated event Tick(float DeltaTime)
{
	if (bRunning)  
		dlgTimerFunc();	
}

DefaultProperties
{	
}
