/**
 * Дорожный знак 3.25 конец ограничение максимальной скорости 80
 * */

class Gorod_Znak_3_25_80 extends Gorod_Znak_3_25 placeable;

DefaultProperties
{
	Begin Object Name=MeshCompSign
		Materials[0] = MaterialInstanceConstant'Znaky.Material_Instances.3_25_80_mINST' 
	End Object
	speed_limit = 80
}
