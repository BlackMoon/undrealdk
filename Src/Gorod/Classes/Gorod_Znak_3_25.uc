/**
 * �������� ���� 3.25 ����� ����������� ������������ ��������
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
