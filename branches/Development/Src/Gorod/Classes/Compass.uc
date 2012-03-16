class Compass extends Actor placeable implements(ICompass);

event PostBeginPlay()
{
	super.PostBeginPlay();
	`log("===================================",,'UTBook');
    `log("Compass Heading"@GetRadianHeading()@GetDegreeHeading(),,'UTBook');
	`log("===================================",,'UTBook');
}


/** Yaw в Радины */ 
function float GetRadianHeading()
{
	local Vector v;
	local Rotator r;
	local float f;
 
	r.Yaw = rotation.Yaw;   // a
	v = vector(r);          // b

	f = GetHeadingAngle(v); // c
	f = UnwindHeading(f);   // d

	while (f < 0)		    // e
		f += PI * 2.0f;

	return f;
} 

/** Из Радиан в Градусы */
function float GetDegreeHeading()
{
	local float f;

	f = GetRadianHeading();

	f *= RadToDeg;

	return f;
}

/** Значение рысканья */
function int GetYaw()
{
	return Rotation.Yaw;
}
/** Значние Ротатора*/					  
function Rotator GetRotator()
{
	return Rotation;
}
/** Значение ротатора в векторе */
function vector GetVectorizedRotator()
{
	return vector(Rotation);
}

DefaultProperties
{
	Begin Object Class=ArrowComponent Name=Arrow
		ArrowColor = (B=80,G=80,R=200,A=255)
		ArrowSize = 1.000000
		Name = "North Heading"
	End Object
	Components(0) = Arrow

	Begin Object Class=SpriteComponent Name=Sprite 
		Sprite=Texture2D'GorodHUD.2DMap.Compass'//Texture2D'UTBookTextures.compass'
		HiddenGame = True
		AlwaysLoadOnClient = False
		AlwaysLoadOnServer = False
		Name  = "Sprite"
	End Object
	Components(1) = Sprite

	bStatic   = True
	bHidden   = True
	bNoDelete = True
	bMovable  = False
}
