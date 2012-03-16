class Kamaz_SeqEvent_MatineeStop extends SequenceEvent;

var int Count;

event Activated()
{
	Count++;
}

DefaultProperties
{
	ObjName="Matinee Stop"
	ObjCategory="Kamaz"

	VariableLinks.Empty;
	VariableLinks(0)=(ExpectedType=class'SeqVar_Bool',LinkDesc="Value")


	OutputLinks(0) = (LinkDesc="Stop");
	bAutoActivateOutputLinks=true;

	bPlayerOnly=false;
	MaxTriggerCount=0;
	bClientSideOnly=false;
	Count=0;
}
