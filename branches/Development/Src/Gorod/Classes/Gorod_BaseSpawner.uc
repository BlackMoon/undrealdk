class Gorod_BaseSpawner extends Actor 
	implements(Gorod_EventListener)
	placeable;

`include(Gorod_Events.uci);

struct SpawnPoint
{
	var Vector Location;
	var Rotator Rotation;
	var Gorod_BasePathNode firstPathNode;
};

struct PathNodeEx
{
	var Gorod_BasePathNode PathNode;
	var float Offset;
};

/** ���-�� ����� ������� ���� �������� */
var() int BotNum;

/** ��������� ���������� ����� */
var() array<Gorod_BasePathNode> PathNodes;

/** ���������� �����, � ������� ��������� �������� ����� */
var array<SpawnPoint> SpawnNodes;

/** ����� ������� �������� ��� �� �������� */
var float BotLength;

/** ��������������� ������ ��� ������ ���������� ����� */
var array<PathNodeEx> MorePathNodes;
/** ���-�� ��������� �� ��������������� ������� ��� ������ ����� */
var int MorePathNodesLength;

/** ������ �� �������� ����������� ����� */
var() Gorod_RelocationBotManager RelocManager;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	// ���� �� ��� ��� ����, ������ �� �����
	//if(Gorod_Game(WorldInfo.Game) == none)
	//	return;

	RegisterInEventDispatcher();
}

function RegisterInEventDispatcher()
{
	local PlayerController LocalPlayerController;
	local Common_PlayerController CommonPlayerController;

	LocalPlayerController = GetALocalPlayerController();
	if(LocalPlayerController == none)
	{
		SetTimer(3, false, 'RegisterInEventDispatcher');
		return;
	}
	else
	{
		// ������� �����, ����� �������� PlayerController
		SpawnBots();
	}

	CommonPlayerController = Common_PlayerController(LocalPlayerController);
	if(CommonPlayerController != none && CommonPlayerController.EventDispatcher != none)
	{
		CommonPlayerController.EventDispatcher.RegisterListener(self, GOROD_EVENT_GAME);
	}
}

function HandleEvent(Gorod_Event evt)
{
	/*
	if ((Role == ROLE_Authority) && (evt.eventType == GOROD_EVENT_GAME) && (evt.messageID == GOROD_POSSESSED))
		SpawnBots();
	*/
}

/**
 * ������� ����� � ������, ��������� ��������� ������� ��� ����� ������ ����� ������ �� ��������, ����������� ������� ���������� �����.
 */
exec function SpawnBots()
{
	local int i, SpawnNodesLength, DelPointsNum;

	if(Role == ROLE_Authority)
	{
		MorePathNodesLength = 0;
		SpawnNodes.Remove(0, SpawnNodes.Length);

		if(BotLength <= 0)
			BotLength = 1;

		// ������� ����, �������������� ����������� ������� (������ �� ������� �������� ������ �� ��������� �����)
		// ������� � �����, ������������ � ������� PathNodes � ������������ ������ �����.
		
		// ��� ������� �������, ������������� ����� ������� ���������� ����� ��������� ����� �����, ��������������� �� ������ �������
		// �� ����������� ���������� ���� �� �����, ����������� ��� ���� ����� � ������ �� ����� ������������ ������ ����� ���� ���������� ������-���.
		// ��������������, ��� ����� ���� �����-����� ��������� � ����� BotLength

		for(i = 0; i < PathNodes.Length; i++)
			EvalWayPointsForSections(PathNodes[i]);
		
		i = 0;
		while(i < MorePathNodesLength)
		{
			EvalWayPointsForSections(MorePathNodes[i].PathNode, MorePathNodes[i].Offset);	
			i++;
		}
		
		//  �� ����������� ������ ����� ��������� ������� ������� ����� �� ��� ���, ���� �� �������� BotNum �����
		SpawnNodesLength = SpawnNodes.Length;
		DelPointsNum = SpawnNodesLength - BotNum;
		for(i = 0; i < DelPointsNum; i++)
		{
			SpawnNodes.Remove(Rand(SpawnNodesLength), 1);
			SpawnNodesLength--;
		}

		//  ��������� ������ �� �������
		//SetTimer((SpawnDeltaSeconds > 0 ? SpawnDeltaSeconds : 1.f), true, 'SpawnAIVehicle');

		// ������� �����
		for(i = 0; i < SpawnNodes.Length; i++)
			SpawnBot(SpawnNodes[i]);
	}
}

/**
 * ��� ������ ���������� ����� T, � ������� ����� ������� �� ����� St ������������ ���� ����� <St, T>
 */
function EvalWayPointsForSections(Gorod_BasePathNode St, optional float Offset)
{
	local int i;
	local array<Gorod_BasePathNode> nodes;
	
	if((St == none) || St.bIsProcessed) 
		return;

	nodes = St.GetNextPathNodes();

	for(i = 0; i < nodes.Length; i++)
		EvalWayPointsForSection(St, nodes[i], Offset);

	St.bIsProcessed = true;
}

/** 
 *  ������������ ����� �� ������� [St.Location; Fn.Location] 
 */
function EvalWayPointsForSection(Gorod_BasePathNode St, Gorod_BasePathNode Fn, optional float Offset)
{
	/** ��������������� ����� */
	local SpawnPoint P;
	/** ��������� ������, ����������� �� ����������� � �������� ���� */
	local Vector SectionRot;
	
	/** ����� ������� ���� */
	local float SectionLength;
	/** ����� ��� ����� ������� ����, ���� �� ��� ��������� ����� */
	local float ProcessedLength;
	/** ����� �������� �������� */
	local float NewOffset;
	/** ���������� �� ��������� ���� ��� ������ � ������ MorePathNodes */
	local PathNodeEx Node;

	if(St == none || Fn == none) 
		return;

	SectionLength = VSize(Fn.Location - St.Location);
	NewOffset = 0;

	// ���� ������� ����������� �����, � St � Fn �� ��������� �� ������������ ��� ��������� �� ������ ������������...
	if((SectionLength >= 2*BotLength) && ((St.CrossRoad == none) || (Fn.CrossRoad == none) || (St.CrossRoad != Fn.CrossRoad)))
	{
		ProcessedLength = 0;
		SectionRot = Normal(Fn.Location - St.Location);
		P.Rotation = rotator(SectionRot);
		P.firstPathNode = Fn;

		// ��������� ������ ����� � ������ Offset	
		P.Location = St.Location + (Offset+0.5*BotLength)*SectionRot;
		SpawnNodes.AddItem(P);
		ProcessedLength += Offset+0.5*BotLength;
	
		// ���� ����� ��������� ����� ����� � �� �� ������� �� �������� ����� �������
		while(ProcessedLength + BotLength < SectionLength)
		{
			P.Location += BotLength*SectionRot;
			ProcessedLength += BotLength;
			SpawnNodes.AddItem(P);
		}
	
		// ������������ ������ offset
		NewOffset = ProcessedLength + 0.5*BotLength - SectionLength;
	}

	Node.PathNode = Fn;
	Node.Offset = NewOffset;
	MorePathNodes.AddItem(Node);
	MorePathNodesLength++;
}

// ������� ���� ������ ��� ��������, �.�. ���������� �������� �������
function SpawnBot(SpawnPoint P)
{
}

DefaultProperties
{
}