class Kamaz_SeqAct_CarEngineStop extends SequenceAction;
 
var() bool bFreeze;

event Activated()
{
	local SeqVar_Object ObjVar;
	local SeqVar_Bool BoolVar;
	local Kamaz_PlayerCar TheVehicle;
	local bool pFreeze;
	local bool pFreezeIsUsed;
	foreach LinkedVariables(class'SeqVar_Object', ObjVar, "Vehicle")
	{
		TheVehicle = Kamaz_PlayerCar(ObjVar.GetObjectValue());
		if (TheVehicle != None)
		{
			break;
		}
	}

	foreach LinkedVariables(class'SeqVar_Bool', BoolVar, "Freeze")
	{
		pFreeze= (BoolVar.bValue>0)? true :false;
		pFreezeIsUsed=true;
	}

	if(TheVehicle!=none)
		if(pFreezeIsUsed)
			TheVehicle.SetCarStoped(pFreeze);
		else
			TheVehicle.SetCarStoped(bFreeze);
}



DefaultProperties
{
		
	bCallHandler=false
	ObjCategory="Kamaz"
	ObjName="Car stop and freeze"
	VariableLinks(0)=(MinVars=1,MaxVars=1)
	VariableLinks(1)=(ExpectedType=class'SeqVar_Bool',LinkDesc="Freeze",MinVars=1,MaxVars=1)
	VariableLinks(2)=(ExpectedType=class'SeqVar_Object',LinkDesc="Vehicle",MinVars=1,MaxVars=1)
	bFreeze=false
}
