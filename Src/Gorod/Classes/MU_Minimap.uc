class MU_Minimap extends Compass;

/**  для хранения ссылки на материал */
var() MaterialInstanceConstant Minimap;
/** MIC переменной, ссылающейся материал для наложения компас также необходима */
var() MaterialInstanceConstant CompassOverlay;

var Vector2D MapRangeMin,MapRangeMax;

/** стрелка показывает направление движения вперед */
var() Bool bForwardAlwaysUp;

/** центр карты текстур */
var Vector2D MapCenter;

var() Const EditConst DrawSphereComponent MapExtentsComponent;

function PostBeginPlay()
{
	local MaterialInstanceConstant micMinimap;
	local MaterialInstanceConstant micCompassOverlay;

	Super.PostBeginPlay();
	
	micMinimap = MaterialInstanceConstant'GorodHUD.2DMap.micMinimap';
	micCompassOverlay = MaterialInstanceConstant'GorodHUD.2DMap.micCompass';

	Minimap = new(Outer) class'MaterialInstanceConstant';
	CompassOverlay  = new(Outer) class'MaterialInstanceConstant';
	
	Minimap.SetParent( micMinimap);
	CompassOverlay.SetParent( micCompassOverlay);
	
	MapCenter.X = Location.X;
	MapCenter.Y = Location.Y;
	MapRangeMin.X = MapCenter.X - MapExtentsComponent.SphereRadius;
	MapRangeMax.X = MapCenter.X + MapExtentsComponent.SphereRadius;
	MapRangeMin.Y = MapCenter.Y - MapExtentsComponent.SphereRadius;
	MapRangeMax.Y = MapCenter.Y + MapExtentsComponent.SphereRadius;
}

defaultproperties
{
	Begin Object Class=DrawSphereComponent Name=DrawSphere0
     	SphereColor=(B=0,G=255,R=0,A=255)
     	SphereRadius=1024.000000
	End Object
	MapExtentsComponent=DrawSphere0
	Components.Add(DrawSphere0)

	bForwardAlwaysUp=True
}