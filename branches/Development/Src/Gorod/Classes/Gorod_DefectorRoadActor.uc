class Gorod_DefectorRoadActor extends Actor placeable;

var() array<Gorod_HumanBotPathNode> endHumanPathNode;

/** Начало полосы движения */
var() Gorod_AIVehicle_PathNode startVPathNode;
/** Конец полосы движения */
var() Gorod_AIVehicle_PathNode endVPathNode;
/** Шанс перебегания */
var() int chanceToCrossTheRoad;
/** перебегающий бот */
var Gorod_HumanBot crossingBot;

/** Массив зарегестрированных машин */
var array<Gorod_AIVehicle> registredBotCar;

/** Массив зарегестрированных ботов - игроков */
var array<Gorod_HumanBot> registredHumanBot;

/** Массив зарегестрированных машин */
var array<Vehicle> registredPlayerCar;

var float startHSize;
var float endHSize;
var float startVSize;
var float endVSize;
var bool bPlayerInside;
var bool bIsBotCrossing;

simulated function PostBeginPlay()
{
	local Gorod_HumanBotPathNode pn;
	super.PostBeginPlay();

	SetCollisionType(COLLIDE_TouchAll);

	`warn("startVPathNode==none", startVPathNode==none);
	`warn("endVPathNode==none", endVPathNode==none);
	`warn("endHumanPathNode lenght==0",endHumanPathNode.Length==0);
	`warn("chanceToCrossTheRoad <0",chanceToCrossTheRoad<0);
	
	if ((startVPathNode!=none) && (endVPathNode!=none) && endHumanPathNode.Length!=0 && chanceToCrossTheRoad>0)
	{
		foreach endHumanPathNode(pn)
			pn.nodeTouch=BotTouch;
		if(chanceToCrossTheRoad>100)
			chanceToCrossTheRoad = 100;
	}
	else
	{
		SetCollisionType(COLLIDE_NoCollision);
		GotoState('Broken');
	}
}


//стейт по-умолчанию
auto simulated state Idle
{
	Begin:
		GotoState('Sleeping');
}

//стейт в котором не вычисляется, может ли бот перебежать дорогу, просто работают события Touch и Untouch 
simulated state Sleeping
{
}
//сломался
simulated state Broken
{
	ignores Touch, UnTouch;
}
//стейт, в котором вычисляется, может ли бот-человек перебегать дорогу
simulated state Eval
{
	/** Решаем перебегать ли боту-человеку к точке, которая указана в параметре ? */
	function SolveToCross()
	{
		/** Итератор бота-человека */
		local Gorod_HumanBot tempBot;
		/** Временная точка, в которую бот будет бежать */
		local Gorod_HumanBotPathNode endNode;

		/** Итератор машин */
		local Gorod_AIVehicle car;
		/** Контроллер бота-машины */
		local Gorod_AIVehicle_Controller AIVehicleController;
		/** Контроллер бота-человека */
		local Gorod_HumanBotAiController HumanBotAiController;

		foreach registredHumanBot(tempBot)
		{
			//если успеет перебежать
			if( TimeTo (tempBot, endNode ) )
			{
				HumanBotAiController = Gorod_HumanBotAiController(tempBot.Controller);
				if(HumanBotAiController != none)
				{
					//если бот не бежит
					if(!HumanBotAiController.bIsCrossingTheRoad)
					{
						//если бот будет перебегать дорогу, предупреждаем ботов-машин
						if(HumanBotAiController.cross(endNode,chanceToCrossTheRoad))
						{
							crossingBot = tempBot;
							bIsBotCrossing = true;
							//предупреждаем машины, что бот будет перебегать
							foreach registredBotCar(car)
							{
								AIVehicleController = Gorod_AIVehicle_Controller(car.Controller);
								if(AIVehicleController!=none)
									AIVehicleController.RegisterDangerousActor(tempBot);
							}
						}
						else
						{
							unregisterHumanBot(tempBot);
						}
					}
					

				}
			}
		}
	}

	/** Проверяет, успеет ли бот перебежать дорогу до какой либо точки.  Внимание! Проверяюся все машины! */

	function bool TimeTo(Gorod_HumanBot bot,out Gorod_HumanBotPathNode endNode)
	{

		local Gorod_AIVehicle gorodcar;

		local Vehicle car;
		/** Безопастная дистанция */
		local float safeDistance;
		/** Текущая дистанция до места столкновения */
		local float currentDistance;

		local Gorod_AIVehicle_Controller AIVehicleController;

		local float BreakFactor;

		local Vector CrossPoint;

		//получаем точкe, которая пересекает путь машины относительно бота-человека
		if(!getFirstAvailableCrossPoint(bot, CrossPoint, endNode))
			return false;

		//если машина управляется аи (БОТ), получаем у нее безопастную дистанцию (В идеале надо проверять только те машины, которые находятся на полосе, которую перебегает чел )
		//безопасная дистанция (safeDistance) - дистанция, которую проедет машина после торможения с текщей скоростью + оффсет для того чтобы не произошло столкновение
		foreach registredBotCar(gorodcar)
		{
			AIVehicleController = Gorod_AIVehicle_Controller(gorodcar.Controller);
			if(AIVehicleController!=none)
			{
				safeDistance = AIVehicleController.GetSafeDistance();
				currentDistance = VSize(gorodcar.Location-CrossPoint);
				if(currentDistance<safeDistance)
					return false;   // не успеет затормозить 
			}
		}

		//если машина управляется человеком, вычисляем у него безопастную дистанцию до предпологаемого места столкновения
		foreach registredPlayerCar (car)
		{
			//вынести в ini
			BreakFactor = 0.65;

			if(BreakFactor!=0)
			{
				safeDistance = VSize(car.Velocity)/BreakFactor;// + CarTrigger.carBot.MINDISTANCE-;
				currentDistance = VSize(car.Location-CrossPoint);
			}
			else
			{
				`warn("Devide by zero!");
				safeDistance=0;
				return false;
			}
			if(currentDistance<safeDistance)
				// не успеет затормозить 
				return false;
		}
		// должен успеть затормозить, можно перебегать
		return true;
	}


	/** возвращает ближайшую точку до которой надо бежать, путь до которой пересекает путь машины */
	function bool getFirstAvailableCrossPoint(Gorod_HumanBot bot , out Vector CrossPoint, out Gorod_HumanBotPathNode endPathNode )
	{
		//длинна до ближайжей точки
		local float length;
		//длинна до следующей
		local float newLength;

		//если нашли хотя бы одну точку, путь до которой пересекает путь машины
		local bool bFoundCrossed;
		//временные переменные
		local Vector crossP;

		local Gorod_HumanBotPathNode endP;

		bFoundCrossed = false;

		//вычисляем предполагаемую точку столкновения (пока вычисляется первая )
		foreach endHumanPathNode(endP)
		{
			if(PathSectionCross(bot.Location, endP.Location, startVPathNode.Location, endVPathNode.Location, crossP))
			{
				//Первый раз вычисляем длинну пути.
				if(!bFoundCrossed)
				{
					bFoundCrossed =true;
					length= VSize(bot.Location - crossP);
					CrossPoint = crossP;
					endPathNode = endP;
				}
				//какую-то точку уже нашли до этого, смотрим, ближе ли к нам текущая точка
				else
				{
					newLength = VSize(bot.Location - crossP);
					// если эта точка ближе
					if(length > newLength)
					{
						length = newLength;
						CrossPoint = crossP;
						endPathNode = endP;
					}
				}
			}

		}
		if(bFoundCrossed)
			return true;
		return false;
	}



Begin:
	SolveToCross();
	Sleep(0.5);
	goto 'Begin';
}

/** регистрирует машину-бота */
function registerBotCar(Gorod_AIVehicle car)
{
	if(registredBotCar.Find(car) == INDEX_NONE)
		registredBotCar.AddItem(car);
}

/** убирает регистрацию машины-бота*/
function unregisterBotCar(Gorod_AIVehicle car)
{
	if(registredBotCar.Find(car) != INDEX_NONE)
		registredBotCar.RemoveItem(car);
}

/** регистрирует машину-человаека */
function registerPlayerCar(Vehicle car)
{
	if(registredPlayerCar.Find(car) == INDEX_NONE)
		registredPlayerCar.AddItem(car);
}

/** убирает регистрацию машины-бота*/
function unregisterPlayerCar(Vehicle car)
{
	if(registredPlayerCar.Find(car) != INDEX_NONE)
		registredPlayerCar.RemoveItem(car);
}

/** регистрирует бота-человека */
function registerHumanBot(Gorod_HumanBot bot)
{
	if(registredHumanBot.Find(bot) == INDEX_NONE)
		registredHumanBot.AddItem(bot);
}

/** убирает регистрацию бота-человека */
function unregisterHumanBot(Gorod_HumanBot bot)
{
	if(registredHumanBot.Find(bot) != INDEX_NONE)
		registredHumanBot.RemoveItem(bot);
}

function BotTouch( Actor Other)
{
	local Gorod_HumanBot bot;
	bot = Gorod_HumanBot(Other);
	if(bot!=none)
		unregisterHumanBot(bot);
}

/**
 * Вычисляет являются ли отрезки [A1; A2] и [A3; A4] пересекающимися. CrossPoint - точка пересечения прямых, на которых упомянутые отрезки (если не пересекаются - none)
 */
function bool PathSectionCross(Vector A1, Vector A2, Vector A3, Vector A4, optional out Vector SomeCrossPoint)
{	
	local float Ua, Ub, Zn;
	local float eps;
	eps = 0.0001f;
	// Вычисляем, пересекаются ли отрезки, игнорируя координату Z (описание здесьhttp://algolist.manual.ru/maths/geom/intersect/lineline2d.php)

	Zn = (A4.Y-A3.Y)*(A2.X-A1.X) - (A4.X-A3.X)*(A2.Y-A1.Y);
	
	// пока вычисляем только числители
	Ua = ((A4.X-A3.X)*(A1.Y-A3.Y) - (A4.Y-A3.Y)*(A1.X-A3.X));
	Ub = ((A2.X-A1.X)*(A1.Y-A3.Y) - (A2.Y-A1.Y)*(A1.X-A3.X));

	if(Abs(Zn) < eps)
	{
		if(Abs(Ua) < eps)   // прямые совпадают, отрезки лежат на одной прямой 
			return (PathSectionContainsPoint(A1, A2, A3) || PathSectionContainsPoint(A1, A2, A4)); // если A3 лежит на отрезке [A1; A2] или если A4 лежит на отрезке [A1; A2]
		else                // прямые параллельны
			return false;   
	}

	Ua /= Zn;
	SomeCrossPoint = A1 + Ua*(A2 - A1);

	if((Ua < -eps) || (Ua > (1.f + eps))) // Отрезок A пересекается за своими границами
		return false;

	Ub /= Zn;
	if((Ub < -eps) || (Ub > (1.f + eps))) // Отрезок B пересекается за своими границами
		return false;
	
	return true;
}

function bool PathSectionContainsPoint(Vector A1, Vector A2, Vector A)
{
	local float p;
	p = (A.X - A2.X)/(A1.X - A2.X);
	return (Abs((A.Y - p*A1.Y + (1 - p)*A2.Y)) < 0.0001f);
}

simulated event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
	local Gorod_HumanBot gorodbot;
	local VehicleBase gorodcar;
	local Gorod_AIVehicle botcar;
	local Vehicle car;
	//если коснулся человек
	gorodbot = Gorod_HumanBot(Other);
	if(gorodbot !=none)
	{
		registerHumanBot(gorodbot);
		//больше делать ничего ненадо
		return;
	}
	// если коснулась машина
	gorodcar = VehicleBase(Other);
	if(gorodcar!=none)
	{
		botcar = Gorod_AIVehicle(gorodcar);
		//если это бот-машина, регистрируем ее как бота, если CT_Handle это машина игрока
		if(botcar != none)
			registerBotCar(botcar);
		else if(PlayerCarBase(gorodcar) != none)
		{
			registerPlayerCar(gorodcar);
			tryToWakeUp();

		}
	}
	else 
	{
		car = Vehicle(Other);
		if(car != none)
		{
			registerPlayerCar(car);
			//Рядом игрок, будим актора
			tryToWakeUp();
		}

	}
}

simulated event UnTouch( Actor Other)
{
	//человечишко
	local Gorod_HumanBot gorodbot;
	local VehicleBase gorodcar;
	local Gorod_AIVehicle botcar;
	local Vehicle car;

	//если коснулся человек
	gorodbot = Gorod_HumanBot(Other);
	if(gorodbot !=none)
	{
		unregisterHumanBot(gorodbot);
		//больше делать ничего ненадо
		return;
	}

	gorodcar = VehicleBase(Other);
	//если машина выехала, разрегистрируем ее
	if(gorodcar != none)
	{
		botcar = Gorod_AIVehicle(gorodcar);
		if(botcar != none)
			unregisterBotCar(botcar);
		else if(PlayerCarBase(gorodcar) != none)
		{
			unregisterPlayerCar(gorodcar);
			tryToSleep();
		}
	}
	else
	{
		car = Vehicle(Other);
		if(car != none)
		{
			unregisterPlayerCar(car);
			//пытаемся уснуть
			tryToSleep();
		}
	}
}


/** Пытаемся проснуться */
function tryToWakeUp()
{
	//если спим - просыпаемся
	if(IsInState('Sleeping'))
		GotoState('Eval');
}
/** Пытаемся уснуть */
function tryToSleep()
{
	//если машин игроков нет - поспим
	if(registredPlayerCar.Length==0)
		GotoState('Sleeping');
}


DefaultProperties
{
	Begin Object Class=StaticMeshComponent Name=MBox 
		StaticMesh = StaticMesh'Tools_1.Meshes.Mesh_Crossroad'
		CollideActors = true
		BlockActors = false
		BlockRigidBody=false
		RBChannel=RBCC_GameplayPhysics
		RBCollideWithChannels=(Default=TRUE,BlockingVolume=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE,Vehicle=TRUE)
		HiddenGame = true
	End Object
	CollisionType = COLLIDE_TouchAll;
	Components.Add(MBox);
	CollisionComponent = MBox
	bPlayerInside = false
	bIsBotCrossing = false
	chanceToCrossTheRoad = 100;
}