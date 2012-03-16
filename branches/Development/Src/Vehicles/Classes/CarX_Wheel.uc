class CarX_Wheel extends UDKVehicleWheel;

function CarX_Tick(CarX_Vehicle carX)
{

}

DefaultProperties
{
	bCollidesVehicles = true;
	
	LongSlipFactor=4.0
	LatSlipFactor=2.75
	HandbrakeLongSlipFactor=0.7
	HandbrakeLatSlipFactor=0.3
	ParkedSlipFactor=10.0
	
	WheelRadius=23

}
