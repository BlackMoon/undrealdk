class GorodSeqAct_EnterVehicle extends SequenceAction;

/** index of the seat of the vehicle the bot should use, or -1 for auto-select */
var() int SeatIndex;

event Activated()
{
	local SeqVar_Object ObjVar;
	local Pawn Target;
	local UDKVehicle TheVehicle;

	foreach LinkedVariables(class'SeqVar_Object', ObjVar, "Vehicle")
	{
		TheVehicle = UDKVehicle(ObjVar.GetObjectValue());
		if (TheVehicle != None)
		{
			break;
		}
	}
	if (TheVehicle == None)
	{
		ScriptLog("WARNING: Vehicle variable for" @ self @ "is empty");
	}
	else
	{
		// get the pawn(s) that should enter the vehicle
		foreach LinkedVariables(class'SeqVar_Object', ObjVar, "Target")
		{
			Target = GetPawn(Actor(ObjVar.GetObjectValue()));
			
			if (Target != None)
			{
				if(TheVehicle.Driver == None)
				{
					CarX_Vehicle_Kamaz_4x4( TheVehicle).TryToDrive(Target);
				}
			}
		}
	}
}

defaultproperties
{
	bCallHandler=false
	ObjCategory="Gorod"
	ObjName="Enter Vehicle"
	VariableLinks(0)=(MinVars=1,MaxVars=1)
	VariableLinks(1)=(ExpectedType=class'SeqVar_Object',LinkDesc="Vehicle",MinVars=1,MaxVars=1)
	SeatIndex=-1
}
