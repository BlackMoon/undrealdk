/** ������� ����� ��� ���� ����� � ������� ����� - ������, ������� ����� ������ � �� ��������� �� PenetrationDestroy */
class VehicleBase extends UDKVehicle abstract;

/** ����� ������ */
var float VEHICLE_LENGTH;

/** ������ ������ */
var float VEHICLE_WIDTH;

// ���������� ��� ��������������� ������� ������ �����, ����� �� ����� ����� � �����
// #ToDo: ������� ����� �������� ������� ��������.
event RBPenetrationDestroy();

function SetVehicleLength(float val)
{
	VEHICLE_LENGTH = val;
}

function SetVehicleWidth(float val)
{
	VEHICLE_WIDTH = val;
}

DefaultProperties
{
}
