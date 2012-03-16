/** Класс точек для путей человека-бота. Проект "Город" */
class Gorod_HumanBotPathNode extends Gorod_BasePathNode;

/** ссылки на другие точки */
var() array<Gorod_HumanBotPathNode> NextPathNodes;
/** переменная, определяющая находится ли точка между левелами */
var() bool bIsBetweenLevels;
/** переменная, определяющая можно ли попасть из этой точки в другой левел */
var() bool bIsStart;
/** если переменная true, то в этой точке можно спавнить */
var() bool bCanSpawn;

/** ссылка на точку на другом левеле */
var Gorod_HumanBotPathNode LevelStreamingPathNode;

delegate nodeTouch(Actor a);

//срабатывает при загрузке level'a при levelstream'инге
simulated event PostBeginPlay()
{
	local Gorod_HumanBotPathNode OterPathnode;

	super.PostBeginPlay();
	//если в настройках указано, что Pathnode находится между подгружаемыми уровнями - ищем прилегающий Pathnode на другом уровне
	if(bIsBetweenLevels==true)
	{
		//сам поиск
		foreach CollidingActors(class'Gorod_HumanBotPathNode', OterPathnode, 270) 
		{
			//если нашли не себя, добавляем найденному Pathnod'у ссылку на себя
			if(OterPathnode != self)
			{
				OterPathnode.LevelStreamingPathNode = self;
				//если в настройках указано, что на Pathnod можно перейти с другого уровня - добавляем ссылку к себе на найденый Pathnod
				if(bIsStart)
					self.LevelStreamingPathNode = OterPathnode;
				break;
			}
		}
	}
	// для проверок
	//foreach NextPathNodes(OterPathnode)
	//{
	//	DrawDebugLine(Location, OterPathnode.Location, 255, 255, 0, true);
	//}
}
simulated function bool IsFreeForRelloc()
{
	local Gorod_HumanBot OtherBot;
	//проверяем, мешается есть ли бот рядом

	////////////////////
	local float Distance;
	// для проекта форссаж
	//local Gorod_PlayerController PC;
	local PlayerController PC;

	// проверяем, находится ли данная точка достаточно близко хотя бы к одному игроку
	// для проекта форсаж
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

	foreach CollidingActors(class'Gorod_HumanBot', OtherBot, 50) //45 чуть болше диаметра целиндра бота
	{
		//если находим другого бота - выходим
		return false;
	}
		//если ботов нет
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

/** Возвращает случайную следующую точку. Если указан LastPathNode, то он не возвращется */
simulated function Gorod_HumanBotPathNode GetNextPathNode(optional Gorod_HumanBotPathNode LastPathNode)
{
	local int randPathNode;
	local array<Gorod_HumanBotPathNode> TempPathNodes;
	local int i;
	//если задана последняя точка, то мы не должны ее вернуть
	if(LastPathNode!=none)
	{
		//копируем данные во временны массив
		for(i = 0; i < NextPathNodes.Length; i++)
		{
			if(NextPathNodes[i] != LastPathNode)
				TempPathNodes.AddItem(NextPathNodes[i]);

		}
		if(TempPathNodes.Length <= 0)
			return LastPathNode;
		//выбираем случайную точку
		randPathNode = rand(TempPathNodes.Length);
		if (TempPathNodes[randPathNode] != none)
			return TempPathNodes[randPathNode];
	}
	//иначе, просто выбираем случайную точку
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

/** Возвращает индекс случаного пути. Если указан LastPath, то его индекс не возвращается. Если путей ненайдено, возвращается -1 */
simulated function int GetNextPathIndex(optional Gorod_BasePath LastPath)
{
	local int randPath;
	local int i;
	local array<int> PathIndex;

	//если задана последняя точка, то мы не должны ее вернуть
	if(LastPath != none)
	{
		//копируем данные во временны массив
		for(i = 0; i <= Paths.Length-1; i++)
		{
			if(Paths[i] != LastPath)
				PathIndex.AddItem(i);
		}
		if(PathIndex.Length==0)
			return -1;
		//выбираем случайную точку
		randPath = rand(PathIndex.Length);
		return PathIndex[randPath];
	}
	//иначе, просто выбираем случайную точку
	else
	{
		//
		randPath = rand(Paths.Length);
		return randPath;
	}
}

/** Возвращает сслыки из точки, которые не принадлежат пути */
simulated function array<Gorod_HumanBotPathNode> GetNextNonPathPathNodes(optional Gorod_HumanBotPathNode LastPathNode)
{
	/** Временный массив для хранения точек, не принадлежащих пути */
	local array<Gorod_HumanBotPathNode> TempPathNodes;
	/** Временная точка */
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
