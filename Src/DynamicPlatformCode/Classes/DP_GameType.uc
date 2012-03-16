class DP_GameType extends UDKGame;

var DP_Signals objDPSignals;

event PostBeginPlay()
{
	super.PostBeginPlay();
	objDPSignals = spawn(class'DP_Signals');
	`warn("objDPSignals == none", objDPSignals == none);
}

DefaultProperties
{
	HUDType=class'DynamicPlatformCode.DP_HUD'
	PlayerControllerClass=class'DynamicPlatformCode.DP_PlayerController'
}
