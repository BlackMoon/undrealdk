class Gorod_PlayerInput extends PlayerInput;

simulated function BOOL InputKey( INT ControllerId, Name Key, EInputEvent Event, FLOAT AmountDepressed = 1.f, BOOL bGamepad = FALSE )
{
	`log( "InputKey() Key = "@Key @" Event = "@Event @" AmountDepressed = "@AmountDepressed@" bGamepad = "@bGamepad );
	
	return false; 
}

simulated function BOOL InputAxis(INT ControllerId, Name Key, FLOAT Delta, FLOAT DeltaTime, BOOL bGamepad=FALSE)
{
	`log( "InputAxis() Key = "@Key @"Delta = "@Delta @"DeltaTime = "@DeltaTime@ " bGamepad = "@bGamepad );
	return false;
}


DefaultProperties
{
}
