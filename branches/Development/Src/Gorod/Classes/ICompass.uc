interface ICompass;

/** ������������ ��������, ��������������� ������ � ������� */
function float GetDegreeHeading();
/** ��������� ������������� ��������� ������� */
function float GetRadianHeading();

/** ��������� Yaw ������ �������� �������� */
function int GetYaw();
/** ��������� �������� �������� ������� */
function Rotator GetRotator();
/** ��������� �������, ��������������� � ������. */
function vector GetVectorizedRotator();
