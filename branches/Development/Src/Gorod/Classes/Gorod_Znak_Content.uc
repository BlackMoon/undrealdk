/** Дорожный знак (без столба)
 *  класс используется для создания других знаков, которые отслеживают игрока */
//??? знаки будут отслеживать игрока только на клиенте?

class Gorod_Znak_Content extends Actor;

/** дорожный знак */
var(Sign) StaticMeshComponent SignMesh;

/** коллизия для touch с игроком */
var(Sign) StaticMeshComponent SignBoxMesh;

/** свет */
var(Sign) DynamicLightEnvironmentComponent LightEnvironment;


DefaultProperties
{
	Begin Object Class=DynamicLightEnvironmentComponent Name=SignLightEnvironment
	End Object
	Components.Add(SignLightEnvironment)
	LightEnvironment=SignLightEnvironment

	//дорожный знак
	Begin Object Class=StaticMeshComponent Name=MeshCompSign
		CachedMaxDrawDistance = 7000
		LightEnvironment=SignLightEnvironment
		AbsoluteScale=true;
		//HiddenGame = true
	End Object
	Components.Add(MeshCompSign)
	SignMesh = MeshCompSign

	//коллизия для контроля игрока при проезде знака
	Begin Object Class=StaticMeshComponent Name=MeshCompSignBox 
		StaticMesh = StaticMesh'Tools_1.Meshes.Mesh_Plane150x1x150' //коллизия, положение коллизии ???
		CollideActors = true
		BlockActors = false
		BlockRigidBody=false
		RBChannel=RBCC_GameplayPhysics
		RBCollideWithChannels=(Default=TRUE,BlockingVolume=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE,Vehicle=TRUE)
		HiddenGame = true
	End Object 
	Components.Add(MeshCompSignBox)
	SignBoxMesh = MeshCompSignBox
	CollisionComponent = MeshCompSignBox

	bCollideActors = true
	CollisionType = COLLIDE_TouchAll
	bHidden=true;
	
}

