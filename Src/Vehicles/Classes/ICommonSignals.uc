interface ICommonSignals;

/** ������������� */
function bool Initialize();

/** ������� ��������� ��������� ��������� ���������� */
function bool Update();

/** ������� ���� */
function float GetSteering(bool normalized = true);

 /** ������ ���� */
function float GetGasPedal(bool normalized = true);

/** ������ ��������� */
function float GetClutchPedal(bool normalized = true);

/** ������ ������� */
function float GetBrakePedal(bool normalized = true);

/** ���������� ������ */
function bool GetHandBrake();

/** ����� ���������� */
function bool GetLeftTurn();

/** ������ ���������� */
function bool GetRightTurn();

/** ����� ���� */
function bool GetViewChange();

/** ���������� ���� */
function bool GetDimensionalFires();

/** ������� ���� */
function bool GetPassingLight();

/** ������� ���� */
function bool GetHeadLight();

/** ���������������� */
function bool GetScreenWiper();

/** ������ ����� */
function bool GetLookAtLeft();

/** ������ ������ */
function bool GetLookAtRight();

/** ��������� */
function bool GetIgnition();

/** ������� */
function bool GetStarter();

/** ��������� ������������ */
function bool GetAlarmSignal();

/** 1-� �������� */
function bool GetFirstStep();

/** 2-� �������� */
function bool GetSecondStep();

/** 3-� �������� */
function bool GetThirdStep();

/** 4-� �������� */
function bool GetFourthStep();

/** 5-� �������� */
function bool GetFifthStep();

/** ������ �������� */
function bool GetBackStep();

/** ��������� */
function bool GetNeutral();

/** ������������� ����� */
function bool GetBeltOn();

DefaultProperties
{
}
