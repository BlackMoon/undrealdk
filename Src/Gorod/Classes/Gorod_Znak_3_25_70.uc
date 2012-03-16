/**
 * Дорожный знак 3.25 конец ограничение максимальной скорости 70
 * */

class Gorod_Znak_3_25_70 extends Gorod_Znak_3_25 placeable;

DefaultProperties
{
	Begin Object Name=MeshCompSign
		Materials[0] = MaterialInstanceConstant'Znaky.Material_Instances.3_25_70_mINST' 
	End Object
	speed_limit = 70
}
