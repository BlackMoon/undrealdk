class Zarnitza_VehicleTouchHelperActor extends Actor;

var private{private} CylinderComponent CylinderComponent;

var PlayerController PC;

/*event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	`log(self @" Touched " @ Other);
}

event UnTouch( Actor Other )
{
	`log(self @" UNTouched " @ Other);
}*/

simulated event PostBeginPlay()
{
	//SetPhysics(PHYS_RigidBody);
	//SetCollisionType(COLLIDE_TouchAll);
	super.PostBeginPlay();
}

DefaultProperties
{
// Add a cylinder component to be used for collision
	Begin Object Class=CylinderComponent Name=CollisionCylinder
		// These get overwritten on load or spawn
		CollisionRadius=20.000000
		CollisionHeight=1000.000000
		CollideActors=true
		BlockActors=false
		// Don't want the cylinder to block bullets
		BlockZeroExtent=false
		BlockNonZeroExtent=true
		HiddenGame = false
		HiddenEditor = false
	End Object
	CollisionComponent=CollisionCylinder
	CylinderComponent=CollisionCylinder
	Components.Add(CollisionCylinder)

	/*Begin Object Class=StaticMeshComponent Name=ArrowM
		StaticMesh = StaticMesh'Raznoe.Arrow'
	end object

	Components.Add(ArrowM)*/

	CollisionType = COLLIDE_TouchAll
	Physics = PHYS_Custom//PHYS_RigidBody
	bCollideActors = true
	//bBlockActors = true
}
