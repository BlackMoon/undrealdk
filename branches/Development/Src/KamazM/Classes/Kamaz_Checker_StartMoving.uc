class Kamaz_Checker_StartMoving extends Kamaz_Checker_Base;

`include(Gorod\Gorod_Events.uci);
/**
 * ������ ��������� ��� �������� ������������������ �������� ��� ������ ��������
 */
enum StartMovingProcessStates
{
	SMP_ReadyToStart,   // ����� � ������ ��������
	SMP_Belt,           // ����������� ������
	SMP_ClutchDown,     // ��������� ����
	SMP_Mass,           // ������ ����������� �����
	SMP_Ignition,       // ���� ���������
	SMP_FirstGear,      // ������ ��������
	SMP_TurnSignalLeft, // ��������� �������� (�����)
	SMP_TurnSignalRight,// ��������� �������� (������)
	SMP_HandBrake,      // ���������� ������ ����
	SMP_Throttle,       // ���
	SMP_ClutchUp        // ��������� ������
};

/** ������� ��������� ��� �������� ������������������ �������� ��� ������ �������� */
var StartMovingProcessStates CurrentState;

/** ������ �� ������ ��� ��������� ������� */
var Gorod_Event EventToSend;

/** ������ �� ���������� ������ */
var Kamaz_PlayerController CurrentPlayerController;

/** ����, ������������ ��������������� �� ������ ������ � ��������� ��������� */
var private bool bHasRegisteredInMessageManager;

/** ���������� � �����������, ���������� ��� ������ �������� */
var private Gorod_StartMovingMessages StartMovingMessages;

/** ��������� ��������� �� */
var Vector StartLocation;

/** ����, ������������, ��� �� �������� ������� - ����� �� ����� */
var bool bIsMission;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	EventToSend = new class'Gorod_Event';
	EventToSend.sender = self;
	EventToSend.eventType = GOROD_EVENT_HUD;

	StartMovingMessages = new class'Gorod_StartMovingMessages';
	StartMovingMessages.checkConfig();
	RegisterInMessagesManager();
}

/** ������������ ������ ������ � ��������� ��������� */
function RegisterInMessagesManager()
{
	if(CurrentPlayerController == none)
	{
		CurrentPlayerController = Kamaz_PlayerController(GetALocalPlayerController());
		if(CurrentPlayerController == none)
		{
			SetTimer(1, false, 'RegisterInMessagesManager');
			return;
		}
	}

	if(CurrentPlayerController.MessagesManager != none)
	{
		CurrentPlayerController.MessagesManager.Register(StartMovingMessages);
		bHasRegisteredInMessageManager = true;
	}
	else
	{
		SetTimer(1, false, 'RegisterInMessagesManager');
	}
}

simulated function StartCheck(CarX_Vehicle p)
{
	super.StartCheck(p);
	CurrentState = SMP_ReadyToStart;
	self.SecondsBetweenCheck = 0.1;
	StartLocation = VehicleForCheck.Location;

	if(Quest_Mission(CurrentPlayerController.Quest) != none)
		bIsMission = true;
	else
		bIsMission = false;
}

simulated function Check(float DeltaSeconds)
{	
	super.Check(DeltaSeconds);

	if(VSize(VehicleForCheck.Location - StartLocation) > 50)
	{
		// ������ ��������
		StopCheck();
		return;
	}

	switch(CurrentState)
	{
		case SMP_ReadyToStart:
			if(!VehicleForCheck.GetBelt())
				SendStartMovingEvent(GOROD_STARTMOVING_BELT);
			CurrentState = SMP_Belt;
		case SMP_Belt:
			if(VehicleForCheck.GetBelt())
			{
				if(VehicleForCheck.GetClutch() != 0)
					SendStartMovingEvent(GOROD_STARTMOVING_CLUTCH_DOWN);

				CurrentState = SMP_ClutchDown;
			}
			else
			{
				return;
			}
		case SMP_ClutchDown:
			if(VehicleForCheck.GetClutch() == 0)
			{
				if(!VehicleForCheck.GetMass())
					SendStartMovingEvent(GOROD_STARTMOVING_TURN_ON_MASS);

				CurrentState = SMP_Mass;
			}
			else
			{
				return;
			}
		case SMP_Mass:
			if(VehicleForCheck.GetMass())
			{
				if(!VehicleForCheck.GetIgnition())
					SendStartMovingEvent(GOROD_STARTMOVING_IGNITION);

				CurrentState = SMP_Ignition;
			}
			else
			{
				return;
			}
		case SMP_Ignition:
			if(VehicleForCheck.GetIgnition() && VehicleForCheck.GetRPM() > 800)
			{
				if(VehicleForCheck.GetGear() != 2)
					SendStartMovingEvent(GOROD_STARTMOVING_FIRST_GEAR);
				CurrentState = SMP_FirstGear;
			}
			else
			{
				return;
			}
		case SMP_FirstGear:
			if(VehicleForCheck.GetGear() == 1)
			{
				if(bIsMission && !VehicleForCheck.GetRightTurnSignal())
					SendStartMovingEvent(GOROD_STARTMOVING_RIGHT_TURN_SIGNAL);

				CurrentState = SMP_TurnSignalRight;
			}
			else return;			
		case SMP_TurnSignalRight:
			if (!bIsMission || VehicleForCheck.GetRightTurnSignal())
			{
				if(VehicleForCheck.GetHandBrake())
					SendStartMovingEvent(GOROD_STARTMOVING_HAND_BRAKE);

				CurrentState = SMP_HandBrake;
			}
			else
			{
				return;
			}
		case SMP_TurnSignalLeft:
			if(!bIsMission || VehicleForCheck.GetLeftTurnSignal())
			{
				if(VehicleForCheck.GetHandBrake())
					SendStartMovingEvent(GOROD_STARTMOVING_HAND_BRAKE);
				CurrentState = SMP_HandBrake;
			}
			else
			{
				return;
			}
		case SMP_HandBrake:
			if(!VehicleForCheck.GetHandBrake())
			{
				if(VehicleForCheck.GetThrottle() <= 0.3) SendStartMovingEvent(GOROD_STARTMOVING_THROTTLE);
				CurrentState = SMP_Throttle;
			}
			else
			{
				return;
			}
		case SMP_Throttle:
			if(VehicleForCheck.GetThrottle() > 0.3)
			{
				if(VehicleForCheck.GetClutch() != 1)
					SendStartMovingEvent(GOROD_STARTMOVING_CLUTCH_UP);

				CurrentState = SMP_ClutchUp;
			}
			else
			{
				return;
			}
		case SMP_ClutchUp:
			if(VehicleForCheck.GetClutch() == 1)
			{
				StopCheck();
			}
			else
			{
				return;
			}
	}
}

/** �������� ������� �� ������� ������� */
simulated function SendStartMovingEvent(int MsgId)
{
	if(CurrentPlayerController != none)
	{
		EventToSend.messageID = MsgId;
 		CurrentPlayerController.EventDispatcher.SendEvent(EventToSend);
	}
}

/** ���������� ��� ��������� */
function Gorod_StartMovingMessages getMessages()
{
	return StartMovingMessages;
}

DefaultProperties
{
	bHasRegisteredInMessageManager = false;
	SecondsBetweenCheck = 0.1;
}