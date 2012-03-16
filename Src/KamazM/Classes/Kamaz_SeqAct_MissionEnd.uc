class Kamaz_SeqAct_MissionEnd extends SequenceAction;

event Activated()
{
	local WorldInfo w;
	w =self.GetWorldInfo();
	Kamaz_Game( w.Game).EndMission();
}

defaultproperties
{
	bCallHandler=false
	ObjCategory="Kamaz"
	ObjName="Mission End"
	VariableLinks(0)=(MinVars=1,MaxVars=1)
	VariableLinks(1)=(ExpectedType=class'SeqVar_Object',LinkDesc="Pawn",MinVars=1,MaxVars=1)
}