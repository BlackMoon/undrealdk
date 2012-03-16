/** Дорожный знак  (без столба) "круглый"
 *  класс используется для создания круглых знаков, которые отслеживают игрока */

class Gorod_Znak_Circle extends Gorod_Znak_Touch;


DefaultProperties
{
	Begin Object Name=MeshCompSign
		StaticMesh = StaticMesh'Znaky.Meshes.circle'
	End Object
}
