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

	time_in_neutral = 10; // ����������
	time_to_clutch = 10; // ����������
	time_to_declutch = 10; // ����������

	fCurentGear =  GEAR_NEUTRAL;
	fGearType = GEAR_FWD;
	fTransfer = TRANSFER_LOW;

	//	������������� ��� ����������� ���������� �������
	fGears[0] = &(fGearsHlp[0]);
	fGears[1] = &(fGearsHlp[7]);

	/** ����� */
	// ������� ��������
	fTopGear = 7.22f;

	// ����������
	fGears[0][0] = -7.38f; // ������
	fGears[0][1] = 0.0f; // ��������
	fGears[0][2] = 7.82f; // ������
	fGears[0][3] = 4.03f; // ������
	fGears[0][4] = 2.50f; // ������
	fGears[0][5] = 1.53f; // ��������
	fGears[0][6] = 1.0f; // �����

	// ����������
	fGears[1][0] = -6.02f; // ������
	fGears[1][1] = 0.0f; // ��������
	fGears[1][2] = 6.38f; // ������
	fGears[1][3] = 3.29f; // ������
	fGears[1][4] = 2.04f; // ������
	fGears[1][5] = 1.25f; // ��������
	fGears[1][6] = 0.815f; // �����

	// ����������� �������
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
/* ������� 412
fTopGear = 3.91f;
fGears[0] = -3.39f;
fGears[1] = 0;
fGears[2] = 3.49f;
fGears[3] = 2.04f;
fGears[4] = 1.33f;
fGears[5] = 1.0f;*/

/* ������������
topGear = 3.9f;
gears[0] = -4.0f; // ������
gears[1] = 0.0f; // ��������
gears[2] = 3.64f; // ������
gears[3] = 1.95f; // ������
gears[4] = 1.36f; // ������
gears[5] = 0.94f; // ��������
gears[6] = 0.78f; // �����
*/
