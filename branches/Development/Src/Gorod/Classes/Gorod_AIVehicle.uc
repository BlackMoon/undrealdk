/** ������, ������� ����� ����� � �������� ����� � �������� ��������� */
class Gorod_AIVehicle extends VehicleBase;

`include(Gorod_Events.uci);

/** ���������� �����, � ������� ��� �������� � ������ ������ */
var RepNotify Gorod_AIVehicle_PathNode Target;

/** ��������� ���������� �����, ����� ������� ������� ��� */
var Gorod_AIVehicle_PathNode OldTarget;

/** ��������� �������� */
var RepNotify float NeededSpeed;

/** ����������� �� ������� ���������� ����� */
var Vector TargetViewDirection;

/** ������� ������ ������� �������� */
var float CurrentVelocity;

/** ������ �� �������-������������ (������� ������ �������� ��� ����� �wner) */
var() Gorod_RelocationBotManager RelocManager;

/** ������� �����, ����� ����� ���� ������������� ���� ������ 0.1 ������ */
var float countTick;
     
/** �������� ����, ������������ �� ������� ���� */
var float newThrottle;

/** �������� ���� �������� ����, ������������ �� ������� ���� */
var float newSteering;

/** ������ �� ������ ��� ������ � ���������� ������ */
var Gorod_VehicleLightsController VehicleLightsController;

/** ��������� ��� �������������� �������� �� ������������ �������� ������ */
var const float DeltaForWrongDrivingDetection;

/** ��������� ��� �������� ���������� � ��������� �������� �������� ������ */
struct SignalLightsInfo
{
	// ����� ����������
	var bool bLeftSignalLightOn;
	// ������ ����������
	var bool bRightSignalLightOn;
	// ����
	var bool bHeadLightsOn;
	// ���������� ����
	var bool bParkingLightsOn;

	structdefaultproperties
	{
		bLeftSignalLightOn = false;
		bRightSignalLightOn = false;
		bHeadLightsOn = false;
		bParkingLightsOn = false;
	}
};

/** ���������� � ��������� �������� �������� ������ */
var RepNotify SignalLightsInfo LightsInfo;

/** ��������� ������ ��� �������/���������� */
var int VelocityStep;

/** ��������, �� ������� ������ ����� �����������, ���� �� ������ ������, ����� ������ �������� */
var RepNotify float FavoriteSpeed;

/** ���������� ���� �������� */
var private bool bStopped;

var SkeletalMeshComponent SMesh;

replication
{
	if(bNetDirty)
		Target, NeededSpeed, LightsInfo;
	if(bNetInitial)
		FavoriteSpeed;
}

simulated event ReplicatedEvent(Name VarName)
{
	switch(VarName)
	{
		case 'LightsInfo':
			// ��� ��������� LightsInfo ���������� VehicleLightsController.UpdateSignalLights() �� �������, �� �������
			// ReplicatedEvent �� �� ������� ���������� �� �������
			if (Role != ROLE_Authority)
				VehicleLightsController.UpdateSignalLights();
			break;
	}
}

simulated event PreBeginPlay()
{
	Super.PreBeginPlay();
	TargetViewDirection = vector(Rotation);
}

simulated event PostBeginPlay()
{
	super.PostBeginPlay();	

	// ������� Gorod_VehicleLightsController ������ �� ������� � ������ ��� �����-�����
	if(Role == ROLE_Authority)
		VehicleLightsController = Spawn(class'Gorod_VehicleLightsController', self);
	if(Target != none)
		Initialize();
}

function Initialize()
{
	local vector DriverSpawnLocation;
	local Pawn drvr;	
	// ��� ������ ������� ������
	//local Gorod_Game GorodGame;
	local Gorod_AIVehicle_Controller refCtl;
	
	// ��� ������ ������� ������
	//GorodGame = Gorod_Game(WorldInfo.Game);

	// �������� ������������� ������ ��� ��������������� ���� ���� � ������ ��� �����-�����
	// �������� �� Gorod_Game ���������������� ��� ������ ������� ������
	if(Driver == none)
	{
		// �������� �������� � ������� ��� � ������ (��� �������, ����� ������������ epic'������ ������� ��� ���������� ����������, possess, unpossess � ��.)
		DriverSpawnLocation = Location;
		DriverSpawnLocation.Z += 200;
		drvr = Spawn(class'UDKPawn', , , DriverSpawnLocation, Rotation, , true);
		refCtl = Spawn(class'Gorod_AIVehicle_Controller');
		`warn("refCtl == none", refCtl == none);
		drvr.Controller = refCtl;
		DriverEnter(drvr);
	}
	
	// ����������� ��������� �������� ��������� ��������� (������ MaxSpeed �� ����������, ����� ���������� �������� ������)
	MaxSpeed = 0;
	GroundSpeed = 0;
	AirSpeed = 0;
	WaterSpeed = 0;

	// ���� ������ ������ ������� �� � ������� Gorod_AIVehicleSpawner
	// ��������� ���������� 
	if((Gorod_AIVehicle_Spawner(self.Owner) == none) && (refCtl != none))
		refCtl.StartController();
}

function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation)
{
	// �������� ������� �� �������
	return false;
}

/** ������� ���������� ���������� � ������ */
/*simulated function DrawHUD(HUD H)
{
	local Vector X, Y, Z, WorldLoc, ScreenLoc;
	local Kamaz_HUD gHud;
	
	super.DrawHUD(H);
	gHud = Gorod_HUD(H);
	if(gHud != none)
	{
		if(gHud.bShowBotNames)
		{
			// ������ ��������� ��� ������-���� ��� �������
			GetAxes(Rotation, X, Y, Z);
			WorldLoc =  Location;
			ScreenLoc = H.Canvas.Project(WorldLoc);
    	
			if(ScreenLoc.X >= 0 &&	ScreenLoc.X < H.Canvas.ClipX && ScreenLoc.Y >= 0 && ScreenLoc.Y < H.Canvas.ClipY)
			{
				H.Canvas.DrawColor = MakeColor(0,0,255,255);
				H.Canvas.SetPos(ScreenLoc.X, ScreenLoc.Y);
				H.Canvas.DrawText("[" @ Name @ "] -" @ MaxSpeed @ NeededSpeed @ CurrentVelocity);
			}
		}
	}
}*/

simulated event Tick(float deltaSeconds)
{
	/** ������������ ���� �������� ���� */
	local float MaxSteerAngle;
	// ������ �������������� �����
	local float VehicleHeading, SteerHeading, DeltaTargetHeading;
	local Rotator VehicleRot, TargetViewRot;
	local float DeltaVelocity;

	super.Tick(deltaSeconds);
  	
	// ���� ��� Target'�, ���������� �������� ��� ���� � ���� �������� ���� � ������ �� ������
	if(Target == none)
	{
		newThrottle = 0;
		newSteering = 0;
		return;
	}

	CurrentVelocity = VSize(Velocity);

	if(!bStopped)
	{
		//------------------------------------------------------
		// ������ ���� �������� ����

		VehicleRot.Yaw = Rotation.Yaw;
		TargetViewRot.Yaw = rotator(Target.Location - Location).Yaw;
	
		VehicleHeading = GetHeadingAngle(vector(VehicleRot));
	
		// ������, ������������ � ������� ��������� ���������� �����
		TargetViewDirection = vector(TargetViewRot);

		SteerHeading = GetHeadingAngle(TargetViewDirection);
	
		DeltaTargetHeading = FindDeltaAngle(SteerHeading, VehicleHeading);

		/*
		if(DeltaTargetHeading > 1 || DeltaTargetHeading < -1)
		{
			`warn("DeltaTargetHeading is too big!" @ self @ Target);
		}
		*/

		// ��������� � �������
		DeltaTargetHeading *= RadToDeg;

		// ��������� ������������� ���� �������� ����
		//SimCar = SVehicleSimCar(SimObj);
		//EvalInterpCurveFloat(SimCar.MaxSteerAngleCurve, CurrentVelocity);

		// ���������� ������� ��������� ������������� ���� �������� ����
		MaxSteerAngle = 45;
	
		// ��������������� �������� ���� �������� ����
		newSteering = DeltaTargetHeading/MaxSteerAngle;

		// ������������� ���������� ���� ������� ����
		if(newSteering > 1)
			newSteering = 1;
		else if(newSteering < -1)
			newSteering = -1;
	
		//--------------------------------------------
		// ������ ����

	
		countTick += deltaSeconds;
		if(countTick >= 0.1)
		{
			if(MaxSpeed == 0)
				newThrottle = 0;
			else
				newThrottle = 1;

			// ���������� �� ��������
			DeltaVelocity = CurrentVelocity - NeededSpeed;

			// ���� ���������� �� �������� ������ ��� ��������� ���������, �������� MaxSpeed �� �������� ���������, �����
			// ������������� ������ �������� MaxSpeed
			if(DeltaVelocity > VelocityStep)
				MaxSpeed -= VelocityStep*countTick;
			else if(DeltaVelocity < -VelocityStep)
				MaxSpeed += VelocityStep*countTick;
			else
				MaxSpeed = NeededSpeed;

			// ������ �������� �������� ������ ��� FavoriteSpeed
			MaxSpeed = Min(FavoriteSpeed, MaxSpeed);

			// �������� �������� ������ ���������, ��� ��� ��������� MaxSpeed �� ���������� ��� ����������� �������� ������
			GroundSpeed = MaxSpeed;
			AirSpeed = MaxSpeed;
			WaterSpeed = MaxSpeed;

			countTick = 0;
		}
	}	

	// ��������� ������������ �������� ���� � ���� �������� ����
	Throttle = newThrottle;
	Steering = newSteering;
	Rise = 0;
}

/** ���������� ��� ������������ � ������ �������� */
simulated event RigidBodyCollision(PrimitiveComponent HitComponent, PrimitiveComponent OtherComponent, const out CollisionImpactData RigidCollisionData, int ContactIndex)
{
	local Gorod_AIVehicle_Controller VC;
	VC = Gorod_AIVehicle_Controller(self.Controller);

	// ���������� ���������� � ������������ � ������ �������
	if (VC != none) VC.NotifyRigidBobyCollision(HitComponent, OtherComponent, RigidCollisionData, ContactIndex);
}

/** ������������� �������� ��������� �������� */
simulated function SetTargetSpeed(float s)
{
	// ����� �������� �� ������, ��� ��������, ��������� � ������ Target'�
	if((Target == none) || (s < 0))
		NeededSpeed = 0.f;
	else
		NeededSpeed = Min(s, Target.CarMaxSpeed);
}

/** ������������� ���������� �����, � ������� ������ ������ ����� ����������� �� ����� */
function Appear(Gorod_AIVehicle_PathNode t)
{
	local Gorod_AIVehicle_Controller refCtl;

	if (t != none)
	{
		refCtl = Gorod_AIVehicle_Controller(Controller);
		`warn("refCtl == none", refCtl == none);
		if (refCtl != none)
			refCtl.Appear(t);
	}
}

/** ��������� ������� ���� */
simulated function SetNoThrottle(bool val)
{
	if(val)
		newThrottle = 0;
	bStopped = val;
}

/** �������������� �������� �� ������������ �������� ������-���� */
function bool IsDrivingWrong()
{
	// ��������� ����������, ������� ������ �������� �� ������� ������ �� Velocity � ������ �� �������� �������� �������� ����
	// ���������� ���������� ���������� � ������ ����� � ���, ������� �� ������. �. ���� �������, �� ���������� true
	local vector lVelocity;
	local float lCurrentVelocity;
	local float MinSpinVel;

	lVelocity = Velocity;
	lVelocity.Z = 0;
	lCurrentVelocity = VSize(lVelocity);
	MinSpinVel = FMin(Wheels[2].SpinVel*Wheels[2].WheelRadius, Wheels[3].SpinVel*Wheels[3].WheelRadius);

	return (lCurrentVelocity < (MinSpinVel - DeltaForWrongDrivingDetection));
}

defaultproperties
{
	bNoDelete = false;
	bStatic = false;

	RemoteRole = ROLE_SimulatedProxy

	VelocityStep = 100;
	countTick = 0;
	bStopped = false;
	DeltaForWrongDrivingDetection = 200;
}