class Kamaz_SeqAct_SetKamazLocation extends SequenceAction;

/** index of the seat of the vehicle the bot should use, or -1 for auto-select */
var() int SeatIndex;

event Activated()
{
	local SeqVar_Object ObjVar;
	local Actor Mark;
	local UDKVehicle TheVehicle;

	
	foreach LinkedVariables(class'SeqVar_Object', ObjVar, "Target")
	{
		Mark=Actor(ObjVar.GetObjectValue());
		if (Mark != None)
		{
			break;
		}
	}
	

	foreach LinkedVariables(class'SeqVar_Object', ObjVar, "Vehicle")
	{
		TheVehicle = UDKVehicle(ObjVar.GetObjectValue());
		if (TheVehicle != None)
		{
			break;
		}
	}
	/*
	foreach LinkedVariables(class'SeqVar_Vector', ObjVect, "Location")
	{
		loc = ObjVect.VectValue;
		break;
	}

	foreach LinkedVariables(class'SeqVar_Vector', ObjVect, "Rotation")
	{
		rot = ObjVect.VectValue;
		break;
	}
	*/




	if (TheVehicle == none || Mark==none )
	{
		ScriptLog("WARNING: Vehicle or mark variable for" @ self @ "is empty");
	}
	else
	{
		//rotator1.Yaw=rot.Y;

		TheVehicle.SetRotation(Mark.Rotation);
		TheVehicle.SetLocation(Mark.Location);
		
		TheVehicle.CollisionComponent.SetRBRotation(Mark.Rotation);
		TheVehicle.CollisionComponent.SetRBPosition(Mark.Location);

		
		
		
		
	}
}

defaultproperties
{
	bCallHandler=false
	ObjCategory="Kamaz"
	ObjName="SetKamazLocation"
	VariableLinks(0)=(MinVars=1,MaxVars=1)
	VariableLinks(1)=(ExpectedType=class'SeqVar_Object',LinkDesc="Vehicle",MinVars=1,MaxVars=1)
	//VariableLinks(2)=(ExpectedType=class'SeqVar_Vector',LinkDesc="Location",MinVars=1,MaxVars=1)
	//VariableLinks(3)=(ExpectedType=class'SeqVar_Vector',LinkDesc="Rotation",MinVars=1,MaxVars=1)
	SeatIndex=-1
}