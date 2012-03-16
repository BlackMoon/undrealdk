/** ƒорожный знак 3.24 ограничение максимальной скорости 50 */

class Gorod_Znak_3_24_50 extends Gorod_Znak_3_24 placeable;


DefaultProperties
{
	Begin Object Name=MeshCompSign
		Materials[0] = MaterialInstanceConstant'Znaky.Material_Instances.3_24_50_mINST' //!!!!! изменить материал, когда его добавит  амиль
	End Object
	speed_limit = 50
}


