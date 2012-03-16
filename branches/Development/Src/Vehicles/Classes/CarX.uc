class CarX extends Actor DLLBind(CarXDll);

/** Передачи */
enum CarX_Gear 
{
	GEAR_BACK,      // Задний
	GEAR_NEUTRAL,   // Нейтраль
	GEAR_FIRST,
	GEAR_SECOND,
	GEAR_THIRD,
	GEAR_FOURTH,
	GEAR_FIFTH,
	GEAR_NUM        //  появилось из C++ проекта по аналогии с ним
};

/** тип привода type(fwd,rwd,4wd)*/
enum CarX_GearType 
{
	TYPE_FWD, // Передний
	TYPE_RWD, // Задний
	TYPE_4WD, // Полный
	// и общее количество
	TYPE_NUM
};

/** Тип передачи диференцала, повышающая или понижающая */
enum CarX_TransferGear 
{
	TRANSFER_LOW, // Понижающая
	TRANSFER_HIGH, // Повышающая
	// и общее количество
	TRANSFER_NUM
};

/** тип коробки type(auto,manual)*/
enum CarX_GearShiftType 
{
	SHIFT_AUTO, // коробка-автомат
	SHIFT_MANUAL, // ручная КПП простая
	// и общее количество
	SHIFT_NUM
};

/** Структура для колес */
struct TWheelX 
{
	var float rpm;              // Обороты колеса в минуту
	var float brakeTorque;      // Тормозной крутящий момент 
	var float chassisTorque;    // Крутящий момент на Шасси машины от колеса 
	var float torque;	        // Крутящий момент передаваеммый от двигателя к колесу
};

/** Структура отражающая состояние машины для работы с Dll */
struct TCarX 
{
	var Vector u;	                    //  Вектор нормали машины
	var float rpm;                      //  Кол-во оборотов двигателя в минуту

	// IN - Входные параметры
	var int ignition;                   //  Зажигание включено/выключенно 1..0
	var int starter;                    //  Включить стартер 1..0
	var float brake;                    //  Тормоза на все колеса значение крутящего момента
	var float clutch;		            //  Значение оси сцепления от 1..0
	var float handBrake;                //  Ручной тормоз, значение только на задние колеса
	var int gear;                       //  Текущая передача
	var float throttle;	                //  Значение оси поднятия дроселя 0..1

	// OUT - Выходные параметры	
	var vector Flong;                   //  Результирующая сила влияющая на машину
	var Vector speed;                   //  Векторная скорость машины
	var Vector a;                       //  Векторное ускорение машины

	// gearbox 
	var int gearType;                   //  Тип коробки передачь: передний, задний или полный привод
	var int transfer;                   //  Передача: повышающия или понижающая

	/** Межосевой дифференциал */
	var int diff_axle;
	/** Межколесный дифференциал 1 */
	var int diff_wheels1;
	/** Межколесный дифференциал 2 */
	var int diff_wheels2;
	// Wheel
	var int countWheel;                 //  Кол-во колес 2,4,6
	var array <TWheelX> wheels;         //  Массив колес
};

/** Кол-во UU в Метре */
const UU2M=50;
/** Константа - кол-во колес в машине */
const COUNT_WHEEL = 4;
/** Машина */
var TCarX car; 
var int iTickIdx;

//C++ __declspec(dllexport) int progress(TCarX* fCar);							 
/** Основная функция для вызова CarX.Dll 
 *  fCar - In|Out структура сосстояния  машины 
 *  DeltaSeconds - время которое прошло после прошлого тика */
dllimport final function int progressX(out TCarX fCar, float DeltaSeconds);


function STick (FLOAT DeltaSeconds) 
{
	// Убираем блуждающую скорость
	if (VSize (car.speed) < 10)
	{
		car.speed.X = 0.f;
		car.speed.Y = 0.f;
		car.speed.Z = 0.f;
	}
	else
	{
		/* Преобразуем UU в Метры, для значений Скорости и Силы */
		car.speed /= UU2M;
		//car.Flong /= UU2M;
	}

	/* Запускаем DLL, на выходе получаем новые значения */
	progressX(car, DeltaSeconds);	

	/* Преобразуем Из Метров в UU */
	//car.speed *= UU2M;
	//car.Flong *= UU2M;
	//car.a *= UU2M;

	/* Уменьшаем все крутящие моменты на колеса, чистый крутящий рвет машину */
	for (iTickIdx = 0; iTickIdx < COUNT_WHEEL; iTickIdx++) 
	{
		if (car.rpm > 300.f)
		{
			car.wheels[iTickIdx].torque = car.wheels[iTickIdx].torque * 0.25f;
			car.wheels[iTickIdx].brakeTorque = 1.f;
		}
		else 
		{
			car.wheels[iTickIdx].brakeTorque = 3.f + Abs(car.wheels[iTickIdx].torque) * car.clutch;
			car.wheels[iTickIdx].torque = 0.f;
		}
	}
}

event PostBeginPlay()
{
	local TWheelX wheel;

	`Entry();
	super.PostBeginPlay();

	car.u.X = 1;
	car.u.Y = 0;
	car.u.Z = 0;
	
	car.speed.X = 0;
	car.speed.Y = 0;
	car.speed.Z = 0;

	car.Flong.X = 0;
	car.Flong.Y = 0;
	car.Flong.Z = 0;

	car.a.X = 0;
	car.a.Y = 0;
	car.a.Z = 0;

	car.ignition = 0;
	car.starter = 0;
	car.brake = 0;
	car.handBrake = 1;

	car.gear = GEAR_NEUTRAL;
	car.gearType = TYPE_FWD;
	car.transfer = TRANSFER_HIGH;
	car.diff_axle = 0;
	car.diff_wheels1 = 0;
	car.diff_wheels2 = 0;

	car.clutch = 0.0;
	car.rpm = 0.0;
	car.throttle = 0.3;
	
	car.countWheel = COUNT_WHEEL;
	car.wheels.Add(COUNT_WHEEL);
	foreach car.wheels (wheel) 
	{
		wheel.rpm = 0;
		wheel.torque = 0;
		wheel.brakeTorque = 0;
		wheel.chassisTorque = 0;
	}
	`Exit();
}

DefaultProperties
{

}