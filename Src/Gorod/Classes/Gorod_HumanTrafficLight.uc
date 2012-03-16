/** 
 * ����� ��������� ������ ��������� ��� ���������
 */
class Gorod_HumanTrafficLight extends Actor placeable;

var(TrafficLight) StaticMeshComponent Mesh;

var repnotify bool RedLightOn;
var repnotify bool GreenLightOn;

/** ���� ������ ��������� */
var(TrafficLight) bool Working;

/** �������������� ���������� �������� */
var(TrafficLight) array<Gorod_CrossRoadsTrigger> ControlledTriggers;

/** �������������� ���� ��� ����� */
var(TrafficLight) array<Gorod_BasePath> Paths;

/** ����� ������� �������� ����� */
var(TrafficLight) float RedLightTime;

/** ����� ������� �������� ����� */
var(TrafficLight) float GreenLightTime;

/** ���� ���������� ���� ����, ������� ���� ��������� ������ ��� ������ ������ ��������� */
var(TrafficLight) bool StartRedLightOn;

/** ��������� ��� ���������� */
var MaterialInstanceConstant RedLightMatInst;
var MaterialInstanceConstant GreenLightMatInst;

replication
{
	if(bNetDirty)
		RedLightOn, GreenLightOn;
}

//========================================================================================================================================================
simulated event ReplicatedEvent(name v)
{
	if(v == 'RedLightOn' || v == 'GreenLightOn')
		UpdateAllLights();
	else
		super.ReplicatedEvent(v);
}

simulated function InitMaterials()
{
	RedLightMatInst = new class'MaterialInstanceConstant';
	RedLightMatInst.SetParent(Mesh.GetMaterial(1));
	Mesh.SetMaterial(1, RedLightMatInst);
	
	GreenLightMatInst = new class'MaterialInstanceConstant';
	GreenLightMatInst.SetParent(Mesh.GetMaterial(0));
	Mesh.SetMaterial(0, GreenLightMatInst);
}


simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	InitMaterials();
	UpdateAllLights();

	if(Working)
	{
		if(StartRedLightOn)
		{
			GotoState ('Red');
		}
		else
		{
			GotoState ('Green');
		}
	}
	else 
		GotoState ('Offline');
}


/** UpdatePaths - ��������� ��������� ����� �� ����������� (��������� ��� ���������, � ����������� �� ��������� block) */
function UpdatePaths(bool block)
{
	local Gorod_BasePath path;
	foreach Paths(path)
		path.PathState = (block ? PS_None : PS_Opened);
}

/** UpdateTriggers - ��������� ��������� ��������� �� ����������� (��������� ��� ���������, � ����������� �� ��������� block) */
simulated function UpdateTriggers(bool block)
{
	local Gorod_CrossRoadsTrigger trg;

	foreach ControlledTriggers(trg)
	{
		trg.SetColor(block ? trg.RedColor : trg.GreenColor);
		trg.IsBlocked = block;
	}
}

simulated event Tick( FLOAT DeltaSeconds ) 
{
	if(Role == ROLE_Authority)
		GotoState(Working ? 'Red' : 'Offline');
}
 
/** UpdateLights - ��������� �������� ����� ���������, � ����������� �� �������� ��������� ������������� */
simulated function UpdateAllLights()
{
	RedLightMatInst.SetScalarParameterValue('Off', RedLightOn ? 0 : 1);
	GreenLightMatInst.SetScalarParameterValue('Off', GreenLightOn ? 0 : 1);
}

/** ToggleRedLight - ������������� ���� ���������� �������� ����� ��������� */
function ToggleRedLight(bool turnOn)
{
	if(RedLightOn != turnOn)
	{
		RedLightOn = turnOn;
		RedLightMatInst.SetScalarParameterValue('Off', RedLightOn ? 0 : 1);
	}
}

/** ToggleRedLight - ������������� ���� ���������� �������� ����� ��������� */
function ToggleGreenLight(bool turnOn)
{
	if(GreenLightOn != turnOn)
	{
		GreenLightOn = turnOn;
		GreenLightMatInst.SetScalarParameterValue('Off', GreenLightOn ? 0 : 1);
	}
}

state Red
{
ignores Tick;
Begin:
	UpdateTriggers(false);

	ToggleRedLight (true);
	Sleep (RedLightTime);
	ToggleRedLight (false);
	GotoState ('Green');
}


state Green
{
//simulated event Tick( FLOAT DeltaSeconds );
ignores Tick;
Begin:
	UpdateTriggers(true);

	ToggleGreenLight (true);
	
	Sleep (GreenLightTime);
	ToggleGreenLight (false);
	
	GotoState ('Red');
}

auto state Offline
{
ignores Tick;
Begin:

	ToggleGreenLight (false);
	ToggleRedLight (false);
	
	Sleep(100);
	GoTo('Begin');
}

Defaultproperties
{
	Begin Object Class=StaticMeshComponent Name=MBox 
		CollideActors = true
		BlockActors = true
		RBChannel=RBCC_GameplayPhysics
		RBCollideWithChannels=(Default=TRUE,BlockingVolume=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE,Vehicle=TRUE)
		bAllowApproximateOcclusion=TRUE
		bForceDirectLightMap=TRUE
		bUsePrecomputedShadows=TRUE
	End Object
	Components.Add(MBox);
	Mesh = MBox
	CollisionComponent = MBox

	RedLightOn = false
	//YellowLightOn = false
	GreenLightOn = false

	Working = false;

	//YellowLightFlickeringTime = 1.0;

	RedLightTime = 20.0
	GreenLightTime = 20.0

	bNoDelete = true
	RemoteRole = ROLE_SimulatedProxy

	bMovable=false
	bCollideActors=true
	bBlockActors=true
	bCollideWhenPlacing=false
}
