class Gorod_CrossRoadAutomated 
	extends Gorod_CrossRoad;

/**
 * Кол-во полос в одну сторону на дороге, расположенной вдоль направления Actor'а перекрёстка
 */
var() int ForwardLineNum;
/**
 * Ширина дороги, расположенной вдоль направления Actor'а перекрёстка
 */
var() float ForwardWidth;
/**
 * Кол-во полос в одну сторону на дороге, расположенной поперёк направления Actor'а перекрёстка
 */
var() int SideLineNum;
/**
 * Ширина дороги, расположенной поперёк направления Actor'а перекрёстка
 */
var() float SideWidth;

/**
 * Ширина одной полосы дороги
 */
var() const float RoadLineWidth;

/**
 * Смещение светофора, относительно границы перекрёстка
 */
var() const int TrafficLightOffset;

/**
 * Минимальный радиус поворота
 */
var() const int MinTurnRadius;

/**
 * Максимальная ширина машины
 */
var() const int MaxVehicleWidth;
/**
 * Отрезок, в доль которого раставляются маршрутные точки на перекрёстке при начальной расстановке точек
 */
struct Segment
{
	var Vector St;
	var Vector Fn;
	var array<bool> bIsDriveInNode;
	var() array<Gorod_AIVehicle_PathNode> PathNodes;
	var array<Gorod_BasePath> Paths;
	var Gorod_TrafficLight TrafficLight;
	var array<Gorod_CrossRoadsTrigger> Triggers;
};


var(Segments) Segment TopSegment;
var(Segments) Segment BottomSegment;
var(Segments) Segment LeftSegment;
var(Segments) Segment RightSegment;

/**
 * Единичные векторы направленные вдоль перекрёстка и перпендикулярно перекрёстку
 */
var Vector ForwardDirection, SideDirection;

var() float CarMaxSpeed;

simulated function PostBeginPlay()
{
	ForwardWidth = DrawScale3D.Y*ForwardWidth;
	SideWidth = DrawScale3D.X*SideWidth;

	// переводим в юниты в секунду
	CarMaxSpeed = 50*CarMaxSpeed/3.6;

	// убиваем все пути, если они есть
	Paths.Remove(0, Paths.Length);

	EvalCrossroadActors();

	// спауним триггеры и настраиваем для каждого из сегментов
	SpawnTriggers();

	// 
	ConnectTrafficLights();

	super.PostBeginPlay();
}

/**
 * Спауним всех акторов, которые нужны перекрёстку
 */
function EvalCrossroadActors()
{
	local Vector ForwardDistance, SideDistance;
	local Rotator Rot;

	ForwardDirection = Normal(Vector(self.Rotation));
	Rot.Yaw = self.Rotation.Yaw + 16384;
	SideDirection = Normal(Vector(Rot));

	//--------------------------------------------------
	// начальная расстановка точек
	
	// Рассчёт четырёх отрезков, соответствующих четырём сторонам перекрёстка
	ForwardDistance = (SideWidth/2 - RoadLineWidth/2)*ForwardDirection;
	SideDistance = (ForwardWidth/2 - RoadLineWidth/2)*SideDirection;

	// Расчёт начальных точек отрезков (они соответствуют четырём вершинам прямоугольника со сторонами ForwardWidth и SideWidth и центром с координатами self.Rotation)
	TopSegment.St = self.Location + ForwardDistance + SideDistance;
	BottomSegment.St = self.Location - ForwardDistance - SideDistance;	
	LeftSegment.St = self.Location + ForwardDistance - SideDistance;
	RightSegment.St = self.Location - ForwardDistance + SideDistance;

	// Расчёт конечных точек отрезков
	TopSegment.Fn = LeftSegment.St;
	LeftSegment.Fn = BottomSegment.St;
	BottomSegment.Fn = RightSegment.St;
	RightSegment.Fn = TopSegment.St;

	SearchSegmentPathNodes(TopSegment);
	SearchSegmentPathNodes(BottomSegment);
	SearchSegmentPathNodes(LeftSegment);
	SearchSegmentPathNodes(RightSegment);

	// для каждой точки каждого отрезка определяем, является ли она точкой въезда на перекрёсток
	// (для этого нужны два отрезка, лежащие друг напротив друга)
	SetDriveInNodes(BottomSegment, TopSegment, ForwardLineNum, ForwardDirection);
	SetDriveInNodes(LeftSegment, RightSegment, SideLineNum, SideDirection);

	// соединяем точки путями, позволяющими проехать перекрёсток прямо
	LinkStraight(BottomSegment, TopSegment, ForwardLineNum);
	LinkStraight(LeftSegment, RightSegment, SideLineNum);
	
	// соединяем точки путями, позволяющими на перекрёстке повернуть направо
	LinkForRightTurning(BottomSegment, RightSegment);
	LinkForRightTurning(RightSegment, TopSegment);
	LinkForRightTurning(TopSegment, LeftSegment);
	LinkForRightTurning(LeftSegment, BottomSegment);

	// соединяем точки путями, позволяющими на перекрёстке повернуть налево
	LinkForLeftTurning(BottomSegment, LeftSegment);
	LinkForLeftTurning(LeftSegment, TopSegment);
	LinkForLeftTurning(TopSegment, RightSegment);
	LinkForLeftTurning(RightSegment, BottomSegment);

	LinkTrafficLightWithPaths(TopSegment, TopTrafficLight);
	LinkTrafficLightWithPaths(BottomSegment, BottomTrafficLight);
	LinkTrafficLightWithPaths(LeftSegment, LeftTrafficLight);
	LinkTrafficLightWithPaths(RightSegment, RightTrafficLight);
}


function MoveSegment(Vector OffsetVector, out Segment seg)
{
	seg.St += OffsetVector;
	seg.Fn += OffsetVector;
}

function SetDriveInNodes(out Segment seg1, out Segment seg2, int LineNum, Vector BaseDirection)
{
	local int i;
	local int PathNodesLength;
	local Vector V;

	V.X = 1;
	V.Y = 0;
	V.Z = 0;

	PathNodesLength = seg1.PathNodes.Length;

	if(PathNodesLength > 0)
	{
		for(i = 0; i < LineNum; i++)
		{
			seg1.bIsDriveInNode[PathNodesLength-1-i] = true;
			seg1.PathNodes[PathNodesLength-1-i].SetRotation(Rotator(V));
		}
	}

	PathNodesLength = seg2.PathNodes.Length;

	if(PathNodesLength > 0)
	{
		for(i = LineNum; i < PathNodesLength; i++)
		{
			seg2.bIsDriveInNode[i] = true;
			seg2.PathNodes[i].SetRotation(Rotator(V));
		}
	}
}

/**
 * Соединяем точки на отрезках seg1 и seg2, исходя из ForwardLineNum и SideLineNum. Отрезки д.б. указаны в порядке
 * соответствующем движению вдоль основного направления движения ("снизу вверх" или "справа на лево")
 */
function LinkStraight(out Segment seg1, out Segment seg2, int LineNum)
{
	local int i;
	local int PathNodesLength;
	local Gorod_BasePath BP;

	if(seg1.PathNodes.Length > 0 && seg2.PathNodes.Length > 0)
	{
		PathNodesLength = Min(seg1.PathNodes.Length, seg2.PathNodes.Length);

		for(i = 0; i < LineNum; i++)
		{
			// если из текущей точки нельзя ехать прямо, то пропускаем её
			if(!seg1.PathNodes[PathNodesLength-1-i].bCanDriveForward)
				continue;

			seg1.PathNodes[PathNodesLength-1-i].NextPathNodes.AddItem(seg2.PathNodes[i]);
		
			// спауним соответствующий прямой путь
			BP = Spawn(class'Gorod_BasePath', , , seg1.PathNodes[PathNodesLength-1-i].Location, self.Rotation);
			if(BP != none)
			{
				BP.PathNodes.AddItem(seg1.PathNodes[PathNodesLength-1-i]);
				BP.PathNodes.AddItem(seg2.PathNodes[i]);
				BP.RegCrossRoad(self);
				Paths.AddItem(BP);
				seg1.Paths.AddItem(BP);
			}
		}

		for(i = LineNum; i < PathNodesLength; i++)
		{
			// если из текущей точки нельзя ехать прямо, то пропускаем её
			if(!seg2.PathNodes[i].bCanDriveForward)
				continue;

			seg2.PathNodes[i].NextPathNodes.AddItem(seg1.PathNodes[PathNodesLength-1-i]);

			BP = Spawn(class'Gorod_BasePath', , , seg2.PathNodes[i].Location, self.Rotation);
			if(BP != none)
			{
				BP.PathNodes.AddItem(seg2.PathNodes[i]);
				BP.PathNodes.AddItem(seg1.PathNodes[PathNodesLength-1-i]);
				BP.RegCrossRoad(self);
				Paths.AddItem(BP);
				seg2.Paths.AddItem(BP);
			}
		}
	}
}


/**
 * Соединяем точки путями, позволяющими на перекрёстке повернуть направо. seg1 и seg2 должны идти в порядке,
 * соответствующем направлению проезда перекрёстка. Подразумевается, что поворачивать направо можно только
 * из крайнего правого ряда в правый же краиний ряд
 */
function LinkForRightTurning(out Segment seg1, out Segment seg2)
{
	local Vector CrossPoint, CornerPoint, Seg1Vector, Seg2Vector, Center;
	local float TurnMultiplier;
	local Gorod_BasePath BP;
	local Gorod_AIVehicle_PathNode PN;
	local int i;
	local array<Vector> MiddlePoints;
	local Vector v;
	
	// индекс точки в seg1.PathNodes, которая является первой точкой поворота
	local int DriveInIndex;
	// индекс точки в seg2.PathNodes, которая является последней точкой поворота
	local int DriveOutIndex;

	DriveInIndex = seg1.PathNodes.Length-1;
	DriveOutIndex = 0;

	// если в обоих отрезках есть точки И
	// последняя точка первого отрезка является точкой въезда на перекрёсток И первая точка второго отрезка не является точкой въезда на перекрёсток И
	// у последней точки первого отрезка стоит флаг, разрешающий поворот направо
	if(seg1.PathNodes.Length > 0 && seg2.PathNodes.Length > 0 &&
		seg1.bIsDriveInNode[seg1.bIsDriveInNode.Length-1] && !seg2.bIsDriveInNode[0] &&
		seg1.PathNodes[seg1.bIsDriveInNode.Length-1].bCanTurnRight)
	{		
		// спауним криволинейный путь
		BP = Spawn(class'Gorod_BasePath', , , seg1.PathNodes[DriveInIndex].Location + vect(0, 0, 100), self.Rotation);
		if(BP != none)
		{
			BP.PathTurnType = PDR_Right;

			BP.PathNodes.AddItem(seg1.PathNodes[DriveInIndex]);

			// расчитываем и спауним дополнительные маршрутные точки
			PathSectionCross(seg1.St, seg1.Fn, seg2.St, seg2.Fn, CrossPoint);

			PointDistToSegment(seg1.PathNodes[DriveInIndex].Location, seg1.St, seg1.Fn, Seg1Vector);
			PointDistToSegment(seg2.PathNodes[DriveOutIndex].Location, seg2.St, seg2.Fn, Seg2Vector);

			CornerPoint = Seg1Vector + Seg2Vector - CrossPoint;

			TurnMultiplier = (MinTurnRadius - MaxVehicleWidth/2) / VSize(CrossPoint - CornerPoint);

			Center = CornerPoint + TurnMultiplier*(CrossPoint-CornerPoint);
			Center.Z = seg1.PathNodes[DriveInIndex].Location.Z;

			EvalMiddlePoints(   Center,
								TurnMultiplier*VSize(Seg1Vector - CrossPoint),
								TurnMultiplier*VSize(Seg2Vector - CrossPoint),
								3,
								(CrossPoint - Seg1Vector),
								MiddlePoints);

			foreach MiddlePoints(v)
			{
				PN = Spawn(class'Gorod_AIVehicle_PathNode', , , v, self.Rotation, , true);
				if(PN != none)
				{
					BP.PathNodes.AddItem(PN);
					PN.CarMaxSpeed = CarMaxSpeed;
				}
				else
				{
					`warn("Failed to spawn path node. CrossRoad:" @ self.Name @ "Path:" @ BP.Name);
				}
			}
			
			BP.PathNodes.AddItem(seg2.PathNodes[0]);

			// настраиваем связи между маршрутными точками пути
			for(i = 0; i < BP.PathNodes.Length - 1; i++)
			{
				Gorod_AIVehicle_PathNode(BP.PathNodes[i]).NextPathNodes.AddItem(Gorod_AIVehicle_PathNode(BP.PathNodes[i+1]));
			}

			BP.RegCrossRoad(self);
			Paths.AddItem(BP);
			seg1.Paths.AddItem(BP);
		}
		else
		{
			`warn("Failed to spawn path. CrossRoad:" @ self.Name);
		}
	}
}


function LinkForLeftTurning(Segment seg1, Segment seg2)
{
	local Vector CrossPoint, CornerPoint, Seg1Vector, Seg2Vector, Center;
	local float TurnMultiplier;
	local Gorod_BasePath BP;
	local Gorod_AIVehicle_PathNode PN;
	local int i;
	local array<Vector> MiddlePoints;

	// индекс точки в seg1.PathNodes, которая является первой точкой поворота
	local int DriveInIndex;
	// индекс точки в seg2.PathNodes, которая является последней точкой поворота
	local int DriveOutIndex;

	// если хотя бы в одном отрезке нет точек - ничего не делаем
	if(seg1.PathNodes.Length == 0 || seg2.PathNodes.Length == 0)
		return;

	// находим точки, которые будем соединять (это точки на крайних левых полосах обоих отрезков)
	// точка, являющаяся точкой въезда на перекрёсток с наименьшим индексом
	DriveInIndex = INDEX_NONE;
	for(i = seg1.PathNodes.Length - 1; i >= 0; i--)
	{
		if(seg1.bIsDriveInNode[i])
			DriveInIndex = i;
	}

	// точка, являющаяся точкой выезда с перекрёстка с наибольшим индексом
	DriveOutIndex = INDEX_NONE;
	for(i = 0; i < seg2.PathNodes.Length; i++)
	{
		if(!seg2.bIsDriveInNode[i])
			DriveOutIndex = i;
	}

	// если найдены первая и последняя точки для поворота И
	// у первой точки поворота стоит флаг, разрешающий поворот налево
	if(	DriveInIndex != INDEX_NONE && DriveOutIndex != INDEX_NONE &&
		seg1.PathNodes[DriveInIndex].bCanTurnLeft)
	{		
		// спауним криволинейный путь
		BP = Spawn(class'Gorod_BasePath', , , seg1.PathNodes[DriveInIndex].Location + vect(0, 0, 100), self.Rotation);
		if(BP != none)
		{
			BP.PathTurnType = PDR_Left;

			BP.PathNodes.AddItem(seg1.PathNodes[DriveInIndex]);

			// расчитываем и спауним дополнительные маршрутные точки
			PathSectionCross(seg1.St, seg1.Fn, seg2.St, seg2.Fn, CrossPoint);

			PointDistToSegment(seg1.PathNodes[DriveInIndex].Location, seg1.St, seg1.Fn, Seg1Vector);
			PointDistToSegment(seg2.PathNodes[DriveOutIndex].Location, seg2.St, seg2.Fn, Seg2Vector);

			CornerPoint = Seg1Vector + Seg2Vector - CrossPoint;


			TurnMultiplier = (MinTurnRadius - MaxVehicleWidth/2) / VSize(CrossPoint - CornerPoint);

			Center = CornerPoint + TurnMultiplier*(CrossPoint-CornerPoint);
			Center.Z = seg1.PathNodes[DriveInIndex].Location.Z;

			EvalMiddlePoints(   Center,
								TurnMultiplier*VSize(Seg2Vector - CrossPoint),
								TurnMultiplier*VSize(Seg1Vector - CrossPoint),
								3,
								(CrossPoint - Seg2Vector),
								MiddlePoints);

			for(i = MiddlePoints.Length - 1; i >= 0; i--)
			{
				PN = Spawn(class'Gorod_AIVehicle_PathNode', , , MiddlePoints[i], self.Rotation, , true);
				if(PN != none)
				{
					BP.PathNodes.AddItem(PN);
					PN.CarMaxSpeed = CarMaxSpeed;
				}
				else
				{
					`warn("Failed to spawn path node. CrossRoad:" @ self.Name @ "Path:" @ BP.Name);
				}
			}
			
			BP.PathNodes.AddItem(seg2.PathNodes[DriveOutIndex]);

			// настраиваем связи между маршрутными точками пути
			for(i = 0; i < BP.PathNodes.Length - 1; i++)
			{
				Gorod_AIVehicle_PathNode(BP.PathNodes[i]).NextPathNodes.AddItem(Gorod_AIVehicle_PathNode(BP.PathNodes[i+1]));
			}

			BP.RegCrossRoad(self);
			Paths.AddItem(BP);
			seg1.Paths.AddItem(BP);
		}
		else
		{
			`warn("Failed to spawn path. CrossRoad:" @ self.Name);
		}
	}
}

/**
 * Ищем точки для каждого из отрезков
 */
function SearchSegmentPathNodes(out Segment seg)
{
	local Actor Act;
	local Gorod_AIVehicle_PathNode PN;
	local Gorod_BasePathNode BPN;
	local Gorod_BasePath BP;
	local Vector HitLoc, HitNorm, TraceExtent;

	TraceExtent.X = RoadLineWidth/2;
	TraceExtent.Y = RoadLineWidth/2;
	TraceExtent.Z = 300;

	foreach TraceActors(class'Actor', Act, HitLoc, HitNorm, seg.Fn, seg.St, TraceExtent)
	{
		PN = Gorod_AIVehicle_PathNode(Act);
		if((PN != none) && (seg.PathNodes.Find(PN) == INDEX_NONE))
		{
			seg.PathNodes.AddItem(PN);
			seg.bIsDriveInNode.AddItem(false);
			PN.CarMaxSpeed = CarMaxSpeed;
		}
		
		BP = Gorod_BasePath(Act);
		if((BP != none) && (seg.Paths.Find(BP) == INDEX_NONE))
		{
			BP.RegCrossRoad(self);
			Paths.AddItem(BP);
			seg.Paths.AddItem(BP);
			foreach BP.PathNodes(BPN)
			{
				PN = Gorod_AIVehicle_PathNode(BPN);
				if(PN != none)
				{
					PN.CarMaxSpeed = CarMaxSpeed;
				}
			}
			
		}
	}
}

/**
 * Устанавливает ссылки на пути для светофоров
 */
function LinkTrafficLightWithPaths(out Segment seg, Gorod_TrafficLight trafficLight)
{
	local Gorod_BasePath pth;
	local Gorod_AIVehicle_PathNode PN;

	if(trafficLight != none)
	{
		foreach seg.Paths(pth)
		{
			// проверка на то, что в пути есть хотя бы одна точка
			if(pth.PathNodes.Length == 0)
				continue;

			// Получаем Gorod_AIVehicle_PathNode из пути (если это возможно)
			PN = Gorod_AIVehicle_PathNode(pth.PathNodes[0]);

			// если в пути содержатся точки не для ботов-машин, то привязываем путь к светофор,
			// не думая о секциях
			if(PN == none)
			{
				trafficLight.Paths.AddItem(pth);
			}
			else
			{
				// иначе, думаем о секциях на основании флагов у первой точки пути

				// если нужная секция вкдючена и установлен флаг, то привязываем путь к соответствующей секции,
				// иначе - к светофору
				if(trafficLight.LeftSection.On && PN.bControlByLeftSection)
				{
					trafficLight.LeftSection.Paths.AddItem(pth);
				}
				else if(trafficLight.RightSection.On && PN.bControlByRightSection)
				{
					trafficLight.RightSection.Paths.AddItem(pth);
				}
				else
				{
					trafficLight.Paths.AddItem(pth);
				}
			}
		}
	}
}

/**
 * Вычисляет N точек, лежащих на дуги эллипса от Pi до 3*Pi/2. CrossPoint - центр эллипса. A, B - полуоси.
 * Выполняет поворот всех точек в соответствии с вектором Dir.
 * MiddlePoints - список полученных точек.
 */
function EvalMiddlePoints(Vector CrossPoint, float A, float B, int N, Vector Dir, out array<Vector> MiddlePoints)
{
	local int i;
	local float Ti, Pi2, PiN;
	local Vector Loc;
	local Rotator rot;

	Pi2 = Pi/2;
	PiN = Pi2/(N+1);

	for(i = 0; i <= N+1; i++)
	{
		Ti = Pi + PiN*i;

		Loc.X = A*Cos(Ti);
		Loc.Y = B*Sin(Ti);

		rot = Rotator(Dir);
		Loc = Loc >> Rot;

		Loc += CrossPoint;
		Loc.Z = CrossPoint.Z;

		MiddlePoints.AddItem(Loc);
	}
}

function DrawDebugInfo(Segment seg)
{
	DrawDebugSphere(seg.St, 10, 16, 0, 0, 255, true);
	DrawDebugSphere(seg.Fn, 5, 8, 0, 0, 255, true);
}

function SpawnTriggers()
{
	local Gorod_AIVehicle_PathNode BPN;
	local Gorod_CrossRoadsTrigger trg, trg2;
	local Rotator   rot;
	local TriggerReference trgRef;
	local int tmpCount, i, tmpCount2, z;
	
	rot.Yaw = 8192 * 2;     // 90 degr

	// спауним триггеры в точках входа и выхода
	// TOP
	foreach self.TopSegment.PathNodes(BPN)
	{
		trg = Spawn(class'Gorod_CrossRoadsTrigger', , , BPN.Location , BPN.bManualRotation ? BPN.Rotation : (Rotation + rot));
		trg.bCanTurnRight = BPN.bCanTurnRight;
		trg.bCanTurnLeft = BPN.bCanTurnLeft;
		trg.bCanTurnLeftFromInternalSide = BPN.bCanTurnLeftFromInternalSide;
		trg.bCanTurnRightFromInternalSide = BPN.bCanTurnRightFromInternalSide;
		trg.bCanTurnReverse = BPN.bCanTurnReverse;
		trg.bCanTurnReverseFromInternalSide = BPN.bCanTurnReverseFromInternalSide;
		trg.bCanDriveForward = BPN.bCanDriveForward;
		trg.bControlByLeftSection = BPN.bControlByLeftSection;
		trg.bControlByRightSection = BPN.bControlByRightSection;

		TopSegment.Triggers.AddItem(trg);
		self.Triggers.AddItem(trg);
		trg = none;
	}

	// BOTTOM
	foreach self.BottomSegment.PathNodes(BPN)
	{
		trg = Spawn(class'Gorod_CrossRoadsTrigger', , , BPN.Location , BPN.bManualRotation ? BPN.Rotation : (Rotation + rot));
		trg.bCanTurnRight = BPN.bCanTurnRight;
		trg.bCanTurnLeft = BPN.bCanTurnLeft;
		trg.bCanTurnLeftFromInternalSide = BPN.bCanTurnLeftFromInternalSide;
		trg.bCanTurnRightFromInternalSide = BPN.bCanTurnRightFromInternalSide;
		trg.bCanTurnReverse = BPN.bCanTurnReverse;
		trg.bCanTurnReverseFromInternalSide = BPN.bCanTurnReverseFromInternalSide;
		trg.bCanDriveForward = BPN.bCanDriveForward;
		trg.bControlByLeftSection = BPN.bControlByLeftSection;
		trg.bControlByRightSection = BPN.bControlByRightSection;

		self.Triggers.AddItem(trg);
		BottomSegment.Triggers.AddItem(trg);
		trg = none;
	}

	// LEFT
	foreach self.LeftSegment.PathNodes(BPN)
	{
		trg = Spawn(class'Gorod_CrossRoadsTrigger', , , BPN.Location , BPN.bManualRotation ? BPN.Rotation : (Rotation));
		trg.bCanTurnRight = BPN.bCanTurnRight;
		trg.bCanTurnLeft = BPN.bCanTurnLeft;
		trg.bCanTurnLeftFromInternalSide = BPN.bCanTurnLeftFromInternalSide;
		trg.bCanTurnRightFromInternalSide = BPN.bCanTurnRightFromInternalSide;
		trg.bCanTurnReverse = BPN.bCanTurnReverse;
		trg.bCanTurnReverseFromInternalSide = BPN.bCanTurnReverseFromInternalSide;
		trg.bCanDriveForward = BPN.bCanDriveForward;
		trg.bControlByLeftSection = BPN.bControlByLeftSection;
		trg.bControlByRightSection = BPN.bControlByRightSection;

		self.Triggers.AddItem(trg);
		LeftSegment.Triggers.AddItem(trg);
		trg = none;
		
	}

	// RIGHT
	foreach self.RightSegment.PathNodes(BPN)
	{
		trg = Spawn(class'Gorod_CrossRoadsTrigger', , , BPN.Location , BPN.bManualRotation ? BPN.Rotation : (Rotation));
		trg.bCanTurnRight = BPN.bCanTurnRight;
		trg.bCanTurnLeft = BPN.bCanTurnLeft;
		trg.bCanTurnLeftFromInternalSide = BPN.bCanTurnLeftFromInternalSide;
		trg.bCanTurnRightFromInternalSide = BPN.bCanTurnRightFromInternalSide;
		trg.bCanTurnReverse = BPN.bCanTurnReverse;
		trg.bCanTurnReverseFromInternalSide = BPN.bCanTurnReverseFromInternalSide;
		trg.bCanDriveForward = BPN.bCanDriveForward;
		trg.bControlByLeftSection = BPN.bControlByLeftSection;
		trg.bControlByRightSection = BPN.bControlByRightSection;

		self.Triggers.AddItem(trg);
		RightSegment.Triggers.AddItem(trg);
		trg = none;
	}

	// TOP ========================================================================================================================================================================================================
	i = 0;
	tmpCount = TopSegment.Triggers.Length;
	foreach TopSegment.Triggers(trg)
	{
		// проверяем, является ли триггер "Входным"
		if(i >= tmpCount - ForwardLineNum)
		{
			// устанавливаем триггер как "Входной"
			trg.trType = TRIGGERTYPE_ENTRY;

			// ищем триггеры в нижнем сегменте (только если разрешен проезд вперед)
			if(trg.bCanDriveForward == true)
			{
				tmpCount2 = BottomSegment.Triggers.Length;
				z = 0;

				foreach BottomSegment.Triggers(trg2)
				{
					// если сортируемый триггер является противоположным (начиная от нулевого до ForwardLineNum - 1, не включая), включаем его в список правильных триггеров
					if(z < tmpCount2 - ForwardLineNum)
					{
						trgRef.triggerRef = trg2;
						//trgRef.Message = "[Message from AutomatedCR]: CORRECT - you drive in FORWARD direction";
						trgRef.MessageID = 3022;
						trg.CorrectTriggers.AddItem(trgRef);
					}

					// если нет - то в список неправильных
					else
					{
						trgRef.triggerRef = trg2;
						//trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in FORWARD direction";

						trgRef.MessageID = 3023;
						trgRef.bShowMessageInHUD = true;
						trg.IncorrectTriggers.AddItem(trgRef);
					}

					z++;
				}
			}
			else
			{ // проезд вперед запрещен настройками точки вьезда
				foreach BottomSegment.Triggers(trg2)
				{
					trgRef.triggerRef = trg2;
					trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in FORWARD direction while it disabled";
					trgRef.MessageID = 3024;
					trgRef.bShowMessageInHUD = true;
					trg.IncorrectTriggers.AddItem(trgRef);
				}
			}

			//----------------------------------------------------------------------------------------------------------------------------------------------------------------------
			// ищем триггеры в правом сегменте (слева относительно верхнего сегмента)

			// если триггер является первым в сегменте (считая смещение ForwardLineNum), то он предназначен для поворота налево
			if(i == tmpCount - ForwardLineNum)
			{
				if(trg.bCanTurnLeft == true)
				{
					tmpCount2 = RightSegment.Triggers.Length;
					z = 0;

					foreach RightSegment.Triggers(trg2)
					{
						// если сортируемый триггер является противоположным (начиная от нулевого до SideLineNum - 1, не включая), включаем его в список правильных триггеров
						if(z < tmpCount2 - SideLineNum)
						{
							trgRef.triggerRef = trg2;
							trgRef.Message = "[Message from AutomatedCR]: CORRECT - you drive in LEFT direction";
							trgRef.MessageID = 3025;
							trgRef.bShowMessageInHUD = true;
							trg.CorrectTriggers.AddItem(trgRef);
						}

						// если нет - то в список НЕправильных
						else
						{
							trgRef.triggerRef = trg2;
							trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in LEFT direction";
							trgRef.MessageID = 3026;
							trgRef.bShowMessageInHUD = true;
							trg.IncorrectTriggers.AddItem(trgRef);
						}

						z++;
					}
				} // if can turn left
				else
				{ // проезд направо запрещен настройками точки вьезда
					foreach RightSegment.Triggers(trg2)
					{
						trgRef.triggerRef = trg2;
						trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in LEFT direction while it disabled";
						trgRef.MessageID = 3027;
						trgRef.bShowMessageInHUD = true;
						trg.IncorrectTriggers.AddItem(trgRef);
					}
				}

				//===============
				if(trg.bCanTurnReverse)
				{
					tmpCount2 = TopSegment.Triggers.Length;
					z = 0;
		
					foreach TopSegment.Triggers(trg2)
					{
						// если сортируемый триггер является реверсивным (для разворота) (начиная от нулевого до ForwardLineNum - 1, не включая), включаем его в список правильных триггеров
						if(z < tmpCount2 - ForwardLineNum)
						{
							trgRef.triggerRef = trg2;
							trgRef.Message = "[Message from AutomatedCR]: CORRECT - you drive in REVERSE direction";
							trgRef.MessageID = 3033;
							trgRef.bShowMessageInHUD = true;
							trg.CorrectTriggers.AddItem(trgRef);
						}

						// если нет - то в список неправильных
						else
						{
							trgRef.triggerRef = trg2;
							trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in REVERSE direction";
							trgRef.MessageID = 3034;
							trgRef.bShowMessageInHUD = true;
							trg.IncorrectTriggers.AddItem(trgRef);
						}

						z++;
					}
				} // end if can turn reverse
				else
				{ // разворот запрещен настройками точки въезда
					foreach TopSegment.Triggers(trg2)
					{
						trgRef.triggerRef = trg2;
						trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in REVERSE direction while it disabled";
						trgRef.MessageID = 3035;
						trgRef.bShowMessageInHUD = true;
						trg.IncorrectTriggers.AddItem(trgRef);
					}
				}
			} // если крайняя левая

			// точка является внутренней
			else
			{
				if(trg.bCanTurnLeftFromInternalSide == true)
				{
					tmpCount2 = RightSegment.Triggers.Length;
					z = 0;

					foreach RightSegment.Triggers(trg2)
					{
						// если сортируемый триггер является противоположным (начиная от нулевого до SideLineNum - 1, не включая), включаем его в список правильных триггеров
						if(z < tmpCount2 - SideLineNum)
						{
							trgRef.triggerRef = trg2;
							trgRef.Message = "[Message from AutomatedCR]: CORRECT - you drive in LEFT direction";
							trgRef.MessageID = 3025;
							trgRef.bShowMessageInHUD = true;

							trg.CorrectTriggers.AddItem(trgRef);
						}

						// если нет - то в список НЕправильных
						else
						{
							trgRef.triggerRef = trg2;
							trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in LEFT direction";
							trgRef.MessageID = 3026;
							trgRef.bShowMessageInHUD = true;
							trg.IncorrectTriggers.AddItem(trgRef);
						}

						z++;
					}
				}
				else
				{ // поворот налево из внутренней точки запрещен настройками триггера
					foreach RightSegment.Triggers(trg2)
					{
						trgRef.triggerRef = trg2;
						trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in LEFT direction from internal entry point while it disabled";
						trgRef.MessageID = 3028;
						trgRef.bShowMessageInHUD = true;
						trg.IncorrectTriggers.AddItem(trgRef);
					}
				}

				if(trg.bCanTurnReverseFromInternalSide)
				{
					tmpCount2 = TopSegment.Triggers.Length;
					z = 0;
		
					foreach TopSegment.Triggers(trg2)
					{
						// если сортируемый триггер является реверсивным (для разворота) (начиная от нулевого до ForwardLineNum - 1, не включая), включаем его в список правильных триггеров
						if(z < tmpCount2 - ForwardLineNum)
						{
							trgRef.triggerRef = trg2;
							trgRef.Message = "[Message from AutomatedCR]: CORRECT - you drive in REVERSE direction";
							trgRef.MessageID = 3033;
							trgRef.bShowMessageInHUD = true;
							trg.CorrectTriggers.AddItem(trgRef);
						}

						// если нет - то в список неправильных
						else
						{
							trgRef.triggerRef = trg2;
							trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in REVERSE direction";
							trgRef.MessageID = 3034;
							trgRef.bShowMessageInHUD = true;
							trg.IncorrectTriggers.AddItem(trgRef);
						}

						z++;
					}
				}
				else
				{ // разворот из внутренней точки запрещен настройками триггера
					foreach TopSegment.Triggers(trg2)
					{
						trgRef.triggerRef = trg2;
						trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in REVERSE direction while it disabled";
						trgRef.MessageID = 3035;
						trgRef.bShowMessageInHUD = true;
						trg.IncorrectTriggers.AddItem(trgRef);
					}
				}
			}  // END TOP TO LEFT CONNECTION (RIGHT SEGMENT)
			//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

			// если триггер является последним в сегменте, то он является крайним справа
			if(i == tmpCount - 1)
			{
				if(trg.bCanTurnRight)
				{
					// ищем триггеры в левом сегменте (справа относительно верхнего сегмента)
					tmpCount2 = LeftSegment.Triggers.Length;
					z = 0;

					foreach LeftSegment.Triggers(trg2)
					{
						// если сортируемый триггер является противоположным (начиная от нулевого до SideLineNum - 1, не включая), включаем его в список правильных триггеров
						if(z < tmpCount2 - SideLineNum)
						{
							trgRef.triggerRef = trg2;
							trgRef.Message = "[Message from AutomatedCR]: CORRECT - you drive in RIGHT direction";
							trgRef.MessageID = 3029;
							trgRef.bShowMessageInHUD = true;
							trg.CorrectTriggers.AddItem(trgRef);
						}

						// если нет - то в список НЕправильных
						else
						{
							trgRef.triggerRef = trg2;
							trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in RIGHT direction";
							trgRef.MessageID = 3030;
							trgRef.bShowMessageInHUD = true;
							trg.IncorrectTriggers.AddItem(trgRef);
						}

						z++;
					}
				}
				// поворот направо запрещен настройками точки въезда
				else
				{
					foreach LeftSegment.Triggers(trg2)
					{
						trgRef.triggerRef = trg2;
						trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in RIGHT direction while it disabled";
						trgRef.MessageID = 3031;
						trgRef.bShowMessageInHUD = true;
						trg.IncorrectTriggers.AddItem(trgRef);
					}
				}
			}
			// если нет, то точка является внутренней
			else
			{
				if(trg.bCanTurnRightFromInternalSide == true)
				{
					// ищем триггеры в левом сегменте (справа относительно верхнего сегмента)
					tmpCount2 = LeftSegment.Triggers.Length;
					z = 0;

					foreach LeftSegment.Triggers(trg2)
					{
						// если сортируемый триггер является противоположным (начиная от нулевого до SideLineNum - 1, не включая), включаем его в список правильных триггеров
						if(z < tmpCount2 - SideLineNum)
						{
							trgRef.triggerRef = trg2;
							trgRef.Message = "[Message from AutomatedCR]: CORRECT - you drive in RIGHT direction";
							trgRef.MessageID = 3029;
							trgRef.bShowMessageInHUD = true;
							trg.CorrectTriggers.AddItem(trgRef);
						}

						// если нет - то в список НЕправильных
						else
						{
							trgRef.triggerRef = trg2;
							trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in RIGHT direction";
							trgRef.MessageID = 3030;
							trgRef.bShowMessageInHUD = true;
							trg.IncorrectTriggers.AddItem(trgRef);
						}

						z++;
					}
				}
				// поворот направо из внутренней точки запрещен настройками точки въезда
				else
				{
					foreach LeftSegment.Triggers(trg2)
					{
						trgRef.triggerRef = trg2;
						trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in RIGHT direction form internal entry point while it disabled";
						trgRef.MessageID = 3032;
						trgRef.bShowMessageInHUD = true;
						trg.IncorrectTriggers.AddItem(trgRef);
					}
				}
			}
			//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		}

		i++;
	}

	// BOTTOM ====================================================================================================================================================================================================
	i = 0;
	tmpCount = BottomSegment.Triggers.Length;
	foreach BottomSegment.Triggers(trg)
	{
		//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		// обрабатываем только триггеры точек вьезда
		if(i >= tmpCount - ForwardLineNum)
		{
			// устанавливаем триггер как "Входной"
			trg.trType = TRIGGERTYPE_ENTRY;

			if(trg.bCanDriveForward == true)
			{
				// ищем триггеры в верхнем сегменте
				tmpCount2 = TopSegment.Triggers.Length;
				z = 0;
			
				foreach TopSegment.Triggers(trg2)
				{
					// если сортируемый триггер является противоположным (начиная от нулевого до ForwardLineNum - 1, не включая), включаем его в список правильных триггеров
					if(z < tmpCount2 - ForwardLineNum)
					{
						trgRef.triggerRef = trg2;
						trgRef.Message = "[Message from AutomatedCR]: CORRECT - you drive in forward direction";
						trgRef.MessageID = 3022;
						trgRef.bShowMessageInHUD = true;
						trg.CorrectTriggers.AddItem(trgRef);
					}

					// если нет - то в список неправильных
					else
					{
						trgRef.triggerRef = trg2;
						trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in forward direction";
						trgRef.MessageID = 3023;
						trgRef.bShowMessageInHUD = true;
						trg.IncorrectTriggers.AddItem(trgRef);
					}

					z++;
				}
			}
			else
			{
				foreach TopSegment.Triggers(trg2)
				{
					trgRef.triggerRef = trg2;
					trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in FORWARD direction while it disabled";
					trgRef.MessageID = 3024;
					trgRef.bShowMessageInHUD = true;
					trg.IncorrectTriggers.AddItem(trgRef);
				}
			}
			
			//----------------------------------------------------------------------------------------------------------------------------------------------------------------- BOTTOM - RIGHT
			// ищем триггеры в правом сегменте

			// если точка является крайней справа
			if(i == tmpCount - 1)
			{
				if(trg.bCanTurnRight == true)
				{
					tmpCount2 = RightSegment.Triggers.Length;
					z = 0;

					foreach RightSegment.Triggers(trg2)
					{
						// если сортируемый триггер является противоположным (начиная от нулевого до SideLineNum - 1, не включая), включаем его в список правильных триггеров
						if(z < tmpCount2 - SideLineNum)
						{
							trgRef.triggerRef = trg2;
							trgRef.Message = "[Message from AutomatedCR]: CORRECT - you drive in right direction";
							trgRef.MessageID = 3029;
							trgRef.bShowMessageInHUD = true;
							trg.CorrectTriggers.AddItem(trgRef);
						}

						// если нет - то в список НЕправильных
						else
						{
							trgRef.triggerRef = trg2;
							trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in right direction";
							trgRef.MessageID = 3030;
							trgRef.bShowMessageInHUD = true;
							trg.IncorrectTriggers.AddItem(trgRef);
						}

						z++;
					}
				}
				// поворот направо запрещен настройками триггера
				else
				{
					foreach RightSegment.Triggers(trg2)
					{
						trgRef.triggerRef = trg2;
						trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in right direction while it disabled";
						trgRef.MessageID = 3031;
						trgRef.bShowMessageInHUD = true;
						trg.IncorrectTriggers.AddItem(trgRef);
					}
				}
			}
			// иначе - точка является внутренней относительно поворота направо
			else
			{
				if(trg.bCanTurnRightFromInternalSide == true)
				{
					tmpCount2 = RightSegment.Triggers.Length;
					z = 0;

					foreach RightSegment.Triggers(trg2)
					{
						// если сортируемый триггер является противоположным (начиная от нулевого до SideLineNum - 1, не включая), включаем его в список правильных триггеров
						if(z < tmpCount2 - SideLineNum)
						{
							trgRef.triggerRef = trg2;
							trgRef.Message = "[Message from AutomatedCR]: CORRECT - you drive in RIGHT direction";
							trgRef.MessageID = 3029;
							trgRef.bShowMessageInHUD = true;
							trg.CorrectTriggers.AddItem(trgRef);
						}

						// если нет - то в список НЕправильных
						else
						{
							trgRef.triggerRef = trg2;
							trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in RIGHT direction";
							trgRef.MessageID = 3030;
							trgRef.bShowMessageInHUD = true;
							trg.IncorrectTriggers.AddItem(trgRef);
						}

						z++;
					}
				}
				// поворот направо из внутренней точки запрещен настройками триггера
				else
				{
					foreach RightSegment.Triggers(trg2)
					{
						trgRef.triggerRef = trg2;
						trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in RIGHT direction from internal point while it disabled";
						trgRef.MessageID = 3032;
						trgRef.bShowMessageInHUD = true;
						trg.IncorrectTriggers.AddItem(trgRef);
					}
				}
			}

			//----------------------------------------------------------------------------------------------------------------------------------------------------------------- BOTTOM - LEFT
			// ищем триггеры в левом сегменте

			// если точка является крайней левой
			if(i == tmpCount - ForwardLineNum)
			{
				if(trg.bCanTurnLeft == true)
				{
					TriggerConnectToLeftSegment(trg);
				}
				// поворот налево запрещен настройками точкой вьезда
				else
				{
					foreach LeftSegment.Triggers(trg2)
					{
						trgRef.triggerRef = trg2;
						trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in left direction while it disabled";
						trgRef.MessageID = 3026;
						trgRef.bShowMessageInHUD = true;
						trg.IncorrectTriggers.AddItem(trgRef);
					}
				}


				if(trg.bCanTurnReverse)
				{
					// ищем триггеры в нижнем сегменте (текущий сегмент)
					tmpCount2 = BottomSegment.Triggers.Length;
					z = 0;
		
					foreach BottomSegment.Triggers(trg2)
					{
						// если сортируемый триггер является реверсивным (для разворота) (начиная от нулевого до ForwardLineNum - 1, не включая), включаем его в список правильных триггеров
						if(z < tmpCount2 - ForwardLineNum)
						{
							trgRef.triggerRef = trg2;
							trgRef.Message = "[Message from AutomatedCR]: CORRECT - you drive in REVERSE direction";
							trgRef.MessageID = 3033;
							trgRef.bShowMessageInHUD = true;
							trg.CorrectTriggers.AddItem(trgRef);
						}

						// если нет - то в список неправильных
						else
						{
							trgRef.MessageID = 3034;
							trgRef.bShowMessageInHUD = true;
							trgRef.triggerRef = trg2;
							trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in REVERSE direction";
							trg.IncorrectTriggers.AddItem(trgRef);
						}

						z++;
					}
				}
				else
				{
					foreach BottomSegment.Triggers(trg2)
					{
						trgRef.triggerRef = trg2;
						trgRef.MessageID = 3035;
						trgRef.bShowMessageInHUD = true;
						trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in REVERSE direction while it disabled";
						trg.IncorrectTriggers.AddItem(trgRef);
					}
				}
			}
			// точка является внутренней относительно левого поворота
			else
			{
				if(trg.bCanTurnLeftFromInternalSide == true && trg.bCanTurnLeft == true)
				{
					TriggerConnectToLeftSegment(trg);
				}
				// поворот налево из внутренней точки запрещен настройками точки вьезда
				else
				{
					foreach LeftSegment.Triggers(trg2)
					{
						trgRef.triggerRef = trg2;
						trgRef.MessageID = 3028;
						trgRef.bShowMessageInHUD = true;
						trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in left direction from internal point while it disabled";

						trg.IncorrectTriggers.AddItem(trgRef);
					}
				}

				if(trg.bCanTurnReverseFromInternalSide)
				{
					tmpCount2 = BottomSegment.Triggers.Length;
					z = 0;
		
					foreach BottomSegment.Triggers(trg2)
					{
						// если сортируемый триггер является реверсивным (для разворота) (начиная от нулевого до ForwardLineNum - 1, не включая), включаем его в список правильных триггеров
						if(z < tmpCount2 - ForwardLineNum)
						{
							trgRef.triggerRef = trg2;
							trgRef.Message = "[Message from AutomatedCR]: CORRECT - you drive in REVERSE direction from internal point";
							// ! internal 
							trgRef.MessageID = 3033;
							trgRef.bShowMessageInHUD = true;
							trg.CorrectTriggers.AddItem(trgRef);
						}

						// если нет - то в список неправильных
						else
						{
							trgRef.triggerRef = trg2;
							trgRef.MessageID = 3036;
							trgRef.bShowMessageInHUD = true;
							trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in REVERSE direction from internal point";
							trg.IncorrectTriggers.AddItem(trgRef);
						}

						z++;
					}
				}
				else
				{
					foreach BottomSegment.Triggers(trg2)
					{
						trgRef.triggerRef = trg2;
						trgRef.MessageID = 3036;
						trgRef.bShowMessageInHUD = true;
						trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in REVERSE direction from internal point";
						trg.IncorrectTriggers.AddItem(trgRef);
					}
				}
			}
		}

		//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		i++;
	}
	// RIGHT ====================================================================================================================================================================================================
	i = 0;
	tmpCount = RightSegment.Triggers.Length;

	foreach RightSegment.Triggers(trg)
	{
		
		// обрабатываем только триггеры точек вьезда
		if(i >= tmpCount - SideLineNum)
		{
			// устанавливаем триггер как "Входной"
			trg.trType = TRIGGERTYPE_ENTRY;

			//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			// для всех точек
			// если разрешен проезд вперед
			if(trg.bCanDriveForward)
			{
				tmpCount2 = LeftSegment.Triggers.Length;
				z = 0;
		
				foreach LeftSegment.Triggers(trg2)
				{
					if(z < tmpCount2 - SideLineNum)
					{
						trgRef.triggerRef = trg2;
						trgRef.Message = "[Message from AutomatedCR]: CORRECT - you drive in FORWARD direction";
						trgRef.MessageID = 3022;
						trgRef.bShowMessageInHUD = true;
						trg.CorrectTriggers.AddItem(trgRef);
					}
					else
					{
						trgRef.triggerRef = trg2;
						trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in FORWARD direction";
						trgRef.MessageID = 3023;
						trgRef.bShowMessageInHUD = true;
						trg.IncorrectTriggers.AddItem(trgRef);
					}
						

					z++;
				}
			}
			// проезд вперед не разрешен
			else
			{
				foreach LeftSegment.Triggers(trg2)
				{
					trgRef.triggerRef = trg2;
					trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in FORWARD direction while it disabled";
					trgRef.MessageID = 3024;
					trgRef.bShowMessageInHUD = true;
					trg.IncorrectTriggers.AddItem(trgRef);
				}
			}

			// только для внутренних точек --------------------------------------------------------------------------------------------------------------------------------------------------------------------
			if(i > tmpCount - SideLineNum  &&  i < tmpCount - 1)
			{
				// поворот направо (внутренняя точка)
				if(trg.bCanTurnRightFromInternalSide)
				{
					z=0;
					tmpCount2 = TopSegment.Triggers.Length;

					foreach TopSegment.Triggers(trg2)
					{
						if(z < tmpCount2 - ForwardLineNum)
						{
							trgRef.triggerRef = trg2;
							trgRef.Message = "[Message from AutomatedCR]: CORRECT - you drive in RIGHT direction";
							trgRef.MessageID = 3029;
							trgRef.bShowMessageInHUD = true;
							trg.CorrectTriggers.AddItem(trgRef);
						}
						else
						{
							trgRef.triggerRef = trg2;
							trgRef.MessageID = 3030;
							trgRef.bShowMessageInHUD = true;
							trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in RIGHT direction";
							trg.IncorrectTriggers.AddItem(trgRef);
						}
						z++;
					}
				}
				else
				{
					foreach TopSegment.Triggers(trg2)
					{
						trgRef.triggerRef = trg2;
						trgRef.MessageID = 3031;
						trgRef.bShowMessageInHUD = true;
						trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in RIGHT direction while it disabled";
						trg.IncorrectTriggers.AddItem(trgRef);
					}
				}


				// поворот налево из внутренней точки
				if(trg.bCanTurnLeftFromInternalSide)
				{
					z=0;
					tmpCount2 = BottomSegment.Triggers.Length;

					foreach BottomSegment.Triggers(trg2)
					{
						if(z < tmpCount2 - ForwardLineNum)
						{
							trgRef.triggerRef = trg2;
							trgRef.MessageID = 3025;
							trgRef.bShowMessageInHUD = true;
							trgRef.Message = "[Message from AutomatedCR]: CORRECT - you drive in LEFT direction";
							trg.CorrectTriggers.AddItem(trgRef);
						}
						else
						{
							trgRef.triggerRef = trg2;
							trgRef.MessageID = 3026;
							trgRef.bShowMessageInHUD = true;
							trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in LEFT direction";
							trg.IncorrectTriggers.AddItem(trgRef);
						}
						z++;
					}
				}
				else
				{
					foreach BottomSegment.Triggers(trg2)
					{
						trgRef.triggerRef = trg2;
						trgRef.MessageID = 3027;
						trgRef.bShowMessageInHUD = true;
						trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in LEFT direction while it disabled";
						trg.IncorrectTriggers.AddItem(trgRef);
					}
				}

				// если разрешен разворот
				if(trg.bCanTurnReverseFromInternalSide)
				{
					tmpCount2 = RightSegment.Triggers.Length;
					z = 0;
		
					foreach RightSegment.Triggers(trg2)
					{
						// если сортируемый триггер является реверсивным (для разворота) (начиная от нулевого до SideLineNum - 1, не включая), включаем его в список правильных триггеров (крайняя левая точка)
						if(z < tmpCount2 - SideLineNum)
						{
							trgRef.triggerRef = trg2;
							trgRef.Message = "[Message from AutomatedCR]: CORRECT - you drive in REVERSE direction from internal point";

							trg.CorrectTriggers.AddItem(trgRef);
						}

						// если нет - то в список неправильных (крайняя левая точка)
						else
						{
							trgRef.triggerRef = trg2;
							trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in REVERSE direction from internal point";
							trgRef.MessageID = 3036;
							trgRef.bShowMessageInHUD = true;
							trg.IncorrectTriggers.AddItem(trgRef);
						}

						z++;
					}
				}
				// если не разрешен разворот  (крайняя левая точка)
				else
				{
					foreach RightSegment.Triggers(trg2)
					{
						trgRef.triggerRef = trg2;
						trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in REVERSE direction while it disabled (from internal point)";
						
						// !!!!!!!!!!!!! рассотреть случай проезда из внутренних и внешних точек
						trgRef.MessageID = 3036;
						trgRef.bShowMessageInHUD = true;
						trg.IncorrectTriggers.AddItem(trgRef);
					}
				}
			}

			
			// если крайняя правая -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			if(i == tmpCount - 1)
			{
				// если разрешен поворот направо из крайней правой
				if(trg.bCanTurnRight)
				{
					z=0;
					tmpCount2 = TopSegment.Triggers.Length;

					foreach TopSegment.Triggers(trg2)
					{
						if(z < tmpCount2 - ForwardLineNum)
						{
							trgRef.triggerRef = trg2;
							trgRef.MessageID = 3029;
							trgRef.bShowMessageInHUD = true;
							trgRef.Message = "[Message from AutomatedCR]: CORRECT - you drive in RIGHT direction";
							trg.CorrectTriggers.AddItem(trgRef);
						}
						else
						{
							trgRef.triggerRef = trg2;
							trgRef.MessageID = 3030;
							trgRef.bShowMessageInHUD = true;
							trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in RIGHT direction";
							trg.IncorrectTriggers.AddItem(trgRef);
						}
						z++;
					}
				}
				// поворот направо не разрешен (крайняя правая)
				else
				{
					foreach TopSegment.Triggers(trg2)
					{
						trgRef.triggerRef = trg2;
						trgRef.MessageID = 3031;
						trgRef.bShowMessageInHUD = true;
						trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in RIGHT direction while it disabled";
						trg.IncorrectTriggers.AddItem(trgRef);
					}
				}

				// поворот налево из крайней правой
				if(trg.bCanTurnLeftFromInternalSide)
				{
					z=0;
					tmpCount2 = BottomSegment.Triggers.Length;

					foreach BottomSegment.Triggers(trg2)
					{
						if(z < tmpCount2 - ForwardLineNum)
						{
							trgRef.triggerRef = trg2;
							trgRef.Message = "[Message from AutomatedCR]: CORRECT - you drive in LEFT direction from internal point";
							trg.CorrectTriggers.AddItem(trgRef);
						}
						else
						{
							trgRef.triggerRef = trg2;
							trgRef.MessageID = 3028;
							trgRef.bShowMessageInHUD = true;
							trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in LEFT direction from internal point";
							trg.IncorrectTriggers.AddItem(trgRef);
						}
						z++;
					}
				}
				else
				{
					foreach BottomSegment.Triggers(trg2)
					{
						trgRef.triggerRef = trg2;
						// !!!!!!!! рассмотреть случай внешних и внутренних точек
						trgRef.MessageID = 3028;
						trgRef.bShowMessageInHUD = true;
						trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in LEFT direction while it disabled from internal point";
						trg.IncorrectTriggers.AddItem(trgRef);
					}
				}

				// если разрешен разворот
				if(trg.bCanTurnReverseFromInternalSide)
				{
					tmpCount2 = RightSegment.Triggers.Length;
					z = 0;
		
					foreach RightSegment.Triggers(trg2)
					{
						// если сортируемый триггер является реверсивным (для разворота) (начиная от нулевого до SideLineNum - 1, не включая), включаем его в список правильных триггеров (крайняя левая точка)
						if(z < tmpCount2 - SideLineNum)
						{
							trgRef.triggerRef = trg2;
							trgRef.Message = "[Message from AutomatedCR]: CORRECT - you drive in REVERSE direction from right point";
							
							trg.CorrectTriggers.AddItem(trgRef);
						}

						// если нет - то в список неправильных (крайняя левая точка)
						else
						{
							trgRef.triggerRef = trg2;
							trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in REVERSE direction from right point";
							trgRef.MessageID = 3036;
							trgRef.bShowMessageInHUD = true;
							trg.IncorrectTriggers.AddItem(trgRef);
						}

						z++;
					}
				}
				// если не разрешен разворот  (крайняя левая точка)
				else
				{
					foreach RightSegment.Triggers(trg2)
					{
						trgRef.triggerRef = trg2;
						trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in REVERSE direction while it disabled (from right point)";
						trgRef.MessageID = 3036;
						trgRef.bShowMessageInHUD = true;
						trg.IncorrectTriggers.AddItem(trgRef);
					}
				}
			}


			// если крайняя левая точка ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			if(i == tmpCount - SideLineNum)
			{
				// если разрешен разворот (крайняя левая точка)
				if(trg.bCanTurnReverse)
				{
					tmpCount2 = RightSegment.Triggers.Length;
					z = 0;
		
					foreach RightSegment.Triggers(trg2)
					{
						// если сортируемый триггер является реверсивным (для разворота) (начиная от нулевого до SideLineNum - 1, не включая), включаем его в список правильных триггеров (крайняя левая точка)
						if(z < tmpCount2 - SideLineNum)
						{
							trgRef.triggerRef = trg2;
							trgRef.Message = "[Message from AutomatedCR]: CORRECT - you drive in REVERSE direction";
							trgRef.MessageID = 3033;
							trgRef.bShowMessageInHUD = true;
							trg.CorrectTriggers.AddItem(trgRef);
						}

						// если нет - то в список неправильных (крайняя левая точка)
						else
						{
							trgRef.triggerRef = trg2;
							trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in REVERSE direction";
							trgRef.MessageID = 3034;
							trgRef.bShowMessageInHUD = true;
							trg.IncorrectTriggers.AddItem(trgRef);
						}

						z++;
					}
				}
				// если не разрешен разворот  (крайняя левая точка)
				else
				{
					foreach RightSegment.Triggers(trg2)
					{
						trgRef.triggerRef = trg2;
						trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in REVERSE direction while it disabled";
						trgRef.MessageID = 3035;
						trgRef.bShowMessageInHUD = true;
						trg.IncorrectTriggers.AddItem(trgRef);
					}
				}

				// если разрешен поворот налево (крайняя левая точка)
				if(trg.bCanTurnLeft)
				{
					tmpCount2 = BottomSegment.Triggers.Length;
					z = 0;

					foreach BottomSegment.Triggers(trg2)
					{
						if(z < tmpCount2 - ForwardLineNum)
						{
							trgRef.triggerRef = trg2;
							trgRef.Message = "[Message from AutomatedCR]: CORRECT - you drive in LEFT direction";
							trgRef.MessageID = 3025;
							trgRef.bShowMessageInHUD = true;
							trg.CorrectTriggers.AddItem(trgRef);
						}
						else
						{
							trgRef.triggerRef = trg2;
							trgRef.MessageID = 3026;
							trgRef.bShowMessageInHUD = true;
							trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in LEFT direction";
							trg.CorrectTriggers.AddItem(trgRef);
						}

						z++;
					}
				}

				// поворот налево не разрешен (крайняя левая точка)
				else
				{
					foreach BottomSegment.Triggers(trg2)
					{
						trgRef.triggerRef = trg2;
						trgRef.MessageID = 3027;
						trgRef.bShowMessageInHUD = true;
						trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in LEFT direction while it disabled";
						trg.IncorrectTriggers.AddItem(trgRef);
					}
				}

				// поворот направо (крайняя левая точка)
				if(trg.bCanTurnRightFromInternalSide)
				{
					z=0;
					tmpCount2 = TopSegment.Triggers.Length;

					foreach TopSegment.Triggers(trg2)
					{
						if(z < tmpCount2 - ForwardLineNum)
						{
							trgRef.triggerRef = trg2;
							trgRef.MessageID = 3029;
							trgRef.bShowMessageInHUD = true;
							trgRef.Message = "[Message from AutomatedCR]: CORRECT - you drive in RIGHT direction";
							trg.CorrectTriggers.AddItem(trgRef);
						}
						else
						{
							trgRef.triggerRef = trg2;
							trgRef.MessageID = 3030;
							trgRef.bShowMessageInHUD = true;
							trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in RIGHT direction";
							trg.IncorrectTriggers.AddItem(trgRef);
						}
						z++;
					}
				}
				else
				{
					foreach TopSegment.Triggers(trg2)
					{
						trgRef.triggerRef = trg2;
						trgRef.MessageID = 3031;
						trgRef.bShowMessageInHUD = true;
						trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in RIGHT direction while it disabled";
						trg.IncorrectTriggers.AddItem(trgRef);
					}
				}
			}
			//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			//
		}

		i++;
	}

	// LEFT ===========================================================================================================================================================================================================================
	i = 0;
	tmpCount = LeftSegment.Triggers.Length;

	foreach LeftSegment.Triggers(trg)
	{
		if(i >= tmpCount - SideLineNum)
		{
			// устанавливаем триггер как "Входной"
			trg.trType = TRIGGERTYPE_ENTRY;

			// для всех точек ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			if(trg.bCanDriveForward)
			{
				tmpCount2 = RightSegment.Triggers.Length;
				z = 0;

				foreach RightSegment.Triggers(trg2)
				{
					if(z < tmpCount2 - SideLineNum)
					{
						trgRef.triggerRef = trg2;
						trgRef.MessageID = 3022;
						trgRef.bShowMessageInHUD = true;
						trgRef.Message = "[Message from AutomatedCR]: CORRECT - you drive in FORWARD direction";
						trg.CorrectTriggers.AddItem(trgRef);
					}
					else
					{
						trgRef.triggerRef = trg2;
						trgRef.MessageID = 3023;
						trgRef.bShowMessageInHUD = true;
						trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in FORWARD direction";
						trg.IncorrectTriggers.AddItem(trgRef);
					}

					z++;
				}
			}
			else
			{
				foreach RightSegment.Triggers(trg2)
				{
					trgRef.triggerRef = trg2;
					trgRef.MessageID = 3024;
					trgRef.bShowMessageInHUD = true;
					trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in FORWARD direction while it disabled";
					trg.IncorrectTriggers.AddItem(trgRef);
				}
			}

			// для крайней правой ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			if(i == tmpCount - 1)
			{
				if(trg.bCanTurnRight)
				{
					z = 0;
					tmpCount2 = BottomSegment.Triggers.Length;

					foreach BottomSegment.Triggers(trg2)
					{
						if(z < tmpCount2 - ForwardLineNum)
						{
							trgRef.triggerRef = trg2;
							trgRef.MessageID = 3029;
							trgRef.bShowMessageInHUD = true;
							trgRef.Message = "[Message from AutomatedCR]: CORRECT - you drive in RIGHT direction";
							trg.CorrectTriggers.AddItem(trgRef);
						}
						else
						{
							trgRef.triggerRef = trg2;
							trgRef.MessageID = 3030;
							trgRef.bShowMessageInHUD = true;
							trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in RIGHT direction";
							trg.IncorrectTriggers.AddItem(trgRef);
						}

						z++;
					}
				}
				else
				{
					trgRef.triggerRef = trg2;
					trgRef.MessageID = 3031;
					trgRef.bShowMessageInHUD = true;
					trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in RIGHT direction while it disabled";
					trg.IncorrectTriggers.AddItem(trgRef);
				}
			}
			else // внутренняя относительно крайней правой
			{
				if(trg.bCanTurnRightFromInternalSide)
				{
					z = 0;
					tmpCount2 = BottomSegment.Triggers.Length;

					foreach BottomSegment.Triggers(trg2)
					{
						if(z < tmpCount2 - ForwardLineNum)
						{
							trgRef.triggerRef = trg2;
							trgRef.Message = "[Message from AutomatedCR]: CORRECT - you drive in RIGHT direction from internal point";
							trg.CorrectTriggers.AddItem(trgRef);
						}
						else
						{
							trgRef.triggerRef = trg2;
							trgRef.MessageID = 3032;
							trgRef.bShowMessageInHUD = true;
							trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in RIGHT direction from internal point";
							trg.IncorrectTriggers.AddItem(trgRef);
						}

						z++;
					}
				}
				else
				{
					foreach BottomSegment.Triggers(trg2)
					{
						trgRef.triggerRef = trg2;
						// !!!!!!!!!!!!!!!!!! internal
						trgRef.MessageID = 3032;
						trgRef.bShowMessageInHUD = true;
						trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in RIGHT direction while it disabled (from internal point)";
						trg.IncorrectTriggers.AddItem(trgRef);
					}
				}
			}

			// для крайней левой -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			if(i == tmpCount - SideLineNum)
			{
				if(trg.bCanTurnLeft)
				{
					z = 0;
					tmpCount2 = TopSegment.Triggers.Length;

					foreach TopSegment.Triggers(trg2)
					{
						if(z < tmpCount2 - ForwardLineNum)
						{
							trgRef.triggerRef = trg2;
							trgRef.MessageID = 3025;
							trgRef.bShowMessageInHUD = true;
							trgRef.Message = "[Message from AutomatedCR]: CORRECT - you drive in LEFT direction";
							trg.CorrectTriggers.AddItem(trgRef);
						}
						else
						{
							trgRef.triggerRef = trg2;
							trgRef.MessageID = 3026;
							trgRef.bShowMessageInHUD = true;
							trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in LEFT direction";
							trg.IncorrectTriggers.AddItem(trgRef);
						}

						z++;
					}
				}
				else
				{
					foreach TopSegment.Triggers(trg2)
					{
						trgRef.triggerRef = trg2;
						trgRef.MessageID = 3027;
						trgRef.bShowMessageInHUD = true;
						trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in LEFT direction while it disabled";
						trg.IncorrectTriggers.AddItem(trgRef);
					}
				}

				// если разрешен разворот (крайняя левая)
				if(trg.bCanTurnReverse)
				{
					z = 0;
					tmpCount2 = LeftSegment.Triggers.Length;

					foreach LeftSegment.Triggers(trg2)
					{
						if(z < tmpCount2 - SideLineNum)
						{
							trgRef.triggerRef = trg2;
							trgRef.MessageID = 3033;
							trgRef.bShowMessageInHUD = true;
							trgRef.Message = "[Message from AutomatedCR]: CORRECT - you drive in REVERSE direction";
							trg.CorrectTriggers.AddItem(trgRef);
						}
						else
						{
							trgRef.triggerRef = trg2;
							trgRef.MessageID = 3034;
							trgRef.bShowMessageInHUD = true;
							trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in REVERSE direction";
							trg.IncorrectTriggers.AddItem(trgRef);
						}

						z++;
					}
				}
				else
				{
					foreach LeftSegment.Triggers(trg2)
					{
						trgRef.triggerRef = trg2;
						trgRef.MessageID = 3035;
						trgRef.bShowMessageInHUD = true;
						trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in REVERSE direction while it disabled";
						trg.IncorrectTriggers.AddItem(trgRef);
					}
				}
			}
			else // внутренняя относительно крайней левой
			{
				if(trg.bCanTurnLeftFromInternalSide)
				{
					z = 0;
					tmpCount2 = TopSegment.Triggers.Length;

					foreach TopSegment.Triggers(trg2)
					{
						if(z < tmpCount2 - ForwardLineNum)
						{
							trgRef.triggerRef = trg2;

							trgRef.Message = "[Message from AutomatedCR]: CORRECT - you drive in LEFT direction from internal point";
							trg.CorrectTriggers.AddItem(trgRef);
						}
						else
						{
							trgRef.triggerRef = trg2;
							trgRef.MessageID = 3028;
							trgRef.bShowMessageInHUD = true;
							trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in LEFT direction from internal point";
							trg.IncorrectTriggers.AddItem(trgRef);
						}

						z++;
					}
				}
				else
				{
					foreach TopSegment.Triggers(trg2)
					{
						trgRef.triggerRef = trg2;
						trgRef.MessageID = 3028;
						trgRef.bShowMessageInHUD = true;
						trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in LEFT direction from internal point while it disabled";
						trg.IncorrectTriggers.AddItem(trgRef);
					}
				}

				// если разрешен разворот
				if(trg.bCanTurnReverseFromInternalSide)
				{
					z = 0;
					tmpCount2 = LeftSegment.Triggers.Length;

					foreach LeftSegment.Triggers(trg2)
					{
						if(z < tmpCount2 - SideLineNum)
						{
							trgRef.triggerRef = trg2;
							trgRef.Message = "[Message from AutomatedCR]: CORRECT - you drive in REVERSE direction from internal point";
							trg.CorrectTriggers.AddItem(trgRef);
						}
						else
						{
							trgRef.triggerRef = trg2;
							trgRef.MessageID = 3036;
							trgRef.bShowMessageInHUD = true;
							trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in REVERSE direction from internal point";
							trg.IncorrectTriggers.AddItem(trgRef);
						}

						z++;
					}
				}
				else
				{
					foreach LeftSegment.Triggers(trg2)
					{
						trgRef.triggerRef = trg2;
						trgRef.MessageID = 3036;
						trgRef.bShowMessageInHUD = true;
						trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in REVERSE direction from internal point (while it disabled)";
						trg.IncorrectTriggers.AddItem(trgRef);
					}
				}
			}
		}
		//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		i++;
	}

	SpawnInvalidEntryTriggers();
}

function TriggerConnectToTopSegment(out Gorod_CrossRoadsTrigger trg)
{
	//
}

function TriggerConnectToRightSegment(out Gorod_CrossRoadsTrigger trg)
{
	local Gorod_CrossRoadsTrigger trg2;
	local TriggerReference trgRef;
	local int tmpCount2, z;

	// ищем триггеры в правом сегменте
	tmpCount2 = RightSegment.Triggers.Length;
	z = 0;

	foreach RightSegment.Triggers(trg2)
	{
		// если сортируемый триггер является противоположным (начиная от нулевого до SideLineNum - 1, не включая), включаем его в список правильных триггеров
		if(z < tmpCount2 - SideLineNum)
		{
			trgRef.triggerRef = trg2;
			trgRef.MessageID = 3029;
			trgRef.bShowMessageInHUD = true;
			trgRef.Message = "[Message from AutomatedCR]: CORRECT - you drive in right direction";

			trg.CorrectTriggers.AddItem(trgRef);
		}

		// если нет - то в список НЕправильных
		else
		{
			trgRef.triggerRef = trg2;
			trgRef.MessageID = 3030;
			trgRef.bShowMessageInHUD = true;
			trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in right direction";

			trg.IncorrectTriggers.AddItem(trgRef);
		}

		z++;
	}
}

function TriggerConnectToLeftSegment(out Gorod_CrossRoadsTrigger trg)
{
	local Gorod_CrossRoadsTrigger trg2;
	local TriggerReference trgRef;
	local int tmpCount2, z;

	// ищем триггеры в правом сегменте
	tmpCount2 = LeftSegment.Triggers.Length;
	z = 0;

	foreach LeftSegment.Triggers(trg2)
	{
		// если сортируемый триггер является противоположным (начиная от нулевого до SideLineNum - 1, не включая), включаем его в список правильных триггеров
		if(z < tmpCount2 - SideLineNum)
		{
			trgRef.triggerRef = trg2;
			trgRef.Message = "[Message from AutomatedCR]: CORRECT - you drive in left direction";
			trgRef.MessageID = 3025;
			trgRef.bShowMessageInHUD = true;
			trg.CorrectTriggers.AddItem(trgRef);
		}

		// если нет - то в список НЕправильных
		else
		{
			trgRef.triggerRef = trg2;
			trgRef.Message = "[Message from AutomatedCR]: INCORRECT - you drive in left direction";
			trgRef.MessageID = 3026;
			trgRef.bShowMessageInHUD = true;
			trg.IncorrectTriggers.AddItem(trgRef);
		}

		z++;
	}
}

function ConnectTrafficLight(Gorod_TrafficLight TrafficLight, Segment lSegment)
{
	local int i, tmpCount;
	local Gorod_CrossRoadsTrigger trg;

	if(TrafficLight != none)
	{
		i = 0;
		tmpCount = lSegment.Triggers.Length;
		lSegment.TrafficLight = TrafficLight;

		foreach lSegment.Triggers(trg)
		{
			if(i >= tmpCount - ForwardLineNum)
			{
				// если триггер настроен как контролируемый одной из дополнительных секций, записываем его в список этой секции
				if(trg.bControlByLeftSection || trg.bControlByRightSection)
				{
					if(trg.bControlByRightSection)
					{
						TrafficLight.RightSection.Triggers.AddItem(trg);
					}
					else
					{
						TrafficLight.LeftSection.Triggers.AddItem(trg);
					}
				}
				else
					TrafficLight.ControlledTriggers.AddItem(trg);
			}

			i++;
		}
	}

}


function ConnectTrafficLights()
{
	ConnectTrafficLight(TopTrafficLight, TopSegment);
	ConnectTrafficLight(BottomTrafficLight, BottomSegment);
	ConnectTrafficLight(RightTrafficLight, RightSegment);
	ConnectTrafficLight(LeftTrafficLight, LeftSegment);

	/*
	if (!TopTrafficLight.GetWorking() || !BottomTrafficLight.GetWorking() || !RightTrafficLight.GetWorking() || !LeftTrafficLight.GetWorking())
	{
		if (TopTrafficLight != none)
			TopTrafficLight.setWorking (false);
		if (BottomTrafficLight != none)
			BottomTrafficLight.setWorking (false);
		if (RightTrafficLight != none)
			RightTrafficLight.setWorking (false);
		if (LeftTrafficLight != none)
			LeftTrafficLight.setWorking (false);
	}*/
}

function SpawnInvalidEntryTriggers()
{
	local Vector loc1, loc2, disp, rotDisp;
	local float trgLength, trgDisp;


	trgLength = 150.0;
	disp.X = trgLength / 2.0;
	trgDisp = 5.0;

	// TOP SEGMENT ==================================================================================================================
	if(TopSegment.Triggers.Length > 0)
	{
		// LEFT SIDE ---------------------------------------------------------------------------------------
		if(LeftSegment.Triggers.Length > 0)
		{
			// получаем позиции крайних триггеров
			loc1 = TopSegment.Triggers[TopSegment.Triggers.Length - 1].Location;
			rotDisp = disp >> TopSegment.Triggers[TopSegment.Triggers.Length - 1].Rotation;
			loc1 -= rotDisp;

			loc2 = LeftSegment.Triggers[0].Location;
			rotDisp = disp >> LeftSegment.Triggers[0].Rotation;
			loc2 += rotDisp;

			spawnInvalidEntryTrigger(loc1, loc2, trgLength, trgDisp);
		}
		// от Top до Bottom с левой стороны
		else if(BottomSegment.Triggers.Length > 0)
		{
			// получаем позиции крайних триггеров
			loc1 = TopSegment.Triggers[TopSegment.Triggers.Length - 1].Location;
			rotDisp = disp >> TopSegment.Triggers[TopSegment.Triggers.Length - 1].Rotation;
			loc1 -= rotDisp;

			loc2 = BottomSegment.Triggers[0].Location;
			rotDisp = disp >> BottomSegment.Triggers[0].Rotation;
			loc2 -= rotDisp;

			spawnInvalidEntryTrigger(loc1, loc2, trgLength, trgDisp);
		}


		// RIGHT SIDE ---------------------------------------------------------------------------------------
		if(RightSegment.Triggers.Length > 0)
		{
			// получаем позиции крайних триггеров
			loc1 = TopSegment.Triggers[0].Location;
			rotDisp = disp >> TopSegment.Triggers[0].Rotation;
			loc1 += rotDisp;

			loc2 = RightSegment.Triggers[RightSegment.Triggers.Length - 1].Location;
			rotDisp = disp >> RightSegment.Triggers[RightSegment.Triggers.Length - 1].Rotation;
			loc2 += rotDisp;

			spawnInvalidEntryTrigger(loc1, loc2, trgLength, trgDisp);
		}
		// от Top до Bottom с правой стороны -------------------------------------------------------------------------------------------------------
		else if(BottomSegment.Triggers.Length > 0)
		{
			// получаем позиции крайних триггеров
			loc1 = TopSegment.Triggers[0].Location;
			rotDisp = disp >> TopSegment.Triggers[0].Rotation;
			loc1 += rotDisp;

			loc2 = BottomSegment.Triggers[BottomSegment.Triggers.Length - 1].Location;
			rotDisp = disp >> BottomSegment.Triggers[BottomSegment.Triggers.Length - 1].Rotation;
			loc2 += rotDisp;

			spawnInvalidEntryTrigger(loc1, loc2, trgLength, trgDisp);
		}
	}
	// BOTTOM =====================================================================================================================================
	if(BottomSegment.Triggers.Length > 0)
	{
		if(LeftSegment.Triggers.Length > 0)
		{
			// получаем позиции крайних триггеров
			loc1 = BottomSegment.Triggers[0].Location;
			rotDisp = disp >> BottomSegment.Triggers[0].Rotation;
			loc1 -= rotDisp;

			loc2 = LeftSegment.Triggers[LeftSegment.Triggers.Length - 1].Location;
			rotDisp = disp >> LeftSegment.Triggers[LeftSegment.Triggers.Length - 1].Rotation;
			loc2 -= rotDisp;

			spawnInvalidEntryTrigger(loc1, loc2, trgLength, trgDisp);
		}

		if(RightSegment.Triggers.Length > 0)
		{
			// получаем позиции крайних триггеров
			loc1 = BottomSegment.Triggers[BottomSegment.Triggers.Length - 1].Location;
			rotDisp = disp >> BottomSegment.Triggers[BottomSegment.Triggers.Length - 1].Rotation;
			loc1 += rotDisp;

			loc2 = RightSegment.Triggers[0].Location;
			rotDisp = disp >> RightSegment.Triggers[0].Rotation;
			loc2 -= rotDisp;

			spawnInvalidEntryTrigger(loc1, loc2, trgLength, trgDisp);
		}
	}

	// LEFT ===========================================================================================================================
	if(LeftSegment.Triggers.Length > 0)
	{
		if(TopSegment.Triggers.Length == 0   &&   RightSegment.Triggers.Length > 0)
		{
			// получаем позиции крайних триггеров
			loc1 = LeftSegment.Triggers[0].Location;
			rotDisp = disp >> LeftSegment.Triggers[0].Rotation;
			loc1 += rotDisp;

			loc2 = RightSegment.Triggers[RightSegment.Triggers.Length - 1].Location;
			rotDisp = disp >> RightSegment.Triggers[RightSegment.Triggers.Length - 1].Rotation;
			loc2 += rotDisp;

			spawnInvalidEntryTrigger(loc1, loc2, trgLength, trgDisp);
		}

		if(BottomSegment.Triggers.Length == 0   &&   RightSegment.Triggers.Length > 0)
		{
			// получаем позиции крайних триггеров
			loc1 = LeftSegment.Triggers[LeftSegment.Triggers.Length - 1].Location;
			rotDisp = disp >> LeftSegment.Triggers[LeftSegment.Triggers.Length - 1].Rotation;
			loc1 -= rotDisp;

			loc2 = RightSegment.Triggers[0].Location;
			rotDisp = disp >> RightSegment.Triggers[0].Rotation;
			loc2 -= rotDisp;

			spawnInvalidEntryTrigger(loc1, loc2, trgLength, trgDisp);
		}
	}
	
}

private function spawnInvalidEntryTrigger(Vector loc1, Vector loc2, float trgLength, float trgDisp)
{
	local Vector turn, lc, perp;
	local Gorod_CrossRoadsTrigger trg;
	local Rotator rot;

	local float dist;

	// вычисляем положение триггера (среднее значение между крайними триггерами)
	lc = (loc1 + loc2) / 2;

	// вычисляем дистанцию между триггерами
	dist = VSize(loc2 - loc1);

	// проекция триггеров
	perp.X = loc2.x;
	perp.Y = loc1.y;
	perp.Z = lc.z;

	// вектор поворота
	turn = perp - lc;

	rot = Rotator(turn);
	rot.Yaw = -rot.Yaw;

	trg = Spawn(class'Gorod_CrossRoadsTrigger', self, , lc, rot);
	trg.trType = TRIGGERTYPE_INVALIDENTRY;

	lc.X = dist / (trgLength + trgDisp);
	lc.Y = 1.0;
	lc.Z = 1.0;
	trg.SetDrawScale3D(lc);
	trg.SetColor(trg.RedColor);

	self.Triggers.AddItem(trg);
}

defaultproperties
{
	ForwardWidth = 1225;
	SideWidth = 1225;

	RoadLineWidth = 222.5;

	TrafficLightOffset = 300;

	MinTurnRadius = 450;
	MaxVehicleWidth = 125;

	CarMaxSpeed = 14;
}
