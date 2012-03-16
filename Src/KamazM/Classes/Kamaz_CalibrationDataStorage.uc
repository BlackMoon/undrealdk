/** ����� ��� �������� ���������� � ����������
 *  */

class Kamaz_CalibrationDataStorage extends Object;

/** ������, ��� �������� �������� ���������� � ���������� */
var Zarnitza_KamazSignals KamazSignalsObj;



/** ��� ����������� �������
 * ���������� ����� ����������  
*/
function AddCalibrationPoint(int DeviceId, float ResVal, float FrontVal)
{
	`log("ACP: " @ DeviceId @ ResVal @ FrontVal );

	// ���������� ����������
	switch(DeviceID)
	{
	case 0: // speedometer
		break;

	case 1: // tahometer
		break;

	case 2: // oil pressure (oil)
		break;

	case 3: // engine temperature (water)
		break;

	case 4: // accumulator charge (accum)
		break;

	case 5: // fuel (bensin)
		break;

	case 6: // engine pressure (pressure)
		break;

	default:
		`warn("Unknown ArrowDevice");
	}
}


/** ��� ����������� �������
 *  ����� ����������� �������� ��� ���������� ���������� */
function Reset(int DeviceID)
{
	`log("Reset: " @ DeviceID);

	// ���������� ����������
	switch(DeviceID)
	{
	case 0: // speedometer
		break;

	case 1: // tahometer
		break;

	case 2: // oil pressure (oil)
		break;

	case 3: // engine temperature (water)
		break;

	case 4: // accumulator charge (accum)
		break;

	case 5: // fuel (bensin)
		break;

	case 6: // engine pressure (pressure)
		break;

	default:
		`warn("Unknown ArrowDevice");
	}
}

/** ��� ����������� �������
 *  ���������� ���������� ���������� ���������� 
 *  DeviceID    id ����������
 *  MinFront    ����������� �������� �� ������ ����������� �������
 *  MaxFront    ������������ �������� �� ������ ����������� �������
 *  MaxResVal   ������������ �������� ����������� ��������� ����������� �������
 *  */
function Update(int DeviceID, float MinFront, float MaxFront, float MaxResVal)
{
	`log("Update: DevID: " @ DeviceID @ " MinFront: " @ MinFront @ " MaxFront: " @ MaxFront @ " MaxResVal: " @ MaxResVal);

	// ���������� ����������
	switch(DeviceID)
	{
	case 0: // speedometer
		break;

	case 1: // tahometer
		break;

	case 2: // oil pressure (oil)
		break;

	case 3: // engine temperature (water)
		break;

	case 4: // accumulator charge (accum)
		break;

	case 5: // fuel (bensin)
		break;

	case 6: // engine pressure (pressure)
		break;

	default:
		`warn("Unknown ArrowDevice");
	}
}


/** ��� ����������� �������
 * ���������� �������� � ini ���� 
*/
function Save()
{
	`log("Save");
}

DefaultProperties
{
}
