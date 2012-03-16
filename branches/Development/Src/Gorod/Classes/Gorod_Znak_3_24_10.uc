/** Дорожный знак 3.24 ограничение максимальной скорости 10 */

class Gorod_Znak_3_24_10 extends Gorod_Znak_3_24 placeable;

DefaultProperties
{
	Begin Object Name=MeshCompSign
		Materials[0] = MaterialInstanceConstant'Znaky.Material_Instances.3_24_10_mINST'
	End Object
	speed_limit = 10
}