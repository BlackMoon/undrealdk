/** �������� ���� (��� ������)
 *  ����� ������������ ��� �������� ������ ������, ������� ����������� ������ */
//??? ����� ����� ����������� ������ ������ �� �������?

class Gorod_Znak_Content extends Actor;

/** �������� ���� */
var(Sign) StaticMeshComponent SignMesh;

/** �������� ��� touch � ������� */
var(Sign) StaticMeshComponent SignBoxMesh;

/** ���� */
var(Sign) DynamicLightEnvironmentComponent LightEnvironment;


DefaultProperties
{
	Begin Object Class=DynamicLightEnvironmentComponent Name=SignLightEnvironment
	End Object
	Components.Add(SignLightEnvironment)
	LightEnvironment=SignLightEnvironment

	//�������� ����
	Begin Object Class=StaticMeshComponent Name=MeshCompSign
		CachedMaxDrawDistance = 7000
		LightEnvironment=SignLightEnvironment
		AbsoluteScale=true;
		//HiddenGame = true
	End Object
	Components.Add(MeshCompSign)
	SignMesh = MeshCompSign

	//�������� ��� �������� ������ ��� ������� �����
	Begin Object Class=StaticMeshComponent Name=MeshCompSignBox 
		StaticMesh = StaticMesh'Tools_1.Meshes.Mesh_Plane150x1x150' //��������, ��������� �������� ???
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

