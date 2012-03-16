class Gorod_Znak_2_5 extends Gorod_Znak_Speed placeable;

function Activate(vector HitLocation, vector HitNormal)
{
	super.Activate(HitLocation, HitNormal);
	SendZnakEvent(self,2007);
}
function UnActivate()
{
	SendZnakEvent(self,2008);
}

DefaultProperties
{
	Begin Object Name=MeshCompSign
		Materials[0] = MaterialInstanceConstant'Znaky.Material_Instances.2_5_mINST'
	End Object
	speed_limit=0;
}
