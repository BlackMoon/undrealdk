
/** ��������� �����. ��������� �������������� �������� ��� ������ , ������� � �. �. */
class Kamaz_CMapState extends Actor;

/** ������ ������ */
var Kamaz_PlayerCar PlayerCar;

/** ���������� ������ */
var Kamaz_PlayerController PC;

/** ���������� ������ */
var PlayerStart PStart;


/** ��������� ������� �� ����� � �������� ��������� */
client reliable function ReturnMapsObjectsToInitState()
{
	local Kamaz_Game KG;	
	
	CheckPlayerCar();
	KG=Kamaz_Game(WorldInfo.Game);
	
	if(PlayerCar!=none && PC!= none && KG!=none )
	{
		PC.LeaveCar(Vehicle(PC.Pawn) );
		PlayerCar.SetLocation(Vect(200472.0,218139.0,2004.0));
		PlayerCar.CollisionComponent.SetRBPosition(Vect(200472.0,218139.0,2004.0));

		PlayerCar.Ignition = false;
		PlayerCar.bMass = false;
		PlayerCar.ClutchPedal = 1.0;
		PlayerCar.GasPedal = 0.3;  
		PlayerCar.HandBrake = true;
		PlayerCar.BrakePedal = 0;
		PlayerCar.SetCurrentGear(0);
		PlayerCar.SetLeftTurn(false);
		PlayerCar.SetRightTurn(false);
		PlayerCar.SetAlarmSignal(false);
		PlayerCar.SetSirenaSignal(false);
		
		// ������� ������� ��� �������, ������ �������� ��� ����������� �������� �� ���������� ������.
		// ������� ��� ������� ������ ���������
		KG.MissionObjectsHide();
	}
	else
	{
		`warn ("Execepted error in: Gorod_CMapState.ReturnMapsObjectsToInitState()");
	}
	

	// ���� ����� ����������. ������-�� ������ ��������� ��������, ���� ���� �� ���� ����� �� �����
	// �������� ��������
	PC.CheckerAutodrom.StopAutodromCheck();
	PC.CheckerAutodrom.SetEnadled(false);
}

/** ������������� �� ��� ���c��*/
client reliable function GoToMission(Quest_Custom quest)
{
	local Kamaz_Game KG;
	CheckPlayerCar();

	KG=Kamaz_Game(WorldInfo.Game);
	if(KG!=none)
	{	
		KG.StartMissionKismet(); // ��������� �����
		PC.bIsMission=true;
		PC.bIsMenu=false;
	}	
}

/** ������������� �� ��� ��������� ������� � ���������  */
client reliable function GoToFreeDrv(Quest_Custom quest)
{
	local Vector loc;
	local Rotator rot;
	local Quest_Autodrom questA;
	
	CheckPlayerCar();
		
	if(PlayerCar!=none && PC!= none)
	{
		loc = quest.StartPoint.CarPosition.Location;
		rot = quest.StartPoint.CarPosition.Rotation;

		PlayerCar.SetLocation(loc);
		PlayerCar.CollisionComponent.SetRBPosition(loc);
		PlayerCar.SetRotation(rot);
		PlayerCar.CollisionComponent.SetRBRotation(rot);
		PlayerCar.TryToDrive(PC.Pawn);
		
		
		PC.bIsMission=false;
		PC.bIsMenu=false;

		questA = Quest_Autodrom(quest);
		// ���� quest - ��������, �� ���. ��������
		if(questA != none)
		{
			PC.CheckerAutodrom.SetEnadled(true);
			PC.CheckerAutodrom.SetVisualHintsEnabled(questA.bVisualHintsEnabled);
		}
	}
	else
	{
		`log ("Execepted error in: Gorod_CMapState.GoToFreeDrv()");
	}
	
}

/**������������� �� ��� �������� � ������� ����*/
client reliable function GoToMenu()
{
	local Vector loc;
	local Rotator rot;
	
	
	ReturnMapsObjectsToInitState();
	
	if( PC!= none )
	{
		CheckPlayerStart();
		loc = PStart.Location;
		rot = PStart.Rotation;
		if(PC.Pawn!=none)
		{
			PC.Pawn.SetLocation(loc);
			PC.Pawn.SetRotation(rot);
		}
		PC.SetLocation(loc);
		PC.SetRotation(rot);
		PC.IgnoreMoveInput(true);
		PC.IgnoreLookInput(true);
		//PC.StopCheckCarControlElements();   ���������������� ��� ��� ������ ��� ��� �� ���������� � UnPossess() Gorod_PlayerController � ����� � ��� ��� �� ������ ������ �������� �������� �� ������
		PC.bIsMission=false;
		PC.bIsMenu=true;
	}

}

/** ������� �������� ������ �� �����, � ������ ���� ������ ������, �������� ��������� */
function CheckPlayerCar()
{
	local Kamaz_PlayerCar PlayerC;
	if(PlayerCar==none)	
	{
		foreach AllActors(class'Kamaz_PlayerCar',PlayerC)
		{
			PlayerCar = PlayerC;
			break;
		}
	}
}
/** ���������, ���� �� ������ �� ����������. ���� ��� - ������� � ��������� */
function CheckPlayerStart()
{
	local PlayerStart PS;
	if(PStart ==none)
	{
		foreach WorldInfo.AllNavigationPoints(class'PlayerStart', PS)
		{
			PStart = PS;
			break;
		}
	}
}
DefaultProperties
{
}
