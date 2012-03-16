class Gorod_BasePath extends Actor
	placeable;

enum PState
{
	PS_None,        // �� ����������
	PS_Opened,      // ������ ��� ��������
	PS_Closed       // ������������ (���� ��������� �����-����� �� ��������������� ����, ���� ����������)
};

/** ������������� ����� ���� + �����, ������� ���� ����������� ��� �������� �� ����� ���� */
var() array<Gorod_BasePathNode> PathNodes;

/** ��������� ���� */
var() PState PathState;

/** Pawn'�, ������� �������� �� ������� ���� */
var array<Pawn> DrivingPawns;

/** Pawn'�, ������� ������� ������ ���� ��� �������� �� ��� �� ������� �� ���� */
var array<Pawn> WantToDrivePawns;

/** ���� ������ ����� �������� ������� �� ����������, �� ����� �������� ������ �� ���� ���������� */
var Gorod_CrossRoad CrossRoad;

/** ����, ������������, ��� �������� �� ������� ���� ��������� (bIsClosed=true) */
var bool bIsClosed;

/** ������������ ���� �������� ��� �������� �� ���� s*/
enum PTurnType
{
	PDR_Left,
	PDR_Right,
	PDR_Straight
};

/** ��� �������� ��� �������� �� ���� */
var() PTurnType PathTurnType;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
}

/**
 * ��������� ������ �� ����������, �������� ����������� ������ ����
 * ������� ������ �� ���������� � �� ������ ���� ���� ���������� ������, �������� � ������ ����
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
 *  ������������ Pawn'� ��� ������������ �� ������� ����
 */
function GoIn(Pawn p)
{	
	if(WantToDrivePawns.Find(P) == INDEX_NONE || DrivingPawns.Find(p) != INDEX_NONE) return;

	DrivingPawns.AddItem(p);
	WantToDrivePawns.RemoveItem(p);
}

/** 
 *  ������������ Pawn'� ��� ����������� ������ ���� 
 */
function GoOut(Pawn p)
{	
	if(DrivingPawns.Find(p) != INDEX_NONE)
		DrivingPawns.RemoveItem(p);
}

/** 
 * ������������ Pawn'� ��� ��������� ������ �������� �� ������� ���� 
 */
function Select(Pawn p)
{
	if(WantToDrivePawns.Find(P) == INDEX_NONE)
		WantToDrivePawns.AddItem(p);
	//ReportPawns();
}

/**
 * ��������� ���� � ������ �������� ���������������� ������
 */
function CancelPath(Pawn p)
{
	WantToDrivePawns.RemoveItem(p);
	DrivingPawns.RemoveItem(p);
}

/** �������� �� ����������� ��������� �� ������� ���� */
function bool CanGo()
{
	return (PathState == PS_Opened);
}

/** ��������� �������� �� ������� ���� */
function Close()
{
	bIsClosed = true;
}

/** ��������� �������� �� ������� ���� */
function Open()
{
	bIsClosed = false;
}

/** ������� � ��� ������ Pawn'��, �������� ��������� �� ������� ���� � ������ Pawn'��, ����������� �� ������� ���� */
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

/** ���������� ���������� ��������� � ���� */
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