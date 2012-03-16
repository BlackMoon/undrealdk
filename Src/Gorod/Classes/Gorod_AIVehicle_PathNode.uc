class Gorod_AIVehicle_PathNode extends Gorod_BasePathNode;

var float BOT_COLLIDE_DIST;
/** Маршрутные точки, в которые можно поехать из текущей (следующие маршрутные точки) */
var() array<Gorod_AIVehicle_PathNode> NextPathNodes;

/** Максимальная скорость с которой разрешено ехать к данной точке */
var() float CarMaxSpeed;

/** Список контроллеров машин, которые едут к данныой точке */
var array<Gorod_AIVehicle_Controller> IncomingAIVehicleControllers;

/** Последняя машина, проехавшая через эту точку */
var Gorod_AIVehicle LastCar;

/** Если флаг активен(true), с данной точки разрешается повернуть направо (относится только к внутренним точкам вьезда) */
var(AIVehicle_PathNode) bool bCanTurnRightFromInternalSide;

/** Если флаг активен(true), с данной точки разрешается повернуть налево (относится только к внутренним точкам вьезда) */
var(AIVehicle_PathNode) bool bCanTurnLeftFromInternalSide;

/** Если флаг активен(true), с данной точки разрешается повернуть налево (относится только к крайним точкам вьезда) */
var(AIVehicle_PathNode) bool bCanTurnLeft;

/** Если флаг активен(true), с данной точки разрешается повернуть направо (относится только к крайним точкам вьезда) */
var(AIVehicle_PathNode) bool bCanTurnRight;

/** Если флаг активен(true), с данной точки разрешается проехать вперед */
var(AIVehicle_PathNode) bool bCanDriveForward;

/** Если флаг активен(true), с данной точки разрешается развернуться налево (относится только к крайним точкам вьезда) */
var(AIVehicle_PathNode) bool bCanTurnReverse;

/** Если флаг активен(true), с данной точки разрешается развернуться налево (относится только к внутренним точкам вьезда) */
var(AIVehicle_PathNode) bool bCanTurnReverseFromInternalSide;

/** Если этот флаг активен, эта точка будет контролироваться правой дополнительной секцией */
var(AIVehicle_PathNode) bool bControlByRightSection;

/** Если этот флаг активен, эта точка будет контролироваться левой дополнительной секцией */
var(AIVehicle_PathNode) bool bControlByLeftSection;

/** Материал поверхности, над которой расположена точка */
var Material SurfaceMaterial;

/** Ссылка на точку для перестроения налево */
var(AIVehicle_PathNode) Gorod_AIVehicle_PathNode leftChangelineNode;
/** Ссылка на точку для перестроения направо */
var(AIVehicle_PathNode) Gorod_AIVehicle_PathNode rightChangelineNode;


var Gorod_AIVehicle_Controller ChangeLineAiVehicle_Controller;


function PostBeginPlay()
{
	super.PostBeginPlay();

	// переводим в юниты в секунду
	if(CrossRoad == none)
	{
		CarMaxSpeed = 50*CarMaxSpeed/3.6;
	}
}

/** Точка свободна для телепортации туда машины */
simulated function bool IsFreeForRelloc()
{	
	local bool result;		
	local Gorod_AIVehicle_Controller aivc;	
	local float d0, d1;
	
	result = true;	
	// если ни один игрок не видит данную точку и данная точка не находится на перекрёстке
	if(CrossRoad != none || NextPathNodes.Length == 0) // || DangerousVehicleNum > 0)
	{
		result = false;
	}
	else
	{
		// проверка из базового класса (по расстоянию до игроков-людей)
		result = super.IsFreeForRelloc();		
		if (result)
		{	
			d1 = BOT_COLLIDE_DIST;
			foreach IncomingAIVehicleControllers(aivc)
			{
				d0 = vSize(aivc.ControlledCar.Location - Location);				
				if (d0 < aivc.SafeDistance + 150 /*aivc.VEHICLE_LENGTH*/) return false;
				d1 = max(d1, aivc.SafeDistance + 150/*aivc.VEHICLE_LENGTH*/);
			}
			
			if (LastCar != none)
			{				
				d0 = vSize(LastCar.Location - Location);
				if (d0 < d1) return false;
			}			
		}
	}
	return result;
}

/** Определяет, если поверхность под данной точкой */
simulated function bool HasSurface()
{
	local Vector TraceStart, TraceEnd, HitNormal, HitLoc;
	local TraceHitInfo hi;

	// Если нет ссылки на метериал поверхности под ботом - трейсим вниз
	if(SurfaceMaterial == none)
	{
		TraceStart = self.Location;
		TraceEnd = self.Location - vect(0, 0, 100);

		Trace(HitLoc, HitNormal, TraceEnd, TraceStart, true, , hi, 1);
		SurfaceMaterial = hi.Material;
	}

	// если материал поверхности всё ещё не найден или это не материал дороги, возвращаем false
	if(SurfaceMaterial == none || !OnRoad(SurfaceMaterial.Name))
		return false;
	else
		return true;
}

/************************************************************************************/
/*          Работа с точками и путями                                               */
/************************************************************************************/

/** Возвращает все следующие маршрутные точки */
simulated function array<Gorod_BasePathNode> GetNextPathNodes()
{
	return NextPathNodes;
}

/** Возвращает случайный путь, проходящий через данную точку */
function Gorod_BasePath GetRandomPath()
{
	if(StartingPaths.Length == 0)
		return none;
	else
		return StartingPaths[Rand(StartingPaths.Length)];
}

/** Возвращает случайно выбранную следующую маршрутную точку */
function Gorod_AIVehicle_PathNode GetRandomNode()
{
	if(NextPathNodes.Length == 0)
		return none;
	else
		return NextPathNodes[Rand(NextPathNodes.Length)];
}

/** Проверяет, безопасно ли перестоиться в данную точку */
function bool isSafeForChangeLine()
{
	local Gorod_AIVehicle_Controller IncomingAIVehicleController;
	foreach IncomingAIVehicleControllers(IncomingAIVehicleController)
	{
		IncomingAIVehicleController.CalcSafeDistance();
		if(Vsize(self.Location -IncomingAIVehicleController.ControlledCar.Location) <  IncomingAIVehicleController.SafeDistance)
			return false;
	}
	return true;
}


/** Проверка на материал дороги */ 
function bool OnRoad(name matName)
{
	if(Left(string(matName), 9) == "M_4_strip" || Left(string(matName), 5) == "M_Per")
		return true;
	else
		return false;
}

DefaultProperties
{
	CarMaxSpeed = 20;

	bStatic = false;
	bNoDelete = false;

	bCanTurnRightFromInternalSide = false
	bCanTurnLeftFromInternalSide = false
	bCanTurnLeft = true
	bCanTurnRight = true
	bCanDriveForward = true
	bCanTurnReverse = true
	bCanTurnReverseFromInternalSide = false
	bControlByLeftSection = false
	bControlByRightSection = false
	
	// для теста
	Begin Object Class=StaticMeshComponent Name=MyStaticMeshComponent
		StaticMesh=StaticMesh'Pickups.Ammo_Shock.Mesh.S_Ammo_ShockRifle'
		HiddenGame = true
	End Object
	
	BOT_COLLIDE_DIST=500.0f

}