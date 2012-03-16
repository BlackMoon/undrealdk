class Gorod_BasePath extends Actor
	placeable;

enum PState
{
	PS_None,        // не определено
	PS_Opened,      // открыт дл€ движени€
	PS_Closed       // заблокирован (либо движением юотов-машин по пересекающемус€ пути, либо светофором)
};

/** ѕромежуточные точки пути + точки, которые надо блокировать при движении по этому пути */
var() array<Gorod_BasePathNode> PathNodes;

/** состо€ние пути */
var() PState PathState;

/** Pawn'ы, которые движутс€ по данному пути */
var array<Pawn> DrivingPawns;

/** Pawn'ы, которые выбрали данный путь дл€ движени€ но ещЄ не заехали на него */
var array<Pawn> WantToDrivePawns;

/** ≈сли данна€ точка €вл€етс€ въездои на перекрЄсток, то здесь хранитс€ ссылка на этот перекрЄсток */
var Gorod_CrossRoad CrossRoad;

/** ‘лаг, показывающий, что движение по данному пути запрещено (bIsClosed=true) */
var bool bIsClosed;

/** ¬севозможные типы поворота при движении по пути s*/
enum PTurnType
{
	PDR_Left,
	PDR_Right,
	PDR_Straight
};

/** “ип поворота при движении по пути */
var() PTurnType PathTurnType;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
}

/**
 * —охран€ет ссылку на перекрЄсток, которому принадлежит данный путь
 * ѕередаЄт ссылку на перекрЄсток и на самого себ€ всем маршрутным точкам, вход€щим в данный путь
 */
function RegCrossRoad(Gorod_CrossRoad cr)
{
	local Gorod_BasePathNode P;

	CrossRoad = cr;
	foreach PathNodes(P)
	{
		P.RegCrossRoad(cr);
		P.RegPath(self);
	}
}

/** 
 *  –егистрируем Pawn'а как двигающегос€ по данному пути
 */
function GoIn(Pawn p)
{	
	if(WantToDrivePawns.Find(P) == INDEX_NONE || DrivingPawns.Find(p) != INDEX_NONE) return;

	DrivingPawns.AddItem(p);
	WantToDrivePawns.RemoveItem(p);
}

/** 
 *  –егистрируем Pawn'а как покинувшего данный путь 
 */
function GoOut(Pawn p)
{	
	if(DrivingPawns.Find(p) != INDEX_NONE)
		DrivingPawns.RemoveItem(p);
}

/** 
 * –егистрируем Pawn'а как желающего начать движение по данному пути 
 */
function Select(Pawn p)
{
	if(WantToDrivePawns.Find(P) == INDEX_NONE)
		WantToDrivePawns.AddItem(p);
	//ReportPawns();
}

/**
 * ѕокидание пути в случае выгрузки соответствующего уровн€
 */
function CancelPath(Pawn p)
{
	WantToDrivePawns.RemoveItem(p);
	DrivingPawns.RemoveItem(p);
}

/** ѕроверка на возможность двинатьс€ по данному пути */
function bool CanGo()
{
	return (PathState == PS_Opened);
}

/** «апрещает движение по данному пути */
function Close()
{
	bIsClosed = true;
}

/** –азрешает движение по данному пути */
function Open()
{
	bIsClosed = false;
}

/** ¬ыводит в лог список Pawn'ов, желающих двигатьс€ по данному пути и список Pawn'ов, двигающихс€ по данному пути */
simulated function ReportPawns()
{
	local Pawn p;

	`log(">>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<");
	`log(self);
	`log("_________goin pawns___________");
	
	foreach DrivingPawns(p)
	{
		if(Gorod_HumanBot(p)!=none)
			`log(p);
	}
	`log("=========want to go pawns============");
	foreach WantToDrivePawns(p)
	{
		if(Gorod_HumanBot(p)!=none)
			`log(p);
	}
	`log(">>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<");
}

/** ќтображает отладочную инфорацию о пути */
simulated function DrawSphere()
{
	local int radius;

	radius = (PathTurnType == PDR_Straight ? 10 : 5);
	if(bIsClosed)
		DrawDebugSphere(self.Location, radius, 16, 255, 0, 0, true);
	else
		DrawDebugSphere(self.Location, radius, 16, 0, 255, 0, true);
}

/** */
simulated function DrawLines(byte R, byte G)
{
	local int i;

	for(i = 0; i < PathNodes.Length - 1; i++)
	{
		DrawDebugLine(PathNodes[i].Location, PathNodes[i+1].Location, R, G, 0, true);
	}
}

DefaultProperties
{
	bCollideActors=true;
	bCollideWorld=true;
	bBlockActors=false;

	bMovable = false;

	Begin Object Class=CylinderComponent Name=CollisionCylinder
		CollisionRadius=+0001.000000
		CollisionHeight=+0001.000000
		BlockNonZeroExtent=true
		BlockZeroExtent=true
		BlockActors=false
		CollideActors=true
		BlockRigidBody=false
	End Object
	
	CollisionComponent=CollisionCylinder
	Components.Add(CollisionCylinder)

	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorResources.PathBezier'
		HiddenGame=true
		HiddenEditor=false
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
		SpriteCategoryName="Navigation"
	End Object
	Components.Add(Sprite)

	bIsClosed = false

	PathTurnType = PDR_Straight;
}