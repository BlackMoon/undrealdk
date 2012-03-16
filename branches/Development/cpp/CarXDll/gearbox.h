#ifndef gearboxH
#define gearboxH

enum Gear 
{
	GEAR_BACK = 0, 
	GEAR_NEUTRAL, 
	GEAR_FIRST, 
	GEAR_SECOND, 
	GEAR_THIRD, 
	GEAR_FOURTH, 
	GEAR_FIFTH
};

// тип привода
// type(fwd,rwd,4wd)
enum GearType 
{
	GEAR_FWD, 
	GEAR_RWD, 
	GEAR_4WD,
	// и общее количество
	GEAR_NUM
};

enum TransferGear 
{
  TRANSFER_LOW = 0, 
  TRANSFER_HIGH = 1,
  TRANSFER_NUM
};

// тип коробки
// type(auto,manual)
enum GearShiftType 
{
	SHIFT_AUTO, SHIFT_MANUAL,
	// и общее количество
	SHIFT_NUM
};

class TGearbox 
{
	private:
		float fGearsHlp[14];

	protected:
		float* fGears[2];
		float fTransferGear[2];

		float fEfficiency;
		float fTopGear;

		Gear fCurentGear;
		GearType fGearType;
		TransferGear fTransfer;

		int time_to_declutch;
		int time_in_neutral;
		int time_to_clutch;

	public:
		void setGearType(int GearType);
		GearType getGearType();

		void setGear(Gear gear);
		Gear getGear();

		void setTransferGear(TransferGear transfer);
		float transTorqK(float torque = 1);
		float transRpm(float rpm = 1);

		TGearbox();
};

#endif /* #ifndef TransmissionH */
