interface ICommonSignals;

/** Инициализация */
function bool Initialize();

/** Функция обновляет состояние устройств управления */
function bool Update();

/** Поворот руля */
function float GetSteering(bool normalized = true);

 /** Педаль газа */
function float GetGasPedal(bool normalized = true);

/** Педаль сцепления */
function float GetClutchPedal(bool normalized = true);

/** Педаль тормоза */
function float GetBrakePedal(bool normalized = true);

/** Стояночный тормоз */
function bool GetHandBrake();

/** Левый повототник */
function bool GetLeftTurn();

/** Правый повототник */
function bool GetRightTurn();

/** Смена вида */
function bool GetViewChange();

/** Габаритные огни */
function bool GetDimensionalFires();

/** Ближный свет */
function bool GetPassingLight();

/** Дальний свет */
function bool GetHeadLight();

/** Стеклоочиститель */
function bool GetScreenWiper();

/** Взгляд влево */
function bool GetLookAtLeft();

/** Взгляд вправо */
function bool GetLookAtRight();

/** Зажигание */
function bool GetIgnition();

/** Стартер */
function bool GetStarter();

/** Аварийная сигнализация */
function bool GetAlarmSignal();

/** 1-я передача */
function bool GetFirstStep();

/** 2-я передача */
function bool GetSecondStep();

/** 3-я передача */
function bool GetThirdStep();

/** 4-я передача */
function bool GetFourthStep();

/** 5-я передача */
function bool GetFifthStep();

/** Задняя передача */
function bool GetBackStep();

/** Нейтралка */
function bool GetNeutral();

/** Пристегивание ремня */
function bool GetBeltOn();

DefaultProperties
{
}
