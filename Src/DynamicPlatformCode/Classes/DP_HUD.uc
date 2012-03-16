class DP_HUD extends HUD;

var Font PlayerFont;
var Gorod_VehicleContent_Lada_12 refLadaCar;
var float fTime;

event PostBeginPlay()
{
	local Gorod_VehicleContent_Lada_12 refCar;
	
	super.PostBeginPlay();
	foreach AllActors(class 'Gorod_VehicleContent_Lada_12', refCar)
	{
		refLadaCar = refCar;
		break;
	}
	`warn("refLadaCar == none", refLadaCar == none);
}

simulated function Tick(float fDeltaTime)
{
	super.Tick(fDeltaTime);
	fTime += fDeltaTime;
}

function DrawHUD()
{
	super.DrawHUD();

	if (refLadaCar != none)
	{
		Canvas.Font = PlayerFont;
		Canvas.SetDrawColor(0x00, 0xff, 0x00);
		Canvas.SetPos(10, 10, 0);
		Canvas.DrawText("Time (secs) == " @ fTime @ "Roll == " @ refLadaCar.Rotation.Roll @ ", Pitch == " @ refLadaCar.Rotation.Pitch);
	}
}

DefaultProperties
{
	PlayerFont=MultiFont'UI_Fonts_Final.HUD.MF_Medium'
	fTime = 0.f
}
