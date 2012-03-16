class Kamaz_Checker_Exercise2 extends Kamaz_Cheker_ExerciseBase placeable;
`include(Gorod\Gorod_Events.uci);

var private float SecondsCounter;
var private Vector DriveOutInitialLoc;
var private Rotator DriveOutInitialRot;
var private bool bWasDriveBack;

enum ChekerStates_Exercise2
{
	CS_Start,
	CS_StartDrive,
	CS_Stop,
	CS_Wait,
	CS_BeforeDriveOut,
	CS_DriveOut
};

var ChekerStates_Exercise2 CurrentState;

simulated function StartCheck(CarX_Vehicle p)
{
	local rotator rot;	
	super.StartCheck(p);
	SecondsCounter = 0;
	CurrentState = CS_Start;
	
	rot.Pitch = 32;
	rot.Roll = -44;
	rot.Yaw = 19572;

	AutoDrom.setBrdMeshes(vect(120811, 126134, 1930), vect(120303, 125988, 1846), rot, rot);
}

simulated function StopCheck()
{
	super.StopCheck();
	CurrentState = CS_Start;
	AutoDrom.showBrdMeshes(false);
}

simulated function Check(float DeltaSeconds)
{
	local float CurrentDeltaAngle;
	local bool bVehicleIsStoped;

	super.Check(DeltaSeconds);

	// ���� �������� ���������� ���������
	if(!bCheckStarted) return;

	switch(CurrentState)
	{
		case CS_Start:
			// ��������, �� �������� �� �� ��� ������ ��������������
			if(!IsRectangleOutside())
			{
				// �� �������� ������ ����������
				StopCheck();
			}
			else
			{
				// ��������� � ���������� ��������
				CurrentState = CS_StartDrive;
				// ��������� � ������ ����������
				Autodrom.SendAutodromEvent(self, GOROD_EVENT_EXERCISE2_STARTED);

				// ��������� "���������� �� �� �������"
				Autodrom.SendAutodromEvent(self, GOROD_EVENT_GO_TO_ASCENT);
				ResetCountDown();
			}
			break;
		case CS_StartDrive:
			// ���� �������� � ����
			if(!ISRectangleAtForwardLine())
			{
				StopCheck();
				Autodrom.SendAutodromEvent(self, 1024);
				return;
			}

			// ���, ���� ������ ������ � �������������
			if(IsRectangleInside())
			{
				CurrentState = CS_Stop;
				// ��������� "������������ �� � ����������� ���������"
				Autodrom.SendAutodromEvent(self, GOROD_EVENT_STOP);
				ResetCountDown();
			}
			break;
		case CS_Stop:
			// ���� �������� ��������
			if(IsRectangleAboveForward())
			{
				StopCheck();
				Autodrom.SendAutodromEvent(self, 1024);
				return;
			}

			// ��� ���� ������ �����������, ��� ���� ���������, ����� ��� �� ������� �� ������� ��������������
			if(VehicleIsStoped())
			{
 				if(!IsRectangleInside())
				{
					// ������: ��� ��������� �� �� ������ ����� �������� ���������� ���������� �� �������� ������� �������� ��
					// ��� ������ ����� "����"
					Autodrom.SendAutodromEvent(self, 1012);
				}

				// ��������� � ���������� ��������
				CurrentState = CS_Wait;
				// ��������� "���������� ��������, �� �������� ������"
				Autodrom.SendAutodromEvent(self, GOROD_EVENT_GO);
				ResetCountDown();
			}
			break;
		case CS_Wait:
			// ��� 3 �������, ��� ���� ������ ������ ���������� �� �����
			SecondsCounter += DeltaSeconds;
			
			bVehicleIsStoped = VehicleIsStoped();
			if(!bVehicleIsStoped && SecondsCounter < 3)
			{
				// ������: ����� �������� �����, ��� ����� 3� ����� ���������
				Autodrom.SendAutodromEvent(self, 1013);

				// ��������� � ���������� ����
				CurrentState = CS_BeforeDriveOut;
				ResetCountDown();
			}
			else if(!bVehicleIsStoped && SecondsCounter > 3)
			{
				// ��������� � ���������� ����
				CurrentState = CS_BeforeDriveOut;
				ResetCountDown();
			}
			else if(bVehicleIsStoped && SecondsCounter >= 30)
			{
				// ������: �� ����� �������� � ������� 30� ����� ���������
				Autodrom.SendAutodromEvent(self, 1014);

				// ��������� � ���������� ����
				CurrentState = CS_BeforeDriveOut;
				ResetCountDown();
			}
			break;
		case CS_BeforeDriveOut:
			DriveOutInitialLoc = VehicleForCheck.Location;
			DriveOutInitialRot = VehicleForCheck.Rotation;
			bWasDriveBack = false;
			CurrentState = CS_DriveOut;
			ResetCountDown();
			break;
		case CS_DriveOut:
			// ��������� �������� ������

			// ���� �� ���� ������������� ������ �����
			if(!bWasDriveBack)
			{
				// ���� ����� ����������� Rotation'�� � ������������ �������� ������ � ������ ������
				CurrentDeltaAngle = RadToDeg*FindDeltaAngle(GetHeadingAngle(Vector(DriveOutInitialRot)), GetHeadingAngle(VehicleForCheck.Location - DriveOutInitialLoc));

				// ���� ���� �����
				if(CurrentDeltaAngle > 90 || CurrentDeltaAngle < -90)
				{
					// ���� �������� ������ ��� �� 0.3 �����
					if(VSize(DriveOutInitialLoc - VehicleForCheck.Location) > 0.3*50)
					{
						Autodrom.SendAutodromEvent(self, 1015);
						bWasDriveBack = true;
					}
				}
			}

			// ���������, ������� �� ������ �� ������� ��������������
			if(IsRectangleAboveForward())
			{
				// ��������� ���������� ����������
				StopCheck();
				Autodrom.SendAutodromEvent(self, 1003);
			}
			break;
	}
}

/** ����������, ��������� �� ������ ����� �������� ��������� �������������� */
function bool ISRectangleAtForwardLine()
{
	local Vector cp;

	PointDistToSegment(FrontLeftCornerLoc, ForwardLeftPoint.Location, ForwardRightPoint.Location, cp);
	if(cp == ForwardLeftPoint.Location)
		return false;

	PointDistToSegment(FrontRightCornerLoc, ForwardLeftPoint.Location, ForwardRightPoint.Location, cp);
	if(cp == ForwardRightPoint.Location)
		return false;

	PointDistToSegment(BackRightCornerLoc, BackwardRightPoint.Location, BackwardLeftPoint.Location, cp);
	if(cp == BackwardRightPoint.Location)
		return false;

	PointDistToSegment(BackLeftCornerLoc, BackwardRightPoint.Location, BackwardLeftPoint.Location, cp);
	if(cp == BackwardLeftPoint.Location)
		return false;

	return true;
}

DefaultProperties
{
}
