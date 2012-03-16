class Kamaz_SeqAct_SetSirenaSignal extends SequenceAction;


/** index of the seat of the vehicle the bot should use, or -1 for auto-select */
var() int SeatIndex;

event Activated()
{
	local SeqVar_Object ObjVar;
	local CarX_Vehicle TheVehicle;
	local SeqVar_Bool SeqVarBool;
	local bool Enable;

	foreach LinkedVariables(class'SeqVar_Object', ObjVar, "Vehicle")
	{
		TheVehicle = CarX_Vehicle(ObjVar.GetObjectValue());
		if (TheVehicle != None)
		{
			break;
		}
	}

	foreach LinkedVariables(class'SeqVar_Bool', SeqVarBool, "Enable")
	{
		Enable =bool (SeqVarBool);
	}


	if (TheVehicle == None)
	{
		ScriptLog("WARNING: Vehicle variable for" @ self );
	}
	else
	{
		TheVehicle.setSirenaSignal(Enable);
	}
}

defaultproperties
{
	bCallHandler=false
	ObjCategory="Gorod"
	ObjName="Set sirena signal"
	VariableLinks(0)=(MinVars=1,MaxVars=1)
	VariableLinks(1)=(ExpectedType=class'SeqVar_Object',LinkDesc="Vehicle",MinVars=1,MaxVars=1)
	VariableLinks(2)=(ExpectedType=class'SeqVar_Bool',LinkDesc="Enable",MinVars=1,MaxVars=1)
}
