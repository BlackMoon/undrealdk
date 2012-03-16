class Gorod_DefectorRoadActor extends Actor placeable;

var() array<Gorod_HumanBotPathNode> endHumanPathNode;

/** ������ ������ �������� */
var() Gorod_AIVehicle_PathNode startVPathNode;
/** ����� ������ �������� */
var() Gorod_AIVehicle_PathNode endVPathNode;
/** ���� ����������� */
var() int chanceToCrossTheRoad;
/** ������������ ��� */
var Gorod_HumanBot crossingBot;

/** ������ ������������������ ����� */
var array<Gorod_AIVehicle> registredBotCar;

/** ������ ������������������ ����� - ������� */
var array<Gorod_HumanBot> registredHumanBot;

/** ������ ������������������ ����� */
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


//����� ��-���������
auto simulated state Idle
{
	Begin:
		GotoState('Sleeping');
}

//����� � ������� �� �����������, ����� �� ��� ���������� ������, ������ �������� ������� Touch � Untouch 
simulated state Sleeping
{
}
//��������
simulated state Broken
{
	ignores Touch, UnTouch;
}
//�����, � ������� �����������, ����� �� ���-������� ���������� ������
simulated state Eval
{
	/** ������ ���������� �� ����-�������� � �����, ������� ������� � ��������� ? */
	function SolveToCross()
	{
		/** �������� ����-�������� */
		local Gorod_HumanBot tempBot;
		/** ��������� �����, � ������� ��� ����� ������ */
		local Gorod_HumanBotPathNode endNode;

		/** �������� ����� */
		local Gorod_AIVehicle car;
		/** ���������� ����-������ */
		local Gorod_AIVehicle_Controller AIVehicleController;
		/** ���������� ����-�������� */
		local Gorod_HumanBotAiController HumanBotAiController;

		foreach registredHumanBot(tempBot)
		{
			//���� ������ ����������
			if( TimeTo (tempBot, endNode ) )
			{
				HumanBotAiController = Gorod_HumanBotAiController(tempBot.Controller);
				if(HumanBotAiController != none)
				{
					//���� ��� �� �����
					if(!HumanBotAiController.bIsCrossingTheRoad)
					{
						//���� ��� ����� ���������� ������, ������������� �����-�����
						if(HumanBotAiController.cross(endNode,chanceToCrossTheRoad))
						{
							crossingBot = tempBot;
							bIsBotCrossing = true;
							//������������� ������, ��� ��� ����� ����������
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

	/** ���������, ������ �� ��� ���������� ������ �� ����� ���� �����.  ��������! ���������� ��� ������! */

	function bool TimeTo(Gorod_HumanBot bot,out Gorod_HumanBotPathNode endNode)
	{

		local Gorod_AIVehicle gorodcar;

		local Vehicle car;
		/** ����������� ��������� */
		local float safeDistance;
		/** ������� ��������� �� ����� ������������ */
		local float currentDistance;

		local Gorod_AIVehicle_Controller AIVehicleController;

		local float BreakFactor;

		local Vector CrossPoint;

		//�������� ����e, ������� ���������� ���� ������ ������������ ����-��������
		if(!getFirstAvailableCrossPoint(bot, CrossPoint, endNode))
			return false;

		//���� ������ ����������� �� (���), �������� � ��� ����������� ��������� (� ������ ���� ��������� ������ �� ������, ������� ��������� �� ������, ������� ���������� ��� )
		//���������� ��������� (safeDistance) - ���������, ������� ������� ������ ����� ���������� � ������ ��������� + ������ ��� ���� ����� �� ��������� ������������
		foreach registredBotCar(gorodcar)
		{
			AIVehicleController = Gorod_AIVehicle_Controller(gorodcar.Controller);
			if(AIVehicleController!=none)
			{
				safeDistance = AIVehicleController.GetSafeDistance();
				currentDistance = VSize(gorodcar.Location-CrossPoint);
				if(currentDistance<safeDistance)
					return false;   // �� ������ ����������� 
			}
		}

		//���� ������ ����������� ���������, ��������� � ���� ����������� ��������� �� ��������������� ����� ������������
		foreach registredPlayerCar (car)
		{
			//������� � ini
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
				// �� ������ ����������� 
				return false;
		}
		// ������ ������ �����������, ����� ����������
		return true;
	}


	/** ���������� ��������� ����� �� ������� ���� ������, ���� �� ������� ���������� ���� ������ */
	function bool getFirstAvailableCrossPoint(Gorod_HumanBot bot , out Vector CrossPoint, out Gorod_HumanBotPathNode endPathNode )
	{
		//������ �� ��������� �����
		local float length;
		//������ �� ���������
		local float newLength;

		//���� ����� ���� �� ���� �����, ���� �� ������� ���������� ���� ������
		local bool bFoundCrossed;
		//��������� ����������
		local Vector crossP;

		local Gorod_HumanBotPathNode endP;

		bFoundCrossed = false;

		//��������� �������������� ����� ������������ (���� ����������� ������ )
		foreach endHumanPathNode(endP)
		{
			if(PathSectionCross(bot.Location, endP.Location, startVPathNode.Location, endVPathNode.Location, crossP))
			{
				//������ ��� ��������� ������ ����.
				if(!bFoundCrossed)
				{
					bFoundCrossed =true;
					length= VSize(bot.Location - crossP);
					CrossPoint = crossP;
					endPathNode = endP;
				}
				//�����-�� ����� ��� ����� �� �����, �������, ����� �� � ��� ������� �����
				else
				{
					newLength = VSize(bot.Location - crossP);
					// ���� ��� ����� �����
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

/** ������������ ������-���� */
function registerBotCar(Gorod_AIVehicle car)
{
	if(registredBotCar.Find(car) == INDEX_NONE)
		registredBotCar.AddItem(car);
}

/** ������� ����������� ������-����*/
function unregisterBotCar(Gorod_AIVehicle car)
{
	if(registredBotCar.Find(car) != INDEX_NONE)
		registredBotCar.RemoveItem(car);
}

/** ������������ ������-��������� */
function registerPlayerCar(Vehicle car)
{
	if(registredPlayerCar.Find(car) == INDEX_NONE)
		registredPlayerCar.AddItem(car);
}

/** ������� ����������� ������-����*/
function unregisterPlayerCar(Vehicle car)
{
	if(registredPlayerCar.Find(car) != INDEX_NONE)
		registredPlayerCar.RemoveItem(car);
}

/** ������������ ����-�������� */
function registerHumanBot(Gorod_HumanBot bot)
{
	if(registredHumanBot.Find(bot) == INDEX_NONE)
		registredHumanBot.AddItem(bot);
}

/** ������� ����������� ����-�������� */
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
 * ��������� �������� �� ������� [A1; A2] � [A3; A4] ���������������. CrossPoint - ����� ����������� ������, �� ������� ���������� ������� (���� �� ������������ - none)
 */
function bool PathSectionCross(Vector A1, Vector A2, Vector A3, Vector A4, optional out Vector SomeCrossPoint)
{	
	local float Ua, Ub, Zn;
	local float eps;
	eps = 0.0001f;
	// ���������, ������������ �� �������, ��������� ���������� Z (�������� �����http://algolist.manual.ru/maths/geom/intersect/lineline2d.php)

	Zn = (A4.Y-A3.Y)*(A2.X-A1.X) - (A4.X-A3.X)*(A2.Y-A1.Y);
	
	// ���� ��������� ������ ���������
	Ua = ((A4.X-A3.X)*(A1.Y-A3.Y) - (A4.Y-A3.Y)*(A1.X-A3.X));
	Ub = ((A2.X-A1.X)*(A1.Y-A3.Y) - (A2.Y-A1.Y)*(A1.X-A3.X));

	if(Abs(Zn) < eps)
	{
		if(Abs(Ua) < eps)   // ������ ���������, ������� ����� �� ����� ������ 
			return (PathSectionContainsPoint(A1, A2, A3) || PathSectionContainsPoint(A1, A2, A4)); // ���� A3 ����� �� ������� [A1; A2] ��� ���� A4 ����� �� ������� [A1; A2]
		else                // ������ �����������
			return false;   
	}

	Ua /= Zn;
	SomeCrossPoint = A1 + Ua*(A2 - A1);

	if((Ua < -eps) || (Ua > (1.f + eps))) // ������� A ������������ �� ������ ���������
		return false;

	Ub /= Zn;
	if((Ub < -eps) || (Ub > (1.f + eps))) // ������� B ������������ �� ������ ���������
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
	//���� �������� �������
	gorodbot = Gorod_HumanBot(Other);
	if(gorodbot !=none)
	{
		registerHumanBot(gorodbot);
		//������ ������ ������ ������
		return;
	}
	// ���� ��������� ������
	gorodcar = VehicleBase(Other);
	if(gorodcar!=none)
	{
		botcar = Gorod_AIVehicle(gorodcar);
		//���� ��� ���-������, ������������ �� ��� ����, ���� CT_Handle ��� ������ ������
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
			//����� �����, ����� ������
			tryToWakeUp();
		}

	}
}

simulated event UnTouch( Actor Other)
{
	//�����������
	local Gorod_HumanBot gorodbot;
	local VehicleBase gorodcar;
	local Gorod_AIVehicle botcar;
	local Vehicle car;

	//���� �������� �������
	gorodbot = Gorod_HumanBot(Other);
	if(gorodbot !=none)
	{
		unregisterHumanBot(gorodbot);
		//������ ������ ������ ������
		return;
	}

	gorodcar = VehicleBase(Other);
	//���� ������ �������, ��������������� ��
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
			//�������� ������
			tryToSleep();
		}
	}
}


/** �������� ���������� */
function tryToWakeUp()
{
	//���� ���� - �����������
	if(IsInState('Sleeping'))
		GotoState('Eval');
}
/** �������� ������ */
function tryToSleep()
{
	//���� ����� ������� ��� - ������
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