/** ƒорожный знак 4.6 ограничение минимальной скорости */

class Gorod_Znak_4_6 extends  Gorod_Znak_Speed;

function Activate(vector HitLocation, vector HitNormal)
{
	super.Activate(HitLocation, HitNormal);
	self.SendZnakEvent(self,2002);

}

DefaultProperties
{
	
}
