/**
 * GearBox_SimpleHandle - класс ручной коробки передач простого типа
 */

class GearBox_SimpleHandle extends GearBox;

var array<Gear> speedGears;                     // массив для хранения скоростных передач
var float reverseSpeed;                         // максимальная скорость при движении назад
var float reverseTorque;                        // крутящий момент при движении назад


/** AddSpeedGear - добавляет скоростную передачу 
 *  maxSpeed -  максимальная скорость, которая может быть достигнута на этой передаче
 *  torque -    крутящий момент
 *  maxRPM   -  Обороты двигателя при достижении максимальной скорости текущей передачи
 */
function AddSpeedGear(float maxSpeed, float torque, float maxRPM)
{
	local Gear gr;
	local InterpCurvePointFloat pt;

	pt.InterpMode = CIM_CurveAuto;

	gr.gearType = GEAR_Speed;
	gr.gearMaxSpeed = maxSpeed;
	gr.gearTorque = torque;

	/** добавляем кривую скорости\крут.момента */
	// настройка скорости при движении назад
	pt.InVal = reverseSpeed - 1;
	pt.OutVal = 0;
	gr.gearTorqueVSpeedCurve.Points.AddItem(pt);

	pt.InVal = reverseSpeed;
	pt.OutVal = reverseTorque;
	gr.gearTorqueVSpeedCurve.Points.AddItem(pt);

	// скорость при начальном разгоне
	pt.InVal = 0;
	pt.OutVal = torque;
	gr.gearTorqueVSpeedCurve.Points.AddItem(pt);

	// конечная скорость
	pt.InVal = maxSpeed - 1;
	pt.OutVal = torque;
	gr.gearTorqueVSpeedCurve.Points.AddItem(pt);

	// ограничение скорости
	pt.InVal = maxSpeed;
	pt.OutVal = 0;
	gr.gearTorqueVSpeedCurve.Points.AddItem(pt);

	// отрицательный крут момент при скорости, более высокой чем максимальная
	pt.InVal = maxSpeed + 1;
	pt.OutVal = -10;
	gr.gearTorqueVSpeedCurve.Points.AddItem(pt);


	/** Добавляем кривую скорости/оборотов двигателя */
	// при движении назад
	pt.InVal = reverseSpeed;
	pt.OutVal = reverseTorque;
	gr.gearEngineRPMCurve.Points.AddItem(pt);

	// обороты при отсутствии движения
	pt.InVal = 0.0;
	pt.OutVal = 200.0;
	gr.gearEngineRPMCurve.Points.AddItem(pt);

	// при наборе скорости
	pt.InVal = maxSpeed;
	pt.OutVal = maxRPM;
	gr.gearEngineRPMCurve.Points.AddItem(pt);
	
	speedGears.AddItem(gr);

	numOfGears = speedGears.Length;
}

/** Переключает текущую передачу на верхнюю */
function NextGear()
{
	if(currentGear < numOfGears - 1)
		currentGear++;
}

/** Переключает текущую передачу на нижнюю */
function PreviousGear()
{
	if(currentGear > 0)
		currentGear--;
}

/** Возвращает текущую передачу */
function Gear GetCurrentGear()
{
	if(speedGears.Length > 0)
		return speedGears[currentGear];
}

DefaultProperties
{
	currentGear = 0;
	reverseSpeed = -300.0;
	reverseTorque = 70.0;
}
