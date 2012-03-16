/** Класс для хранения информации о калибровке
 *  */

class Kamaz_CalibrationDataStorage extends Object;

/** Объект, для которого хранится информация о калибровке */
var Zarnitza_KamazSignals KamazSignalsObj;



/** ДЛЯ СТРЕЛОЧНОГО ПРИБОРА
 * Добавление точки калибровки  
*/
function AddCalibrationPoint(int DeviceId, float ResVal, float FrontVal)
{
	`log("ACP: " @ DeviceId @ ResVal @ FrontVal );

	// определяем устройство
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


/** ДЛЯ СТРЕЛОЧНОГО ПРИБОРА
 *  Сброс сохраненных настроек для указанного устройства */
function Reset(int DeviceID)
{
	`log("Reset: " @ DeviceID);

	// определяем устройство
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

/** ДЛЯ СТРЕЛОЧНОГО ПРИБОРА
 *  Обновление параметров калибровки устройства 
 *  DeviceID    id устройства
 *  MinFront    минимальное значение на панели стрелочного прибора
 *  MaxFront    максимальное значение на панели стрелочного прибора
 *  MaxResVal   максимальное значение переменного резистора стрелочного прибора
 *  */
function Update(int DeviceID, float MinFront, float MaxFront, float MaxResVal)
{
	`log("Update: DevID: " @ DeviceID @ " MinFront: " @ MinFront @ " MaxFront: " @ MaxFront @ " MaxResVal: " @ MaxResVal);

	// определяем устройство
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


/** ДЛЯ СТРЕЛОЧНОГО ПРИБОРА
 * Сохранение настроек в ini файл 
*/
function Save()
{
	`log("Save");
}

DefaultProperties
{
}
