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

/** кол-во ботов которое надо спаунить */
var() int BotNum;

/** Начальные маршрутные точки */
var() array<Gorod_BasePathNode> PathNodes;

/** Маршрутные точки, в которые разрешено спаунить ботов */
var array<SpawnPoint> SpawnNodes;

/** Длина которую занимает бот на маршруте */
var float BotLength;

/** вспомогательный массив для обхода маршрутных точек */
var array<PathNodeEx> MorePathNodes;
/** кол-во элементов во вспомогательном массиве для обхода точек */
var int MorePathNodesLength;

/** Ссылка на менеджер перемещения ботов */
var() Gorod_RelocationBotManager RelocManager;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	// если не тот тип игры, ничего не далем
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
		// спауним ботов, когда создался PlayerController
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
 * Спаунит ботов в точках, выбранных случайным образом так чтобы данные точки лежали на отрезках, соединяющих смежные маршрутные точки.
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

		// Обходим граф, сформированный маршрутными точками (каждая из которых содержит ссылку на следующие точки)
		// начиная с точек, содержащихся в массиве PathNodes и обрабатываем каждую точку.
		
		// Для каждого отрезка, образованного парой смежных маршрутных точек вычисляем набор точек, располагающихся на данном отрезке
		// на минимальном расстоянии друг от друга, достаточном для того чтобы в каждой из точек вычисленного набора могла быть отспаунена машина-бот.
		// Предполагается, что длина всех машин-ботов одинакова и равна BotLength

		for(i = 0; i < PathNodes.Length; i++)
			EvalWayPointsForSections(PathNodes[i]);
		
		i = 0;
		while(i < MorePathNodesLength)
		{
			EvalWayPointsForSections(MorePathNodes[i].PathNode, MorePathNodes[i].Offset);	
			i++;
		}
		
		//  Из полученного набора точек случайным образом удаляем точки до тех пор, пока не осталось BotNum точек
		SpawnNodesLength = SpawnNodes.Length;
		DelPointsNum = SpawnNodesLength - BotNum;
		for(i = 0; i < DelPointsNum; i++)
		{
			SpawnNodes.Remove(Rand(SpawnNodesLength), 1);
			SpawnNodesLength--;
		}

		//  запускаем таймер на сервере
		//SetTimer((SpawnDeltaSeconds > 0 ? SpawnDeltaSeconds : 1.f), true, 'SpawnAIVehicle');

		// спауним ботов
		for(i = 0; i < SpawnNodes.Length; i++)
			SpawnBot(SpawnNodes[i]);
	}
}

/**
 * Для каждой маршрутной точки T, в которую можно попасть из точки St обрабатываем пару точек <St, T>
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
 *  Рассчитывает точки на отрезке [St.Location; Fn.Location] 
 */
function EvalWayPointsForSection(Gorod_BasePathNode St, Gorod_BasePathNode Fn, optional float Offset)
{
	/** вспомогательная точка */
	local SpawnPoint P;
	/** единичный вектор, совпадающий по направлению с отрезком пути */
	local Vector SectionRot;
	
	/** Длина отрезка пути */
	local float SectionLength;
	/** Длина той части отрезка пути, куда мы уже поставили точки */
	local float ProcessedLength;
	/** Новое значение смещения */
	local float NewOffset;
	/** Информация об очередном узле для записи в массив MorePathNodes */
	local PathNodeEx Node;

	if(St == none || Fn == none) 
		return;

	SectionLength = VSize(Fn.Location - St.Location);
	NewOffset = 0;

	// если отрезок достаточной длины, а St и Fn не находятся на перекрестках или находятся на разных перекрестках...
	if((SectionLength >= 2*BotLength) && ((St.CrossRoad == none) || (Fn.CrossRoad == none) || (St.CrossRoad != Fn.CrossRoad)))
	{
		ProcessedLength = 0;
		SectionRot = Normal(Fn.Location - St.Location);
		P.Rotation = rotator(SectionRot);
		P.firstPathNode = Fn;

		// добавляем первую точку с учётом Offset	
		P.Location = St.Location + (Offset+0.5*BotLength)*SectionRot;
		SpawnNodes.AddItem(P);
		ProcessedLength += Offset+0.5*BotLength;
	
		// пока можно добавлять новые точки и мы не вылезем за конечнуб точку отрезка
		while(ProcessedLength + BotLength < SectionLength)
		{
			P.Location += BotLength*SectionRot;
			ProcessedLength += BotLength;
			SpawnNodes.AddItem(P);
		}
	
		// формирование нового offset
		NewOffset = ProcessedLength + 0.5*BotLength - SectionLength;
	}

	Node.PathNode = Fn;
	Node.Offset = NewOffset;
	MorePathNodes.AddItem(Node);
	MorePathNodesLength++;
}

// Спаунит бота машину или человека, д.б. переписана дочерних классах
function SpawnBot(SpawnPoint P)
{
}

DefaultProperties
{
}