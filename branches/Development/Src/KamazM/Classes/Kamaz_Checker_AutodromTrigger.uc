class Kamaz_Checker_AutodromTrigger extends Gorod_Trigger placeable;

var Gorod_ActorWithTriggers_Interface ActorWithTriggers;
var() Color TriggerColor;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	SetColor(TriggerColor);
}

event Touch(Actor Other, PrimitiveComponent OtherComp, Vector HitLocation, Vector HitNormal)
{
	if(ActorWithTriggers != none)
		ActorWithTriggers.OnTriggerTouch(self, Other);
}

event UnTouch(Actor Other)
{
	if(ActorWithTriggers != none)
		ActorWithTriggers.OnTriggerUnTouch(self, Other);
}

DefaultProperties
{
	TriggerColor = (R=255,G=255,B=0,A=255)

	Begin Object Name=MBox 
		HiddenGame = false
	End Object
}
