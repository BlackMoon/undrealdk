/** Припаркованная машина */
class Gorod_StaticCar extends Actor
	config(StaticCar)

	placeable;

var config int ChanceToSpawnCar;
var config array<LinearColor> VehicleColors;

var StaticMeshComponent StaticMeshComponent;

/** Номер статикмеша, если есть */
var repnotify int StaticMeshIdx;
/** Цвета машины */
var repnotify LinearColor VehicleColor;

/** Изменился ли статик меш машины */
var bool bStaticMeshHasChanged;

replication
{
	if (Role == ROLE_Authority && bNetInitial) 
		StaticMeshIdx, VehicleColor;//,StaticMeshComponent;
}
simulated event ReplicatedEvent(name VarName)
{
	super.ReplicatedEvent( VarName );
	if (VarName == 'StaticMeshIdx' && Role<ROLE_Authority)
	{
		setStaticMeshCar(StaticMeshIdx);
	}
	else if(VarName =='VehicleColor' && Role<ROLE_Authority)
	{
		setColorCar(VehicleColor);
	}
}

simulated event PostBeginPlay()
{
    super.PostBeginPlay();
	switch (WorldInfo.NetMode)
	{
	case NM_Standalone:                 // если сервер ещё не создан или мы ещё не подключились к серверу			
	case NM_ListenServer:               //Показываем меню только на сервере
		GenSettings();
		setStaticMeshCar(StaticMeshIdx);
		setColorCar(VehicleColor);
		break;
	case NM_Client:
		StaticMeshComponent.SetStaticMesh(none,true);
		
	default:
		break;
	}

}
/** Генерирует настройки машины */
simulated function GenSettings()
{

	local int SpawnChance;
	SpawnChance = rand(100);
	SpawnChance += 1;
	if(SpawnChance <=ChanceToSpawnCar)
	{
		StaticMeshIdx = rand(5)+1;
		VehicleColor = genRandColor(StaticMeshIdx);
	}
}


/** Устанавливает статик меш машины взависимости от индекса */
simulated function setStaticMeshCar(int idx)
{
	if(WorldInfo.NetMode == NM_Client)
	{
		`log(idx);
	}
		switch ( idx )
		{
		case 0:
			StaticMeshComponent.SetStaticMesh(none,true);
			break;		
		case 1:
			StaticMeshComponent.SetStaticMesh(StaticMesh'Cars.Meshes.gazel',true);
			break;		
		case 2:
			StaticMeshComponent.SetStaticMesh(StaticMesh'Cars.Meshes.lada_kalina',true);
			break;		
		case 3:
			StaticMeshComponent.SetStaticMesh(StaticMesh'Cars.Meshes.Lada_Priora',true);
			break;		
		case 4:
			StaticMeshComponent.SetStaticMesh(StaticMesh'Cars.Meshes.niva_shevrole',true);
			break;
		case 5:
			StaticMeshComponent.SetStaticMesh(StaticMesh'Cars.Meshes.audi',true);
			break;
		default:

			StaticMeshComponent.SetStaticMesh(none,true);
			break;		
		}
		bStaticMeshHasChanged = true;
		setColorCar(VehicleColor);
}
/** Устанавливает цвет машины взависимости от индекса */
simulated function setColorCar(LinearColor col)
{
	local MaterialInstanceConstant MatInst;
	if(!bStaticMeshHasChanged)
		return;
	MatInst = new class'MaterialInstanceConstant';
	MatInst.SetParent( StaticMeshComponent.GetMaterial(0) );
	MatInst.SetVectorParameterValue('Kuzov_Color', col);
	StaticMeshComponent.SetMaterial(0,MatInst);
}

simulated function LinearColor GenRandColor(int CarIndex)
{
	local LinearColor col;
	local int n;
	n = Rand(VehicleColors.Length);
	col = VehicleColors[n];
	col.R/=255;
	col.G/=255;
	col.B/=255;
	return col;

}
DefaultProperties
{
	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent0
		StaticMesh = StaticMesh'Cars.Meshes.gazel'
		bAllowApproximateOcclusion=TRUE
		bAcceptsLights= TRUE
		bForceDirectLightMap=TRUE
	End Object
	bCollideActors = TRUE
	bBlockActors = TRUE
	RemoteRole = ROLE_SimulatedProxy
	Role = ROLE_Authority
	bNoDelete= true

	CollisionComponent=StaticMeshComponent0
	StaticMeshComponent=StaticMeshComponent0
	Components.Add(StaticMeshComponent0)
	bReplicateMovement=false
	bMovable=false

	bStaticMeshHasChanged = false;
	bAlwaysRelevant = true
	bUpdateSimulatedPosition = false
	bReplicateInstigator = false

	bTicked = false
}
