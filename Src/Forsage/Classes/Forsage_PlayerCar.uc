class Forsage_PlayerCar extends PlayerCarBase config(ForsageCar);
`include(Library_Msg.uci);

const angle = 182;
const SoundDuration = 0.324f;

var const vector eyeOffset;	// смещение на уровень глаз водителя
var Zarnitza_VehicleTouchHelperActor vth;
var private float CrashTimeout;
var Zarnitza_OnRoadSituationDetector RoadDetector;
var Gorod_EventDispatcher EventDispatcher;
var private Gorod_Event EventToSend;
var Zarnitza_VehicleTouchHelperActor TouchHelper;

var Vector OldLocation;
// вспомогательные переменные, определяющие состояние машины
var bool bTurnLeft, bTurnRight, bAlarmSignal,bHooterSignal;
var float EngineRPM;

/** настройки зеркала  */
var repnotify config struct MirrorSettings
{
	var bool Toning;        // тонировка зеркал
	var float FOV;
	var rotator Rotation;
	var int minPitch, maxPitch, minYaw, maxYaw;

	StructDefaultProperties
	{
		FOV = 65.f;
		Toning = false;

		minPitch = -8192;
		maxPitch = 8192;
		minYaw = -8192;
		maxYaw = 8192;
	}	
} msBackMirror, msLeftMirror, msRightMirror;
/** режим настройки зеркала*/
var enum eTuningType
{	
	TT_BackMirrorPitchInc,
	TT_BackMirrorPitchDec,
	TT_BackMirrorYawInc,
	TT_BackMirrorYawDec,
	TT_LeftMirrorPitchInc,
	TT_LeftMirrorPitchDec,
	TT_LeftMirrorYawInc,
	TT_LeftMirrorYawDec,
	TT_RightMirrorPitchInc,
	TT_RightMirrorPitchDec,
	TT_RightMirrorYawInc,
	TT_RightMirrorYawDec,
	TT_None
} TuningType;

/** Названия костей зеркал */
var name LeftMirrorBoneName;
var name RightMirrorBoneName;
var name BackMirrorBoneName;

/** Ссылки на кости, соответствующие зеркалам */
var SkelControlSingleBone LeftMirrorBone;
var SkelControlSingleBone RightMirrorBone;
var SkelControlSingleBone BackMirrorBone;
/** начальное положение для камеры (режим mainmenu при старте игры) */
var vector startLoc;
var rotator startRot;

/** Скелмеш салона */
var() StaticMeshComponent InteriorCarMeshComponent;

/** Текущая передача */
var int CurrentStep;
//
var bool bAlarm;
var bool bHeadLight;
var bool bPassingLight;
var bool bDimensional_fires;
var bool bStarter;
var bool bLeftTurn;
var bool bRightTurn;
var bool bHandBrake;

var bool bCalibrating;
// CarX >>
/** ссылка на объект для взаимодействия с CarX */
var Forsage_CarXDLL CarX;

var SkelControlSingleBone FrontRightWheel, FrontLeftWheel, RearRightWheel, RearLeftWheel;
var Vector FrontRightWheelLoc, FrontLeftWheelLoc, RearRightWheelLoc, RearLeftWheelLoc;

var float LastDeltaSeconds;

var bool bReady;
var bool bHasBeenTelepoted;

var bool bHasRigidBodyCollision;
// CarX <<

var Forsage_Signals ForsageSignals;

var config EInputMode UserInputMode;

replication
{
	if (bNetDirty && Role == Role_Authority) 
		msBackMirror, msLeftMirror, msRightMirror;
}

function bool DriverEnter(Pawn P)
{	
	InputMode = UserInputMode;
	return super.DriverEnter(P);
}

function cleanSignals()
{
	if (InputMode == IM_Simulator)
		ForsageSignals.Finalize(1);
}

function OnDriveOnRoad() {
	// Gorod_PlayerController(self.Controller).ClientShowMsg(MESSAGE_INFORM ,"Вы выехали на проезжую часть");
	SendPDDEvent(3008);
	SendHUDEvent(3008);
}

function OnDriveOffRoad() {
	SendPDDEvent(3007);
	SendHUDEvent(3007);
	//Gorod_PlayerController(self.Controller).ClientShowMsg(MESSAGE_INFORM ,"Вы выехали за пределы дороги");
}

function OnDriveToRoad() {
	// #ToDo SendEvent
	// Gorod_PlayerController(self.Controller).ClientShowMsg(MESSAGE_INFORM ,"Вы выезжаете на проезжую часть");
}

function OnDriveToOffroad() {
	// #ToDo SendEvent
	// Gorod_PlayerController(self.Controller).ClientShowMsg(MESSAGE_INFORM ,"Вы съезжаете с дороги");
}

function OnStartDriveInCorrectDirectionWhileInWrongSide() {
	// #ToDo SendEvent
	// Gorod_PlayerController(self.Controller).ClientShowMsg(MESSAGE_INFORM ,"Вы развернулись в неположенном месте");
}

/** выезд на встречку (частично) */
function OnDriveToWrongSide() {
	SendPDDEvent(3014);
	SendHUDEvent(3014);
	// #ToDo SendEvent
	// Gorod_PlayerController(self.Controller).ClientShowMsg(MESSAGE_INFORM ,"Вы выезжаете на встречную полосу");
}

/** полностью на встречке */
function OnDriveOnWrongSide() {
	SendPDDEvent(3013);
	SendHUDEvent(3013);
	// Gorod_PlayerController(self.Controller).ClientShowMsg(MESSAGE_INFORM ,"Вы выехали на встречную полосу");
}


function OnMoveToLeft() {
	SendPDDEvent(3015);
	//SendHUDEvent(3015);
	// #ToDo SendEvent
	// Gorod_PlayerController(self.Controller).ClientShowMsg(MESSAGE_INFORM ,"Вы перестраиваетесь влево");
}

function OnMoveToRight() {
	SendPDDEvent(3016);
	//SendHUDEvent(3016);
	// #ToDo SendEvent
	// Gorod_PlayerController(self.Controller).ClientShowMsg(MESSAGE_INFORM ,"Вы перестраиваетесь вправо");
}

function OnCompleteMoveToLeft() {
	SendPDDEvent(3017);
	//SendHUDEvent(3017);
	// #ToDo SendEvent
	// Gorod_PlayerController(self.Controller).ClientShowMsg(MESSAGE_INFORM ,"Вы ПЕРЕСТРОИЛИСЬ ВЛЕВО");
}

function OnCompleteMoveToRight() {
	SendPDDEvent(3018);
	//SendHUDEvent(3018);
	// #ToDo SendEvent
	// Gorod_PlayerController(self.Controller).ClientShowMsg(MESSAGE_INFORM ,"Вы ПЕРЕСТРОИЛИСЬ ВПРАВО");
}

function SendHUDEvent(int mid)
{
	if(EventDispatcher == none)
		return;

	EventToSend.eventType = GOROD_EVENT_HUD;
	EventToSend.messageID = mid;
	EventDispatcher.SendEvent(EventToSend);
}

function SendPDDEvent(int mid)
{
	if(EventDispatcher == none)
		return;

	EventToSend.eventType = GOROD_EVENT_PDD;
	EventToSend.messageID = mid;
	EventDispatcher.SendEvent(EventToSend);
}

simulated function SetIgnition(bool value)
{
	Ignition = value;
	if (Ignition && !bEngineOn)
	{
		ForsageSignals.Accumulator(1);
		ForsageSignals.Belt(1);
		ForsageSignals.CheckEngine(1);
		ForsageSignals.Oil(1);
	}
	else 
		setTimer(0.5f, false, 'IgnitionValid');	
}

simulated function IgnitionValid()
{
	if (!Ignition)
		ToggleEngine(false);
}

simulated function ToggleEngine(bool value)
{		
	ForsageSignals.Accumulator(0);
	ForsageSignals.CheckEngine(0);
	ForsageSignals.Belt(0);
	ForsageSignals.Oil(0);	

	// если надо включить двигатель, то начинаем проигрывать звук
	// и, с задержкой, устанавливаем соответствующий флаг
	if (value) 	
	{
		SetTimer(1, false, 'ToggleEngineTimer');
	}
	else 
	{
		ForsageSignals.ShowCalibratedValue(1, 0);
		ClearTimer('IgnitionValid');
		bEngineOn = false;
	}
}

simulated function ToggleEngineTimer()
{
	bEngineOn = true;
}

simulated function ToggleAlarmLamp()
{
	super.ToggleAlarmLamp();
	ForsageSignals.Alarm(iAlarm);
	ForsageSignals.LeftTurn(iAlarm);
	ForsageSignals.RightTurn(iAlarm);
}

simulated function ToggleLeftTurnLamp()
{
	iAlarm = 1 - iAlarm;	
	ForsageSignals.LeftTurn(iAlarm);	
}

simulated function ToggleRightTurnLamp()
{
	iAlarm = 1 - iAlarm;	
	ForsageSignals.RightTurn(iAlarm);
}

simulated event ReplicatedEvent(name VarName)
{
	switch (VarName)
	{
		case 'msLeftMirror':			
			LeftMirrorBone.BoneRotation = msLeftMirror.Rotation;
			mirrorToning();				
			break;
		case 'msRightMirror':
			RightMirrorBone.BoneRotation = msRightMirror.Rotation;			
			mirrorToning();	
			break;
		case 'msBackMirror':
			BackMirrorBone.BoneRotation = msBackMirror.Rotation;
			mirrorToning();			
			break;
		default:
			super.ReplicatedEvent(VarName);
			break;
	}
}

simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	RoadDetector = new class'Zarnitza_OnRoadSituationDetector';
	RoadDetector.DetectingPawn = self;

	RoadDetector.dlgOnChangeDriveState_ToOffroad = OnDriveToOffroad;
	RoadDetector.dlgOnChangeDriveState_ToRoad = OnDriveToRoad;
	RoadDetector.dlgOnChangeDriveState_OnRoad = OnDriveOnRoad;
	RoadDetector.dlgOnChangeDriveState_OnOffroad = OnDriveOffRoad;
	RoadDetector.dlgOnStartDriveInCorrentDirectionWhileInWrongSide = OnStartDriveInCorrectDirectionWhileInWrongSide;
	RoadDetector.dlgOnDriveInWrongSide = OnDriveOnWrongSide;
	RoadDetector.dlgOnDriveToWrongSide = OnDriveToWrongSide;
	RoadDetector.dlgOnMoveToLeft = OnMoveToLeft;
	RoadDetector.dlgOnMoveToRight = OnMoveToRight;
	RoadDetector.dlgOnCompleteMovementFromLeft = OnCompleteMoveToLeft;
	RoadDetector.dlgOnCompleteMovementFromRight = OnCompleteMoveToRight;

	EventToSend = new class'Gorod_Event';

	vth = Spawn(class'Zarnitza_VehicleTouchHelperActor', self, , Location + vect(220.0, 0.0, 0.0));
	
	CarX = Spawn(class'Forsage_CarXDLL', self);
	CarX.OwnerVehicle = self;

	//  получаем ссылки на контроллеры костей для колес
	FrontLeftWheel = SkelControlSingleBone(Mesh.FindSkelControl('F_L_Tire'));
	`warn("FrontLeftWheel == none", FrontLeftWheel == none);
	FrontRightWheel = SkelControlSingleBone(Mesh.FindSkelControl('F_R_Tire'));
	`warn("FrontRightWheel == none", FrontRightWheel == none);
	RearLeftWheel = SkelControlSingleBone(Mesh.FindSkelControl('B_L_Tire'));
	`warn("RearLeftWheel == none", RearLeftWheel == none);
	RearRightWheel = SkelControlSingleBone(Mesh.FindSkelControl('B_R_Tire'));
	`warn("RearRightWheel == none", RearRightWheel == none);

	//  задание информации для CarX о верхних положениях колес при вжатой подвеске
	FrontLeftWheelLoc = Mesh.GetBoneLocation('F_L_Tire', 1);
	CarX.CarXInitInfo.F_L_Wheel_X = FrontLeftWheelLoc.X;
	CarX.CarXInitInfo.F_L_Wheel_Y = FrontLeftWheelLoc.Y;
	CarX.CarXInitInfo.F_L_Wheel_Z = FrontLeftWheelLoc.Z + 7;
	//  --
	FrontRightWheelLoc = Mesh.GetBoneLocation('F_R_Tire', 1);
	CarX.CarXInitInfo.F_R_Wheel_X = FrontRightWheelLoc.X;
	CarX.CarXInitInfo.F_R_Wheel_Y = FrontRightWheelLoc.Y;
	CarX.CarXInitInfo.F_R_Wheel_Z = FrontRightWheelLoc.Z + 7;
	//  --
	RearLeftWheelLoc = Mesh.GetBoneLocation('B_L_Tire', 1);
	CarX.CarXInitInfo.R_L_Wheel_X = RearLeftWheelLoc.X;
	CarX.CarXInitInfo.R_L_Wheel_Y = RearLeftWheelLoc.Y;
	CarX.CarXInitInfo.R_L_Wheel_Z = RearLeftWheelLoc.Z + 7;
	//  --
	RearRightWheelLoc = Mesh.GetBoneLocation('B_R_Tire', 1);
	CarX.CarXInitInfo.R_R_Wheel_X = RearRightWheelLoc.X;
	CarX.CarXInitInfo.R_R_Wheel_Y = RearRightWheelLoc.Y;
	CarX.CarXInitInfo.R_R_Wheel_Z = RearRightWheelLoc.Z + 7;

	//  задание прямоугольника для CarX
	CarX.CarXInitInfo.BoxMinLoc_X = -96;
	CarX.CarXInitInfo.BoxMinLoc_Y = -48;
	CarX.CarXInitInfo.BoxMinLoc_Z = -16;
	CarX.CarXInitInfo.BoxMaxLoc_X = 120;
	CarX.CarXInitInfo.BoxMaxLoc_Y = 48;
	CarX.CarXInitInfo.BoxMaxLoc_Z = 48;

	CarX.InitCarX();
	// << CarX

	// CarX >>
	FrontLeftWheel.BoneTranslationSpace = BCS_WorldSpace;
	FrontRightWheel.BoneTranslationSpace = BCS_WorldSpace;
	RearLeftWheel.BoneTranslationSpace = BCS_WorldSpace;
	RearRightWheel.BoneTranslationSpace = BCS_WorldSpace;

	OldLocation = Location;
	// CarX <<
}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	Super.PostInitAnimTree(SkelComp);

	if (SkelComp == Mesh)
	{
		// получаем ссылки на контроллеры костей для зеркал
		BackMirrorBone = SkelControlSingleBone(Mesh.FindSkelControl(BackMirrorBoneName));
		`warn("No back mirror found!", BackMirrorBone == none);
		
		LeftMirrorBone = SkelControlSingleBone(Mesh.FindSkelControl(LeftMirrorBoneName));
		`warn("No left mirror found!", LeftMirrorBone == none);

		RightMirrorBone = SkelControlSingleBone(Mesh.FindSkelControl(RightMirrorBoneName));
		`warn("No right mirror found!", RightMirrorBone == none);		
	}
}

//===============================================================================================
// Работа с зеркалами

/** получение положения зеркала */
reliable client function vector getMirrorLocation(eViewMode vm)
{
	local vector v;
	switch (vm)
	{		
		case VM_LeftMirror:			
			v = Mesh.GetBoneLocation(LeftMirrorBoneName);	
			break;
		case VM_RightMirror:
			v = Mesh.GetBoneLocation(RightMirrorBoneName);	
			break;
		default:
			v = Mesh.GetBoneLocation(BackMirrorBoneName);
			break;
	}		
	return v;
}

/** получение поворота зеркала */
reliable client function MirrorSettings getMirrorSettings(eViewMode vm)
{
	local MirrorSettings ms;	
	switch (vm) 
	{		
		case VM_LeftMirror:
			ms.FOV = msLeftMirror.FOV;				
			ms.Rotation = QuatToRotator(Mesh.GetBoneQuaternion(LeftMirrorBoneName));		
			break;
		case VM_RightMirror:
			ms.FOV = msRightMirror.FOV;
			ms.Rotation = QuatToRotator(Mesh.GetBoneQuaternion(RightMirrorBoneName));		
			break;
		default:
			ms.FOV = msBackMirror.FOV;
			ms.Rotation = QuatToRotator(Mesh.GetBoneQuaternion(BackMirrorBoneName));
			break;
	}		
	return ms;	
}

reliable server function mirrorRotate()
{
	switch (TuningType)
	{
		// back mirror
		case TT_BackMirrorPitchInc:			
			msBackMirror.Rotation.Pitch = Clamp(msBackMirror.Rotation.Pitch + angle, msBackMirror.minPitch, msBackMirror.maxPitch);
			break;
		case TT_BackMirrorPitchDec:
			msBackMirror.Rotation.Pitch = Clamp(msBackMirror.Rotation.Pitch - angle, msBackMirror.minPitch, msBackMirror.maxPitch);
			break;
		case TT_BackMirrorYawInc:
			msBackMirror.Rotation.Yaw = Clamp(msBackMirror.Rotation.Yaw + angle, msBackMirror.minYaw, msBackMirror.maxYaw);
			break;
		case TT_BackMirrorYawDec:
			msBackMirror.Rotation.Yaw = Clamp(msBackMirror.Rotation.Yaw - angle, msBackMirror.minYaw, msBackMirror.maxYaw);
			break;
		// left mirror
		case TT_LeftMirrorPitchInc:			
			msLeftMirror.Rotation.Pitch = Clamp(msLeftMirror.Rotation.Pitch + angle, msLeftMirror.minPitch, msLeftMirror.maxPitch);
			break;
		case TT_LeftMirrorPitchDec:
			msLeftMirror.Rotation.Pitch = Clamp(msLeftMirror.Rotation.Pitch - angle, msLeftMirror.minPitch, msLeftMirror.maxPitch);
			break;
		case TT_LeftMirrorYawInc:
			msLeftMirror.Rotation.Yaw = Clamp(msLeftMirror.Rotation.Yaw + angle, msLeftMirror.minYaw, msLeftMirror.maxYaw);
			break;
		case TT_LeftMirrorYawDec:
			msLeftMirror.Rotation.Yaw = Clamp(msLeftMirror.Rotation.Yaw - angle, msLeftMirror.minYaw, msLeftMirror.maxYaw);
			break;
		// right mirror
		case TT_RightMirrorPitchInc:			
			msRightMirror.Rotation.Pitch = Clamp(msRightMirror.Rotation.Pitch + angle, msRightMirror.minPitch, msRightMirror.maxPitch);
			break;
		case TT_RightMirrorPitchDec:
			msRightMirror.Rotation.Pitch = Clamp(msRightMirror.Rotation.Pitch - angle, msRightMirror.minPitch, msRightMirror.maxPitch);
			break;
		case TT_RightMirrorYawInc:
			msRightMirror.Rotation.Yaw = Clamp(msRightMirror.Rotation.Yaw + angle, msRightMirror.minYaw, msRightMirror.maxYaw);
			break;
		case TT_RightMirrorYawDec:
			msRightMirror.Rotation.Yaw = Clamp(msRightMirror.Rotation.Yaw - angle, msRightMirror.minYaw, msRightMirror.maxYaw);
			break;
	}
}
// тонировка только для боковых зеркал
unreliable client function mirrorToning()
{
	local Forsage_controller C;	
	foreach LocalPlayerControllers(class'Forsage_Controller', C)
    {	
    	switch (C.ViewMode)
        {					
			case VM_LeftMirror:				
				C.setToneColor(msLeftMirror.Toning);				
				break;
			case VM_RightMirror:				
				C.setToneColor(msRightMirror.Toning);
				break;
        }    	
    }
}

function relocate(vector newLocation, rotator newRotation)
{	
	bReady = false;
	CustomGravityScaling = 1;

	SetLocation(newLocation);
	SetRotation(newRotation);
	CollisionComponent.SetRBPosition(newLocation);
	CollisionComponent.SetRBRotation(newRotation);
		
	SetCollisionType(COLLIDE_BlockAll);
	SetPhysics(PHYS_RigidBody);
	
	CustomGravityScaling = 0;
	bReady = true;
	bHasBeenTelepoted = true;
}

reliable client function showVehicleMesh(eViewMode vm)
{
	switch(vm)
	{
		case VM_BackMirror:
			InteriorCarMeshComponent.SetHidden(false);
			break;
		case VM_LeftMirror:
		case VM_RightMirror:
			Mesh.SetHidden(false);
			break;
	}
}

function setMirrorToning()
{
	local bool bToning; 
	bToning = !msLeftMirror.Toning;

	msLeftMirror.Toning = bToning;
	msRightMirror.Toning = bToning;	
}

simulated function bool CalcCamera(float fDeltaTime, out Vector out_CamLoc, out Rotator out_CamRot, out float out_FOV)
{	
	if (Forsage_Controller(Controller).bMenuIsFirstTime) {
		out_CamLoc = startLoc;
		out_CamRot = startRot;		
	}
	else
	{
		Mesh.GetSocketWorldLocationAndRotation(CameraSocketNames[CameraSocketIndex], out_CamLoc, out_CamRot);
	}
	return true;
}
// Работа с зеркалами ===============================================================================================

simulated function ProcessWheelHandling()
{	
	if (CS != none)
	{	
		// >> Устанавливать управляющие сигналы для машины через CarX.Car
		if(InputMode != IM_Keyboard)
		{
			if (Ignition != CS.GetIgnition())			
				SetIgnition(!Ignition);

			if (bStarter != CS.GetStarter())
			{
				bStarter = !bStarter;
				if (!bEngineOn && bStarter) 
					ToggleEngine(true);
			}
			
			if (bEngineOn && !bCalibrating)
			{
				ForsageSignals.ShowCalibratedValue(0, CarX.CarState.SpeedKmH);		
				ForsageSignals.ShowCalibratedValue(1, EngineRPM);
			}
		}

		ForsageSignals.CarSpeed(CarX.CarState.SpeedKmH);


		if (bAlarm != CS.GetAlarmSignal())
		{
			bAlarm = !bAlarm;
			if (bAlarm)
			{
				ToggleAlarmLamp();
				SetTimer(SoundDuration, true, 'ToggleAlarmLamp');
			}
			else 
			{
				ClearTimer('ToggleAlarmLamp');
				ForsageSignals.Alarm(0);
				ForsageSignals.LeftTurn(0);
				ForsageSignals.RightTurn(0);
			}
		}		

		if (bHeadLight != ForsageSignals.GetHeadLight()) 
		{			
			bHeadLight = !bHeadLight;
			ForsageSignals.HeadLight(int(bHeadLight));
		}

		if (bDimensional_fires != CS.GetDimensionalFires()) 
		{			
			bDimensional_fires = !bDimensional_fires;			
			ForsageSignals.DimensionalFires(int(bDimensional_fires));
			ForsageSignals.Illumination(int(bDimensional_fires));
		}		

		if (bLeftTurn != CS.GetLeftTurn()) 
		{			
			bLeftTurn = !bLeftTurn;			
			if (bLeftTurn)
			{
				ToggleLeftTurnLamp();
				SetTimer(SoundDuration, true, 'ToggleLeftTurnLamp');
			}
			else 
			{
				ClearTimer('ToggleLeftTurnLamp');				
				ForsageSignals.LeftTurn(0);				
			}
		}

		if (bRightTurn != CS.GetRightTurn()) 
		{			
			bRightTurn = !bRightTurn;
			if (bRightTurn)
			{
				ToggleRightTurnLamp();
				SetTimer(SoundDuration, true, 'ToggleRightTurnLamp');
			}
			else 
			{
				ClearTimer('ToggleRightTurnLamp');				
				ForsageSignals.RightTurn(0);				
			}
		}
	}
}

// CarX >>
function ProcessCarX(float DeltaSeconds)
{
	local int i;
	local Vector TraceStart, TraceEnd, HitLocation, HitNormal;
	local TraceHitInfo HitInfo;
	local int res;
	local Actor TraceActor;
	local bool TraceResult;

	local float MaxSteerAngle;
	local Quat Quaternion;
	local Vector Loc;

	local Actor t;
	local Vector CustomVelocity;

	//------------------------------------------------------------
	// задаём параметры машины
	
	CarX.Car.GlobalAngularVelocity_X = AngularVelocity.X;
	CarX.Car.GlobalAngularVelocity_Y = AngularVelocity.Y;
	CarX.Car.GlobalAngularVelocity_Z = AngularVelocity.Z;

	Quaternion = QuatFromRotator(Rotation);
	CarX.Car.Quaternion_X = Quaternion.X;
	CarX.Car.Quaternion_Y = Quaternion.Y;
	CarX.Car.Quaternion_Z = Quaternion.Z;
	CarX.Car.Quaternion_W = Quaternion.W;

	CarX.Car.Location_X = Location.X;
	CarX.Car.Location_Y = Location.Y;
	CarX.Car.Location_Z = Location.Z;

	if(bHasRigidBodyCollision)
		CustomVelocity = (Location - OldLocation)/DeltaSeconds;	
	else
		CustomVelocity = Velocity;

	OldLocation = Location;

	bHasRigidBodyCollision = false;
	
	foreach Touching(t)
	{
		if(t.bBlockActors)
			bHasRigidBodyCollision = true;
	}

	CarX.Car.GlobalVelocity_X = CustomVelocity.X;
	CarX.Car.GlobalVelocity_Y = CustomVelocity.Y;
	CarX.Car.GlobalVelocity_Z = CustomVelocity.Z;
	
	CarX.Car.COMOffset_X = COMOffset.X;
	CarX.Car.COMOffset_Y = COMOffset.Y;
	CarX.Car.COMOffset_Z = COMOffset.Z;

	// если двигатель не работает, не даём газовать
	if(!bEngineOn)
		CarX.Car.Throttle = 0;
	else
		CarX.Car.Throttle = GasPedal;

	CarX.Car.Brake = BrakePedal;
	CarX.Car.Clutch = ClutchPedal;
	CarX.Car.Gear = CurrentGear;
	CarX.Car.HandBrake = HandBrake ? 1 : 0;
	CarX.Car.Steering = Steer;
	
	// получаем максимальный угол поворота колёс
	//MaxSteerAngle = EvalInterpCurveFloat(SimCar.MaxSteerAngleCurve, VSize(Velocity));
	MaxSteerAngle = 45;
	// вычисялем угол поворота колёс по степени поворота руля
	CarX.Car.SteerAngle = CarX.Car.Steering*DegToRad*MaxSteerAngle;

	//------------------------------------------------------------
	// обновляем состояние машины в CarX

	CarX.SetCarParameters(carX.Car);

	for(i = 0; i < 4; i++)
	{
		CarX.GetTracePointsForWheel(i, TraceStart, TraceEnd);

		TraceResult = true;
		foreach TraceActors(class'Actor', TraceActor, HitLocation, HitNormal, TraceEnd, TraceStart, vect(1, 1, 1), HitInfo, TRACEFLAG_Blocking)
		{
			if(TraceActor == self)
				continue;

			TraceResult = false;
			break;
		}


		if(!TraceResult)
		{
			res = 0;
			CarX.rti.Target = HitLocation;
			CarX.rti.N = Normal(HitNormal);
		}
		else
		{
			res = 1;
		}

		CarX.SetTraceResults(i, res, CarX.rti);
	}

	CarX.Update(DeltaSeconds);
	CarX.GetTotals(CarX.Fdt, CarX.MFdt);
	CarX.GetCarXInfo(CarX.CarState);



	//---------------------------------------------------------------------------
	// изменение положений колёс

	// получаем вектор - кординаты переднего левого колеса
	Loc.X = CarX.CarState.F_L_WheelLoc_X;
	Loc.Y = CarX.CarState.F_L_WheelLoc_Y;
	Loc.Z = CarX.CarState.F_L_WheelLoc_Z;

	// получаем кватернион - поворот переднего левого колеса
	Quaternion.X = CarX.CarState.F_L_WheelQuat_X;
	Quaternion.Y = CarX.CarState.F_L_WheelQuat_Y;
	Quaternion.Z = CarX.CarState.F_L_WheelQuat_Z;
	Quaternion.W = CarX.CarState.F_L_WheelQuat_W;

	SetWheel(FrontLeftWheel, FrontLeftWheelLoc, Loc, Quaternion, DeltaSeconds);

	// получаем вектор - кординаты переднего правого колеса
	Loc.X = CarX.CarState.F_R_WheelLoc_X;
	Loc.Y = CarX.CarState.F_R_WheelLoc_Y;
	Loc.Z = CarX.CarState.F_R_WheelLoc_Z;

	// получаем кватернион - поворот переднего правого колеса
	Quaternion.X = CarX.CarState.F_R_WheelQuat_X;
	Quaternion.Y = CarX.CarState.F_R_WheelQuat_Y;
	Quaternion.Z = CarX.CarState.F_R_WheelQuat_Z;
	Quaternion.W = CarX.CarState.F_R_WheelQuat_W;

	SetWheel(FrontRightWheel, FrontRightWheelLoc, Loc, Quaternion, DeltaSeconds);

	// получаем вектор - кординаты заднего левого колеса
	Loc.X = CarX.CarState.R_L_WheelLoc_X;
	Loc.Y = CarX.CarState.R_L_WheelLoc_Y;
	Loc.Z = CarX.CarState.R_L_WheelLoc_Z;

	// получаем кватернион - поворот заднего левого колеса
	Quaternion.X = CarX.CarState.R_L_WheelQuat_X;
	Quaternion.Y = CarX.CarState.R_L_WheelQuat_Y;
	Quaternion.Z = CarX.CarState.R_L_WheelQuat_Z;
	Quaternion.W = CarX.CarState.R_L_WheelQuat_W;

	SetWheel(RearLeftWheel, RearLeftWheelLoc, Loc, Quaternion, DeltaSeconds);

	// получаем вектор - кординаты заднего правого колеса
	Loc.X = CarX.CarState.R_R_WheelLoc_X;
	Loc.Y = CarX.CarState.R_R_WheelLoc_Y;
	Loc.Z = CarX.CarState.R_R_WheelLoc_Z;

	// получаем кватернион - поворот заднего правого колеса
	Quaternion.X = CarX.CarState.R_R_WheelQuat_X;
	Quaternion.Y = CarX.CarState.R_R_WheelQuat_Y;
	Quaternion.Z = CarX.CarState.R_R_WheelQuat_Z;
	Quaternion.W = CarX.CarState.R_R_WheelQuat_W;

	SetWheel(RearRightWheel, RearRightWheelLoc, Loc, Quaternion, DeltaSeconds);

	//-----------------------------------------------------------------------------------------
	// применение скорости и угловой скорости, полученных от CarX к RigidBody

	Mesh.SetRBLinearVelocity(CarX.Fdt, false);
	Mesh.SetRBAngularVelocity(CarX.MFdt, false);
}
// CarX <<

// >> CarX
/** задаёт положение колеса машины с помощью изменения положения кости */
function SetWheel(SkelControlSingleBone Wheel, Vector InitialLoc, Vector DeltaLoc, Quat Quaternion, float dt)
{
	Wheel.BoneTranslation = DeltaLoc + dt*Velocity;
	Wheel.BoneRotation = QuatToRotator(Quaternion);
}
// << CarX

simulated event Tick(float delta)
{
	local Vector vct;	

	if(bReady)
	{
		// CarX >>
		ProcessCarX(delta);

		if(bEngineOn)
			EngineRPM = CarX.CarState.RPM;
		else
			EngineRPM = 0;
		// CarX <<
	}

	RoadDetector.Update();

	mirrorRotate();	 

	LastDeltaSeconds = delta;

	super.Tick(delta);

	Mesh.GetSocketWorldLocationAndRotation('TouchHelper_Front', vct);

	vth.SetLocation(vct); 

	CrashTimeout -= delta;
	// чтобы счётчик не уменьшался до больших отрицательных значений
	if(CrashTimeout <= 0)
		CrashTimeout = 0;
}

simulated event RigidBodyCollision(PrimitiveComponent HitComponent, PrimitiveComponent OtherComponent, const out CollisionImpactData RigidCollisionData, int ContactIndex)
{
	super.RigidBodyCollision(HitComponent, OtherComponent, RigidCollisionData, ContactIndex);
	bHasRigidBodyCollision = true;
}

exec function Ready()
{
	bReady = !bReady;
}

//================================================================================
// Управление
function SetStarter(bool bOn)
{
	super.SetStarter(bOn);
	if (!bEngineOn && Ignition && Starter) 
		ToggleEngine(true);
}

simulated function DrawHUD( HUD H ) 
{
	local int PosY;
	
	PosY = 150;

	super.DrawHud(H);

	if (CarX == none)
		return;

	H.Canvas.SetDrawColor(255,0,0);
	
	H.Canvas.SetPos(10, PosY, 0);
	H.Canvas.DrawText("Velocity: " @ CarX.CarState.SpeedKmH);
	H.Canvas.DrawText("RPM:      " @ CarX.CarState.RPM);
	H.Canvas.DrawText("Accel:    " @ CarX.CarState.Accel);
	H.Canvas.DrawText("Clutch:   " @ CarX.CarState.Clutch);
	H.Canvas.DrawText("Gear:     " @ CarX.CarState.Gear);
	H.Canvas.DrawText("HandBrake:" @ CarX.Car.HandBrake);

	H.Canvas.SetPos(10, PosY+100, 0);
	H.Canvas.DrawText("Ignition:" @ Ignition);
	H.Canvas.DrawText("Starter: " @ bStarter);
	H.Canvas.DrawText("EngineOn:" @ bEngineOn);
}

protected function GetSignalsObj(out ICommonSignals sig)
{
	if(InputMode == IM_Simulator)
	{
		ForsageSignals = new class'Forsage_Signals';
		sig = ForsageSignals;
	}
	else
		super.GetSignalsObj(sig);
}

DefaultProperties
{	
	// CarX >>
	Mass = 1050.f	
	CustomGravityScaling = 0;

	TickGroup = TG_PreAsyncWork
	Components.Remove(CollisionCylinder)

	bReady = false
	bHasBeenTelepoted = false
	bEngineOn = false
	// CarX <<

	bSirenaSignal = true

	bCalibrating = false;	
	eyeOffset = (X=5,Y=-13,Z=12);
	TuningType = TT_None	

	BackMirrorBoneName = "C_Mirror"
	LeftMirrorBoneName = "L_Mirror"
	RightMirrorBoneName = "R_Mirror"

	CameraSocketNames.Add("CameraInsideViewSocket")

	// для CarX >>
	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'UDKPriora_Forsage.Lada_Priora_Forsage'
		PhysicsAsset=PhysicsAsset'UDKPriora_Forsage.Lada_Priora_CarX_Physics'
		AnimTreeTemplate(0)=AnimTree'UDKPriora_Forsage.UDKPriora_CarX_AnimTree'
		BlockZeroExtent=false
		AlwaysCheckCollision=true
		//HiddenGame = true
    end object
	// для CarX <<

	Begin Object Class=StaticMeshComponent Name=InteriorMeshComp
		StaticMesh = StaticMesh'Cars.Meshes.S_LPriora_interier'
		Translation = (X=12.0,Y=0.0,Z=-26.1)
		HiddenGame = true
	End object
	Components.Add(InteriorMeshComp)
	InteriorCarMeshComponent = InteriorMeshComp;

	// SOUNDS
	Begin Object Class=AudioComponent Name=KamazTireSound
		SoundCue=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireDirt01Cue'
	End Object
	TireAudioComp=KamazTireSound
	Components.Add(KamazTireSound);

	TireSoundList(0)=(MaterialType=Dirt,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireDirt01Cue')
	TireSoundList(1)=(MaterialType=Foliage,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireFoliage01Cue')
	TireSoundList(2)=(MaterialType=Grass,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireGrass01Cue')
	TireSoundList(3)=(MaterialType=Metal,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireMetal01Cue')
	TireSoundList(4)=(MaterialType=Mud,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireMud01Cue')
	TireSoundList(5)=(MaterialType=Snow,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireSnow01Cue')
	TireSoundList(6)=(MaterialType=Stone,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireStone01Cue')
	TireSoundList(7)=(MaterialType=Wood,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireWood01Cue')
	TireSoundList(8)=(MaterialType=Water,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireWater01Cue')

	WheelParticleEffects[0]=(MaterialType=Generic,ParticleTemplate=ParticleSystem'Envy_Level_Effects_2.Vehicle_Dust_Effects.P_Scorpion_Wheel_Dust')
	WheelParticleEffects[1]=(MaterialType=Dirt,ParticleTemplate=ParticleSystem'VH_Scorpion.Effects.PS_Wheel_Rocks')
	WheelParticleEffects[2]=(MaterialType=Water,ParticleTemplate=ParticleSystem'Envy_Level_Effects_2.Vehicle_Water_Effects.P_Scorpion_Water_Splash')
	WheelParticleEffects[3]=(MaterialType=Snow,ParticleTemplate=ParticleSystem'Envy_Level_Effects_2.Vehicle_Snow_Effects.P_Scorpion_Wheel_Snow')

	SquealThreshold=0.1
	SquealLatThreshold=0.02
}