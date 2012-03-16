class ObjectSynchronizerHelperOfFireAlarmScene extends Actor placeable;

var () SkeletalMeshActorMAT FireFighter[3];
var () SkeletalMeshActorMAT Kamaz;
var () CameraActor Camera;


function PostBeginPlay()
{
	super.PostBeginPlay();
	Helping();
}

function Helping()
{
	// 1. ��������  ���������� � ��������
	local Vector FireFighterLocation[3];
	local Rotator FireFighterRotation[3];
	local Vector CameraLocation;
	local Rotator CameraRotation;
	local int i;
	
	for(i=0;i<3;i++)
	{
		// 1.1 �������� ���� �������� ���������� ������������ ���� �������� ������
		FireFighterRotation[i]=FireFighter[i].Rotation-Kamaz.Rotation;
		// 1.2 ������� ����� �� ������ ����������, ������� ���������� ������������ ������
		FireFighterLocation[i]=FireFighter[i].Location+(-1*Kamaz.Location);
		// 1.3 �������� ����� � ���������� ������ ������, ������� ������ ��������
		FireFighterLocation[i]=FireFighterLocation[i]>>(-1*kamaz.Rotation);
		// 2. ������� � �������.
		`log(FireFighter[i].Name);
		`log(FireFighterLocation[i]);
		`log(FireFighterRotation[i].Yaw * UnrRotToDeg);
	}
	CameraRotation=Camera.Rotation-Kamaz.Rotation;
	CameraLocation=Camera.Location+(-1*Kamaz.Location);
	CameraLocation=CameraLocation>>(-1*kamaz.Rotation);

	`log(Camera.Name);
	`log(CameraLocation);
	`log(CameraRotation.Yaw * UnrRotToDeg);
}

DefaultProperties
{
	Begin Object Class=StaticMeshComponent Name=StaticMashLabel
		StaticMesh=StaticMesh'NodeBuddies.3D_Icons.NodeBuddy_LeanRightMPref';
		bUsePrecomputedShadows = true;
	End Object
	Components.Add(StaticMashLabel);
}
