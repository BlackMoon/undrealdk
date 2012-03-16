class Kamaz_Checker_Exercise7 extends Kamaz_Cheker_ExerciseBase placeable;

`include(Gorod\Gorod_Events.uci);

var() Kamaz_ExercisePoint F_L_TireLineLoc, F_R_TireLineLoc, B_L_TireLineLoc, B_R_TireLineLoc;

enum ChekerStates_Exercise7
{
	CS_Start,
	CS_StartDrive,
	CS_StopDrive,
	CS_StartBackDrive,
	CS_BackDrive,
	CS_StopBackDrive,
	CS_DriveOut
};

var ChekerStates_Exercise7 CurrentState;

var float SecondsCounter;

simulated function StartCheck(CarX_Vehicle p)
{
	local rotator rot;

	super.StartCheck(p);
	SecondsCounter = 0;
	CurrentState = CS_Start;

	rot.Pitch = -211;
	rot.Roll = -244;
	rot.Yaw = 3124;

	AutoDrom.setBrdMeshes(vect(126335, 118920, 1836), vect(126081, 120562, 1836), rot, rot);
	Autodrom.SendAutodromEvent(self, 1006);
}

simulated function StopCheck()
{
	super.StopCheck();
	AutoDrom.showBrdMeshes(false);
}

simulated function Check(float DeltaSeconds)
{
	local Vector F_R_TireLoc, B_R_TireLoc, cp1, cp2;
	local bool bWheelWrongPosition;

	super.Check(DeltaSeconds);

	// ���� �������� ���������� ���������
	if(!bCheckStarted) return;

	SecondsCounter += DeltaSeconds;

	switch(CurrentState)
	{
		case CS_Start:
			SecondsCounter = 0;

			// �� �������� ���� �������� ��� � ������
			if(VehicleForCheck.Driver == none)
				return;

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
				// ��������� "�������� �����"
				Autodrom.SendAutodromEvent(self, GOROD_EVENT_MOVE_FORWARDS);
				ResetCountDown();
			}
			break;
		case CS_StartDrive:
			// ���, ���� ������ ������� �������������
			if(IsRectangleAboveForward())
			{
				CurrentState = CS_StopDrive;
				// ��������� "���������� �� �� ����� �������� ������ �����"
				Autodrom.SendAutodromEvent(self, GOROD_EVENT_PARK_RIGHT);
				ResetCountDown();
			}
			break;
		case CS_StopDrive:
			if(DriveBackStarted())
			{
				CurrentState = CS_StartBackDrive;
				ResetCountDown();
			}
			break;
		case CS_StartBackDrive:
			if(VehicleForCheck.CurrentGear == -1)
			{
				CurrentState = CS_BackDrive;
				ResetCountDown();
			}
			break;
		case CS_BackDrive:
			if(VehicleForCheck.CurrentGear != -1)
			{
				F_R_TireLoc =  VehicleForCheck.Mesh.GetBoneLocation('F_R_Tire');
				B_R_TireLoc =  VehicleForCheck.Mesh.GetBoneLocation('B_R_Tire');

				if(!IsRectangleInside())
				{
					// ������ ������� �� ����������� �����
					Autodrom.SendAutodromEvent(self, 1020);
				}

				bWheelWrongPosition = false;

				// ��������� ��������� ��������� ������� ������
				PointDistToSegment(F_R_TireLoc, F_L_TireLineLoc.Location, F_R_TireLineLoc.Location, cp1);
				PointDistToSegment(F_R_TireLoc, F_L_TireLineLoc.Location, B_L_TireLineLoc.Location, cp2);
				if((cp1 == F_L_TireLineLoc.Location || cp1 == F_R_TireLineLoc.Location) || (cp2 == F_L_TireLineLoc.Location || cp2 == B_L_TireLineLoc.Location))
				{
					bWheelWrongPosition = true;
				}
				
				// ��������� ��������� ������� ������� ������
				PointDistToSegment(B_R_TireLoc, F_L_TireLineLoc.Location, F_R_TireLineLoc.Location, cp1);
				PointDistToSegment(B_R_TireLoc, F_L_TireLineLoc.Location, B_L_TireLineLoc.Location, cp2);
				if((cp1 == F_L_TireLineLoc.Location || cp1 == F_R_TireLineLoc.Location) || (cp2 == F_L_TireLineLoc.Location || cp2 == B_L_TireLineLoc.Location))
				{
					bWheelWrongPosition = true;
				}

				// ������� ��������� � ������ ��������� ������������ ����
				if(bWheelWrongPosition)
				{
					Autodrom.SendAutodromEvent(self, 1019);
				}

				CurrentState = CS_DriveOut;
				// ��������� "��������� � ����� ��������"
				Autodrom.SendAutodromEvent(self, GOROD_EVENT_DRIVE_OUT_FROM_PARKING);
				ResetCountDown();
			}
			break;
		case CS_DriveOut:
			// ���� ������� �� ���� ���������� ����������
			if(IsRectangleAboveForward())
			{
				// ��������� ���������� �������, ����������� �� ���������� ����������
				if(SecondsCounter > 120)
				{
					Autodrom.SendAutodromEvent(self, 1021);
				}

				StopCheck();

				// �������� � ���������� ����������
				Autodrom.SendAutodromEvent(self, 1007);
			}
			break;
	}
}

DefaultProperties
{
}