class Kamaz_Checker_AutodromTrigger_Hint extends Kamaz_Checker_AutodromTrigger;

/** Тип сообщения, посылаемого при касании данного триггера */
enum HintMessageType
{
	// поверните налево
	HMT_DRIVE_LEFT,
	// поверните направо
	HMT_DRIVE_RIGHT,
	// проедьте прямо
	HMT_DRIVE_FORWARD
};

var() HintMessageType HintMessage;

var bool bEnabled;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	SetHidden(true);
}

event Touch(Actor Other, PrimitiveComponent OtherComp, Vector HitLocation, Vector HitNormal)
{
	local float product;
	local Rotator rot;

	if(!bEnabled) return;
	if(Kamaz_PlayerCar(Other) == none) return;

	rot.Yaw = Rotation.Yaw + 16384; // + DegToUnrRot*90

	product = Vector(rot) dot Vector(Other.Rotation);

	/**подъехали с лицевов стороны знака?*/
	if (product >= 0 && product < 1)
	{
		super.Touch(Other, OtherComp, HitLocation, HitNormal);
		bEnabled = false;
	}
}

DefaultProperties
{
	HintMessage = HMT_DRIVE_FORWARD;
	bEnabled = false;
}
