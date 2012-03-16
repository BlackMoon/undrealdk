/**
 * Дорожный знак 3.25 конец ограничение максимальной скорости
 * */
class Gorod_Znak_3_25 extends Gorod_Znak_Speed;

function Activate(vector HitLocation, vector HitNormal)
{
	super.Activate( HitLocation, HitNormal);
	self.SendZnakEvent(self,2003);
	return;
}

DefaultProperties
{

}
