/** Класс GearBox инкапсулирует логику работы коробки передач */

class GearBox extends Object abstract;

enum GearTypes
{
	GEAR_Neutral,
	GEAR_Speed,
	GEAR_Reverse
};

struct Gear
{
	var GearTypes gearType;
	var float gearMaxSpeed;
	var float gearTorque;
	var InterpCurveFloat gearTorqueVSpeedCurve;        // кривая отношения скорости к крутящему моменту
	var InterpCurveFloat gearEngineRPMCurve;           // кривая отношения скорости к оборотам двигателя
};
	
var int numOfGears;                // количество передач
var int currentGear;               // текущая передача

DefaultProperties
{
	numOfGears = 0;
}
