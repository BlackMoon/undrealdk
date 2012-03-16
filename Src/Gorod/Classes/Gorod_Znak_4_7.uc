/** Класс знаков отмена ограничения минимальной скорости*/
class Gorod_Znak_4_7 extends Gorod_Znak_Speed;

function Activate(vector HitLocation, vector HitNormal)
{
	super.Activate(HitLocation, HitNormal);
	self.SendZnakEvent(self,2005);
}

DefaultProperties
{
}
