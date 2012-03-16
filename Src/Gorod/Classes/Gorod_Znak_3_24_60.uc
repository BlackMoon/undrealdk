/** Дорожный знак 3.24 ограничение максимальной скорости 60 */

class Gorod_Znak_3_24_60 extends Gorod_Znak_3_24 placeable;

DefaultProperties
{
	Begin Object Name=MeshCompSign
		Materials[0] = MaterialInstanceConstant'Znaky.Material_Instances.3_24_60_mINST' 
	End Object
	speed_limit = 60
}


