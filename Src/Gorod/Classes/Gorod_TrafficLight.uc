/** 
 * ����� ��������� ������ ���������
 */
class Gorod_TrafficLight extends Actor placeable;

var(TrafficLight) StaticMeshComponent Mesh;

/** ��������� �������������� ������ */
struct AdditionalSection
{
	// ��������� ��� ���������� ������ �������������� ������
	var() bool On;

	// ���� ��������� �������� �������������� ������ (true ���� ��������)
	var bool isGlow;

	// ����, �����������, ����� ������ �������� ����� �� ����(������� ��� �������) �������� ��������� ���.������ (�������� StartTimeDisplacement)
	var() bool StartAfterRed;

	// ����� ��������
	var() float GlowTime;

	// �������� �������, �� ��������� �������� ����������� ��������� �������� ���.������
	var() float StartTimeDisplacement;

	// �������������� ������� ��������
	var array<Gorod_CrossRoadsTrigger> Triggers;

	// �������������� ������� ����
	var array<Gorod_BasePath> Paths;

	structdefaultproperties
	{
		On = true
		isGlow = false
		StartAfterRed = false
		GlowTime = 5.0
		StartTimeDisplacement = 0.0
	}
};

/** ��������� ��� �������� ���������� � ��������� ��������� ��� �������� �� ���� */ 
struct TrafficLightsInformation
{
	var bool RedLightOn;
	var bool YellowLightOn;
	var bool GreenLightOn;
};

var int i;

/** ���������� � ��������� ��������� (������������ ��� ������������� � ����) */ 
var repnotify TrafficLightsInformation TrafficLightsInfo;

/** ���� ������ ��������� */
var(TrafficLight) protected bool Working;

/** ������� ������� ������� ����� */
var(TrafficLight) float YellowLightFlickeringTime;
/** ������� ������� �������� ����� */
var(TrafficLight) float GreenLightFlickeringTime;

var private float YellowLightLastSwitchTime;

/** �������������� ���������� �������� */
var(TrafficLight) array<Gorod_CrossRoadsTrigger> ControlledTriggers;

/** �������������� ���� ��� ����� */
var(TrafficLight) array<Gorod_BasePath> Paths;

/** ����� ������� �������� ����� */
var(TrafficLight) float RedLightTime;
/** ����� ������� ������� ����� */
var(TrafficLight) float YellowLightTime;
/** ����� ������� �������� ����� */
var(TrafficLight) float GreenLightTime;

/** ������ ������� ��������� ����� ����� */
var private float LastSwitchTime;

/** ���� ���������� ���� ����, ������� ���� ��������� ������ ��� ������ ������ ��������� */
var(TrafficLight) bool StartRedLightOn;

/** ����� ���. ������ */
var(TrafficLight) AdditionalSection LeftSection;

/** ������ ���. ������ */
var(TrafficLight) AdditionalSection RightSection;

/** ��������� ��� ���������� */
var MaterialInstanceConstant RedLightMatInst;
var MaterialInstanceConstant YellowLightMatInst;
var MaterialInstanceConstant GreenLightMatInst;
var MaterialInstanceConstant LeftSectMatInst;
var MaterialInstanceConstant RightSectMatInst;

var	const LinearColor NullColor, RedColor, GreenColor, YellowColor;
var LinearColor col;

replication
{
	if(bNetDirty && (Role == ROLE_Authority))
		TrafficLightsInfo;
}

simulated event ReplicatedEvent(name varName)
{
	if(varName == 'TrafficLightsInfo')
		UpdateAllLights();
	else
		super.ReplicatedEvent(varName);
}

/** ������������� ���.���������, ������ ���������� �������� � ����� ������ ���� */
simulated function InitMaterials()
{
	RedLightMatInst = new class'MaterialInstanceConstant';
	RedLightMatInst.SetParent(Mesh.GetMaterial(0));
	Mesh.SetMaterial(0, RedLightMatInst);

	YellowLightMatInst = new class'MaterialInstanceConstant';
	YellowLightMatInst.SetParent(Mesh.GetMaterial(1));
	Mesh.SetMaterial(1, YellowLightMatInst);
	
	GreenLightMatInst = new class'MaterialInstanceConstant';
	GreenLightMatInst.SetParent(Mesh.GetMaterial(2));
	Mesh.SetMaterial(2, GreenLightMatInst);

	LeftSectMatInst = new class'MaterialInstanceConstant';
	LeftSectMatInst.SetParent(Mesh.GetMaterial(3));
	Mesh.SetMaterial(3, LeftSectMatInst);

	RightSectMatInst = new class'MaterialInstanceConstant';
	RightSectMatInst.SetParent(Mesh.GetMaterial(4));
	Mesh.SetMaterial(4, RightSectMatInst);
}

function setWorking(bool value)
{
	if (Working != value)
	{
		Working = value;
		if(Working)
			GotoState (StartRedLightOn ? 'Red' : 'Green');
		else 
			GotoState ('YellowFlash');
	}
}
//========================================================================================================================================================

simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	InitMaterials();
	UpdateAllLights();
	LastSwitchTime = WorldInfo.TimeSeconds;
	
	if(Working)
	{
		if(StartRedLightOn)
		{
			GotoState ('Red');
			UpdatePaths(true);
		}
		else
		{
			GotoState ('Green');
			UpdatePaths(true);
		}
	}
	else 
		GotoState ('YellowFlash');
}

/** UpdatePaths - ��������� ��������� ����� �� ����������� (��������� ��� ���������, � ����������� �� ��������� block) */
function UpdatePaths(bool block)
{
	local Gorod_BasePath path;
	
	foreach Paths(path)
	{
		if(block)
			path.Close();
		else
			path.Open();
	}
}

/** UpdateTriggers - ��������� ��������� ��������� �� ����������� (��������� ��� ���������, � ����������� �� ��������� block) */
simulated function UpdateTriggers(bool block)
{
	local Gorod_CrossRoadsTrigger trg;

	foreach ControlledTriggers(trg)
	{
		if(!trg.bControlByLeftSection && !trg.bControlByRightSection)
		{
			if(block)
				trg.SetColor(trg.RedColor);
			else
				trg.SetColor(trg.GreenColor);
			trg.IsBlocked = block;
		}
		
	}
}

/** ���������� ��������� �������������� ������ ���.������� ��������� */
simulated function UpdateRightSectionTriggers()
{
	local Gorod_CrossRoadsTrigger trg;

	foreach RightSection.Triggers(trg)
	{
		if(RightSection.isGlow)
		{
			trg.SetColor(trg.GreenColor);
		}
		else
		{
			trg.SetColor(trg.RedColor);
		}

		trg.IsBlocked = !RightSection.isGlow;
	}
}

/** ���������� ��������� �������������� ����� ���.������� ��������� */
simulated function UpdateLeftSectionTriggers()
{
	local Gorod_CrossRoadsTrigger trg;

	foreach LeftSection.Triggers(trg)
	{
		if(LeftSection.isGlow)
		{
			trg.SetColor(trg.GreenColor);
		}
		else
		{
			trg.SetColor(trg.RedColor);
		}

		trg.IsBlocked = !LeftSection.isGlow;
	}
}

/** ���������� ��������� ����� �������������� ����� ���.������� ��������� */
simulated function UpdateLeftSectionPaths(bool turnOn)
{
	local Gorod_BasePath P;

	// ���� ������ �� ��������, ������ �� ������
	if(!LeftSection.On)
		return;

	// ���� ������ ���������� ��� ����� ������ ����
	if(turnOn)
	{
		// ��������� ��������������� ����
		foreach LeftSection.Paths(P)
			P.Open();
	}
	else
	{
		// ��������� ��������������� ����
		foreach LeftSection.Paths(P)
			P.Close();
	}
}

/** ���������� ��������� ����� �������������� ������ ���.������� ��������� */
simulated function UpdateRightSectionPaths(bool turnOn)
{
	local Gorod_BasePath P;

	if(!RightSection.On)
		return;

	// ���� ������ ����������
	if(turnOn)
	{
		// ��������� ��������������� ����
		foreach RightSection.Paths(P)
			P.Open();
	}
	else
	{
		// ��������� ��������������� ����
		foreach RightSection.Paths(P)
			P.Close();
	}
}

simulated event Tick( FLOAT DeltaSeconds ) 
{
	if(Role != ROLE_Authority)
	{
		return;
	}

	if(Working == true)
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
	{
		GotoState ('YellowFlash');
	}

	// ����� - �������� ��������
}

/** UpdateLights - ��������� �������� ����� ���������, � ����������� �� �������� ��������� ������������� */
simulated function UpdateAllLights()
{
	if(TrafficLightsInfo.RedLightOn == true)
		col = RedColor;
	else
		col = NullColor;
	RedLightMatInst.SetVectorParameterValue('Color', col);

	//=============================================
	if(TrafficLightsInfo.YellowLightOn == true)
		col = YellowColor;
	else
		col = NullColor;		
	YellowLightMatInst.SetVectorParameterValue('Color', col);

	//=============================================================
	if(TrafficLightsInfo.GreenLightOn == true)
		col = GreenColor;
	else
		col = NullColor;	
	GreenLightMatInst.SetVectorParameterValue('Color', col);

	// ��������� ��������� ���. ������
	if(LeftSection.On)
	{
		if(LeftSection.isGlow)
			col = GreenColor;
		else
			col = NullColor;
		LeftSectMatInst.SetVectorParameterValue('Color', col);
	}

	if(RightSection.On)
	{
		if(RightSection.isGlow)
		col = GreenColor;
		else
			col = NullColor;

		RightSectMatInst.SetVectorParameterValue('Color', col);
	}
}

/** 
 *  ToggleRedLight - ������������� ���� ���������� �������� ����� ��������� */
function ToggleRedLight(bool turnOn)
{
	if(TrafficLightsInfo.RedLightOn != turnOn)
	{
		TrafficLightsInfo.RedLightOn = turnOn;
		col = TrafficLightsInfo.RedLightOn ? RedColor : NullColor;
		RedLightMatInst.SetVectorParameterValue('Color', col);
	}
}

/** 
 *  ToggleRedLight - ������������� ���� ���������� ������� ����� ��������� */
function ToggleYellowLight(bool turnOn)
{
	if(TrafficLightsInfo.YellowLightOn != turnOn)
	{
		TrafficLightsInfo.YellowLightOn = turnOn;
		col = TrafficLightsInfo.YellowLightOn ? YellowColor : NullColor;
		YellowLightMatInst.SetVectorParameterValue('Color', col);
	}
}

/** 
 *  ToggleRedLight - ������������� ���� ���������� �������� ����� ��������� */
function ToggleGreenLight(bool turnOn)
{
	if(TrafficLightsInfo.GreenLightOn != turnOn)
	{
		TrafficLightsInfo.GreenLightOn = turnOn;
		col = TrafficLightsInfo.GreenLightOn  ? GreenColor : NullColor;
		GreenLightMatInst.SetVectorParameterValue('Color', col);
	}
}

/**  ��������� ��������� ���. ������ */
function ToggleLeftSectionLight(bool turnOn)
{
	if(LeftSection.On  && LeftSection.isGlow != turnOn)
	{
		LeftSection.isGlow = turnOn;			
		col = LeftSection.isGlow ? GreenColor : NullColor;
		LeftSectMatInst.SetVectorParameterValue('Color', col);
	}

	UpdateLeftSectionTriggers();
	UpdateLeftSectionPaths(turnOn);
}


/**  ��������� ��������� ���. ������ */
function ToggleRightSectionLight(bool turnOn)
{
	if(RightSection.On && RightSection.isGlow != turnOn)
	{
		RightSection.isGlow = turnOn;
		col = RightSection.isGlow ? GreenColor : NullColor;
		RightSectMatInst.SetVectorParameterValue('Color', col);
	}

	UpdateRightSectionTriggers();
	UpdateRightSectionPaths(turnOn);
}


/** ������� */
state Green 
{
	simulated event Tick( FLOAT DeltaSeconds ); 
Begin:
	// ���������� ����������� ���������
	UpdateTriggers(false);
	// ���������� �����
	UpdatePaths(false);
	
	ToggleGreenLight(true);

	// ������
	if (LeftSection.On && LeftSection.StartAfterRed)
	{
		ToggleLeftSectionLight(true);
	}
	if (RightSection.On && RightSection.StartAfterRed)
	{
		ToggleRightSectionLight(true);
	}

	
	Sleep(GreenLightTime/2); // -PAUSE / 2-------------------------------------

	
	if (LeftSection.On && !LeftSection.StartAfterRed)
	{
		ToggleLeftSectionLight(false);
	}
	if (RightSection.On && !RightSection.StartAfterRed)
	{
		ToggleRightSectionLight(false);
	}
	
	Sleep(GreenLightTime/2); // -PAUSE / 2-------------------------------------
	
	ToggleGreenLight(false);
	GotoState('GreenFlash');
}

/** �������� ������� */
state GreenFlash
{
	simulated event Tick( FLOAT DeltaSeconds );
Begin:
	for (i = 0; i < 6; i++)
	{
		ToggleGreenLight(!TrafficLightsInfo.GreenLightOn);
		Sleep(GreenLightFlickeringTime); // -PAUSE 0.5 sec -------------------------------------
	}
	ToggleGreenLight(false);

	// ���������� ����������� ���������
	UpdateTriggers(true);
	// ���������� �����
	UpdatePaths(true);

	GotoState('Yellow');
}

state Yellow
{
	simulated event Tick( FLOAT DeltaSeconds );

Begin:
	ToggleYellowLight (true);
	Sleep(YellowLightTime); // -PAUSE 2 sec -------------------------------------
	
	ToggleYellowLight (false);
	
	GotoState('Red');
}

state YellowFlash
{
	simulated event Tick( FLOAT DeltaSeconds );

Begin:
	ToggleYellowLight (!TrafficLightsInfo.YellowLightOn);
	Sleep(YellowLightFlickeringTime); // -PAUSE-------------------------------------
	goto('Begin');
}


state Red
{
	simulated event Tick( FLOAT DeltaSeconds );

Begin:
	ToggleRedLight(true);
	// ������
	if (LeftSection.On && !LeftSection.StartAfterRed)
	{
		ToggleLeftSectionLight(true);
	}
	
	if (RightSection.On && !RightSection.StartAfterRed)
	{
		ToggleRightSectionLight(true);
	}
	
	Sleep(RedLightTime/2); // -PAUSE / 2-------------------------------------
	
	// ������
	if (LeftSection.On && LeftSection.StartAfterRed)
	{
		ToggleLeftSectionLight (false);
	}

	if (RightSection.On && RightSection.StartAfterRed)
	{
		ToggleRightSectionLight (false);
	}	

	Sleep(RedLightTime/2); // -PAUSE / 2-------------------------------------

	
	GotoState('RedYellow');
}

state RedYellow
{
	simulated event Tick( FLOAT DeltaSeconds );
Begin:
	ToggleYellowLight (true);
	Sleep(YellowLightTime); // -PAUSE-------------------------------------

	ToggleRedLight(false);
	ToggleYellowLight (false);
	
	GotoState('Green');
}

Defaultproperties
{
	Begin Object Class=StaticMeshComponent Name=MBox 
		StaticMesh = StaticMesh'svetofor.Meshes.svetofor_1'
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

	
	Working = true;

	YellowLightFlickeringTime = 1.0
	GreenLightFlickeringTime = 1.0

	RedLightTime = 20.0
	GreenLightTime = 20.0
	YellowLightTime = 2.0

	RemoteRole = ROLE_SimulatedProxy
	
	bMovable=false
	bCollideActors=true
	bBlockActors=true
	bCollideWhenPlacing=false

	NullColor = (R=0, G=0, B=0, A=1)
	RedColor = (R=3.5, G=0.05, B=0.05, A=1)
	GreenColor = (R=0, G=5, B=2.5, A=1)
	YellowColor = (R=5, G=4.25, B=0, A=1)

}
