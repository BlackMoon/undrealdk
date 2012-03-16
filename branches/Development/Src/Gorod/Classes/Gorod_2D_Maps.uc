class Gorod_2D_Maps extends GFxMoviePlayer;

var Vector locPlayer;

const MULTIPLIER = 94.54;
// Размер окна 2D карты в Пикселах
const SIZE_2DMAP = 300;

function bool Start(optional bool StartPaused = false)
{
	local bool Result;
	Result = super.Start(StartPaused);

	Advance(0.f);
	SetViewport(0, 0, SIZE_2DMAP, SIZE_2DMAP);
    SetViewScaleMode(SM_NoScale);
    SetAlignment(Align_TopRight);

	return Result;
}

function Vector2D CalcPos(Vector Location) 
{
	local Vector2D Result;
	
	// Коэффиценты для Карты City
	Result.x = 515 - Location.Y / MULTIPLIER;
	Result.y = Location.X / MULTIPLIER - 1608;

	return Result;
}

/** Указать текущую позицию игрока */
function Position(float X, float Y, int Pitch = 0)
{
	ActionScriptInt("Position");
}

function vPosition(Vector Location)
{
	local Vector2D vect2D;
	
	locPlayer = Location;

	vect2D = CalcPos(Location);
	Position(vect2D.X, vect2D.Y);
}

/** Указать позицию ботов */
function PositionTraffic(string ID, float X, float Y, float Velocity = 0)
{
	ActionScriptInt("PositionTraffic");
}

function vPositionTraffic(string id, Vector Location, Vector Velocity) 
{
	local Vector diffLocation;
	//local float diff, shift;
	//local float indent;
	
	diffLocation = Location - locPlayer;
	// Отсуп от Позиции игрока
	//indent = 1.5 * MULTIPLIER * SIZE_2DMAP;
	//diff = VSizeSq (diffLocation);
	diffLocation /= MULTIPLIER;

	//shift = Square(1.1 * MULTIPLIER * SIZE_2DMAP);
	if (Abs (diffLocation.X) < SIZE_2DMAP / 2 && Abs(diffLocation.Y) < SIZE_2DMAP / 2)
	{
		PositionTraffic(id, diffLocation.Y + SIZE_2DMAP / 2, SIZE_2DMAP / 2 - diffLocation.X, VSize(Velocity));
	}
}

DefaultProperties
{
	
	MovieInfo=SwfMovie'GorodHUD.Roads'
	bCaptureInput = false
}
