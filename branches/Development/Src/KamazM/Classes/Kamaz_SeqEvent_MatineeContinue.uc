class Kamaz_SeqEvent_MatineeContinue extends SequenceEvent;

var int Count;

event Activated()
{
	Count++;
}

DefaultProperties
{
	ObjName="Matinee continue"
	ObjCategory="Kamaz"

	VariableLinks.Empty;
	VariableLinks(0)=(ExpectedType=class'SeqVar_Bool',LinkDesc="Value")


	OutputLinks(0) = (LinkDesc="Continue");
	bAutoActivateOutputLinks=true;

	bPlayerOnly=false;
	MaxTriggerCount=0;
	bClientSideOnly=false;
	Count=0;
}
