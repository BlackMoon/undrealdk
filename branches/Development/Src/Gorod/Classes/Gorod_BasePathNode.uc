class Gorod_BasePathNode extends Actor
	placeable; 
var bool bIsProcessed;

/** ����, ������� ������ ���������� ����� ����������� */
var array<Gorod_BasePath> Paths;

/** ����, ������� ���������� � ������ ����� */
var array<Gorod_Basepath> StartingPaths;

/** ���� ������ ����� �������� ������� �� ����������, �� ����� �������� ������ �� ���� ���������� */
var Gorod_CrossRoad CrossRoad;

/** ��� ������� ��� �������� �������� */
var StaticMeshComponent ArrowMesh;

/** ������ ������� �������� (���� true, ������� �������� ����� �������� ���� ����� ) */
var(BasePathNode) bool bManualRotation;
/** ���� ���� ���� �� �������, ��� ����� ����� ���������� ��� �������� ����� */
var () bool bEnabled;

/** ������ ������, �� ������� ��������� ������ ����� */
var int LevelIndex;

simulated function array<Gorod_BasePathNode> GetNextPathNodes()
{
}

/** �������, ������� �������� �� ���������� ����� �� ���� ���������� ���� */
simulated function bool IsFreeForRelloc()
{
	local float Distance;
	// ��� ������� ������
	//local Gorod_PlayerController PC;
	local PlayerController PC;


	// ���������, ��������� �� ������ ����� ���������� ������ ���� �� � ������ ������
	// ��� ������� ������
	//foreach LocalPlayerControllers(class'Gorod_PlayerController', PC)
	foreach LocalPlayerControllers(class'PlayerController', PC)
	{
		if (PC.Pawn == none)
			return false;

		Distance = VSize(PC.Pawn.Location - self.Location);
		if(Distance >= `MAX_DISTANCE || Distance <= `MIN_DISTANCE)
			return false;
	}

	return true;
}

simulated function bool HasSurface()
{
	return true;
}

/** P����������� Gorod_BasePath, ��� ���������� ������ ���������� ����� */
function RegPath(Gorod_BasePath P)
{
	if(Paths.Find(P) == INDEX_NONE)
		Paths.AddItem(P);

	if(P.PathNodes[0] == self && StartingPaths.Find(P) == INDEX_NONE)
		StartingPaths.AddItem(P);
}

function RegCrossRoad(Gorod_CrossRoad cr)
{
	CrossRoad = cr;
}


simulated function DrawHUD(HUD H, optional float dist)
{
	local Vector X, Y, Z, WorldLoc, ScreenLoc;
	// ������ ��������� ��� ������-���� ��� �������
	GetAxes(Rotation, X, Y, Z);
    WorldLoc =  Location;
    ScreenLoc = H.Canvas.Project(WorldLoc);
    	
	if(ScreenLoc.X >= 0 &&	ScreenLoc.X < H.Canvas.ClipX && ScreenLoc.Y >= 0 && ScreenLoc.Y < H.Canvas.ClipY)
	{
		H.Canvas.DrawColor = MakeColor(255,0,0,255);
		H.Canvas.SetPos(ScreenLoc.X, ScreenLoc.Y);
		H.Canvas.DrawText("[" @ Name @ "]"$dist);
	}
	
}

DefaultProperties
{
	bIsProcessed = false;

	bCollideActors=true;
	bCollideWorld=true;
	bBlockActors=false;
	bEnabled = true;
	bMovable = false;
	
	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorResources.S_Pickup'
		HiddenGame=true
		HiddenEditor=false
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
		SpriteCategoryName="Navigation"
	End Object
	Components.Add(Sprite);

	Begin Object Class=CylinderComponent Name=CollisionCylinder
		CollisionRadius=+0001.000000
		CollisionHeight=+0050.000000
		BlockNonZeroExtent=true
		BlockZeroExtent=true
		BlockActors=false
		CollideActors=true
		BlockRigidBody=false
	End Object

	CollisionComponent=CollisionCylinder;
	Components.Add(CollisionCylinder);

	Begin Object Class=StaticMeshComponent Name=ArrowM
		StaticMesh = StaticMesh'Raznoe.Arrow'
		HiddenGame = true;         // ���������� � ���� ��� ���
		bUsePrecomputedShadows = true;

		CollideActors = false
		BlockActors = false
		BlockRigidBody=false
		RBChannel=RBCC_GameplayPhysics
		RBCollideWithChannels=(Default=TRUE,BlockingVolume=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE,Vehicle=TRUE)
	End Object 
	Components.Add(ArrowM);
	ArrowMesh = ArrowM;

	bManualRotation = false;

	LevelIndex = INDEX_NONE
	bTicked = false;
}
