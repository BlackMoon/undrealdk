class SeqEvent_MissionObjectsHide extends SequenceEvent;

var int Count;

event Activated()
{
	Count++;
}

DefaultProperties
{
	ObjName="MissionObjectsHide"
	ObjCategory="Gorod"

	VariableLinks.Empty;
	VariableLinks(0)=(ExpectedType=class'SeqVar_Bool', LinkDesc="Value")


	OutputLinks(0) = (LinkDesc="Started");
	bAutoActivateOutputLinks=true;

	bPlayerOnly=false;
	MaxTriggerCount=0;
	bClientSideOnly=false;
	Count=0;
}