/** �������� ���� 3.24 ����������� ������������ �������� */
class Gorod_Znak_3_24 extends  Gorod_Znak_Speed;


function Activate(vector HitLocation, vector HitNormal)
{
	super.Activate(HitLocation, HitNormal);
	self.SendZnakEvent(self,2001);
	return;
}

DefaultProperties
{
	
}
