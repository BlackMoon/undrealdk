class Gorod_AIVehicle_Spawner extends Gorod_BaseSpawner config(Spawner);

var class<Gorod_AIVehicle> Selected_AIVehicle_Class;

struct VehicleTypeInfo
{
	var class<Gorod_AIVehicle> AIVehicle_Class;
	var int Probability;
};

var config array<VehicleTypeInfo> VehicleTypes;

/** Число для вычисления типа машины, который появится в при очередном спауне */
var int Total;

/** Массив для вычисления типа машины, который появится в при очередном спауне */
/** параллельный массив для VehicleTypes, где содержатся значения, разделяющие отрезок длиной Total
 *  на несколько частей, соответственно количеству разных типов машин 
 */
var array<int> segments;

simulated event PostBeginPlay()
{
	BotLength = 300;
	EvalSegments();
	super.PostBeginPlay();
}


/** Вычисляет сегменты*/
function EvalSegments()
{
	local int i;

	Total = 0;
	segments.AddItem(0);
	
	for(i = 0; i < VehicleTypes.Length; i++)
	{
		Total += VehicleTypes[i].Probability;
		segments.AddItem(Total);
	}
}

/** Определяет класс очередного бота */
function SetVehicleToSpawn()
{
	local int Num, i;
	
	Num = Rand(Total);

	for(i = 0; i < segments.Length - 1; i++)
	{
		if(Num >= segments[i] && Num < segments[i+1])
		{
			Selected_AIVehicle_Class = VehicleTypes[i].AIVehicle_Class;
			break;
		}
	}
}

function SpawnBot(SpawnPoint P)
{
	local Gorod_AIVehicle CarBot;

	SetVehicleToSpawn();

	CarBot = Spawn(Selected_AIVehicle_Class, self, 'bot', P.Location, P.Rotation, , false);
	
	if(CarBot == none)
	{
		`warn("Failed to spawn vehicle at" @ P.Location);
		return;
	}

	// задание первой маршрутной точки
	CarBot.Target = Gorod_AIVehicle_PathNode(P.firstPathNode);
	CarBot.RelocManager = RelocManager;
	CarBot.Initialize();
}

DefaultProperties
{
	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorResources.S_NavP'
		HiddenGame=true
		HiddenEditor=false
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
		SpriteCategoryName="Navigation"
	End Object
	Components.Add(Sprite)

	//RemoteRole = ROLE_SimulatedProxy
}
