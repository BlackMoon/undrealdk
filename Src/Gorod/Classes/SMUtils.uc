/** Библиотека внешних системных функций */
class SMUtils extends Object DLLBind(smutils);	

/** возвращает количество мониторов в системе */
dllimport final function int MonitorsNum();
/** функция для перемещения окна UDK */
dllimport final function WindowPos(int x, int y, int cx, int cy);

DefaultProperties
{
}
