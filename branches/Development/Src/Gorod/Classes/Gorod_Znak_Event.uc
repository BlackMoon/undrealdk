class Gorod_Znak_Event extends Gorod_Event;


enum Gorod_Znak_Type
{
	GOROD_ZNAK_SPEEDTYPE,
	GOROD_ZNAK_OTHERTYPE,
};
var int speed;
var Gorod_Znak_Type znakType;

DefaultProperties
{
	ZnakType=GOROD_ZNAK_OTHERTYPE;
	speed=0;
}
