class SeqAct_FireBug extends SequenceAction;

event Activated()
{
	local SeqVar_Object ObjVar;
	local SkeletalMeshActor TargetObj;
 
	foreach LinkedVariables(class'SeqVar_Object', ObjVar, "Target")
	{
		TargetObj = SkeletalMeshActor(ObjVar.GetObjectValue());
		if (TargetObj != None)
		{
			break;
		}
	}

	if(TargetObj==none )
		return;

	TargetObj.SkeletalMeshComponent.bEnableFullAnimWeightBodies=true;
	
}




DefaultProperties
{
	bCallHandler=false
	ObjCategory="Gorod"
	ObjName="Firebag"
	VariableLinks(0)=(MinVars=1,MaxVars=1)
	VariableLinks(2)=(ExpectedType=class'SeqVar_Object',LinkDesc="Target",MinVars=1,MaxVars=1)
}
