/** Дорожный знак 3.24 ограничение максимальной скорости 30 */

class Gorod_Znak_3_24_30 extends Gorod_Znak_3_24 placeable;

DefaultProperties
{
	Begin Object Name=MeshCompSign
		Materials[0] = MaterialInstanceConstant'Znaky.Material_Instances.3_24_30_mINST'
	End Object
	speed_limit = 30
}

