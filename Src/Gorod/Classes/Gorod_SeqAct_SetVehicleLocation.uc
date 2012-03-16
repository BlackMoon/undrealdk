class Gorod_SeqAct_SetVehicleLocation extends SequenceAction;

/** index of the seat of the vehicle the bot should use, or -1 for auto-select */
var() int SeatIndex;

event Activated()
{
	local SeqVar_Object ObjVar;
	local Actor Mark;
	//local Actor TheVehicle;

	local UTVehicle TheVehicle;
	local UTVehicleFactory Factory;
	local Vehicle SimpleVehicle;
	
	
	foreach LinkedVariables(class'SeqVar_Object', ObjVar, "Target")
	{
		Mark=Actor(ObjVar.GetObjectValue());
		if (Mark != None)
		{
			break;
		}
	}
	

	foreach LinkedVariables(class'SeqVar_Object', ObjVar, "Vehicle/Vehicle factory")
	{
		// попробуем получить UTVehicle или UTVehicleFactory
		TheVehicle = UTVehicle(ObjVar.GetObjectValue());
		if (TheVehicle == None)
		{
			Factory = UTVehicleFactory(ObjVar.GetObjectValue());
			if (Factory != None)
			{
				TheVehicle = UTVehicle(Factory.ChildVehicle);
			}
		}
		if (TheVehicle != None)
		{
			break;
		}

		// попробуем получить объект транспорта из класса Vehicle
		SimpleVehicle = Vehicle(ObjVar.GetObjectValue());
		if (SimpleVehicle != None)
		{
			break;
		}
	}
	
	// перемещаем
	if ( Mark!=none )
	{
		if(SimpleVehicle!= none || TheVehicle!=none )
		{
			if(TheVehicle!=none)
			{
				TheVehicle.SetRotation(Mark.Rotation);
				TheVehicle.SetLocation(Mark.Location);
		
				TheVehicle.CollisionComponent.SetRBRotation(Mark.Rotation);
				TheVehicle.CollisionComponent.SetRBPosition(Mark.Location);
			}
			else
			{
				SimpleVehicle.SetRotation(Mark.Rotation);
				SimpleVehicle.SetLocation(Mark.Location);
		
				SimpleVehicle.CollisionComponent.SetRBRotation(Mark.Rotation);
				SimpleVehicle.CollisionComponent.SetRBPosition(Mark.Location);
			}
		}
		else
		{
			ScriptLog("WARNING:  Vehicle/Vehicle factory variable for" @ self @ "is empty");
		}
		
	}
	else
	{
		ScriptLog("WARNING:  Mark variable for" @ self @ "is empty");
	}
}

defaultproperties
{
	bCallHandler=false
	ObjCategory="Gorod"
	ObjName="Set vehicle location"
	VariableLinks(0)=(MinVars=1,MaxVars=1)
	VariableLinks(1)=(ExpectedType=class'SeqVar_Object',LinkDesc="Vehicle/Vehicle factory",MinVars=1,MaxVars=1)
	SeatIndex=-1
}