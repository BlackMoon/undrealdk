/** Ѕазовый класс дл€ всех машин в проекте √ород - машина, имеюща€ длину ширину и не умирающа€ от PenetrationDestroy */
class VehicleBase extends UDKVehicle abstract;

/** длина машины */
var float VEHICLE_LENGTH;

/** ширина машины */
var float VEHICLE_WIDTH;

// необходимо дл€ переопределени€ событи€ смерти пауна, иначе не можем сесть в камаз
// #ToDo: ”далить когда найдетс€ решение проблемы.
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
