class CarX_Vehicle_FireCarTest_Content extends CarX_Vehicle_Pickup_Content;

/*var Zarnitza_AAA ForwardActor;
var float Offset;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	Offset = 200;
	ForwardActor = Spawn(class'Zarnitza_AAA', , , Location + Offset*Vector(Rotation));
}

simulated event Tick(float DeltaSeconds)
{
	super.Tick(DeltaSeconds);

	ForwardActor.SetLocation(Location + Offset*Vector(Rotation));
}*/

DefaultProperties
{
	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'Kamaz.SkelMeshes.Kamaz_skel'
		AnimTreeTemplate=AnimTree'Kamaz.AnimSets.AT_Kamaz_skel'
		PhysicsAsset=PhysicsAsset'Kamaz.SkelMeshes.PA_Kamaz_skel'
	End Object

	DrawScale=1.0
}
