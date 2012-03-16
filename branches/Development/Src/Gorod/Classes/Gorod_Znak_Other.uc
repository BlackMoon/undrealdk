class Gorod_Znak_Other extends Gorod_Znak_Circle;
var int msgId;

function Activate(vector HitLocation, vector HitNormal)
{
	if(CheckDirection(HitLocation,HitNormal))
	{
		self.SendZnakEvent(self,msgId);
	}
}


DefaultProperties
{

}
