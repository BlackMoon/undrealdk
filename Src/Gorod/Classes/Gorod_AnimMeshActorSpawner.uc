/** ������� ���� ��� ������ */
class Gorod_AnimMeshActorSpawner extends Actor
	config(AnimMeshActor)
	placeable
	perobjectconfig;

enum AnimationType
{
	AT_Normal,
	AT_LookAtFire
};

var() AnimationType AnimType;

/** �������� ���������� ��������� ����� ��� ������ */
var() int NumPoints;
/** �������� ���������� ����� */
var() int NumBots;

/** ������������ ��������� ���� �������� ���� */
var() int MaxRandBotRotation;

/** �������� ���������� ��������� ����� ��� ������, ����������� � INI */
var config int SavedNumPoints;

var float BotDiameter;
//�����������
var float BotDiameterImprecision;

/** ������ �����, � ������� ��������� ������*/
var config array<Vector> SpawnPoints;
/** ������ */
var float width;
/** ������ */

var float heigth;

var config Vector Scale;


simulated event PostBeginPlay()
{
    super.PostBeginPlay();

	SetCollisionType(COLLIDE_TouchAll);
	width  *=  DrawScale3D.X;
	heigth *=  DrawScale3D.Y;

	BotDiameter = 40;
	//���� ���������� ����� ��� ������ ������ ��� ����� ���� ��� ���������� ����� ������ ��� ����� ����, ������ �� ������
	//����� �������� ��������������
	if(NumPoints <= 0 || NumBots <=0)
		return;

	if(NumBots > NumPoints)
	{
		`warn(" NumPoints must be equal or greather than NumBots! ");
		return;
	}
	//���� ���������� ����� ��� ������ �� ����� ������������ � ������ ����, ����� ��������� ����� �������� ��� �������
	//��� �� ���������, ���� ��������� ������� ����
	if(SavedNumPoints != NumPoints ||  VSize(Scale - DrawScale3D)>0.001 )
		EvalAndSaveAllSpawnPoins();

	//���� ���������� ����� ����� ���������� �����, �� ������� � �������, ������� �������� ��� �����. �����, ��������� ��������� ����� �� �������
	if(NumBots == NumPoints)
		SpawnAnimMeshActor( SpawnPoints );
	else
		SpawnAnimMeshActor( EvalRandPoints() );
}
/** ��������� ����� � ���������� � ������ ���� */ 
function EvalAndSaveAllSpawnPoins()
{
	local int i;
	/** ������-������ � ��������� ����������� */
	local Vector spawnVector;
	/** �������� */
	local Vector sp;
	/** ����, ������� ��������� ��� ����� ����� ��������� */
	local bool bCanAddPoint;
	//������� ������ ���������
	SpawnPoints.Remove(0,SpawnPoints.Length);
	//��������� ������ ����� 
	SpawnPoints.AddItem( GenerateNewPoint() );

	for( i=0; i < NumPoints; i++ )
	{
		bCanAddPoint = true;
		spawnVector = GenerateNewPoint();
		foreach SpawnPoints( sp )
		{
			if( VSize(sp-spawnVector) < BotDiameter + BotDiameterImprecision )
			{
				bCanAddPoint = false;
			}
		}
		if(bCanAddPoint)
			SpawnPoints.AddItem(spawnVector);

	}
	//�����������
	SavedNumPoints = NumPoints;
	Scale = DrawScale3D;
	SaveConfig();
}

/** ���������� ��������� ����� (������������ ���������� ����������) */
function Vector GenerateNewPoint()
{
	local Vector spawnVector;
	spawnVector.X = rand(width) - (width/2);
	spawnVector.Y = rand(heigth) - (heigth/2);
	//������� ����� �����
	spawnVector.Z = self.Location.Z;
	//�������������
	spawnVector = (spawnVector >> self.Rotation);
	//�������
	spawnVector += self.Location;
	return spawnVector;
}



/** ��������� �������� ����� ��� �����  */
function array<Vector> EvalRandPoints()
{
	//��������� ������ �����, � ������� ��������
	local array<Vector> TempSpawnPoints;
	//��������
	local Vector sp;
	//��������
	local int i;
	/** ���������� ����� ��� �������� */
	local int CountPointsToDelete;
	/** ������ �����, ������� ����� ������� �� ������� */
	local int idxPointToDelete;

	CountPointsToDelete = NumPoints - NumBots ;

	//��������� ��������� ������
	foreach SpawnPoints(sp) 
		TempSpawnPoints.AddItem(sp);

	//������� �������� �����
	for (i= 0; i < CountPointsToDelete; i++)
	{
		idxPointToDelete = rand(TempSpawnPoints.Length);
		TempSpawnPoints.Remove(idxPointToDelete,1);
	}
	return TempSpawnPoints;
}

/** ������� ������  */
function SpawnAnimMeshActor(array<Vector> pointsToSpawn )
{
	//��������
	local Vector sp;
	/** ���� �������� ����*/
	local Rotator r;
	local Gorod_AnimMeshActor AnimMeshActor;

	foreach pointsToSpawn(sp)
	{
		// ���������� ���� ��������
		r = self.Rotation;
		r.Yaw += ( rand( MaxRandBotRotation ) - (MaxRandBotRotation/2) ) * DegToUnrRot;
		// �������
		AnimMeshActor = Spawn(class'Gorod_AnimMeshActor', self,, sp, r);
		AnimMeshActor.SetPhysics(PHYS_Walking);
		//������ ��������
		switch (AnimType)
		{
		case AT_Normal:
			AnimMeshActor.AnimationType = 0.0;
			break;

		case AT_LookAtFire:
			AnimMeshActor.AnimationType = 1.0;
			break;
		}

	}
}


DefaultProperties
{

	width = 1225;
	heigth = 1225;
	BotDiameterImprecision = 5;
	MaxRandBotRotation = 0;

	Begin Object Class=StaticMeshComponent Name=MBox 
		StaticMesh = StaticMesh'Tools_1.Meshes.Mesh_Pesh'
		CollideActors = true
		BlockActors = false
		BlockRigidBody=false
		RBChannel=RBCC_GameplayPhysics
		RBCollideWithChannels=(Default=TRUE,BlockingVolume=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE,Vehicle=TRUE)
		HiddenGame = true
	End Object
	CollisionType = COLLIDE_TouchAll;
	Components.Add(MBox);
	CollisionComponent = MBox
}
