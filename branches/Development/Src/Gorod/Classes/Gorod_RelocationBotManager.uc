/** Класс, который  следит за перемещениями ботов */
class Gorod_RelocationBotManager extends Actor
	placeable;

/** Массив точек, в которые можно перемещать */
var array<Gorod_BasePathNode> RelocationPoint;

var array<Gorod_BasePathNode> FreePathNodes;
/** Время между поиском свободных точек для перемещения */
var() float SecondsBetweenFind;
/** Массив Pawn'ов, которых надо переместить */
var array<Pawn> PawnToRelocation;
var private int Counter;

enum RelocationBotManagerTypes
{
	RBM_Vehicle,
	RBM_Human
};

var() RelocationBotManagerTypes RelocationBotManagerType;

simulated event PostBeginPlay()
{
	local Gorod_AIVehicle_PathNode VehiclePathNode;
	local Gorod_HumanBotPathNode HumanPathNode;

	super.PostBeginPlay();
	RelocationPoint.Remove(0, RelocationPoint.Length);

	switch(RelocationBotManagerType)
	{
		case RBM_Vehicle:
			foreach AllActors(class'Gorod_AIVehicle_PathNode', VehiclePathNode)
			{
				if(VehiclePathNode.CrossRoad == none && VehiclePathNode.NextPathNodes.Length > 0)
					RelocationPoint.AddItem(VehiclePathNode);
			}
			break;
		case RBM_Human:	
			foreach AllActors(class'Gorod_HumanBotPathNode', HumanPathNode)
			{
				if(HumanPathNode.NextPathNodes.Length > 0)
					RelocationPoint.AddItem(HumanPathNode);
			}
			break;
	}

	SecondsBetweenFind = 0.1f;
}

/** Функция добавления Pawn'а в очередь на перемещение */
 function AddPawnToReloc(Pawn P)
{
	local Vector hiddeNloc;
	local Gorod_AIVehicle v;
	//Pawn уже есть
	if(PawnToRelocation.Find(P)!=INDEX_NONE)
		return;
	hiddeNloc = Location;
	
	//Устанавливаем новое местоположение, недоступное игроку
	v = Gorod_AIVehicle(P);
	if(v != none)
	{
		v.SetCollisionType(COLLIDE_NoCollision);
		v.SetPhysics(PHYS_None);
		v.SetLocation(hiddeNloc);
		v.SetRotation(v.Rotation);
		v.CollisionComponent.SetRBPosition(hiddeNloc);
		v.CollisionComponent.SetRBRotation(v.Rotation);
	}
	else
	{
		P.SetPhysics(PHYS_None);
		P.SetLocation(hiddeNloc);
		p.Mesh.bUpdateKinematicBonesFromAnimation = false;
	}
	
	//Делаем невидимым Pawn
	P.SetHidden(true);
	//Добавляем в массив на перемещение
		PawnToRelocation.AddItem(P);
	//Переходим в стейт, который ищет свободные точки для перемещения
	GoToState('FindigFreePoint');
}

function ReportQueueLen()
{
	local Pawn p;
	
	`log("--> PawnToRelocation <--");

	foreach PawnToRelocation(p)
	{
		`log(p @ VSize(p.Velocity));
	}
}

/** Фунция возвращения Pawn'a на основную карту*/
function RelocPawn()
{
	/** Точка, в которую будем возвращать бота*/
	
	/** Бот-машина */
	local Gorod_AIVehicle Vehic;
	/** Бот-человек */
	local Gorod_HumanBot Bot;

	local Vector RelocLocation;
	
	/** Ссылка на следующую точку для машины */
	local Gorod_AIVehicle_PathNode NextVehiclePathNode;
	local Gorod_BasePathNode relocPathNode;

	//Если массив пуст, выходим
	if(PawnToRelocation.Length<=0)
		return;

	//Если нет точек для возвращения ботов на карту - ругаемся
	if(RelocationPoint.Length<=0)
		`warn("RelocationPoint.Length<=0");

	//выбираем точку для Spawna
	relocPathNode = GetRelocNode();	
	if(relocPathNode == none) return;
	
	RelocLocation = relocPathNode.Location;
	//делаем первого Pawna в списке видимым
	PawnToRelocation[0].SetHidden(false);
	
	//устанавливаем первый таргет боту
	Vehic = Gorod_AIVehicle(PawnToRelocation[0]);
	if(Vehic!=none)
	{
		NextVehiclePathNode = Gorod_AIVehicle_PathNode(relocPathNode).NextPathNodes[0];

		Vehic.SetLocation(RelocLocation);
		Vehic.SetRotation(Rotator(NextVehiclePathNode.Location - relocPathNode.Location));
		Vehic.CollisionComponent.SetRBPosition(RelocLocation);
		Vehic.CollisionComponent.SetRBRotation(Rotator(NextVehiclePathNode.Location - relocPathNode.Location));
		
		Vehic.SetCollisionType(COLLIDE_BlockAll);
		Vehic.SetPhysics(PHYS_RigidBody);
		
		Vehic.Appear(Gorod_AIVehicle_PathNode(relocPathNode));	
	}

	Bot = Gorod_HumanBot(PawnToRelocation[0]);
	if(Bot!=none)
	{
		//возвращаем Pawn'a на карту
		if(PawnToRelocation[0].Physics!=PHYS_Walking)
			PawnToRelocation[0].SetPhysics(PHYS_Walking);
		PawnToRelocation[0].SetLocation(RelocLocation);
		PawnToRelocation[0].SetRotation(relocPathNode.Rotation);
		Bot.ChangeTarget(Gorod_HumanBotPathNode(relocPathNode));
	}

	// удаляем точку, в которую только что переместили бота из массива FreePathNodes
	FreePathNodes.RemoveItem(relocPathNode);

	//сдвигаем очередь
	PawnToRelocation.Remove(0,1);
}

/** Возвращает случайную свободную точку, в которую можно переместить Pawn'a*/
function Gorod_BasePathNode GetRelocNode()
{
	/** Случайный индекс массива */
	local int rPathNode;
	local Gorod_BasePathNode base_pn;		
	base_pn = none;	
	
	GetFreePathNodes();				
	//выбираем случайную точку
	if(FreePathNodes.Length > 0 )
	{		
		rPathNode = rand(FreePathNodes.Length);
		base_pn = FreePathNodes[rPathNode];
		//возвращаем, если под точкой есть поверхность
		if(!base_pn.HasSurface()) base_pn = none;
	}		
	return base_pn;
}
/** Возвращает все точки, которые свободны */
function array<Gorod_BasePathNode> GetFreePathNodes()
{		
	local Gorod_BasePathNode base_pn;		
	if (FreePathNodes.Length > 0) FreePathNodes.Remove(0, FreePathNodes.Length);
	//обходим массив точек, в которые можно перемещать
	foreach RelocationPoint(base_pn)
	{		
		if (base_pn.IsFreeForRelloc()) 			
			FreePathNodes.AddItem(base_pn);				//добавляем во временный массив			
	}	
	//возвращаем
	return FreePathNodes;
}
//в стейте ищем свободные точки и перемещаем туда ботов
state FindigFreePoint
{
Begin:
	//если очередь не пуста
	if(PawnToRelocation.Length > 0)
	{
		//ищем свободные точки и перемещаем туда ботов
		RelocPawn();
		//защита от дурака
		if(SecondsBetweenFind<=0)
			SecondsBetweenFind = 1;
		
		Sleep(SecondsBetweenFind);
		goto 'Begin';
	}
	else
	{
		//если очередь пуста, то переходим в стейт где ничего не делаем
		GoToState('Clear');
	}

}
//стейт, где ничего не делаем
auto state Clear
{
Begin:
}

DefaultProperties
{
	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'Gorod_HumanBot.Texture.RelocMan'
		HiddenGame=true
		HiddenEditor=false
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
		SpriteCategoryName="Navigation"
	End Object
	Components.Add(Sprite)
	SecondsBetweenFind= 5
}