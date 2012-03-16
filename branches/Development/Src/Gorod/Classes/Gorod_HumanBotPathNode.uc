/** ����� ����� ��� ����� ��������-����. ������ "�����" */
class Gorod_HumanBotPathNode extends Gorod_BasePathNode;

/** ������ �� ������ ����� */
var() array<Gorod_HumanBotPathNode> NextPathNodes;
/** ����������, ������������ ��������� �� ����� ����� �������� */
var() bool bIsBetweenLevels;
/** ����������, ������������ ����� �� ������� �� ���� ����� � ������ ����� */
var() bool bIsStart;
/** ���� ���������� true, �� � ���� ����� ����� �������� */
var() bool bCanSpawn;

/** ������ �� ����� �� ������ ������ */
var Gorod_HumanBotPathNode LevelStreamingPathNode;

delegate nodeTouch(Actor a);

//����������� ��� �������� level'a ��� levelstream'����
simulated event PostBeginPlay()
{
	local Gorod_HumanBotPathNode OterPathnode;

	super.PostBeginPlay();
	//���� � ���������� �������, ��� Pathnode ��������� ����� ������������� �������� - ���� ����������� Pathnode �� ������ ������
	if(bIsBetweenLevels==true)
	{
		//��� �����
		foreach CollidingActors(class'Gorod_HumanBotPathNode', OterPathnode, 270) 
		{
			//���� ����� �� ����, ��������� ���������� Pathnod'� ������ �� ����
			if(OterPathnode != self)
			{
				OterPathnode.LevelStreamingPathNode = self;
				//���� � ���������� �������, ��� �� Pathnod ����� ������� � ������� ������ - ��������� ������ � ���� �� �������� Pathnod
				if(bIsStart)
					self.LevelStreamingPathNode = OterPathnode;
				break;
			}
		}
	}
	// ��� ��������
	//foreach NextPathNodes(OterPathnode)
	//{
	//	DrawDebugLine(Location, OterPathnode.Location, 255, 255, 0, true);
	//}
}
simulated function bool IsFreeForRelloc()
{
	local Gorod_HumanBot OtherBot;
	//���������, �������� ���� �� ��� �����

	////////////////////
	local float Distance;
	// ��� ������� �������
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
		if(Distance >= `MAX_BOT_DISTANCE || Distance <= `MIN_BOT_DISTANCE)
		{
			return false;
		}
	}


	//////////////////////

	foreach CollidingActors(class'Gorod_HumanBot', OtherBot, 50) //45 ���� ����� �������� �������� ����
	{
		//���� ������� ������� ���� - �������
		return false;
	}
		//���� ����� ���
	return true;
}

//simulated event Touch(Actor Other, PrimitiveComponent OtherComp, Vector HitLocation, Vector HitNormal)
//{
//	local PCity_BotPathNode OterPathnode;
//	`log(">>>>>>>>>>>>>>>>Iam touch someone !<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
//	OterPathnode = PCity_BotPathNode(Other);
//	if(OterPathnode!=none)
//	{
//		`log(">>>>>>>>>>>>>>>>Iam touch some Pathnode!<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
//		OterPathnode.NextPathNodes.AddItem(self);

//	}
//}

simulated function array<Gorod_BasePathNode> GetNextPathNodes()
{
	return NextPathNodes;
}

/** ���������� ��������� ��������� �����. ���� ������ LastPathNode, �� �� �� ����������� */
simulated function Gorod_HumanBotPathNode GetNextPathNode(optional Gorod_HumanBotPathNode LastPathNode)
{
	local int randPathNode;
	local array<Gorod_HumanBotPathNode> TempPathNodes;
	local int i;
	//���� ������ ��������� �����, �� �� �� ������ �� �������
	if(LastPathNode!=none)
	{
		//�������� ������ �� �������� ������
		for(i = 0; i < NextPathNodes.Length; i++)
		{
			if(NextPathNodes[i] != LastPathNode)
				TempPathNodes.AddItem(NextPathNodes[i]);

		}
		if(TempPathNodes.Length <= 0)
			return LastPathNode;
		//�������� ��������� �����
		randPathNode = rand(TempPathNodes.Length);
		if (TempPathNodes[randPathNode] != none)
			return TempPathNodes[randPathNode];
	}
	//�����, ������ �������� ��������� �����
	else
	{
		//
		`log("warn,LastPathNode = none ");
		randPathNode = rand(NextPathNodes.Length);
		if (NextPathNodes[randPathNode] != none)
			return NextPathNodes[randPathNode];
	}
	return none;
}

/** ���������� ������ ��������� ����. ���� ������ LastPath, �� ��� ������ �� ������������. ���� ����� ���������, ������������ -1 */
simulated function int GetNextPathIndex(optional Gorod_BasePath LastPath)
{
	local int randPath;
	local int i;
	local array<int> PathIndex;

	//���� ������ ��������� �����, �� �� �� ������ �� �������
	if(LastPath != none)
	{
		//�������� ������ �� �������� ������
		for(i = 0; i <= Paths.Length-1; i++)
		{
			if(Paths[i] != LastPath)
				PathIndex.AddItem(i);
		}
		if(PathIndex.Length==0)
			return -1;
		//�������� ��������� �����
		randPath = rand(PathIndex.Length);
		return PathIndex[randPath];
	}
	//�����, ������ �������� ��������� �����
	else
	{
		//
		randPath = rand(Paths.Length);
		return randPath;
	}
}

/** ���������� ������ �� �����, ������� �� ����������� ���� */
simulated function array<Gorod_HumanBotPathNode> GetNextNonPathPathNodes(optional Gorod_HumanBotPathNode LastPathNode)
{
	/** ��������� ������ ��� �������� �����, �� ������������� ���� */
	local array<Gorod_HumanBotPathNode> TempPathNodes;
	/** ��������� ����� */
	local Gorod_HumanBotPathNode pn;

	foreach NextPathNodes(pn)
	{
		if((pn.Paths.Length == 0) && (pn != LastPathNode))
			TempPathNodes.AddItem(pn);
	}
	return TempPathNodes;
}

simulated event Touch(Actor Other, PrimitiveComponent OtherComp, Object.Vector HitLocation, Object.Vector HitNormal)
{
	nodeTouch(Other);
	super.Touch( Other,  OtherComp,  HitLocation,  HitNormal);
}

defaultproperties
{
	Begin Object Name=CollisionCylinder
		CollisionRadius=+0050.000000
		CollisionHeight=+0050.000000
		BlockNonZeroExtent=true
		BlockZeroExtent=true
		BlockActors=true
		CollideActors=true
		BlockRigidBody=false
	End Object
	bIsBetweenLevels = false
	bIsStart = true
	bCanSpawn = true
	Begin Object NAME=Sprite
		Sprite = Texture2D'Gorod_HumanBot.Texture.BotPathNode'
	End Object

}
