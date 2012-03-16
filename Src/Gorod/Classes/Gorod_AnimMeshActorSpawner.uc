/** —паунит аним меш акторы */
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

/** ∆елаемое количество различных точек дл€ спауна */
var() int NumPoints;
/** ∆елаемое количество ботов */
var() int NumBots;

/** ћаксимальный случайный угол поворота бота */
var() int MaxRandBotRotation;

/** ∆елаемое количество различных точек дл€ спауна, сохраненное в INI */
var config int SavedNumPoints;

var float BotDiameter;
//погрешность
var float BotDiameterImprecision;

/** ћассив точек, в которых спаун€тс€ актора*/
var config array<Vector> SpawnPoints;
/** Ўирина */
var float width;
/** ¬ысота */

var float heigth;

var config Vector Scale;


simulated event PostBeginPlay()
{
    super.PostBeginPlay();

	SetCollisionType(COLLIDE_TouchAll);
	width  *=  DrawScale3D.X;
	heigth *=  DrawScale3D.Y;

	BotDiameter = 40;
	//если количество точек дл€ спауна меньше или равно нулю или количество ботов меньше или равно нулю, ничего не делаем
	//можно добавить пердупреждение
	if(NumPoints <= 0 || NumBots <=0)
		return;

	if(NumBots > NumPoints)
	{
		`warn(" NumPoints must be equal or greather than NumBots! ");
		return;
	}
	//если количество точек дл€ спауна не равно сохраненному и больше нул€, тогда вычисл€ем новые значени€ дл€ массива
	//“ак же вычисл€ем, если помен€лс€ масштаб меша
	if(SavedNumPoints != NumPoints ||  VSize(Scale - DrawScale3D)>0.001 )
		EvalAndSaveAllSpawnPoins();

	//если количество точек равно количеству ботов, то спауним в массиве, который содержит все точки. »наче, вычисл€ем случайные точки из массива
	if(NumBots == NumPoints)
		SpawnAnimMeshActor( SpawnPoints );
	else
		SpawnAnimMeshActor( EvalRandPoints() );
}
/** ¬ычисл€ет точки и записывает в конфиг файл */ 
function EvalAndSaveAllSpawnPoins()
{
	local int i;
	/** –адиус-вектор в локальных координатах */
	local Vector spawnVector;
	/** »тератор */
	local Vector sp;
	/** ‘лаг, который указывает что точку можно добавл€ть */
	local bool bCanAddPoint;
	//очищаем массив полностью
	SpawnPoints.Remove(0,SpawnPoints.Length);
	//добавл€ем первую точку 
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
	//сохран€емс€
	SavedNumPoints = NumPoints;
	Scale = DrawScale3D;
	SaveConfig();
}

/** √енерирует случайную точку (используютс€ глобальные координаты) */
function Vector GenerateNewPoint()
{
	local Vector spawnVector;
	spawnVector.X = rand(width) - (width/2);
	spawnVector.Y = rand(heigth) - (heigth/2);
	//—мещаем чуток вверх
	spawnVector.Z = self.Location.Z;
	//поворачитваем
	spawnVector = (spawnVector >> self.Rotation);
	//смещаем
	spawnVector += self.Location;
	return spawnVector;
}



/** ¬ычисл€ет случаные точки дл€ ботов  */
function array<Vector> EvalRandPoints()
{
	//временный массив точек, в которых спаунить
	local array<Vector> TempSpawnPoints;
	//итератор
	local Vector sp;
	//итератор
	local int i;
	/**  оличество точек дл€ удалени€ */
	local int CountPointsToDelete;
	/** »ндекс точки, котора€ будет удалена из массива */
	local int idxPointToDelete;

	CountPointsToDelete = NumPoints - NumBots ;

	//заполн€ем временный массив
	foreach SpawnPoints(sp) 
		TempSpawnPoints.AddItem(sp);

	//удал€ем случаные точки
	for (i= 0; i < CountPointsToDelete; i++)
	{
		idxPointToDelete = rand(TempSpawnPoints.Length);
		TempSpawnPoints.Remove(idxPointToDelete,1);
	}
	return TempSpawnPoints;
}

/** —паунит акторы  */
function SpawnAnimMeshActor(array<Vector> pointsToSpawn )
{
	//итератор
	local Vector sp;
	/** угол поворота бота*/
	local Rotator r;
	local Gorod_AnimMeshActor AnimMeshActor;

	foreach pointsToSpawn(sp)
	{
		// –асчитвыем угол поворота
		r = self.Rotation;
		r.Yaw += ( rand( MaxRandBotRotation ) - (MaxRandBotRotation/2) ) * DegToUnrRot;
		// —пауним
		AnimMeshActor = Spawn(class'Gorod_AnimMeshActor', self,, sp, r);
		AnimMeshActor.SetPhysics(PHYS_Walking);
		//задаем анимацию
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
