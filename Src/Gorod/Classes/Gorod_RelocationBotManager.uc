/** �����, �������  ������ �� ������������� ����� */
class Gorod_RelocationBotManager extends Actor
	placeable;

/** ������ �����, � ������� ����� ���������� */
var array<Gorod_BasePathNode> RelocationPoint;

var array<Gorod_BasePathNode> FreePathNodes;
/** ����� ����� ������� ��������� ����� ��� ����������� */
var() float SecondsBetweenFind;
/** ������ Pawn'��, ������� ���� ����������� */
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

/** ������� ���������� Pawn'� � ������� �� ����������� */
 function AddPawnToReloc(Pawn P)
{
	local Vector hiddeNloc;
	local Gorod_AIVehicle v;
	//Pawn ��� ����
	if(PawnToRelocation.Find(P)!=INDEX_NONE)
		return;
	hiddeNloc = Location;
	
	//������������� ����� ��������������, ����������� ������
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
	
	//������ ��������� Pawn
	P.SetHidden(true);
	//��������� � ������ �� �����������
		PawnToRelocation.AddItem(P);
	//��������� � �����, ������� ���� ��������� ����� ��� �����������
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

/** ������ ����������� Pawn'a �� �������� �����*/
function RelocPawn()
{
	/** �����, � ������� ����� ���������� ����*/
	
	/** ���-������ */
	local Gorod_AIVehicle Vehic;
	/** ���-������� */
	local Gorod_HumanBot Bot;

	local Vector RelocLocation;
	
	/** ������ �� ��������� ����� ��� ������ */
	local Gorod_AIVehicle_PathNode NextVehiclePathNode;
	local Gorod_BasePathNode relocPathNode;

	//���� ������ ����, �������
	if(PawnToRelocation.Length<=0)
		return;

	//���� ��� ����� ��� ����������� ����� �� ����� - ��������
	if(RelocationPoint.Length<=0)
		`warn("RelocationPoint.Length<=0");

	//�������� ����� ��� Spawna
	relocPathNode = GetRelocNode();	
	if(relocPathNode == none) return;
	
	RelocLocation = relocPathNode.Location;
	//������ ������� Pawna � ������ �������
	PawnToRelocation[0].SetHidden(false);
	
	//������������� ������ ������ ����
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
		//���������� Pawn'a �� �����
		if(PawnToRelocation[0].Physics!=PHYS_Walking)
			PawnToRelocation[0].SetPhysics(PHYS_Walking);
		PawnToRelocation[0].SetLocation(RelocLocation);
		PawnToRelocation[0].SetRotation(relocPathNode.Rotation);
		Bot.ChangeTarget(Gorod_HumanBotPathNode(relocPathNode));
	}

	// ������� �����, � ������� ������ ��� ����������� ���� �� ������� FreePathNodes
	FreePathNodes.RemoveItem(relocPathNode);

	//�������� �������
	PawnToRelocation.Remove(0,1);
}

/** ���������� ��������� ��������� �����, � ������� ����� ����������� Pawn'a*/
function Gorod_BasePathNode GetRelocNode()
{
	/** ��������� ������ ������� */
	local int rPathNode;
	local Gorod_BasePathNode base_pn;		
	base_pn = none;	
	
	GetFreePathNodes();				
	//�������� ��������� �����
	if(FreePathNodes.Length > 0 )
	{		
		rPathNode = rand(FreePathNodes.Length);
		base_pn = FreePathNodes[rPathNode];
		//����������, ���� ��� ������ ���� �����������
		if(!base_pn.HasSurface()) base_pn = none;
	}		
	return base_pn;
}
/** ���������� ��� �����, ������� �������� */
function array<Gorod_BasePathNode> GetFreePathNodes()
{		
	local Gorod_BasePathNode base_pn;		
	if (FreePathNodes.Length > 0) FreePathNodes.Remove(0, FreePathNodes.Length);
	//������� ������ �����, � ������� ����� ����������
	foreach RelocationPoint(base_pn)
	{		
		if (base_pn.IsFreeForRelloc()) 			
			FreePathNodes.AddItem(base_pn);				//��������� �� ��������� ������			
	}	
	//����������
	return FreePathNodes;
}
//� ������ ���� ��������� ����� � ���������� ���� �����
state FindigFreePoint
{
Begin:
	//���� ������� �� �����
	if(PawnToRelocation.Length > 0)
	{
		//���� ��������� ����� � ���������� ���� �����
		RelocPawn();
		//������ �� ������
		if(SecondsBetweenFind<=0)
			SecondsBetweenFind = 1;
		
		Sleep(SecondsBetweenFind);
		goto 'Begin';
	}
	else
	{
		//���� ������� �����, �� ��������� � ����� ��� ������ �� ������
		GoToState('Clear');
	}

}
//�����, ��� ������ �� ������
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