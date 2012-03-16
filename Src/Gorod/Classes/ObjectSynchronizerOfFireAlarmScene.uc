class ObjectSynchronizerOfFireAlarmScene extends Actor placeable;

struct FireFighter
{
	var () Vector dVector;
	var () Rotator dRotator;
	var () SkeletalMeshActorMAT FireFighter;
};
struct CameraStruct
{
	var () Vector dVector;
	var () Rotator dRotator;
	var () CameraActor Camera;
};

var StaticMeshComponent label;
var () CameraStruct Camera;
var () FireFighter Fighter[3];
var () SkeletalMeshActor kamaz;
var () bool bEnable;


function PostBeginPlay()
{
	super.PostBeginPlay();
}

function Synchronize()
{
	local Vector FireFighterLocation[3];
	local Rotator FireFighterRotation[3];
	local Vector CameraLocation;
	local Rotator CameraRotation;
	local int i;
	

	if(bEnable)
	{
		// 1 перенести пожарников по заданным dx и dy
		for (i=0;i<3; i++)
		{
			FireFighterLocation[i]=Fighter[i].dVector;
		}
		CameraLocation=Camera.dVector;

		// 2 задать угол поворота пожарникам
		for (i=0;i<3; i++)
		{
			FireFighterRotation[i]=Fighter[i].dRotator;
		}
		CameraRotation=Camera.dRotator;

		// 3 повернуть камаз и пожарников обратно
		for (i=0;i<3;i++)
		{
			FireFighterLocation[i]=FireFighterLocation[i]>>kamaz.Rotation;

			FireFighterRotation[i]= Fighter[i].dRotator + kamaz.Rotation;
			Fighter[i].FireFighter.SetRotation(FireFighterRotation[i]);
		}
		CameraLocation=CameraLocation>>kamaz.Rotation;
		CameraRotation=Camera.dRotator+kamaz.Rotation;
		Camera.Camera.SetRotation(CameraRotation);

		// 4 сместить пожарников
		for (i=0;i<3; i++)
		{
			Fighter[i].FireFighter.SetLocation(FireFighterLocation[i]+kamaz.Location);
		}
		Camera.Camera.SetLocation(CameraLocation+kamaz.Location);
		
	}
}




DefaultProperties
{
	Begin Object Class=StaticMeshComponent Name=StaticMashLabel
		StaticMesh=StaticMesh'NodeBuddies.3D_Icons.NodeBuddy_Climb';
		bUsePrecomputedShadows = true;
		
	End Object
	label=StaticMashLabel;
	Components.Add(StaticMashLabel);
	
}