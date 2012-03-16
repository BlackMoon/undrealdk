/**
 * Дорожный знак 3.25 конец ограничение максимальной скорости 20
 * */
class Gorod_Znak_3_25_20 extends Gorod_Znak_3_25 placeable;

DefaultProperties
{
	Begin Object Name=MeshCompSign
		Materials[0] = MaterialInstanceConstant'Znaky.Material_Instances.3_25_20_mINST' 
	End Object
	speed_limit = 20
}
