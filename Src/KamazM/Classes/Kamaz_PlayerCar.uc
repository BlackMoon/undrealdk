class Kamaz_PlayerCar extends CarX_Vehicle_Kamaz_4x4
	placeable
	config(KamazCar);

`include(Gorod\Gorod_Events.uci);

var private Gorod_EventDispatcher EventDisp;
var private Gorod_Event EventToSend;
var private Gorod_Event CrashEvent;
var private PrimitiveComponent CrashComponent;
var private float CrashTimeout;
var Zarnitza_OnRoadSituationDetector RoadDetector;

var Zarnitza_VehicleTouchHelperActor vth;

var bool bIsDrivenByPlayer;

var(Cabine) config Vector CabineMesh3DScale;
var(Cabine) config Vector CabineMeshTranslation;
var(Cabine) SkeletalMeshComponent CabineMesh;
var(Cabine) config Vector CabineViewTranslation;
var(Cabine) config Rotator CabineViewRotation;
var(Cabine) config float CabineFOV;

var(Mirrors) config Vector LeftMirrorBaseLoc;
var(Mirrors) config Vector LeftMirrorLoc;
var(Mirrors) config Rotator LeftMirrorRot;
var(Mirrors) config Rotator LeftMirrorBaseRot;

var(Mirrors) config Vector RightMirrorBaseLoc;
var(Mirrors) config Vector RightMirrorLoc;
var(Mirrors) config Rotator RightMirrorRot;
var(Mirrors) config Rotator RightMirrorBaseRot;

// electrotorch_device
var bool bETD; 
var bool boldETD;
var bool boldMass;
var bool bLamps;
var bool bTurnSignalOn;

var config EInputMode UserInputMode;

simulated function DrawHUD(HUD H)
{
	super.DrawHUD(h);

	//RoadDetector.DrawDebug(H);
}

exec function Car_SetClutchPedal(float val)
{
	SetClutchPedal(1 - val);
}

function OnDriveOnRoad() {
	// Gorod_PlayerController(self.Controller).ClientShowMsg(MESSAGE_INFORM ,"�� ������� �� �������� �����");
	SendPDDEvent(3008);
	SendHUDEvent(3008);
}

function OnDriveOffRoad() {
	SendPDDEvent(3007);
	SendHUDEvent(3007);
	//Gorod_PlayerController(self.Controller).ClientShowMsg(MESSAGE_INFORM ,"�� ������� �� ������� ������");
}

function OnDriveToRoad() {
	// #ToDo SendEvent
	// Gorod_PlayerController(self.Controller).ClientShowMsg(MESSAGE_INFORM ,"�� ��������� �� �������� �����");
}

function OnDriveToOffroad() {
	// #ToDo SendEvent
	// Gorod_PlayerController(self.Controller).ClientShowMsg(MESSAGE_INFORM ,"�� ��������� � ������");
}

function OnStartDriveInCorrectDirectionWhileInWrongSide() {
	// #ToDo SendEvent
	// Gorod_PlayerController(self.Controller).ClientShowMsg(MESSAGE_INFORM ,"�� ������������ � ������������ �����");
}

/** ����� �� �������� (��������) */
function OnDriveToWrongSide() {
	SendPDDEvent(3014);
	SendHUDEvent(3014);
	// #ToDo SendEvent
	// Gorod_PlayerController(self.Controller).ClientShowMsg(MESSAGE_INFORM ,"�� ��������� �� ��������� ������");
}

/** ��������� �� �������� */
function OnDriveOnWrongSide() {
	SendPDDEvent(3013);
	SendHUDEvent(3013);
	// Gorod_PlayerController(self.Controller).ClientShowMsg(MESSAGE_INFORM ,"�� ������� �� ��������� ������");
}


function OnMoveToLeft() {
	SendPDDEvent(3015);
	//SendHUDEvent(3015);
	// #ToDo SendEvent
	// Gorod_PlayerController(self.Controller).ClientShowMsg(MESSAGE_INFORM ,"�� ���������������� �����");
}

function OnMoveToRight() {
	SendPDDEvent(3016);
	//SendHUDEvent(3016);
	// #ToDo SendEvent
	// Gorod_PlayerController(self.Controller).ClientShowMsg(MESSAGE_INFORM ,"�� ���������������� ������");
}

function OnCompleteMoveToLeft() {
	SendPDDEvent(3017);
	//SendHUDEvent(3017);
	// #ToDo SendEvent
	// Gorod_PlayerController(self.Controller).ClientShowMsg(MESSAGE_INFORM ,"�� ������������� �����");
}

function OnCompleteMoveToRight() {
	SendPDDEvent(3018);
	//SendHUDEvent(3018);
	// #ToDo SendEvent
	// Gorod_PlayerController(self.Controller).ClientShowMsg(MESSAGE_INFORM ,"�� ������������� ������");
}

function bool DriverEnter(Pawn P)
{
	local bool retval;
	local Kamaz_PlayerController PC;

	Mesh.SetHidden(true);
	CabineMesh.SetHidden(false);

		PC = none;

	if((P != none) && (P.Controller != none))
	{
		PC = Kamaz_PlayerController(P.Controller);
	}

	if(PC != none)
		bIsDrivenByPlayer = true;
	else
		bIsDrivenByPlayer = false;
	
	InputMode = UserInputMode;
	retval = super.DriverEnter(P);	

	if(retval)
	{
		vth.PC = PlayerController(self.Controller);

		if(EventDisp == none)
		{
			EventDisp = Kamaz_PlayerController(self.Controller).EventDispatcher;
		}
		return true;
	}
	else
		return false;
}

function ToggleAlarmLamp()
{
	super.ToggleAlarmLamp();
	if (InputMode == IM_Simulator)
		KamazSignals.TurnLamp(iAlarm);	
}
//====================================================================================
// ��������� ���������� ������
function SetHandBrake(bool val)
{
	if (HandBrake != val)
	{
		HandBrake = val;
		if (InputMode == IM_Simulator)
			KamazSignals.StopBrakeLamp(int(HandBrake));
	}
}
// ���������������� ����������
function SetETD(bool val)
{
	if (bETD != val)
	{
		bETD = val;
		if (InputMode == IM_Simulator)
			KamazSignals.ElectrotorchDeviceLamp(int(bETD));
	}
}

simulated function InitMirror()
{
	local SkelControlSingleBone scb;
	local vector SocketLoc;
    local rotator SocketRot;

	super.InitMirror();

	// ��������� ������ ������
	
	// ����� �������
	CabineMesh.GetSocketWorldLocationAndRotation(name("Left_mirror"), SocketLoc, SocketRot);
	leftMirror = spawn(class'Zarnitza_SceneCapture2DActor');	
	leftMirror.SetLocation (SocketLoc);
	leftMirror.SetRotation (SocketRot);	
	SceneCapture2DComponent(leftMirror.SceneCapture).SetCaptureParameters(TextureRenderTarget2D'Kamaz.Textures.Left_mirror', 90, 20, 0);
	SceneCapture2DComponent(leftMirror.SceneCapture).SetFrameRate (5);
	leftMirror.SetBase (self, , CabineMesh);
	leftMirror.BaseBoneName = Name("L_mirror");
	
	// ������ �������
	CabineMesh.GetSocketWorldLocationAndRotation(name("Right_mirror"), SocketLoc, SocketRot);
	rightMirror = spawn(class'Zarnitza_SceneCapture2DActor');
	rightMirror.SetLocation (SocketLoc);
	rightMirror.SetRotation (SocketRot);
	SceneCapture2DComponent(rightMirror.SceneCapture).SetCaptureParameters(TextureRenderTarget2D'Kamaz.Textures.Right_mirror', 90, 20, 0);
	SceneCapture2DComponent(rightMirror.SceneCapture).SetFrameRate (5);
	rightMirror.SetBase (self, , CabineMesh);
	rightMirror.BaseBoneName = Name("R_mirror");

	scb = SkelControlSingleBone(CabineMesh.FindSkelControl('SkelControl_LeftMirror_Base'));
	scb.BoneTranslation = LeftMirrorBaseLoc;
	scb.BoneRotation = LeftMirrorBaseRot;

	scb = SkelControlSingleBone(CabineMesh.FindSkelControl('SkelControl_LeftMirror'));
	scb.BoneTranslation = LeftMirrorLoc;
	scb.BoneRotation = LeftMirrorRot;
	

	scb = SkelControlSingleBone(CabineMesh.FindSkelControl('SkelControl_RightMirror_Base'));
	scb.BoneTranslation = RightMirrorBaseLoc;
	scb.BoneRotation = RightMirrorBaseRot;

	scb = SkelControlSingleBone(CabineMesh.FindSkelControl('SkelControl_RightMirror'));
	scb.BoneTranslation = RightMirrorLoc;
	scb.BoneRotation = RightMirrorRot;



	// ��������� ������ ����
	scb = SkelControlSingleBone(Mesh.FindSkelControl('SkelControl_LeftMirror_Base'));
	scb.BoneTranslation = LeftMirrorBaseLoc;
	scb.BoneRotation = LeftMirrorBaseRot;

	scb = SkelControlSingleBone(Mesh.FindSkelControl('SkelControl_LeftMirror'));
	scb.BoneTranslation = LeftMirrorLoc;
	scb.BoneRotation = LeftMirrorRot;

	scb = SkelControlSingleBone(Mesh.FindSkelControl('SkelControl_RightMirror_Base'));
	scb.BoneTranslation = RightMirrorBaseLoc;
	scb.BoneRotation = RightMirrorBaseRot;

	scb = SkelControlSingleBone(Mesh.FindSkelControl('SkelControl_RightMirror'));
	scb.BoneTranslation = RightMirrorLoc;
	scb.BoneRotation = RightMirrorRot;
}

function DriverLeft() {
	EventDisp = none;
	super.DriverLeft();

	Mesh.SetHidden(false);
	CabineMesh.SetHidden(true);

	bIsDrivenByPlayer = false;
}


function SendHUDEvent(int mid)
{
	if(EventDisp == none)
		return;

	EventToSend.eventType = GOROD_EVENT_HUD;
	EventToSend.messageID = mid;
	EventDisp.SendEvent(EventToSend);
}

function SendPDDEvent(int mid)
{
	if(EventDisp == none)
		return;

	EventToSend.eventType = GOROD_EVENT_PDD;
	EventToSend.messageID = mid;
	EventDisp.SendEvent(EventToSend);
}

simulated event Tick(float delta)
{
	local Vector vct;
	super.Tick(delta);

	RoadDetector.Update();

	Mesh.GetSocketWorldLocationAndRotation('TouchHelper_Front', vct);

	vth.SetLocation(vct);

	CrashTimeout -= delta;
	// ����� ������� �� ���������� �� ������� ������������� ��������
	if(CrashTimeout <= 0)
		CrashTimeout = 0;
}

simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
	local Vector loc;
	local Rotator rot;

	if(CamType == 0)
	{
		if(CabineMesh.HiddenGame)
		{
			CabineMesh.SetHidden(false);
			Mesh.SetHidden(true);
		}

		if(CameraSocketNames[CameraSocketIndex] == 'CameraViewSocket')
			CabineMesh.GetSocketWorldLocationAndRotation(CameraSocketNames[CameraSocketIndex], loc, rot);
		else
			Mesh.GetSocketWorldLocationAndRotation(CameraSocketNames[CameraSocketIndex], loc, rot);

		out_CamLoc = loc + CabineViewTranslation;
		out_CamRot = rot + CabineViewRotation;

		out_FOV = CabineFOV;

		return true;
	}
	else
	{
		if(!CabineMesh.HiddenGame)
		{
			CabineMesh.SetHidden(true);
			Mesh.SetHidden(false);
		}

		return super.CalcCamera(fDeltaTime, out_CamLoc, out_CamRot, out_FOV);
	}
}

simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	if (Role == ROLE_Authority)
	{
		//  ��������� �������� �������� ���� ������ �� ������� �������
		RoadDetector = new class'Zarnitza_OnRoadSituationDetector';
		RoadDetector.Initialize(self);
	}

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

	CrashEvent = new class'Gorod_Event';
	CrashEvent.eventType = GOROD_EVENT_HUD;
	CrashEvent.sender = self;

	// �������� ���
	CabineMesh.SetHidden(true);
	CabineMesh.SetScale3D(CabineMesh3DScale);
	CabineMesh.SetTranslation(CabineMeshTranslation);
}

simulated event RigidBodyCollision(PrimitiveComponent HitComponent, PrimitiveComponent OtherComponent, const out CollisionImpactData RigidCollisionData, int ContactIndex)
{
	if(bIsDrivenByPlayer)
	{
		if(Gorod_HumanBot(OtherComponent.Owner) != none) return;

		if(CrashComponent == OtherComponent)
		{
			if(CrashTimeout > 0) return;
		}
		else
		{
			CrashComponent = OtherComponent;
		}

		CrashTimeout = 30;

		CrashEvent.messageID = GOROD_CRASH_COMMON;
		EventDisp.SendEvent(CrashEvent);
	}
}

function SetSirenaSignal(bool value)
{
	super.SetSirenaSignal(value);

	if(value)
		SendPDDEvent(3044); // ������ ������� ��� ��� ����������� � ��������� ������� ������
	else
		SendPDDEvent(3045); // ������ ������� ��� ��� ����������� � ���������� ������� ������
}

function SetCarStoped(bool bIsStoped)
{
	if(bIsStoped)
	{
		setHandBrake(true);
		setIgnition(false);
		//ToDo# �� ����������� �� ������� �� ���������
    }
	else
	{
		//ToDo# ������ ����������� �� ������� �� ���������
	}
}

protected function Update()
{
	super.Update();

	// �������, ������� �� ����� ������� ������� ����
	if(InputMode != IM_Joystick)
	{
		// 1� ������� - ���, 2� - ����
		if (boldMass != KamazSignals.GetWeightSwitchingOff())
		{
			boldMass = !boldMass;
			if (boldMass) 
				SetMass(!bMass);			
		}
		 
		if (bLamps != (!alarmSignal || leftTurn || rightTurn))
		{
			bLamps = !bLamps;			
			if (bLamps)
			{
				ToggleAlarmLamp();
				SetTimer(0.34f, true, 'ToggleAlarmLamp');	
			}
			else 
			{
				iAlarm = 1;
				ClearTimer('ToggleAlarmLamp');				
				ToggleAlarmLamp();				
			}
		}
		// 1� ������� - ���, 2� - ����
		if (boldETD != KamazSignals.GetElectrotorchDevice())
		{
			boldETD = !boldETD;
			if (boldETD) 
				SetETD(!bETD);			
		}

		KamazSignals.ShowCalibratedValue(0, GetSpeedInKMpH());	
		KamazSignals.ShowCalibratedValue(1, fCarX.car.rpm);
		KamazSignals.StopBrakeLamp(int(HandBrake));
	}
}

protected function GetSignalsObj(out ICommonSignals sig)
{
	if(InputMode == IM_Simulator)
	{
		KamazSignals = new class'Zarnitza_KamazSignals';
		sig = KamazSignals;
	}
	else
		super.GetSignalsObj(sig);
}

DefaultProperties
{
	bIsDrivenByPlayer = false;

	begin object class=SkeletalMeshComponent name=kbmesh
		AnimTreeTemplate=AnimTree'Kamaz.SkelMeshes.AT_KamazCabine'
		SkeletalMesh=SkeletalMesh'Kamaz.SkelMeshes.Kabina_01'
	end object
	Components.Add(kbmesh)
	CabineMesh = kbmesh

	CameraSocketNames.Add("CameraLeftViewSocket")
	CameraSocketNames.Add("CameraRightViewSocket")
	CameraSocketNames.Add("CameraTopViewSocket")
	CameraSocketNames.Add("CameraViewSocket")
}