#pragma hdrstop

#include "stdafx.h"
#include "gearbox.h"
#include <malloc.h>

float TGearbox::transTorqK(float torque) 
{
	return (torque * fEfficiency * fTopGear * fTransferGear[fTransfer] * fGears[fTransfer][fCurentGear]);
}

float TGearbox::transRpm(float rpm) 
{
	return (rpm * fTopGear * fTransferGear[fTransfer] * fGears[fTransfer][fCurentGear]);
}

TGearbox::TGearbox() 
{
	fEfficiency = 0.9f;

	time_in_neutral = 10; // милисекунд
	time_to_clutch = 10; // милисекунд
	time_to_declutch = 10; // милисекунд

	fCurentGear =  GEAR_NEUTRAL;
	fGearType = GEAR_FWD;
	fTransfer = TRANSFER_LOW;

	//	инициализация для обеспечения интерфейса матрицы
	fGears[0] = &(fGearsHlp[0]);
	fGears[1] = &(fGearsHlp[7]);

	/** Камаз */
	// Главная передача
	fTopGear = 7.22f;

	// Пониженная
	fGears[0][0] = -7.38f; // задняя
	fGears[0][1] = 0.0f; // нейтраль
	fGears[0][2] = 7.82f; // первая
	fGears[0][3] = 4.03f; // вторая
	fGears[0][4] = 2.50f; // третья
	fGears[0][5] = 1.53f; // четвёртая
	fGears[0][6] = 1.0f; // пятая

	// Повышенная
	fGears[1][0] = -6.02f; // задняя
	fGears[1][1] = 0.0f; // нейтраль
	fGears[1][2] = 6.38f; // первая
	fGears[1][3] = 3.29f; // вторая
	fGears[1][4] = 2.04f; // третья
	fGears[1][5] = 1.25f; // четвёртая
	fGears[1][6] = 0.815f; // пятая

	// Раздаточная коробка
	fTransferGear[0] = 1.692f;
	fTransferGear[1] = 0.917f;
}

void TGearbox::setGear(Gear gear) 
{
	fCurentGear = gear;
}

Gear TGearbox::getGear() 
{
	return fCurentGear;
}

void TGearbox::setGearType(int gearType) 
{
	fGearType = (GearType)gearType;
}

GearType TGearbox::getGearType() 
{
	return fGearType;
}

void TGearbox::setTransferGear(TransferGear transfer) 
{
	fTransfer = transfer;
}

//==============================================================================
/* Москвич 412
fTopGear = 3.91f;
fGears[0] = -3.39f;
fGears[1] = 0;
fGears[2] = 3.49f;
fGears[3] = 2.04f;
fGears[4] = 1.33f;
fGears[5] = 1.0f;*/

/* Четырнадцатя
topGear = 3.9f;
gears[0] = -4.0f; // задняя
gears[1] = 0.0f; // нейтраль
gears[2] = 3.64f; // первая
gears[3] = 1.95f; // вторая
gears[4] = 1.36f; // третья
gears[5] = 0.94f; // четвёртая
gears[6] = 0.78f; // пятая
*/
